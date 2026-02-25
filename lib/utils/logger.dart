class Logger {
  static const bool _enableLog = false;

  static void d(String message) {
    if (_enableLog) {
      print('[DEBUG] $message');
    }
  }

  static void i(String message) {
    if (_enableLog) {
      print('[INFO] $message');
    }
  }

  static void e(String message, [Object? error, StackTrace? stackTrace]) {
    if (_enableLog) {
      print('[ERROR] $message');
      if (error != null) print('Error: $error');
      if (stackTrace != null) print('StackTrace: $stackTrace');
    }
  }
}
