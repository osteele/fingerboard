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

pitchNumberToName = (pitchNumber) ->
  pitch = pitchToPitchClass(pitchNumber)
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
    # 'Octatonic' is the classical name. It's the jazz 'Diminished' scale.
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

class Instrument
  constructor: ({@name, @stringPitches}) ->

  pitchAt: ({string, fret}) ->
    @stringPitches[string] + fret


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
].map (attrs) -> new Instrument(attrs)

do ->
  Instruments[instrument.name] = instrument for instrument in Instruments

exports = {
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
