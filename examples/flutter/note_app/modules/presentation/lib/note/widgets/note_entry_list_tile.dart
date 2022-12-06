import 'package:domain/note/entities/note_entry.dart';
import 'package:flutter/material.dart';
import 'package:presentation/note/pages/note_entry_form_page.dart';

/// {@template NoteEntryListTile}
/// A [ListTile] that displays a [NoteEntry] and navigates to the
/// [NoteEntryFormPage] when tapped.
/// {@endtemplate}
class NoteEntryListTile extends StatelessWidget {
  /// {@macro NoteEntryListTile}
  const NoteEntryListTile({super.key, required this.noteEntry});

  /// The [NoteEntry] to display.
  final NoteEntry noteEntry;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      key: ValueKey(noteEntry.id),
      title: Text(noteEntry.title.isEmpty ? 'No title' : noteEntry.title),
      subtitle:
          Text(noteEntry.content.isEmpty ? 'No content' : noteEntry.content),
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => NoteEntryFormPage(noteEntry: noteEntry),
        ),
      ),
    );
  }
}
