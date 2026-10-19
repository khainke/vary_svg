import 'package:vary_svg/model/options.dart';

enum PlaceholderType {
  /// A placeholder for a text value.
  text(name: "text"),

  /// A placeholder for a file path.
  path(name: "path");

  final String name;

  const PlaceholderType({required this.name});
}

class Placeholder {
  /// Id of the XML Node in the SVG template file.
  ///
  /// This allows very precise replacement / insertion of values into
  /// the template.
  ///
  /// If [id] is specified, it takes priority over [value].
  /// If neither [id] nor [value] is specified, the field might
  /// still be used in [Options.enablers], but will not modify
  /// the template in any way.
  final String? id;

  /// The placeholder value to replace.
  ///
  /// The first occorunce of [value] in a node
  /// matching the [type], will be replaced with a value.
  ///
  /// If [id] is specified, it takes priority over [value].
  final String? value;

  /// Type of the placeholder.
  final PlaceholderType type;

  /// Name of the column in the values file that
  /// holds the values for this placeholder.
  final String column;

  const Placeholder({
    this.id,
    this.value,
    required this.type,
    required this.column,
  });

  const Placeholder.text({
    this.id,
    this.value,
    required this.column,
  }) : type = PlaceholderType.text;

  const Placeholder.path({
    this.id,
    this.value,
    required this.column,
  }) : type = PlaceholderType.path;

  factory Placeholder.fromJson(Map<String, Object?> json) {
    String typeName = json['type'] as String;
    final type = PlaceholderType.values.firstWhere(
      (type) => type.name == typeName,
      orElse: () => PlaceholderType.text,
    );

    return Placeholder(
      value: json['placeholder'] as String?,
      id: json['id'] as String?,
      type: type,
      column: json['column'] as String,
    );
  }
}
