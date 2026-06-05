import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path_provider/path_provider.dart';
import 'package:cookie_jar/cookie_jar.dart';

import 'app/router.dart';
import 'features/auth/bloc/auth_bloc.dart';
import 'features/auth/bloc/auth_event.dart';
import 'features/auth/data/repositories/auth_repository.dart';
import 'features/auth/data/datasource/auth_remote_datasource.dart';

import 'features/notes/data/repositories/notes_repository.dart';
import 'features/notes/data/datasource/notes_remote_datasource.dart';

import 'core/network/api_client.dart';
import 'core/storage/token_storage.dart';
import 'core/network/auth_interceptor.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final appDocDir = await getApplicationDocumentsDirectory();
  final String cookiePath = '${appDocDir.path}/.cookies/';

  final cookieJar = PersistCookieJar(
    ignoreExpires: false,
    storage: FileStorage(cookiePath),
  );

  final storage = TokenStorage();
  final apiClient = ApiClient(cookieJar: cookieJar);
  final dio = apiClient.dio;

  final authRemote = AuthRemoteDataSource(dio);
  final authRepo = AuthRepository(remote: authRemote, storage: storage);

  final notesRemote = NotesRemoteDataSource(dio);
  final notesRepo = NotesRepository(notesRemote);

  dio.interceptors.add(AuthInterceptor(storage, dio));

  runApp(
    MultiRepositoryProvider(
      providers: [
        RepositoryProvider<AuthRepository>.value(value: authRepo),
        RepositoryProvider<NotesRepository>.value(value: notesRepo),
      ],
      child: MyApp(authRepository: authRepo),
    ),
  );
}

class MyApp extends StatelessWidget {
  final AuthRepository authRepository;

  const MyApp({super.key, required this.authRepository});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AuthBloc(authRepository)..add(CheckAuthStatus()),
      child: MaterialApp.router(
        debugShowCheckedModeBanner: false,
        routerConfig: AppRouter.router,
      ),
    );
  }
}
