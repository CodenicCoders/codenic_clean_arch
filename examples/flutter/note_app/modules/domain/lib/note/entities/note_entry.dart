import 'package:domain/domain.dart';

/// {@template NoteEntry}
/// A model representing a note entry.
/// {@endtemplate}
class NoteEntry with EquatableMixin {
  /// {@macro NoteEntry}
  const NoteEntry({
    required this.id,
    required this.title,
    required this.content,
    required this.updatedAt,
  });

  /// The unique identifier of the note entry.
  final String id;

  /// The title of the note entry.
  final String title;

  /// The content of the note entry.
  final String content;

  /// The date and time when the note entry was last updated.
  final DateTime updatedAt;

  /// Creates a copy of the note entry with the given fields replaced with the
  /// new values.
  NoteEntry copyWith({
    String? id,
    String? title,
    String? content,
    DateTime? updatedAt,
  }) =>
      NoteEntry(
        id: id ?? this.id,
        title: title ?? this.title,
        content: content ?? this.content,
        updatedAt: updatedAt ?? this.updatedAt,
      );

  @override
  List<Object?> get props => [id, title, content, updatedAt];
}
