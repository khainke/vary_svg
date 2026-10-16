bool? tryParseJsonBool(
  String? source, {
  bool caseSensitive = true,
}) {
  if (source == null) return null;
  const Map<String, bool> mappedValues = {
    '0': false,
    'no': false,
    'NO': false,
    '1': true,
    'yes': true,
    'YES': true,
  };
  final s = caseSensitive ? source : source.toLowerCase();
  if (mappedValues.containsKey(s)) {
    return mappedValues[s];
  }
  return bool.tryParse(source, caseSensitive: caseSensitive);
}
