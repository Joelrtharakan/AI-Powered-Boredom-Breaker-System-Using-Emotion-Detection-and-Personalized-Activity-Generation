import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import 'screens/landing_screen.dart';
import 'screens/main_layout.dart';
import 'services/api_client.dart';
import 'services/session_manager.dart';

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
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF09090B),
        primarySwatch: Colors.blue,
        textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF09090B),
          elevation: 0,
          scrolledUnderElevation: 0,
        ),
      ),
      home: initialScreen,
    );
  }
}
