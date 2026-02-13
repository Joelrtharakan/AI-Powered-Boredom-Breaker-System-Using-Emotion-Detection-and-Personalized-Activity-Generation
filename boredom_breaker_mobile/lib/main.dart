import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'screens/landing_screen.dart';
import 'screens/main_layout.dart';
import 'services/api_client.dart';
import 'services/session_manager.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize session and token
  final token = await SessionManager.getToken();
  if (token != null) {
    ApiClient.setToken(token);
  }

  final bool loggedIn = await SessionManager.isLoggedIn();

  runApp(
    ProviderScope(
      child: BoredomBreakerApp(
        initialScreen: loggedIn ? const MainLayout() : const LandingScreen(),
      ),
    ),
  );
}

class BoredomBreakerApp extends StatelessWidget {
  final Widget initialScreen;
  const BoredomBreakerApp({super.key, required this.initialScreen});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Boredom Breaker',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: initialScreen,
    );
  }
}
