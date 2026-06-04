import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../features/auth/presentation/auth_page.dart';
import '../features/notes/presentation/notes_page.dart';
import '../features/notes/bloc/notes_bloc.dart';
import '../features/notes/data/repositories/notes_repository.dart'; 

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/auth',
    routes: [
      GoRoute(
        path: '/auth',
        builder: (context, state) => const AuthPage(),
      ),
      GoRoute(
        path: '/notes',
        builder: (context, state) => BlocProvider(
          create: (context) => NotesBloc(
            context.read<NotesRepository>(), 
          )..add(LoadNotes()),
          child: const NotesPage(),
        ),
      ),
    ],
  );
}
