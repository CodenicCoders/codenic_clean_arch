/// {@template NotesDatabaseContract}
/// A contract class for the notes SQL database.
/// {@endtemplate}
class NotesDatabaseContract {
  /// {@macro NotesDatabaseContract}
  NotesDatabaseContract._();

  /// The name of the database.
  static const databaseName = 'notes.db';

  /// The current version of the database.
  static const databaseVersion = 1;
}
