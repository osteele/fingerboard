{SharpNoteNames, getPitchName, pitchNameToNumber, pitchToPitchClass} = require('schoen').pitches
{Instruments, Pitch, Scales} = require('schoen')

controllers = angular.module('fingerboard.controllers', [])

controllers.controller 'FingerboardScalesCtrl', ($scope, $timeout, styles) ->
  # $scope.aboutText = document.querySelector('#about-text').outerHTML
  $scope.aboutText = $('#about-text').html()
  $scope.scales = Scales
  $scope.instruments = Instruments.filter (instrument) -> not instrument.fretted
  $scope.instrument = Instruments.Violin
  $scope.scale = Scales[0].modes[0]
  $scope.tonic = Pitch.fromString('C')
  $scope.hover =
    pitchClasses: null
    tonic: null

  $scope.handleKey = (event) ->
    char = String.fromCharCode(event.charCode).toUpperCase()
    adjustPitchBy = (delta) ->
      $scope.tonic = Pitch.fromMidiNumber(($scope.tonic.midiNumber + delta + 12) % 12)
    switch char
      when 'A', 'B', 'C', 'D', 'E', 'F', 'G'
        $scope.tonic = Pitch.fromString(char)
      when '#', '+'
        adjustPitchBy 1
      when 'b', '-'
        adjustPitchBy -1
      # when '\015' then $scope.apply ->
      # else console.info char, event.charCode

  $scope.setInstrument = (instr) ->
    $scope.instrument = instr if instr?

  $scope.selectScale = (scale) ->
    $scope.scale = scale.modes?[scale.modeIndex] or scale

  $scope.bodyClassNames = ->
    hover = $scope.hover
    tonic = (hover.tonic ? $scope.tonic).toPitchClass()
    scalePitchClasses = hover.scale?.pitchClasses ? $scope.scale.pitchClasses
    showSharps = Boolean(
      (SharpNoteNames[tonic.toPitchClass().semitones].length == 1) ^
      Boolean(SharpNoteNames[tonic.toPitchClass().semitones].match(/F/))
    )
    classes = []
    classes.push (if showSharps then 'hide-flat-labels' else 'hide-sharp-labels')
    classes = classes.concat ("scale-includes-relative-pitch-class-#{semitones}" for {semitones} in scalePitchClasses)
    ks = ("scale-includes-pitch-class-#{pitchToPitchClass(semitones + tonic)}" for {semitones} in scalePitchClasses)
    classes = classes.concat ks
    if hover.pitch?
      classes.push "hover-note-relative-pitch-class-#{pitchToPitchClass(hover.pitch.midiNumber - tonic.semitones)}"
      classes.push "hover-note-pitch-class-#{pitchToPitchClass(hover.pitch.toPitchClass().semitones)}"
    classes

  do ->
    noteGrid = d3.music.noteGrid($scope, styles.fingerboard, document.querySelector('#fingerboard'))
    noteGridElement = d3.select('#scale-notes')
    noteGridElement.call noteGrid
    # `update` forces a layout; is very slow
    $timeout(->
        noteGrid.update()
        noteGridElement.classed 'initializing', false
        $scope.$watch -> noteGrid.update()
        # don't animate to the initial position
        $timeout (-> noteGridElement.classed 'animate', true), 1
      , 1000)

  $('#fingerings .btn').click ->
    $('#fingerings .btn').removeClass 'btn-default'
    $(@).addClass 'btn-default'
    noteLabelName = $(@).text().replace(' ', '_').toLowerCase().replace('fingers', 'fingerings')
    $scope.$apply ->
      $scope.noteLabel = noteLabelName

  angular.element(document).bind 'touchmove', false
  angular.element(document.body).removeClass 'loading'
