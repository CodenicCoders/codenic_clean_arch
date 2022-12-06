/// {@template NoteEntryContract}
/// A contract class for the note entries table of the notes database.
/// {@endtemplate}
class NoteEntryContract {
  /// {@macro NoteEntryContract}
  NoteEntryContract._();

  /// The name of the database table.
  static const String tableName = 'noteEntries';

  /// The name of the ID column.
  static const String idField = 'id';

  /// The name of the title column.
  static const String titleField = 'title';

  /// The name of the content column.
  static const String contentField = 'content';

  /// The name of the last updated time column.
  static const String updateTimestampField = 'updateTimestamp';

  /// Constructs a SQL query for creating the note entries table.
  static const String createTableQuery = '''
    CREATE TABLE $tableName (
      $idField TEXT PRIMARY KEY,
      $titleField TEXT NOT NULL,
      $contentField TEXT NOT NULL,
      $updateTimestampField INTEGER NOT NULL
    )
  ''';

  /// Constructs a SQL query for inserting one or more new note entries into 
  /// the database.
  static String insertQuery([int count = 1]) {
    final buffer = StringBuffer('''
      INSERT INTO $tableName (
        $idField,
        $titleField,
        $contentField,
        $updateTimestampField
      ) VALUES (?, ?, ?, ?) 
    ''');

    for (var i = 1; i < count; i++) {
      buffer.write('''
        , (?, ?, ?, ?)
      ''');
    }

    return buffer.toString();
  }

  /// A where clause for selecting a note entry by its ID.
  static String whereId = '$idField = ?';

  /// A where clause for ordering the note entries by their update timestamp in
  /// descending order.
  static String orderByUpdateTimestampDesc = '$updateTimestampField DESC';
}
