directives = angular.module('music.directives', [])

directives.directive 'fingerboard', (styles) ->
  restrict: 'CE'
  link: (scope, element, attrs) ->
    fingerboard = d3.music.fingerboard(scope, styles.fingerboard)
    d3.select(element[0]).call fingerboard
    scope.$watch ->
      fingerboard.attr 'noteLabel', scope.noteLabel
      fingerboard.attr 'scale', scope.scale
      fingerboard.attr 'instrument', scope.instrument
      fingerboard.attr 'tonic', scope.tonic
    fingerboard.on 'tapPitch', (pitch) ->
      scope.$apply ->
        scope.scaleTonic = pitch
    fingerboard.on 'focusPitch', (pitch) ->
      scope.$apply -> scope.hover.pitch = pitch
    fingerboard.on 'blurPitch', ->
      scope.$apply -> scope.hover.pitch = null

directives.directive 'pitchConstellation', (styles) ->
  restrict: 'CE'
  replace: true
  scope: {pitchClasses: '=', pitches: '=', hover: '='}
  transclude: true
  link: (scope, element, attrs) ->
    constellation = d3.music.pitchConstellation(scope.pitches, styles.scales)
    d3.select(element[0]).call constellation

directives.directive 'keyboard', (styles) ->
  restrict: 'CE'
  link: (scope, element, attrs) ->
    keyboard = d3.music.keyboard(scope, styles.keyboard)
    d3.select(element[0]).call keyboard
    scope.$watch ->
      keyboard.attr 'scale', scope.scale
      keyboard.attr 'tonic', scope.tonic
    keyboard.on 'tapPitch', (pitch) ->
      scope.$apply ->
        scope.tonic = pitch
    keyboard.on 'focusPitch', (pitch) ->
      scope.$apply ->
        scope.hover.pitch = pitch
        scope.hover.tonic = pitch
    keyboard.on 'blurPitch', ->
      scope.$apply ->
        scope.hover.pitch = null
        scope.hover.tonic = null
