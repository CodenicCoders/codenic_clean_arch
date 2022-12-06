import 'package:domain/domain.dart';
import 'package:domain/note/use_cases/create_note_entry.dart';
import 'package:domain/note/use_cases/delete_note_entry.dart';
import 'package:domain/note/use_cases/fetch_note_entries.dart';
import 'package:domain/note/use_cases/update_note_entry.dart';
import 'package:domain/note/use_cases/watch_note_entries.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:presentation/common/snackbar_handler.dart';
import 'package:presentation/note/pages/home_page.dart';
import 'package:presentation/presentation.dart';

/// {@template MainApp}
/// The root widget of the app.
/// {@endtemplate}
class MainApp extends StatelessWidget {
  /// {@macro MainApp}
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      scrollBehavior: const MaterialScrollBehavior(),
      debugShowCheckedModeBanner: false,
      home: const HomePage(),
      // The Blocs are placed here so that they can be accessed by any
      // widgets in the widget tree
      builder: (context, child) => _GlobalBlocs(child: child!),
    );
  }
}

/// {@template _GlobalBlocs}
/// A widget contianing the Bloc providers and listeners for the global Bloc
/// instances.
/// {@endtemplate}
class _GlobalBlocs extends StatelessWidget {
  const _GlobalBlocs({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        // Lazily create the note CRUD use cases
        BlocProvider(
          create: (context) => serviceLocator<CreateNoteEntry>(),
        ),
        BlocProvider(
          create: (context) => serviceLocator<FetchNoteEntries>(),
        ),
        BlocProvider(
          create: (context) => serviceLocator<UpdateNoteEntry>(),
        ),
        BlocProvider(
          create: (context) => serviceLocator<DeleteNoteEntry>(),
        ),
        // Eagerly create and start the [WatchNoteEntries] use
        // case to start streamining the 10 recent note entries
        BlocProvider(
          lazy: false,
          create: (context) => serviceLocator<WatchNoteEntries>()
            ..watch(params: const WatchNoteEntriesParams(limit: 10)),
        ),
      ],
      child: MultiBlocListener(
        listeners: [
          // Set up a listener for the note CRUD use cases
          BlocListener<CreateNoteEntry, RunnerState>(
            listener: (context, createNoteEntryState) => _handleRunnerState(
              context,
              createNoteEntryState,
              'Note entry created',
            ),
          ),
          BlocListener<UpdateNoteEntry, RunnerState>(
            listener: (context, updateNoteEntryState) => _handleRunnerState(
              context,
              updateNoteEntryState,
              'Note entry updated',
            ),
          ),
          BlocListener<DeleteNoteEntry, RunnerState>(
            listener: (context, deleteNoteEntryState) => _handleRunnerState(
              context,
              deleteNoteEntryState,
              'Note entry deleted',
            ),
          ),
        ],
        child: child,
      ),
    );
  }

  /// Handles the given [state].
  ///
  /// If [state] is a [RunFailed] then an error snackbar is displayed.
  /// If [state] is a [RunSuccess] then a success snackbar is displayed and the
  /// note entries pagination is refreshed.
  void _handleRunnerState(
    BuildContext context,
    RunnerState state,
    String successMessage,
  ) {
    if (state is Running) {
      // A state that indicates that the use case is still in progress
      // In this example, do nothing
    } else if (state is RunFailed<Failure>) {
      SnackBarHandler.error(context, state.leftValue.message);
    } else if (state is RunSuccess) {
      SnackBarHandler.info(context, successMessage);

      context
          .read<FetchNoteEntries>()
          .run(params: const FetchNoteEntriesParams(pageToken: 0));
    }
  }
}
