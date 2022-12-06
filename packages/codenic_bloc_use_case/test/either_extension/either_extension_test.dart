import 'package:codenic_bloc_use_case/codenic_bloc_use_case.dart';
import 'package:test/test.dart';

void main() {
  group(
    'Either extension',
    () {
      group(
        'get right or null',
        () {
          test(
            'should return null when left is available',
            () {
              final either = Either<String, int>.left('lorep');

              expect(either.getRightOrNull(), isNull);
            },
          );

          test(
            'should return value when left is null',
            () {
              final either = Either<String, int>.right(1);

              expect(either.getRightOrNull(), 1);
            },
          );
        },
      );

      group(
        'get left or null',
        () {
          test(
            'should return null when right is available',
            () {
              final either = Either<String, int>.right(1);

              expect(either.getLeftOrNull(), isNull);
            },
          );

          test(
            'should return value when right is null',
            () {
              final either = Either<String, int>.left('lorep');

              expect(either.getLeftOrNull(), 'lorep');
            },
          );
        },
      );
    },
  );
}
