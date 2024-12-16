import '../data/database.dart';
import '../models/note_model.dart';
import '../rust/models/notes.dart';

class NoteRepository {
  final Database _db;

  NoteRepository(this._db);

  Future<NoteModel> getNote(String id) async {
    return NoteModel.fromNote(await _db.getNote(id));
  }

  Future<List<NoteModel>> listNotes(String query) async {
    return (await _db.listNote(query))
        .map((l) => NoteModel.fromNote(l))
        .toList();
  }

  Future<NoteModel> addNote(NoteModel note) async {
    final data = Note.fromNoteModel(note);
    final newNote = await _db.postNote(data);
    return NoteModel.fromNote(newNote);
  }

  Future<NoteModel> updateNote(String id, NoteModel note) async {
    final data = Note.fromNoteModel(note);
    final updatedNote = await _db.putNote(id, data);
    return NoteModel.fromNote(updatedNote);
  }

  Future<NoteModel> deleteNote(String id) async {
    final deletedNote = await _db.deleteNote(id);
    return NoteModel.fromNote(deletedNote);
  }
}
