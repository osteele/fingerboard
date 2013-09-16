module.exports = (grunt) ->
  grunt.initConfig

    options:
      build_directory: '<%= options.dev_directory %>'
      dev_directory: 'build'
      release_directory: 'release'

    context:
      release:
        options:
          build_directory: '<%= options.release_directory %>'
        coffee:
          options:
            sourceMap: false
        jade:
          options:
            pretty: false
        sass:
          options:
            sourcemap: false
            style: 'compressed'

    livescript:
      app:
        files:
          '<%= options.build_directory %>/js/fingerboard.js': 'app/js/**/*.ls'
        options:
          join: true
          sourceMap: true

    clean:
      dev: '<%= options.dev_directory %>'
      release: '<%= options.release_directory %>/*'

    coffeelint:
      app: ['**/*.coffee', '!**/node_modules/**', '!Gruntfile.coffee']
      gruntfile: 'Gruntfile.coffee'
      options:
        max_line_length:
          value: 120

    connect:
      server:
        options:
          base: '<%= options.build_directory %>'

    copy:
      app:
        expand: true
        cwd: 'app'
        dest: '<%= options.build_directory %>'
        src: ['**/*', '!**/*.{coffee,jade,ls,scss}']
        filter: 'isFile'

    githubPages:
      target:
        src: '<%= options.release_directory %>'

    jade:
      app:
        expand: true
        cwd: 'app'
        src: '**/*.jade'
        dest: '<%= options.build_directory %>'
        ext: '.html'
      options:
        pretty: true

    sass:
      app:
        expand: true
        cwd: 'app'
        dest: '<%= options.build_directory %>'
        src: ['css/**.scss']
        ext: '.css'
        filter: 'isFile'
      options:
        sourcemap: true

    watch:
      options:
        livereload: true
      copy:
        files: ['app/**/*', '!app/**/*.{coffee,jade,ls,scss}']
        tasks: ['copy:debug']
      gruntfile:
        files: 'Gruntfile.coffee'
        tasks: ['coffeelint:gruntfile']
      sass:
        files: ['app/**/main.scss']
        tasks: ['sass']
      jade:
        files: ['app/**/*.jade']
        tasks: ['jade']
      scripts:
        files: ['**/*.ls', '!**/node_modules/**']
        tasks: ['livescript']

  require('load-grunt-tasks')(grunt)

  grunt.registerTask 'context', (context) ->
    copyContext = (obj, prefix='') ->
      for k, v of obj
        if typeof v == 'object'
          copyContext v, prefix + k + '.'
        else
          grunt.config.set(prefix + k, v)
    copyContext grunt.config.get(['context', context])
    return

  grunt.registerTask 'build', ['clean', 'livescript', 'jade', 'sass', 'copy']
  grunt.registerTask 'build:release', ['context:release', 'build']
  grunt.registerTask 'deploy', ['build:release', 'githubPages:target']
  grunt.registerTask 'default', ['build', 'connect', 'watch']
