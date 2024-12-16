import 'package:freezed_annotation/freezed_annotation.dart';

import '../rust/models/notes.dart';

part 'note_model.freezed.dart';
part 'note_model.g.dart';

@freezed
class NoteModel with _$NoteModel {
  const factory NoteModel({
    String? id,
    required String name,
    required bool isFavorite,
    String? note,
    int? createdAt,
    String? createdBy,
    int? updatedAt,
    String? updatedBy,
    List<String>? tags,
  }) = _NoteModel;

  factory NoteModel.fromJson(Map<String, Object?> json) =>
      _$NoteModelFromJson(json);

  factory NoteModel.fromNote(Note note) {
    return NoteModel(
      id: note.id,
      name: note.name,
      isFavorite: note.isFavorite ?? false,
      note: note.note,
      createdAt: note.createdAt,
      createdBy: note.createdBy,
      updatedAt: note.updatedAt,
      updatedBy: note.updatedBy,
      tags: note.tags?.split(',') ?? [],
    );
  }
}
