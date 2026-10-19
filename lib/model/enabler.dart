import 'package:vary_svg/json/json_utils.dart';

/// Evaluates a column in a record to a boolean
/// value, that determines whether this record
/// should be used.
class Enabler {
  /// Name of the column in the record that
  /// holds the values for this placeholder.
  final String column;

  /// Default value, if the record holds no value
  /// for [column] or if it could not be parsed
  /// by [evaluate].
  final bool defaultValue;

  /// How to evaluate the value of the record in
  /// the [column].
  ///
  /// Returns `true` if the record should be used,
  /// `false` if not, and `null` if the [defaultValue]
  /// should be used.
  /// Returns null, when the value could not be
  /// parsed.
  final bool? Function(dynamic value) evaluate;

  const Enabler({
    required this.column,
    required this.defaultValue,
    required this.evaluate,
  });

  /// The default boolean evaluation.
  ///
  /// Its a boolean parser similar to [bool.tryParse], but covers
  /// more truthy and falsy words.
  static bool? _boolEvaluate(
    dynamic v, {
    bool caseSensitive = false,
  }) {
    if (v is bool) {
      return v;
    }
    if (v is String) {
      const Map<String, bool> mappedValues = {
        'false': false,
        'FALSE': false,
        '0': false,
        'no': false,
        'NO': false,
        'disabled': false,
        'DISABLED': false,
        'true': true,
        'TRUE': true,
        '1': true,
        'yes': true,
        'YES': true,
        'enabled': true,
        'ENABLED': true,
      };
      return mappedValues[caseSensitive ? v : v.toLowerCase()];
    }
    return bool.tryParse(v.toString(), caseSensitive: caseSensitive);
  }

  const Enabler.bool({
    required this.column,
    this.defaultValue = false,
  }) : evaluate = _boolEvaluate;

  factory Enabler.fromJson(Map<String, Object?> json) {
    return Enabler.bool(
      column: json['column'] as String,
      defaultValue: tryParseJsonBool(json['default'] as String?) ?? false,
    );
  }

  bool isEnabled({
    required Map<String, dynamic> record,
  }) {
    if (!record.containsKey(column)) return defaultValue;
    return evaluate(record[column]) ?? defaultValue;
  }
}
