module.exports = (grunt) ->
  grunt.initConfig
    pkg: grunt.file.readJSON 'package.json'
    livescript:
      debug:
        expand: true
        cwd: 'app'
        src: '*.ls'
        dest: 'build'
        ext: '.js'
        options:
          sourceMap: true
      release:
        expand: true
        cwd: 'app'
        src: '*.ls'
        dest: 'release'
        ext: '.js'
        options:
          sourceMap: false
    coffeelint:
      app: ['**/*.coffee', '!**/node_modules/**', '!Gruntfile.coffee']
      gruntfile: '!Gruntfile.coffee'
      options:
        max_line_length:
          value: 120
    connect:
      server:
        options:
          base: 'build'
    copy:
      debug:
        expand: true
        cwd: 'app'
        dest: 'build'
        src: ['**/*.html', '**/*.jpg', '**/*.png']
        filter: 'isFile'
      release:
        expand: true
        cwd: 'app'
        dest: 'release'
        src: ['**/*.html', '**/*.jpg', '**/*.png']
        filter: 'isFile'
    githubPages:
      target:
        src: 'release'
    jade:
      debug:
        expand: true
        cwd: 'app'
        src: '**/*.jade'
        dest: 'build'
        ext: '.html'
        options:
          pretty: true
          data:
            cdn_scheme: 'http:'
            debug: true
      release:
        expand: true
        cwd: 'app'
        src: '**/*.jade'
        dest: 'release'
        ext: '.html'
        options:
          data:
            cdn_scheme: ''
            debug: false
    sass:
      debug:
        expand: true
        cwd: 'app'
        dest: 'build'
        src: ['css/**.scss']
        ext: '.css'
        filter: 'isFile'
        options:
          sourcemap: true
      release:
        expand: true
        cwd: 'app'
        dest: 'release'
        src: ['css/**.scss']
        ext: '.css'
        filter: 'isFile'
        options:
          sourcemap: false
          style: 'compressed'
    watch:
      options:
        livereload: true
      copy:
        files: ['app/img/**/*', 'app/**/*.html']
        tasks: ['copy:debug']
      gruntfile:
        files: 'Gruntfile.coffee'
        tasks: ['coffeelint:gruntfile']
      sass:
        files: ['app/**/main.scss']
        tasks: ['sass:debug']
      jade:
        files: ['app/**/*.jade']
        tasks: ['jade:debug']
      scripts:
        files: ['**/*.ls', '!**/node_modules/**']
        tasks: ['livescript:debug']

  grunt.loadNpmTasks 'grunt-coffeelint'
  grunt.loadNpmTasks 'grunt-contrib-coffee'
  grunt.loadNpmTasks 'grunt-contrib-connect'
  grunt.loadNpmTasks 'grunt-contrib-copy'
  grunt.loadNpmTasks 'grunt-contrib-jade'
  grunt.loadNpmTasks 'grunt-contrib-sass'
  grunt.loadNpmTasks 'grunt-contrib-watch'
  grunt.loadNpmTasks 'grunt-github-pages'
  grunt.loadNpmTasks 'grunt-livescript'
  grunt.loadNpmTasks 'grunt-notify'

  grunt.registerTask 'build', ['livescript:debug', 'jade:debug', 'sass:debug', 'copy:debug']
  grunt.registerTask 'build:release', ['livescript:release', 'jade:release', 'sass:release', 'copy:release']
  grunt.registerTask 'deploy', ['build:release', 'githubPages:target']
  grunt.registerTask 'default', ['build', 'connect', 'watch']
