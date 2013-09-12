#
# Imports
#


#
# Settings
#

const FingerPositions = 7

const Style =
  fingerboard:
    string_width: 50
    fret_height: 50
    note_radius: 20

  keyboard:
    octaves: 2
    key_width: 25
    key_spacing: 3
    white_key_height: 120
    black_key_height: 90

  scales:
    constellation_radius: 28
    pitch_radius: 3


#
# D3
#

d3.music or= {}

d3.music.keyboard = (model, attributes) ->
  const style = attributes
  const octaves = attributes.octaves
  const stroke_width = 1
  const attrs =
    scale: model.scale
    tonic_pitch: model.tonic_pitch
  const dispatcher = d3.dispatch \focus_pitch \blur_pitch \tap_pitch
  selection = null

  my.on = (...args) -> dispatcher.on ...args

  my.attr = (key, value) ->
    return attrs[key] if arguments.length < 2
    unless attrs[key] == value
      attrs[key] = value
      update!
    return my

  function my _selection
    selection := _selection
    const keys = [0 til 12 * octaves].map (pitch) ->
      pitch_class = pitch_to_pitch_class(pitch)
      is_black_key = FlatNoteNames[pitch_class].length > 1
      pitch_class_name = pitch_name pitch, {+flat}
      height = (if is_black_key then style.black_key_height else style.white_key_height)
      return {pitch, pitch_class, pitch_class_name, is_black_key, attrs: {width: style.key_width, height, y: 0}}

    x = stroke_width
    for {{width}:attrs, is_black_key} in keys
      attrs.x = x
      attrs.x -= width / 2 if is_black_key
      x += width + style.key_spacing unless is_black_key

    # order the black keys on top of (following) the white keys
    keys.sort (a, b) -> a.is_black_key - b.is_black_key

    const white_key_count = octaves * 7
    root = selection.append \svg
      .attr do
        width: white_key_count * (style.key_width + style.key_spacing) - style.key_spacing + 2 * stroke_width
        height: style.white_key_height + 1

    key_views = root.selectAll \.piano-key
      .data(keys).enter!
        .append \g
          .attr \class -> "pitch-#{it.pitch} pitch-class-#{it.pitch_class}"
          .classed \piano-key true
          .classed \black-key (.is_black_key)
          .classed \white-key, -> (not it.is_black_key)
          .on \click, -> dispatcher.tap_pitch it.pitch
          .on \mouseover, -> dispatcher.focus_pitch it.pitch
          .on \mouseout, -> dispatcher.blur_pitch it.pitch

    key_views.append \rect
      .attr do
        x: ({attrs}) -> attrs.x
        y: ({attrs}) -> attrs.y
        width: ({attrs}) -> attrs.width
        height: ({attrs}) -> attrs.height

    key_views.append \text
      .classed \flat-label, true
      .attr do
        x: ({{x, width}:attrs}) -> x + width / 2
        y: ({{y, height}:attrs}) -> y + height - 6
      .text -> FlatNoteNames[it.pitch_class]

    key_views.append \text
      .classed \sharp-label, true
      .attr do
        x: ({{x, width}:attrs}) -> x + width / 2
        y: ({{y, height}:attrs}) -> y + height - 6
      .text -> SharpNoteNames[it.pitch_class]

    key_views.append \title .text (-> "Click to set the scale tonic to #{it.pitch_class_name}.")

    update!

  update = ->
    selection.selectAll \.piano-key
      .classed \root, -> pitch_to_pitch_class(it.pitch - model.scale_tonic_pitch) == 0
      .classed \scale-note, -> pitch_to_pitch_class(it.pitch - model.scale_tonic_pitch) in model.scale.pitch_classes
      .classed \fifth, -> pitch_to_pitch_class(it.pitch - model.scale_tonic_pitch) == 7

  return my


d3.music.pitch-constellation = (pitch_classes, attributes) ->
  const style = attributes

  (selection) ->
    const r = style.constellation_radius
    const note_radius = style.pitch_radius
    const pc_width = 2 * (r + note_radius + 1)

    root = selection.append \svg
      .attr width: pc_width, height: pc_width
      .append \g
        .attr transform: "translate(#{pc_width / 2}, #{pc_width / 2})"

    const endpoints = Pitches.map (pitch_class) ->
      a = (pitch_class - 3) * 2 * Math.PI / 12
      x = Math.cos(a) * r
      y = Math.sin(a) * r
      chromatic = pitch_class not in pitch_classes
      return {x, y, chromatic, pitch_class}

    root.selectAll \line
      .data endpoints
      .enter!
        .append \line
          .classed \chromatic (.chromatic)
          .attr \x2 (.x)
          .attr \y2 (.y)

    root.selectAll \circle
      .data endpoints
      .enter!
        .append \circle
          .attr \class -> "relative-pitch-class-#{it.pitch_class}"
          .classed \chromatic (.chromatic)
          .classed \root (.pitch_class == 0)
          .classed \fifth (.pitch_class == 7)
          .attr \cx (.x)
          .attr \cy (.y)
          .attr \r note_radius


d3.music.fingerboard = (model, attributes) ->
  const style = attributes
  const label_sets = <[ notes fingerings scale-degrees ]>
  const dispatcher = d3.dispatch \focus_pitch \blur_pitch \tap_pitch
  const attrs =
    instrument: model.instrument
    note_label: null
    scale: model.scale
    tonic_pitch: model.scale_tonic_pitch
  const cached = {}
  d3_notes = null

  my.on = (...args) -> dispatcher.on ...args

  function my selection
    const instrument = attrs.instrument
    const string_count = instrument.string_pitches.length
    const finger_positions = []

    for string_number from 0 til string_count
      for fret_number from 0 to FingerPositions
        pitch = fingerboard_position_pitch {instrument, string_number, fret_number}
        finger_positions.push {
          string_number
          fret_number
          pitch
          pitch_class: pitch_to_pitch_class(pitch)
          fingering_name: String Math.ceil(fret_number / 2)
        }

    root = selection
      .append \svg
        .attr width: string_count * style.string_width
        .attr height: (1 + FingerPositions) * style.fret_height

    # nut
    root.append \line
      .classed \nut true
      .attr do
        x2: string_count * style.string_width
        transform: "translate(0, #{style.fret_height - 5})"

    # strings
    root.selectAll \.string
      .data [0 til string_count]
      .enter!
        .append \line
          .classed \string true
          .attr do
            y1: style.fret_height * 0.5
            y2: (1 + FingerPositions) * style.fret_height
            transform: -> "translate(#{(it + 0.5) * style.string_width}, 0)"

    # finger positions
    d3_notes := root.selectAll \.finger-position
      .data finger_positions
      .enter!
        .append \g
          .classed \finger-position true
          .attr transform: ({string_number, fret_number}) ->
            const dx = (string_number + 0.5) * style.string_width
            const dy = fret_number * style.fret_height + style.note_radius + 1
            "translate(#{dx}, #{dy})"
          .on \click, -> dispatcher.tap_pitch it.pitch
          .on \mouseover, -> dispatcher.focus_pitch it.pitch
          .on \mouseout, -> dispatcher.blur_pitch it.pitch

    d3_notes.append \circle
      .attr r: style.note_radius
    d3_notes.append \title

    const text_y = 7
    note_labels = d3_notes.append \text .classed \note true .attr y: text_y
    note_labels.append \tspan .classed \base true
    note_labels.append \tspan .classed \accidental true .classed \flat true .classed \flat-label true
    note_labels.append \tspan .classed \accidental true .classed \sharp true .classed \sharp-label true
    d3_notes.append \text
      .classed \fingering true
      .attr y: text_y
      .text (.fingering_name)
    d3_notes.append \text
      .classed \scale-degree true
      .attr y: text_y

    update!

  my.attr = (key, value) ->
    throw "Unknown key #{key}" unless key of attrs
    return attrs[key] unless arguments.length > 1
    unless attrs[key] == value
      attrs[key] = value
      update!
    return my

  update = ->
    return if cached.instrument == attrs.instrument
      and cached.scale == attrs.scale
      and cached.tonic == attrs.tonic

    update_instrument!

    const scale = cached.scale = attrs.scale
    const tonic_pitch = cached.tonic = attrs.tonic_pitch
    const scale_relative_pitch_classes = scale.pitch_classes

    attrs.note_label or= label_sets.0
    for k in label_sets
      const visible = k == attrs.note_label.replace /_/g '-'
      const labels = d3.select \#fingerboard .selectAll '.' + k.replace /s$/ ''
      labels.attr \visibility (if visible then 'inherit' else 'hidden')

    d3_notes.each ({pitch}:note) ->
      note.relative_pitch_class = pitch_to_pitch_class(pitch - tonic_pitch)

    d3_notes
      .attr \class, -> "pitch-class-#{it.pitch_class} relative-pitch-class-#{it.relative_pitch_class}"
      .classed \finger-position true
      .classed \scale, -> it.relative_pitch_class in scale_relative_pitch_classes
      .classed \chromatic, -> it.relative_pitch_class not in scale_relative_pitch_classes
      .select \.scale-degree
        .text ""
        .text -> ScaleDegreeNames[it.relative_pitch_class]

    d3_notes.each ({pitch}) ->
      note_labels = d3.select this

  update_instrument = ->
    return if cached.instrument == attrs.instrument
    const instrument = cached.instrument = attrs.instrument
    const scale_tonic_name = attrs.scale_tonic_name

    const string_pitches = instrument.string_pitches
    d3_notes.each ({string_number, fret_number}:note) ->
      note.pitch =  fingerboard_position_pitch {instrument, string_number, fret_number}
      note.pitch_class = pitch_to_pitch_class(note.pitch)

    const pitch_name_options = if scale_tonic_name == /\u266D/ then {+flat} else {+sharp}
    select_pitch_name_component = (component, {pitch, pitch_class}) -->
      const name = pitch_name pitch, pitch_name_options
      switch component
      | \base => name - /[^\w]/
      | \accidental => name - /[\w]/
      | \flat => FlatNoteNames[pitch_class].slice(1)
      | \sharp => SharpNoteNames[pitch_class].slice(1)

    d3_notes.each ({string_number, fret_number, pitch}:note) ->
      note_labels = d3.select this .select \.note
      note_labels.select \.base .text select_pitch_name_component \base
      note_labels.select \.flat .text select_pitch_name_component \flat
      note_labels.select \.sharp .text select_pitch_name_component \sharp

    d3_notes.select \title .text (-> "Click to set the scale tonic to #{FlatNoteNames[it.pitch_class]}.")

  return my


d3.music.note-grid = (model, style, referenceElement) ->
  const column_count = style.columns ? 12 * 5
  const row_count = style.rows ? 12
  cached_offset = null
  selection = null

  function my _selection
    selection := _selection
    const notes = [{column, row} for column in [0 til column_count] for row in [0 til row_count]]
    for note in notes then note.relative_pitch_class = pitch_to_pitch_class note.column * 7 + note.row
    degree_groups = d3.nest!
      .key (.relative_pitch_class)
      .entries notes
    for degree in degree_groups then degree.relative_pitch_class = Number(degree.key)

    root = selection
      .append \svg
        .attr do
          width: column_count * style.string_width
          height: row_count * style.fret_height

    note_views = root.selectAll \.scale-degree
      .data degree_groups
      .enter!
        .append \g
          .classed \scale-degree true
          .selectAll \.note
          .data (.values)
          .enter!
            .append \g
              .classed \note true
              .attr transform: ({column, row}) ->
                  x = (column + 0.5) * style.string_width
                  y = row * style.fret_height + style.note_radius
                  "translate(#{x}, #{y})"

    note_views.append \circle
      .attr r: style.note_radius
    note_views.append \text
      .attr y: 7
      .text -> ScaleDegreeNames[it.relative_pitch_class]

    setTimeout (-> selection.classed \animate true), 1 # don't animate to the initial position

  my.update = ->
    update_note_colors!
    update_position!

  function update_note_colors
    scale_pitch_classes = model.scale.pitch_classes
    selection.selectAll \.scale-degree
      .classed \chromatic ({relative_pitch_class}) -> relative_pitch_class not in scale_pitch_classes
      .classed \tonic ({relative_pitch_class}) -> relative_pitch_class in scale_pitch_classes and relative_pitch_class == 0
      .classed \fifth ({relative_pitch_class}) -> relative_pitch_class in scale_pitch_classes and relative_pitch_class == 7

  update_position = ->
    const scale_tonic = model.scale_tonic_pitch
    const bass_pitch = model.instrument.string_pitches.0
    const offset = style.string_width * pitch_to_pitch_class((scale_tonic - bass_pitch) * 5)

    return if offset == cached_offset # profiled
    cached_offset := offset
    pos = $(referenceElement).offset!

    # FIXME why the fudge factor?
    # FIXME why doesn't work?: @selection.attr
    selection.each ->
      $(@).css left: pos.left - offset + 1, top: pos.top + 1

  return my


#
# Angular
#

module = angular.module 'FingerboardApp', ['ui.bootstrap']

@FingerboardScalesCtrl = ($scope) ->
  for k, v of MusicTheory then window[k] = v
  # $scope.aboutText = document.querySelector('#about-text').outerHTML
  $scope.aboutText = $('#about-text').html!
  $scope.scales = Scales
  $scope.instruments = Instruments
  $scope.instrument = Instruments.Violin
  $scope.scale = Scales.0.modes.0
  $scope.scale_tonic_name = \C
  $scope.scale_tonic_pitch = 0
  $scope.hover =
    pitch_classes: null
    scale_tonic_pitch: null

  $scope.handleKey = (event) ->
    char = String.fromCharCode(event.charCode).toUpperCase()
    switch char
    when 'A', 'B', 'C', 'D', 'E', 'F', 'G' then
      $scope.scale_tonic_name = char
      $scope.scale_tonic_pitch = pitch_name_to_number char
    when '#', '+' then
      $scope.scale_tonic_pitch += 1
      $scope.scale_tonic_pitch %%= 12
      $scope.scale_tonic_name = pitch_name $scope.scale_tonic_pitch
    when 'b', '-' then
      $scope.scale_tonic_pitch -= 1
      $scope.scale_tonic_pitch %%= 12
      $scope.scale_tonic_name = pitch_name $scope.scale_tonic_pitch
    # when '\015' then $scope.apply ->
    # else console.info char, event.charCode

  $scope.setInstrument = (instr) ->
    $scope.instrument = instr if instr?

  $scope.setScale = (s) ->
    $scope.scale = s.modes?[s.mode_index] or s

  $scope.bodyClassNames = ->
    const hover = $scope.hover
    const scale_tonic = hover.scale_tonic_pitch ? $scope.scale_tonic_pitch
    const scale_pitch_classes = hover.scale?.pitch_classes ? $scope.scale.pitch_classes
    const show_sharps = (FlatNoteNames[pitch_to_pitch_class(scale_tonic)].length == 1) xor FlatNoteNames[pitch_to_pitch_class(scale_tonic)] == /F/
    classes = []
    classes.push (if show_sharps then \hide-flat-labels else \hide-sharp-labels)
    classes ++= ["scale-includes-relative-pitch-class-#{n}" for n in scale_pitch_classes]
    classes ++= ["scale-includes-pitch-class-#{pitch_to_pitch_class(n + scale_tonic)}" for n in scale_pitch_classes]
    if hover.pitch?
      classes.push "hover-note-relative-pitch-class-#{pitch_to_pitch_class(hover.pitch - scale_tonic)}"
      classes.push "hover-note-pitch-class-#{pitch_to_pitch_class(hover.pitch)}"
    classes

  const note-grid = d3.music.note-grid $scope, Style.fingerboard, document.querySelector('#fingerboard')
  d3.select(\#scale-notes).call note-grid
  $scope.$watch -> note-grid.update!

  $('#fingerings .btn').click ->
    $('#fingerings .btn').removeClass \btn-default
    $(@).addClass \btn-default
    note_label_name = $(@).text!.replace(' ', '_').toLowerCase!.replace(\fingers, \fingerings)
    $scope.$apply ->
      $scope.note_label = note_label_name

  angular.element(document).bind \touchmove false
  angular.element(document.body).removeClass \loading

module.directive \fingerboard, ->
  restrict: 'CE'
  link: (scope, element, attrs) ->
    const fingerboard = d3.music.fingerboard scope, Style.fingerboard
    d3.select(element.0).call fingerboard
    scope.$watch ->
      fingerboard.attr \note_label, scope.note_label
      fingerboard.attr \scale, scope.scale
      fingerboard.attr \tonic_pitch, scope.scale_tonic_pitch
    fingerboard.on \tap_pitch, (pitch) ->
      scope.$apply ->
        scope.scale_tonic_name = pitch_name(pitch)
        scope.scale_tonic_pitch = pitch
    fingerboard.on \focus_pitch, (pitch) ->
      scope.$apply -> scope.hover.pitch = pitch
    fingerboard.on \blur_pitch, ->
      scope.$apply -> scope.hover.pitch = null

module.directive \pitchConstellation, ->
  restrict: 'CE'
  replace: true
  scope: {pitch_classes: '=', pitches: '=', hover: '='}
  transclude: true
  link: (scope, element, attrs) ->
    const constellation = d3.music.pitch-constellation scope.pitches, Style.scales
    d3.select(element.0).call constellation

module.directive \keyboard, ->
  restrict: 'CE'
  link: (scope, element, attrs) ->
    const keyboard = d3.music.keyboard scope, Style.keyboard
    d3.select(element.0).call keyboard
    scope.$watch ->
      keyboard.attr \tonic_pitch, scope.scale_tonic_pitch
      keyboard.attr \scale, scope.scale
    keyboard.on \tap_pitch, (pitch) ->
      scope.$apply ->
        scope.scale_tonic_name = pitch_name pitch
        scope.scale_tonic_pitch = pitch
    keyboard.on \focus_pitch, (pitch) ->
      scope.$apply ->
        scope.hover.pitch = pitch
        scope.hover.scale_tonic_pitch = pitch
    keyboard.on \blur_pitch, ->
      scope.$apply ->
        scope.hover.pitch = null
        scope.hover.scale_tonic_pitch = null

module.directive \unsafePopoverPopup, ->
  restrict: 'EA'
  replace: true
  scope: {title: '@', content: '@', placement: '@', animation: '&', isOpen: '&'}
  templateUrl: 'templates/popover.html'
.directive \unsafePopover, ($tooltip) ->
  $tooltip \unsafePopover \popover \click
