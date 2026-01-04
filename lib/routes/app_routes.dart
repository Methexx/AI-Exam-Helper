import 'package:flutter/material.dart';
import '../features/auth/login_screen.dart';
import '../features/auth/register_screen.dart';
import '../features/auth/forgot_password_screen.dart';
import '../features/scan/scan_screen.dart';
import '../features/result/result_screen.dart';
import '../features/history/history_screen.dart';
import '../features/profile/profile_screen.dart';
import '../welcome.dart';
import '../home.dart';

class AppRoutes {
  // Route Names
  static const String welcome = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';
  static const String home = '/home';
  static const String scan = '/scan';
  static const String result = '/result';
  static const String history = '/history';
  static const String profile = '/profile';

  // Route Generator
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case welcome:
        return MaterialPageRoute(builder: (_) => const WelcomeScreen());

      case login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());

      case register:
        return MaterialPageRoute(builder: (_) => const RegisterScreen());

      case forgotPassword:
        return MaterialPageRoute(builder: (_) => const ForgotPasswordScreen());

      case home:
        return MaterialPageRoute(builder: (_) => const Home());

      case scan:
        return MaterialPageRoute(builder: (_) => const ScanScreen());

      case result:
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => ResultScreen(
            question: args?['question'] ?? '',
            answer: args?['answer'] ?? '',
          ),
        );

      case history:
        return MaterialPageRoute(builder: (_) => const HistoryScreen());

      case profile:
        return MaterialPageRoute(builder: (_) => const ProfileScreen());

      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            appBar: AppBar(title: const Text('Error')),
            body: Center(child: Text('No route defined for ${settings.name}')),
          ),
        );
    }
  }

  // Navigation Helper Methods
  static void navigateToLogin(BuildContext context) {
    Navigator.pushNamed(context, login);
  }

  static void navigateToRegister(BuildContext context) {
    Navigator.pushNamed(context, register);
  }

  static void navigateToHome(BuildContext context) {
    Navigator.pushNamedAndRemoveUntil(context, home, (route) => false);
  }

  static void navigateToScan(BuildContext context) {
    Navigator.pushNamed(context, scan);
  }

  static void navigateToResult(
    BuildContext context,
    String question,
    String answer,
  ) {
    Navigator.pushNamed(
      context,
      result,
      arguments: {'question': question, 'answer': answer},
    );
  }

  static void navigateToHistory(BuildContext context) {
    Navigator.pushNamed(context, history);
  }

  static void navigateToProfile(BuildContext context) {
    Navigator.pushNamed(context, profile);
  }

  static void goBack(BuildContext context) {
    Navigator.pop(context);
  }
}
