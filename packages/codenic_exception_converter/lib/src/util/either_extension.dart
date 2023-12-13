import 'package:fpdart/fpdart.dart';

/// Extension for the [Either] class.
extension EitherExtension<L, R> on Either<L, R> {
  /// Returns the value of [Right] if available. Otherwise, a [StateError]
  /// is thrown.
  R right() => fold(
        (l) => throw StateError('The value is not a right value: $l'),
        (r) => r,
      );

  /// Returns the value of [Left] if available. Otherwise, a [StateError]
  /// is thrown.
  L left() => fold(
        (l) => l,
        (r) => throw StateError('The value is not a left value: $r'),
      );

  /// Returns the value of [Right] if available. Otherwise, `null` is returned.
  R? rightOrNull() => fold((l) => null, (r) => r);

  /// Returns the value of [Left] if available. Otherwise, `null` is returned.
  L? leftOrNull() => fold((l) => l, (r) => null);
}
