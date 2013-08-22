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
  pitch = pitch_class(pitch_number)
  SharpNoteNames.indexOf(pitch) or FlatNoteNames.indexOf(pitch)

pitch_class = (pitch) ->
  pitch %% 12

pitch_name = (pitch, options={}) ->
  flatName = FlatNoteNames[pitch]
  sharpName = SharpNoteNames[pitch]
  name = if options.sharp then sharpName else flatName
  if options.flat and options.sharp and flatName != sharpName
    name = "#{flatName}/\n#{sharpName}"
  name

const Scales =
  * name: 'Diatonic Major'
    pitches: [0 2 4 5 7 9 11]
    mode_names: <[ Ionian Dorian Phrygian Lydian Mixolydian Aeolian Locrian ]>
  * name: 'Natural Minor'
    pitches: [0 2 3 5 7 8 10]
    mode_of: 'Diatonic Major'
  * name: 'Major Pentatonic'
    pitches: [0 2 4 7 9]
    mode_names: ['Major Pentatonic' 'Suspended Pentatonic' 'Man Gong' 'Ritusen' 'Minor Pentatonic']
  * name: 'Minor Pentatonic'
    pitches: [0 3 5 7 10]
    mode_of: 'Major Pentatonic'
  * name: 'Melodic Minor'
    pitches: [0 2 3 5 7 9 11]
    mode_names: ['Jazz Minor' 'Dorian b2' 'Lydian Augmented' 'Lydian Dominant' 'Mixolydian b6' 'Semilocrian' 'Superlocrian']
  * name: 'Harmonic Minor'
    pitches: [0 2 3 5 7 8 11]
    mode_names: ['Harmonic Minor' 'Locrian #6' 'Ionian Augmented' 'Romanian' 'Phrygian Dominant' 'Lydian #2' 'Ultralocrian']
  * name: 'Blues'
    pitches: [0 3 5 6 7 10]
  * name: 'Freygish'
    pitches: [0 1 4 5 7 8 10]
  * name: 'Whole Tone'
    pitches: [0 2 4 6 8 10]
  * name: 'Octatonic'
    pitches: [0 2 3 5 6 8 9 11]

do ->
  for {name, mode_names, pitches}:scale in Scales
    Scales[name] = scale
  rotate = (pitches, i) ->
    i %%= pitches.length
    pitches = pitches.slice(i) ++ pitches[0 til i]
    pitches.map -> pitch_class(it - pitches[0])
  for {name, mode_names, mode_of, pitches}:scale in Scales
    scale.base = base = Scales[mode_of]
    mode_names or= base?.mode_names
    if mode_names?
      scale.mode_index = 0
      [scale.mode_index] = [0 til pitches.length].filter((i) -> rotate(base.pitches, i) * ',' == pitches * ',') if base?
      scale.modes = [{name: name.replace(/#/ '\u266F').replace(/\bb(\d)/ '\u266D$1'), pitches: rotate(base?.pitches or pitches, i), parent: scale} for name, i in mode_names]

const Instruments =
  * name: 'Violin'
    string_pitches: [7 14 21 28]
  * name: 'Viola'
    string_pitches: [0 7 14 21]
  * name: 'Cello'
    string_pitches: [0 7 14 21]

do ->
  for instrument in Instruments then Instruments[instrument.name] = instrument

pitch_at = (string_number, fret_number) ->
  pitch_class string_number * 7 + fret_number


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
    const keys = [pitch_class(i) for i in [0 til 12 * octaves]].map (pitch) ->
      is_black_key = FlatNoteNames[pitch].length > 1
      note_name = pitch_name pitch, {+flat}
      height = (if is_black_key then style.black_key_height else style.white_key_height)
      return {pitch, name: note_name, is_black_key, attrs: {width: style.key_width, height, y: 0}}

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
          .attr \class -> "scale-note-pitch-#{it.pitch}"
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
      .attr do
        x: ({{x, width}:attrs}) -> x + width / 2
        y: ({{y, height}:attrs}) -> y + height - 6
      .text ({name}) -> name

    update = ->
      key_views
        .classed \root, ({pitch}) -> pitch == model.scale_tonic_pitch
        .classed \scale-note, ({pitch}) -> pitch_class(pitch - model.scale_tonic_pitch) in model.scale.pitches
        .classed \fifth, ({pitch}) -> pitch_class(pitch - model.scale_tonic_pitch) == 7

    dispatcher.on \update -> update!
    update!

  return my


d3.music.pitch-constellation = (pitches, attributes) ->
  const style = attributes

  (selection) ->
    const r = style.constellation_radius
    const note_radius = style.pitch_radius
    const pc_width = 2 * (r + note_radius + 1)

    root = selection.append \svg
      .attr width: pc_width, height: pc_width
      .append \g
        .attr transform: "translate(#{pc_width / 2}, #{pc_width / 2})"

    const endpoints = Pitches.map (pitch) ->
      a = (pitch - 3) * 2 * Math.PI / 12
      x = Math.cos(a) * r
      y = Math.sin(a) * r
      chromatic = pitch not in pitches
      return {x, y, chromatic, pitch}

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
          .attr \class -> "scale-note-degree-#{it.pitch}"
          .classed \chromatic (.chromatic)
          .classed \root (.pitch == 0)
          .classed \fifth (.pitch == 7)
          .attr \cx (.x)
          .attr \cy (.y)
          .attr \r note_radius


d3.music.fingerboard = (model, attributes) ->
  const style = attributes
  const label_sets = <[ notes fingerings scale-degrees ]>
  const dispatcher = my.dispatcher = d3.dispatch \mouseover \mouseout \update
  d3_notes = null
  note_label = null

  function my selection
    const string_count = model.instrument.string_pitches.length
    const finger_positions = []
    for string_number from 0 til string_count
      for fret_number from 0 to FingerPositions
        pitch = pitch_at string_number, fret_number
        fingering_name = String Math.ceil(fret_number / 2)
        finger_positions.push {
          string_number
          fret_number
          pitch
          fingering_name
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

    # notes
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

    const scale_tonic = model.scale_tonic_pitch
    const scale = model.scale
    const scale_pitches = [pitch_class(pitch + scale_tonic) for pitch in scale.pitches]
    const tonic = scale_pitches.0

    note_label := note_label or \notes
    for k in label_sets
      visible = k == note_label.replace /_/g '-'
      labels = d3.select \#fingerboard .selectAll '.' + k.replace /s$/ ''
      labels.attr \visibility (if visible then 'inherit' else 'hidden')

    scale_degree = (pitch) -> pitch_class pitch - tonic

    d3_notes
      .attr \class -> "scale-note-pitch-#{it.pitch} scale-note-degree-#{pitch_class(it.pitch - tonic)}"
      .classed \finger-position true
      .classed \scale -> it.pitch in scale_pitches
      .classed \chromatic -> it.pitch not in scale_pitches
      .select \.scale-degree
        .text ""
        .text ({pitch}) -> ScaleDegreeNames[pitch_class pitch - tonic]

    d3_notes.each ({pitch}) ->
      note_labels = d3.select this

  update_instrument = ->
    string_pitches = model.instrument.string_pitches
    scale_tonic_name = model.scale_tonic_name
    pitch_name_options = if scale_tonic_name == /\u266D/ then {+flat} else {+sharp}
    select_pitch_name_component = (component, {pitch}) -->
      name = pitch_name pitch, pitch_name_options
      switch component
      | \base => name - /[^\w]/
      | \accidental => name - /[\w]/

    d3_notes.each ({string_number, fret_number, pitch}:note) ->
      note.pitch = pitch_class string_pitches[string_number] + fret_number
      note_labels = d3.select this .select \.note
      note_labels.select \.base .text select_pitch_name_component \base
      note_labels.select \.accidental .text select_pitch_name_component \accidental

  return my


d3.music.note-grid = (model, style, referenceElement) ->
  const column_count = style.columns ? 12 * 5
  const row_count = style.rows ? 12
  selection = null

  function my _selection
    selection := _selection
    notes = [{column, row} for column in [0 til column_count] for row in [0 til row_count]]
    for note in notes then note.scale_degree = pitch_class note.column * 7 + note.row
    degree_groups = d3.nest!
      .key (.scale_degree)
      .entries notes
    for degree in degree_groups then degree.scale_degree = Number(degree.key)

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
      .text -> ScaleDegreeNames[it.scale_degree]

    my.update!

    setTimeout (-> selection.classed \animate true), 1

  function update_note_colors
    scale_pitches = model.scale.pitches

    selection.selectAll \.scale-degree
      .classed \chromatic ({scale_degree}) -> scale_degree not in scale_pitches
      .classed \tonic ({scale_degree}) -> scale_degree in scale_pitches and scale_degree == 0
      .classed \fifth ({scale_degree}) -> scale_degree in scale_pitches and scale_degree == 7

  my.update = ->
    update_note_colors!
    scale_tonic = model.scale_tonic_pitch
    bass_pitch = model.instrument.string_pitches.0
    pos = referenceElement.offset!
    pos.left -= style.string_width * pitch_class((scale_tonic - bass_pitch) * 5)
    # FIXME why the fudge factors?
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
    pitches: null
    scale_tonic_pitch: null

  $scope.setInstrument = (instr) ->
    $scope.instrument = instr if instr?

  $scope.setScale = (s) ->
    $scope.scale = s.modes?[s.mode_index] or s

  $scope.bodyClassNames = ->
    tonic = $scope.hover.scale_tonic_pitch ? $scope.scale_tonic_pitch
    pitches = $scope.hover.pitches ? $scope.scale.pitches
    classes = []
    classes ++= ["scale-includes-degree-#{n}" for n in pitches]
    classes ++= ["scale-includes-pitch-#{pitch_class(n + tonic)}" for n in pitches]
    classes.push "hover-scale-note-degree-#{pitch_class(tonic - $scope.scale_tonic_pitch)}" if $scope.hover.scale_tonic_pitch?
    classes.push "hover-scale-note-pitch-#{tonic}" if $scope.hover.scale_tonic_pitch?
    classes

  note-grid = d3.music.note-grid $scope, Style.fingerboard, $('#fingerboard')
  d3.select(\#scale-notes).call note-grid
  $scope.$watch -> note-grid.update!

  $('#instruments .btn').click ->
    $('#instruments .btn').removeClass \btn-default
    $(@).addClass \btn-default
    instrument_name = $(@).text!
    $scope.$apply ->
      $scope.instrument = Instruments[instrument_name]

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
      $scope.$apply -> $scope.hover.scale_tonic_pitch = pitch
    fingerboard.dispatcher.on \mouseout, ->
      $scope.$apply -> $scope.hover.scale_tonic_pitch = null

module.directive \pitchConstellation, ->
  restrict: 'CE'
  replace: true
  scope: {pitches: '=', hover: '='}
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
      $scope.$apply -> $scope.hover.scale_tonic_pitch = pitch
    keyboard.dispatcher.on \mouseout, ->
      $scope.$apply -> $scope.hover.scale_tonic_pitch = null

module.directive \unsafePopoverPopup, ->
  restrict: 'EA'
  replace: true
  scope: {title: '@', content: '@', placement: '@', animation: '&', isOpen: '&'}
  templateUrl: 'template/popover.html'
.directive \unsafePopover, ($tooltip) ->
  $tooltip \unsafePopover \popover \click
