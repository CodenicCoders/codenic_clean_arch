import 'package:codenic_logger/src/map_extension.dart';
import 'package:test/test.dart';

void main() {
  group(
    'toJsonEncodable',
    () {
      test(
        'should encode string',
        () {
          // Assign
          final map = <String, dynamic>{'key': 'value'};

          // Act
          final jsonEncodableMap = map.toJsonEncodable();

          // Assert
          expect(jsonEncodableMap['key'], 'value');
        },
      );

      test(
        'should encode number',
        () {
          // Assign
          final map = <String, dynamic>{'key': 42};

          // Act
          final jsonEncodableMap = map.toJsonEncodable();

          // Assert
          expect(jsonEncodableMap['key'], 42);
        },
      );

      test(
        'should encode boolean',
        () {
          // Assign
          final map = <String, dynamic>{'key': true};

          // Act
          final jsonEncodableMap = map.toJsonEncodable();

          // Assert
          expect(jsonEncodableMap['key'], true);
        },
      );

      test(
        'should encode null',
        () {
          // Assign
          final map = <String, dynamic>{'key': null};

          // Act
          final jsonEncodableMap = map.toJsonEncodable();

          // Assert
          expect(jsonEncodableMap['key'], null);
        },
      );

      test(
        'should encode date',
        () {
          // Assign
          final map = <String, dynamic>{'key': DateTime(2021)};

          // Act
          final jsonEncodableMap = map.toJsonEncodable();

          // Assert
          expect(jsonEncodableMap['key'], '2021-01-01 00:00:00.000');
        },
      );

      test(
        'should encode date in nested map',
        () {
          // Assign
          final map = <String, dynamic>{
            'key': <String, dynamic>{'key': DateTime(2021)},
          };

          // Act
          final jsonEncodableMap = map.toJsonEncodable();

          // Assert
          expect(jsonEncodableMap['key'], {'key': '2021-01-01 00:00:00.000'});
        },
      );

      test(
        'should encode date in list',
        () {
          // Assign
          final map = <String, dynamic>{
            'key': <DateTime>[DateTime(2021)],
          };

          // Act
          final jsonEncodableMap = map.toJsonEncodable();

          // Assert
          expect(jsonEncodableMap['key'], ['2021-01-01 00:00:00.000']);
        },
      );

      test(
        'should encode date in set',
        () {
          // Assign
          final map = <String, dynamic>{
            'key': <DateTime>{DateTime(2021)},
          };

          // Act
          final jsonEncodableMap = map.toJsonEncodable();

          // Assert
          expect(jsonEncodableMap['key'], ['2021-01-01 00:00:00.000']);
        },
      );
    },
  );
}
