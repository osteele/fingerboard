controllers = angular.module('fingerboard.controllers', [])

controllers.controller 'FingerboardScalesCtrl', ($scope) ->
  window[k] = v for k, v of MusicTheory
  # $scope.aboutText = document.querySelector('#about-text').outerHTML
  $scope.aboutText = $('#about-text').html()
  $scope.scales = Scales
  $scope.instruments = Instruments
  $scope.instrument = Instruments.Violin
  $scope.scale = Scales[0].modes[0]
  $scope.scale_tonic_name = 'C'
  $scope.scale_tonic_pitch = 0
  $scope.hover =
    pitch_classes: null
    scale_tonic_pitch: null

  $scope.handleKey = (event) ->
    char = String.fromCharCode(event.charCode).toUpperCase()
    switch char
      when 'A', 'B', 'C', 'D', 'E', 'F', 'G'
        $scope.scale_tonic_name = char
        $scope.scale_tonic_pitch = pitch_name_to_number char
      when '#', '+'
        $scope.scale_tonic_pitch = (($scope.scale_tonic_pitch + 1) % 12)
        $scope.scale_tonic_name = pitch_name $scope.scale_tonic_pitch
      when 'b', '-'
        $scope.scale_tonic_pitch = (($scope.scale_tonic_pitch - 1 + 12) % 12)
        $scope.scale_tonic_name = pitch_name $scope.scale_tonic_pitch
      # when '\015' then $scope.apply ->
      # else console.info char, event.charCode

  $scope.setInstrument = (instr) ->
    $scope.instrument = instr if instr?

  $scope.setScale = (s) ->
    $scope.scale = s.modes?[s.mode_index] or s

  $scope.bodyClassNames = ->
    hover = $scope.hover
    scale_tonic = hover.scale_tonic_pitch ? $scope.scale_tonic_pitch
    scale_pitch_classes = hover.scale?.pitch_classes ? $scope.scale.pitch_classes
    show_sharps = Boolean(
      (FlatNoteNames[pitch_to_pitch_class(scale_tonic)].length == 1) ^
      (FlatNoteNames[pitch_to_pitch_class(scale_tonic)] == /F/)
    )
    classes = []
    classes.push (if show_sharps then 'hide-flat-labels' else 'hide-sharp-labels')
    classes = classes.concat ("scale-includes-relative-pitch-class-#{n}" for n in scale_pitch_classes)
    ks = ("scale-includes-pitch-class-#{pitch_to_pitch_class(n + scale_tonic)}" for n in scale_pitch_classes)
    classes = classes.concat ks
    if hover.pitch?
      classes.push "hover-note-relative-pitch-class-#{pitch_to_pitch_class(hover.pitch - scale_tonic)}"
      classes.push "hover-note-pitch-class-#{pitch_to_pitch_class(hover.pitch)}"
    classes

  note_grid = d3.music.note_grid $scope, Style.fingerboard, document.querySelector('#fingerboard')
  d3.select('#scale-notes').call note_grid
  $scope.$watch -> note_grid.update()

  $('#fingerings .btn').click ->
    $('#fingerings .btn').removeClass 'btn-default'
    $(@).addClass 'btn-default'
    note_label_name = $(@).text().replace(' ', '_').toLowerCase().replace('fingers', 'fingerings')
    $scope.$apply ->
      $scope.note_label = note_label_name

  angular.element(document).bind 'touchmove', false
  angular.element(document.body).removeClass 'loading'
