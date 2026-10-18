import 'dart:io';

/// Merges all [pdfFiles] to one pdf file at [outputPath].
///
/// If you want to repeat a page multiple times you may
/// specifiy the amount of time to include a file in [counts].
///
/// Output is path to combined pdf.
Future<String> mergePdfsToOne({
  required List<File> pdfFiles,
  List<int>? counts,
  required String outputPath,
}) async {
  String inputFilesGsString = List.generate(pdfFiles.length, (i) => i)
      .expand((i) => List.generate(
          counts != null ? counts[i] : 1, (j) => pdfFiles[i].absolute.path))
      .map((p) => '"$p"')
      .join(" ");

  await Process.run(
      'gs'
      ' -dNOPAUSE'
      ' -sDEVICE=pdfwrite'
      ' -dAutoRotatePages=/None'
      ' -sOUTPUTFILE="$outputPath"'
      ' -dBATCH'
      ' $inputFilesGsString',
      []);

  return outputPath;
}
