import 'package:flutter/material.dart';
import '../core/logger.dart';

class ErrorHandlers {
  static void setupGlobalErrorHandlers() {
    // Global error handlers (minimal, for crash diagnostics)
    FlutterError.onError = (FlutterErrorDetails details) {
      FlutterError.dumpErrorToConsole(details);
      logger.e(
        '[GlobalError][FlutterError] ${details.exceptionAsString()}',
        error: details.exception,
        stackTrace: details.stack,
      );
    };

    WidgetsBinding.instance.platformDispatcher.onError = (Object error, StackTrace stack) {
      logger.e('[GlobalError][Platform] $error', error: error, stackTrace: stack);
      return true; // prevent silent crash to surface logs
    };
  }
}
