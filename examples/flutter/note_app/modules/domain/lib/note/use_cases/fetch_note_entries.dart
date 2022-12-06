import 'package:codenic_bloc_use_case/codenic_bloc_use_case.dart';
import 'package:codenic_exception_converter/codenic_exception_converter.dart';
import 'package:domain/note/entities/note_entry.dart';
import 'package:domain/note/repositories/note_repository.dart';

/// {@template FetchNoteEntryParams}
/// The parameters for the [FetchNoteEntries] use case.
/// {@endtemplate}
class FetchNoteEntriesParams with EquatableMixin {
  /// {@macro FetchNoteEntryParams}
  const FetchNoteEntriesParams({this.limit = 10, this.pageToken});

  /// The number of [NoteEntry]s to fetch.
  final int limit;

  /// A token used for fetching a particular page of [NoteEntry]s.
  final dynamic pageToken;

  @override
  List<Object?> get props => [limit, pageToken];
}

/// {@template FetchNoteEntries}
/// See [NoteRepository.fetchNoteEntries].
/// {@endtemplate}
class FetchNoteEntries
    extends Runner<FetchNoteEntriesParams, Failure, List<NoteEntry>> {
  /// {@macro FetchNoteEntry}
  FetchNoteEntries({required NoteRepository noteRepository})
      : _noteRepository = noteRepository;

  /// A reference to the [NoteRepository] instance.
  final NoteRepository _noteRepository;

  @override
  Future<Either<Failure, List<NoteEntry>>> onCall(
          FetchNoteEntriesParams params) =>
      _noteRepository.fetchNoteEntries(
        limit: params.limit,
        pageToken: params.pageToken,
      );
}
