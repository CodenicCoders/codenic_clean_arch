// ignore_for_file: avoid_print

import 'package:bloc/bloc.dart';

class SimpleBlocObserver extends BlocObserver {
  @override
  void onCreate(BlocBase<dynamic> bloc) {
    super.onCreate(bloc);
    print('\nonCreate -- bloc: ${bloc.runtimeType}');
  }

  @override
  void onEvent(Bloc<dynamic, dynamic> bloc, Object? event) {
    super.onEvent(bloc, event);
    print('\nonEvent -- bloc: ${bloc.runtimeType}, event: $event');
  }

  @override
  void onChange(BlocBase<dynamic> bloc, Change<dynamic> change) {
    super.onChange(bloc, change);
    print('\nonChange -- bloc: ${bloc.runtimeType}, change: $change');
  }

  @override
  void onTransition(
    Bloc<dynamic, dynamic> bloc,
    Transition<dynamic, dynamic> transition,
  ) {
    super.onTransition(bloc, transition);
    print(
      '\nonTransition -- bloc: ${bloc.runtimeType}, transition: $transition',
    );
  }

  @override
  void onError(BlocBase<dynamic> bloc, Object error, StackTrace stackTrace) {
    print('\nonError -- bloc: ${bloc.runtimeType}, error: $error');
    super.onError(bloc, error, stackTrace);
  }

  @override
  void onClose(BlocBase<dynamic> bloc) {
    super.onClose(bloc);
    print('onClose -- bloc: ${bloc.runtimeType}');
  }
}
