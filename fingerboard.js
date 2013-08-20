(function(){
  var SharpNoteNames, FlatNoteNames, ScaleDegreeNames, Scales, pitch_name_to_number, pitch_number_to_name, Instruments, Pitches, pitch_at, pitch_class, pitch_name, FingerPositions, Style, module, replace$ = ''.replace;
  SharpNoteNames = ['C', 'C#', 'D', 'D#', 'E', 'F', 'F#', 'G', 'G#', 'A', 'A#', 'B'].map(function(it){
    return it.replace(/#/g, '\u266F');
  });
  FlatNoteNames = ['C', 'Db', 'D', 'Eb', 'E', 'F', 'Gb', 'G', 'Ab', 'A', 'Bb', 'B'].map(function(it){
    return it.replace(/b/, '\u266D');
  });
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
  pitch_number_to_name = function(pitch_number){
    var pitch;
    pitch = pitch_class(pitch_number);
    return SharpNoteNames.indexOf(pitch) || FlatNoteNames.indexOf(pitch);
  };
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
    return name;
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
    var style, octaves, stroke_width, dispatcher;
    style = attributes;
    octaves = attributes.octaves;
    stroke_width = 1;
    my.dispatcher = dispatcher = d3.dispatch('mouseover', 'mouseout', 'tonic', 'update');
    my.update = function(){
      return dispatcher.update();
    };
    function my(selection){
      var keys, i, x, i$, len$, ref$, attrs, width, is_black_key, white_key_count, root, onclick, key_views, update;
      keys = (function(){
        var i$, ref$, len$, results$ = [];
        for (i$ = 0, len$ = (ref$ = (fn$())).length; i$ < len$; ++i$) {
          i = ref$[i$];
          results$.push(pitch_class(i));
        }
        return results$;
        function fn$(){
          var i$, to$, results$ = [];
          for (i$ = 0, to$ = 12 * octaves; i$ < to$; ++i$) {
            results$.push(i$);
          }
          return results$;
        }
      }()).map(function(pitch){
        var is_black_key, note_name, height;
        is_black_key = FlatNoteNames[pitch].length > 1;
        note_name = pitch_name(pitch, {
          flat: true
        });
        height = is_black_key
          ? style.black_key_height
          : style.white_key_height;
        return {
          pitch: pitch,
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
        var pitch, name;
        pitch = arg$.pitch, name = arg$.name;
        model.scale_tonic_name = FlatNoteNames[pitch];
        model.scale_tonic_pitch = pitch;
        update();
        return dispatcher.tonic(model.scale_tonic_name);
      };
      key_views = root.selectAll('.piano-key').data(keys).enter().append('g').attr('class', function(it){
        return "scale-note-pitch-" + it.pitch;
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
      key_views.append('text').attr({
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
      }).text(function(arg$){
        var name;
        name = arg$.name;
        return name;
      });
      update = function(){
        return key_views.classed('root', function(arg$){
          var pitch;
          pitch = arg$.pitch;
          return pitch === model.scale_tonic_pitch;
        }).classed('fifth', function(arg$){
          var pitch;
          pitch = arg$.pitch;
          return pitch_class(pitch - model.scale_tonic_pitch) === 7;
        });
      };
      dispatcher.on('update', function(){
        return update();
      });
      return update();
    }
    return my;
  };
  d3.music.pitchConstellation = function(pitches, attributes){
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
      root.selectAll('line').data(endpoints).enter().append('line').classed('chromatic', function(it){
        return it.chromatic;
      }).attr('x2', function(it){
        return it.x;
      }).attr('y2', function(it){
        return it.y;
      });
      return root.selectAll('circle').data(endpoints).enter().append('circle').attr('class', function(it){
        return "scale-note-degree-" + it.pitch;
      }).classed('chromatic', function(it){
        return it.chromatic;
      }).classed('root', function(it){
        return it.pitch === 0;
      }).classed('fifth', function(it){
        return it.pitch === 7;
      }).attr('cx', function(it){
        return it.x;
      }).attr('cy', function(it){
        return it.y;
      }).attr('r', note_radius);
    };
  };
  d3.music.fingerboard = function(model, attributes){
    var style, label_sets, dispatcher, d3_notes, note_label, update_instrument;
    style = attributes;
    label_sets = ['notes', 'fingerings', 'scale-degrees'];
    dispatcher = my.dispatcher = d3.dispatch('mouseover', 'mouseout', 'update');
    d3_notes = null;
    note_label = null;
    function my(selection){
      var string_count, finger_positions, i$, string_number, j$, to$, fret_number, pitch, fingering_name, root, note_labels;
      string_count = model.instrument.string_pitches.length;
      finger_positions = [];
      for (i$ = 0; i$ < string_count; ++i$) {
        string_number = i$;
        for (j$ = 0, to$ = FingerPositions; j$ <= to$; ++j$) {
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
      note_labels = d3_notes.append('text').classed('note', true).attr({
        y: 7
      });
      note_labels.append('tspan').classed('base', true);
      note_labels.append('tspan').classed('accidental', true);
      d3_notes.append('text').classed('fingering', true).attr({
        y: 7
      }).text(function(it){
        return it.fingering_name;
      });
      d3_notes.append('text').classed('scale-degree', true).attr({
        y: 7
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
      var scale_tonic, scale, scale_pitches, res$, i$, ref$, len$, pitch, tonic, k, visible, labels, scale_degree;
      update_instrument();
      scale_tonic = model.scale_tonic_pitch;
      scale = model.scale;
      res$ = [];
      for (i$ = 0, len$ = (ref$ = scale.pitches).length; i$ < len$; ++i$) {
        pitch = ref$[i$];
        res$.push(pitch_class(pitch + scale_tonic));
      }
      scale_pitches = res$;
      tonic = scale_pitches[0];
      note_label = note_label || 'notes';
      for (i$ = 0, len$ = (ref$ = label_sets).length; i$ < len$; ++i$) {
        k = ref$[i$];
        visible = k === note_label.replace(/_/g, '-');
        labels = d3.select('#fingerboard').selectAll('.' + k.replace(/s$/, ''));
        labels.attr('visibility', visible ? 'inherit' : 'hidden');
      }
      scale_degree = function(pitch){
        return pitch_class(pitch - tonic);
      };
      d3_notes.attr('class', function(it){
        return "scale-note-pitch-" + it.pitch + " scale-note-degree-" + pitch_class(it.pitch - tonic);
      }).classed('finger-position', true).classed('scale', function(it){
        return in$(it.pitch, scale_pitches);
      }).classed('chromatic', function(it){
        return !in$(it.pitch, scale_pitches);
      }).select('.scale-degree').text("").text(function(arg$){
        var pitch;
        pitch = arg$.pitch;
        return ScaleDegreeNames[pitch_class(pitch - tonic)];
      });
      return d3_notes.each(function(arg$){
        var pitch, note_labels;
        pitch = arg$.pitch;
        return note_labels = d3.select(this);
      });
    };
    update_instrument = function(){
      var string_pitches, scale_tonic_name, pitch_name_options, select_pitch_name_component;
      string_pitches = model.instrument.string_pitches;
      scale_tonic_name = model.scale_tonic_name;
      pitch_name_options = /\u266D/.exec(scale_tonic_name)
        ? {
          flat: true
        }
        : {
          sharp: true
        };
      select_pitch_name_component = curry$(function(component, arg$){
        var pitch, name;
        pitch = arg$.pitch;
        name = pitch_name(pitch, pitch_name_options);
        switch (component) {
        case 'base':
          return replace$.call(name, /[^\w]/, '');
        case 'accidental':
          return replace$.call(name, /[\w]/, '');
        }
      });
      return d3_notes.each(function(note){
        var string_number, fret_number, pitch, note_labels;
        string_number = note.string_number, fret_number = note.fret_number, pitch = note.pitch;
        note.pitch = pitch_class(string_pitches[string_number] + fret_number);
        note_labels = d3.select(this).select('.note');
        note_labels.select('.base').text(select_pitch_name_component('base'));
        return note_labels.select('.accidental').text(select_pitch_name_component('accidental'));
      });
    };
    return my;
  };
  d3.music.noteGrid = function(model, style, referenceElement){
    var column_count, ref$, row_count, selection;
    column_count = (ref$ = style.columns) != null
      ? ref$
      : 12 * 5;
    row_count = (ref$ = style.rows) != null ? ref$ : 12;
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
        note.scale_degree = pitch_class(note.column * 7 + note.row);
      }
      degree_groups = d3.nest().key(function(it){
        return it.scale_degree;
      }).entries(notes);
      for (i$ = 0, len$ = degree_groups.length; i$ < len$; ++i$) {
        degree = degree_groups[i$];
        degree.scale_degree = Number(degree.key);
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
        return ScaleDegreeNames[it.scale_degree];
      });
      my.update();
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
    function update_note_colors(){
      var scale_pitches;
      scale_pitches = model.scale.pitches;
      return selection.selectAll('.scale-degree').classed('chromatic', function(arg$){
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
    }
    my.update = function(){
      var scale_tonic, bass_pitch, pos;
      update_note_colors();
      scale_tonic = model.scale_tonic_pitch;
      bass_pitch = model.instrument.string_pitches[0];
      pos = referenceElement.offset();
      pos.left -= style.string_width * pitch_class((scale_tonic - bass_pitch) * 5);
      return selection.each(function(){
        return $(this).css({
          left: pos.left + 1,
          top: pos.top + 1
        });
      });
    };
    return my;
  };
  module = angular.module('FingerboardScales', []);
  this.FingerboardScalesCtrl = function($scope){
    var noteGrid;
    $('#about-text a').attr('target', '_blank');
    $('#about').popover({
      content: $('#about-text').html(),
      html: true,
      placement: 'bottom'
    });
    $scope.instrument = Instruments.Violin;
    $scope.scales = Scales;
    $scope.scale = Scales[0];
    $scope.scale_tonic_name = 'C';
    $scope.scale_tonic_pitch = 0;
    $scope.setScale = function(s){
      return $scope.scale = s;
    };
    $scope.hover = {
      pitches: null,
      scale_tonic_pitch: null
    };
    $scope.bodyClassNames = function(){
      var tonic, ref$, pitches, classes, n;
      tonic = (ref$ = $scope.hover.scale_tonic_pitch) != null
        ? ref$
        : $scope.scale_tonic_pitch;
      pitches = (ref$ = $scope.hover.pitches) != null
        ? ref$
        : $scope.scale.pitches;
      classes = [];
      classes = classes.concat((function(){
        var i$, ref$, len$, results$ = [];
        for (i$ = 0, len$ = (ref$ = pitches).length; i$ < len$; ++i$) {
          n = ref$[i$];
          results$.push("scale-includes-degree-" + n);
        }
        return results$;
      }()));
      classes = classes.concat((function(){
        var i$, ref$, len$, results$ = [];
        for (i$ = 0, len$ = (ref$ = pitches).length; i$ < len$; ++i$) {
          n = ref$[i$];
          results$.push("scale-includes-pitch-" + pitch_class(n + tonic));
        }
        return results$;
      }()));
      if ($scope.hover.scale_tonic_pitch != null) {
        classes.push("hover-scale-note-degree-" + pitch_class(tonic - $scope.scale_tonic_pitch));
      }
      if ($scope.hover.scale_tonic_pitch != null) {
        classes.push("hover-scale-note-pitch-" + tonic);
      }
      return classes;
    };
    noteGrid = d3.music.noteGrid($scope, Style.fingerboard, $('#fingerboard'));
    d3.select('#scale-notes').call(noteGrid);
    $scope.$watch(function(){
      return noteGrid.update();
    });
    $('#instruments .btn').click(function(){
      var instrument_name;
      $('#instruments .btn').removeClass('btn-default');
      $(this).addClass('btn-default');
      instrument_name = $(this).text();
      return $scope.$apply(function(){
        return $scope.instrument = Instruments[instrument_name];
      });
    });
    $('#fingerings .btn').click(function(){
      var note_label_name;
      $('#fingerings .btn').removeClass('btn-default');
      $(this).addClass('btn-default');
      note_label_name = $(this).text().replace(' ', '_').toLowerCase();
      return $scope.$apply(function(){
        return $scope.note_label = note_label_name;
      });
    });
    $(document).bind('touchmove', false);
    return $('body').removeClass('loading');
  };
  module.directive('fingerboard', function(){
    return {
      restrict: 'CE',
      link: function($scope, element, attrs){
        var fingerboard;
        fingerboard = d3.music.fingerboard($scope, Style.fingerboard);
        d3.select(element.context).call(fingerboard);
        $scope.$watch(function(){
          fingerboard.attr('note_label', $scope.note_label);
          return fingerboard.update();
        });
        fingerboard.dispatcher.on('mouseover', function(pitch){
          return $scope.$apply(function(){
            return $scope.hover.scale_tonic_pitch = pitch;
          });
        });
        return fingerboard.dispatcher.on('mouseout', function(){
          return $scope.$apply(function(){
            return $scope.hover.scale_tonic_pitch = null;
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
        pitches: '=',
        hover: '='
      },
      transclude: true,
      link: function($scope, element, attrs){
        var constellation;
        constellation = d3.music.pitchConstellation($scope.pitches, Style.scales);
        return d3.select(element.context).call(constellation);
      }
    };
  });
  module.directive('keyboard', function(){
    return {
      restrict: 'CE',
      link: function($scope, element, attrs){
        var keyboard;
        keyboard = d3.music.keyboard($scope, Style.keyboard);
        d3.select(element.context).call(keyboard);
        keyboard.dispatcher.on('tonic', function(tonic_name){
          return $scope.$apply(function(){
            $scope.scale_tonic_name = tonic_name;
            return $scope.scale_tonic_pitch = pitch_name_to_number(tonic_name);
          });
        });
        keyboard.dispatcher.on('mouseover', function(pitch){
          return $scope.$apply(function(){
            return $scope.hover.scale_tonic_pitch = pitch;
          });
        });
        return keyboard.dispatcher.on('mouseout', function(){
          return $scope.$apply(function(){
            return $scope.hover.scale_tonic_pitch = null;
          });
        });
      }
    };
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
