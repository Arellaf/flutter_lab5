import '../datasource/notes_remote_datasource.dart';
import '../models/note_model.dart';

class NotesRepository {
  final NotesRemoteDataSource remote;

  NotesRepository(this.remote);

  Future<List<NoteModel>> getNotes() async {
    final res = await remote.getNotes();
    return (res.data as List)
        .map((e) => NoteModel.fromJson(e))
        .toList();
  }

  Future<void> create(String title, String content) async {
    await remote.createNote(title, content);
  }

  Future<void> update(String id, String title, String content) async {
    await remote.updateNote(id, title, content);
  }

  Future<void> delete(String id) async {
    await remote.deleteNote(id);
  }
}