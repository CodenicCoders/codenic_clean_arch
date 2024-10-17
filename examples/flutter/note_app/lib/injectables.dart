import 'package:domain/domain.dart';
import 'package:domain/note/repositories/note_repository.dart';
import 'package:domain/note/use_cases/create_note_entry.dart';
import 'package:domain/note/use_cases/delete_note_entry.dart';
import 'package:domain/note/use_cases/fetch_note_entries.dart';
import 'package:domain/note/use_cases/update_note_entry.dart';
import 'package:domain/note/use_cases/watch_note_entries.dart';
import 'package:infrastructure/data_sources/sqlbrite/sqlbrite_data_source.dart';
import 'package:infrastructure/note/note_repository_impl.dart';
import 'package:presentation/presentation.dart';

/// Initializes the service locator by registering all external dependencies,
/// data sources, repositories and use cases.
void initializeServiceLocator() {
  serviceLocator.registerLazySingleton<ExceptionConverterSuite>(
    () => ExceptionConverterSuite(),
  );

  serviceLocator
      .registerLazySingleton<SqlbriteDataSource>(() => SqlbriteDataSource());

  // When injecting repositories, make sure to use the interface as the generic
  // type (i.e. NoteRepository instead of NoteRepositoryImpl) so that the
  // repository can be swapped out with a different implementation
  serviceLocator.registerLazySingleton<NoteRepository>(
    () => NoteRepositoryImpl(
      exceptionConverterSuite: serviceLocator(),
      sqlbriteDataSource: serviceLocator(),
    ),
  );

  // Inject use cases as factories so that they can be instantiated more than
  // once

  serviceLocator.registerFactory<CreateNoteEntry>(
    () => CreateNoteEntry(noteRepository: serviceLocator()),
  );

  serviceLocator.registerFactory<UpdateNoteEntry>(
    () => UpdateNoteEntry(noteRepository: serviceLocator()),
  );

  serviceLocator.registerFactory<DeleteNoteEntry>(
    () => DeleteNoteEntry(noteRepository: serviceLocator()),
  );

  serviceLocator.registerFactory<FetchNoteEntries>(
    () => FetchNoteEntries(noteRepository: serviceLocator()),
  );

  serviceLocator.registerFactory<WatchNoteEntries>(
    () => WatchNoteEntries(noteRepository: serviceLocator()),
  );
}
