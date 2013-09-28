directives = angular.module('music.directives', [])

directives.directive 'fingerboard', ->
  restrict: 'CE'
  link: (scope, element, attrs) ->
    fingerboard = d3.music.fingerboard scope, Style.fingerboard
    d3.select(element[0]).call fingerboard
    scope.$watch ->
      fingerboard.attr 'note_label', scope.note_label
      fingerboard.attr 'scale', scope.scale
      fingerboard.attr 'tonic_pitch', scope.scale_tonic_pitch
    fingerboard.on 'tap_pitch', (pitch) ->
      scope.$apply ->
        scope.scale_tonic_name = pitch_name(pitch)
        scope.scale_tonic_pitch = pitch
    fingerboard.on 'focus_pitch', (pitch) ->
      scope.$apply -> scope.hover.pitch = pitch
    fingerboard.on 'blur_pitch', ->
      scope.$apply -> scope.hover.pitch = null

directives.directive 'pitchConstellation', ->
  restrict: 'CE'
  replace: true
  scope: {pitch_classes: '=', pitches: '=', hover: '='}
  transclude: true
  link: (scope, element, attrs) ->
    constellation = d3.music.pitch_constellation scope.pitches, Style.scales
    d3.select(element[0]).call constellation

directives.directive 'keyboard', ->
  restrict: 'CE'
  link: (scope, element, attrs) ->
    keyboard = d3.music.keyboard scope, Style.keyboard
    d3.select(element[0]).call keyboard
    scope.$watch ->
      keyboard.attr 'tonic_pitch', scope.scale_tonic_pitch
      keyboard.attr 'scale', scope.scale
    keyboard.on 'tap_pitch', (pitch) ->
      scope.$apply ->
        scope.scale_tonic_name = pitch_name pitch
        scope.scale_tonic_pitch = pitch
    keyboard.on 'focus_pitch', (pitch) ->
      scope.$apply ->
        scope.hover.pitch = pitch
        scope.hover.scale_tonic_pitch = pitch
    keyboard.on 'blur_pitch', ->
      scope.$apply ->
        scope.hover.pitch = null
        scope.hover.scale_tonic_pitch = null
