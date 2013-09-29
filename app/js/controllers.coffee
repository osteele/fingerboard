{FlatNoteNames, Scales, getPitchName, pitchNameToNumber, pitchToPitchClass} = require('schoen').theory
Instruments = require('schoen').Instruments

controllers = angular.module('fingerboard.controllers', [])

controllers.controller 'FingerboardScalesCtrl', ($scope, $timeout, styles) ->
  # $scope.aboutText = document.querySelector('#about-text').outerHTML
  $scope.aboutText = $('#about-text').html()
  $scope.scales = Scales
  $scope.instruments = Instruments.filter (instrument) -> not instrument.fretted
  $scope.instrument = Instruments.Violin
  $scope.scale = Scales[0].modes[0]
  $scope.scaleTonicName = 'C'
  $scope.scaleTonicPitch = 0
  $scope.hover =
    pitchClasses: null
    scaleTonicPitch: null

  $scope.handleKey = (event) ->
    char = String.fromCharCode(event.charCode).toUpperCase()
    adjustPitchBy = (delta) ->
      $scope.scaleTonicPitch = (($scope.scaleTonicPitch + delta) % 12)
      $scope.scaleTonicName = getPitchName($scope.scaleTonicPitch)
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
