bool? tryParseJsonBool(
  String? source, {
  bool caseSensitive = true,
}) {
  if (source == null) return null;
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
  final s = caseSensitive ? source : source.toLowerCase();
  if (mappedValues.containsKey(s)) {
    return mappedValues[s];
  }
  return bool.tryParse(source, caseSensitive: caseSensitive);
}
