import 'package:vary_svg/json/json_utils.dart';
import 'package:vary_svg/model/enabler.dart';
import 'package:vary_svg/model/placeholder.dart';
import 'package:vary_svg/model/options.dart';

/// Config for the VarySVG tool.
///
/// This is similar to [Options]. But in contrast to [Options],
/// this class is used to define the structure of provided user input,
/// instead of options for the tools processing.
///
/// A [Config] might be defined with more nullable parameters,
/// that are later specified by default values or
/// overwritten by command line options.
///
/// Use this class when reading a user defined config from a file. For
/// controlling a run of the tool use [Options] instead.
class Config {
  /// see [Options.templatePath].
  final String? template;

  /// see [Options.recordsPath].
  final String? records;

  /// see [Options.outDir].
  final String? outDir;

  /// see [Options.resDir].
  final String? resDir;

  /// see [Options.tmpDir].
  final String? tmpDir;

  /// see [Options.overwriteFiles].
  final bool? overwriteFiles;

  /// see [Options.placeholders].
  final List<Placeholder> placeholders;

  /// see [Options.enablers].
  final List<Enabler>? enablers;

  const Config({
    this.template,
    this.records,
    this.outDir,
    this.resDir,
    this.tmpDir,
    required this.placeholders,
    this.enablers,
    this.overwriteFiles,
  });

  factory Config.fromJson(Map<String, Object?> json) {
    final placeholdersJson = json['placeholders'] as List<Map<String, Object?>>;
    final placeholders =
        placeholdersJson.map((e) => Placeholder.fromJson(e)).toList();

    final enablersJson = json['enablers'] as List<Map<String, Object?>>?;
    final enablers = enablersJson?.map((e) => Enabler.fromJson(e)).toList();

    return Config(
      template: json['template'] as String?,
      records: json['records'] as String?,
      resDir: json['resDir'] as String?,
      tmpDir: json['tmpDir'] as String?,
      placeholders: placeholders,
      enablers: enablers,
      overwriteFiles: tryParseJsonBool(json['overwriteFiles'] as String?),
    );
  }
}
