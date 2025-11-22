import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_home_ai/providers/auth_provider.dart';
import 'package:smart_home_ai/screens/login_screen.dart';
import 'package:smart_home_ai/screens/setup_screen.dart';
import 'package:smart_home_ai/screens/home_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_fonts/google_fonts.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase (Mocked for now if no config found, but good practice to try)
  try {
    await Firebase.initializeApp();
  } catch (e) {
    print("Firebase init failed (Expected if no google-services.json): $e");
  }

  runApp(
    const ProviderScope(
      child: SmartHomeApp(),
    ),
  );
}

class SmartHomeApp extends ConsumerWidget {
  const SmartHomeApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);

    return MaterialApp(
      title: 'Smart Home AI',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: Colors.cyanAccent,
        scaffoldBackgroundColor: Colors.black,
        textTheme: GoogleFonts.robotoTextTheme(ThemeData.dark().textTheme),
        useMaterial3: true,
        colorScheme: ColorScheme.dark(
          primary: Colors.cyanAccent,
          secondary: Colors.purpleAccent,
        ),
      ),
      home: _getScreen(authState),
    );
  }

  Widget _getScreen(AuthState state) {
    if (!state.isAuthenticated) {
      return const LoginScreen();
    }
    
    if (state.ownerName == null || state.assistantName == null) {
      return const SetupScreen();
    }

    return const HomeScreen();
  }
}
