(function(){
  var SharpNoteNames, FlatNoteNames, ScaleDegreeNames, Scales, pitch_name_to_number, Instruments, State, D3State, StringCount, FingerPositions, FingerboardStyle, KeyboardStyle, ScaleStyle, Pitches, pitch_at, pitch_class, pitch_name, KeyboardView, ScaleSelectorView, FingerboardView, NoteGridView;
  SharpNoteNames = ['C', 'C#', 'D', 'D#', 'E', 'F', 'F#', 'G', 'G#', 'A', 'A#', 'B'];
  FlatNoteNames = ['C', 'Db', 'D', 'Eb', 'E', 'F', 'Gb', 'G', 'Ab', 'A', 'Bb', 'B'];
  ScaleDegreeNames = ['1', 'b2', '2', 'b3', '3', '4', 'b5', '5', 'b6', '6', 'b7', '7'].map(function(it){
    return it.replace(/(\d)/, '$1\u0302').replace(/b/g, '\u266D');
  });
  Scales = [
    {
      name: 'Diatonic Major',
      pitches: [0, 2, 4, 5, 7, 9, 11]
    }, {
      name: 'Natural Minor',
      pitches: [0, 2, 3, 5, 7, 8, 10]
    }, {
      name: 'Major Pentatonic',
      pitches: [0, 2, 4, 7, 9]
    }, {
      name: 'Minor Pentatonic',
      pitches: [0, 3, 5, 7, 10]
    }, {
      name: 'Melodic Minor',
      pitches: [0, 2, 3, 5, 7, 9, 11]
    }, {
      name: 'Harmonic Minor',
      pitches: [0, 2, 3, 5, 7, 8, 11]
    }, {
      name: 'Blues',
      pitches: [0, 3, 5, 6, 7, 10]
    }, {
      name: 'Freygish',
      pitches: [0, 1, 4, 5, 7, 8, 10]
    }, {
      name: 'Whole Tone',
      pitches: [0, 2, 4, 6, 8, 10]
    }, {
      name: 'Octatonic',
      pitches: [0, 2, 3, 5, 6, 8, 9, 11]
    }
  ];
  (function(){
    var i$, ref$, len$, scale, results$ = [];
    for (i$ = 0, len$ = (ref$ = Scales).length; i$ < len$; ++i$) {
      scale = ref$[i$];
      results$.push(Scales[scale.name] = scale);
    }
    return results$;
  })();
  pitch_name_to_number = function(pitch_name){
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
    scale: Scales[0],
    scale_tonic_name: 'C',
    scale_tonic_pitch: 0,
    scale_class_name: 'Diatonic Major'
  };
  D3State = d3.dispatch('instrument', 'note_label', 'scale', 'scale_tonic');
  StringCount = 4;
  FingerPositions = 7;
  FingerboardStyle = {
    string_width: 50,
    fret_height: 50,
    note_radius: 20
  };
  KeyboardStyle = {
    key: {
      width: 25,
      h_margin: 3
    },
    white_key: {
      height: 120
    },
    black_key: {
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
      }
    }
  };
  Pitches = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11];
  pitch_at = function(string_number, fret_number){
    return pitch_class(string_number * 7 + fret_number);
  };
  pitch_class = function(pitch){
    var ref$;
    return ((pitch) % (ref$ = 12) + ref$) % ref$;
  };
  pitch_name = function(pitch, options){
    var flatName, sharpName, name;
    options == null && (options = {});
    flatName = FlatNoteNames[pitch];
    sharpName = SharpNoteNames[pitch];
    name = options.sharp ? sharpName : flatName;
    if (options.flat && options.sharp && flatName !== sharpName) {
      name = flatName + "/\n" + sharpName;
    }
    return name.replace(/b/, '\u266D').replace(/#/g, '\u266F');
  };
  KeyboardView = (function(){
    KeyboardView.displayName = 'KeyboardView';
    var prototype = KeyboardView.prototype, constructor = KeyboardView;
    function KeyboardView(selection, style){
      var root, next_x, keys, onclick, key_views, update, this$ = this instanceof ctor$ ? this : new ctor$;
      root = selection.append('svg').attr({
        width: 7 * (style.key.width + style.key.h_margin),
        height: style.white_key.height + 1
      });
      next_x = 1;
      keys = Pitches.map(function(pitch){
        var note_name, is_black_key, key_style, ref$, width, height, x;
        note_name = pitch_name(pitch, {
          flat: true
        });
        is_black_key = FlatNoteNames[pitch].length > 1;
        ref$ = key_style = _.extend({}, style.key, is_black_key
          ? style.black_key
          : style.white_key), width = ref$.width, height = ref$.height;
        x = next_x;
        if (!is_black_key) {
          next_x += width + style.key.h_margin;
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
      keys.sort(function(a, b){
        return a.is_black_key - b.is_black_key;
      });
      onclick = function(arg$){
        var pitch, name;
        pitch = arg$.pitch, name = arg$.name;
        State.scale_tonic_name = FlatNoteNames[pitch];
        State.scale_tonic_pitch = pitch;
        return D3State.scale_tonic();
      };
      key_views = root.selectAll('.piano-key').data(keys).enter().append('g').classed('piano-key', true).classed('black-key', function(it){
        return it.is_black_key;
      }).classed('white-key', function(it){
        return !it.is_black_key;
      }).on('click', onclick);
      key_views.append('rect').attr({
        x: function(arg$){
          var attrs;
          attrs = arg$.attrs;
          return attrs.x;
        },
        y: function(arg$){
          var attrs;
          attrs = arg$.attrs;
          return attrs.y;
        },
        width: function(arg$){
          var attrs;
          attrs = arg$.attrs;
          return attrs.width;
        },
        height: function(arg$){
          var attrs;
          attrs = arg$.attrs;
          return attrs.height;
        }
      });
      key_views.append('text').attr({
        x: function(arg$){
          var attrs;
          attrs = arg$.attrs;
          return attrs.x + attrs.width / 2;
        },
        y: function(arg$){
          var attrs;
          attrs = arg$.attrs;
          return attrs.y + attrs.height - 6;
        }
      }).text(function(arg$){
        var name;
        name = arg$.name;
        return name;
      });
      update = function(){
        return key_views.classed('root', function(arg$){
          var pitch;
          pitch = arg$.pitch;
          return pitch === State.scale_tonic_pitch;
        });
      };
      D3State.on('scale_tonic.keyboard', function(){
        return update();
      });
      update();
      return this$;
    } function ctor$(){} ctor$.prototype = prototype;
    return KeyboardView;
  }());
  ScaleSelectorView = (function(){
    ScaleSelectorView.displayName = 'ScaleSelectorView';
    var prototype = ScaleSelectorView.prototype, constructor = ScaleSelectorView;
    function ScaleSelectorView(selection, style){
      var onclick, scales, pc_width, update, this$ = this instanceof ctor$ ? this : new ctor$;
      onclick = function(scale_name){
        State.scale = Scales[scale_name];
        State.scale_class_name = scale_name;
        return D3State.scale();
      };
      this$.scales = scales = selection.selectAll('.scale').data(Scales.map(function(it){
        return it.name;
      })).enter().append('div').classed('scale', true).on('click', onclick);
      scales.append('h2').text(function(scale_name){
        return scale_name;
      });
      pc_width = 2 * (style.pitch_circle.radius + style.pitch_circle.note.radius + 1);
      scales.append('svg').attr({
        width: pc_width,
        height: pc_width
      }).append('g').attr({
        transform: "translate(" + pc_width / 2 + ", " + pc_width / 2 + ")"
      });
      scales.selectAll('svg g').each(function(scale_name){
        var pitches, r, endpoints;
        pitches = Scales[scale_name].pitches;
        r = style.pitch_circle.radius;
        endpoints = Pitches.map(function(pitch){
          var a, x, y, chromatic;
          a = (pitch - 3) * 2 * Math.PI / 12;
          x = Math.cos(a) * r;
          y = Math.sin(a) * r;
          chromatic = !in$(pitch, pitches);
          return {
            x: x,
            y: y,
            chromatic: chromatic,
            pitch: pitch
          };
        });
        d3.select(this).selectAll('line').data(endpoints).enter().append('line').classed('chromatic', function(it){
          return it.chromatic;
        }).attr('x2', function(it){
          return it.x;
        }).attr('y2', function(it){
          return it.y;
        });
        return d3.select(this).selectAll('circle').data(endpoints).enter().append('circle').classed('chromatic', function(it){
          return it.chromatic;
        }).classed('root', function(it){
          return it.pitch === 0;
        }).classed('fifth', function(it){
          return it.pitch === 7;
        }).attr('cx', function(it){
          return it.x;
        }).attr('cy', function(it){
          return it.y;
        }).attr('r', style.pitch_circle.note.radius);
      });
      update = function(){
        return scales.classed('selected', function(it){
          return it === State.scale_class_name;
        });
      };
      D3State.on('scale.scale', function(){
        return update();
      });
      update();
      return this$;
    } function ctor$(){} ctor$.prototype = prototype;
    return ScaleSelectorView;
  }());
  FingerboardView = (function(){
    FingerboardView.displayName = 'FingerboardView';
    var prototype = FingerboardView.prototype, constructor = FingerboardView;
    function FingerboardView(selection, style){
      var finger_positions, i$, to$, string_number, j$, to1$, fret_number, pitch, fingering_name, root, note_labels, this$ = this instanceof ctor$ ? this : new ctor$;
      this$.label_sets = ['notes', 'fingerings', 'scale-degrees'];
      finger_positions = [];
      for (i$ = 0, to$ = StringCount; i$ < to$; ++i$) {
        string_number = i$;
        for (j$ = 0, to1$ = FingerPositions; j$ <= to1$; ++j$) {
          fret_number = j$;
          pitch = pitch_at(string_number, fret_number);
          fingering_name = String(Math.ceil(fret_number / 2));
          finger_positions.push({
            string_number: string_number,
            fret_number: fret_number,
            pitch: pitch,
            fingering_name: fingering_name
          });
        }
      }
      root = selection.append('svg').attr({
        width: StringCount * style.string_width
      }).attr({
        height: FingerPositions * style.fret_height
      });
      root.append('line').classed('nut', true).attr({
        x2: StringCount * style.string_width,
        transform: "translate(0, " + (style.fret_height - 5) + ")"
      });
      root.selectAll('.string').data((function(){
        var i$, to$, results$ = [];
        for (i$ = 0, to$ = StringCount; i$ < to$; ++i$) {
          results$.push(i$);
        }
        return results$;
      }())).enter().append('line').classed('string', true).attr({
        y1: style.fret_height * 0.5,
        y2: (1 + FingerPositions) * style.fret_height,
        transform: function(it){
          return "translate(" + (it + 0.5) * style.string_width + ", 0)";
        }
      });
      this$.d3_notes = root.selectAll('.finger-position').data(finger_positions).enter().append('g').classed('finger-position', true).attr({
        transform: function(arg$){
          var string_number, fret_number, dx, dy;
          string_number = arg$.string_number, fret_number = arg$.fret_number;
          dx = (string_number + 0.5) * style.string_width;
          dy = fret_number * style.fret_height + style.note_radius + 1;
          return "translate(" + dx + ", " + dy + ")";
        }
      });
      this$.d3_notes.append('circle').attr({
        r: style.note_radius
      });
      note_labels = this$.d3_notes.append('text').classed('note', true).attr({
        y: 7
      });
      note_labels.append('tspan').classed('base', true);
      note_labels.append('tspan').classed('accidental', true);
      this$.d3_notes.append('text').classed('fingering', true).attr({
        y: 7
      }).text(function(it){
        return it.fingering_name;
      });
      this$.d3_notes.append('text').classed('scale-degree', true).attr({
        y: 7
      });
      D3State.on('instrument.fingerboard', function(){
        return this$.update_instrument();
      });
      D3State.on('note_label', function(){
        return this$.update();
      });
      D3State.on('scale.fingerboard', function(){
        return this$.update();
      });
      D3State.on('scale_tonic.fingerboard', function(){
        return this$.update();
      });
      this$.update_instrument();
      return this$;
    } function ctor$(){} ctor$.prototype = prototype;
    prototype.update = function(){
      var scale_tonic, scale, scale_pitches, res$, i$, ref$, len$, pitch, tonic, k, visible, labels;
      scale_tonic = State.scale_tonic_pitch;
      scale = State.scale;
      res$ = [];
      for (i$ = 0, len$ = (ref$ = scale.pitches).length; i$ < len$; ++i$) {
        pitch = ref$[i$];
        res$.push(pitch_class(pitch + scale_tonic));
      }
      scale_pitches = res$;
      tonic = scale_pitches[0];
      State.note_label || (State.note_label = 'notes');
      for (i$ = 0, len$ = (ref$ = this.label_sets).length; i$ < len$; ++i$) {
        k = ref$[i$];
        visible = k === State.note_label.replace(/_/g, '-');
        labels = d3.select('#fingerboard').selectAll('.' + k.replace(/s$/, ''));
        labels.attr('visibility', visible ? 'inherit' : 'hidden');
      }
      return this.d3_notes.each(function(arg$){
        var pitch, scale_degree, note_label;
        pitch = arg$.pitch;
        scale_degree = pitch_class(pitch - tonic);
        return note_label = d3.select(this).classed('scale', in$(pitch, scale_pitches)).classed('chromatic', !in$(pitch, scale_pitches)).classed('root', scale_degree === 0).classed('fifth', scale_degree === 7).select('.scale-degree').text(function(arg$){
          var pitch;
          pitch = arg$.pitch;
          return ScaleDegreeNames[pitch_class(pitch - tonic)];
        });
      });
    };
    prototype.update_instrument = function(){
      var string_pitches, scale_tonic_name, pitch_name_options, select_pitch_name_component;
      string_pitches = Instruments[State.instrument_name];
      scale_tonic_name = State.scale_tonic_name;
      pitch_name_options = /b/.exec(scale_tonic_name)
        ? {
          sharp: true
        }
        : {
          flat: true
        };
      select_pitch_name_component = function(component){
        return function(arg$){
          var pitch, name;
          pitch = arg$.pitch;
          name = pitch_name(pitch, pitch_name_options);
          switch (component) {
          case 'base':
            return name.replace(/(.).*/, '$1');
          case 'accidental':
            return name.replace(/^./, '');
          }
        };
      };
      this.d3_notes.each(function(note){
        var string_number, fret_number, pitch, note_label;
        string_number = note.string_number, fret_number = note.fret_number, pitch = note.pitch;
        note.pitch = pitch_class(string_pitches[string_number] + fret_number);
        note_label = d3.select(this).select('.note');
        note_label.select('.base').text(select_pitch_name_component('base'));
        return note_label.select('.accidental').text(select_pitch_name_component('accidental'));
      });
      return this.update();
    };
    return FingerboardView;
  }());
  NoteGridView = (function(){
    NoteGridView.displayName = 'NoteGridView';
    var prototype = NoteGridView.prototype, constructor = NoteGridView;
    function NoteGridView(selection, style, reference){
      var column_count, ref$, row_count, notes, res$, i$, len$, column, j$, ref1$, len1$, row, note, degree_groups, degree, this$ = this instanceof ctor$ ? this : new ctor$;
      this$.selection = selection;
      this$.style = style;
      this$.reference = reference;
      selection = this$.selection;
      style = this$.style;
      column_count = (ref$ = style.columns) != null
        ? ref$
        : 12 * 5;
      row_count = (ref$ = style.rows) != null ? ref$ : 12;
      res$ = [];
      for (i$ = 0, len$ = (ref$ = (fn$())).length; i$ < len$; ++i$) {
        column = ref$[i$];
        for (j$ = 0, len1$ = (ref1$ = (fn1$())).length; j$ < len1$; ++j$) {
          row = ref1$[j$];
          res$.push({
            column: column,
            row: row
          });
        }
      }
      notes = res$;
      for (i$ = 0, len$ = notes.length; i$ < len$; ++i$) {
        note = notes[i$];
        note.scale_degree = pitch_class(note.column * 7 + note.row);
      }
      degree_groups = d3.nest().key(function(it){
        return it.scale_degree;
      }).entries(notes);
      for (i$ = 0, len$ = degree_groups.length; i$ < len$; ++i$) {
        degree = degree_groups[i$];
        degree.scale_degree = Number(degree.key);
      }
      this$.root = selection.append('svg').attr({
        width: column_count * style.string_width,
        height: row_count * style.fret_height
      });
      this$.note_views = this$.root.selectAll('.scale-degree').data(degree_groups).enter().append('g').classed('scale-degree', true).selectAll('.note').data(function(it){
        return it.values;
      }).enter().append('g').classed('note', true).attr({
        transform: function(arg$){
          var column, row, x, y;
          column = arg$.column, row = arg$.row;
          x = (column + 0.5) * style.string_width;
          y = row * style.fret_height + style.note_radius;
          return "translate(" + x + ", " + y + ")";
        }
      });
      this$.note_views.append('circle').attr({
        r: style.note_radius
      });
      this$.note_views.append('text').attr({
        y: 7
      }).text(function(it){
        return ScaleDegreeNames[it.scale_degree];
      });
      D3State.on('instrument.note_grid', function(){
        return this$.update();
      });
      D3State.on('scale.note_grid', function(){
        return this$.update();
      });
      D3State.on('scale_tonic.note_grid', function(){
        return this$.update();
      });
      this$.update();
      setTimeout(function(){
        return selection.classed('animate', true);
      }, 1);
      return this$;
      function fn$(){
        var i$, to$, results$ = [];
        for (i$ = 0, to$ = column_count; i$ < to$; ++i$) {
          results$.push(i$);
        }
        return results$;
      }
      function fn1$(){
        var i$, to$, results$ = [];
        for (i$ = 0, to$ = row_count; i$ < to$; ++i$) {
          results$.push(i$);
        }
        return results$;
      }
    } function ctor$(){} ctor$.prototype = prototype;
    prototype.update_note_colors = function(){
      var scale_pitches;
      scale_pitches = Scales[State.scale_class_name].pitches;
      return this.selection.selectAll('.scale-degree').classed('chromatic', function(arg$){
        var scale_degree;
        scale_degree = arg$.scale_degree;
        return !in$(scale_degree, scale_pitches);
      }).classed('tonic', function(arg$){
        var scale_degree;
        scale_degree = arg$.scale_degree;
        return in$(scale_degree, scale_pitches) && scale_degree === 0;
      }).classed('fifth', function(arg$){
        var scale_degree;
        scale_degree = arg$.scale_degree;
        return in$(scale_degree, scale_pitches) && scale_degree === 7;
      });
    };
    prototype.update = function(){
      var scale_tonic, bass_pitch, pos;
      this.update_note_colors();
      scale_tonic = State.scale_tonic_pitch;
      bass_pitch = Instruments[State.instrument_name][0];
      pos = $('#fingerboard').offset();
      pos.left -= this.style.string_width * pitch_class((scale_tonic - bass_pitch) * 5);
      return this.selection.each(function(){
        return $(this).css({
          left: pos.left + 1,
          top: pos.top + 1
        });
      });
    };
    return NoteGridView;
  }());
  d3.select('#fingerboard').call(FingerboardView, FingerboardStyle);
  d3.select('#keyboard').call(KeyboardView, KeyboardStyle);
  d3.select('#scales').call(ScaleSelectorView, ScaleStyle);
  d3.select('#scale-notes').call(NoteGridView, FingerboardStyle);
  $('#instruments .btn').click(function(){
    $('#instruments .btn').removeClass('btn-default');
    $(this).addClass('btn-default');
    State.instrument_name = $(this).text();
    return D3State.instrument();
  });
  $('#fingerings .btn').click(function(){
    $('#fingerings .btn').removeClass('btn-default');
    $(this).addClass('btn-default');
    State.note_label = $(this).text().replace(' ', '_').toLowerCase();
    return D3State.note_label();
  });
  $('#about-text a').attr('target', '_blank');
  $('#about').popover({
    content: $('#about-text').html(),
    html: true,
    placement: 'bottom'
  });
  function in$(x, arr){
    var i = -1, l = arr.length >>> 0;
    while (++i < l) if (x === arr[i] && i in arr) return true;
    return false;
  }
}).call(this);
