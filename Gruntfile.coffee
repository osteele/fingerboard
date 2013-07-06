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
    githubPages:
      target:
        src: 'build'
    jade:
      compile:
        options:
          client: false
          pretty: true
        files:
          'build/index.html': 'index.jade'
    sass:
      compile:
        files:
          'build/main.css': 'main.scss'
    watch:
      options:
        livereload: true
      sass:
        files: ['main.scss']
        tasks: ['sass']
      jade:
        files: ['index.jade']
        tasks: ['jade']
      scripts:
        files: ['**/*.coffee']
        tasks: ['coffeelint', 'coffee']

  grunt.loadNpmTasks 'grunt-coffeelint'
  grunt.loadNpmTasks 'grunt-contrib-coffee'
  grunt.loadNpmTasks 'grunt-contrib-jade'
  grunt.loadNpmTasks 'grunt-contrib-sass'
  grunt.loadNpmTasks 'grunt-contrib-watch'
  grunt.loadNpmTasks 'grunt-github-pages'

  grunt.registerTask 'build', ['jade', 'sass', 'coffee']
  grunt.registerTask 'deploy', ['build', 'githubPages:target']
  grunt.registerTask 'default', ['watch']
