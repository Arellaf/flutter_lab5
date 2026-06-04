import 'package:equatable/equatable.dart';

abstract class NotesEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadNotes extends NotesEvent {}

class CreateNote extends NotesEvent {
  final String title;
  final String content;

  CreateNote(this.title, this.content);
}

class DeleteNote extends NotesEvent {
  final String id;

  DeleteNote(this.id);
}

class UpdateNote extends NotesEvent {
  final String id;
  final String title;
  final String content;

  UpdateNote(this.id, this.title, this.content);

  @override
  List<Object?> get props => [id, title, content];
}