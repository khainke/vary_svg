import 'dart:io';
import 'package:logging/logging.dart';
import 'package:vary_svg/model/options.dart';
import 'package:vary_svg/model/placeholder.dart';
import 'package:xml/xml.dart';
import 'package:xml/xpath.dart';

/// Creates a variant of a template.
///
/// The [template] file is edited according to the [values]
/// and [options]. The result is written to [output].
///
/// Returns the path to the [output] file, after it was written.
Future<File> createVariantSvg({
  required File template,
  required File output,
  required Map<String, String> values,
  required Options options,
  Logger? log,
}) async {
  final document = XmlDocument.parse(await template.readAsString());
  for (final placeholder in options.placeholders) {
    if (!values.containsKey(placeholder.column)) {
      log?.severe(
          'No value for placeholder in column="${placeholder.column}"!');
    }
    final value = values[placeholder.column] ?? '';
    final resourcesDir = (options.resourcesDir != null)
        ? Directory(options.resourcesDir!)
        : Directory.current;

    if (placeholder.type == PlaceholderType.text) {
      if (placeholder.id != null) {
        final node = document.xpath('//*[@id="${placeholder.id}"').firstOrNull;
        if (node == null) {
          log?.severe(
              'Could not find placeholder node! No node in the template with id="${placeholder.id}"!');
          continue;
        }
        node.innerText = value;
      } else if (placeholder.value != null) {
        final node = document
            .xpath(
                '((//text | //tspan | //textPath)[text()="${placeholder.value}"])')
            .firstOrNull;
        if (node == null) {
          log?.severe(
              'Could not find placeholder node! No text node in the template with text="${placeholder.value}"!');
          continue;
        }
        node.innerText = value;
      }
    } else if (placeholder.type == PlaceholderType.path) {
      final fileValue = File.fromUri(resourcesDir.uri.resolve(value));
      if (!await fileValue.exists()) {
        log?.warning('Linked file does not exist: ${fileValue.path}');
      }
      final newValue = '/${fileValue.absolute.path}';

      if (placeholder.id != null) {
        final node = document.xpath('//*[@id="${placeholder.id}"').firstOrNull;
        if (node == null) {
          log?.severe(
              'Could not find placeholder node! No node in the template with id="${placeholder.id}"!');
          continue;
        }
        node.setAttribute('xlink:href', newValue);
        node.setAttribute('href', newValue);
      } else if (placeholder.value != null) {
        final node = document
            .xpath('(//*[@href="xyz" or @xlink:href="${placeholder.value}"])')
            .firstOrNull;
        if (node == null) {
          log?.severe(
              'Could not find placeholder node! No text node in the template with text="${placeholder.value}"!');
          continue;
        }
        node.innerText = value;
      }
    }
  }
  return output;
}
