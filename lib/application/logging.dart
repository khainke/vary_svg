import 'dart:async';

import 'package:logging/logging.dart';
import 'dart:developer' as dev;

StreamSubscription<LogRecord>? _logListener;
StreamSubscription<LogRecord>? _printListener;

Future<void> configureLogging({
  Level logLevel = Level.ALL,
  Level printLevel = Level.WARNING,
}) async {
  Logger.root.level = Level.ALL;
  _logListener?.cancel();
  _printListener?.cancel();
  _logListener = Logger.root.onRecord.listen((record) {
    dev.log(
      record.message,
      error: record.error,
      level: record.level.value,
      name: record.loggerName,
      sequenceNumber: record.sequenceNumber,
      stackTrace: record.stackTrace,
      time: record.time,
      zone: record.zone,
    );
  });
  if (printLevel < Level.OFF) {
    _printListener = Logger.root.onRecord
        .where((r) => r.level >= printLevel)
        .listen((record) {
      final msg =
          '[${record.loggerName}][${record.level.name}](${record.time.toIso8601String()}): ${record.message}';
      print(msg);
    });
  }
}
