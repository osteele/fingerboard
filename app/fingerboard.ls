#
# Music Theory
#

const SharpNoteNames = <[ C C# D D# E F F# G G# A A# B ]> .map (.replace /#/ '\u266F')
const FlatNoteNames = <[ C Db D Eb E F Gb G Ab A Bb B ]> .map (.replace /b/ '\u266D')
const ScaleDegreeNames = <[ 1 b2 2 b3 3 4 b5 5 b6 6 b7 7 ]> .map (.replace /(\d)/ '$1\u0302' .replace /b/ '\u266D')

const Pitches = [0 til 12]

pitch_name_to_number = (pitch_name) ->
  pitch = FlatNoteNames.indexOf pitch_name
  pitch = SharpNoteNames.indexOf pitch_name unless pitch >= 0
  return pitch

pitch_number_to_name = (pitch_number) ->
  pitch = pitch_to_pitch_class(pitch_number)
  SharpNoteNames.indexOf(pitch) or FlatNoteNames.indexOf(pitch)

pitch_to_pitch_class = (pitch) ->
  pitch %% 12

pitch_name = (pitch, options={}) ->
  pitch_class = pitch_to_pitch_class(pitch)
  flatName = FlatNoteNames[pitch_class]
  sharpName = SharpNoteNames[pitch_class]
  name = if options.sharp then sharpName else flatName
  if options.flat and options.sharp and flatName != sharpName
    name = "#{flatName}/\n#{sharpName}"
  name

const Scales =
  * name: 'Diatonic Major'
    pitch_classes: [0 2 4 5 7 9 11]
    mode_names: <[ Ionian Dorian Phrygian Lydian Mixolydian Aeolian Locrian ]>
  * name: 'Natural Minor'
    pitch_classes: [0 2 3 5 7 8 10]
    mode_of: 'Diatonic Major'
  * name: 'Major Pentatonic'
    pitch_classes: [0 2 4 7 9]
    mode_names: ['Major Pentatonic' 'Suspended Pentatonic' 'Man Gong' 'Ritusen' 'Minor Pentatonic']
  * name: 'Minor Pentatonic'
    pitch_classes: [0 3 5 7 10]
    mode_of: 'Major Pentatonic'
  * name: 'Melodic Minor'
    pitch_classes: [0 2 3 5 7 9 11]
    mode_names: ['Jazz Minor' 'Dorian b2' 'Lydian Augmented' 'Lydian Dominant' 'Mixolydian b6' 'Semilocrian' 'Superlocrian']
  * name: 'Harmonic Minor'
    pitch_classes: [0 2 3 5 7 8 11]
    mode_names: ['Harmonic Minor' 'Locrian #6' 'Ionian Augmented' 'Romanian' 'Phrygian Dominant' 'Lydian #2' 'Ultralocrian']
  * name: 'Blues'
    pitch_classes: [0 3 5 6 7 10]
  * name: 'Freygish'
    pitch_classes: [0 1 4 5 7 8 10]
  * name: 'Whole Tone'
    pitch_classes: [0 2 4 6 8 10]
  * name: 'Octatonic'
    pitch_classes: [0 2 3 5 6 8 9 11]

do ->
  for {name, mode_names, pitch_classes}:scale in Scales
    Scales[name] = scale
  rotate = (pitch_classes, i) ->
    i %%= pitch_classes.length
    pitch_classes = pitch_classes.slice(i) ++ pitch_classes[0 til i]
    pitch_classes.map -> pitch_to_pitch_class(it - pitch_classes[0])
  for {name, mode_names, mode_of, pitch_classes}:scale in Scales
    scale.base = base = Scales[mode_of]
    mode_names or= base?.mode_names
    if mode_names?
      scale.mode_index = 0
      [scale.mode_index] = [0 til pitch_classes.length].filter((i) -> rotate(base.pitch_classes, i) * ',' == pitch_classes * ',') if base?
      scale.modes = [{name: name.replace(/#/ '\u266F').replace(/\bb(\d)/ '\u266D$1'), pitch_classes: rotate(base?.pitch_classes or pitch_classes, i), parent: scale} for name, i in mode_names]

const Instruments =
  * name: 'Violin'
    string_pitches: [7 14 21 28]
  * name: 'Viola'
    string_pitches: [0 7 14 21]
  * name: 'Cello'
    string_pitches: [0 7 14 21]

do ->
  for instrument in Instruments then Instruments[instrument.name] = instrument

fingerboard_position_pitch = ({instrument, string_number, fret_number}) ->
  instrument.string_pitches[string_number] + fret_number


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
  my.dispatcher = dispatcher = d3.dispatch \mouseover \mouseout \tonic \update
  my.update = -> dispatcher.update!

  function my selection
    const keys = [0 til 12 * octaves].map (pitch) ->
      pitch_class = pitch_to_pitch_class(pitch)
      is_black_key = FlatNoteNames[pitch_class].length > 1
      note_name = pitch_name pitch, {+flat}
      height = (if is_black_key then style.black_key_height else style.white_key_height)
      return {pitch, pitch_class, name: note_name, is_black_key, attrs: {width: style.key_width, height, y: 0}}

    x = stroke_width
    for {{width}:attrs, is_black_key} in keys
      attrs.x = x
      attrs.x -= width / 2 if is_black_key
      x += width + style.key_spacing unless is_black_key

    # order the black keys on top of (following) the while keys
    keys.sort (a, b) -> a.is_black_key - b.is_black_key

    const white_key_count = octaves * 7
    root = selection.append \svg
      .attr do
        width: white_key_count * (style.key_width + style.key_spacing) - style.key_spacing + 2 * stroke_width
        height: style.white_key_height + 1

    onclick = ({pitch, name}) ->
      model.scale_tonic_name = FlatNoteNames[pitch]
      model.scale_tonic_pitch = pitch
      update!
      dispatcher.tonic model.scale_tonic_name

    key_views = root.selectAll \.piano-key
      .data(keys).enter!
        .append \g
          .attr \class -> "pitch-#{it.pitch} pitch-class-#{it.pitch_class}"
          .classed \piano-key true
          .classed \black-key (.is_black_key)
          .classed \white-key, -> (not it.is_black_key)
          .on \click, onclick
          .on \mouseover, -> dispatcher.mouseover it.pitch
          .on \mouseout, -> dispatcher.mouseout it.pitch

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

    update = ->
      key_views
        .classed \root, -> pitch_to_pitch_class(it.pitch - model.scale_tonic_pitch) == 0
        .classed \scale-note, -> pitch_to_pitch_class(it.pitch - model.scale_tonic_pitch) in model.scale.pitch_classes
        .classed \fifth, -> pitch_to_pitch_class(it.pitch - model.scale_tonic_pitch) == 7

    dispatcher.on \update -> update!
    update!

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
  const dispatcher = my.dispatcher = d3.dispatch \mouseover \mouseout \update
  instrument = model.instrument
  d3_notes = null
  note_label = null

  function my selection
    const string_count = model.instrument.string_pitches.length
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
            dx = (string_number + 0.5) * style.string_width
            dy = fret_number * style.fret_height + style.note_radius + 1
            "translate(#{dx}, #{dy})"
          .on \mouseover, -> dispatcher.mouseover it.pitch
          .on \mouseout, -> dispatcher.mouseout it.pitch

    d3_notes.append \circle
      .attr r: style.note_radius

    note_labels = d3_notes.append \text .classed \note true .attr y: 7
    note_labels.append \tspan .classed \base true
    note_labels.append \tspan .classed \accidental true
    note_labels.append \tspan .classed \accidental true .classed \flat true .classed \flat-label true
    note_labels.append \tspan .classed \accidental true .classed \sharp true .classed \sharp-label true
    d3_notes.append \text
      .classed \fingering true
      .attr y: 7
      .text (.fingering_name)
    d3_notes.append \text
      .classed \scale-degree true
      .attr y: 7

    dispatcher.on \update -> my.update!
    my.update!

  my.attr = (key, value) ->
    throw "Unknown key #{key}" unless key = 'note_label'
    return note_label unless arguments.length > 1
    note_label := value
    my.update!

  my.update = ->
    update_instrument!

    const scale = model.scale
    const scale_pitch_classes = scale.pitch_classes
    const scale_tonic = model.scale_tonic_pitch

    note_label := note_label or \notes
    for k in label_sets
      visible = k == note_label.replace /_/g '-'
      labels = d3.select \#fingerboard .selectAll '.' + k.replace /s$/ ''
      labels.attr \visibility (if visible then 'inherit' else 'hidden')

    d3_notes.each ({pitch}:note) ->
      note.relative_pitch_class = pitch_to_pitch_class(pitch - scale_tonic)

    d3_notes
      .attr \class, -> "pitch-class-#{it.pitch_class} relative-pitch-class-#{it.relative_pitch_class}"
      .classed \finger-position true
      .classed \scale, -> it.relative_pitch_class in scale_pitch_classes
      .classed \chromatic, -> it.relative_pitch_class not in scale_pitch_classes
      .select \.scale-degree
        .text ""
        .text -> ScaleDegreeNames[it.relative_pitch_class]

    d3_notes.each ({pitch}) ->
      note_labels = d3.select this

  update_instrument = ->
    return if instrument == model.instrument
    instrument = model.instrument

    string_pitches = instrument.string_pitches
    d3_notes.each ({string_number, fret_number}:note) ->
      note.pitch =  fingerboard_position_pitch {instrument, string_number, fret_number}
      note.pitch_class = pitch_to_pitch_class(note.pitch)

    scale_tonic_name = model.scale_tonic_name
    pitch_name_options = if scale_tonic_name == /\u266D/ then {+flat} else {+sharp}
    select_pitch_name_component = (component, {pitch, pitch_class}) -->
      name = pitch_name pitch, pitch_name_options
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
      # note_labels.select \.accidental .text select_pitch_name_component \accidental

  return my


d3.music.note-grid = (model, style, referenceElement) ->
  const column_count = style.columns ? 12 * 5
  const row_count = style.rows ? 12
  selection = null

  function my _selection
    selection := _selection
    notes = [{column, row} for column in [0 til column_count] for row in [0 til row_count]]
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

    my.update!

    setTimeout (-> selection.classed \animate true), 1

  function update_note_colors
    scale_pitch_classes = model.scale.pitch_classes

    selection.selectAll \.scale-degree
      .classed \chromatic ({relative_pitch_class}) -> relative_pitch_class not in scale_pitch_classes
      .classed \tonic ({relative_pitch_class}) -> relative_pitch_class in scale_pitch_classes and relative_pitch_class == 0
      .classed \fifth ({relative_pitch_class}) -> relative_pitch_class in scale_pitch_classes and relative_pitch_class == 7

  my.update = ->
    update_note_colors!
    scale_tonic = model.scale_tonic_pitch
    bass_pitch = model.instrument.string_pitches.0
    pos = referenceElement.offset!
    pos.left -= style.string_width * pitch_to_pitch_class((scale_tonic - bass_pitch) * 5)
    # FIXME why the fudge factor?
    # FIXME why doesn't work?: @selection.attr
    selection.each -> $(this).css left: pos.left + 1, top: pos.top + 1

  return my


#
# Angular
#

module = angular.module 'FingerboardApp', ['ui.bootstrap']

@FingerboardScalesCtrl = ($scope) ->
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

  $scope.setInstrument = (instr) ->
    $scope.instrument = instr if instr?

  $scope.setScale = (s) ->
    $scope.scale = s.modes?[s.mode_index] or s

  $scope.bodyClassNames = ->
    hover = $scope.hover
    scale_tonic = hover.scale_tonic_pitch ? $scope.scale_tonic_pitch
    scale_pitch_classes = hover.scale?.pitch_classes ? $scope.scale.pitch_classes
    classes = []
    show_sharps = (FlatNoteNames[pitch_to_pitch_class(scale_tonic)].length == 1) xor FlatNoteNames[pitch_to_pitch_class(scale_tonic)] == /F/
    classes.push (if show_sharps then \hide-flat-labels else \hide-sharp-labels)
    classes ++= ["scale-includes-relative-pitch-class-#{n}" for n in scale_pitch_classes]
    classes ++= ["scale-includes-pitch-class-#{pitch_to_pitch_class(n + scale_tonic)}" for n in scale_pitch_classes]
    if hover.pitch?
      classes.push "hover-note-relative-pitch-class-#{pitch_to_pitch_class(hover.pitch - scale_tonic)}"
      classes.push "hover-note-pitch-class-#{pitch_to_pitch_class(hover.pitch)}"
    classes

  note-grid = d3.music.note-grid $scope, Style.fingerboard, $('#fingerboard')
  d3.select(\#scale-notes).call note-grid
  $scope.$watch -> note-grid.update!

  $('#fingerings .btn').click ->
    $('#fingerings .btn').removeClass \btn-default
    $(@).addClass \btn-default
    note_label_name = $(@).text!.replace(' ', '_').toLowerCase!.replace(\fingers, \fingerings)
    $scope.$apply ->
      $scope.note_label = note_label_name

  $(document).bind \touchmove false
  $('body').removeClass \loading

module.directive \fingerboard, ->
  restrict: 'CE'
  link: ($scope, element, attrs) ->
    fingerboard = d3.music.fingerboard $scope, Style.fingerboard
    d3.select(element.context).call fingerboard
    $scope.$watch ->
      fingerboard.attr \note_label, $scope.note_label
      fingerboard.update!
    fingerboard.dispatcher.on \mouseover, (pitch) ->
      $scope.$apply -> $scope.hover.pitch = pitch
    fingerboard.dispatcher.on \mouseout, ->
      $scope.$apply -> $scope.hover.pitch = null

module.directive \pitchConstellation, ->
  restrict: 'CE'
  replace: true
  scope: {pitch_classes: '=', pitches: '=', hover: '='}
  transclude: true
  link: ($scope, element, attrs) ->
    constellation = d3.music.pitch-constellation $scope.pitches, Style.scales
    d3.select(element.context).call constellation

module.directive \keyboard, ->
  restrict: 'CE'
  link: ($scope, element, attrs) ->
    keyboard = d3.music.keyboard $scope, Style.keyboard
    d3.select(element.context).call keyboard
    $scope.$watch ->
      keyboard.update!
    keyboard.dispatcher.on \tonic, (tonic_name) ->
      $scope.$apply ->
        $scope.scale_tonic_name = tonic_name
        $scope.scale_tonic_pitch = pitch_name_to_number(tonic_name)
    keyboard.dispatcher.on \mouseover, (pitch) ->
      $scope.$apply ->
        $scope.hover.pitch = pitch
        $scope.hover.scale_tonic_pitch = pitch
    keyboard.dispatcher.on \mouseout, ->
      $scope.$apply ->
        $scope.hover.pitch = null
        $scope.hover.scale_tonic_pitch = null

module.directive \unsafePopoverPopup, ->
  restrict: 'EA'
  replace: true
  scope: {title: '@', content: '@', placement: '@', animation: '&', isOpen: '&'}
  templateUrl: 'template/popover.html'
.directive \unsafePopover, ($tooltip) ->
  $tooltip \unsafePopover \popover \click
