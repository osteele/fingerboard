var FingerPositions, FlatNoteNames, Instruments, Pitches, ScaleDegreeNames, Scales, SharpNoteNames, controllers, directives, exports, fingerboardPositionPitch, getPitchName, pitchNameToNumber, pitchNumberToName, pitchToPitchClass,
  __slice = [].slice,
  __indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

angular.module('FingerboardApp', ['ui.bootstrap', 'music.directives', 'unsafe-popover', 'fingerboard.controllers']);

this.Style = {
  fingerboard: {
    stringWdith: 50,
    fretHeight: 50,
    noteRadius: 20
  },
  keyboard: {
    octaves: 2,
    keyWidth: 25,
    keyMargin: 3,
    whiteKeyHeight: 120,
    blackKeyHeight: 90
  },
  scales: {
    constellationRadius: 28,
    pitchRadius: 3
  }
};

controllers = angular.module('fingerboard.controllers', []);

controllers.controller('FingerboardScalesCtrl', function($scope) {
  var k, noteGrid, v;
  for (k in MusicTheory) {
    v = MusicTheory[k];
    window[k] = v;
  }
  $scope.aboutText = $('#about-text').html();
  $scope.scales = Scales;
  $scope.instruments = Instruments;
  $scope.instrument = Instruments.Violin;
  $scope.scale = Scales[0].modes[0];
  $scope.scaleTonicName = 'C';
  $scope.scaleTonicPitch = 0;
  $scope.hover = {
    pitchClasses: null,
    scaleTonicPitch: null
  };
  $scope.handleKey = function(event) {
    var char;
    char = String.fromCharCode(event.charCode).toUpperCase();
    switch (char) {
      case 'A':
      case 'B':
      case 'C':
      case 'D':
      case 'E':
      case 'F':
      case 'G':
        $scope.scaleTonicName = char;
        return $scope.scaleTonicPitch = pitchNameToNumber(char);
      case '#':
      case '+':
        $scope.scaleTonicPitch = ($scope.scaleTonicPitch + 1) % 12;
        return $scope.scaleTonicName = getPitchName($scope.scaleTonicPitch);
      case 'b':
      case '-':
        $scope.scaleTonicPitch = ($scope.scaleTonicPitch - 1 + 12) % 12;
        return $scope.scaleTonicName = getPitchName($scope.scaleTonicPitch);
    }
  };
  $scope.setInstrument = function(instr) {
    if (instr != null) {
      return $scope.instrument = instr;
    }
  };
  $scope.setScale = function(s) {
    var _ref;
    return $scope.scale = ((_ref = s.modes) != null ? _ref[s.modeIndex] : void 0) || s;
  };
  $scope.bodyClassNames = function() {
    var classes, hover, ks, n, scalePitchClasses, scaleTonic, showSharps, _ref, _ref1, _ref2;
    hover = $scope.hover;
    scaleTonic = (_ref = hover.scaleTonicPitch) != null ? _ref : $scope.scaleTonicPitch;
    scalePitchClasses = (_ref1 = (_ref2 = hover.scale) != null ? _ref2.pitchClasses : void 0) != null ? _ref1 : $scope.scale.pitchClasses;
    showSharps = Boolean((FlatNoteNames[pitchToPitchClass(scaleTonic)].length === 1) ^ (FlatNoteNames[pitchToPitchClass(scaleTonic)] === /F/));
    classes = [];
    classes.push((showSharps ? 'hide-flat-labels' : 'hide-sharp-labels'));
    classes = classes.concat((function() {
      var _i, _len, _results;
      _results = [];
      for (_i = 0, _len = scalePitchClasses.length; _i < _len; _i++) {
        n = scalePitchClasses[_i];
        _results.push("scale-includes-relative-pitch-class-" + n);
      }
      return _results;
    })());
    ks = (function() {
      var _i, _len, _results;
      _results = [];
      for (_i = 0, _len = scalePitchClasses.length; _i < _len; _i++) {
        n = scalePitchClasses[_i];
        _results.push("scale-includes-pitch-class-" + (pitchToPitchClass(n + scaleTonic)));
      }
      return _results;
    })();
    classes = classes.concat(ks);
    if (hover.pitch != null) {
      classes.push("hover-note-relative-pitch-class-" + (pitchToPitchClass(hover.pitch - scaleTonic)));
      classes.push("hover-note-pitch-class-" + (pitchToPitchClass(hover.pitch)));
    }
    return classes;
  };
  noteGrid = d3.music.noteGrid($scope, Style.fingerboard, document.querySelector('#fingerboard'));
  d3.select('#scale-notes').call(noteGrid);
  $scope.$watch(function() {
    return noteGrid.update();
  });
  $('#fingerings .btn').click(function() {
    var noteLabelName;
    $('#fingerings .btn').removeClass('btn-default');
    $(this).addClass('btn-default');
    noteLabelName = $(this).text().replace(' ', '_').toLowerCase().replace('fingers', 'fingerings');
    return $scope.$apply(function() {
      return $scope.noteLabel = noteLabelName;
    });
  });
  angular.element(document).bind('touchmove', false);
  return angular.element(document.body).removeClass('loading');
});

FingerPositions = 7;

d3.music || (d3.music = {});

d3.music.keyboard = function(model, style) {
  var attrs, dispatcher, my, octaves, selection, strokeWidth, update;
  octaves = style.octaves;
  strokeWidth = 1;
  attrs = {
    scale: model.scale,
    tonicPitch: model.tonicPitch
  };
  dispatcher = d3.dispatch('focusPitch', 'blurPitch', 'tapPitch');
  selection = null;
  my = function(_selection) {
    var isBlackKey, key_views, keys, root, whiteKeyCount, width, x, _i, _j, _len, _ref, _ref1, _results;
    selection = _selection;
    keys = (function() {
      _results = [];
      for (var _i = 0, _ref = 12 * octaves; 0 <= _ref ? _i < _ref : _i > _ref; 0 <= _ref ? _i++ : _i--){ _results.push(_i); }
      return _results;
    }).apply(this).map(function(pitch) {
      var height, isBlackKey, pitchClass, pitchClassName;
      pitchClass = pitchToPitchClass(pitch);
      isBlackKey = FlatNoteNames[pitchClass].length > 1;
      pitchClassName = getPitchName(pitch, {
        flat: true
      });
      height = (isBlackKey ? style.blackKeyHeight : style.whiteKeyHeight);
      return {
        pitch: pitch,
        pitchClass: pitchClass,
        pitchClassName: pitchClassName,
        isBlackKey: isBlackKey,
        attrs: {
          width: style.keyWidth,
          height: height,
          y: 0
        }
      };
    });
    x = strokeWidth;
    for (_j = 0, _len = keys.length; _j < _len; _j++) {
      _ref1 = keys[_j], attrs = _ref1.attrs, isBlackKey = _ref1.isBlackKey;
      width = attrs.width;
      attrs.x = x;
      if (isBlackKey) {
        attrs.x -= width / 2;
      }
      if (!isBlackKey) {
        x += width + style.keyMargin;
      }
    }
    keys.sort(function(a, b) {
      return a.isBlackKey - b.isBlackKey;
    });
    whiteKeyCount = octaves * 7;
    root = selection.append('svg').attr({
      width: whiteKeyCount * (style.keyWidth + style.keyMargin) - style.keyMargin + 2 * strokeWidth,
      height: style.whiteKeyHeight + 1
    });
    key_views = root.selectAll('.piano-key').data(keys).enter().append('g').attr('class', function(d) {
      return "pitch-" + d.pitch + " pitch-class-" + d.pitchClass;
    }).classed('piano-key', true).classed('black-key', function(d) {
      return d.isBlackKey;
    }).classed('white-key', function(d) {
      return !d.isBlackKey;
    }).on('click', function(d) {
      return dispatcher.tapPitch(d.pitch);
    }).on('mouseover', function(d) {
      return dispatcher.focusPitch(d.pitch);
    }).on('mouseout', function(d) {
      return dispatcher.blurPitch(d.pitch);
    });
    key_views.append('rect').attr({
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
    key_views.append('text').classed('flat-label', true).attr({
      x: function(_arg) {
        var width, x, _ref2;
        _ref2 = _arg.attrs, x = _ref2.x, width = _ref2.width;
        return x + width / 2;
      },
      y: function(_arg) {
        var height, y, _ref2;
        _ref2 = _arg.attrs, y = _ref2.y, height = _ref2.height;
        return y + height - 6;
      }
    }).text(function(d) {
      return FlatNoteNames[d.pitchClass];
    });
    key_views.append('text').classed('sharp-label', true).attr({
      x: function(_arg) {
        var width, x, _ref2;
        _ref2 = _arg.attrs, x = _ref2.x, width = _ref2.width;
        return x + width / 2;
      },
      y: function(_arg) {
        var height, y, _ref2;
        _ref2 = _arg.attrs, y = _ref2.y, height = _ref2.height;
        return y + height - 6;
      }
    }).text(function(d) {
      return SharpNoteNames[d.pitchClass];
    });
    key_views.append('title').text(function(d) {
      return "Click to set the scale tonic to " + d.pitchClassName + ".";
    });
    return update();
  };
  my.on = function() {
    var args;
    args = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
    return dispatcher.on.apply(dispatcher, args);
  };
  my.attr = function(key, value) {
    if (arguments.length < 2) {
      return attrs[key];
    }
    if (attrs[key] !== value) {
      attrs[key] = value;
      update();
    }
    return my;
  };
  update = function() {
    return selection.selectAll('.piano-key').classed('root', function(d) {
      return pitchToPitchClass(d.pitch - model.scaleTonicPitch) === 0;
    }).classed('scale-note', function(d) {
      var _ref;
      return _ref = pitchToPitchClass(d.pitch - model.scaleTonicPitch), __indexOf.call(model.scale.pitchClasses, _ref) >= 0;
    }).classed('fifth', function(d) {
      return pitchToPitchClass(d.pitch - model.scaleTonicPitch) === 7;
    });
  };
  return my;
};

d3.music.pitchConstellation = function(pitchClasses, style) {
  return function(selection) {
    var endpoints, noteRadius, pc_width, r, root;
    r = style.constellationRadius;
    noteRadius = style.pitchRadius;
    pc_width = 2 * (r + noteRadius + 1);
    root = (selection.append('svg')).attr({
      width: pc_width,
      height: pc_width
    }).append('g').attr('transform', "translate(" + (pc_width / 2) + ", " + (pc_width / 2) + ")");
    endpoints = Pitches.map(function(pitchClass) {
      var a, chromatic, x, y;
      a = (pitchClass - 3) * 2 * Math.PI / 12;
      x = Math.cos(a) * r;
      y = Math.sin(a) * r;
      chromatic = __indexOf.call(pitchClasses, pitchClass) < 0;
      return {
        x: x,
        y: y,
        chromatic: chromatic,
        pitchClass: pitchClass
      };
    });
    root.selectAll('line').data(endpoints).enter().append('line').classed('chromatic', function(d) {
      return d.chromatic;
    }).attr('x2', function(d) {
      return d.x;
    }).attr('y2', function(d) {
      return d.y;
    });
    return root.selectAll('circle').data(endpoints).enter().append('circle').attr('class', function(d) {
      return "relative-pitch-class-" + d.pitchClass;
    }).classed('chromatic', function(d) {
      return d.chromatic;
    }).classed('root', function(d) {
      return d.pitchClass === 0;
    }).classed('fifth', function(d) {
      return d.pitchClass === 7;
    }).attr('cx', function(d) {
      return d.x;
    }).attr('cy', function(d) {
      return d.y;
    }).attr('r', noteRadius);
  };
};

d3.music.fingerboard = function(model, style) {
  var attrs, cached, d3Notes, dispatcher, label_sets, my, update, update_instrument;
  label_sets = ['notes', 'fingerings', 'scale-degrees'];
  dispatcher = d3.dispatch('focusPitch', 'blurPitch', 'tapPitch');
  attrs = {
    instrument: model.instrument,
    noteLabel: null,
    scale: model.scale,
    tonicPitch: model.scaleTonicPitch
  };
  cached = {};
  d3Notes = null;
  my = function(selection) {
    var finger_positions, fret_number, instrument, noteLabels, pitch, root, string_count, string_number, text_y, _i, _j, _k, _results;
    instrument = attrs.instrument;
    string_count = instrument.stringPitches.length;
    finger_positions = [];
    for (string_number = _i = 0; 0 <= string_count ? _i < string_count : _i > string_count; string_number = 0 <= string_count ? ++_i : --_i) {
      for (fret_number = _j = 0; 0 <= FingerPositions ? _j <= FingerPositions : _j >= FingerPositions; fret_number = 0 <= FingerPositions ? ++_j : --_j) {
        pitch = fingerboardPositionPitch({
          instrument: instrument,
          string_number: string_number,
          fret_number: fret_number
        });
        finger_positions.push({
          string_number: string_number,
          fret_number: fret_number,
          pitch: pitch,
          pitchClass: pitchToPitchClass(pitch),
          fingering_name: String(Math.ceil(fret_number / 2))
        });
      }
    }
    root = selection.append('svg').attr({
      width: string_count * style.stringWdith
    }).attr({
      height: (1 + FingerPositions) * style.fretHeight
    });
    root.append('line').classed('nut', true).attr({
      x2: string_count * style.stringWdith,
      transform: "translate(0, " + (style.fretHeight - 5) + ")"
    });
    root.selectAll('.string').data((function() {
      _results = [];
      for (var _k = 0; 0 <= string_count ? _k < string_count : _k > string_count; 0 <= string_count ? _k++ : _k--){ _results.push(_k); }
      return _results;
    }).apply(this)).enter().append('line').classed('string', true).attr({
      y1: style.fretHeight * 0.5,
      y2: (1 + FingerPositions) * style.fretHeight,
      transform: function(d) {
        return "translate(" + ((d + 0.5) * style.stringWdith) + ", 0)";
      }
    });
    d3Notes = root.selectAll('.finger-position').data(finger_positions).enter().append('g').classed('finger-position', true).attr({
      transform: function(_arg) {
        var dx, dy, fret_number, string_number;
        string_number = _arg.string_number, fret_number = _arg.fret_number;
        dx = (string_number + 0.5) * style.stringWdith;
        dy = fret_number * style.fretHeight + style.noteRadius + 1;
        return "translate(" + dx + ", " + dy + ")";
      }
    }).on('click', function(d) {
      return dispatcher.tapPitch(d.pitch);
    }).on('mouseover', function(d) {
      return dispatcher.focusPitch(d.pitch);
    }).on('mouseout', function(d) {
      return dispatcher.blurPitch(d.pitch);
    });
    d3Notes.append('circle').attr({
      r: style.noteRadius
    });
    d3Notes.append('title');
    text_y = 7;
    noteLabels = d3Notes.append('text').classed('note', true).attr({
      y: text_y
    });
    noteLabels.append('tspan').classed('base', true);
    noteLabels.append('tspan').classed('accidental', true).classed('flat', true).classed('flat-label', true);
    noteLabels.append('tspan').classed('accidental', true).classed('sharp', true).classed('sharp-label', true);
    d3Notes.append('text').classed('fingering', true).attr({
      y: text_y
    }).text(function(d) {
      return d.fingering_name;
    });
    d3Notes.append('text').classed('scale-degree', true).attr({
      y: text_y
    });
    return update();
  };
  my.on = function() {
    var args;
    args = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
    return dispatcher.on.apply(dispatcher, args);
  };
  my.attr = function(key, value) {
    if (!(key in attrs)) {
      throw new Error("Unknown key " + key);
    }
    if (!(arguments.length > 1)) {
      return attrs[key];
    }
    if (attrs[key] !== value) {
      attrs[key] = value;
      update();
    }
    return my;
  };
  update = function() {
    var k, labels, scale, scale_relative_pitch_classes, tonicPitch, visible, _i, _len;
    if (cached.instrument === attrs.instrument && cached.scale === attrs.scale && cached.tonic === attrs.tonic) {
      return;
    }
    update_instrument();
    scale = cached.scale = attrs.scale;
    tonicPitch = cached.tonic = attrs.tonicPitch;
    scale_relative_pitch_classes = scale.pitchClasses;
    attrs.noteLabel || (attrs.noteLabel = label_sets[0]);
    for (_i = 0, _len = label_sets.length; _i < _len; _i++) {
      k = label_sets[_i];
      visible = k === attrs.noteLabel.replace(/_/g, '-');
      labels = d3.select('#fingerboard').selectAll('.' + k.replace(/s$/, ''));
      labels.attr('visibility', visible ? 'inherit' : 'hidden');
    }
    d3Notes.each(function(note) {
      var pitch;
      pitch = note.pitch;
      return note.relativePitchClass = pitchToPitchClass(pitch - tonicPitch);
    });
    d3Notes.attr('class', function(d) {
      return "pitch-class-" + d.pitchClass + " relative-pitch-class-" + d.relativePitchClass;
    }).classed('finger-position', true).classed('scale', function(d) {
      var _ref;
      return _ref = d.relativePitchClass, __indexOf.call(scale_relative_pitch_classes, _ref) >= 0;
    }).classed('chromatic', function(d) {
      var _ref;
      return _ref = d.relativePitchClass, __indexOf.call(scale_relative_pitch_classes, _ref) < 0;
    }).select('.scale-degree').text("").text(function(d) {
      return ScaleDegreeNames[d.relativePitchClass];
    });
    return d3Notes.each(function(_arg) {
      var noteLabels, pitch;
      pitch = _arg.pitch;
      return noteLabels = d3.select(this);
    });
  };
  update_instrument = function() {
    var instrument, pitchNameOptions, scaleTonicName, selectPitchNameComponent, stringPitches;
    if (cached.instrument === attrs.instrument) {
      return;
    }
    instrument = cached.instrument = attrs.instrument;
    scaleTonicName = attrs.scaleTonicName;
    stringPitches = instrument.stringPitches;
    d3Notes.each(function(note) {
      var fret_number, string_number;
      string_number = note.string_number, fret_number = note.fret_number;
      note.pitch = fingerboardPositionPitch({
        instrument: instrument,
        string_number: string_number,
        fret_number: fret_number
      });
      return note.pitchClass = pitchToPitchClass(note.pitch);
    });
    pitchNameOptions = scaleTonicName === /\u266D/ ? {
      flat: true
    } : {
      sharp: true
    };
    selectPitchNameComponent = function(component) {
      return function(_arg) {
        var name, pitch, pitchClass;
        pitch = _arg.pitch, pitchClass = _arg.pitchClass;
        name = getPitchName(pitch, pitchNameOptions);
        switch (component) {
          case 'base':
            return name.replace(/[^\w]/, '');
          case 'accidental':
            return name.replace(/[\w]/, '');
          case 'flat':
            return FlatNoteNames[pitchClass].slice(1);
          case 'sharp':
            return SharpNoteNames[pitchClass].slice(1);
        }
      };
    };
    d3Notes.each(function(note) {
      var fret_number, noteLabels, pitch, string_number;
      string_number = note.string_number, fret_number = note.fret_number, pitch = note.pitch;
      noteLabels = d3.select(this).select('.note');
      noteLabels.select('.base').text(selectPitchNameComponent('base'));
      noteLabels.select('.flat').text(selectPitchNameComponent('flat'));
      return noteLabels.select('.sharp').text(selectPitchNameComponent('sharp'));
    });
    return d3Notes.select('title').text(function(d) {
      return "Click to set the scale tonic to " + FlatNoteNames[d.pitchClass] + ".";
    });
  };
  return my;
};

d3.music.noteGrid = function(model, style, referenceElement) {
  var cached_offset, column_count, my, row_count, selection, update_note_colors, update_position, _ref, _ref1;
  column_count = (_ref = style.columns) != null ? _ref : 12 * 5;
  row_count = (_ref1 = style.rows) != null ? _ref1 : 12;
  cached_offset = null;
  selection = null;
  my = function(_selection) {
    var column, degree, degree_groups, note, note_views, notes, root, row, _i, _j, _len, _len1;
    selection = _selection;
    notes = _.flatten((function() {
      var _i, _results;
      _results = [];
      for (row = _i = 0; 0 <= row_count ? _i < row_count : _i > row_count; row = 0 <= row_count ? ++_i : --_i) {
        _results.push((function() {
          var _j, _results1;
          _results1 = [];
          for (column = _j = 0; 0 <= column_count ? _j < column_count : _j > column_count; column = 0 <= column_count ? ++_j : --_j) {
            _results1.push({
              column: column,
              row: row
            });
          }
          return _results1;
        })());
      }
      return _results;
    })(), true);
    for (_i = 0, _len = notes.length; _i < _len; _i++) {
      note = notes[_i];
      note.relativePitchClass = pitchToPitchClass(note.column * 7 + note.row);
    }
    degree_groups = d3.nest().key(function(d) {
      return d.relativePitchClass;
    }).entries(notes);
    for (_j = 0, _len1 = degree_groups.length; _j < _len1; _j++) {
      degree = degree_groups[_j];
      degree.relativePitchClass = Number(degree.key);
    }
    root = selection.append('svg').attr({
      width: column_count * style.stringWdith,
      height: row_count * style.fretHeight
    });
    note_views = root.selectAll('.scale-degree').data(degree_groups).enter().append('g').classed('scale-degree', true).selectAll('.note').data(function(d) {
      return d.values;
    }).enter().append('g').classed('note', true).attr('transform', function(_arg) {
      var column, row, x, y;
      column = _arg.column, row = _arg.row;
      x = (column + 0.5) * style.stringWdith;
      y = row * style.fretHeight + style.noteRadius;
      return "translate(" + x + ", " + y + ")";
    });
    note_views.append('circle').attr({
      r: style.noteRadius
    });
    note_views.append('text').attr({
      y: 7
    }).text(function(d) {
      return ScaleDegreeNames[d.relativePitchClass];
    });
    return setTimeout((function() {
      return selection.classed('animate', true);
    }), 1);
  };
  my.update = function() {
    update_note_colors();
    return update_position();
  };
  update_note_colors = function() {
    var scale_pitch_classes;
    scale_pitch_classes = model.scale.pitchClasses;
    return selection.selectAll('.scale-degree').classed('chromatic', function(_arg) {
      var relativePitchClass;
      relativePitchClass = _arg.relativePitchClass;
      return __indexOf.call(scale_pitch_classes, relativePitchClass) < 0;
    }).classed('tonic', function(_arg) {
      var relativePitchClass;
      relativePitchClass = _arg.relativePitchClass;
      return __indexOf.call(scale_pitch_classes, relativePitchClass) >= 0 && relativePitchClass === 0;
    }).classed('fifth', function(_arg) {
      var relativePitchClass;
      relativePitchClass = _arg.relativePitchClass;
      return __indexOf.call(scale_pitch_classes, relativePitchClass) >= 0 && relativePitchClass === 7;
    });
  };
  update_position = function() {
    var bass_pitch, offset, pos, scale_tonic;
    scale_tonic = model.scaleTonicPitch;
    bass_pitch = model.instrument.stringPitches[0];
    offset = style.stringWdith * pitchToPitchClass((scale_tonic - bass_pitch) * 5);
    if (offset === cached_offset) {
      return;
    }
    cached_offset = offset;
    pos = $(referenceElement).offset();
    return selection.each(function() {
      return $(this).css({
        left: pos.left - offset + 1,
        top: pos.top + 1
      });
    });
  };
  return my;
};

directives = angular.module('music.directives', []);

directives.directive('fingerboard', function() {
  return {
    restrict: 'CE',
    link: function(scope, element, attrs) {
      var fingerboard;
      fingerboard = d3.music.fingerboard(scope, Style.fingerboard);
      d3.select(element[0]).call(fingerboard);
      scope.$watch(function() {
        fingerboard.attr('noteLabel', scope.noteLabel);
        fingerboard.attr('scale', scope.scale);
        fingerboard.attr('instrument', scope.instrument);
        return fingerboard.attr('tonicPitch', scope.scaleTonicPitch);
      });
      fingerboard.on('tapPitch', function(pitch) {
        return scope.$apply(function() {
          scope.scaleTonicName = getPitchName(pitch);
          return scope.scaleTonicPitch = pitch;
        });
      });
      fingerboard.on('focusPitch', function(pitch) {
        return scope.$apply(function() {
          return scope.hover.pitch = pitch;
        });
      });
      return fingerboard.on('blurPitch', function() {
        return scope.$apply(function() {
          return scope.hover.pitch = null;
        });
      });
    }
  };
});

directives.directive('pitchConstellation', function() {
  return {
    restrict: 'CE',
    replace: true,
    scope: {
      pitchClasses: '=',
      pitches: '=',
      hover: '='
    },
    transclude: true,
    link: function(scope, element, attrs) {
      var constellation;
      constellation = d3.music.pitchConstellation(scope.pitches, Style.scales);
      return d3.select(element[0]).call(constellation);
    }
  };
});

directives.directive('keyboard', function() {
  return {
    restrict: 'CE',
    link: function(scope, element, attrs) {
      var keyboard;
      keyboard = d3.music.keyboard(scope, Style.keyboard);
      d3.select(element[0]).call(keyboard);
      scope.$watch(function() {
        keyboard.attr('tonicPitch', scope.scaleTonicPitch);
        return keyboard.attr('scale', scope.scale);
      });
      keyboard.on('tapPitch', function(pitch) {
        return scope.$apply(function() {
          scope.scaleTonicName = getPitchName(pitch);
          return scope.scaleTonicPitch = pitch;
        });
      });
      keyboard.on('focusPitch', function(pitch) {
        return scope.$apply(function() {
          scope.hover.pitch = pitch;
          return scope.hover.scaleTonicPitch = pitch;
        });
      });
      return keyboard.on('blurPitch', function() {
        return scope.$apply(function() {
          scope.hover.pitch = null;
          return scope.hover.scaleTonicPitch = null;
        });
      });
    }
  };
});

angular.module('unsafe-popover', []).directive('unsafePopoverPopup', function() {
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
    templateUrl: 'templates/popover.html'
  };
}).directive('unsafePopover', function($tooltip) {
  return $tooltip('unsafePopover', 'popover', 'click');
});

SharpNoteNames = 'C C# D D# E F F# G G# A A# B'.split(/\s/).map(function(d) {
  return d.replace(/#/, '\u266F');
});

FlatNoteNames = 'C Db D Eb E F Gb G Ab A Bb B'.split(/\s/).map(function(d) {
  return d.replace(/b/, '\u266D');
});

ScaleDegreeNames = '1 b2 2 b3 3 4 b5 5 b6 6 b7 7'.split(/\s/).map(function(d) {
  return d.replace(/(\d)/, '$1\u0302').replace(/b/, '\u266D');
});

Pitches = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11];

pitchNameToNumber = function(pitchName) {
  var pitch;
  pitch = FlatNoteNames.indexOf(pitchName);
  if (!(pitch >= 0)) {
    pitch = SharpNoteNames.indexOf(pitchName);
  }
  return pitch;
};

pitchNumberToName = function(pitch_number) {
  var pitch;
  pitch = pitchToPitchClass(pitch_number);
  return SharpNoteNames.indexOf(pitch) || FlatNoteNames.indexOf(pitch);
};

pitchToPitchClass = function(pitch) {
  return (pitch % 12 + 12) % 12;
};

getPitchName = function(pitch, options) {
  var flatName, name, pitchClass, sharpName;
  if (options == null) {
    options = {};
  }
  pitchClass = pitchToPitchClass(pitch);
  flatName = FlatNoteNames[pitchClass];
  sharpName = SharpNoteNames[pitchClass];
  name = options.sharp ? sharpName : flatName;
  if (options.flat && options.sharp && flatName !== sharpName) {
    name = "" + flatName + "/\n" + sharpName;
  }
  return name;
};

Scales = [
  {
    name: 'Diatonic Major',
    pitchClasses: [0, 2, 4, 5, 7, 9, 11],
    modeNames: 'Ionian Dorian Phrygian Lydian Mixolydian Aeolian Locrian'.split(/\s/)
  }, {
    name: 'Natural Minor',
    pitchClasses: [0, 2, 3, 5, 7, 8, 10],
    parentName: 'Diatonic Major'
  }, {
    name: 'Major Pentatonic',
    pitchClasses: [0, 2, 4, 7, 9],
    modeNames: ['Major Pentatonic', 'Suspended Pentatonic', 'Man Gong', 'Ritusen', 'Minor Pentatonic']
  }, {
    name: 'Minor Pentatonic',
    pitchClasses: [0, 3, 5, 7, 10],
    parentName: 'Major Pentatonic'
  }, {
    name: 'Melodic Minor',
    pitchClasses: [0, 2, 3, 5, 7, 9, 11],
    modeNames: ['Jazz Minor', 'Dorian b2', 'Lydian Augmented', 'Lydian Dominant', 'Mixolydian b6', 'Semilocrian', 'Superlocrian']
  }, {
    name: 'Harmonic Minor',
    pitchClasses: [0, 2, 3, 5, 7, 8, 11],
    modeNames: ['Harmonic Minor', 'Locrian #6', 'Ionian Augmented', 'Romanian', 'Phrygian Dominant', 'Lydian #2', 'Ultralocrian']
  }, {
    name: 'Blues',
    pitchClasses: [0, 3, 5, 6, 7, 10]
  }, {
    name: 'Freygish',
    pitchClasses: [0, 1, 4, 5, 7, 8, 10]
  }, {
    name: 'Whole Tone',
    pitchClasses: [0, 2, 4, 6, 8, 10]
  }, {
    name: 'Octatonic',
    pitchClasses: [0, 2, 3, 5, 6, 8, 9, 11]
  }
];

(function() {
  var modeNames, name, parent, parentName, pitchClasses, rotate, scale, _i, _j, _k, _len, _len1, _ref, _results, _results1;
  for (_i = 0, _len = Scales.length; _i < _len; _i++) {
    scale = Scales[_i];
    Scales[scale.name] = scale;
  }
  rotate = function(pitchClasses, i) {
    i %= pitchClasses.length;
    pitchClasses = pitchClasses.slice(i).concat(pitchClasses.slice(0, i));
    return pitchClasses.map(function(pc) {
      return pitchToPitchClass(pc - pitchClasses[0]);
    });
  };
  _results = [];
  for (_j = 0, _len1 = Scales.length; _j < _len1; _j++) {
    scale = Scales[_j];
    name = scale.name, modeNames = scale.modeNames, parentName = scale.parentName, pitchClasses = scale.pitchClasses;
    parent = scale.parent = Scales[parentName];
    modeNames || (modeNames = parent != null ? parent.modeNames : void 0);
    if (modeNames != null) {
      scale.modeIndex = 0;
      if (parent != null) {
        scale.modeIndex = (function() {
          _results1 = [];
          for (var _k = 0, _ref = pitchClasses.length; 0 <= _ref ? _k < _ref : _k > _ref; 0 <= _ref ? _k++ : _k--){ _results1.push(_k); }
          return _results1;
        }).apply(this).filter(function(i) {
          return rotate(parent.pitchClasses, i).join(',') === pitchClasses.join(',');
        })[0];
      }
      _results.push(scale.modes = modeNames.map(function(name, i) {
        return {
          name: name.replace(/#/, '\u266F').replace(/\bb(\d)/, '\u266D$1'),
          pitchClasses: rotate((parent != null ? parent.pitchClasses : void 0) || pitchClasses, i),
          parent: scale
        };
      }));
    } else {
      _results.push(void 0);
    }
  }
  return _results;
})();

Instruments = [
  {
    name: 'Violin',
    stringPitches: [7, 14, 21, 28]
  }, {
    name: 'Viola',
    stringPitches: [0, 7, 14, 21]
  }, {
    name: 'Cello',
    stringPitches: [0, 7, 14, 21]
  }
];

(function() {
  var instrument, _i, _len, _results;
  _results = [];
  for (_i = 0, _len = Instruments.length; _i < _len; _i++) {
    instrument = Instruments[_i];
    _results.push(Instruments[instrument.name] = instrument);
  }
  return _results;
})();

fingerboardPositionPitch = function(_arg) {
  var fret_number, instrument, string_number;
  instrument = _arg.instrument, string_number = _arg.string_number, fret_number = _arg.fret_number;
  return instrument.stringPitches[string_number] + fret_number;
};

exports = {
  fingerboardPositionPitch: fingerboardPositionPitch,
  FlatNoteNames: FlatNoteNames,
  Instruments: Instruments,
  getPitchName: getPitchName,
  pitchToPitchClass: pitchToPitchClass,
  Pitches: Pitches,
  ScaleDegreeNames: ScaleDegreeNames,
  Scales: Scales,
  SharpNoteNames: SharpNoteNames
};

if ((typeof module !== "undefined" && module !== null ? module.exports : void 0) != null) {
  module.exports = exports;
} else {
  this.MusicTheory = exports;
}

/*
//@ sourceMappingURL=app.js.map
*/