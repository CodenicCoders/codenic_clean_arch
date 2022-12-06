import 'dart:async';
import 'dart:math';

import 'package:flutter_lorem/flutter_lorem.dart';
import 'package:infrastructure/data_sources/sqlbrite/contracts/note_entry_contract.dart';
import 'package:infrastructure/data_sources/sqlbrite/contracts/notes_database_contract.dart';
import 'package:infrastructure/data_sources/sqlbrite/note_entry_model.dart';
import 'package:sqlbrite/sqlbrite.dart';

/// {@template SqlbriteDataSource}
/// A data source that uses [BriteDatabase] to interact with the local SQLite
/// database.
/// {@endtemplate}
class SqlbriteDataSource {
  /// A reference to the [BriteDatabase] instance used to interact with the
  /// underlying database
  ///
  /// [initialize] must be called before accessing this property.
  late final BriteDatabase _database;

  /// Initializes the database.
  ///
  /// Must be called at the start of the app.
  Future<void> initialize() async {
    // Open the database
    final database = await openDatabase(
      NotesDatabaseContract.databaseName,
      version: NotesDatabaseContract.databaseVersion,
      onCreate: (db, version) async {
        // Create the note entries table when the database has been created
        await db.execute(NoteEntryContract.createTableQuery);
        await _generateData(db);
      },
    );

    _database = BriteDatabase(database, logger: null);
  }

  /// Saves the new note entry to the database.
  Future<void> createNoteEntry({
    required String title,
    required String content,
  }) {
    final noteEntry = NoteEntryModel(
      id: _generateId(),
      title: title,
      content: content,
      updateTimestamp: DateTime.now().millisecondsSinceEpoch,
    );

    return _database.insert(NoteEntryContract.tableName, noteEntry.toJson());
  }

  /// Produces a random ID for the note entry.
  String _generateId() {
    final rnd = Random.secure();
    return List<int>.generate(20, (index) => rnd.nextInt(10)).join();
  }

  /// Updates the note entry with the given [id].
  Future<void> updateNoteEntry({
    required String id,
    required String? title,
    required String? content,
  }) {
    return _database.update(
      NoteEntryContract.tableName,
      {
        if (title != null) NoteEntryContract.titleField: title,
        if (content != null) NoteEntryContract.contentField: content,
        NoteEntryContract.updateTimestampField:
            DateTime.now().millisecondsSinceEpoch,
      },
      where: NoteEntryContract.whereId,
      whereArgs: [id],
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Deletes the note entry with the given [id].
  Future<void> deleteNoteEntry({required String id}) {
    return _database.delete(
      NoteEntryContract.tableName,
      where: NoteEntryContract.whereId,
      whereArgs: [id],
    );
  }

  /// Fetches a list of note entries from the database sorted by the update
  /// timestamp in descending order.
  ///
  /// An [offset] can be provided to skip a number of entries ideal for
  /// implementing pagination.
  Future<List<NoteEntryModel>> fetchNoteEntries({
    required int limit,
    int? offset,
  }) async {
    final result = await _database.query(
      NoteEntryContract.tableName,
      orderBy: NoteEntryContract.orderByUpdateTimestampDesc,
      limit: limit,
      offset: offset,
    );

    return result.map<NoteEntryModel>(NoteEntryModel.fromJson).toList();
  }

  /// Streams a list of note entries sorted by the update timestamp in
  /// descending order with the number of entries specified by the given
  /// [limit].
  ///
  /// The stream will emit a new list of note entries whenever a change is made
  /// to the database.
  Stream<List<NoteEntryModel>> watchRecentNoteEntries({required int limit}) {
    return _database
        .createQuery(
          NoteEntryContract.tableName,
          orderBy: NoteEntryContract.orderByUpdateTimestampDesc,
          limit: limit,
          offset: 0,
        )
        .mapToList((row) => NoteEntryModel.fromJson(row));
  }

  /// A method for generating initial test data for the database.
  Future<int> _generateData(Database db) async {
    final rnd = Random();
    final currentTime = DateTime.now().millisecondsSinceEpoch;

    final mockNoteEntries = <NoteEntryModel>[
      for (var i = 0; i < 100; i++)
        NoteEntryModel(
          id: _generateId(),
          title: lorem(
            paragraphs: 1,
            words: rnd.nextInt(2) + 1,
          ).replaceAll('.', ''),
          content: lorem(
            paragraphs: 1,
            words: rnd.nextInt(10) + 1,
          ),
          updateTimestamp: currentTime - (i * 3600),
        ),
    ];

    return db.rawInsert(
      NoteEntryContract.insertQuery(mockNoteEntries.length),
      mockNoteEntries
          .expand((e) => [
                e.id,
                e.title,
                e.content,
                e.updateTimestamp,
              ])
          .toList(),
    );
  }
}
