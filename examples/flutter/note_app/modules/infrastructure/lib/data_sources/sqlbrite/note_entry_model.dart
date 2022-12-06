import 'package:domain/note/entities/note_entry.dart';
import 'package:infrastructure/data_sources/sqlbrite/sqlbrite_data_source.dart';
import 'package:json_annotation/json_annotation.dart';

part 'note_entry_model.g.dart';

/// {@template NoteEntryModel}
/// A model to represent a [NoteEntry] in the [SqlbriteDataSource].
/// {@endtemplate}
@JsonSerializable()
class NoteEntryModel {
  /// {@macro NoteEntryModel}
  const NoteEntryModel({
    required this.id,
    required this.title,
    required this.content,
    required this.updateTimestamp,
  });

  /// The unique identifier of the note entry.
  final String id;

  /// The title of the note entry.
  final String title;

  /// The content of the note entry.
  final String content;

  /// The timestamp of the last update of the note entry in milliseconds since
  /// epoch.
  final int updateTimestamp;

  /// A constructor to create a new [NoteEntryModel] from a [NoteEntry].
  factory NoteEntryModel.fromEntity(NoteEntry entity) => NoteEntryModel(
        id: entity.id,
        title: entity.title,
        content: entity.content,
        updateTimestamp: entity.updatedAt.millisecondsSinceEpoch,
      );

  /// Converts this [NoteEntryModel] to a [NoteEntry].
  NoteEntry toEntity() => NoteEntry(
        id: id,
        title: title,
        content: content,
        updatedAt: DateTime.fromMillisecondsSinceEpoch(updateTimestamp),
      );

  /// A constructor to create a new [NoteEntryModel] from a JSON object.
  factory NoteEntryModel.fromJson(Map<String, dynamic> json) =>
      _$NoteEntryModelFromJson(json);

  /// Converts this [NoteEntryModel] to a JSON object.
  Map<String, dynamic> toJson() => _$NoteEntryModelToJson(this);
}
