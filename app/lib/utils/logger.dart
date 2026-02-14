import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart' as log;

class AppLogger {
  AppLogger()
      : _inner = log.Logger(
          filter:
              kReleaseMode ? log.ProductionFilter() : log.DevelopmentFilter(),
          printer: log.PrettyPrinter(
            methodCount: 0,
            errorMethodCount: 8,
            lineLength: 120,
            colors: true,
            printEmojis: true,
            dateTimeFormat: log.DateTimeFormat.onlyTimeAndSinceStart,
          ),
        );

  final log.Logger _inner;

  void d(dynamic message, {Object? error, StackTrace? stackTrace}) {
    _inner.d(message, error: error, stackTrace: stackTrace);
  }

  void i(dynamic message, {Object? error, StackTrace? stackTrace}) {
    _inner.i(message, error: error, stackTrace: stackTrace);
  }

  void w(dynamic message, {Object? error, StackTrace? stackTrace}) {
    _inner.w(message, error: error, stackTrace: stackTrace);
  }

  void e(dynamic message, {Object? error, StackTrace? stackTrace}) {
    _inner.e(message, error: error, stackTrace: stackTrace);
    _inner.d(message, error: error, stackTrace: stackTrace);
  }

  void f(dynamic message, {Object? error, StackTrace? stackTrace}) {
    _inner.f(message, error: error, stackTrace: stackTrace);
    _inner.d(message, error: error, stackTrace: stackTrace);
  }
}

final logger = AppLogger();
