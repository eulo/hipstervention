var gulp = require('gulp');
var args = require('yargs').argv;
var plugins = require('gulp-load-plugins')();
var runSequence = require('run-sequence');

var paths = {
  scripts: ['assets/src/coffeescript/**/*.coffee', 'assets/src/coffeescript/templates/*.hbs'],
  styles: ['assets/src/scss/**/*.scss']
};

args.env = 'prod';
var isProd = args.env === 'prod';
if(!isProd) {
  args.env = 'prod';
}
plugins.util.log("Build Environment: " + plugins.util.colors.yellow(args.env.toUpperCase()));

gulp.task('clean_styles', function() {
	return gulp.src(plugins.if(isProd,'./assets/dist/css','./assets/css'), {read: false})
		.pipe(plugins.rimraf());
});

gulp.task('clean_scripts', function() {
	return gulp.src(plugins.if(isProd,'./assets/dist/js','./assets/js'), {read: false})
		.pipe(plugins.rimraf());
});

gulp.task('compile_scripts', function() {
  return gulp.src('assets/src/coffeescript/index.coffee', { read: false }) //paths.scripts
    .pipe(plugins.browserify({
      extensions: ['.coffee', '.hbs']
    }).on('error', plugins.util.log))
    .pipe(plugins.concat('app.js'))
    .pipe(plugins.if(isProd, plugins.uglify()))
    .pipe(plugins.if(isProd, gulp.dest('assets/dist/js'), gulp.dest('assets/js')));
});


gulp.task('compile_styles', function() {
  return gulp.src(paths.styles)
    .pipe(plugins.sass({
      errLogToConsole: true
    }))
    .pipe(plugins.if(isProd,plugins.minifyCss()))
    .pipe(plugins.if(isProd, gulp.dest('assets/dist/css'), gulp.dest('assets/css')));
});

gulp.task('styles_watch', function() {
  gulp.watch(paths.styles,['compile_styles']);
});

gulp.task('scripts_watch', function() {
  gulp.watch(paths.scripts,['compile_scripts']);
});


gulp.task('build_scripts', function() {
  runSequence('clean_scripts', 'compile_scripts');
});

gulp.task('build_styles', function() {
  runSequence('clean_styles', 'compile_styles');
});

gulp.task('watch', function() {
  runSequence('clean_styles', 'clean_scripts','compile_styles','compile_scripts', ['scripts_watch','styles_watch']);
});

gulp.task('deploy', function() {
  runSequence('build_scripts','build_styles');
});
