import 'package:domain/domain.dart';
import 'package:domain/note/entities/note_entry.dart';
import 'package:domain/note/use_cases/create_note_entry.dart';
import 'package:domain/note/use_cases/delete_note_entry.dart';
import 'package:domain/note/use_cases/update_note_entry.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// {@template NoteEntryFormPage}
/// A page that allows the user to create, edit or delete a [NoteEntry].
/// {@endtemplate}
class NoteEntryFormPage extends StatefulWidget {
  const NoteEntryFormPage({super.key, this.noteEntry});

  /// The note entry to edit. If `null`, a new note entry will be created.
  final NoteEntry? noteEntry;

  @override
  State<NoteEntryFormPage> createState() => _NoteEntryFormPageState();
}

class _NoteEntryFormPageState extends State<NoteEntryFormPage> {
  /// The text controller for the note title.
  late final _titleController =
      TextEditingController(text: widget.noteEntry?.title);

  /// The text controller for the note content.
  late final _contentController =
      TextEditingController(text: widget.noteEntry?.content);

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          _saveButton(),
          if (widget.noteEntry != null) _deleteButton(),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 24),
          child: Column(
            children: [_titleField(), _contentField()],
          ),
        ),
      ),
    );
  }

  /// Returns a text field widget for the note title.
  Widget _titleField() => TextFormField(
        controller: _titleController,
        decoration: const InputDecoration(hintText: 'Title'),
      );

  /// Returns a text field widget for the note content.
  Widget _contentField() => TextFormField(
        controller: _contentController,
        maxLines: null,
        decoration: const InputDecoration(
          border: InputBorder.none,
          hintText: 'Write your note here...',
        ),
      );

  /// Creates the note entry if it is new. Otherwise, updates the existing note.
  Widget _saveButton() {
    return IconButton(
      onPressed: () async {
        final Either<Failure, void>? result;

        if (widget.noteEntry == null) {
          result = await context.read<CreateNoteEntry>().run(
                params: CreateNoteEntryParams(
                  title: _titleController.text,
                  content: _contentController.text,
                ),
              );
        } else {
          result = await context.read<UpdateNoteEntry>().run(
                params: UpdateNoteEntryParams(
                  id: widget.noteEntry!.id,
                  title: _titleController.text,
                  content: _contentController.text,
                ),
              );
        }

        if (!mounted) return;

        if (result?.isRight() ?? false) Navigator.of(context).pop();
      },
      icon: const Icon(Icons.save),
    );
  }

  /// Deletes the note entry.
  Widget _deleteButton() {
    return IconButton(
      onPressed: () async {
        final result = await context.read<DeleteNoteEntry>().run(
              params: DeleteNoteEntryParams(id: widget.noteEntry!.id),
            );

        if (!mounted) {
          return;
        }

        if (result?.isRight() ?? false) {
          Navigator.of(context).pop();
        }
      },
      icon: const Icon(Icons.delete),
    );
  }
}
