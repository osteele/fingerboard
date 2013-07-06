SharpNoteNames = 'C C# D D# E F F# G G# A A# B'.split(/\s/)
FlatNoteNames = 'C Db D Eb E F Gb G Ab A Bb B'.split(/\s/)

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

Instruments =
  Violin: [7,14,21,28]
  Viola: [0,7,14,21]
  Cello: [0,7,14,21]

CurrentInstrument = 'Cello'
CurrentScaleRoot = 'C'
CurrentScale = 'Diatonic Major'

StringCount = 4
FingerPositions = 7

FingerboardStyle =
  string_width: 50
  fret_height: 50

ScaleRootColor = 'rgb(255,96,96)'

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
  root:
    fill: ScaleRootColor
  Key:
    width: 25
    margin: 3
  WhiteKey:
    height: 120
    key:
      fill: 'white'
    label:
      'font-size': 20
  BlackKey:
    height: 90
    key:
      fill: 'black'
    label:
      'font-size': 12
      fill: 'white'

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

FingerboardPaper = Raphael('fingerboard',
  StringCount * FingerboardStyle.string_width,
  FingerPositions * FingerboardStyle.fret_height)

KeyboardPaper = Raphael('keyboard',
  7 * (KeyboardStyle.Key.width + KeyboardStyle.Key.margin),
  KeyboardStyle.WhiteKey.height + 1)

ScalePaper = Raphael('scales',
  (ScaleStyle.cell.width + ScaleStyle.cell.padding) * ScaleStyle.cols,
  Math.ceil(_.keys(Scales).length / ScaleStyle.cols) * (ScaleStyle.cell.height + ScaleStyle.cell.padding))

pitch_at = (string_number, fret_number) ->
  (string_number * 7 + fret_number) % 12

pitch_name = (pitch, options={}) ->
  flatName = FlatNoteNames[pitch]
  sharpName = SharpNoteNames[pitch]
  name = if options.sharp then sharpName else flatName
  if options.flat and options.sharp and flatName != sharpName
    name = "#{flatName}/\n#{sharpName}"
  name.replace(/b/, '\u266D').replace(/#/g, '\u266F')

create_keyboard = ->
  paper = KeyboardPaper
  next_x = 1
  black_keys = paper.set()
  [0...12].forEach (pitch) ->
    is_black_key = FlatNoteNames[pitch].length > 1
    style = _.extend {}, KeyboardStyle.Key, (if is_black_key then KeyboardStyle.BlackKey else KeyboardStyle.WhiteKey)
    {width, height} = style
    x = next_x
    next_x += width + KeyboardStyle.Key.margin unless is_black_key
    x -= width / 2 if is_black_key
    note_name = pitch_name(pitch, flat: true)

    paper.setStart()
    key = paper.rect(x, 0, width, height, 2).attr(style.key)#.glow()
    label = paper.text(x + width / 2, height - 10, note_name).attr style.label
    hover = paper.rect(x, 0, width, height).attr fill: (if is_black_key then 'white' else 'black'), 'fill-opacity': 0
    note_view = paper.setFinish()
      .attr(cursor: 'pointer')
      .mouseover(-> hover.animate 'fill-opacity': 0.4, 100)
      .mouseout(-> hover.animate 'fill-opacity': 0, 100)
      .click ->
        CurrentScaleRoot = pitch
        set_scale_notes fingerboard_notes, pitch
    black_keys.push note_view if is_black_key
    KeyboardViews[pitch] = {key, style}
  black_keys.toFront()

update_keyboard = (root_pitch) ->
  for pitch in [0...12]
    note_view = KeyboardViews[pitch]
    note_view.key.animate fill: (if pitch == root_pitch then KeyboardStyle.root.fill else note_view.style.key.fill), 100

ScaleViews = {}

create_scales = ->
  style = ScaleStyle
  paper = ScalePaper
  cols = style.cols
  ScaleNames.forEach (name, i) ->
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
      .click ->
        CurrentScale = name
        set_scale_notes fingerboard_notes, CurrentScaleRoot
        update_scales()
    ScaleViews[name] = bg

update_scales = ->
  ScaleNames.forEach (name, i) ->
    ScaleViews[name].animate fill: (if name == CurrentScale then 'lightBlue' else 'white')

draw_fingerboard = ->
  paper = FingerboardPaper
  for string_number in [0...StringCount]
    x = (string_number + 0.5) * FingerboardStyle.string_width
    # draw the string
    path = ['M', x, FingerboardStyle.fret_height * 0.5, 'L', x, (1 + FingerPositions) * FingerboardStyle.fret_height]
    paper.path(path.join())
  # draw the nut
  do ->
    y = FingerboardStyle.fret_height - 5
    paper.path(['M', 0, y, 'L', StringCount * FingerboardStyle.string_width, y].join())
      .attr 'stroke-width': 4, stroke: 'gray'

create_fingerboard_notes = ->
  paper = FingerboardPaper
  notes = []
  for string_number in [0...StringCount]
    x = (string_number + 0.5) * FingerboardStyle.string_width
    for fret_number in [0..FingerPositions]
      y = fret_number * FingerboardStyle.fret_height + FingerboardNoteStyle.all.radius + 1
      pitch = pitch_at(string_number, fret_number)
      notes.push
        string_number: string_number
        fret_number: fret_number
        pitch: pitch
        circle: paper.circle(x, y, FingerboardNoteStyle.all.radius).attr(FingerboardNoteStyle.all)
        label: paper.text x, y, pitch_name(pitch)
  notes

KeyboardViews = {}

set_scale_notes = (notes, scale_root=0) ->
  scale_root_name = scale_root
  if typeof(scale_root) == 'string'
    scale_root = FlatNoteNames.indexOf(scale_root_name)
    scale_root = SharpNoteNames.indexOf(scale_root_name) unless scale_root >= 0
  scale_root_name = FlatNoteNames[scale_root] unless typeof(scale_root_name) == 'string'
  update_keyboard scale_root
  scale = Scales[CurrentScale]
  scale_pitches = ((n + scale_root) % 12 for n in scale)
  update_background_scale scale_pitches
  for {pitch, circle, label} in notes
    note_type = {0: 'root', '-1': 'chromatic'}[scale_pitches.indexOf(pitch)] or 'scale'
    note_type = 'fifth' if pitch in scale_pitches and (pitch - scale_pitches[0] + 12) % 12 == 7
    pitch_name_options = {sharp: true}
    pitch_name_options = {flat: true} if scale_root_name.match(/b/)
    pitch_name_options = {flat: true, sharp: true} if note_type == 'chromatic'
    attrs = _.extend({}, FingerboardNoteStyle.all, FingerboardNoteStyle[note_type])
    circle.animate attrs, 400
    label.attr text: pitch_name(pitch, pitch_name_options)
    label.animate _.extend({}, FingerboardNoteStyle.all.label, FingerboardNoteStyle[note_type].label), 400

BackgroundScaleViews = []
do ->
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
      BackgroundScaleViews.push {pitch, circle}

update_background_scale = (scale_pitches_0) ->
  scale_pitches = Scales[CurrentScale]
  for {pitch, circle} in BackgroundScaleViews
    pitch = (pitch + 12 + Instruments[CurrentInstrument][0]) % 12
    fill = 'white'
    fill = 'green' if pitch in scale_pitches
    fill = 'blue' if pitch in scale_pitches and pitch == 7
    fill = 'red' if scale_pitches.indexOf(pitch) == 0
    circle.animate fill: fill, 100
  pos = $('#fingerboard').offset()
  pos.left += 5
  pos.top += 4
  style = FingerboardStyle
  pos.left -= style.string_width * ((scale_pitches_0[0] * 5) % 12)
  $('#scale-notes').addClass('animate')
  $('#scale-notes').css(left: pos.left, top: pos.top)

create_keyboard()
create_scales()
draw_fingerboard()
fingerboard_notes = create_fingerboard_notes()
set_scale_notes(fingerboard_notes, CurrentScaleRoot)
update_scales()

$('h2#instruments span').click ->
  CurrentInstrument = $(@).text()
  string_pitches = Instruments[CurrentInstrument]
  for note in fingerboard_notes
    {string_number, fret_number} = note
    note.pitch = (string_pitches[string_number] + fret_number) % 12
  set_scale_notes fingerboard_notes, CurrentScaleRoot
  $('h2#instruments span').removeClass('selected')
  $(@).addClass('selected')
  set_scale_notes(fingerboard_notes, CurrentScaleRoot)
