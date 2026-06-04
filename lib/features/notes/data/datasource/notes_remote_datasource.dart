import 'package:dio/dio.dart';

class NotesRemoteDataSource {
  final Dio dio;

  NotesRemoteDataSource(this.dio);

  Future<Response> getNotes() async {
    return await dio.get('/notes');
  }

  Future<Response> createNote(String title, String content) async {
    return await dio.post('/notes', data: {
      'title': title,
      'content': content,
    });
  }

  Future<Response> updateNote(String id, String title, String content) async {
    return await dio.put('/notes/$id', data: {
      'title': title,
      'content': content,
    });
  }

  Future<Response> deleteNote(String id) async {
    return await dio.delete('/notes/$id');
  }
}