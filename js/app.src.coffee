#
# App
#

angular.module 'FingerboardApp', ['ui.bootstrap', 'music.directives', 'unsafe-popover', 'fingerboard.controllers']


#
# Style
#

@Style =
  fingerboard:
    stringWdith: 50
    fretHeight: 50
    noteRadius: 20

  keyboard:
    octaves: 2
    keyWidth: 25
    keyMargin: 3
    whiteKeyHeight: 120
    blackKeyHeight: 90

  scales:
    constellationRadius: 28
    pitchRadius: 3

controllers = angular.module('fingerboard.controllers', [])

controllers.controller 'FingerboardScalesCtrl', ($scope) ->
  window[k] = v for k, v of MusicTheory
  # $scope.aboutText = document.querySelector('#about-text').outerHTML
  $scope.aboutText = $('#about-text').html()
  $scope.scales = Scales
  $scope.instruments = Instruments
  $scope.instrument = Instruments.Violin
  $scope.scale = Scales[0].modes[0]
  $scope.scaleTonicName = 'C'
  $scope.scaleTonicPitch = 0
  $scope.hover =
    pitchClasses: null
    scaleTonicPitch: null

  $scope.handleKey = (event) ->
    char = String.fromCharCode(event.charCode).toUpperCase()
    switch char
      when 'A', 'B', 'C', 'D', 'E', 'F', 'G'
        $scope.scaleTonicName = char
        $scope.scaleTonicPitch = pitchNameToNumber(char)
      when '#', '+'
        $scope.scaleTonicPitch = (($scope.scaleTonicPitch + 1) % 12)
        $scope.scaleTonicName = getPitchName($scope.scaleTonicPitch)
      when 'b', '-'
        $scope.scaleTonicPitch = (($scope.scaleTonicPitch - 1 + 12) % 12)
        $scope.scaleTonicName = getPitchName($scope.scaleTonicPitch)
      # when '\015' then $scope.apply ->
      # else console.info char, event.charCode

  $scope.setInstrument = (instr) ->
    $scope.instrument = instr if instr?

  $scope.setScale = (s) ->
    $scope.scale = s.modes?[s.modeIndex] or s

  $scope.bodyClassNames = ->
    hover = $scope.hover
    scaleTonic = hover.scaleTonicPitch ? $scope.scaleTonicPitch
    scalePitchClasses = hover.scale?.pitchClasses ? $scope.scale.pitchClasses
    showSharps = Boolean(
      (FlatNoteNames[pitchToPitchClass(scaleTonic)].length == 1) ^
      (FlatNoteNames[pitchToPitchClass(scaleTonic)] == /F/)
    )
    classes = []
    classes.push (if showSharps then 'hide-flat-labels' else 'hide-sharp-labels')
    classes = classes.concat ("scale-includes-relative-pitch-class-#{n}" for n in scalePitchClasses)
    ks = ("scale-includes-pitch-class-#{pitchToPitchClass(n + scaleTonic)}" for n in scalePitchClasses)
    classes = classes.concat ks
    if hover.pitch?
      classes.push "hover-note-relative-pitch-class-#{pitchToPitchClass(hover.pitch - scaleTonic)}"
      classes.push "hover-note-pitch-class-#{pitchToPitchClass(hover.pitch)}"
    classes

  noteGrid = d3.music.noteGrid($scope, Style.fingerboard, document.querySelector('#fingerboard'))
  d3.select('#scale-notes').call noteGrid
  $scope.$watch -> noteGrid.update()

  $('#fingerings .btn').click ->
    $('#fingerings .btn').removeClass 'btn-default'
    $(@).addClass 'btn-default'
    noteLabelName = $(@).text().replace(' ', '_').toLowerCase().replace('fingers', 'fingerings')
    $scope.$apply ->
      $scope.noteLabel = noteLabelName

  angular.element(document).bind 'touchmove', false
  angular.element(document.body).removeClass 'loading'

FingerPositions = 7

d3.music or= {}

d3.music.keyboard = (model, style) ->
  octaves = style.octaves
  strokeWidth = 1
  attrs =
    scale: model.scale
    tonicPitch: model.tonicPitch
  dispatcher = d3.dispatch('focusPitch', 'blurPitch', 'tapPitch')
  selection = null

  my = (_selection) ->
    selection = _selection
    keys = [0 ... 12 * octaves].map (pitch) ->
      pitchClass = pitchToPitchClass(pitch)
      isBlackKey = FlatNoteNames[pitchClass].length > 1
      pitchClassName = getPitchName(pitch, flat: true)
      height = (if isBlackKey then style.blackKeyHeight else style.whiteKeyHeight)
      return {pitch, pitchClass, pitchClassName, isBlackKey, attrs: {width: style.keyWidth, height, y: 0}}

    x = strokeWidth
    for {attrs, isBlackKey} in keys
      {width} = attrs
      attrs.x = x
      attrs.x -= width / 2 if isBlackKey
      x += width + style.keyMargin unless isBlackKey

    # order the black keys on top of (following) the white keys
    keys.sort (a, b) -> a.isBlackKey - b.isBlackKey

    whiteKeyCount = octaves * 7
    root = selection.append('svg')
      .attr
        width: whiteKeyCount * (style.keyWidth + style.keyMargin) - style.keyMargin + 2 * strokeWidth
        height: style.whiteKeyHeight + 1

    key_views = root.selectAll('.piano-key')
      .data(keys).enter()
        .append('g')
          .attr('class', (d) -> "pitch-#{d.pitch} pitch-class-#{d.pitchClass}")
          .classed('piano-key', true)
          .classed('black-key', (d) -> (d.isBlackKey))
          .classed('white-key', (d) -> (not d.isBlackKey))
          .on('click', (d) -> dispatcher.tapPitch d.pitch)
          .on('mouseover', (d) -> dispatcher.focusPitch d.pitch)
          .on('mouseout', (d) -> dispatcher.blurPitch d.pitch)

    key_views.append('rect')
      .attr
        x: ({attrs}) -> attrs.x
        y: ({attrs}) -> attrs.y
        width: ({attrs}) -> attrs.width
        height: ({attrs}) -> attrs.height

    key_views.append('text')
      .classed('flat-label', true)
      .attr
        x: ({attrs: {x, width}}) -> x + width / 2
        y: ({attrs: {y, height}}) -> y + height - 6
      .text (d) -> FlatNoteNames[d.pitchClass]

    key_views.append('text')
      .classed('sharp-label', true)
      .attr
        x: ({attrs: {x, width}}) -> x + width / 2
        y: ({attrs: {y, height}}) -> y + height - 6
      .text (d) -> SharpNoteNames[d.pitchClass]

    key_views.append('title').text (d) -> "Click to set the scale tonic to #{d.pitchClassName}."

    update()

  my.on = (args...) -> dispatcher.on args...

  my.attr = (key, value) ->
    return attrs[key] if arguments.length < 2
    unless attrs[key] == value
      attrs[key] = value
      update()
    return my

  update = ->
    selection.selectAll('.piano-key')
      .classed('root', (d) -> pitchToPitchClass(d.pitch - model.scaleTonicPitch) == 0)
      .classed('scale-note', (d) -> pitchToPitchClass(d.pitch - model.scaleTonicPitch) in model.scale.pitchClasses)
      .classed('fifth', (d) -> pitchToPitchClass(d.pitch - model.scaleTonicPitch) == 7)

  return my


d3.music.pitchConstellation = (pitchClasses, style) ->
  (selection) ->
    r = style.constellationRadius
    noteRadius = style.pitchRadius
    pc_width = 2 * (r + noteRadius + 1)

    root =(selection.append 'svg')
      .attr(width: pc_width, height: pc_width)
      .append('g')
        .attr('transform', "translate(#{pc_width / 2}, #{pc_width / 2})")

    endpoints = Pitches.map (pitchClass) ->
      a = (pitchClass - 3) * 2 * Math.PI / 12
      x = Math.cos(a) * r
      y = Math.sin(a) * r
      chromatic = pitchClass not in pitchClasses
      return {x, y, chromatic, pitchClass}

    root.selectAll('line')
      .data(endpoints)
      .enter()
        .append('line')
          .classed('chromatic', (d) -> d.chromatic)
          .attr('x2', (d) -> d.x)
          .attr('y2', (d) -> d.y)

    root.selectAll('circle')
      .data(endpoints)
      .enter()
        .append('circle')
          .attr('class', (d) -> "relative-pitch-class-#{d.pitchClass}")
          .classed('chromatic', (d) -> d.chromatic)
          .classed('root', (d) -> d.pitchClass == 0)
          .classed('fifth', (d) -> d.pitchClass == 7)
          .attr('cx', (d) -> d.x)
          .attr('cy', (d) -> d.y)
          .attr('r', noteRadius)


d3.music.fingerboard = (model, style) ->
  label_sets = ['notes', 'fingerings', 'scale-degrees']
  dispatcher = d3.dispatch('focusPitch', 'blurPitch', 'tapPitch')
  attrs =
    instrument: model.instrument
    noteLabel: null
    scale: model.scale
    tonicPitch: model.scaleTonicPitch
  cached = {}
  d3Notes = null

  my = (selection) ->
    instrument = attrs.instrument
    string_count = instrument.stringPitches.length
    finger_positions = []

    for string_number in [0 ... string_count]
      for fret_number in [0 .. FingerPositions]
        pitch = fingerboardPositionPitch {instrument, string_number, fret_number}
        finger_positions.push {
          string_number
          fret_number
          pitch
          pitchClass: pitchToPitchClass(pitch)
          fingering_name: String Math.ceil(fret_number / 2)
        }

    root = selection
      .append('svg')
        .attr(width: string_count * style.stringWdith)
        .attr(height: (1 + FingerPositions) * style.fretHeight)

    # nut
    root.append('line')
      .classed('nut', true)
      .attr
        x2: string_count * style.stringWdith
        transform: "translate(0, #{style.fretHeight - 5})"

    # strings
    root.selectAll('.string')
      .data([0 ... string_count])
      .enter()
        .append('line')
          .classed('string', true)
          .attr
            y1: style.fretHeight * 0.5
            y2: (1 + FingerPositions) * style.fretHeight
            transform: (d) -> "translate(#{(d + 0.5) * style.stringWdith}, 0)"

    # finger positions
    d3Notes = root.selectAll('.finger-position')
      .data(finger_positions)
      .enter()
        .append('g')
          .classed('finger-position', true)
          .attr(transform: ({string_number, fret_number}) ->
            dx = (string_number + 0.5) * style.stringWdith
            dy = fret_number * style.fretHeight + style.noteRadius + 1
            "translate(#{dx}, #{dy})")
          .on('click', (d) -> dispatcher.tapPitch d.pitch)
          .on('mouseover', (d) -> dispatcher.focusPitch d.pitch)
          .on('mouseout', (d) -> dispatcher.blurPitch d.pitch)

    d3Notes.append('circle').attr(r: style.noteRadius)
    d3Notes.append('title')

    text_y = 7
    noteLabels = d3Notes.append('text').classed('note', true).attr(y: text_y)
    noteLabels.append('tspan').classed('base', true)
    noteLabels.append('tspan').classed('accidental', true).classed('flat', true).classed('flat-label', true)
    noteLabels.append('tspan').classed('accidental', true).classed('sharp', true).classed('sharp-label', true)
    d3Notes.append('text')
      .classed('fingering', true)
      .attr(y: text_y)
      .text((d) -> d.fingering_name)
    d3Notes.append('text')
      .classed('scale-degree', true)
      .attr(y: text_y)

    update()

  my.on = (args...) -> dispatcher.on args...

  my.attr = (key, value) ->
    throw new Error("Unknown key #{key}") unless key of attrs
    return attrs[key] unless arguments.length > 1
    unless attrs[key] == value
      attrs[key] = value
      update()
    return my

  update = ->
    return if cached.instrument == attrs.instrument and
      cached.scale == attrs.scale and
      cached.tonic == attrs.tonic

    update_instrument()

    scale = cached.scale = attrs.scale
    tonicPitch = cached.tonic = attrs.tonicPitch
    scale_relative_pitch_classes = scale.pitchClasses

    attrs.noteLabel or= label_sets[0]
    for k in label_sets
      visible = k == attrs.noteLabel.replace(/_/g, '-')
      labels = d3.select('#fingerboard').selectAll('.' + k.replace(/s$/, ''))
      labels.attr('visibility', if visible then 'inherit' else 'hidden')

    d3Notes.each (note) ->
      {pitch} = note
      note.relativePitchClass = pitchToPitchClass(pitch - tonicPitch)

    d3Notes
      .attr('class', (d) -> "pitch-class-#{d.pitchClass} relative-pitch-class-#{d.relativePitchClass}")
      .classed('finger-position', true)
      .classed('scale', (d) -> d.relativePitchClass in scale_relative_pitch_classes)
      .classed('chromatic', (d) -> d.relativePitchClass not in scale_relative_pitch_classes)
      .select('.scale-degree')
        .text("")
        .text((d) -> ScaleDegreeNames[d.relativePitchClass])

    d3Notes.each ({pitch}) ->
      noteLabels = d3.select this

  update_instrument = ->
    return if cached.instrument == attrs.instrument
    instrument = cached.instrument = attrs.instrument
    scaleTonicName = attrs.scaleTonicName

    stringPitches = instrument.stringPitches
    d3Notes.each (note) ->
      {string_number, fret_number} = note
      note.pitch =  fingerboardPositionPitch {instrument, string_number, fret_number}
      note.pitchClass = pitchToPitchClass(note.pitch)

    pitchNameOptions = if scaleTonicName == /\u266D/ then {flat: true} else {sharp: true}
    selectPitchNameComponent = (component) -> ({pitch, pitchClass}) ->
      name = getPitchName(pitch, pitchNameOptions)
      switch component
        when 'base' then name.replace(/[^\w]/, '')
        when 'accidental' then name.replace(/[\w]/, '')
        when 'flat' then FlatNoteNames[pitchClass].slice(1)
        when 'sharp' then SharpNoteNames[pitchClass].slice(1)

    d3Notes.each (note) ->
      {string_number, fret_number, pitch} = note
      noteLabels = d3.select(this).select('.note')
      noteLabels.select('.base').text selectPitchNameComponent('base')
      noteLabels.select('.flat').text selectPitchNameComponent('flat')
      noteLabels.select('.sharp').text selectPitchNameComponent('sharp')

    d3Notes.select('title')
      .text (d) -> "Click to set the scale tonic to #{FlatNoteNames[d.pitchClass]}."

  return my


d3.music.noteGrid = (model, style, referenceElement) ->
  column_count = style.columns ? 12 * 5
  row_count = style.rows ? 12
  cached_offset = null
  selection = null

  my = (_selection) ->
    selection = _selection
    notes = _.flatten(({column, row} for column in [0 ... column_count] for row in [0 ... row_count]), true)
    for note in notes
      note.relativePitchClass = pitchToPitchClass note.column * 7 + note.row
    degree_groups = d3.nest()
      .key((d) -> d.relativePitchClass)
      .entries(notes)
    degree.relativePitchClass = Number(degree.key) for degree in degree_groups

    root = selection
      .append('svg')
        .attr
          width: column_count * style.stringWdith
          height: row_count * style.fretHeight

    note_views = root.selectAll('.scale-degree')
      .data(degree_groups)
      .enter()
        .append('g')
          .classed('scale-degree', true)
          .selectAll('.note')
          .data((d) -> d.values)
          .enter()
            .append('g')
              .classed('note', true)
              .attr 'transform', ({column, row}) ->
                x = (column + 0.5) * style.stringWdith
                y = row * style.fretHeight + style.noteRadius
                "translate(#{x}, #{y})"

    note_views.append('circle')
      .attr(r: style.noteRadius)
    note_views.append('text')
      .attr(y: 7)
      .text (d) -> ScaleDegreeNames[d.relativePitchClass]

    setTimeout (-> selection.classed 'animate', true), 1 # don't animate to the initial position

  my.update = ->
    update_note_colors()
    update_position()

  update_note_colors = ->
    scale_pitch_classes = model.scale.pitchClasses
    selection.selectAll('.scale-degree')
      .classed('chromatic', ({relativePitchClass}) -> relativePitchClass not in scale_pitch_classes)
      .classed('tonic', ({relativePitchClass}) ->
        relativePitchClass in scale_pitch_classes and relativePitchClass == 0)
      .classed 'fifth', ({relativePitchClass}) ->
        relativePitchClass in scale_pitch_classes and relativePitchClass == 7

  update_position = ->
    scale_tonic = model.scaleTonicPitch
    bass_pitch = model.instrument.stringPitches[0]
    offset = style.stringWdith * pitchToPitchClass((scale_tonic - bass_pitch) * 5)

    return if offset == cached_offset # profiled
    cached_offset = offset
    pos = $(referenceElement).offset()

    # FIXME why the fudge factor?
    # FIXME why doesn't work?: @selection.attr
    selection.each ->
      $(@).css left: pos.left - offset + 1, top: pos.top + 1

  return my

directives = angular.module('music.directives', [])

directives.directive 'fingerboard', ->
  restrict: 'CE'
  link: (scope, element, attrs) ->
    fingerboard = d3.music.fingerboard scope, Style.fingerboard
    d3.select(element[0]).call fingerboard
    scope.$watch ->
      fingerboard.attr 'noteLabel', scope.noteLabel
      fingerboard.attr 'scale', scope.scale
      fingerboard.attr 'instrument', scope.instrument
      fingerboard.attr 'tonicPitch', scope.scaleTonicPitch
    fingerboard.on 'tapPitch', (pitch) ->
      scope.$apply ->
        scope.scaleTonicName = getPitchName(pitch)
        scope.scaleTonicPitch = pitch
    fingerboard.on 'focusPitch', (pitch) ->
      scope.$apply -> scope.hover.pitch = pitch
    fingerboard.on 'blurPitch', ->
      scope.$apply -> scope.hover.pitch = null

directives.directive 'pitchConstellation', ->
  restrict: 'CE'
  replace: true
  scope: {pitchClasses: '=', pitches: '=', hover: '='}
  transclude: true
  link: (scope, element, attrs) ->
    constellation = d3.music.pitchConstellation scope.pitches, Style.scales
    d3.select(element[0]).call constellation

directives.directive 'keyboard', ->
  restrict: 'CE'
  link: (scope, element, attrs) ->
    keyboard = d3.music.keyboard scope, Style.keyboard
    d3.select(element[0]).call keyboard
    scope.$watch ->
      keyboard.attr 'tonicPitch', scope.scaleTonicPitch
      keyboard.attr 'scale', scope.scale
    keyboard.on 'tapPitch', (pitch) ->
      scope.$apply ->
        scope.scaleTonicName = getPitchName(pitch)
        scope.scaleTonicPitch = pitch
    keyboard.on 'focusPitch', (pitch) ->
      scope.$apply ->
        scope.hover.pitch = pitch
        scope.hover.scaleTonicPitch = pitch
    keyboard.on 'blurPitch', ->
      scope.$apply ->
        scope.hover.pitch = null
        scope.hover.scaleTonicPitch = null

angular.module('unsafe-popover', []).directive 'unsafePopoverPopup', ->
  restrict: 'EA'
  replace: true
  scope: {title: '@', content: '@', placement: '@', animation: '&', isOpen: '&'}
  templateUrl: 'templates/popover.html'
.directive 'unsafePopover', ($tooltip) ->
  $tooltip 'unsafePopover', 'popover', 'click'

#
# Music Theory
#

SharpNoteNames = 'C C# D D# E F F# G G# A A# B'.split(/\s/).map (d) -> d.replace(/#/, '\u266F')
FlatNoteNames = 'C Db D Eb E F Gb G Ab A Bb B'.split(/\s/).map (d) -> d.replace(/b/, '\u266D')
ScaleDegreeNames = '1 b2 2 b3 3 4 b5 5 b6 6 b7 7'.split(/\s/)
  .map (d) -> d.replace(/(\d)/, '$1\u0302').replace(/b/, '\u266D')

Pitches = [0 ... 12]

pitchNameToNumber = (pitchName) ->
  pitch = FlatNoteNames.indexOf(pitchName)
  pitch = SharpNoteNames.indexOf(pitchName) unless pitch >= 0
  return pitch

pitchNumberToName = (pitch_number) ->
  pitch = pitchToPitchClass(pitch_number)
  return SharpNoteNames.indexOf(pitch) or FlatNoteNames.indexOf(pitch)

pitchToPitchClass = (pitch) ->
  (pitch % 12 + 12) % 12

getPitchName = (pitch, options={}) ->
  pitchClass = pitchToPitchClass(pitch)
  flatName = FlatNoteNames[pitchClass]
  sharpName = SharpNoteNames[pitchClass]
  name = if options.sharp then sharpName else flatName
  if options.flat and options.sharp and flatName != sharpName
    name = "#{flatName}/\n#{sharpName}"
  return name

Scales = [
  {
    name: 'Diatonic Major'
    pitchClasses: [0, 2, 4, 5, 7, 9, 11]
    modeNames: 'Ionian Dorian Phrygian Lydian Mixolydian Aeolian Locrian'.split(/\s/)
  }
  {
    name: 'Natural Minor'
    pitchClasses: [0, 2, 3, 5, 7, 8, 10]
    parentName: 'Diatonic Major'
  }
  {
    name: 'Major Pentatonic'
    pitchClasses: [0, 2, 4, 7, 9]
    modeNames: ['Major Pentatonic', 'Suspended Pentatonic', 'Man Gong', 'Ritusen', 'Minor Pentatonic']
  }
  {
    name: 'Minor Pentatonic'
    pitchClasses: [0, 3, 5, 7, 10]
    parentName: 'Major Pentatonic'
  }
  {
    name: 'Melodic Minor'
    pitchClasses: [0, 2, 3, 5, 7, 9, 11]
    modeNames:
      ['Jazz Minor', 'Dorian b2', 'Lydian Augmented', 'Lydian Dominant', 'Mixolydian b6', 'Semilocrian', 'Superlocrian']
  }
  {
    name: 'Harmonic Minor'
    pitchClasses: [0, 2, 3, 5, 7, 8, 11]
    modeNames:
      ['Harmonic Minor', 'Locrian #6', 'Ionian Augmented', 'Romanian', 'Phrygian Dominant', 'Lydian #2', 'Ultralocrian']
  }
  {
    name: 'Blues'
    pitchClasses: [0, 3, 5, 6, 7, 10]
  }
  {
    name: 'Freygish'
    pitchClasses: [0, 1, 4, 5, 7, 8, 10]
  }
  {
    name: 'Whole Tone'
    pitchClasses: [0, 2, 4, 6, 8, 10]
  }
  {
    name: 'Octatonic'
    pitchClasses: [0, 2, 3, 5, 6, 8, 9, 11]
  }
]

do ->
  Scales[scale.name] = scale for scale in Scales
  rotate = (pitchClasses, i) ->
    i %= pitchClasses.length
    pitchClasses = pitchClasses.slice(i).concat pitchClasses[0 ... i]
    pitchClasses.map (pc) -> pitchToPitchClass(pc - pitchClasses[0])
  for scale in Scales
    {name, modeNames, parentName, pitchClasses} = scale
    parent = scale.parent = Scales[parentName]
    modeNames or= parent?.modeNames
    if modeNames?
      scale.modeIndex = 0
      if parent?
        [scale.modeIndex] = [0 ... pitchClasses.length]
          .filter (i) -> rotate(parent.pitchClasses, i).join(',') == pitchClasses.join(',')
      scale.modes = modeNames.map (name, i) -> {
        name: name.replace(/#/, '\u266F').replace(/\bb(\d)/, '\u266D$1')
        pitchClasses: rotate(parent?.pitchClasses or pitchClasses, i)
        parent: scale
      }

Instruments = [
  {
    name: 'Violin'
    stringPitches: [7, 14, 21, 28]
  }
  {
    name: 'Viola'
    stringPitches: [0, 7, 14, 21]
  }
  {
    name: 'Cello'
    stringPitches: [0, 7, 14, 21]
  }
]

do ->
  Instruments[instrument.name] = instrument for instrument in Instruments

fingerboardPositionPitch = ({instrument, string_number, fret_number}) ->
  instrument.stringPitches[string_number] + fret_number

exports = {
  fingerboardPositionPitch
  FlatNoteNames
  Instruments
  getPitchName
  pitchToPitchClass
  Pitches
  ScaleDegreeNames
  Scales
  SharpNoteNames
}

if module?.exports? then module.exports = exports else @MusicTheory = exports
