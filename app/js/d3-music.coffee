FingerPositions = 7

d3.music or= {}

d3.music.keyboard = (model, attributes) ->
  style = attributes
  octaves = attributes.octaves
  stroke_width = 1
  attrs =
    scale: model.scale
    tonic_pitch: model.tonic_pitch
  dispatcher = d3.dispatch('focus_pitch', 'blur_pitch', 'tap_pitch')
  selection = null

  my = (_selection) ->
    selection = _selection
    keys = [0 ... 12 * octaves].map (pitch) ->
      pitch_class = pitch_to_pitch_class(pitch)
      is_black_key = FlatNoteNames[pitch_class].length > 1
      pitch_class_name = pitch_name(pitch, flat: true)
      height = (if is_black_key then style.black_key_height else style.white_key_height)
      return {pitch, pitch_class, pitch_class_name, is_black_key, attrs: {width: style.key_width, height, y: 0}}

    x = stroke_width
    for {attrs, is_black_key} in keys
      {width} = attrs
      attrs.x = x
      attrs.x -= width / 2 if is_black_key
      x += width + style.key_spacing unless is_black_key

    # order the black keys on top of (following) the white keys
    keys.sort (a, b) -> a.is_black_key - b.is_black_key

    white_key_count = octaves * 7
    root = selection.append('svg')
      .attr
        width: white_key_count * (style.key_width + style.key_spacing) - style.key_spacing + 2 * stroke_width
        height: style.white_key_height + 1

    key_views = root.selectAll('.piano-key')
      .data(keys).enter()
        .append('g')
          .attr('class', (d) -> "pitch-#{d.pitch} pitch-class-#{d.pitch_class}")
          .classed('piano-key', true)
          .classed('black-key', (d) -> (d.is_black_key))
          .classed('white-key', (d) -> (not d.is_black_key))
          .on('click', (d) -> dispatcher.tap_pitch d.pitch)
          .on('mouseover', (d) -> dispatcher.focus_pitch d.pitch)
          .on('mouseout', (d) -> dispatcher.blur_pitch d.pitch)

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
      .text (d) -> FlatNoteNames[d.pitch_class]

    key_views.append('text')
      .classed('sharp-label', true)
      .attr
        x: ({attrs: {x, width}}) -> x + width / 2
        y: ({attrs: {y, height}}) -> y + height - 6
      .text (d) -> SharpNoteNames[d.pitch_class]

    key_views.append('title').text (d) -> "Click to set the scale tonic to #{d.pitch_class_name}."

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
      .classed('root', (d) -> pitch_to_pitch_class(d.pitch - model.scale_tonic_pitch) == 0)
      .classed('scale-note', (d) -> pitch_to_pitch_class(d.pitch - model.scale_tonic_pitch) in model.scale.pitch_classes)
      .classed('fifth', (d) -> pitch_to_pitch_class(d.pitch - model.scale_tonic_pitch) == 7)

  return my


d3.music.pitch_constellation = (pitch_classes, attributes) ->
  style = attributes

  (selection) ->
    r = style.constellation_radius
    note_radius = style.pitch_radius
    pc_width = 2 * (r + note_radius + 1)

    root =(selection.append 'svg')
      .attr(width: pc_width, height: pc_width)
      .append('g')
        .attr('transform', "translate(#{pc_width / 2}, #{pc_width / 2})")

    endpoints = Pitches.map (pitch_class) ->
      a = (pitch_class - 3) * 2 * Math.PI / 12
      x = Math.cos(a) * r
      y = Math.sin(a) * r
      chromatic = pitch_class not in pitch_classes
      return {x, y, chromatic, pitch_class}

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
          .attr('class', (d) -> "relative-pitch-class-#{d.pitch_class}")
          .classed('chromatic', (d) -> d.chromatic)
          .classed('root', (d) -> d.pitch_class == 0)
          .classed('fifth', (d) -> d.pitch_class == 7)
          .attr('cx', (d) -> d.x)
          .attr('cy', (d) -> d.y)
          .attr('r', note_radius)


d3.music.fingerboard = (model, attributes) ->
  style = attributes
  label_sets = ['notes', 'fingerings', 'scale-degrees']
  dispatcher = d3.dispatch('focus_pitch', 'blur_pitch', 'tap_pitch')
  attrs =
    instrument: model.instrument
    note_label: null
    scale: model.scale
    tonic_pitch: model.scale_tonic_pitch
  cached = {}
  d3_notes = null

  my = (selection) ->
    instrument = attrs.instrument
    string_count = instrument.string_pitches.length
    finger_positions = []

    for string_number in [0 ... string_count]
      for fret_number in [0 .. FingerPositions]
        pitch = fingerboard_position_pitch {instrument, string_number, fret_number}
        finger_positions.push {
          string_number
          fret_number
          pitch
          pitch_class: pitch_to_pitch_class(pitch)
          fingering_name: String Math.ceil(fret_number / 2)
        }

    root = selection
      .append('svg')
        .attr(width: string_count * style.string_width)
        .attr(height: (1 + FingerPositions) * style.fret_height)

    # nut
    root.append('line')
      .classed('nut', true)
      .attr
        x2: string_count * style.string_width
        transform: "translate(0, #{style.fret_height - 5})"

    # strings
    root.selectAll('.string')
      .data([0 ... string_count])
      .enter()
        .append('line')
          .classed('string', true)
          .attr
            y1: style.fret_height * 0.5
            y2: (1 + FingerPositions) * style.fret_height
            transform: (d) -> "translate(#{(d + 0.5) * style.string_width}, 0)"

    # finger positions
    d3_notes = root.selectAll('.finger-position')
      .data(finger_positions)
      .enter()
        .append('g')
          .classed('finger-position', true)
          .attr(transform: ({string_number, fret_number}) ->
            dx = (string_number + 0.5) * style.string_width
            dy = fret_number * style.fret_height + style.note_radius + 1
            "translate(#{dx}, #{dy})")
          .on('click', (d) -> dispatcher.tap_pitch d.pitch)
          .on('mouseover', (d) -> dispatcher.focus_pitch d.pitch)
          .on('mouseout', (d) -> dispatcher.blur_pitch d.pitch)

    d3_notes.append('circle').attr(r: style.note_radius)
    d3_notes.append('title')

    text_y = 7
    note_labels = d3_notes.append('text').classed('note', true).attr(y: text_y)
    note_labels.append('tspan').classed('base', true)
    note_labels.append('tspan').classed('accidental', true).classed('flat', true).classed('flat-label', true)
    note_labels.append('tspan').classed('accidental', true).classed('sharp', true).classed('sharp-label', true)
    d3_notes.append('text')
      .classed('fingering', true)
      .attr(y: text_y)
      .text((d) -> d.fingering_name)
    d3_notes.append('text')
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
    tonic_pitch = cached.tonic = attrs.tonic_pitch
    scale_relative_pitch_classes = scale.pitch_classes

    attrs.note_label or= label_sets[0]
    for k in label_sets
      visible = k == attrs.note_label.replace(/_/g, '-')
      labels = d3.select('#fingerboard').selectAll('.' + k.replace(/s$/, ''))
      labels.attr('visibility', if visible then 'inherit' else 'hidden')

    d3_notes.each (note) ->
      {pitch} = note
      note.relative_pitch_class = pitch_to_pitch_class(pitch - tonic_pitch)

    d3_notes
      .attr('class', (d) -> "pitch-class-#{d.pitch_class} relative-pitch-class-#{d.relative_pitch_class}")
      .classed('finger-position', true)
      .classed('scale', (d) -> d.relative_pitch_class in scale_relative_pitch_classes)
      .classed('chromatic', (d) -> d.relative_pitch_class not in scale_relative_pitch_classes)
      .select('.scale-degree')
        .text("")
        .text((d) -> ScaleDegreeNames[d.relative_pitch_class])

    d3_notes.each ({pitch}) ->
      note_labels = d3.select this

  update_instrument = ->
    return if cached.instrument == attrs.instrument
    instrument = cached.instrument = attrs.instrument
    scale_tonic_name = attrs.scale_tonic_name

    string_pitches = instrument.string_pitches
    d3_notes.each (note) ->
      {string_number, fret_number} = note
      note.pitch =  fingerboard_position_pitch {instrument, string_number, fret_number}
      note.pitch_class = pitch_to_pitch_class(note.pitch)

    pitch_name_options = if scale_tonic_name == /\u266D/ then {flat: true} else {sharp: true}
    select_pitch_name_component = (component) -> ({pitch, pitch_class}) ->
      name = pitch_name(pitch, pitch_name_options)
      switch component
        when 'base' then name.replace(/[^\w]/, '')
        when 'accidental' then name.replace(/[\w]/, '')
        when 'flat' then FlatNoteNames[pitch_class].slice(1)
        when 'sharp' then SharpNoteNames[pitch_class].slice(1)

    d3_notes.each (note) ->
      {string_number, fret_number, pitch} = note
      note_labels = d3.select(this).select('.note')
      note_labels.select('.base').text select_pitch_name_component('base')
      note_labels.select('.flat').text select_pitch_name_component('flat')
      note_labels.select('.sharp').text select_pitch_name_component('sharp')

    d3_notes.select('title')
      .text (d) -> "Click to set the scale tonic to #{FlatNoteNames[d.pitch_class]}."

  return my


d3.music.note_grid = (model, style, referenceElement) ->
  column_count = style.columns ? 12 * 5
  row_count = style.rows ? 12
  cached_offset = null
  selection = null

  my = (_selection) ->
    selection = _selection
    notes = _.flatten(({column, row} for column in [0 ... column_count] for row in [0 ... row_count]), true)
    for note in notes
      note.relative_pitch_class = pitch_to_pitch_class note.column * 7 + note.row
    degree_groups = d3.nest()
      .key((d) -> d.relative_pitch_class)
      .entries(notes)
    degree.relative_pitch_class = Number(degree.key) for degree in degree_groups

    root = selection
      .append('svg')
        .attr
          width: column_count * style.string_width
          height: row_count * style.fret_height

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
                x = (column + 0.5) * style.string_width
                y = row * style.fret_height + style.note_radius
                "translate(#{x}, #{y})"

    note_views.append('circle')
      .attr(r: style.note_radius)
    note_views.append('text')
      .attr(y: 7)
      .text (d) -> ScaleDegreeNames[d.relative_pitch_class]

    setTimeout (-> selection.classed 'animate', true), 1 # don't animate to the initial position

  my.update = ->
    update_note_colors()
    update_position()

  update_note_colors = ->
    scale_pitch_classes = model.scale.pitch_classes
    selection.selectAll('.scale-degree')
      .classed('chromatic', ({relative_pitch_class}) -> relative_pitch_class not in scale_pitch_classes)
      .classed('tonic', ({relative_pitch_class}) ->
        relative_pitch_class in scale_pitch_classes and relative_pitch_class == 0)
      .classed 'fifth', ({relative_pitch_class}) ->
        relative_pitch_class in scale_pitch_classes and relative_pitch_class == 7

  update_position = ->
    scale_tonic = model.scale_tonic_pitch
    bass_pitch = model.instrument.string_pitches[0]
    offset = style.string_width * pitch_to_pitch_class((scale_tonic - bass_pitch) * 5)

    return if offset == cached_offset # profiled
    cached_offset = offset
    pos = $(referenceElement).offset()

    # FIXME why the fudge factor?
    # FIXME why doesn't work?: @selection.attr
    selection.each ->
      $(@).css left: pos.left - offset + 1, top: pos.top + 1

  return my
