{getPitchName} = require './theory'

directives = angular.module('music.directives', [])

directives.directive 'fingerboard', ->
  restrict: 'CE'
  link: (scope, element, attrs) ->
    fingerboard = d3.music.fingerboard(scope, Style.fingerboard)
    d3.select(element[0]).call fingerboard
    scope.$watch ->
      fingerboard.attr 'noteLabel', scope.noteLabel
      fingerboard.attr 'scale', scope.scale
      fingerboard.attr 'instrument', scope.instrument
      fingerboard.attr 'tonicPitch', scope.scaleTonicPitch
    fingerboard.on 'tapPitch', (pitch) ->
      scope.$apply ->
        scope.scaleTonicName = getPitchName(pitch)
        scope.scaleTonicPitch = pitch
    fingerboard.on 'focusPitch', (pitch) ->
      scope.$apply -> scope.hover.pitch = pitch
    fingerboard.on 'blurPitch', ->
      scope.$apply -> scope.hover.pitch = null

directives.directive 'pitchConstellation', ->
  restrict: 'CE'
  replace: true
  scope: {pitchClasses: '=', pitches: '=', hover: '='}
  transclude: true
  link: (scope, element, attrs) ->
    constellation = d3.music.pitchConstellation(scope.pitches, Style.scales)
    d3.select(element[0]).call constellation

directives.directive 'keyboard', ->
  restrict: 'CE'
  link: (scope, element, attrs) ->
    keyboard = d3.music.keyboard(scope, Style.keyboard)
    d3.select(element[0]).call keyboard
    scope.$watch ->
      keyboard.attr 'tonicPitch', scope.scaleTonicPitch
      keyboard.attr 'scale', scope.scale
    keyboard.on 'tapPitch', (pitch) ->
      scope.$apply ->
        scope.scaleTonicName = getPitchName(pitch)
        scope.scaleTonicPitch = pitch
    keyboard.on 'focusPitch', (pitch) ->
      scope.$apply ->
        scope.hover.pitch = pitch
        scope.hover.scaleTonicPitch = pitch
    keyboard.on 'blurPitch', ->
      scope.$apply ->
        scope.hover.pitch = null
        scope.hover.scaleTonicPitch = null
