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

exports = {
  fingerboard_position_pitch
  FlatNoteNames
  Instruments
  pitch_name
  pitch_to_pitch_class
  Pitches
  ScaleDegreeNames
  Scales
  SharpNoteNames
}

if module?.exports? then module.exports = exports else @MusicTheory = exports
