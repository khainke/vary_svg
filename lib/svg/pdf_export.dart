import 'dart:io';

/// Converts an .svg file to a .pdf file.
///
/// Output is the path to the generated .pdf file.
///
/// [exportPath] needs to end in '.pdf'.
Future<String> convertSvgToPdf({
  required String svgPath,
  required String exportPath,
  Duration startProcessTimeout = const Duration(seconds: 5),
  Duration runProcessTimeout = const Duration(seconds: 5),
  Duration runProcessTimeoutIncrement = const Duration(seconds: 3),
  Duration killProcessPause = const Duration(seconds: 1),
  int maxNumberRetries = 3,
}) async {
  bool success = false;
  int countTries = 0;
  Duration startTimeout = startProcessTimeout;
  Duration runTimeout = runProcessTimeout;
  Duration killPause = killProcessPause;
  Process? process;
  while (!success && (countTries < (maxNumberRetries + 1))) {
    process = null;
    countTries++;
    try {
      process = await Process.start(
        'inkscape'
        ' --export-area-page'
        ' --export-type=pdf'
        ' --export-dpi=1200'
        ' --export-margin=3'
        ' --export-text-to-path'
        ' --export-filename="$exportPath"'
        ' "$svgPath"',
        [],
      ).timeout(startTimeout);
      final exitCode = await process.exitCode.timeout(runTimeout);
      if (exitCode == 0) success = true;
    } catch (e) {
      success = false;

      print("Error while converting svg to pdf! (Attempt #$countTries)");
      stderr.writeln(e);

      if (process != null) {
        final killRes = process.kill();
        print("Tried to kill process. Return was: $killRes");
        await Future.delayed(killPause);
      }
    }

    if (!success) {
      runTimeout = runTimeout + runProcessTimeoutIncrement;
    }
  }

  return exportPath;
}
