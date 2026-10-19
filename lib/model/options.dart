import 'package:vary_svg/model/enabler.dart';
import 'package:vary_svg/model/placeholder.dart';
import 'package:vary_svg/model/config.dart';

/// Options for the VarySVG tool.
///
/// For parsing user input, use [Config] instead.
class Options {
  /// Path to the template file.
  ///
  /// A file with an svg template.
  final String templatePath;

  /// Path to the records file.
  ///
  /// A file with data records with values to be filled
  /// into the template. Is expected to be a csv file.
  final String recordsPath;

  /// Path to the build output directory.
  ///
  /// Will be created if it does not exist yet.
  final String outDir;

  /// Path to the resource base directory.
  ///
  /// A path to a directory with resources. When specified,
  /// the path values in the value file will be interpreted
  /// relative to this directory.
  ///
  /// This can be useful, when you use a separate directory
  /// to store images or other resources and dont want to
  /// specify the path prefix in every row of the
  /// values file.
  final String? resDir;

  /// Path to a directory to store temporary (intermediate) results.
  ///
  /// This directory will be created if it does not exists.
  final String tmpDir;

  /// Whether to allow overwriting already existing files.
  final bool overwriteFiles;

  final List<Placeholder> placeholders;

  /// A list of enablers that determine whether a record (row) in
  /// the [recordsPath] file will be used to generate a variant.
  ///
  /// If this list is empty or if all enablers return `true`
  /// for this record, then a variant is produced, otherwise not.
  final List<Enabler>? enablers;

  const Options({
    required this.templatePath,
    required this.recordsPath,
    required this.outDir,
    required this.tmpDir,
    required this.placeholders,
    this.enablers,
    this.resDir,
    this.overwriteFiles = false,
  });
}
