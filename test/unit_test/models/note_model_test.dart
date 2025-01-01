import 'package:flutter_test/flutter_test.dart';
import 'package:password/src/models/note_model.dart';
import 'package:password/src/rust/models/notes.dart';

void main() {
  group('NoteModel', () {
    test('should create NoteModel from json', () {
      final json = {
        'id': '1',
        'name': 'Test Note',
        'isFavorite': true,
        'note': 'This is a test note',
        'createdAt': 1234567890,
        'createdBy': 'user1',
        'updatedAt': 1234567891,
        'updatedBy': 'user1',
        'tags': ['tag1', 'tag2']
      };

      final noteModel = NoteModel.fromJson(json);

      expect(noteModel.id, '1');
      expect(noteModel.name, 'Test Note');
      expect(noteModel.isFavorite, true);
      expect(noteModel.note, 'This is a test note');
      expect(noteModel.createdAt, 1234567890);
      expect(noteModel.createdBy, 'user1');
      expect(noteModel.updatedAt, 1234567891);
      expect(noteModel.updatedBy, 'user1');
      expect(noteModel.tags, ['tag1', 'tag2']);
    });

    test('should create NoteModel from Note', () {
      final note = Note(
          id: '1',
          name: 'Test Note',
          isFavorite: true,
          note: 'This is a test note',
          createdAt: 1234567890,
          createdBy: 'user1',
          updatedAt: 1234567891,
          updatedBy: 'user1',
          tags: 'tag1,tag2');

      final noteModel = NoteModel.fromNote(note);

      expect(noteModel.id, '1');
      expect(noteModel.name, 'Test Note');
      expect(noteModel.isFavorite, true);
      expect(noteModel.note, 'This is a test note');
      expect(noteModel.createdAt, 1234567890);
      expect(noteModel.createdBy, 'user1');
      expect(noteModel.updatedAt, 1234567891);
      expect(noteModel.updatedBy, 'user1');
      expect(noteModel.tags, ['tag1', 'tag2']);
    });

    test('should handle null values correctly', () {
      final note = Note(
        name: 'Test Note',
      );

      final noteModel = NoteModel.fromNote(note);

      expect(noteModel.id, null);
      expect(noteModel.name, 'Test Note');
      expect(noteModel.isFavorite, false);
      expect(noteModel.note, null);
      expect(noteModel.createdAt, null);
      expect(noteModel.createdBy, null);
      expect(noteModel.updatedAt, null);
      expect(noteModel.updatedBy, null);
      expect(noteModel.tags, []);
    });

    test('should create minimal NoteModel with required fields only', () {
      final noteModel = NoteModel(
        name: 'Test Note',
        isFavorite: false,
      );

      expect(noteModel.name, 'Test Note');
      expect(noteModel.isFavorite, false);
      expect(noteModel.id, null);
      expect(noteModel.note, null);
      expect(noteModel.createdAt, null);
      expect(noteModel.createdBy, null);
      expect(noteModel.updatedAt, null);
      expect(noteModel.updatedBy, null);
      expect(noteModel.tags, null);
    });
  });
}
