import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import 'screens/landing_screen.dart';

void main() {
  runApp(const ProviderScope(child: BoredomBreakerApp()));
}

class BoredomBreakerApp extends StatelessWidget {
  const BoredomBreakerApp({super.key});

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
      home: const LandingScreen(),
    );
  }
}
