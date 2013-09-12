#
# App
#

angular.module 'FingerboardApp', ['ui.bootstrap', 'music.directives', 'unsafe-popover', 'fingerboard.controllers']


#
# Style
#

const @Style =
  fingerboard:
    string_width: 50
    fret_height: 50
    note_radius: 20

  keyboard:
    octaves: 2
    key_width: 25
    key_spacing: 3
    white_key_height: 120
    black_key_height: 90

  scales:
    constellation_radius: 28
    pitch_radius: 3
