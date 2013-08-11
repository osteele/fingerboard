(function() {
  var FingerPositions, FingerboardNoteStyle, FingerboardStyle, FingerboardView, FlatNoteNames, Instruments, KeyboardStyle, KeyboardView, NoteGridView, ScaleDegreeNames, ScaleNames, ScaleRootColor, ScaleSelectorView, ScaleStyle, Scales, SharpNoteNames, State, StringCount, fingerboardView, keyboardView, noteGridView, pitch_at, pitch_name, pitch_name_to_number, scale, scaleSelectorView,
    __indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

  SharpNoteNames = 'C C# D D# E F F# G G# A A# B'.split(/\s/);

  FlatNoteNames = 'C Db D Eb E F Gb G Ab A Bb B'.split(/\s/);

  ScaleDegreeNames = '1 2b 2 3b 3 4 5b 5 6b 6 7b 7'.replace(/(\d)/g, '$1\u0302').replace(/b/g, '\u266D').split(/\s/);

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

  pitch_name_to_number = function(pitch_name) {
    var pitch;
    pitch = FlatNoteNames.indexOf(pitch_name);
    if (!(pitch >= 0)) {
      pitch = SharpNoteNames.indexOf(pitch_name);
    }
    return pitch;
  };

  Instruments = {
    Violin: [7, 14, 21, 28],
    Viola: [0, 7, 14, 21],
    Cello: [0, 7, 14, 21]
  };

  State = {
    instrument_name: 'Violin',
    scale_root_name: 'C',
    scale_root_pitch: 0,
    scale_class_name: 'Diatonic Major'
  };

  StringCount = 4;

  FingerPositions = 7;

  FingerboardStyle = {
    string_width: 50,
    fret_height: 50
  };

  ScaleRootColor = 'rgb(255, 96, 96)';

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
    Key: {
      width: 25,
      margin: 3
    },
    WhiteKey: {
      height: 120
    },
    BlackKey: {
      height: 90
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
      var next_x, onclick, root, style;
      style = KeyboardStyle;
      root = d3.select('#keyboard').append('svg').attr('width', 7 * (style.Key.width + style.Key.margin)).attr('height', style.WhiteKey.height + 1);
      next_x = 1;
      this.keys = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11].map(function(pitch) {
        var height, is_black_key, key_style, note_name, width, x, _ref;
        note_name = pitch_name(pitch, {
          flat: true
        });
        is_black_key = FlatNoteNames[pitch].length > 1;
        _ref = key_style = _.extend({}, KeyboardStyle.Key, (is_black_key ? KeyboardStyle.BlackKey : KeyboardStyle.WhiteKey)), width = _ref.width, height = _ref.height;
        x = next_x;
        if (!is_black_key) {
          next_x += width + KeyboardStyle.Key.margin;
        }
        if (is_black_key) {
          x -= width / 2;
        }
        return {
          pitch: pitch,
          name: note_name,
          is_black_key: is_black_key,
          attrs: {
            width: width,
            height: height,
            x: x,
            y: 0
          }
        };
      });
      this.keys.sort(function(a, b) {
        return a.is_black_key - b.is_black_key;
      });
      onclick = function(_arg) {
        var name, pitch;
        pitch = _arg.pitch, name = _arg.name;
        State.scale_root_name = FlatNoteNames[pitch];
        State.scale_root_pitch = pitch;
        fingerboardView.update();
        return noteGridView.update();
      };
      this.d3_keys = root.selectAll('.piano-key').data(this.keys).enter().append('g').classed('piano-key', true).classed('black-key', function(_arg) {
        var is_black_key;
        is_black_key = _arg.is_black_key;
        return is_black_key;
      }).on('click', onclick);
      this.d3_keys.append('rect').attr({
        x: function(_arg) {
          var attrs;
          attrs = _arg.attrs;
          return attrs.x;
        },
        y: function(_arg) {
          var attrs;
          attrs = _arg.attrs;
          return attrs.y;
        },
        width: function(_arg) {
          var attrs;
          attrs = _arg.attrs;
          return attrs.width;
        },
        height: function(_arg) {
          var attrs;
          attrs = _arg.attrs;
          return attrs.height;
        }
      });
      this.d3_keys.append('text').attr({
        x: function(_arg) {
          var attrs;
          attrs = _arg.attrs;
          return attrs.x + attrs.width / 2;
        },
        y: function(_arg) {
          var attrs;
          attrs = _arg.attrs;
          return attrs.y + attrs.height - 6;
        }
      }).text(function(_arg) {
        var name;
        name = _arg.name;
        return name;
      });
    }

    KeyboardView.prototype.update = function() {
      return this.d3_keys.each(function(_arg) {
        var pitch;
        pitch = _arg.pitch;
        return d3.select(this).classed('root', pitch === State.scale_root_pitch);
      });
    };

    return KeyboardView;

  })();

  ScaleSelectorView = (function() {
    function ScaleSelectorView() {
      var onclick, pc_width, scales, style,
        _this = this;
      style = ScaleStyle;
      onclick = function(scale_name) {
        State.scale_class_name = scale_name;
        fingerboardView.update();
        noteGridView.update();
        return _this.update();
      };
      scales = d3.select('#scales').selectAll('.scale').data(ScaleNames).enter().append('div').classed('scale', true).on('click', onclick);
      scales.append('h2').text(function(scale_name) {
        return scale_name;
      });
      pc_width = 2 * (style.pitch_circle.radius + style.pitch_circle.note.radius + 1);
      scales.append('svg').attr({
        width: pc_width,
        height: pc_width
      }).append('g').attr({
        transform: "translate(" + (pc_width / 2) + ", " + (pc_width / 2) + ")"
      });
      scales.selectAll('svg g').each(function(scale_name) {
        var endpoints, pitches, r;
        pitches = Scales[scale_name];
        r = style.pitch_circle.radius;
        endpoints = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11].map(function(pitch) {
          var a, chromatic, x, y;
          a = (pitch - 3) * 2 * Math.PI / 12;
          x = Math.cos(a) * r;
          y = Math.sin(a) * r;
          chromatic = __indexOf.call(pitches, pitch) < 0;
          return {
            x: x,
            y: y,
            chromatic: chromatic,
            pitch: pitch
          };
        });
        d3.select(this).selectAll('line').data(endpoints).enter().append('line').attr({
          x2: function(d) {
            return d.x;
          },
          y2: function(d) {
            return d.y;
          }
        }).classed('chromatic', function(d) {
          return d.chromatic;
        });
        return d3.select(this).selectAll('circle').data(endpoints).enter().append('circle').attr({
          cx: function(d) {
            return d.x;
          },
          cy: function(d) {
            return d.y;
          },
          r: style.pitch_circle.note.radius
        }).classed('chromatic', function(d) {
          return d.chromatic;
        }).classed('root', function(d) {
          return d.pitch === 0;
        }).classed('fifth', function(d) {
          return d.pitch === 7;
        });
      });
    }

    ScaleSelectorView.prototype.update = function() {
      var scales;
      return scales = d3.select('#scales').selectAll('.scale').classed('selected', function(d) {
        return d === State.scale_class_name;
      });
    };

    return ScaleSelectorView;

  })();

  FingerboardView = (function() {
    function FingerboardView() {
      var finger_positions, fingering_name, fret_number, note_labels, note_name, note_style, pitch, root, scale_degree_name, string_number, style, _i, _j, _k, _results;
      this.label_sets = ['notes', 'fingerings', 'scale-degrees'];
      this.note_display = 'notes';
      finger_positions = [];
      for (string_number = _i = 0; 0 <= StringCount ? _i < StringCount : _i > StringCount; string_number = 0 <= StringCount ? ++_i : --_i) {
        for (fret_number = _j = 0; 0 <= FingerPositions ? _j <= FingerPositions : _j >= FingerPositions; fret_number = 0 <= FingerPositions ? ++_j : --_j) {
          pitch = pitch_at(string_number, fret_number);
          note_name = pitch_name(pitch).replace(/(.)(.)/, '$1-$2');
          fingering_name = String(Math.ceil(fret_number / 2));
          scale_degree_name = ScaleDegreeNames[pitch];
          finger_positions.push({
            string_number: string_number,
            fret_number: fret_number,
            pitch: pitch,
            note_name: note_name,
            fingering_name: fingering_name,
            scale_degree_name: scale_degree_name
          });
        }
      }
      style = FingerboardStyle;
      note_style = FingerboardNoteStyle;
      root = d3.select('#fingerboard').append('svg').attr('width', StringCount * style.string_width).attr('height', FingerPositions * style.fret_height);
      root.append('line').classed('nut', true).attr({
        x2: StringCount * style.string_width,
        transform: "translate(0, " + (style.fret_height - 5) + ")"
      });
      root.selectAll('.string').data((function() {
        _results = [];
        for (var _k = 0; 0 <= StringCount ? _k < StringCount : _k > StringCount; 0 <= StringCount ? _k++ : _k--){ _results.push(_k); }
        return _results;
      }).apply(this)).enter().append('line').classed('string', true).attr({
        y1: style.fret_height * 0.5,
        y2: (1 + FingerPositions) * style.fret_height,
        transform: function(d) {
          return "translate(" + ((d + 0.5) * style.string_width) + ", 0)";
        }
      });
      this.d3_notes = root.selectAll('.finger-position').data(finger_positions).enter().append('g').classed('finger-position', true).attr('transform', function(_arg) {
        var dx, dy, fret_number, string_number;
        string_number = _arg.string_number, fret_number = _arg.fret_number;
        dx = (string_number + 0.5) * style.string_width;
        dy = fret_number * style.fret_height + note_style.all.radius + 1;
        return "translate(" + dx + ", " + dy + ")";
      });
      this.d3_notes.append('circle').attr({
        r: note_style.all.radius
      });
      note_labels = this.d3_notes.append('text').classed('note', true).attr({
        y: 7
      });
      note_labels.append('tspan').classed('base', true);
      note_labels.append('tspan').classed('accidental', true);
      this.d3_notes.append('text').classed('fingering', true).attr({
        y: 7
      }).text(function(d) {
        return d.fingering_name;
      });
      this.d3_notes.append('text').classed('scale-degree', true).attr({
        y: 7
      }).text(function(d) {
        return d.scale_degree_name;
      });
    }

    FingerboardView.prototype.update = function() {
      var k, labels, n, pitch_name_options, scale_pitches, scale_root, scale_root_name, visible, _i, _len, _ref;
      keyboardView.update();
      scale_root_name = State.scale_root_name;
      scale_root = State.scale_root_pitch;
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
      _ref = this.label_sets;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        k = _ref[_i];
        visible = k === this.note_display.replace(/_/g, '-');
        labels = d3.select('#fingerboard').selectAll('.' + k.replace(/s$/, ''));
        labels.attr('visibility', visible ? 'inherit' : 'hidden');
      }
      pitch_name_options = {
        sharp: true
      };
      if (scale_root_name.match(/b/)) {
        pitch_name_options = {
          flat: true
        };
      }
      return this.d3_notes.each(function(_arg) {
        var circle, note_label, pitch, scale_degree;
        pitch = _arg.pitch, circle = _arg.circle;
        scale_degree = (pitch - scale_pitches[0] + 12) % 12;
        note_label = d3.select(this).classed('scale', __indexOf.call(scale_pitches, pitch) >= 0).classed('chromatic', __indexOf.call(scale_pitches, pitch) < 0).classed('root', scale_degree === 0).classed('fifth', scale_degree === 7).select('.note');
        note_label.select('.base').text(function(_arg1) {
          var pitch;
          pitch = _arg1.pitch;
          return pitch_name(pitch, pitch_name_options).replace(/(.).*/, '$1');
        });
        return note_label.select('.accidental').text(function(_arg1) {
          var pitch;
          pitch = _arg1.pitch;
          return pitch_name(pitch, pitch_name_options).replace(/^./, '');
        });
      });
    };

    FingerboardView.prototype.update_instrument = function() {
      var string_pitches;
      string_pitches = Instruments[State.instrument_name];
      this.d3_notes.each(function(note) {
        var fret_number, string_number;
        string_number = note.string_number, fret_number = note.fret_number;
        return note.pitch = (string_pitches[string_number] + fret_number) % 12;
      });
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

    NoteGridView.prototype.update_note_colors = function() {
      var circle, fill, label, pitch, scale_class_name, scale_pitches, _i, _len, _ref, _ref1, _results;
      scale_class_name = State.scale_class_name;
      if (this.scale_class_name === scale_class_name) {
        return;
      }
      this.scale_class_name = scale_class_name;
      scale_pitches = Scales[State.scale_class_name];
      _ref = this.views;
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        _ref1 = _ref[_i], pitch = _ref1.pitch, circle = _ref1.circle, label = _ref1.label;
        fill = (function() {
          switch (false) {
            case scale_pitches.indexOf(pitch) !== 0:
              return 'red';
            case !(__indexOf.call(scale_pitches, pitch) >= 0 && pitch === 7):
              return 'blue';
            case __indexOf.call(scale_pitches, pitch) < 0:
              return 'green';
            default:
              return null;
          }
        })();
        _results.push(circle.attr({
          fill: fill
        }));
      }
      return _results;
    };

    NoteGridView.prototype.update = function() {
      var bass_pitch, n, pos, scale_pitches, scale_root, style;
      this.update_note_colors();
      scale_pitches = Scales[State.scale_class_name];
      scale_root = State.scale_root_pitch;
      bass_pitch = Instruments[State.instrument_name][0];
      scale_pitches = (function() {
        var _i, _len, _results;
        _results = [];
        for (_i = 0, _len = scale_pitches.length; _i < _len; _i++) {
          n = scale_pitches[_i];
          _results.push((n + scale_root - bass_pitch + 12) % 12);
        }
        return _results;
      })();
      pos = $('#fingerboard').offset();
      pos.left += 1;
      pos.top += 2;
      style = FingerboardStyle;
      pos.left -= style.string_width * ((scale_pitches[0] * 5) % 12);
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

  fingerboardView.update_instrument();

  fingerboardView.update();

  scaleSelectorView.update();

  noteGridView.update();

  $('#instruments .btn').click(function() {
    $('#instruments .btn').removeClass('btn-default');
    $(this).addClass('btn-default');
    State.instrument_name = $(this).text();
    fingerboardView.update_instrument();
    return noteGridView.update();
  });

  $('#fingerings .btn').click(function() {
    $('#fingerings .btn').removeClass('btn-default');
    $(this).addClass('btn-default');
    fingerboardView.note_display = $(this).text().replace(' ', '_').toLowerCase();
    return fingerboardView.update();
  });

  $('#about-text a').attr('target', '_blank');

  $("#about").popover({
    content: $('#about-text').html(),
    html: true,
    placement: 'bottom'
  });

}).call(this);
