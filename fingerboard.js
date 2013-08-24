(function(){
  var SharpNoteNames, FlatNoteNames, ScaleDegreeNames, Pitches, pitch_name_to_number, pitch_number_to_name, pitch_to_pitch_class, pitch_name, Scales, Instruments, fingerboard_position_pitch, FingerPositions, Style, module, slice$ = [].slice, join$ = [].join, replace$ = ''.replace;
  SharpNoteNames = ['C', 'C#', 'D', 'D#', 'E', 'F', 'F#', 'G', 'G#', 'A', 'A#', 'B'].map(function(it){
    return it.replace(/#/, '\u266F');
  });
  FlatNoteNames = ['C', 'Db', 'D', 'Eb', 'E', 'F', 'Gb', 'G', 'Ab', 'A', 'Bb', 'B'].map(function(it){
    return it.replace(/b/, '\u266D');
  });
  ScaleDegreeNames = ['1', 'b2', '2', 'b3', '3', '4', 'b5', '5', 'b6', '6', 'b7', '7'].map(function(it){
    return it.replace(/(\d)/, '$1\u0302').replace(/b/, '\u266D');
  });
  Pitches = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11];
  pitch_name_to_number = function(pitch_name){
    var pitch;
    pitch = FlatNoteNames.indexOf(pitch_name);
    if (!(pitch >= 0)) {
      pitch = SharpNoteNames.indexOf(pitch_name);
    }
    return pitch;
  };
  pitch_number_to_name = function(pitch_number){
    var pitch;
    pitch = pitch_to_pitch_class(pitch_number);
    return SharpNoteNames.indexOf(pitch) || FlatNoteNames.indexOf(pitch);
  };
  pitch_to_pitch_class = function(pitch){
    var ref$;
    return ((pitch) % (ref$ = 12) + ref$) % ref$;
  };
  pitch_name = function(pitch, options){
    var pitch_class, flatName, sharpName, name;
    options == null && (options = {});
    pitch_class = pitch_to_pitch_class(pitch);
    flatName = FlatNoteNames[pitch_class];
    sharpName = SharpNoteNames[pitch_class];
    name = options.sharp ? sharpName : flatName;
    if (options.flat && options.sharp && flatName !== sharpName) {
      name = flatName + "/\n" + sharpName;
    }
    return name;
  };
  Scales = [
    {
      name: 'Diatonic Major',
      pitch_classes: [0, 2, 4, 5, 7, 9, 11],
      mode_names: ['Ionian', 'Dorian', 'Phrygian', 'Lydian', 'Mixolydian', 'Aeolian', 'Locrian']
    }, {
      name: 'Natural Minor',
      pitch_classes: [0, 2, 3, 5, 7, 8, 10],
      mode_of: 'Diatonic Major'
    }, {
      name: 'Major Pentatonic',
      pitch_classes: [0, 2, 4, 7, 9],
      mode_names: ['Major Pentatonic', 'Suspended Pentatonic', 'Man Gong', 'Ritusen', 'Minor Pentatonic']
    }, {
      name: 'Minor Pentatonic',
      pitch_classes: [0, 3, 5, 7, 10],
      mode_of: 'Major Pentatonic'
    }, {
      name: 'Melodic Minor',
      pitch_classes: [0, 2, 3, 5, 7, 9, 11],
      mode_names: ['Jazz Minor', 'Dorian b2', 'Lydian Augmented', 'Lydian Dominant', 'Mixolydian b6', 'Semilocrian', 'Superlocrian']
    }, {
      name: 'Harmonic Minor',
      pitch_classes: [0, 2, 3, 5, 7, 8, 11],
      mode_names: ['Harmonic Minor', 'Locrian #6', 'Ionian Augmented', 'Romanian', 'Phrygian Dominant', 'Lydian #2', 'Ultralocrian']
    }, {
      name: 'Blues',
      pitch_classes: [0, 3, 5, 6, 7, 10]
    }, {
      name: 'Freygish',
      pitch_classes: [0, 1, 4, 5, 7, 8, 10]
    }, {
      name: 'Whole Tone',
      pitch_classes: [0, 2, 4, 6, 8, 10]
    }, {
      name: 'Octatonic',
      pitch_classes: [0, 2, 3, 5, 6, 8, 9, 11]
    }
  ];
  (function(){
    var i$, ref$, len$, scale, name, mode_names, pitch_classes, rotate, mode_of, base, i, results$ = [];
    for (i$ = 0, len$ = (ref$ = Scales).length; i$ < len$; ++i$) {
      scale = ref$[i$], name = scale.name, mode_names = scale.mode_names, pitch_classes = scale.pitch_classes;
      Scales[name] = scale;
    }
    rotate = function(pitch_classes, i){
      var ref$;
      i = ((i) % (ref$ = pitch_classes.length) + ref$) % ref$;
      pitch_classes = pitch_classes.slice(i).concat(slice$.call(pitch_classes, 0, i));
      return pitch_classes.map(function(it){
        return pitch_to_pitch_class(it - pitch_classes[0]);
      });
    };
    for (i$ = 0, len$ = (ref$ = Scales).length; i$ < len$; ++i$) {
      scale = ref$[i$], name = scale.name, mode_names = scale.mode_names, mode_of = scale.mode_of, pitch_classes = scale.pitch_classes;
      scale.base = base = Scales[mode_of];
      mode_names || (mode_names = base != null ? base.mode_names : void 8);
      if (mode_names != null) {
        scale.mode_index = 0;
        if (base != null) {
          scale.mode_index = (fn$()).filter(fn1$)[0];
        }
        results$.push(scale.modes = (fn2$()));
      }
    }
    return results$;
    function fn$(){
      var i$, to$, results$ = [];
      for (i$ = 0, to$ = pitch_classes.length; i$ < to$; ++i$) {
        results$.push(i$);
      }
      return results$;
    }
    function fn1$(i){
      return join$.call(rotate(base.pitch_classes, i), ',') === join$.call(pitch_classes, ',');
    }
    function fn2$(){
      var i$, ref$, len$, results$ = [];
      for (i$ = 0, len$ = (ref$ = mode_names).length; i$ < len$; ++i$) {
        i = i$;
        name = ref$[i$];
        results$.push({
          name: name.replace(/#/, '\u266F').replace(/\bb(\d)/, '\u266D$1'),
          pitch_classes: rotate((base != null ? base.pitch_classes : void 8) || pitch_classes, i),
          parent: scale
        });
      }
      return results$;
    }
  })();
  Instruments = [
    {
      name: 'Violin',
      string_pitches: [7, 14, 21, 28]
    }, {
      name: 'Viola',
      string_pitches: [0, 7, 14, 21]
    }, {
      name: 'Cello',
      string_pitches: [0, 7, 14, 21]
    }
  ];
  (function(){
    var i$, ref$, len$, instrument, results$ = [];
    for (i$ = 0, len$ = (ref$ = Instruments).length; i$ < len$; ++i$) {
      instrument = ref$[i$];
      results$.push(Instruments[instrument.name] = instrument);
    }
    return results$;
  })();
  fingerboard_position_pitch = function(arg$){
    var instrument, string_number, fret_number;
    instrument = arg$.instrument, string_number = arg$.string_number, fret_number = arg$.fret_number;
    return instrument.string_pitches[string_number] + fret_number;
  };
  FingerPositions = 7;
  Style = {
    fingerboard: {
      string_width: 50,
      fret_height: 50,
      note_radius: 20
    },
    keyboard: {
      octaves: 2,
      key_width: 25,
      key_spacing: 3,
      white_key_height: 120,
      black_key_height: 90
    },
    scales: {
      constellation_radius: 28,
      pitch_radius: 3
    }
  };
  d3.music || (d3.music = {});
  d3.music.keyboard = function(model, attributes){
    var style, octaves, stroke_width, selection, dispatcher, update;
    style = attributes;
    octaves = attributes.octaves;
    stroke_width = 1;
    selection = null;
    my.dispatcher = dispatcher = d3.dispatch('mouseover', 'mouseout', 'tonic_name');
    my.update = function(){
      return update;
    };
    function my(_selection){
      var keys, x, i$, len$, ref$, attrs, width, is_black_key, white_key_count, root, onclick, key_views;
      selection = _selection;
      keys = (function(){
        var i$, to$, results$ = [];
        for (i$ = 0, to$ = 12 * octaves; i$ < to$; ++i$) {
          results$.push(i$);
        }
        return results$;
      }()).map(function(pitch){
        var pitch_class, is_black_key, note_name, height;
        pitch_class = pitch_to_pitch_class(pitch);
        is_black_key = FlatNoteNames[pitch_class].length > 1;
        note_name = pitch_name(pitch, {
          flat: true
        });
        height = is_black_key
          ? style.black_key_height
          : style.white_key_height;
        return {
          pitch: pitch,
          pitch_class: pitch_class,
          name: note_name,
          is_black_key: is_black_key,
          attrs: {
            width: style.key_width,
            height: height,
            y: 0
          }
        };
      });
      x = stroke_width;
      for (i$ = 0, len$ = keys.length; i$ < len$; ++i$) {
        ref$ = keys[i$], attrs = ref$.attrs, width = attrs.width, is_black_key = ref$.is_black_key;
        attrs.x = x;
        if (is_black_key) {
          attrs.x -= width / 2;
        }
        if (!is_black_key) {
          x += width + style.key_spacing;
        }
      }
      keys.sort(function(a, b){
        return a.is_black_key - b.is_black_key;
      });
      white_key_count = octaves * 7;
      root = selection.append('svg').attr({
        width: white_key_count * (style.key_width + style.key_spacing) - style.key_spacing + 2 * stroke_width,
        height: style.white_key_height + 1
      });
      onclick = function(arg$){
        var pitch, pitch_class;
        pitch = arg$.pitch, pitch_class = arg$.pitch_class;
        model.scale_tonic_name = FlatNoteNames[pitch_class];
        model.scale_tonic_pitch = pitch;
        update();
        return dispatcher.tonic_name(model.scale_tonic_name);
      };
      key_views = root.selectAll('.piano-key').data(keys).enter().append('g').attr('class', function(it){
        return "pitch-" + it.pitch + " pitch-class-" + it.pitch_class;
      }).classed('piano-key', true).classed('black-key', function(it){
        return it.is_black_key;
      }).classed('white-key', function(it){
        return !it.is_black_key;
      }).on('click', onclick).on('mouseover', function(it){
        return dispatcher.mouseover(it.pitch);
      }).on('mouseout', function(it){
        return dispatcher.mouseout(it.pitch);
      });
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
      key_views.append('text').classed('flat-label', true).attr({
        x: function(arg$){
          var attrs, x, width;
          attrs = arg$.attrs, x = attrs.x, width = attrs.width;
          return x + width / 2;
        },
        y: function(arg$){
          var attrs, y, height;
          attrs = arg$.attrs, y = attrs.y, height = attrs.height;
          return y + height - 6;
        }
      }).text(function(it){
        return FlatNoteNames[it.pitch_class];
      });
      key_views.append('text').classed('sharp-label', true).attr({
        x: function(arg$){
          var attrs, x, width;
          attrs = arg$.attrs, x = attrs.x, width = attrs.width;
          return x + width / 2;
        },
        y: function(arg$){
          var attrs, y, height;
          attrs = arg$.attrs, y = attrs.y, height = attrs.height;
          return y + height - 6;
        }
      }).text(function(it){
        return SharpNoteNames[it.pitch_class];
      });
      return update();
    }
    update = function(){
      return selection.selectAll('.piano-key').classed('root', function(it){
        return pitch_to_pitch_class(it.pitch - model.scale_tonic_pitch) === 0;
      }).classed('scale-note', function(it){
        return in$(pitch_to_pitch_class(it.pitch - model.scale_tonic_pitch), model.scale.pitch_classes);
      }).classed('fifth', function(it){
        return pitch_to_pitch_class(it.pitch - model.scale_tonic_pitch) === 7;
      });
    };
    return my;
  };
  d3.music.pitchConstellation = function(pitch_classes, attributes){
    var style;
    style = attributes;
    return function(selection){
      var r, note_radius, pc_width, root, endpoints;
      r = style.constellation_radius;
      note_radius = style.pitch_radius;
      pc_width = 2 * (r + note_radius + 1);
      root = selection.append('svg').attr({
        width: pc_width,
        height: pc_width
      }).append('g').attr({
        transform: "translate(" + pc_width / 2 + ", " + pc_width / 2 + ")"
      });
      endpoints = Pitches.map(function(pitch_class){
        var a, x, y, chromatic;
        a = (pitch_class - 3) * 2 * Math.PI / 12;
        x = Math.cos(a) * r;
        y = Math.sin(a) * r;
        chromatic = !in$(pitch_class, pitch_classes);
        return {
          x: x,
          y: y,
          chromatic: chromatic,
          pitch_class: pitch_class
        };
      });
      root.selectAll('line').data(endpoints).enter().append('line').classed('chromatic', function(it){
        return it.chromatic;
      }).attr('x2', function(it){
        return it.x;
      }).attr('y2', function(it){
        return it.y;
      });
      return root.selectAll('circle').data(endpoints).enter().append('circle').attr('class', function(it){
        return "relative-pitch-class-" + it.pitch_class;
      }).classed('chromatic', function(it){
        return it.chromatic;
      }).classed('root', function(it){
        return it.pitch_class === 0;
      }).classed('fifth', function(it){
        return it.pitch_class === 7;
      }).attr('cx', function(it){
        return it.x;
      }).attr('cy', function(it){
        return it.y;
      }).attr('r', note_radius);
    };
  };
  d3.music.fingerboard = function(model, attributes){
    var style, label_sets, dispatcher, attrs, d3_notes, note_label, update_instrument;
    style = attributes;
    label_sets = ['notes', 'fingerings', 'scale-degrees'];
    dispatcher = my.dispatcher = d3.dispatch('mouseover', 'mouseout', 'update');
    attrs = {};
    d3_notes = null;
    note_label = null;
    function my(selection){
      var instrument, string_count, finger_positions, i$, string_number, j$, to$, fret_number, pitch, root, text_y, note_labels;
      instrument = model.instrument;
      string_count = instrument.string_pitches.length;
      finger_positions = [];
      for (i$ = 0; i$ < string_count; ++i$) {
        string_number = i$;
        for (j$ = 0, to$ = FingerPositions; j$ <= to$; ++j$) {
          fret_number = j$;
          pitch = fingerboard_position_pitch({
            instrument: instrument,
            string_number: string_number,
            fret_number: fret_number
          });
          finger_positions.push({
            string_number: string_number,
            fret_number: fret_number,
            pitch: pitch,
            pitch_class: pitch_to_pitch_class(pitch),
            fingering_name: String(Math.ceil(fret_number / 2))
          });
        }
      }
      root = selection.append('svg').attr({
        width: string_count * style.string_width
      }).attr({
        height: (1 + FingerPositions) * style.fret_height
      });
      root.append('line').classed('nut', true).attr({
        x2: string_count * style.string_width,
        transform: "translate(0, " + (style.fret_height - 5) + ")"
      });
      root.selectAll('.string').data((function(){
        var i$, to$, results$ = [];
        for (i$ = 0, to$ = string_count; i$ < to$; ++i$) {
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
      d3_notes = root.selectAll('.finger-position').data(finger_positions).enter().append('g').classed('finger-position', true).attr({
        transform: function(arg$){
          var string_number, fret_number, dx, dy;
          string_number = arg$.string_number, fret_number = arg$.fret_number;
          dx = (string_number + 0.5) * style.string_width;
          dy = fret_number * style.fret_height + style.note_radius + 1;
          return "translate(" + dx + ", " + dy + ")";
        }
      }).on('mouseover', function(it){
        return dispatcher.mouseover(it.pitch);
      }).on('mouseout', function(it){
        return dispatcher.mouseout(it.pitch);
      });
      d3_notes.append('circle').attr({
        r: style.note_radius
      });
      text_y = 7;
      note_labels = d3_notes.append('text').classed('note', true).attr({
        y: text_y
      });
      note_labels.append('tspan').classed('base', true);
      note_labels.append('tspan').classed('accidental', true).classed('flat', true).classed('flat-label', true);
      note_labels.append('tspan').classed('accidental', true).classed('sharp', true).classed('sharp-label', true);
      d3_notes.append('text').classed('fingering', true).attr({
        y: text_y
      }).text(function(it){
        return it.fingering_name;
      });
      d3_notes.append('text').classed('scale-degree', true).attr({
        y: text_y
      });
      dispatcher.on('update', function(){
        return my.update();
      });
      return my.update();
    }
    my.attr = function(key, value){
      if (!(key = 'note_label')) {
        throw "Unknown key " + key;
      }
      if (!(arguments.length > 1)) {
        return note_label;
      }
      note_label = value;
      return my.update();
    };
    my.update = function(){
      var scale, scale_tonic, scale_pitch_classes, i$, ref$, len$, k, visible, labels;
      if (attrs.instrument === model.instrument && attrs.scale === model.scale && attrs.tonic === model.tonic) {
        return;
      }
      update_instrument();
      scale = attrs.scale = model.scale;
      scale_tonic = attrs.tonic = model.scale_tonic_pitch;
      scale_pitch_classes = scale.pitch_classes;
      note_label = note_label || 'notes';
      for (i$ = 0, len$ = (ref$ = label_sets).length; i$ < len$; ++i$) {
        k = ref$[i$];
        visible = k === note_label.replace(/_/g, '-');
        labels = d3.select('#fingerboard').selectAll('.' + k.replace(/s$/, ''));
        labels.attr('visibility', visible ? 'inherit' : 'hidden');
      }
      d3_notes.each(function(note){
        var pitch;
        pitch = note.pitch;
        return note.relative_pitch_class = pitch_to_pitch_class(pitch - scale_tonic);
      });
      d3_notes.attr('class', function(it){
        return "pitch-class-" + it.pitch_class + " relative-pitch-class-" + it.relative_pitch_class;
      }).classed('finger-position', true).classed('scale', function(it){
        return in$(it.relative_pitch_class, scale_pitch_classes);
      }).classed('chromatic', function(it){
        return !in$(it.relative_pitch_class, scale_pitch_classes);
      }).select('.scale-degree').text("").text(function(it){
        return ScaleDegreeNames[it.relative_pitch_class];
      });
      return d3_notes.each(function(arg$){
        var pitch, note_labels;
        pitch = arg$.pitch;
        return note_labels = d3.select(this);
      });
    };
    update_instrument = function(){
      var instrument, string_pitches, scale_tonic_name, pitch_name_options, select_pitch_name_component;
      if (attrs.instrument === model.instrument) {
        return;
      }
      instrument = attrs.instrument = model.instrument;
      string_pitches = instrument.string_pitches;
      d3_notes.each(function(note){
        var string_number, fret_number;
        string_number = note.string_number, fret_number = note.fret_number;
        note.pitch = fingerboard_position_pitch({
          instrument: instrument,
          string_number: string_number,
          fret_number: fret_number
        });
        return note.pitch_class = pitch_to_pitch_class(note.pitch);
      });
      scale_tonic_name = model.scale_tonic_name;
      pitch_name_options = /\u266D/.exec(scale_tonic_name)
        ? {
          flat: true
        }
        : {
          sharp: true
        };
      select_pitch_name_component = curry$(function(component, arg$){
        var pitch, pitch_class, name;
        pitch = arg$.pitch, pitch_class = arg$.pitch_class;
        name = pitch_name(pitch, pitch_name_options);
        switch (component) {
        case 'base':
          return replace$.call(name, /[^\w]/, '');
        case 'accidental':
          return replace$.call(name, /[\w]/, '');
        case 'flat':
          return FlatNoteNames[pitch_class].slice(1);
        case 'sharp':
          return SharpNoteNames[pitch_class].slice(1);
        }
      });
      return d3_notes.each(function(note){
        var string_number, fret_number, pitch, note_labels;
        string_number = note.string_number, fret_number = note.fret_number, pitch = note.pitch;
        note_labels = d3.select(this).select('.note');
        note_labels.select('.base').text(select_pitch_name_component('base'));
        note_labels.select('.flat').text(select_pitch_name_component('flat'));
        return note_labels.select('.sharp').text(select_pitch_name_component('sharp'));
      });
    };
    return my;
  };
  d3.music.noteGrid = function(model, style, referenceElement){
    var column_count, ref$, row_count, cached_offset, selection, update_position;
    column_count = (ref$ = style.columns) != null
      ? ref$
      : 12 * 5;
    row_count = (ref$ = style.rows) != null ? ref$ : 12;
    cached_offset = null;
    selection = null;
    function my(_selection){
      var notes, res$, i$, ref$, len$, column, j$, ref1$, len1$, row, note, degree_groups, degree, root, note_views;
      selection = _selection;
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
        note.relative_pitch_class = pitch_to_pitch_class(note.column * 7 + note.row);
      }
      degree_groups = d3.nest().key(function(it){
        return it.relative_pitch_class;
      }).entries(notes);
      for (i$ = 0, len$ = degree_groups.length; i$ < len$; ++i$) {
        degree = degree_groups[i$];
        degree.relative_pitch_class = Number(degree.key);
      }
      root = selection.append('svg').attr({
        width: column_count * style.string_width,
        height: row_count * style.fret_height
      });
      note_views = root.selectAll('.scale-degree').data(degree_groups).enter().append('g').classed('scale-degree', true).selectAll('.note').data(function(it){
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
      note_views.append('circle').attr({
        r: style.note_radius
      });
      note_views.append('text').attr({
        y: 7
      }).text(function(it){
        return ScaleDegreeNames[it.relative_pitch_class];
      });
      return setTimeout(function(){
        return selection.classed('animate', true);
      }, 1);
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
    }
    my.update = function(){
      update_note_colors();
      return update_position();
    };
    function update_note_colors(){
      var scale_pitch_classes;
      scale_pitch_classes = model.scale.pitch_classes;
      return selection.selectAll('.scale-degree').classed('chromatic', function(arg$){
        var relative_pitch_class;
        relative_pitch_class = arg$.relative_pitch_class;
        return !in$(relative_pitch_class, scale_pitch_classes);
      }).classed('tonic', function(arg$){
        var relative_pitch_class;
        relative_pitch_class = arg$.relative_pitch_class;
        return in$(relative_pitch_class, scale_pitch_classes) && relative_pitch_class === 0;
      }).classed('fifth', function(arg$){
        var relative_pitch_class;
        relative_pitch_class = arg$.relative_pitch_class;
        return in$(relative_pitch_class, scale_pitch_classes) && relative_pitch_class === 7;
      });
    }
    update_position = function(){
      var scale_tonic, bass_pitch, offset, pos;
      scale_tonic = model.scale_tonic_pitch;
      bass_pitch = model.instrument.string_pitches[0];
      offset = style.string_width * pitch_to_pitch_class((scale_tonic - bass_pitch) * 5);
      if (offset === cached_offset) {
        return;
      }
      cached_offset = offset;
      pos = $(referenceElement).offset();
      return selection.each(function(){
        return $(this).css({
          left: pos.left - offset + 1,
          top: pos.top + 1
        });
      });
    };
    return my;
  };
  module = angular.module('FingerboardApp', ['ui.bootstrap']);
  this.FingerboardScalesCtrl = function($scope){
    var noteGrid;
    $scope.aboutText = $('#about-text').html();
    $scope.scales = Scales;
    $scope.instruments = Instruments;
    $scope.instrument = Instruments.Violin;
    $scope.scale = Scales[0].modes[0];
    $scope.scale_tonic_name = 'C';
    $scope.scale_tonic_pitch = 0;
    $scope.hover = {
      pitch_classes: null,
      scale_tonic_pitch: null
    };
    $scope.setInstrument = function(instr){
      if (instr != null) {
        return $scope.instrument = instr;
      }
    };
    $scope.setScale = function(s){
      var ref$;
      return $scope.scale = ((ref$ = s.modes) != null ? ref$[s.mode_index] : void 8) || s;
    };
    $scope.bodyClassNames = function(){
      var hover, scale_tonic, ref$, scale_pitch_classes, ref1$, classes, show_sharps, n;
      hover = $scope.hover;
      scale_tonic = (ref$ = hover.scale_tonic_pitch) != null
        ? ref$
        : $scope.scale_tonic_pitch;
      scale_pitch_classes = (ref$ = (ref1$ = hover.scale) != null ? ref1$.pitch_classes : void 8) != null
        ? ref$
        : $scope.scale.pitch_classes;
      classes = [];
      show_sharps = !(ref$ = FlatNoteNames[pitch_to_pitch_class(scale_tonic)].length === 1) !== !(ref1$ = /F/.exec(FlatNoteNames[pitch_to_pitch_class(scale_tonic)])) && (ref$ || ref1$);
      classes.push(show_sharps ? 'hide-flat-labels' : 'hide-sharp-labels');
      classes = classes.concat((function(){
        var i$, ref$, len$, results$ = [];
        for (i$ = 0, len$ = (ref$ = scale_pitch_classes).length; i$ < len$; ++i$) {
          n = ref$[i$];
          results$.push("scale-includes-relative-pitch-class-" + n);
        }
        return results$;
      }()));
      classes = classes.concat((function(){
        var i$, ref$, len$, results$ = [];
        for (i$ = 0, len$ = (ref$ = scale_pitch_classes).length; i$ < len$; ++i$) {
          n = ref$[i$];
          results$.push("scale-includes-pitch-class-" + pitch_to_pitch_class(n + scale_tonic));
        }
        return results$;
      }()));
      if (hover.pitch != null) {
        classes.push("hover-note-relative-pitch-class-" + pitch_to_pitch_class(hover.pitch - scale_tonic));
        classes.push("hover-note-pitch-class-" + pitch_to_pitch_class(hover.pitch));
      }
      return classes;
    };
    noteGrid = d3.music.noteGrid($scope, Style.fingerboard, document.querySelector('#fingerboard'));
    d3.select('#scale-notes').call(noteGrid);
    $scope.$watch(function(){
      return noteGrid.update();
    });
    $('#fingerings .btn').click(function(){
      var note_label_name;
      $('#fingerings .btn').removeClass('btn-default');
      $(this).addClass('btn-default');
      note_label_name = $(this).text().replace(' ', '_').toLowerCase().replace('fingers', 'fingerings');
      return $scope.$apply(function(){
        return $scope.note_label = note_label_name;
      });
    });
    angular.element(document).bind('touchmove', false);
    return angular.element(document.body).removeClass('loading');
  };
  module.directive('fingerboard', function(){
    return {
      restrict: 'CE',
      link: function(scope, element, attrs){
        var fingerboard;
        fingerboard = d3.music.fingerboard(scope, Style.fingerboard);
        d3.select(element[0]).call(fingerboard);
        scope.$watch(function(){
          fingerboard.attr('note_label', scope.note_label);
          return fingerboard.update();
        });
        fingerboard.dispatcher.on('mouseover', function(pitch){
          return scope.$apply(function(){
            return scope.hover.pitch = pitch;
          });
        });
        return fingerboard.dispatcher.on('mouseout', function(){
          return scope.$apply(function(){
            return scope.hover.pitch = null;
          });
        });
      }
    };
  });
  module.directive('pitchConstellation', function(){
    return {
      restrict: 'CE',
      replace: true,
      scope: {
        pitch_classes: '=',
        pitches: '=',
        hover: '='
      },
      transclude: true,
      link: function(scope, element, attrs){
        var constellation;
        constellation = d3.music.pitchConstellation(scope.pitches, Style.scales);
        return d3.select(element[0]).call(constellation);
      }
    };
  });
  module.directive('keyboard', function(){
    return {
      restrict: 'CE',
      link: function(scope, element, attrs){
        var keyboard;
        keyboard = d3.music.keyboard(scope, Style.keyboard);
        d3.select(element[0]).call(keyboard);
        scope.$watch(function(){
          return keyboard.update();
        });
        keyboard.dispatcher.on('tonic_name', function(tonic_name){
          return scope.$apply(function(){
            scope.scale_tonic_name = tonic_name;
            return scope.scale_tonic_pitch = pitch_name_to_number(tonic_name);
          });
        });
        keyboard.dispatcher.on('mouseover', function(pitch){
          return scope.$apply(function(){
            scope.hover.pitch = pitch;
            return scope.hover.scale_tonic_pitch = pitch;
          });
        });
        return keyboard.dispatcher.on('mouseout', function(){
          return scope.$apply(function(){
            scope.hover.pitch = null;
            return scope.hover.scale_tonic_pitch = null;
          });
        });
      }
    };
  });
  module.directive('unsafePopoverPopup', function(){
    return {
      restrict: 'EA',
      replace: true,
      scope: {
        title: '@',
        content: '@',
        placement: '@',
        animation: '&',
        isOpen: '&'
      },
      templateUrl: 'template/popover.html'
    };
  }).directive('unsafePopover', function($tooltip){
    return $tooltip('unsafePopover', 'popover', 'click');
  });
  function in$(x, arr){
    var i = -1, l = arr.length >>> 0;
    while (++i < l) if (x === arr[i] && i in arr) return true;
    return false;
  }
  function curry$(f, bound){
    var context,
    _curry = function(args) {
      return f.length > 1 ? function(){
        var params = args ? args.concat() : [];
        context = bound ? context || this : this;
        return params.push.apply(params, arguments) <
            f.length && arguments.length ?
          _curry.call(context, params) : f.apply(context, params);
      } : f;
    };
    return _curry();
  }
}).call(this);
