import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'core/constants/api_constants.dart';
import 'core/network/api_client.dart';
import 'core/router/app_router.dart';
import 'features/auth/data/repositories/auth_repository.dart';
import 'features/auth/data/services/social_auth_service.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/comments/data/repositories/comments_repository.dart';
import 'features/likes/data/repositories/likes_repository.dart';
import 'features/messages/data/repositories/messages_repository.dart';
import 'features/notifications/data/repositories/notifications_repository.dart';
import 'features/notifications/presentation/bloc/notifications_bloc.dart';
import 'features/posts/data/repositories/posts_repository.dart';
import 'features/profile/data/repositories/profile_repository.dart';
import 'features/search/data/repositories/search_repository.dart';

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  static const _storage = FlutterSecureStorage();

  late final ApiClient _apiClient;
  late final AuthRepository _authRepository;
  late final PostsRepository _postsRepository;
  late final CommentsRepository _commentsRepository;
  late final LikesRepository _likesRepository;
  late final NotificationsRepository _notificationsRepository;
  late final ProfileRepository _profileRepository;
  late final SearchRepository _searchRepository;
  late final MessagesRepository _messagesRepository;
  late final SocialAuthService _socialAuthService;

  @override
  void initState() {
    super.initState();

    _apiClient = ApiClient(baseUrl: ApiConstants.baseUrl, storage: _storage);
    _authRepository = AuthRepository(apiClient: _apiClient, storage: _storage);
    _postsRepository = PostsRepository(apiClient: _apiClient);
    _commentsRepository = CommentsRepository(apiClient: _apiClient);
    _likesRepository = LikesRepository(apiClient: _apiClient);
    _notificationsRepository = NotificationsRepository(apiClient: _apiClient);
    _profileRepository = ProfileRepository(apiClient: _apiClient);
    _searchRepository = SearchRepository(apiClient: _apiClient);
    _messagesRepository = MessagesRepository(apiClient: _apiClient);
    _socialAuthService = SocialAuthService(baseUrl: ApiConstants.baseUrl);
  }

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<ApiClient>.value(value: _apiClient),
        RepositoryProvider<AuthRepository>.value(value: _authRepository),
        RepositoryProvider<PostsRepository>.value(value: _postsRepository),
        RepositoryProvider<CommentsRepository>.value(
          value: _commentsRepository,
        ),
        RepositoryProvider<LikesRepository>.value(value: _likesRepository),
        RepositoryProvider<NotificationsRepository>.value(
          value: _notificationsRepository,
        ),
        RepositoryProvider<ProfileRepository>.value(value: _profileRepository),
        RepositoryProvider<SearchRepository>.value(value: _searchRepository),
        RepositoryProvider<MessagesRepository>.value(
          value: _messagesRepository,
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<AuthBloc>(
            create: (_) => AuthBloc(
              repository: _authRepository,
              socialAuthService: _socialAuthService,
            ),
          ),
          BlocProvider<NotificationsBloc>(
            create: (_) =>
                NotificationsBloc(repository: _notificationsRepository),
          ),
        ],
        child: MaterialApp(
          title: 'Nova',
          debugShowCheckedModeBanner: false,
          initialRoute: '/',
          onGenerateRoute: AppRouter.onGenerateRoute,
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [Locale('en'), Locale('ar')],
          builder: (context, child) {
            _apiClient.setLanguage(
              Localizations.localeOf(context).languageCode,
            );
            return child ?? const SizedBox.shrink();
          },
          theme: ThemeData.light().copyWith(
            primaryColor: Colors.blue,
            colorScheme: ColorScheme.fromSwatch().copyWith(
              primary: Colors.blue,
              secondary: Colors.blueAccent,
            ),
          ),
          darkTheme: ThemeData.dark().copyWith(
            primaryColor: Colors.blue,
            colorScheme: ColorScheme.fromSwatch().copyWith(
              primary: Colors.blue,
              secondary: Colors.blueAccent,
            ),
          ),
          themeMode: ThemeMode.system,
        ),
      ),
    );
  }
}
