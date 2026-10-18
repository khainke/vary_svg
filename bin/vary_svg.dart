import 'dart:convert';
import 'dart:io';

import 'package:args/args.dart';
import 'package:csv/csv.dart';
import 'package:logging/logging.dart';
import 'package:vary_svg/application/logging.dart';
import 'package:vary_svg/model/config.dart';
import 'package:vary_svg/model/options.dart';
import 'package:vary_svg/model/placeholder.dart';

void main(List<String> args) async {
  // presume success
  exitCode = 0;

  await configureLogging();
  final Logger log = Logger('main');

  final parser = ArgParser();

  parser.addOption(
    'config',
    abbr: 'c',
    help: 'Path to a config JSON file with CLI options for this tool.',
    aliases: ['configPath', 'options'],
    valueHelp: "path/to/config.json",
    defaultsTo: 'config.json',
  );

  parser.addOption(
    'template',
    abbr: 't',
    help: 'Path to the template file.',
    aliases: ['templatePath'],
    valueHelp: "path/to/template.svg",
    defaultsTo: "template.svg",
  );

  parser.addOption(
    'values',
    abbr: 'v',
    help: 'Path to the values file.',
    aliases: ['valuesPath'],
    valueHelp: "path/to/values.csv",
    defaultsTo: "values.csv",
  );

  parser.addOption(
    'outDir',
    abbr: 'o',
    help: 'Path to the build output directory.',
    aliases: ['outputDir'],
    valueHelp: "out/",
    defaultsTo: "out/",
  );

  parser.addOption(
    'resourcesDir',
    help: 'Base directory for resource paths in the values file.',
    aliases: ['resBaseDir'],
    valueHelp: "resources/",
  );

  parser.addOption(
    'tmpDir',
    help: 'Path to a directory to store temporary results. '
        'This directory will be '
        'created if it does not exists.',
    aliases: ['tmp'],
    valueHelp: "tmp/",
    defaultsTo: "tmp/",
  );

  parser.addFlag(
    'keep-tmp',
    help: 'Keep temporary (intermediate) results.',
    defaultsTo: false,
  );

  parser.addFlag(
    'start-from-tmp',
    help: 'Start from already existing (intermediate) results.',
    defaultsTo: false,
  );

  parser.addFlag(
    'export-pdfs',
    help: 'Export variants as pdfs.',
    defaultsTo: false,
  );

  parser.addFlag(
    'merge-pdfs',
    help: 'Export variants merged into a single pdf.',
    defaultsTo: false,
  );

  parser.addFlag(
    'overwrite-files',
    aliases: ['overwrite'],
    help: 'Overwrite already existing files.',
    defaultsTo: false,
  );

  parser.addFlag(
    'help',
    abbr: 'h',
    help: 'Print this usage information.',
    negatable: false,
  );

  final argsParsed = parser.parse(args);

  if (argsParsed['help']) {
    print(parser.usage);
    exit(0);
  }

  final configFile = File(argsParsed['config']);
  Config? config;
  if (await configFile.exists()) {
    final configFileString = await configFile.readAsString();
    config = Config.fromJson(jsonDecode(configFileString));
  }

  final templatePath = argsParsed.wasParsed('template')
      ? argsParsed['template']
      : config?.template ?? argsParsed['template'];

  final valuesPath = argsParsed.wasParsed('values')
      ? argsParsed['values']
      : config?.values ?? argsParsed['values'];

  final outDir = argsParsed.wasParsed('outDir')
      ? argsParsed['outDir']
      : config?.outDir ?? argsParsed['outDir'];

  final tmpDir = argsParsed.wasParsed('tmpDir')
      ? argsParsed['tmpDir']
      : config?.tmpDir ?? argsParsed['tmpDir'];

  List<Placeholder> placeholders = [];
  if (argsParsed.wasParsed('placeholders')) {
    placeholders =
        (jsonDecode(argsParsed['placeholders'] as String) as List<dynamic>)
            .map((e) => Placeholder.fromJson(e))
            .toList();
  } else {
    placeholders = config?.placeholders ?? [];
  }

  List<Placeholder> enablers = [];
  if (argsParsed.wasParsed('enablers')) {
    enablers = (jsonDecode(argsParsed['enablers'] as String) as List<dynamic>)
        .map((e) => Placeholder.fromJson(e))
        .toList();
  } else {
    enablers = config?.enablers ?? [];
  }

  final overwriteFiles = argsParsed.wasParsed('overwriteFiles')
      ? argsParsed['overwriteFiles']
      : config?.overwriteFiles ?? argsParsed['overwriteFiles'];

  final options = Options(
    templatePath: templatePath,
    valuesPath: valuesPath,
    outDir: outDir,
    tmpDir: tmpDir,
    placeholders: placeholders,
    enablers: enablers,
    overwriteFiles: overwriteFiles,
  );

  final templateFile = File(options.templatePath);
  if (!(await templateFile.exists())) {
    log.severe("Template File does not exist!");
    exit(1);
  }

  final valuesFile = File(options.valuesPath);
  if (!(await valuesFile.exists())) {
    log.severe("Values File does not exist!");
    exit(1);
  }

  Directory? resDir;
  if (options.resourcesDir != null) {
    resDir = Directory(options.resourcesDir ?? "./");
    if (!(await resDir.exists())) {
      log.severe("Resources Directory does not exist!");
      exit(1);
    }
  }

  // read values from csv
  final contents = await valuesFile.readAsString();
  final lines = csv.decode(contents);
  final header = lines.firstOrNull;
  if (header == null) {
    log.severe("Values file is empty!");
    exit(1);
  }

  exit(0);
}
