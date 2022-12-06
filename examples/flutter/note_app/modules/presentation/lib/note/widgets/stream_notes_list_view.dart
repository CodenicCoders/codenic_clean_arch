import 'package:domain/note/entities/note_entry.dart';
import 'package:domain/note/use_cases/watch_note_entries.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:presentation/note/widgets/note_entry_list_tile.dart';

/// {@template StreamNotesListView}
/// A widget for displaying a list of [NoteEntry]s emitted by the
/// [WatchNoteEntries] use case.
/// {@endtemplate}
class StreamNotesListView extends StatefulWidget {
  /// {@macro StreamNotesListView}
  const StreamNotesListView({super.key});

  @override
  State<StreamNotesListView> createState() => _StreamNotesListViewState();
}

class _StreamNotesListViewState extends State<StreamNotesListView> {
  @override
  Widget build(BuildContext context) {
    final noteEntries = context.select<WatchNoteEntries, List<NoteEntry>>(
      (useCase) => useCase.rightEvent ?? [],
    );

    if (noteEntries.isEmpty) {
      return Container();
    }

    return ListView.builder(
      itemCount: noteEntries.length,
      itemBuilder: (context, index) =>
          NoteEntryListTile(noteEntry: noteEntries[index]),
    );
  }
}
