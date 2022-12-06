import 'package:codenic_logger/src/message_log.dart';
import 'package:test/test.dart';

void main() {
  group(
    'Message log',
    () {
      group(
        'copy with',
        () {
          late MessageLog messageLog;

          setUp(() {
            messageLog = MessageLog(
              id: 'lorep',
              message: 'ipsum',
              data: <String, dynamic>{'arcu': true, 'dictum': 42},
            );
          });

          test(
            'create new copy with new values',
            () {
              // Assign

              // Act
              final newMessageLog = messageLog.copyWith(
                id: 'aliquam',
                message: 'fringilla',
                data: <String, dynamic>{'metus': 'ligulia'},
              );

              // Assert
              expect(newMessageLog.id, 'aliquam');
              expect(newMessageLog.message, 'fringilla');
              expect(newMessageLog.data, <String, dynamic>{'metus': 'ligulia'});
            },
          );

          test(
            'create new copy with same values',
            () {
              // Assign

              // Act
              final newMessageLog = messageLog.copyWith();

              // Assert
              expect(newMessageLog.id, 'lorep');
              expect(newMessageLog.message, 'ipsum');
              expect(
                newMessageLog.data,
                <String, dynamic>{'arcu': true, 'dictum': 42},
              );
            },
          );
        },
      );

      group(
        'to string',
        () {
          test(
            'Format to string with complete properties',
            () {
              // Assign
              final messageLog = MessageLog(
                id: 'lorep',
                message: 'ipsum',
                data: <String, dynamic>{'arcu': true, 'dictum': 42},
              );

              // Act
              final str = messageLog.toString();

              // Assert
              expect(
                str,
                'lorep'
                ' – ipsum'
                ' {arcu: true, dictum: 42}',
              );
            },
          );

          test(
            'Format to string with no message property',
            () {
              // Assign
              final messageLog = MessageLog(
                id: 'lorep',
                data: <String, dynamic>{'arcu': true, 'dictum': 42},
              );

              // Act
              final str = messageLog.toString();

              // Assert
              expect(
                str,
                'lorep'
                ' {arcu: true, dictum: 42}',
              );
            },
          );

          test(
            'Format to string with no data property',
            () {
              // Assign
              final messageLog = MessageLog(
                id: 'lorep',
                message: 'ipsum',
              );

              // Act
              final str = messageLog.toString();

              // Assert
              expect(
                str,
                'lorep'
                ' – ipsum',
              );
            },
          );
        },
      );
    },
  );
}
