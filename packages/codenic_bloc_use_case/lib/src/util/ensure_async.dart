/// Called on state emitting methods to make them truly asynchronous.
///
/// This ensures that states emitted during the first build of a widget will
/// notify the Bloc builders and listeners.
///
/// For more info, see https://github.com/felangel/bloc/issues/1641#issuecomment-963584819
Future<void> ensureAsync() => Future.delayed(Duration.zero);
