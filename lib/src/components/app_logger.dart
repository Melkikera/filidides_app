import 'dart:io';
import 'package:flutter/foundation.dart';

class AppLogger {
  static final AppLogger _instance = AppLogger._internal();
  late final File _logFile;

  factory AppLogger() {
    return _instance;
  }

  AppLogger._internal() {
    // Use application documents directory for log file
    String logPath;
    try {
      logPath =
          Directory.systemTemp.path; // fallback if path_provider not available
    } catch (_) {
      logPath = Directory.current.path;
    }
    _logFile = File('$logPath/app.log');
    if (!_logFile.existsSync()) {
      _logFile.createSync(recursive: true);
    }
  }

  void info(String message) => _write('INFO', message);
  void debug(String message) => _write('DEBUG', message);
  void error(String message) => _write('ERROR', message);

  void _write(String level, String message) {
    final logEntry = '[${DateTime.now().toIso8601String()}][$level] $message\n';
    try {
      _logFile.writeAsStringSync(logEntry, mode: FileMode.append);
      if (kDebugMode) {
        print(logEntry);
      }
    } catch (e) {
      if (kDebugMode) {
        print('Logger error: $e');
      }
    }
  }
}
