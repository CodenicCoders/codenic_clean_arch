class Failure {
  const Failure(this.message);

  final String message;

  @override
  String toString() => 'Failure: $message';
}
