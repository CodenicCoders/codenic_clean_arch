// ignore_for_file: avoid_print

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:codenic_bloc_use_case/codenic_bloc_use_case.dart';

import 'src/failure.dart';
import 'src/simple_bloc_observer.dart';

part 'runner_sample.dart';
part 'watcher_sample.dart';

/// To run, enter the following code:
/// ```
/// dart run example/main.dart
/// ```
///
/// To view the entire code example, see
/// https://github.com/CodenicCoders/codenic_bloc_use_case/tree/master/example

Future<void> main() async {
  Bloc.observer = SimpleBlocObserver();

  print(
    'Enter [0] for Runner, '
    '[1] for Watcher, '
    '[2] for Paginator: ',
  );

  final input = stdin.readLineSync(encoding: utf8);

  switch (input) {
    case '0':
      await runner();
      break;
    case '1':
      await watcher();
      break;
  }
}
