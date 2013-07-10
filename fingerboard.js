(function() {
  var FingerPositions, FingerboardNoteStyle, FingerboardStyle, FingerboardView, FlatNoteNames, Instruments, KeyboardStyle, KeyboardView, NoteGridView, ScaleDegreeNames, ScaleNames, ScaleRootColor, ScaleSelectorView, ScaleStyle, Scales, SharpNoteNames, State, StringCount, fingerboardView, keyboardView, noteGridView, pitch_at, pitch_name, scale, scaleSelectorView,
    __indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

  SharpNoteNames = 'C C# D D# E F F# G G# A A# B'.split(/\s/);

  FlatNoteNames = 'C Db D Eb E F Gb G Ab A Bb B'.split(/\s/);

  ScaleDegreeNames = '1 2b 2 3b 3 4 5b 5 6b 6 7b 7'.replace(/b/g, '\u266D').split(/\s/);

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

  State = {
    instrument_name: 'Cello',
    scale_root: 'C',
    scale_class_name: 'Diatonic Major'
  };

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

  KeyboardView = (function() {
    function KeyboardView() {
      var black_keys, next_x, paper,
        _this = this;
      paper = this.get_paper();
      next_x = 1;
      black_keys = paper.set();
      this.key_views = {};
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
          State.scale_root = pitch;
          return fingerboardView.update();
        });
        if (is_black_key) {
          black_keys.push(note_view);
        }
        return _this.key_views[pitch] = {
          key: key,
          style: style
        };
      });
      black_keys.toFront();
    }

    KeyboardView.prototype.get_paper = function() {
      var style;
      style = KeyboardStyle;
      return this.paper || (this.paper = Raphael('keyboard', 7 * (style.Key.width + style.Key.margin), style.WhiteKey.height + 1));
    };

    KeyboardView.prototype.update_keyboard = function(root_pitch) {
      var fill_color, note_view, pitch, _i, _results;
      _results = [];
      for (pitch = _i = 0; _i < 12; pitch = ++_i) {
        note_view = this.key_views[pitch];
        fill_color = (pitch === root_pitch ? KeyboardStyle.root.fill : note_view.style.key.fill);
        _results.push(note_view.key.animate({
          fill: fill_color
        }, 100));
      }
      return _results;
    };

    return KeyboardView;

  })();

  ScaleSelectorView = (function() {
    function ScaleSelectorView() {
      var cols, paper, style,
        _this = this;
      style = ScaleStyle;
      paper = this.get_paper();
      cols = style.cols;
      this.views = {};
      ScaleNames.forEach(function(name, i) {
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
          State.scale_class_name = name;
          fingerboardView.update();
          return _this.update();
        });
        return _this.views[name] = bg;
      });
    }

    ScaleSelectorView.prototype.get_paper = function() {
      var style;
      style = ScaleStyle;
      return this.paper || (this.paper = Raphael('scales', (style.cell.width + style.cell.padding) * style.cols, Math.ceil(_.keys(Scales).length / style.cols) * (style.cell.height + style.cell.padding)));
    };

    ScaleSelectorView.prototype.update = function() {
      var _this = this;
      return ScaleNames.forEach(function(name, i) {
        return _this.views[name].animate({
          fill: (name === State.scale_class_name ? 'lightBlue' : 'white')
        });
      });
    };

    return ScaleSelectorView;

  })();

  FingerboardView = (function() {
    function FingerboardView() {
      this.note_display = 'notes';
      this.draw_fingerboard();
      this.create_fingerboard_notes();
    }

    FingerboardView.prototype.draw_fingerboard = function() {
      var paper, path, string_number, x, _i;
      paper = this.get_paper();
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

    FingerboardView.prototype.create_fingerboard_notes = function() {
      var circle, fingering_label, fret_number, note_label, notes, paper, pitch, scale_degree_label, string_number, x, y, _i, _results;
      paper = this.get_paper();
      this.note_views = notes = [];
      this.note_sets = {
        notes: paper.set(),
        fingerings: paper.set(),
        scale_degrees: paper.set()
      };
      _results = [];
      for (string_number = _i = 0; 0 <= StringCount ? _i < StringCount : _i > StringCount; string_number = 0 <= StringCount ? ++_i : --_i) {
        x = (string_number + 0.5) * FingerboardStyle.string_width;
        _results.push((function() {
          var _j, _results1;
          _results1 = [];
          for (fret_number = _j = 0; 0 <= FingerPositions ? _j <= FingerPositions : _j >= FingerPositions; fret_number = 0 <= FingerPositions ? ++_j : --_j) {
            y = fret_number * FingerboardStyle.fret_height + FingerboardNoteStyle.all.radius + 1;
            pitch = pitch_at(string_number, fret_number);
            circle = paper.circle(x, y, FingerboardNoteStyle.all.radius).attr(FingerboardNoteStyle.all);
            note_label = paper.text(x, y, pitch_name(pitch));
            fingering_label = paper.text(x, y, String(Math.ceil(fret_number / 2)));
            scale_degree_label = paper.text(x, y, ScaleDegreeNames[pitch]);
            this.note_sets.notes.push(note_label);
            this.note_sets.fingerings.push(fingering_label);
            this.note_sets.scale_degrees.push(scale_degree_label);
            _results1.push(notes.push({
              string_number: string_number,
              fret_number: fret_number,
              pitch: pitch,
              circle: circle,
              note_label: note_label,
              fingering_label: fingering_label,
              scale_degree_label: scale_degree_label
            }));
          }
          return _results1;
        }).call(this));
      }
      return _results;
    };

    FingerboardView.prototype.get_paper = function() {
      var style;
      style = FingerboardStyle;
      return this.paper || (this.paper = Raphael('fingerboard', StringCount * style.string_width, FingerPositions * style.fret_height));
    };

    FingerboardView.prototype.update = function() {
      var attrs, circle, k, label, n, note_type, pitch, pitch_name_options, scale_degree, scale_pitches, scale_root, scale_root_name, v, view, _i, _len, _ref, _ref1, _results;
      _ref = this.note_sets;
      for (k in _ref) {
        v = _ref[k];
        if (k === this.note_display) {
          v.show();
        } else {
          v.hide();
        }
      }
      scale_root = State.scale_root;
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
      keyboardView.update_keyboard(scale_root);
      scale = Scales[State.scale_class_name];
      scale_pitches = (function() {
        var _i, _len, _results;
        _results = [];
        for (_i = 0, _len = scale.length; _i < _len; _i++) {
          n = scale[_i];
          _results.push((n + scale_root) % 12);
        }
        return _results;
      })();
      noteGridView.update_background_scale(scale_pitches);
      _ref1 = this.note_views;
      _results = [];
      for (_i = 0, _len = _ref1.length; _i < _len; _i++) {
        view = _ref1[_i];
        pitch = view.pitch, circle = view.circle;
        note_type = {
          0: 'root',
          '-1': 'chromatic'
        }[scale_pitches.indexOf(pitch)] || 'scale';
        scale_degree = (pitch - scale_pitches[0] + 12) % 12;
        if (__indexOf.call(scale_pitches, pitch) >= 0 && scale_degree === 7) {
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
        view.note_label.attr({
          text: pitch_name(pitch, pitch_name_options)
        });
        view.scale_degree_label.attr({
          text: ScaleDegreeNames[scale_degree]
        });
        label = view[this.note_display.replace(/s$/, '_label')];
        _results.push(label.animate(_.extend({}, FingerboardNoteStyle.all.label, FingerboardNoteStyle[note_type].label), 400));
      }
      return _results;
    };

    FingerboardView.prototype.update_instrument = function() {
      var fret_number, note, string_number, string_pitches, _i, _len, _ref;
      string_pitches = Instruments[State.instrument_name];
      _ref = this.note_views;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        note = _ref[_i];
        string_number = note.string_number, fret_number = note.fret_number;
        note.pitch = (string_pitches[string_number] + fret_number) % 12;
      }
      return this.update();
    };

    return FingerboardView;

  })();

  NoteGridView = (function() {
    function NoteGridView() {
      var circle, fret_count, fret_number, label, paper, pitch, pos, string_count, string_number, style, x, y, _i, _j;
      this.views = [];
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
      for (string_number = _i = 0; 0 <= string_count ? _i < string_count : _i > string_count; string_number = 0 <= string_count ? ++_i : --_i) {
        for (fret_number = _j = 0; 0 <= fret_count ? _j < fret_count : _j > fret_count; fret_number = 0 <= fret_count ? ++_j : --_j) {
          pitch = (string_number * 7 + fret_number) % 12;
          x = (string_number + 0.5) * style.string_width;
          y = fret_number * style.fret_height + FingerboardNoteStyle.all.radius + 1;
          circle = paper.circle(x, y, FingerboardNoteStyle.all.radius).attr({
            fill: 'red'
          });
          label = paper.text(x, y, ScaleDegreeNames[pitch]).attr({
            fill: 'white',
            'font-size': 16
          });
          this.views.push({
            pitch: pitch,
            circle: circle,
            label: label
          });
        }
      }
    }

    NoteGridView.prototype.update_background_scale = function(scale_pitches_0) {
      var circle, fill, label, pitch, pos, scale_pitches, style, _i, _len, _ref, _ref1;
      scale_pitches = Scales[State.scale_class_name];
      _ref = this.views;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        _ref1 = _ref[_i], pitch = _ref1.pitch, circle = _ref1.circle, label = _ref1.label;
        pitch = (pitch + Instruments[State.instrument_name][0] + 12) % 12;
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
        circle.attr({
          fill: fill
        });
        label.attr({
          text: ScaleDegreeNames[pitch]
        });
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

    return NoteGridView;

  })();

  scaleSelectorView = new ScaleSelectorView;

  fingerboardView = new FingerboardView;

  noteGridView = new NoteGridView;

  keyboardView = new KeyboardView;

  fingerboardView.update();

  scaleSelectorView.update();

  $('#instruments li').click(function() {
    $('#instruments li').removeClass('active');
    $(this).addClass('active');
    State.instrument_name = $(this).text();
    return fingerboardView.update_instrument();
  });

  $('#fingerings li').click(function() {
    $('#fingerings li').removeClass('active');
    $(this).addClass('active');
    fingerboardView.note_display = $(this).text().replace(' ', '_').toLowerCase();
    return fingerboardView.update();
  });

}).call(this);
