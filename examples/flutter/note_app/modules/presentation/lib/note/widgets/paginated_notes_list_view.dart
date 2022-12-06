import 'package:domain/domain.dart';
import 'package:domain/note/entities/note_entry.dart';
import 'package:domain/note/use_cases/fetch_note_entries.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:presentation/note/widgets/note_entry_list_tile.dart';

/// {@template PaginatedNotesListView}
/// A widget for displaying a list of [NoteEntry]s paginated by the
/// [FetchNoteEntries] use case.
/// {@endtemplate}
class PaginatedNotesListView extends StatefulWidget {
  const PaginatedNotesListView({super.key});

  @override
  State<PaginatedNotesListView> createState() => _PaginatedNotesListViewState();
}

class _PaginatedNotesListViewState extends State<PaginatedNotesListView> {
  /// A controller containing all the [NoteEntry]s displayed on the list.
  final _pagingController =
      PagingController<dynamic, NoteEntry>(firstPageKey: 0);

  @override
  void initState() {
    super.initState();

    // Fetch the first page of note entries
    _fetchNoteEntries(0);

    // Add a listener to the paging controller so that we can fetch the next 
    // page of note entries when the user scrolls to the end of the list
    _pagingController
        .addPageRequestListener((pageKey) => _fetchNoteEntries(pageKey));
  }

  @override
  void dispose() {
    _pagingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<FetchNoteEntries, RunnerState>(
      listener: (context, fetchNoteEntriesState) {
        if (fetchNoteEntriesState is RunSuccess<List<NoteEntry>>) {
          // Update the note entries in the paging controller when the
          // [FetchNoteEntries] use case succeeds
          _updatePagingController();
        }
      },
      builder: (context, fetchNoteEntriesState) {
        return PagedListView<dynamic, NoteEntry>(
          pagingController: _pagingController,
          shrinkWrap: true,
          builderDelegate: PagedChildBuilderDelegate<NoteEntry>(
            itemBuilder: (context, noteEntry, index) =>
                NoteEntryListTile(noteEntry: noteEntry),
          ),
        );
      },
    );
  }

  /// Fetches a collection of note entries respective to the given [pageKey].
  void _fetchNoteEntries(dynamic pageKey) {
    context.read<FetchNoteEntries>().run(
          params: FetchNoteEntriesParams(pageToken: pageKey),
        );
  }

  /// Updates the note entries in the paging controller.
  void _updatePagingController() {
    final fetchNoteEntries = context.read<FetchNoteEntries>();

    final params = fetchNoteEntries.rightParams;
    final noteEntries = fetchNoteEntries.rightValue;

    if (params == null || noteEntries == null) {
      return;
    }

    if (params.pageToken == 0) {
      // If the token used to fetch the note entries is `0`, then we are
      // fetching the first page
      _pagingController.refresh();
    }

    if (noteEntries.length < params.limit) {
      // If the number of note entries is less than the limit, then we have
      // reached the end of the list
      _pagingController.appendLastPage(noteEntries);
    } else {
      _pagingController.appendPage(
        noteEntries,
        params.pageToken + noteEntries.length,
      );
    }
  }
}
