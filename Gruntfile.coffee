module.exports = (grunt) ->
  grunt.initConfig

    directories:
      build: '<%= directories.dev %>'
      dev: 'build'
      release: 'release'
      ':release':
        build: '<%= directories.release %>'

    clean:
      dev: '<%= directories.dev %>'
      release: '<%= directories.release %>/*'
      target: '<%= directories.build %>/*'

    coffeelint:
      app: ['**/*.coffee', '!**/node_modules/**', '!Gruntfile.coffee']
      gruntfile: 'Gruntfile.coffee'
      options:
        max_line_length:
          value: 120

    connect:
      server:
        options:
          base: '<%= directories.build %>'

    copy:
      app:
        expand: true
        cwd: 'app'
        dest: '<%= directories.build %>'
        src: ['**/*', '!**/*.{coffee,jade,ls,scss,png,jpg,gif}']
        filter: 'isFile'

    githubPages:
      target:
        src: '<%= directories.release %>'

    imagemin:
      app:
        expand: true
        cwd: 'app'
        src: '**/*.{png,jpg,gif}'
        dest: '<%= directories.build %>'

    jade:
      app:
        expand: true
        cwd: 'app'
        src: '**/*.jade'
        dest: '<%= directories.build %>'
        ext: '.html'
      options:
        pretty: true
        ':release':
          pretty: false

    livescript:
      app:
        files:
          '<%= directories.build %>/js/fingerboard.js': 'app/js/**/*.ls'
      options:
        join: true

    sass:
      app:
        expand: true
        cwd: 'app'
        dest: '<%= directories.build %>'
        src: ['css/**.scss']
        ext: '.css'
        filter: 'isFile'
      options:
        sourcemap: true
        ':release':
          sourcemap: false
          style: 'compressed'

    update:
      tasks: ['livescript', 'jade', 'sass', 'copy', 'imagemin']

    watch:
      options:
        livereload: true
      copy:
        files: ['app/**/*', '!app/**/*.{coffee,jade,ls,scss,png,jpg,gif}']
        tasks: ['copy', 'imagemin']
      gruntfile:
        files: 'Gruntfile.coffee'
        tasks: ['coffeelint:gruntfile']
      jade:
        files: ['app/**/*.jade']
        tasks: ['jade']
      sass:
        files: ['app/**/main.scss']
        tasks: ['sass']
      scripts:
        files: ['**/*.ls', '!**/node_modules/**']
        tasks: ['livescript']

  require('load-grunt-tasks')(grunt)

  grunt.registerTask 'context', (contextName) ->
    contextKey = ":#{contextName}"
    installContexts = (obj) ->
      recursiveMerge obj, obj[contextKey] if contextKey of obj
      for k, v of obj
        installContexts v if typeof v == 'object' and not k.match(/^:/)
    recursiveMerge = (target, source) ->
      for k, v of source
        if k of target and typeof v == 'object'
          recursiveMerge target[k], v
        else
          target[k] = v
    installContexts grunt.config.data
    return

  grunt.registerTask 'build', ['clean:target', 'livescript', 'jade', 'sass', 'copy', 'imagemin']
  grunt.registerTask 'build:release', ['context:release', 'build']
  grunt.registerTask 'deploy', ['build:release', 'githubPages:target']
  grunt.registerTask 'default', ['update', 'connect', 'watch']
