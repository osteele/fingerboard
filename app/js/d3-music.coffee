{Interval, Pitch} = require('schoen')
{FlatNoteNames, SharpNoteNames, getPitchName, normalizePitchClass, pitchToPitchClass} = require('schoen').pitches
{ScaleDegreeNames} = require('schoen').scales

FingerPositions = 7

d3.music or= {}

d3.music.keyboard = (model, attributes) ->
  octaves = attributes.octaves
  strokeWidth = 1
  attrs =
    scale: model.scale
    tonic: model.tonic
  dispatcher = d3.dispatch('focusPitch', 'blurPitch', 'tapPitch')
  selection = null

  my = (sel) ->
    selection = sel
    keys = [0 ... 12 * octaves].map (pitchNumber) ->
      pitchClassNumber = pitchToPitchClass(pitchNumber)
      pitchClassName = getPitchName(pitchClassNumber, flat: true)
      isBlackKey = FlatNoteNames[pitchClassNumber].length > 1
      height = (if isBlackKey then attributes.blackKeyHeight else attributes.whiteKeyHeight)
      return {pitchNumber, pitchClassNumber, pitchClassName, isBlackKey, attrs: {width: attributes.keyWidth, height, y: 0}}

    x = strokeWidth
    for {attrs: keyAttrs, isBlackKey} in keys
      {width} = keyAttrs
      keyAttrs.x = x
      keyAttrs.x -= width / 2 if isBlackKey
      x += width + attributes.keyMargin unless isBlackKey

    # order the black keys on top of (following) the white keys
    keys.sort (a, b) -> a.isBlackKey - b.isBlackKey

    whiteKeyCount = octaves * 7
    root = selection.append('svg')
      .attr
        width: whiteKeyCount * (attributes.keyWidth + attributes.keyMargin) - attributes.keyMargin + 2 * strokeWidth
        height: attributes.whiteKeyHeight + 1

    keyViews = root.selectAll('.piano-key')
      .data(keys).enter()
        .append('g')
          .attr('class', (d) -> "pitch-#{d.pitchNumber} pitch-class-#{d.pitchClassNumber}")
          .classed('piano-key', true)
          .classed('black-key', (d) -> (d.isBlackKey))
          .classed('white-key', (d) -> (not d.isBlackKey))
          .on('click', (d) -> dispatcher.tapPitch Pitch.fromMidiNumber(d.pitchNumber))
          .on('mouseover', (d) -> dispatcher.focusPitch Pitch.fromMidiNumber(d.pitchNumber))
          .on('mouseout', (d) -> dispatcher.blurPitch Pitch.fromMidiNumber(d.pitchNumber))

    keyViews.append('rect')
      .attr
        x: ({attrs}) -> attrs.x
        y: ({attrs}) -> attrs.y
        width: ({attrs}) -> attrs.width
        height: ({attrs}) -> attrs.height

    keyViews.append('text')
      .classed('flat-label', true)
      .attr
        x: ({attrs: {x, width}}) -> x + width / 2
        y: ({attrs: {y, height}}) -> y + height - 6
      .text (d) -> FlatNoteNames[d.pitchClassNumber]

    keyViews.append('text')
      .classed('sharp-label', true)
      .attr
        x: ({attrs: {x, width}}) -> x + width / 2
        y: ({attrs: {y, height}}) -> y + height - 6
      .text (d) -> SharpNoteNames[d.pitchClassNumber]

    keyViews.append('title').text (d) -> "Click to set the scale tonic to #{d.pitchClassName}."

    update()

  my.on = (args...) -> dispatcher.on args...

  pitchClassIntervalIs = (semitones) -> (d) ->
    Interval.between(attrs.tonic, Pitch.fromMidiNumber(d.pitchNumber)).semitones == semitones

  scaleContainsPitchNumber = (pitchNumber) ->
    scaleSemitones = (interval.semitones for interval in attrs.scale.intervals)
    normalizePitchClass(Interval.between(attrs.tonic, Pitch.fromMidiNumber(pitchNumber)).semitones) in scaleSemitones

  update = ->
    selection.selectAll('.piano-key')
      .classed('root', pitchClassIntervalIs(0))
      .classed('fifth', pitchClassIntervalIs(7))
      .classed('scale-note', (d) -> scaleContainsPitchNumber(d.pitchNumber))

  my.attr = (key, value) ->
    throw new Error("Unknown key #{key}") unless key of attrs
    return attrs[key] unless arguments.length > 1
    unless attrs[key] == value
      attrs[key] = value
      update()
    return my

  return my


d3.music.pitchConstellation = (pitchClasses, attributes) ->
  (selection) ->
    r = attributes.constellationRadius
    noteRadius = attributes.pitchRadius
    pcWidth = 2 * (r + noteRadius + 1)

    root = selection.append('svg')
      .attr(width: pcWidth, height: pcWidth)
      .append('g')
        .attr('transform', "translate(#{pcWidth / 2}, #{pcWidth / 2})")

    endpoints = [0 ... 12].map (pitchClass) ->
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


d3.music.fingerboard = (model, attributes) ->
  labelSets = ['notes', 'fingerings', 'scale-degrees']
  dispatcher = d3.dispatch('focusPitch', 'blurPitch', 'tapPitch')
  attrs =
    instrument: model.instrument
    noteLabel: null
    scale: model.scale
    tonic: model.tonic
  cached = {}
  d3Notes = null

  my = (selection) ->
    instrument = attrs.instrument
    strings = instrument.stringPitches.length
    fingerPositions = []

    for string in [0 ... strings]
      for fret in [0 .. FingerPositions]
        pitch = instrument.pitchAt {string, fret}
        fingerPositions.push {
          string
          fret
          pitch
          pitchClass: pitch.toPitchClass()
          fingeringName: String(Math.ceil(fret / 2))
        }

    root = selection
      .append('svg')
        .attr(width: strings * attributes.stringWdith)
        .attr(height: (1 + FingerPositions) * attributes.fretHeight)

    # nut
    root.append('line')
      .classed('nut', true)
      .attr
        x2: strings * attributes.stringWdith
        transform: "translate(0, #{attributes.fretHeight - 5})"

    # strings
    root.selectAll('.string')
      .data([0 ... strings])
      .enter()
        .append('line')
          .classed('string', true)
          .attr
            y1: attributes.fretHeight * 0.5
            y2: (1 + FingerPositions) * attributes.fretHeight
            transform: (d) -> "translate(#{(d + 0.5) * attributes.stringWdith}, 0)"

    # finger positions
    d3Notes = root.selectAll('.finger-position')
      .data(fingerPositions)
      .enter()
        .append('g')
          .classed('finger-position', true)
          .attr(transform: ({string, fret}) ->
            dx = (string + 0.5) * attributes.stringWdith
            dy = fret * attributes.fretHeight + attributes.noteRadius + 1
            "translate(#{dx}, #{dy})")
          .on('click', (d) -> dispatcher.tapPitch d.pitch)
          .on('mouseover', (d) -> dispatcher.focusPitch d.pitch)
          .on('mouseout', (d) -> dispatcher.blurPitch d.pitch)

    d3Notes.append('circle').attr(r: attributes.noteRadius)
    d3Notes.append('title')

    textY = 7
    noteLabels = d3Notes.append('text').classed('note', true).attr(y: textY)
    noteLabels.append('tspan').classed('base', true)
    noteLabels.append('tspan').classed('accidental', true).classed('flat', true).classed('flat-label', true)
    noteLabels.append('tspan').classed('accidental', true).classed('sharp', true).classed('sharp-label', true)
    d3Notes.append('text')
      .classed('fingering', true)
      .attr(y: textY)
      .text((d) -> d.fingeringName)
    d3Notes.append('text')
      .classed('scale-degree', true)
      .attr(y: textY)

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

    updateInstrument()

    scale = cached.scale = attrs.scale
    tonic = cached.tonic = attrs.tonic
    scaleRelativePitchClasses = scale.pitchClasses

    attrs.noteLabel or= labelSets[0]
    for k in labelSets
      visible = k == attrs.noteLabel.replace(/_/g, '-')
      labels = d3.select('#fingerboard').selectAll('.' + k.replace(/s$/, ''))
      labels.attr('visibility', if visible then 'inherit' else 'hidden')

    d3Notes.each (note) ->
      {pitch} = note
      note.interval = Interval.between(tonic, pitch)

    scaleSemitones = (interval.semitones for interval in attrs.scale.intervals)
    d3Notes
      .attr('class', (d) -> "pitch-class-#{d.pitchClass.semitones} relative-pitch-class-#{d.interval.semitones}")
      .classed('finger-position', true)
      .classed('scale', (d) -> d.interval.semitones in scaleSemitones)
      .classed('chromatic', (d) -> d.interval.semitones not in scaleSemitones)
      .select('.scale-degree')
        .text("")
        .text((d) -> ScaleDegreeNames[d.interval])

    d3Notes.each ({pitch}) ->
      noteLabels = d3.select this

  updateInstrument = ->
    return if cached.instrument == attrs.instrument
    instrument = cached.instrument = attrs.instrument
    scaleTonicName = attrs.scaleTonicName

    stringPitches = instrument.stringPitches
    d3Notes.each (note) ->
      {string, fret} = note
      note.pitch =  instrument.pitchAt {string, fret}
      note.pitchClassSemitones = note.pitch.toPitchClass().semitones

    pitchNameOptions = if scaleTonicName == /\u266D/ then {flat: true} else {sharp: true}
    selectPitchNameComponent = (component) -> ({pitch, pitchClassSemitones}) ->
      name = getPitchName(pitch.midiNumber, pitchNameOptions)
      switch component
        when 'base' then name.replace(/[^\w]/, '')
        when 'accidental' then name.replace(/[\w]/, '')
        when 'flat' then FlatNoteNames[pitchClassSemitones].slice(1)
        when 'sharp' then SharpNoteNames[pitchClassSemitones].slice(1)

    d3Notes.each (note) ->
      {string, fret, pitch} = note
      noteLabels = d3.select(this).select('.note')
      noteLabels.select('.base').text selectPitchNameComponent('base')
      noteLabels.select('.flat').text selectPitchNameComponent('flat')
      noteLabels.select('.sharp').text selectPitchNameComponent('sharp')

    d3Notes.select('title')
      .text (d) -> "Click to set the scale tonic to #{FlatNoteNames[d.pitchClassSemitones]}."

  return my


d3.music.noteGrid = (model, attributes, referenceElement) ->
  columns = attributes.columns ? 12 * 5
  rows = attributes.rows ? 12
  cachedOffset = null
  selection = null

  my = (sel) ->
    selection = my.selection = sel
    notes = _.flatten(({column, row} for column in [0 ... columns] for row in [0 ... rows]), true)
    for note in notes
      note.relativePitchClass = pitchToPitchClass note.column * 7 + note.row
    degreeGroups = d3.nest()
      .key((d) -> d.relativePitchClass)
      .entries(notes)
    degree.relativePitchClass = Number(degree.key) for degree in degreeGroups

    root = selection
      .append('svg')
        .attr
          width: columns * attributes.stringWdith
          height: rows * attributes.fretHeight

    noteViews = root.selectAll('.scale-degree')
      .data(degreeGroups)
      .enter()
        .append('g')
          .classed('scale-degree', true)
          .selectAll('.note')
          .data((d) -> d.values)
          .enter()
            .append('g')
              .classed('note', true)
              .attr 'transform', ({column, row}) ->
                x = (column + 0.5) * attributes.stringWdith
                y = row * attributes.fretHeight + attributes.noteRadius
                "translate(#{x}, #{y})"

    noteViews.append('circle')
      .attr(r: attributes.noteRadius)
    noteViews.append('text')
      .attr(y: 7)
      .text (d) -> ScaleDegreeNames[d.relativePitchClass]

  my.update = ->
    updateNoteColors()
    updatePosition()

  updateNoteColors = ->
    scalePitchClasses = model.scale.pitchClasses
    selection.selectAll('.scale-degree')
      .classed('chromatic', ({relativePitchClass}) -> relativePitchClass not in scalePitchClasses)
      .classed('tonic', ({relativePitchClass}) ->
        relativePitchClass in scalePitchClasses and relativePitchClass == 0)
      .classed 'fifth', ({relativePitchClass}) ->
        relativePitchClass in scalePitchClasses and relativePitchClass == 7

  updatePosition = ->
    scaleTonic = model.tonic
    bassPitch = model.instrument.stringPitches[0]
    offset = attributes.stringWdith * pitchToPitchClass((scaleTonic - bassPitch) * 5)

    return if offset == cachedOffset # profiled
    cachedOffset = offset
    pos = $(referenceElement).offset()

    # FIXME why the fudge factor?
    # FIXME why doesn't work?: @selection.attr
    selection.each ->
      $(@).css left: pos.left - offset + 1, top: pos.top + 1

  return my
