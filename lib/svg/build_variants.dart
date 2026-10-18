import 'package:vary_svg/model/placeholder.dart';
import 'package:xml/xml.dart';
import 'package:xml/xpath.dart';

/// Fills in all [placeholders] in [template] with [values].
///
/// The [placeholders] in [template] are replaced with the [values]
/// according to their [PlaceholderType].
///
/// If [pathBaseDir] is supplied, values for placeholders
/// with type [PlaceholderType.path] will be interpreted as
/// paths relative to the [pathBaseDir].
///
/// When [strict] mode is enabled, this function will throw a
/// [FormatException] when it cannot locate a suitable XML node
/// in the document for a placeholder in [placeholders], or
/// when it cannot find a replacement value in [values].
/// Otherwise this function, will just continue with the
/// next placeholder.
///
/// For error logging or error handling you can supply the
/// function arguments [onXmlNodeNotFound] and [onValueNotFound].
String fillPlaceholders({
  required String template,
  required List<Placeholder> placeholders,
  required Map<String, dynamic> values,
  String? pathBaseDir,
  bool strict = false,
  XmlNode? Function(Placeholder p)? onXmlNodeNotFound,
  dynamic Function(Placeholder p)? onValueNotFound,
}) {
  final baseDirUri = Uri().resolve(pathBaseDir ?? '');
  final document = XmlDocument.parse(template);
  for (final placeholder in placeholders) {
    // find node in document
    XmlNode? node;
    if (placeholder.id != null) {
      // find node by id
      node = document.xpath('//*[@id="${placeholder.id}"]').firstOrNull;
    } else if (placeholder.value != null) {
      // find node by value
      if (placeholder.type == PlaceholderType.text) {
        // in text nodes
        node = document
            .xpath(
                '((//text | //tspan | //textPath)[text()="${placeholder.value}"])')
            .firstOrNull;
      } else if (placeholder.type == PlaceholderType.path) {
        // in path attributes
        node = document
            .xpath(
                '(//*[@href="${placeholder.value}" or @xlink:href="${placeholder.value}"])')
            .firstOrNull;
      }
    }

    // if node for placeholder could not be found, try fallback
    if (node == null && onXmlNodeNotFound != null) {
      node = onXmlNodeNotFound(placeholder);
    }

    // if node for placeholder still could not be found, either
    // throw an exception (in strict mode) or skip to the next
    if (node == null) {
      if (strict) {
        throw FormatException('No suitable XML node found for a placeholder!');
      } else {
        continue;
      }
    }

    // get replacement value
    dynamic value = values[placeholder.column];
    // if not found, try fallback
    if (value == null && onValueNotFound != null) {
      value = onValueNotFound(placeholder);
    }
    // if still not found, throw or skip
    if (value == null) {
      if (strict) {
        throw FormatException('No value found for a placeholder!');
      } else {
        continue;
      }
    }

    // replace the placeholder in document
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
