import 'dart:async';

import 'package:codenic_bloc_use_case/codenic_bloc_use_case.dart';
import 'package:codenic_exception_converter/codenic_exception_converter.dart';
import 'package:domain/note/entities/note_entry.dart';
import 'package:domain/note/repositories/note_repository.dart';

/// {@template DeleteNoteEntryParams}
/// The parameters for the [DeleteNoteEntry] use case.
/// {@endtemplate}
class DeleteNoteEntryParams with EquatableMixin {
  /// {@macro DeleteNoteEntryParams}
  const DeleteNoteEntryParams({required this.id});

  /// The ID of the [NoteEntry] to delete.
  final String id;

  @override
  List<Object?> get props => [id];
}

/// {@template DeleteNoteEntry}
/// See [NoteRepository.deleteNoteEntry].
/// {@endtemplate}
class DeleteNoteEntry extends Runner<DeleteNoteEntryParams, Failure, void> {
  /// {@macro DeleteNoteEntry}
  DeleteNoteEntry({required NoteRepository noteRepository})
      : _noteRepository = noteRepository;

  /// A reference to the [NoteRepository] instance.
  final NoteRepository _noteRepository;

  @override
  FutureOr<Either<Failure, void>> onCall(DeleteNoteEntryParams params) =>
      _noteRepository.deleteNoteEntry(id: params.id);
}
