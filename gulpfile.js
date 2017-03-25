'use strict'

const coffee = require('gulp-coffee')
const gulp = require('gulp')

gulp.task('clean', () => {
  const del = require('del')
  return del([ 'dist/*' ])
})

gulp.task('build', () => {
  return gulp.src('src/**/*.coffee')
    .pipe(coffee({ bare: true }))
    .pipe(gulp.dest('dist/'))
})

gulp.task('watch', [ 'build' ], () => {
  gulp.watch('src/**/*.coffee', { interval: 500 }, [ 'build' ])
})

gulp.task('default', [ 'clean', 'build', 'watch' ])
