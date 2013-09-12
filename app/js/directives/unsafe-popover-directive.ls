angular.module('unsafe-popover', []).directive \unsafePopoverPopup, ->
  restrict: 'EA'
  replace: true
  scope: {title: '@', content: '@', placement: '@', animation: '&', isOpen: '&'}
  templateUrl: 'templates/popover.html'
.directive \unsafePopover, ($tooltip) ->
  $tooltip \unsafePopover \popover \click
