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
      const stringMapping = {
        'ENABLED': true,
        'enabled': true,
        'TRUE': true,
        'true': true,
        '1': true,
        'DISABLED': false,
        'disabled': false,
        'FALSE': false,
        'false': false,
        '0': false,
      };
      return stringMapping[caseSensitive ? v : v.toLowerCase()];
    }
    return bool.tryParse(v.toString(), caseSensitive: caseSensitive);
  }

  const Enabler.bool({
    required this.column,
    this.defaultValue = false,
  }) : evaluate = _boolEvaluate;

  factory Enabler.fromJson(Map<String, Object?> json) {
    final defaultValueStr = json['defaultValue'] as String?;
    final defaultValue = defaultValueStr != null
        ? bool.tryParse(defaultValueStr) ?? false
        : false;
    return Enabler.bool(
      column: json['columnName'] as String,
      defaultValue: defaultValue,
    );
  }

  bool isEnabled({
    required Map<String, dynamic> record,
  }) {
    if (!record.containsKey(column)) return defaultValue;
    return evaluate(record[column]) ?? defaultValue;
  }
}
