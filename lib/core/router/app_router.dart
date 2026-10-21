import 'package:flutter/material.dart';

import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/auth/presentation/screens/splash_screen.dart';
import '../../features/posts/presentation/screens/feed_screen.dart';

class AppRouter {
  const AppRouter._();

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/':
        return MaterialPageRoute<void>(
          builder: (_) => const SplashScreen(),
          settings: settings,
        );
      case '/login':
        return MaterialPageRoute<void>(
          builder: (context) => LoginScreen(
            onSwitchToSignUp: () =>
                Navigator.of(context).pushReplacementNamed('/signup'),
          ),
          settings: settings,
        );
      case '/signup':
        return MaterialPageRoute<void>(
          builder: (context) => RegisterScreen(
            onSwitchToLogin: () =>
                Navigator.of(context).pushReplacementNamed('/login'),
          ),
          settings: settings,
        );
      case '/feed':
        return MaterialPageRoute<void>(
          builder: (_) => const FeedScreen(),
          settings: settings,
        );
      default:
        return MaterialPageRoute<void>(
          builder: (_) => const SplashScreen(),
          settings: settings,
        );
    }
  }
}
