module.exports = (grunt) ->
  grunt.initConfig
    pkg: grunt.file.readJSON('package.json')
    coffee:
      options:
        sourceMap: true
      compile:
        expand: true
        cwd: "coffee"
        src: "*.coffee"
        dest: "build"
        ext: ".js"
    coffeelint:
      app: ['**/*.coffee']
      options:
        max_line_length: { value: 120 }
    jade:
      compile:
        options:
          client: false
          # debug: true
          pretty: true
        files:
          'build/index.html': ['index.jade']
    watch:
      options:
        livereload: true
      jade:
        files: ['index.jade']
        tasks: ['jade']
      scripts:
        files: ['**/*.coffee']
        tasks: ['coffeelint', 'coffee']
        # options:
          # nospawn: true

  grunt.loadNpmTasks 'grunt-coffeelint'
  grunt.loadNpmTasks 'grunt-contrib-coffee'
  grunt.loadNpmTasks 'grunt-contrib-watch'
  grunt.loadNpmTasks 'grunt-contrib-jade'

  grunt.registerTask 'default', ['watch']
