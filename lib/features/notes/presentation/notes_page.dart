import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../shared/widgets/custom_textfield.dart';
import '../../auth/bloc/auth_bloc.dart';
import '../../auth/bloc/auth_state.dart';
import '../../auth/bloc/auth_event.dart';
import '../bloc/notes_bloc.dart';
import '../data/models/note_model.dart';

class NotesPage extends StatefulWidget {
  const NotesPage({super.key});

  @override
  State<NotesPage> createState() => _NotesPageState();
}

class _NotesPageState extends State<NotesPage> {
  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthUnauthenticated) {
          context.go('/auth');
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        appBar: AppBar(
          title: const Text(
            "My Notes",
            style: TextStyle(
              color: Color(0xFF0F172A),
              fontWeight: FontWeight.bold,
              fontSize: 24,
            ),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: false,
          actions: [
            BlocBuilder<AuthBloc, AuthState>(
              builder: (context, state) {
                String nickname = "User";
                if (state is AuthAuthenticated) {
                  nickname = state.user.nickname;
                }

                return Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2563EB).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        " $nickname",
                        style: const TextStyle(
                          color: Color(0xFF2563EB),
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),

                    const SizedBox(width: 8),

                    IconButton(
                      tooltip: "Logout",
                      icon: const Icon(Icons.logout, color: Color(0xFFEF4444)),
                      onPressed: () {
                        context.read<AuthBloc>().add(LogoutRequested());
                      },
                    ),

                    const SizedBox(width: 8),
                  ],
                );
              },
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          backgroundColor: const Color(0xFF2563EB),
          onPressed: () => _showNoteBottomSheet(context),
          icon: const Icon(Icons.add, color: Colors.white),
          label: const Text(
            "Add Note",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        body: BlocBuilder<NotesBloc, NotesState>(
          builder: (context, state) {
            if (state is NotesLoading) {
              return const Center(
                child: CircularProgressIndicator(color: Color(0xFF2563EB)),
              );
            }

            if (state is NotesLoaded) {
              if (state.notes.isEmpty) {
                return const Center(
                  child: Text(
                    "No notes yet. Tap 'Add Note' to start!",
                    style: TextStyle(color: Color(0xFF64748B)),
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: state.notes.length,
                itemBuilder: (context, index) {
                  final note = state.notes[index];

                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.02),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      title: Text(
                        note.title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0F172A),
                          fontSize: 18,
                        ),
                      ),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Text(
                          note.content ?? "No content",
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Color(0xFF475569),
                            fontSize: 14,
                          ),
                        ),
                      ),
                      onTap: () => _showNoteBottomSheet(context, note: note),
                      trailing: IconButton(
                        icon: const Icon(
                          Icons.delete_outline,
                          color: Color(0xFFEF4444),
                        ),
                        onPressed: () {
                          context.read<NotesBloc>().add(DeleteNote(note.id));
                        },
                      ),
                    ),
                  );
                },
              );
            }

            if (state is NotesError) {
              return Center(
                child: Text(
                  state.message,
                  style: const TextStyle(color: Color(0xFFEF4444)),
                ),
              );
            }

            return const Center(child: Text("No notes"));
          },
        ),
      ),
    );
  }

  void _showNoteBottomSheet(BuildContext context, {NoteModel? note}) {
    final titleController = TextEditingController(text: note?.title ?? "");
    final contentController = TextEditingController(text: note?.content ?? "");
    final isEditing = note != null;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (bottomSheetContext) {
        return Padding(
          padding: EdgeInsets.only(
            top: 24,
            left: 24,
            right: 24,
            bottom: MediaQuery.of(bottomSheetContext).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    isEditing ? "Edit Note" : "Create New Note",
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Color(0xFF64748B)),
                    onPressed: () => Navigator.pop(bottomSheetContext),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              CustomTextField(controller: titleController, hintText: "Title"),
              const SizedBox(height: 12),
              CustomTextField(
                controller: contentController,
                hintText: "Type something...",
                maxLines: 5,
              ),
              const SizedBox(height: 20),
              CustomButton(
                text: isEditing ? "Save Changes" : "Create",
                onPressed: () {
                  if (titleController.text.trim().isEmpty) return;

                  if (isEditing) {
                    context.read<NotesBloc>().add(
                      UpdateNote(
                        note.id,
                        titleController.text.trim(),
                        contentController.text.trim(),
                      ),
                    );
                  } else {
                    context.read<NotesBloc>().add(
                      CreateNote(
                        titleController.text.trim(),
                        contentController.text.trim(),
                      ),
                    );
                  }
                  Navigator.pop(bottomSheetContext);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}