import 'dart:io';

/// merges all the pdfs specified in print specs to one pdf.
///
/// Output is path to combined pdf.
Future<String> mergePdfsToOne({
  required List<File> pdfFiles,
  required List<int> counts,
  required String outputPath,
}) async {
  String inputFilesGsString = List.generate(pdfFiles.length, (i) => i)
      .expand((i) => List.generate(counts[i], (j) => pdfFiles[i].absolute.path))
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
