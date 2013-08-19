const SharpNoteNames = <[ C C# D D# E F F# G G# A A# B ]>
const FlatNoteNames = <[ C Db D Eb E F Gb G Ab A Bb B ]>
const ScaleDegreeNames = <[ 1 b2 2 b3 3 4 b5 5 b6 6 b7 7 ]> .map (.replace /(\d)/ '$1\u0302' .replace /b/g '\u266D')

const Scales =
  * name: 'Diatonic Major'
    pitches: [0 2 4 5 7 9 11]
  * name: 'Natural Minor'
    pitches: [0 2 3 5 7 8 10]
  * name: 'Major Pentatonic'
    pitches: [0 2 4 7 9]
  * name: 'Minor Pentatonic'
    pitches: [0 3 5 7 10]
  * name: 'Melodic Minor'
    pitches: [0 2 3 5 7 9 11]
  * name: 'Harmonic Minor'
    pitches: [0 2 3 5 7 8 11]
  * name: 'Blues'
    pitches: [0 3 5 6 7 10]
  * name: 'Freygish'
    pitches: [0 1 4 5 7 8 10]
  * name: 'Whole Tone'
    pitches: [0 2 4 6 8 10]
  * name: 'Octatonic'
    pitches: [0 2 3 5 6 8 9 11]

do ->
  for scale in Scales then Scales[scale.name] = scale

pitch_name_to_number = (pitch_name) ->
  pitch = FlatNoteNames.indexOf pitch_name
  pitch = SharpNoteNames.indexOf pitch_name unless pitch >= 0
  return pitch

pitch_number_to_name = (pitch_number) ->
  pitch = pitch_class(pitch_number)
  SharpNoteNames.indexOf(pitch) or FlatNoteNames.indexOf(pitch)

const Instruments =
  * name: 'Violin'
    string_pitches: [7 14 21 28]
  * name: 'Viola'
    string_pitches: [0 7 14 21]
  * name: 'Cello'
    string_pitches: [0 7 14 21]

do ->
  for instrument in Instruments then Instruments[instrument.name] = instrument

State =
  instrument: Instruments.Violin
  scale: Scales.0
  scale_tonic_name: \C
  scale_tonic_pitch:~
    -> SharpNoteNames.indexOf(@scale_tonic_name) or FlatNoteNames.indexOf(@scale_tonic_name)

const StringCount = 4
const FingerPositions = 7

const Style =
  fingerboard:
    string_width: 50
    fret_height: 50
    note_radius: 20

  keyboard:
    key_width: 25
    key_spacing: 3
    white_key_height: 120
    black_key_height: 90

  scales:
    constellation_radius: 28
    pitch_radius: 3

const Pitches = [0 til 12]

pitch_at = (string_number, fret_number) ->
  pitch_class string_number * 7 + fret_number

pitch_class = (pitch) ->
  pitch %% 12

pitch_name = (pitch, options={}) ->
  flatName = FlatNoteNames[pitch]
  sharpName = SharpNoteNames[pitch]
  name = if options.sharp then sharpName else flatName
  if options.flat and options.sharp and flatName != sharpName
    name = "#{flatName}/\n#{sharpName}"
  name.replace /b/ '\u266D' .replace /#/g '\u266F'

d3.{}music.keyboard = (model, attributes) ->
  style = attributes
  key_count = 7
  my.dispatcher = dispatcher = d3.dispatch \mouseover \mouseout \tonic \update
  my.update = -> dispatcher.update!

  function my selection
    keys = Pitches.map (pitch) ->
      is_black_key = FlatNoteNames[pitch].length > 1
      note_name = pitch_name pitch, flat: true
      height = (if is_black_key then style.black_key_height else style.white_key_height)
      return {pitch, name: note_name, is_black_key, attrs: {width: style.key_width, height, y: 0}}

    x = 1
    for {{width}:attrs, is_black_key} in keys
      attrs.x = x
      attrs.x -= width / 2 if is_black_key
      x += width + style.key_spacing unless is_black_key

    # order the black keys on top of (following) the while keys
    keys.sort (a, b) -> a.is_black_key - b.is_black_key

    root = selection.append \svg
      .attr do
        width: key_count * (style.key_width + style.key_spacing)
        height: style.white_key_height + 1

    onclick = ({pitch, name}) ->
      model.scale_tonic_name = FlatNoteNames[pitch]
      model.scale_tonic_pitch = pitch
      update!
      dispatcher.tonic model.scale_tonic_name

    key_views = root.selectAll \.piano-key
      .data(keys).enter!
        .append \g
          .attr \class -> "scale-note-#{it.pitch}"
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

    dispatcher.on \update -> update!
    update!

  return my


d3.{}music.pitch-constellation = (pitches, attributes) ->
  style = attributes

  (selection) ->
    r = style.constellation_radius
    note_radius = style.pitch_radius
    pc_width = 2 * (r + note_radius + 1)

    root = selection.append \svg
      .attr width: pc_width, height: pc_width
      .append \g
        .attr transform: "translate(#{pc_width / 2}, #{pc_width / 2})"

    endpoints = Pitches.map (pitch) ->
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
          .attr \class -> "scale-note-#{it.pitch}"
          .classed \chromatic (.chromatic)
          .classed \root (.pitch == 0)
          .classed \fifth (.pitch == 7)
          .attr \cx (.x)
          .attr \cy (.y)
          .attr \r note_radius


d3.{}music.fingerboard = (model, attributes) ->
  style = attributes
  label_sets = <[ notes fingerings scale-degrees ]>
  my.dispatcher = dispatcher = d3.dispatch \mouseover \mouseout \update
  d3_notes = null
  note_label = null

  function my selection
    finger_positions = []
    for string_number from 0 til StringCount
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
        .attr width: StringCount * style.string_width
        .attr height: FingerPositions * style.fret_height

    # nut
    root.append \line
      .classed \nut true
      .attr do
        x2: StringCount * style.string_width
        transform: "translate(0, #{style.fret_height - 5})"

    # strings
    root.selectAll \.string
      .data [0 til StringCount]
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

  my.update = ->
    update_instrument!

    scale_tonic = model.scale_tonic_pitch
    scale = model.scale
    scale_pitches = [pitch_class(pitch + scale_tonic) for pitch in scale.pitches]
    tonic = scale_pitches.0

    note_label := note_label or \notes
    for k in label_sets
      visible = k == note_label.replace /_/g '-'
      labels = d3.select \#fingerboard .selectAll '.' + k.replace /s$/ ''
      labels.attr \visibility (if visible then 'inherit' else 'hidden')

    d3_notes.attr \class -> "scale-note-#{pitch_class it.pitch - tonic}"

    d3_notes.each ({pitch}) ->
      scale_degree = pitch_class pitch - tonic
      # d3.select this .select \scale-degree .text 'x'
      note_label = d3.select this
        .classed \finger-position true
        .classed \scale pitch in scale_pitches
        .classed \chromatic pitch not in scale_pitches
        .classed \root scale_degree == 0
        .classed \fifth scale_degree == 7
        .select \.scale-degree .text ({pitch}) -> ScaleDegreeNames[pitch_class pitch - tonic]

  update_instrument = ->
    string_pitches = model.instrument.string_pitches
    scale_tonic_name = model.scale_tonic_name
    pitch_name_options = if scale_tonic_name == /b/ then {+sharp} else {+flat}
    select_pitch_name_component = (component) -> ({pitch}) ->
      name = pitch_name pitch, pitch_name_options
      switch component
      | \base => name.replace /(.).*/ '$1'
      | \accidental => name.replace /^./ ''

    d3_notes.each ({string_number, fret_number, pitch}:note) ->
      note.pitch = pitch_class string_pitches[string_number] + fret_number
      note_label = d3.select this .select \.note
      note_label.select \.base .text select_pitch_name_component \base
      note_label.select \.accidental .text select_pitch_name_component \accidental

  return my


d3.music.note-grid = (model, style, referenceElement) ->
  column_count = style.columns ? 12 * 5
  row_count = style.rows ? 12
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

module = angular.module 'FingerboardScales', []

@FingerboardScalesCtrl = ($scope) ->
  $('#about-text a').attr \target \_blank
  $('#about').popover content: $('#about-text').html!, html: true, placement: \bottom
  $scope.instrument = Instruments.Violin
  $scope.scales = Scales
  $scope.scale = Scales.0
  $scope.scale_tonic_name = \C
  $scope.scale_tonic_pitch = 0
  $scope.setScale = (s) -> $scope.scale = s
  $scope.bodyClassNames = ->
    tonic = $scope.scale_tonic_pitch
    classes = ["scale-includes-#{pitch_class(n + tonic)}" for n in $scope.scale.pitches]
    classes.push "hover-scale-note-#{pitch_class($scope.hover_pitch - tonic)}" if $scope.hover_pitch >= 0
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
    note_label_name = $(@).text!.replace(' ', '_').toLowerCase!
    $scope.$apply ->
      $scope.note_label = note_label_name

module.directive 'fingerboard', ->
  restrict: 'CE'
  link: (scope, element, attrs) ->
    fingerboard = d3.music.fingerboard scope, Style.fingerboard
    d3.select(element.context).call fingerboard
    scope.$watch -> fingerboard.update!
    fingerboard.dispatcher.on \mouseover, (pitch) ->
      scope.$apply -> scope.hover_pitch = pitch
    fingerboard.dispatcher.on \mouseout, ->
      scope.$apply -> scope.hover_pitch = null

module.directive 'pitchConstellation', ->
  restrict: 'CE'
  replace: true
  scope: {pitches: '=pitches'}
  transclude: true
  link: (scope, element, attrs) ->
    constellation = d3.music.pitch-constellation scope.pitches, Style.scales
    d3.select(element.context).call constellation

module.directive 'keyboard', ->
  restrict: 'CE'
  link: (scope, element, attrs) ->
    keyboard = d3.music.keyboard scope, Style.keyboard
    d3.select(element.context).call keyboard
    keyboard.dispatcher.on \tonic, (tonic_name) ->
      scope.$apply ->
        scope.scale_tonic_name = tonic_name
        scope.scale_tonic_pitch = pitch_name_to_number(tonic_name)
    keyboard.dispatcher.on \mouseover, (pitch) ->
      scope.$apply -> scope.hover_pitch = pitch
    keyboard.dispatcher.on \mouseout, ->
      scope.$apply -> scope.hover_pitch = null
