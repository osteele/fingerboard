module.exports = (grunt) ->
  grunt.initConfig

    directories:
      dev: 'build'
      release: 'release'
      build: '<%= directories.dev %>'
      build$release: '<%= directories.release %>'

    browserify:
      app:
        files: { '<%= directories.build %>/js/app.js': 'app/**/*.coffee' }
        options:
          transform: ['coffeeify']
          debug: true
          debug$release: false
          fast: true

    clean:
      dev: '<%= directories.dev %>'
      release: '<%= directories.release %>/*'
      target: '<%= directories.build %>/*'

    coffee:
      app:
        files: '<%= directories.build %>/js/app.js': 'app/**/*.coffee'
        options:
          bare: true
          combine: true
          sourceMap: true

    coffeelint:
      app: 'app/**/*.coffee'
      gruntfile: 'Gruntfile.coffee'
      options: max_line_length: value: 120

    connect:
      server: options: base: '<%= directories.build %>'

    copy:
      app:
        expand: true
        cwd: 'app'
        dest: '<%= directories.build %>'
        src: ['**/*', '!**/*.{coffee,jade,ls,scss,png,jpg,gif}']
        filter: 'isFile'

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
        pretty$release: false

    s3:
      options:
        bucket: 'code.osteele.com'
        access: 'public-read'
      release:
        upload: [
          src: 'release/**/*',
          dest: 'fingerboard/'
        ]

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
        _release:
          sourcemap: false
          style: 'compressed'

    update:
      tasks: ['coffee', 'jade', 'sass', 'copy', 'imagemin']

    watch:
      options:
        livereload: true
      gruntfile:
        tasks: ['coffeelint:gruntfile']
      browserify:
        files: ['app/**/*.coffee', 'node_modules/schoen/dist/**/*.{js,coffee}']
      copy: {}
      imagemin: {}
      jade: {}
      sass: {}

  require('load-grunt-tasks')(grunt)

  grunt.registerTask 'build', ['clean:target', 'browserify', 'jade', 'sass', 'copy', 'imagemin']
  grunt.registerTask 'build:release', ['contextualize:release', 'build']
  grunt.registerTask 'deploy', ['build:release', 's3:release', 'cloudflare']
  grunt.registerTask 'default', ['update', 'connect', 'autowatch']
