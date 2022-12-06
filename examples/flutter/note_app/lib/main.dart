import 'package:flutter/material.dart';
import 'package:infrastructure/data_sources/sqlbrite/sqlbrite_data_source.dart';
import 'package:note_app/injectables.dart';
import 'package:presentation/main_app.dart';
import 'package:presentation/presentation.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  initializeServiceLocator();

  // Initialize the [SqlbriteDataSource] before `runApp` is called to setup
  // the database
  await serviceLocator<SqlbriteDataSource>().initialize();

  runApp(const MainApp());
}
