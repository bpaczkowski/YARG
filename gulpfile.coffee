gulp = require 'gulp'
gls = require 'gulp-live-server'
gulpsync = require('gulp-sync')(gulp)
clean = require 'gulp-clean'
gutil = require 'gulp-util'
size = require 'gulp-size'
webpack = require 'webpack'
webpackConfig = require './webpack.config.js'
webpackProductionConfig = require './webpack.production.config.js'

gulp.task('clean', ->
  gulp.src('public', {
    read: false
  })
  .pipe(clean())
)

gulp.task('copy-assets', ->
  gulp.src('assets/**')
  .pipe(gulp.dest('public'))
  .pipe(size())
)

gulp.task 'webpack:build', (callback) ->
  webpack webpackProductionConfig, (err, stats) ->
    throw new gutil.PluginError('webpack:build', err) if err
    gutil.log '[webpack:build]', stats.toString colors: true
    callback()
    return
  return

gulp.task 'webpack:build-dev', (callback) ->
  webpack webpackConfig, (err, stats) ->
    throw new gutil.PluginError('webpack:build-dev', err) if err
    gutil.log '[webpack:build-dev]', stats.toString
      colors: true
      chunks: false
    callback()
    return
  return

gulp.task 'default', ['watch']

gulp.task 'build', gulpsync.sync ['clean', ['webpack:build', 'copy-assets']]
gulp.task 'builddev', ['webpack:build-dev', 'copy-assets']

gulp.task 'serve', gulpsync.sync(['clean', ['webpack:build', 'copy-assets']]), ->
  server = gls.static('./public/')
  server.start()

gulp.task 'watch', ['webpack:build-dev', 'copy-assets'], ->
  server = gls.static('./public/')
  server.start()

  gulp.watch 'public/**', (file) ->
    server.notify.apply server, [file]

  gulp.watch('app/**', ['webpack:build-dev'])
  gulp.watch('assets/**', ['copy-assets'])
