import 'dart:async';

import 'package:codenic_bloc_use_case/codenic_bloc_use_case.dart';
import 'package:codenic_exception_converter/codenic_exception_converter.dart';
import 'package:domain/note/entities/note_entry.dart';
import 'package:domain/note/repositories/note_repository.dart';

/// {@template WatchNoteEntriesParams}
/// The parameters for the [WatchNoteEntries] use case.
/// {@endtemplate}
class WatchNoteEntriesParams with EquatableMixin {
  /// {@macro WatchNoteEntriesParams}
  const WatchNoteEntriesParams({required this.limit});

  /// The maximum number of [NoteEntry]s to stream.
  final int limit;

  @override
  List<Object?> get props => [limit];
}

/// {@template WatchNoteEntries}
/// See [NoteRepository.watchNoteEntries].
/// {@endtemplate}
class WatchNoteEntries
    extends Watcher<WatchNoteEntriesParams, Failure, List<NoteEntry>> {
  /// {@macro WatchNoteEntries}
  WatchNoteEntries({required this.noteRepository});

  /// A reference to the [NoteRepository] instance.
  final NoteRepository noteRepository;

  @override
  FutureOr<Either<Failure, VerboseStream<Failure, List<NoteEntry>>>> onCall(
    WatchNoteEntriesParams params,
  ) =>
      noteRepository.watchNoteEntries(limit: params.limit);
}
