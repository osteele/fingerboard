SharpNoteNames = 'C C# D D# E F F# G G# A A# B'.split(/\s/)
FlatNoteNames = 'C Db D Eb E F Gb G Ab A Bb B'.split(/\s/)

Scales =
  'Diatonic Major': [0,2,4,5,7,9,11]
  'Natural Minor': [0,2,3,5,7,8,10]
  'Major Pentatonic': [0,2,4,7,9]
  'Minor Pentatonic': [0,3,5,7,10]
  'Melodic Minor': [0,2,3,5,7,9,11]
  'Harmonic Minor': [0,2,3,5,7,8,11]
  'Blues': [0,3,5,6,7,10]
  'Freygish': [0,1,4,5,7,8,10]
  'Whole Tone': [0,2,4,6,8,10]
  'Octatonic': [0,2,3,5,6,8,9,11]

CurrentScaleRoot = 'C'
CurrentScale = 'Diatonic Major'

StringCount = 4
FingerPositions = 7

StringWidth = 50
FretHeight = 50
NoteRadius = 20
LeftMargin = 0

NoteStyles =
  all:
    stroke: 'blue'
    'fill-opacity': 1
    'stroke-opacity': 1
    label:
      fill: 'black'
      'font-size': 20
  scale:
    fill: 'lightBlue'
  root:
    fill: 'red'
    label: {'font-weight': 'bold'}
  fifth: {fill: 'rgb(192,192,255)'}
  chromatic:
    stroke: 'white'
    fill: 'white'
    'fill-opacity': 0
    'stroke-opacity': 0
    label: {fill: 'gray', 'font-size': 15}

FingerboardWidth = StringCount * StringWidth

paper = Raphael(10, 10, FingerboardWidth + 20 + 7 * 30 + 30, FingerPositions * FretHeight + 60)

pitch_at = (string_number, fret_number) ->
  (string_number * 7 + fret_number) % 12

pitch_name = (pitch, options={}) ->
  flatName = FlatNoteNames[pitch]
  sharpName = SharpNoteNames[pitch]
  name = if options.sharp then sharpName else flatName
  if options.flat and options.sharp and flatName != sharpName
    name = "#{flatName}/\n#{sharpName}"
  name.replace(/b/, '\u266D').replace(/#/g, '\u266F')

KeyboardStyle =
  Key:
    width: 25
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

create_keyboard = ->
  console.info 'x'
  next_x = FingerboardWidth + 20
  black_keys = paper.set()
  [0...12].forEach (pitch) ->
    is_black_key = FlatNoteNames[pitch].length > 1
    style = _.extend {}, KeyboardStyle.Key, (if is_black_key then KeyboardStyle.BlackKey else KeyboardStyle.WhiteKey)
    {width, height} = style
    x = next_x
    y = 0
    next_x += width + 2 unless is_black_key
    x -= width / 2 if is_black_key
    note_name = pitch_name(pitch, flat: true)

    paper.setStart()
    key = paper.rect(x, 10, width, height, 2).attr style.key
    label = paper.text(x + width / 2, y + height, note_name).attr style.label
    note = paper.setFinish()
      .attr(cursor: 'pointer')
      .mouseover(-> key.animate fill: 'gray', 100)
      .mouseout(-> key.animate style.key, 100)
      .click ->
        CurrentScaleRoot = pitch
        set_scale_notes fingerboard_notes, pitch
     black_keys.push note if is_black_key
  black_keys.toFront()

create_scales = ->
  i = -1
  for name, pitches of Scales
    i += 1
    do (name=name) ->
      x = FingerboardWidth + 50 + (i % 3) * 80
      y = 150 + Math.floor(i / 3) * 90
      p = paper.rect(x - 80 / 2, y - 5, 80 - 5, 80, 2)
        .attr(stroke: 'gray')
        .mouseover(-> p.animate fill: 'gray')
        .mouseout(-> p.animate fill: 'white')
        .click ->
          CurrentScale = name
          set_scale_notes fingerboard_notes, CurrentScaleRoot
      paper.text x, y, name
      y += 40
      for pitch in [0...12]
        r = 30
        a = (pitch - 3) * 2 * Math.PI / 12
        nx = x + Math.cos(a) * r
        ny = y + Math.sin(a) * r
        note = paper.circle nx, ny, 2
        if pitch in pitches
          paper.path ['M',x,',',y,'L',nx,',',ny].join('')
          note.attr fill: 'gray'
        note.attr fill: 'red' if pitch == 0

create_scales()

draw_fingerboard = ->
  for string_number in [0...StringCount]
    x = (string_number + 0.5) * StringWidth
    # draw the string
    paper.path(['M', x, FretHeight * 0.5, 'L', x, (1 + FingerPositions) * FretHeight].join())
  # draw the nut
  do ->
    y = FretHeight - 5
    paper.path(['M', 0, y, 'L', StringCount * StringWidth, y].join())
      .attr 'stroke-width': 4, stroke: 'gray'

create_fingerboard_notes = ->
  notes = []
  for string_number in [0...StringCount]
    x = (string_number + 0.5) * StringWidth
    for fret_number in [0..FingerPositions]
      y = fret_number * FretHeight + NoteRadius + 1
      pitch = pitch_at(string_number, fret_number)
      notes.push
        pitch: pitch
        circle: paper.circle(x, y, NoteRadius).attr(NoteStyles.all)
        label: paper.text x, y, pitch_name(pitch)
  notes

set_scale_notes = (notes, scale_root=0) ->
  scale_root_name = scale_root
  if typeof(scale_root) == 'string'
    scale_root = FlatNoteNames.indexOf(scale_root_name)
    scale_root = SharpNoteNames.indexOf(scale_root_name) unless scale_root >= 0
  scale_root_name = FlatNoteNames[scale_root] unless typeof(scale_root_name) == 'string'
  scale = Scales[CurrentScale]
  scale_pitches = ((n + scale_root) % 12 for n in scale)
  for {pitch, circle, label} in notes
    note_type = {0: 'root', 5: 'fifth', '-1': 'chromatic'}[scale_pitches.indexOf(pitch)] or 'scale'
    pitch_name_options = {sharp: true}
    pitch_name_options = {flat: true} if scale_root_name.match(/b/)
    pitch_name_options = {flat: true, sharp: true} if note_type == 'chromatic'
    attrs = _.extend({}, NoteStyles.all, NoteStyles[note_type])
    circle.animate attrs, 400
    label.attr text: pitch_name(pitch, pitch_name_options)
    label.animate _.extend({}, NoteStyles.all.label, NoteStyles[note_type].label), 400

create_keyboard()
draw_fingerboard()
fingerboard_notes = create_fingerboard_notes()
set_scale_notes fingerboard_notes, CurrentScaleRoot
