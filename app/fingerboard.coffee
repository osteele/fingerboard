SharpNoteNames = 'C C# D D# E F F# G G# A A# B'.split(/\s/)
FlatNoteNames = 'C Db D Eb E F Gb G Ab A Bb B'.split(/\s/)
ScaleDegreeNames = '1 2b 2 3b 3 4 5b 5 6b 6 7b 7'.replace(/(\d)/g, '$1\u0302').replace(/b/g, '\u266D').split(/\s/)

Scales = [
  {'Diatonic Major': [0,2,4,5,7,9,11]}
  {'Natural Minor': [0,2,3,5,7,8,10]}
  {'Major Pentatonic': [0,2,4,7,9]}
  {'Minor Pentatonic': [0,3,5,7,10]}
  {'Melodic Minor': [0,2,3,5,7,9,11]}
  {'Harmonic Minor': [0,2,3,5,7,8,11]}
  {'Blues': [0,3,5,6,7,10]}
  {'Freygish': [0,1,4,5,7,8,10]}
  {'Whole Tone': [0,2,4,6,8,10]}
  {'Octatonic': [0,2,3,5,6,8,9,11]}
]

ScaleNames = (_.keys(scale)[0] for scale in Scales)

do ->
  for scale in Scales
    name = _.keys(scale)[0]
    pitches = scale[name]
    Scales[name] = pitches

pitch_name_to_number = (pitch_name) ->
  pitch = FlatNoteNames.indexOf(pitch_name)
  pitch = SharpNoteNames.indexOf(pitch_name) unless pitch >= 0
  return pitch

Instruments =
  Violin: [7,14,21,28]
  Viola: [0,7,14,21]
  Cello: [0,7,14,21]

State =
  instrument_name: 'Violin'
  scale_tonic_name: 'C'
  scale_tonic_pitch: 0
  scale_class_name: 'Diatonic Major'

D3State = d3.dispatch('instrument', 'scale', 'scale_tonic')

StringCount = 4
FingerPositions = 7

FingerboardStyle =
  string_width: 50
  fret_height: 50

ScaleRootColor = 'rgb(255, 96, 96)'

FingerboardNoteStyle =
  all:
    radius: 20

KeyboardStyle =
  Key:
    width: 25
    margin: 3
  WhiteKey:
    height: 120
  BlackKey:
    height: 90

ScaleStyle =
  cols: 4
  cell:
    width: 85
    height: 90
    padding: 0
  pitch_circle:
    radius: 28
    note:
      radius: 3

Pitches = [0...12]

pitch_at = (string_number, fret_number) ->
  pitch_class string_number * 7 + fret_number

pitch_class = (pitch) ->
  ((pitch % 12) + 12) % 12

pitch_name = (pitch, options={}) ->
  flatName = FlatNoteNames[pitch]
  sharpName = SharpNoteNames[pitch]
  name = if options.sharp then sharpName else flatName
  if options.flat and options.sharp and flatName != sharpName
    name = "#{flatName}/\n#{sharpName}"
  name.replace(/b/, '\u266D').replace(/#/g, '\u266F')


class KeyboardView
  constructor: ->
    style = KeyboardStyle
    root = d3.select('#keyboard').append('svg').attr(
      width: 7 * (style.Key.width + style.Key.margin)
      height: style.WhiteKey.height + 1
    )

    next_x = 1
    keys = Pitches.map (pitch) ->
      note_name = pitch_name(pitch, flat: true)
      is_black_key = FlatNoteNames[pitch].length > 1
      {width, height} = key_style =
        _.extend {}, KeyboardStyle.Key, (if is_black_key then KeyboardStyle.BlackKey else KeyboardStyle.WhiteKey)
      x = next_x
      next_x += width + KeyboardStyle.Key.margin unless is_black_key
      x -= width / 2 if is_black_key
      return {pitch, name: note_name, is_black_key, attrs: {width, height, x, y: 0}}
    keys.sort (a, b) -> a.is_black_key - b.is_black_key

    onclick = ({pitch, name}) ->
      State.scale_tonic_name = FlatNoteNames[pitch]
      State.scale_tonic_pitch = pitch
      D3State.scale_tonic()

    @d3_keys = root.selectAll('.piano-key')
      .data(keys).enter()
    .append('g')
      .classed('piano-key', true)
      .classed('black-key', ({is_black_key}) -> is_black_key)
      .on('click', onclick)

    @d3_keys.append('rect')
      .attr(
        x: ({attrs}) -> attrs.x
        y: ({attrs}) -> attrs.y
        width: ({attrs}) -> attrs.width
        height: ({attrs}) -> attrs.height
      )

    @d3_keys.append('text')
      .attr(
        x: ({attrs}) -> attrs.x + attrs.width / 2
        y: ({attrs}) -> attrs.y + attrs.height - 6
      )
      .text(({name}) -> name)

    D3State.on('scale_tonic.keyboard', => @update())
    @update()

  update: ->
    @d3_keys.each ({pitch}) ->
      d3.select(this).classed('root', pitch == State.scale_tonic_pitch)


class ScaleSelectorView
  constructor: ->
    style = ScaleStyle

    onclick = (scale_name) =>
      State.scale_class_name = scale_name
      D3State.scale()
    D3State.on('scale.scale', => @update())

    scales = d3.select('#scales').selectAll('.scale')
      .data(ScaleNames).enter()
    .append('div')
      .classed('scale', true)
      .on('click', onclick)
    scales.append('h2').text((scale_name) -> scale_name)
    pc_width = 2 * (style.pitch_circle.radius + style.pitch_circle.note.radius + 1)
    scales.append('svg')
      .attr(width: pc_width, height: pc_width)
      .append('g')
      .attr(
        transform: "translate(#{pc_width / 2}, #{pc_width / 2})"
      )
    scales.selectAll('svg g').each (scale_name) ->
      pitches = Scales[scale_name]
      r = style.pitch_circle.radius
      endpoints = Pitches.map (pitch) ->
        a = (pitch - 3) * 2 * Math.PI / 12
        x = Math.cos(a) * r
        y = Math.sin(a) * r
        chromatic = pitch not in pitches
        return {x, y, chromatic, pitch}
      d3.select(this).selectAll('line').data(endpoints).enter().append('line')
        .attr(
          x2: (d) -> d.x
          y2: (d) -> d.y
        )
        .classed('chromatic', (d) -> d.chromatic)
      d3.select(this).selectAll('circle').data(endpoints).enter().append('circle')
        .attr(
          cx: (d) -> d.x
          cy: (d) -> d.y
          r: style.pitch_circle.note.radius
        )
        .classed('chromatic', (d) -> d.chromatic)
        .classed('root', (d) -> d.pitch == 0)
        .classed('fifth', (d) -> d.pitch == 7)

    @update()

  update: ->
    scales = d3.select('#scales').selectAll('.scale')
      .classed('selected', (d) -> d == State.scale_class_name)


class FingerboardView
  constructor: ->
    @label_sets = ['notes', 'fingerings', 'scale-degrees']
    @note_display = 'notes'

    finger_positions = []
    for string_number in [0...StringCount]
      for fret_number in [0..FingerPositions]
        pitch = pitch_at(string_number, fret_number)
        note_name = pitch_name(pitch).replace(/(.)(.)/, '$1-$2')
        fingering_name = String(Math.ceil(fret_number / 2))
        scale_degree_name = ScaleDegreeNames[pitch]
        finger_positions.push {
          string_number
          fret_number
          pitch
          note_name
          fingering_name
          scale_degree_name
        }

    style = FingerboardStyle
    note_style = FingerboardNoteStyle

    root = d3.select('#fingerboard').append('svg')
      .attr('width', StringCount * style.string_width)
      .attr('height', FingerPositions * style.fret_height)

    # nut
    root.append('line')
      .classed('nut', true)
      .attr(
        x2: StringCount * style.string_width
        transform: "translate(0, #{style.fret_height - 5})"
      )

    # strings
    root.selectAll('.string')
      .data([0...StringCount]).enter()
    .append('line')
      .classed('string', true)
      .attr(
        y1: style.fret_height * 0.5
        y2: (1 + FingerPositions) * style.fret_height
        transform: (d) -> "translate(#{(d + 0.5) * style.string_width}, 0)"
      )

    # notes
    @d3_notes = root.selectAll('.finger-position')
      .data(finger_positions).enter()
    .append('g')
      .classed('finger-position', true)
      .attr('transform', ({string_number, fret_number}) ->
        dx = (string_number + 0.5) * style.string_width
        dy = fret_number * style.fret_height + note_style.all.radius + 1
        "translate(#{dx}, #{dy})"
      )

    @d3_notes.append('circle')
      .attr(r: note_style.all.radius)

    note_labels = @d3_notes.append('text')
      .classed('note', true)
      .attr(y: 7)
    note_labels.append('tspan').classed('base', true)
    note_labels.append('tspan').classed('accidental', true)
    @d3_notes.append('text')
      .classed('fingering', true)
      .attr(y: 7)
      .text((d) -> d.fingering_name)
    @d3_notes.append('text')
      .classed('scale-degree', true)
      .attr(y: 7)
      .text((d) -> d.scale_degree_name)

    D3State.on('instrument.fingerboard', => @update_instrument())
    D3State.on('scale.fingerboard', => @update())
    D3State.on('scale_tonic.fingerboard', => @update())

    @update()

  update: ->
    scale_tonic_name = State.scale_tonic_name
    scale_tonic = State.scale_tonic_pitch
    scale = Scales[State.scale_class_name]
    scale_pitches = (pitch_class(pitch + scale_tonic) for pitch in scale)
    tonic = scale_pitches[0]

    for k in @label_sets
      visible = k == @note_display.replace(/_/g, '-')
      labels = d3.select('#fingerboard').selectAll('.' + k.replace(/s$/, ''))
      labels.attr('visibility', if visible then 'inherit' else 'hidden')

    pitch_name_options = {sharp: true}
    pitch_name_options = {flat: true} if scale_tonic_name.match(/b/)

    @d3_notes.each ({pitch, circle}) ->
      scale_degree = pitch_class(pitch - tonic)
      note_label = d3.select(this)
        .classed('scale', pitch in scale_pitches)
        .classed('chromatic', pitch not in scale_pitches)
        .classed('root', scale_degree == 0)
        .classed('fifth', scale_degree == 7)
        .select('.note')
      note_label.select('.base')
          .text(({pitch}) -> pitch_name(pitch, pitch_name_options).replace(/(.).*/, '$1'))
      note_label.select('.accidental')
          .text(({pitch}) -> pitch_name(pitch, pitch_name_options).replace(/^./, ''))

  update_instrument: ->
    string_pitches = Instruments[State.instrument_name]
    @d3_notes.each (note) ->
      {string_number, fret_number} = note
      note.pitch = pitch_class(string_pitches[string_number] + fret_number)
    @update()


class NoteGridView
  constructor: ->
    @views = []
    style = FingerboardStyle
    column_count = 12 * 5
    row_count = 12
    pos = $('#fingerboard').offset()

    root = d3.select('#scale-notes').append('svg').attr(
      width: column_count * style.string_width
      height: row_count * style.fret_height
    )

    notes = _.flatten({column, row} for column in [0...column_count] for row in [0...row_count])
    notes.forEach (note) ->
      note.scale_degree = pitch_class(note.column * 7 + note.row)
    degrees = d3.nest()
      .key((d) -> d.scale_degree)
      .entries(notes)

    @note_views = root.selectAll('g')
      .data(degrees).enter()
      .append('g')
      .selectAll('.note').data((d) -> d.values)
        .enter()
          .append('g')
          .classed('note', true)
          .attr(
            transform: ({column, row}) ->
              x = (column + 0.5) * style.string_width
              y = row * style.fret_height + FingerboardNoteStyle.all.radius
              "translate(#{x}, #{y})"
            )

    @note_views.append('circle')
      .attr(r: FingerboardNoteStyle.all.radius)
    @note_views.append('text')
      .attr(y: 7)
      .text((d) -> ScaleDegreeNames[d.scale_degree])

    D3State.on('instrument.note_grid', => @update())
    D3State.on('scale.note_grid', => @update())
    D3State.on('scale_tonic.note_grid', => @update())

    @update()

    # defer this, so it doesn't affect the initial positioning
    setTimeout (-> $('#scale-notes').addClass('animate')), 1

  update_note_colors: ->
    scale_class_name = State.scale_class_name
    return if @scale_class_name == scale_class_name
    @scale_class_name = scale_class_name
    scale_pitches = Scales[State.scale_class_name]

    @note_views
      .classed('chromatic', (d) -> d.scale_degree not in scale_pitches)
      .classed('tonic', (d) -> d.scale_degree in scale_pitches and d.scale_degree == 0)
      .classed('fifth', (d) -> d.scale_degree in scale_pitches and d.scale_degree == 7)

  update: () ->
    @update_note_colors()
    scale_pitches = Scales[State.scale_class_name]
    scale_tonic = State.scale_tonic_pitch
    bass_pitch = Instruments[State.instrument_name][0]
    scale_pitches = (pitch_class(n + scale_tonic - bass_pitch) for n in scale_pitches)
    style = FingerboardStyle
    pos = $('#fingerboard').offset()
    pos.left -= style.string_width * pitch_class(scale_pitches[0] * 5)
    # FIXME why the fudge factors?
    $('#scale-notes').css(left: pos.left + 1, top: pos.top + 1)

scaleSelectorView = new ScaleSelectorView
fingerboardView = new FingerboardView
noteGridView = new NoteGridView
keyboardView = new KeyboardView

$('#instruments .btn').click ->
  $('#instruments .btn').removeClass('btn-default')
  $(@).addClass('btn-default')
  State.instrument_name = $(@).text()
  D3State.instrument()

$('#fingerings .btn').click ->
  $('#fingerings .btn').removeClass('btn-default')
  $(@).addClass('btn-default')
  fingerboardView.note_display = $(@).text().replace(' ', '_').toLowerCase()
  fingerboardView.update()

$('#about-text a').attr('target', '_blank')
$("#about").popover(content: $('#about-text').html(), html: true, placement: 'bottom')
