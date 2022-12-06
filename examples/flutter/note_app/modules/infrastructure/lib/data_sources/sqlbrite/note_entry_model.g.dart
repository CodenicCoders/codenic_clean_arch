// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'note_entry_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NoteEntryModel _$NoteEntryModelFromJson(Map<String, dynamic> json) =>
    NoteEntryModel(
      id: json['id'] as String,
      title: json['title'] as String,
      content: json['content'] as String,
      updateTimestamp: json['updateTimestamp'] as int,
    );

Map<String, dynamic> _$NoteEntryModelToJson(NoteEntryModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'content': instance.content,
      'updateTimestamp': instance.updateTimestamp,
    };
