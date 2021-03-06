#
# App
#

app = angular.module 'FingerboardApp', ['ui.bootstrap', 'music.directives', 'unsafe-popover', 'fingerboard.controllers']


#
# Styles
#

Styles =
  fingerboard:
    stringWdith: 50
    fretHeight: 50
    noteRadius: 20

  keyboard:
    octaves: 2
    keyWidth: 25
    keyMargin: 3
    whiteKeyHeight: 120
    blackKeyHeight: 90

  scales:
    constellationRadius: 28
    pitchRadius: 3

app.constant 'styles', Styles
