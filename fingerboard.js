(function() {
  var BackgroundScaleViews, CurrentInstrument, CurrentScale, CurrentScaleRoot, FingerPositions, FingerboardNoteStyle, FingerboardPaper, FingerboardStyle, FlatNoteNames, Instruments, KeyboardPaper, KeyboardStyle, KeyboardViews, ScaleNames, ScalePaper, ScaleRootColor, ScaleStyle, ScaleViews, Scales, SharpNoteNames, StringCount, create_fingerboard_notes, create_keyboard, create_scales, draw_fingerboard, fingerboard_notes, pitch_at, pitch_name, scale, set_scale_notes, update_background_scale, update_keyboard, update_scales,
    __indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

  SharpNoteNames = 'C C# D D# E F F# G G# A A# B'.split(/\s/);

  FlatNoteNames = 'C Db D Eb E F Gb G Ab A Bb B'.split(/\s/);

  Scales = [
    {
      'Diatonic Major': [0, 2, 4, 5, 7, 9, 11]
    }, {
      'Natural Minor': [0, 2, 3, 5, 7, 8, 10]
    }, {
      'Major Pentatonic': [0, 2, 4, 7, 9]
    }, {
      'Minor Pentatonic': [0, 3, 5, 7, 10]
    }, {
      'Melodic Minor': [0, 2, 3, 5, 7, 9, 11]
    }, {
      'Harmonic Minor': [0, 2, 3, 5, 7, 8, 11]
    }, {
      'Blues': [0, 3, 5, 6, 7, 10]
    }, {
      'Freygish': [0, 1, 4, 5, 7, 8, 10]
    }, {
      'Whole Tone': [0, 2, 4, 6, 8, 10]
    }, {
      'Octatonic': [0, 2, 3, 5, 6, 8, 9, 11]
    }
  ];

  ScaleNames = (function() {
    var _i, _len, _results;
    _results = [];
    for (_i = 0, _len = Scales.length; _i < _len; _i++) {
      scale = Scales[_i];
      _results.push(_.keys(scale)[0]);
    }
    return _results;
  })();

  (function() {
    var name, pitches, _i, _len, _results;
    _results = [];
    for (_i = 0, _len = Scales.length; _i < _len; _i++) {
      scale = Scales[_i];
      name = _.keys(scale)[0];
      pitches = scale[name];
      _results.push(Scales[name] = pitches);
    }
    return _results;
  })();

  Instruments = {
    Violin: [7, 14, 21, 28],
    Viola: [0, 7, 14, 21],
    Cello: [0, 7, 14, 21]
  };

  CurrentInstrument = 'Cello';

  CurrentScaleRoot = 'C';

  CurrentScale = 'Diatonic Major';

  StringCount = 4;

  FingerPositions = 7;

  FingerboardStyle = {
    string_width: 50,
    fret_height: 50
  };

  ScaleRootColor = 'rgb(255,96,96)';

  FingerboardNoteStyle = {
    all: {
      radius: 20,
      stroke: 'blue',
      'fill-opacity': 1,
      'stroke-opacity': 1,
      label: {
        fill: 'black',
        'font-size': 20
      }
    },
    scale: {
      fill: 'lightGreen'
    },
    root: {
      fill: ScaleRootColor,
      label: {
        'font-weight': 'bold'
      }
    },
    fifth: {
      fill: 'rgb(192,192,255)'
    },
    chromatic: {
      stroke: 'white',
      fill: 'white',
      'fill-opacity': 0,
      'stroke-opacity': 0,
      label: {
        fill: 'gray',
        'font-size': 15
      }
    }
  };

  KeyboardStyle = {
    root: {
      fill: ScaleRootColor
    },
    Key: {
      width: 25,
      margin: 3
    },
    WhiteKey: {
      height: 120,
      key: {
        fill: 'white'
      },
      label: {
        'font-size': 20
      }
    },
    BlackKey: {
      height: 90,
      key: {
        fill: 'black'
      },
      label: {
        'font-size': 12,
        fill: 'white'
      }
    }
  };

  ScaleStyle = {
    cols: 4,
    cell: {
      width: 85,
      height: 90,
      padding: 0
    },
    pitch_circle: {
      radius: 28,
      note: {
        radius: 3
      },
      root: {
        fill: 'rgb(255,128,128)'
      },
      fifth: {
        fill: 'rgb(128,128,255)'
      }
    }
  };

  FingerboardPaper = Raphael('fingerboard', StringCount * FingerboardStyle.string_width, FingerPositions * FingerboardStyle.fret_height);

  KeyboardPaper = Raphael('keyboard', 7 * (KeyboardStyle.Key.width + KeyboardStyle.Key.margin), KeyboardStyle.WhiteKey.height + 1);

  ScalePaper = Raphael('scales', (ScaleStyle.cell.width + ScaleStyle.cell.padding) * ScaleStyle.cols, Math.ceil(_.keys(Scales).length / ScaleStyle.cols) * (ScaleStyle.cell.height + ScaleStyle.cell.padding));

  pitch_at = function(string_number, fret_number) {
    return (string_number * 7 + fret_number) % 12;
  };

  pitch_name = function(pitch, options) {
    var flatName, name, sharpName;
    if (options == null) {
      options = {};
    }
    flatName = FlatNoteNames[pitch];
    sharpName = SharpNoteNames[pitch];
    name = options.sharp ? sharpName : flatName;
    if (options.flat && options.sharp && flatName !== sharpName) {
      name = "" + flatName + "/\n" + sharpName;
    }
    return name.replace(/b/, '\u266D').replace(/#/g, '\u266F');
  };

  create_keyboard = function() {
    var black_keys, next_x, paper;
    paper = KeyboardPaper;
    next_x = 1;
    black_keys = paper.set();
    [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11].forEach(function(pitch) {
      var height, hover, is_black_key, key, label, note_name, note_view, style, width, x;
      is_black_key = FlatNoteNames[pitch].length > 1;
      style = _.extend({}, KeyboardStyle.Key, (is_black_key ? KeyboardStyle.BlackKey : KeyboardStyle.WhiteKey));
      width = style.width, height = style.height;
      x = next_x;
      if (!is_black_key) {
        next_x += width + KeyboardStyle.Key.margin;
      }
      if (is_black_key) {
        x -= width / 2;
      }
      note_name = pitch_name(pitch, {
        flat: true
      });
      paper.setStart();
      key = paper.rect(x, 0, width, height, 2).attr(style.key);
      label = paper.text(x + width / 2, height - 10, note_name).attr(style.label);
      hover = paper.rect(x, 0, width, height).attr({
        fill: (is_black_key ? 'white' : 'black'),
        'fill-opacity': 0
      });
      note_view = paper.setFinish().attr({
        cursor: 'pointer'
      }).mouseover(function() {
        return hover.animate({
          'fill-opacity': 0.4
        }, 100);
      }).mouseout(function() {
        return hover.animate({
          'fill-opacity': 0
        }, 100);
      }).click(function() {
        CurrentScaleRoot = pitch;
        return set_scale_notes(fingerboard_notes, pitch);
      });
      if (is_black_key) {
        black_keys.push(note_view);
      }
      return KeyboardViews[pitch] = {
        key: key,
        style: style
      };
    });
    return black_keys.toFront();
  };

  update_keyboard = function(root_pitch) {
    var note_view, pitch, _i, _results;
    _results = [];
    for (pitch = _i = 0; _i < 12; pitch = ++_i) {
      note_view = KeyboardViews[pitch];
      _results.push(note_view.key.animate({
        fill: (pitch === root_pitch ? KeyboardStyle.root.fill : note_view.style.key.fill)
      }, 100));
    }
    return _results;
  };

  ScaleViews = {};

  create_scales = function() {
    var cols, paper, style;
    style = ScaleStyle;
    paper = ScalePaper;
    cols = style.cols;
    return ScaleNames.forEach(function(name, i) {
      var a, bg, cell_height, cell_width, hover, note_circle, nx, ny, pitch, pitches, r, x, y, _i;
      pitches = Scales[name];
      cell_width = style.cell.width;
      cell_height = style.cell.height;
      x = cell_width / 2 + (i % cols) * cell_width;
      y = 6 + Math.floor(i / cols) * cell_height;
      paper.setStart();
      bg = paper.rect(x - cell_width / 2, y - 5, cell_width - 5, cell_width, 2).attr({
        stroke: 'gray'
      });
      hover = paper.rect(x - cell_width / 2, y - 5, cell_width - 5, cell_width, 2).attr({
        fill: 'gray',
        'fill-opacity': 0
      });
      paper.text(x, y, name);
      y += 40;
      for (pitch = _i = 0; _i < 12; pitch = ++_i) {
        r = style.pitch_circle.radius;
        a = (pitch - 3) * 2 * Math.PI / 12;
        nx = x + Math.cos(a) * r;
        ny = y + Math.sin(a) * r;
        note_circle = paper.circle(nx, ny, style.pitch_circle.note.radius);
        if (__indexOf.call(pitches, pitch) >= 0) {
          paper.path(['M', x, ',', y, 'L', nx, ',', ny].join(''));
          note_circle.attr({
            fill: 'gray'
          });
          note_circle.toFront();
          if (pitch === 0) {
            note_circle.attr(style.pitch_circle.root);
          }
          if (pitch === 7) {
            note_circle.attr(style.pitch_circle.fifth);
          }
        }
      }
      bg.toBack();
      hover.toFront();
      paper.setFinish().attr({
        cursor: 'pointer'
      }).mouseover(function() {
        return hover.animate({
          'fill-opacity': 0.4
        });
      }).mouseout(function() {
        return hover.animate({
          'fill-opacity': 0
        });
      }).click(function() {
        CurrentScale = name;
        set_scale_notes(fingerboard_notes, CurrentScaleRoot);
        return update_scales();
      });
      return ScaleViews[name] = bg;
    });
  };

  update_scales = function() {
    return ScaleNames.forEach(function(name, i) {
      return ScaleViews[name].animate({
        fill: (name === CurrentScale ? 'lightBlue' : 'white')
      });
    });
  };

  draw_fingerboard = function() {
    var paper, path, string_number, x, _i;
    paper = FingerboardPaper;
    for (string_number = _i = 0; 0 <= StringCount ? _i < StringCount : _i > StringCount; string_number = 0 <= StringCount ? ++_i : --_i) {
      x = (string_number + 0.5) * FingerboardStyle.string_width;
      path = ['M', x, FingerboardStyle.fret_height * 0.5, 'L', x, (1 + FingerPositions) * FingerboardStyle.fret_height];
      paper.path(path.join());
    }
    return (function() {
      var y;
      y = FingerboardStyle.fret_height - 5;
      return paper.path(['M', 0, y, 'L', StringCount * FingerboardStyle.string_width, y].join()).attr({
        'stroke-width': 4,
        stroke: 'gray'
      });
    })();
  };

  create_fingerboard_notes = function() {
    var fret_number, notes, paper, pitch, string_number, x, y, _i, _j;
    paper = FingerboardPaper;
    notes = [];
    for (string_number = _i = 0; 0 <= StringCount ? _i < StringCount : _i > StringCount; string_number = 0 <= StringCount ? ++_i : --_i) {
      x = (string_number + 0.5) * FingerboardStyle.string_width;
      for (fret_number = _j = 0; 0 <= FingerPositions ? _j <= FingerPositions : _j >= FingerPositions; fret_number = 0 <= FingerPositions ? ++_j : --_j) {
        y = fret_number * FingerboardStyle.fret_height + FingerboardNoteStyle.all.radius + 1;
        pitch = pitch_at(string_number, fret_number);
        notes.push({
          string_number: string_number,
          fret_number: fret_number,
          pitch: pitch,
          circle: paper.circle(x, y, FingerboardNoteStyle.all.radius).attr(FingerboardNoteStyle.all),
          label: paper.text(x, y, pitch_name(pitch))
        });
      }
    }
    return notes;
  };

  KeyboardViews = {};

  set_scale_notes = function(notes, scale_root) {
    var attrs, circle, label, n, note_type, pitch, pitch_name_options, scale_pitches, scale_root_name, _i, _len, _ref, _results;
    if (scale_root == null) {
      scale_root = 0;
    }
    scale_root_name = scale_root;
    if (typeof scale_root === 'string') {
      scale_root = FlatNoteNames.indexOf(scale_root_name);
      if (!(scale_root >= 0)) {
        scale_root = SharpNoteNames.indexOf(scale_root_name);
      }
    }
    if (typeof scale_root_name !== 'string') {
      scale_root_name = FlatNoteNames[scale_root];
    }
    update_keyboard(scale_root);
    scale = Scales[CurrentScale];
    scale_pitches = (function() {
      var _i, _len, _results;
      _results = [];
      for (_i = 0, _len = scale.length; _i < _len; _i++) {
        n = scale[_i];
        _results.push((n + scale_root) % 12);
      }
      return _results;
    })();
    update_background_scale(scale_pitches);
    _results = [];
    for (_i = 0, _len = notes.length; _i < _len; _i++) {
      _ref = notes[_i], pitch = _ref.pitch, circle = _ref.circle, label = _ref.label;
      note_type = {
        0: 'root',
        '-1': 'chromatic'
      }[scale_pitches.indexOf(pitch)] || 'scale';
      if (__indexOf.call(scale_pitches, pitch) >= 0 && (pitch - scale_pitches[0] + 12) % 12 === 7) {
        note_type = 'fifth';
      }
      pitch_name_options = {
        sharp: true
      };
      if (scale_root_name.match(/b/)) {
        pitch_name_options = {
          flat: true
        };
      }
      if (note_type === 'chromatic') {
        pitch_name_options = {
          flat: true,
          sharp: true
        };
      }
      attrs = _.extend({}, FingerboardNoteStyle.all, FingerboardNoteStyle[note_type]);
      circle.animate(attrs, 400);
      label.attr({
        text: pitch_name(pitch, pitch_name_options)
      });
      _results.push(label.animate(_.extend({}, FingerboardNoteStyle.all.label, FingerboardNoteStyle[note_type].label), 400));
    }
    return _results;
  };

  BackgroundScaleViews = [];

  (function() {
    var circle, fret_count, fret_number, paper, pitch, pos, string_count, string_number, style, x, y, _i, _results;
    style = FingerboardStyle;
    string_count = 12 * 5;
    fret_count = 12;
    paper = Raphael('scale-notes', string_count * style.string_width, fret_count * style.fret_height);
    pos = $('#fingerboard').offset();
    pos.left += 5;
    pos.top += 4;
    $('#scale-notes').css({
      left: pos.left,
      top: pos.top
    });
    _results = [];
    for (string_number = _i = 0; 0 <= string_count ? _i < string_count : _i > string_count; string_number = 0 <= string_count ? ++_i : --_i) {
      _results.push((function() {
        var _j, _results1;
        _results1 = [];
        for (fret_number = _j = 0; 0 <= fret_count ? _j < fret_count : _j > fret_count; fret_number = 0 <= fret_count ? ++_j : --_j) {
          pitch = (string_number * 7 + fret_number) % 12;
          x = (string_number + 0.5) * style.string_width;
          y = fret_number * style.fret_height + FingerboardNoteStyle.all.radius + 1;
          circle = paper.circle(x, y, FingerboardNoteStyle.all.radius).attr({
            fill: 'red'
          });
          _results1.push(BackgroundScaleViews.push({
            pitch: pitch,
            circle: circle
          }));
        }
        return _results1;
      })());
    }
    return _results;
  })();

  update_background_scale = function(scale_pitches_0) {
    var circle, fill, pitch, pos, scale_pitches, style, _i, _len, _ref;
    scale_pitches = Scales[CurrentScale];
    for (_i = 0, _len = BackgroundScaleViews.length; _i < _len; _i++) {
      _ref = BackgroundScaleViews[_i], pitch = _ref.pitch, circle = _ref.circle;
      pitch = (pitch + 12 + Instruments[CurrentInstrument][0]) % 12;
      fill = 'white';
      if (__indexOf.call(scale_pitches, pitch) >= 0) {
        fill = 'green';
      }
      if (__indexOf.call(scale_pitches, pitch) >= 0 && pitch === 7) {
        fill = 'blue';
      }
      if (scale_pitches.indexOf(pitch) === 0) {
        fill = 'red';
      }
      circle.animate({
        fill: fill
      }, 100);
    }
    pos = $('#fingerboard').offset();
    pos.left += 5;
    pos.top += 4;
    style = FingerboardStyle;
    pos.left -= style.string_width * ((scale_pitches_0[0] * 5) % 12);
    $('#scale-notes').addClass('animate');
    return $('#scale-notes').css({
      left: pos.left,
      top: pos.top
    });
  };

  create_keyboard();

  create_scales();

  draw_fingerboard();

  fingerboard_notes = create_fingerboard_notes();

  set_scale_notes(fingerboard_notes, CurrentScaleRoot);

  update_scales();

  $('h2#instruments span').click(function() {
    var fret_number, note, string_number, string_pitches, _i, _len;
    CurrentInstrument = $(this).text();
    string_pitches = Instruments[CurrentInstrument];
    for (_i = 0, _len = fingerboard_notes.length; _i < _len; _i++) {
      note = fingerboard_notes[_i];
      string_number = note.string_number, fret_number = note.fret_number;
      note.pitch = (string_pitches[string_number] + fret_number) % 12;
    }
    set_scale_notes(fingerboard_notes, CurrentScaleRoot);
    $('h2#instruments span').removeClass('selected');
    $(this).addClass('selected');
    return set_scale_notes(fingerboard_notes, CurrentScaleRoot);
  });

}).call(this);
