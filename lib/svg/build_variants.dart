import 'package:logging/logging.dart';
import 'package:vary_svg/model/placeholder.dart';
import 'package:xml/xml.dart';
import 'package:xml/xpath.dart';

final Logger _log = Logger('variants.dart');

/// Fills in all [placeholders] in [template] with [values].
///
/// The [placeholders] in [template] are replaced with the [values]
/// according to their [PlaceholderType].
///
/// If [pathBaseDir] is supplied, values for placeholders
/// with type [PlaceholderType.path] will be interpreted as
/// paths relative to the [pathBaseDir].
String fillPlaceholders({
  required String template,
  required List<Placeholder> placeholders,
  required Map<String, dynamic> values,
  String? pathBaseDir,
}) {
  final baseDirUri = Uri().resolve(pathBaseDir ?? '');
  final document = XmlDocument.parse(template);
  for (final placeholder in placeholders) {
    // find node in document
    XmlNode? node;
    if (placeholder.id != null) {
      // find node by id
      node = document.xpath('//*[@id="${placeholder.id}"]').firstOrNull;
      if (node == null) {
        _log.severe(
            'Could not find placeholder node (id:<${placeholder.id}>)!');
      }
    } else if (placeholder.value != null) {
      // find node by value
      if (placeholder.type == PlaceholderType.text) {
        // in text nodes
        node = document
            .xpath(
                '((//text | //tspan | //textPath)[text()="${placeholder.value}"])')
            .firstOrNull;
        if (node == null) {
          _log.severe(
              'Could not find text placeholder node (value:<${placeholder.value}>)!');
        }
      } else if (placeholder.type == PlaceholderType.path) {
        // in path attributes
        node = document
            .xpath(
                '(//*[@href="${placeholder.value}" or @xlink:href="${placeholder.value}"])')
            .firstOrNull;
        if (node == null) {
          _log.severe(
              'Could not find path placeholder node (value:<${placeholder.value}>)!');
        }
      }
    }

    // if placeholder is not of supported type or no node could
    // be found, skip to the next placeholder
    if (node == null) {
      continue;
    }

    // get replacement value
    if (!values.containsKey(placeholder.column)) {
      _log.severe(
          'No value for placeholder in column=<${placeholder.column}>!');
    }
    final value = values[placeholder.column] ?? '';

    // replace in document
    if (placeholder.type == PlaceholderType.text) {
      node.innerText = value;
    } else if (placeholder.type == PlaceholderType.path) {
      final valueUri = baseDirUri.resolve(value);
      final newValue = valueUri.toString();
      node.setAttribute('href', newValue);
      node.setAttribute('xlink:href', newValue);
    }
  }

  return document.toString();
}
