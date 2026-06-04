import 'package:flutter_bloc/flutter_bloc.dart';
import 'notes_event.dart';
import 'notes_state.dart';
import '../data/repositories/notes_repository.dart';

export 'notes_event.dart';
export 'notes_state.dart';

class NotesBloc extends Bloc<NotesEvent, NotesState> {
  final NotesRepository repository;

  NotesBloc(this.repository) : super(NotesInitial()) {
    on<LoadNotes>(_onLoad);
    on<CreateNote>(_onCreate);
    on<DeleteNote>(_onDelete);
    on<UpdateNote>(_onUpdate);
  }

  Future<void> _onLoad(LoadNotes event, Emitter<NotesState> emit) async {
    emit(NotesLoading());
    try {
      final notes = await repository.getNotes();
      emit(NotesLoaded(notes));
    } catch (e) {
      emit(NotesError("Failed to load notes"));
    }
  }

  Future<void> _onCreate(CreateNote event, Emitter<NotesState> emit) async {
    try {
      await repository.create(event.title, event.content);
      add(LoadNotes());
    } catch (e) {
      emit(NotesError("Failed to create note"));
    }
  }

  Future<void> _onDelete(DeleteNote event, Emitter<NotesState> emit) async {
    try {
      await repository.delete(event.id);
      add(LoadNotes());
    } catch (e) {
      emit(NotesError("Failed to delete note"));
    }
  }

  Future<void> _onUpdate(UpdateNote event, Emitter<NotesState> emit) async {
    try {
      await repository.update(event.id, event.title, event.content);

      add(LoadNotes());
    } catch (e) {
      emit(NotesError("Failed to update note"));
    }
  }
}
