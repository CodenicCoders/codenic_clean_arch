import 'package:flutter/material.dart';

/// {@template SnackBarHandler}
/// Provides a suite of snackbars to display an error or info to the user.
/// {@endtemplate}
class SnackBarHandler {
  /// {@macro SnackBarHandler}
  SnackBarHandler._();

  /// Shows an info snackbar.
  static void info(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  /// Shows an error snackbar.
  static void error(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).errorColor,
      ),
    );
  }
}
