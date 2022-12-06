import 'package:fpdart/fpdart.dart';

/// Extension for [Either] to get the value of [Right] or [Left].
extension EitherExtension<L, R> on Either<L, R> {
  /// Returns the value of [Right] if available. Otherwise, `null` is returned.
  R? getRightOrNull() => fold((l) => null, (r) => r);

  /// Returns the value of [Left] if available. Otherwise, `null` is returned.
  L? getLeftOrNull() => fold((l) => l, (r) => null);
}
