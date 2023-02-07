import 'dart:async';

import 'package:codenic_bloc_use_case/codenic_bloc_use_case.dart';
import 'package:codenic_exception_converter/codenic_exception_converter.dart';
import 'package:domain/note/repositories/note_repository.dart';

/// {@template CreateNoteEntryParams}
/// The parameters for the [CreateNoteEntry] use case.
/// {@endtemplate}
class CreateNoteEntryParams with EquatableMixin {
  /// {@macro CreateNoteEntryParams}
  const CreateNoteEntryParams({required this.title, required this.content});

  /// The title of the note entry to create.
  final String? title;

  /// The content of the note entry to create.
  final String? content;

  @override
  List<Object?> get props => [title, content];
}

/// {@template CreateNoteEntry}
/// See [NoteRepository.createNoteEntry].
/// {@endtemplate}
class CreateNoteEntry extends Runner<CreateNoteEntryParams, Failure, void> {
  /// {@macro CreateNoteEntry}
  CreateNoteEntry({required NoteRepository noteRepository})
      : _noteRepository = noteRepository;

  /// A reference to the [NoteRepository] instance.
  final NoteRepository _noteRepository;

  @override
  FutureOr<Either<Failure, void>> onCall(CreateNoteEntryParams params) =>
      _noteRepository.createNoteEntry(
        title: params.title,
        content: params.content,
      );
}
