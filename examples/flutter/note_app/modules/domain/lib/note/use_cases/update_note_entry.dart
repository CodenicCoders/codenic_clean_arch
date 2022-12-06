import 'package:codenic_bloc_use_case/codenic_bloc_use_case.dart';
import 'package:codenic_exception_converter/codenic_exception_converter.dart';
import 'package:domain/note/entities/note_entry.dart';
import 'package:domain/note/repositories/note_repository.dart';

/// {@template UpdateNoteEntryParams}
/// The parameters for the [UpdateNoteEntry] use case.
/// {@endtemplate}
class UpdateNoteEntryParams with EquatableMixin {
  /// {@macro UpdateNoteEntryParams}
  const UpdateNoteEntryParams({required this.id, this.title, this.content});

  /// The ID of the [NoteEntry] to update.
  final String id;

  /// The new title of the [NoteEntry].
  final String? title;

  /// The new content of the [NoteEntry].
  final String? content;

  @override
  List<Object?> get props => [id, title, content];
}

/// {@template UpdateNoteEntry}
/// See [NoteRepository.updateNoteEntry].
/// {@endtemplate}
class UpdateNoteEntry extends Runner<UpdateNoteEntryParams, Failure, void> {
  /// {@macro UpdateNoteEntry}
  UpdateNoteEntry({required NoteRepository noteRepository})
      : _noteRepository = noteRepository;

  /// A reference to the [NoteRepository] instance.
  final NoteRepository _noteRepository;

  @override
  Future<Either<Failure, void>> onCall(UpdateNoteEntryParams params) =>
      _noteRepository.updateNoteEntry(
        id: params.id,
        title: params.title,
        content: params.content,
      );
}
