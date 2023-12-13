import 'package:codenic_exception_converter/src/util/either_extension.dart';
import 'package:fpdart/fpdart.dart';
import 'package:test/test.dart';

void main() {
  group(
    'Either extension',
    () {
      group(
        'right',
        () {
          test(
            'should throw an error when right is unavailable',
            () {
              final either = Either<String, int>.left('lorep');

              expect(either.right, throwsA(isA<StateError>()));
            },
          );

          test(
            'should return value when right is available',
            () {
              final either = Either<String, int>.right(1);

              expect(either.right(), 1);
            },
          );
        },
      );

      group(
        'left',
        () {
          test(
            'should throw an error when left is unavailable',
            () {
              final either = Either<String, int>.right(1);

              expect(either.left, throwsA(isA<StateError>()));
            },
          );

          test(
            'should return value when left is available',
            () {
              final either = Either<String, int>.left('lorep');

              expect(either.left(), 'lorep');
            },
          );
        },
      );

      group(
        'right or null',
        () {
          test(
            'should return null when left is available',
            () {
              final either = Either<String, int>.left('lorep');

              expect(either.rightOrNull(), isNull);
            },
          );

          test(
            'should return value when left is null',
            () {
              final either = Either<String, int>.right(1);

              expect(either.rightOrNull(), 1);
            },
          );
        },
      );

      group(
        'left or null',
        () {
          test(
            'should return null when right is available',
            () {
              final either = Either<String, int>.right(1);

              expect(either.leftOrNull(), isNull);
            },
          );

          test(
            'should return value when right is null',
            () {
              final either = Either<String, int>.left('lorep');

              expect(either.leftOrNull(), 'lorep');
            },
          );
        },
      );
    },
  );
}
