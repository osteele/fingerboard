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
  scale_root_name: 'C'
  scale_root_pitch: 0
  scale_class_name: 'Diatonic Major'

StringCount = 4
FingerPositions = 7

FingerboardStyle =
  string_width: 50
  fret_height: 50

ScaleRootColor = 'rgb(255, 96, 96)'

FingerboardNoteStyle =
  all:
    radius: 20
    stroke: 'blue'
    'fill-opacity': 1
    'stroke-opacity': 1
    label:
      fill: 'black'
      'font-size': 20
  scale:
    fill: 'lightGreen'
  root:
    fill: ScaleRootColor
    label: {'font-weight': 'bold'}
  fifth: {fill: 'rgb(192,192,255)'}
  chromatic:
    stroke: 'white'
    fill: 'white'
    'fill-opacity': 0
    'stroke-opacity': 0
    label: {fill: 'gray', 'font-size': 15}

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
    root:
      fill: 'rgb(255,128,128)'
    fifth:
      fill: 'rgb(128,128,255)'

pitch_at = (string_number, fret_number) ->
  (string_number * 7 + fret_number) % 12

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
    root = d3.select('#keyboard').append('svg')
      .attr('width', 7 * (style.Key.width + style.Key.margin))
      .attr('height', style.WhiteKey.height + 1)

    next_x = 1
    @keys = [0...12].map (pitch) ->
      note_name = pitch_name(pitch, flat: true)
      is_black_key = FlatNoteNames[pitch].length > 1
      {width, height} = key_style =
        _.extend {}, KeyboardStyle.Key, (if is_black_key then KeyboardStyle.BlackKey else KeyboardStyle.WhiteKey)
      x = next_x
      next_x += width + KeyboardStyle.Key.margin unless is_black_key
      x -= width / 2 if is_black_key
      return {pitch, name: note_name, is_black_key, attrs: {width, height, x, y: 0}}
    @keys.sort (a, b) -> a.is_black_key - b.is_black_key

    onclick = ({pitch, name}) ->
      State.scale_root_name = FlatNoteNames[pitch]
      State.scale_root_pitch = pitch
      fingerboardView.update()

    @d3_keys = root.selectAll('.piano-key')
      .data(@keys).enter()
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

  update_keyboard: (root_pitch) ->
    @d3_keys.each ({pitch}) ->
      d3.select(this).classed('root', pitch == State.scale_root_pitch)


class ScaleSelectorView
  constructor: ->
    style = ScaleStyle
    paper = @get_paper()
    cols = style.cols
    @views = {}
    ScaleNames.forEach (name, i) =>
      pitches = Scales[name]
      cell_width = style.cell.width
      cell_height = style.cell.height
      x = cell_width / 2 + (i % cols) * cell_width
      y = 6 + Math.floor(i / cols) * cell_height
      paper.setStart()
      bg = paper.rect(x - cell_width / 2, y - 5, cell_width - 5, cell_width, 2)
        .attr stroke: 'gray'
      hover = paper.rect(x - cell_width / 2, y - 5, cell_width - 5, cell_width, 2)
        .attr fill: 'gray', 'fill-opacity': 0
      paper.text x, y, name
      y += 40
      for pitch in [0...12]
        r = style.pitch_circle.radius
        a = (pitch - 3) * 2 * Math.PI / 12
        nx = x + Math.cos(a) * r
        ny = y + Math.sin(a) * r
        note_circle = paper.circle nx, ny, style.pitch_circle.note.radius
        if pitch in pitches
          paper.path ['M',x,',',y,'L',nx,',',ny].join('')
          note_circle.attr fill: 'gray'
          note_circle.toFront()
          note_circle.attr style.pitch_circle.root if pitch == 0
          note_circle.attr style.pitch_circle.fifth if pitch == 7
      bg.toBack()
      hover.toFront()
      paper.setFinish()
        .attr(cursor: 'pointer')
        .mouseover(-> hover.animate 'fill-opacity': 0.4)
        .mouseout(-> hover.animate 'fill-opacity': 0)
        .click =>
          State.scale_class_name = name
          fingerboardView.update()
          @update()
      @views[name] = bg

  get_paper: ->
    style = ScaleStyle
    @paper or= Raphael('scales',
      (style.cell.width + style.cell.padding) * style.cols,
      Math.ceil(_.keys(Scales).length / style.cols) * (style.cell.height + style.cell.padding))

  update: ->
    ScaleNames.forEach (name, i) =>
      @views[name].animate fill: (if name == State.scale_class_name then 'lightBlue' else 'white')


class FingerboardView
  constructor: ->
    @note_display = 'notes'
    @draw_fingerboard()

  draw_fingerboard: ->
    style = FingerboardStyle

    root = d3.select('#fingerboard').append('svg')
      .attr('width', StringCount * style.string_width)
      .attr('height', FingerPositions * style.fret_height)

    nut_y = style.fret_height - 5
    root.append('line')
      .classed('nut', true)
      .attr(x1: 0, y1: nut_y, x2: StringCount * style.string_width, y2: nut_y)

    root.selectAll('.string')
      .data([0...StringCount]).enter()
    .append('line')
      .classed('string', true)
      .attr(
        x1: (d) -> (d + 0.5) * style.string_width
        y1: style.fret_height * 0.5
        x2: (d) -> (d + 0.5) * style.string_width
        y2: (1 + FingerPositions) * style.fret_height
      )

    note_style = FingerboardNoteStyle
    finger_positions = []
    for string_number in [0...StringCount]
      for fret_number in [0..FingerPositions]
        pitch = pitch_at(string_number, fret_number)
        note_name = pitch_name(pitch)
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
      .attr(r: 20)

    @d3_notes.append('text')
      .classed('note', true)
      .attr(y: 7)
      .text(({note_name}) -> note_name)
    @d3_notes.append('text')
      .classed('fingering', true)
      .attr(y: 7)
      .text(({fingering_name}) -> fingering_name)
    @d3_notes.append('text')
      .classed('scale-degree', true)
      .attr(y: 7)
      .text(({scale_degree_name}) -> scale_degree_name)

  update: ->
    scale_root_name = State.scale_root_name
    scale_root = State.scale_root_pitch
    keyboardView.update_keyboard scale_root
    scale = Scales[State.scale_class_name]
    scale_pitches = ((n + scale_root) % 12 for n in scale)

    for k in ['notes', 'fingerings', 'scale_degrees']
      visible = k == @note_display
      labels = d3.select('#fingerboard').selectAll('.' + k.replace(/s$/, '').replace(/_/g, '-'))
      labels.attr('visibility', if visible then 'inherit' else 'hidden')

    pitch_name_options = {sharp: true}
    pitch_name_options = {flat: true} if scale_root_name.match(/b/)

    @d3_notes.each ({pitch, circle}) ->
      scale_degree = (pitch - scale_pitches[0] + 12) % 12
      d3.select(this)
        .classed('scale', pitch in scale_pitches)
        .classed('chromatic', pitch not in scale_pitches)
        .classed('root', scale_degree == 0)
        .classed('fifth', scale_degree == 7)
        .select('text')
          .text(({pitch}) -> pitch_name(pitch, pitch_name_options))


  update_instrument: ->
    string_pitches = Instruments[State.instrument_name]
    for note in @note_views
      {string_number, fret_number} = note
      note.pitch = (string_pitches[string_number] + fret_number) % 12
    @update()


class NoteGridView
  constructor: ->
    @views = []
    style = FingerboardStyle
    string_count = 12 * 5
    fret_count = 12
    paper = Raphael('scale-notes', string_count * style.string_width, fret_count * style.fret_height)
    pos = $('#fingerboard').offset()
    pos.left += 5
    pos.top += 4
    $('#scale-notes').css(left: pos.left, top: pos.top)
    for string_number in [0...string_count]
      for fret_number in [0...fret_count]
        pitch = (string_number * 7 + fret_number) % 12
        x = (string_number + 0.5) * style.string_width
        y = fret_number * style.fret_height + FingerboardNoteStyle.all.radius + 1
        circle = paper.circle(x, y, FingerboardNoteStyle.all.radius).attr fill: 'red'
        label = paper.text(x, y, ScaleDegreeNames[pitch]).attr fill: 'white', 'font-size': 16
        @views.push {pitch, circle, label}

  update_note_colors: ->
    scale_class_name = State.scale_class_name
    return if @scale_class_name == scale_class_name
    @scale_class_name = scale_class_name
    scale_pitches = Scales[State.scale_class_name]
    for {pitch, circle, label} in @views
      fill = switch
        when scale_pitches.indexOf(pitch) == 0 then 'red'
        when pitch in scale_pitches and pitch == 7 then 'blue'
        when pitch in scale_pitches then 'green'
        else null
      circle.attr fill: fill

  update_background_scale: () ->
    @update_note_colors()
    scale_pitches = Scales[State.scale_class_name]
    scale_root = State.scale_root_pitch
    bass_pitch = Instruments[State.instrument_name][0]
    scale_pitches = ((n + scale_root - bass_pitch + 12) % 12 for n in scale_pitches)
    pos = $('#fingerboard').offset()
    pos.left += 1
    pos.top += 2
    style = FingerboardStyle
    pos.left -= style.string_width * ((scale_pitches[0] * 5) % 12)
    $('#scale-notes').addClass('animate')
    $('#scale-notes').css(left: pos.left, top: pos.top)

scaleSelectorView = new ScaleSelectorView
fingerboardView = new FingerboardView
noteGridView = new NoteGridView
keyboardView = new KeyboardView

fingerboardView.update()
scaleSelectorView.update()
noteGridView.update_background_scale()

$('#instruments .btn').click ->
  $('#instruments .btn').removeClass('btn-default')
  $(@).addClass('btn-default')
  State.instrument_name = $(@).text()
  fingerboardView.update_instrument()
  noteGridView.update_background_scale()

$('#fingerings .btn').click ->
  $('#fingerings .btn').removeClass('btn-default')
  $(@).addClass('btn-default')
  fingerboardView.note_display = $(@).text().replace(' ', '_').toLowerCase()
  fingerboardView.update()
