import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import 'core/theme/app_theme.dart';
import 'features/home/screens/home_screen.dart';
import 'features/game/screens/game_screen.dart';
import 'features/game/screens/difficulty_selection_screen.dart';
import 'features/auth/screens/login_screen.dart';
import 'features/avatars/screens/avatar_selection_screen.dart';
import 'features/auth/screens/signup_screen.dart';
import 'shared/models/game_enums.dart';

void main() {
  runApp(
    const ProviderScope(
      child: SnarkyHangmanApp(),
    ),
  );
}

class SnarkyHangmanApp extends StatelessWidget {
  const SnarkyHangmanApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Snarky Hangman',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      home: const LoginScreen(),
      routes: {
        '/login': (context) => const LoginScreen(),
        '/home': (context) => const HomeScreen(),
        '/difficulty': (context) => const DifficultySelectionScreen(),
        '/game': (context) => const GameScreen(),
        '/avatars': (context) => const AvatarSelectionScreen(),
        '/signup': (context) => const SignupScreen(),
      },
      debugShowCheckedModeBanner: false,
    );
  }
}
