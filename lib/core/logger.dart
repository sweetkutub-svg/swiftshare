import 'dart:developer' as developer;

enum LogLevel { verbose, debug, info, warning, error }

class AppLogger {
  AppLogger._();
  static final AppLogger _instance = AppLogger._();
  static AppLogger get instance => _instance;

  LogLevel _level = LogLevel.debug;

  LogLevel get level => _level;
  set level(LogLevel l) => _level = l;

  void log(LogLevel level, String message, {Object? error, StackTrace? stackTrace}) {
    if (level.index < _level.index) return;

    final prefix = '[${level.name.toUpperCase()}]';
    final buffer = StringBuffer('$prefix $message');

    if (error != null) {
      buffer.write(' | Error: $error');
    }

    developer.log(buffer.toString(),
      name: 'SwiftShare',
      error: error,
      stackTrace: stackTrace,
    );
  }

  void v(String m, {Object? e, StackTrace? s}) => log(LogLevel.verbose, m, error: e, stackTrace: s);
  void d(String m, {Object? e, StackTrace? s}) => log(LogLevel.debug, m, error: e, stackTrace: s);
  void i(String m, {Object? e, StackTrace? s}) => log(LogLevel.info, m, error: e, stackTrace: s);
  void w(String m, {Object? e, StackTrace? s}) => log(LogLevel.warning, m, error: e, stackTrace: s);
  void e(String m, {Object? e, StackTrace? s}) => log(LogLevel.error, m, error: e, stackTrace: s);
}
