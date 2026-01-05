import 'dart:convert';

/// An extension on [Map] that provides utility methods for working with maps.
extension MapExtension on Map<String, dynamic> {
  /// Converts all non-JSON encodable values in the map to strings recursively.
  Map<String, dynamic> toJsonEncodable() {
    return entries.fold(
      <String, dynamic>{},
      (jsonEncodableMap, entry) {
        final encodableKey = _toJsonEncodableValue(entry.key);
        final encodableValue = _toJsonEncodableValue(entry.value);
        jsonEncodableMap[encodableKey.toString()] = encodableValue;
        return jsonEncodableMap;
      },
    );
  }

  dynamic _toJsonEncodableValue(dynamic value) {
    switch (value) {
      case String():
      case num():
      case bool():
      case null:
        return value;
      case Map<String, dynamic>():
        return value.toJsonEncodable();
      case List():
        return value.map(_toJsonEncodableValue).toList();
      case Set():
        return value.map(_toJsonEncodableValue).toList();
      case DateTime():
        return value.toString();
      default:
        try {
          return jsonEncode(value);
        }
        // We want to turn all non-JSON encodable values to strings.
        // ignore: avoid_catches_without_on_clauses
        catch (_) {
          return value.toString();
        }
    }
  }
}
