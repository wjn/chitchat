module.exports = (grunt) ->

    grunt.initConfig
        pkg: grunt.file.readJSON 'package.json'

        sass:
            dist:
                options:
                    style: 'expanded'
                    cacheLocation: 'public/css/_src/.sass-cache'
                files:
                    'public/css/styles.css': 'public/css/_src/app.scss'


    # load Grunt Tasks Files
    grunt.loadNpmTasks 'grunt-contrib-sass'
    grunt.loadNpmTasks 'grunt-contrib-uglify'

    # Register Grunt Tasks
    grunt.registerTask 'dist-styles', [
        'sass'
        'uglify'
    ]
