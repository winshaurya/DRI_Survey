import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'l10n/app_localizations.dart';
import 'providers/locale_provider.dart';
import 'screens/auth/auth_screen.dart';
import 'screens/landing/landing_screen.dart';
import 'screens/survey/survey_screen.dart';
import 'screens/village_survey_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Load environment variables
    await dotenv.load(fileName: "assets/.env");

    // Initialize Supabase
    await Supabase.initialize(
      url: dotenv.env["SUPABASE_URL"] ?? '',
      anonKey: dotenv.env["SUPABASE_KEY"] ?? '',
    );
  } catch (e) {
    // If Supabase initialization fails, continue without it
    print('Supabase initialization failed: $e');
  }

  runApp(
    const ProviderScope(
      child: FamilySurveyApp(),
    ),
  );
}



class FamilySurveyApp extends ConsumerStatefulWidget {
  const FamilySurveyApp({super.key});

  @override
  ConsumerState<FamilySurveyApp> createState() => _FamilySurveyAppState();
}

class _FamilySurveyAppState extends ConsumerState<FamilySurveyApp> {
  String _initialRoute = '/';

  @override
  void initState() {
    super.initState();
    _checkAuthState();
  }

  void _checkAuthState() {
    try {
      final session = Supabase.instance.client.auth.currentSession;
      if (session != null) {
        // Check if session is still valid (within 25 days)
        final now = DateTime.now();
        final sessionExpiry = session.expiresAt;
        if (sessionExpiry != null) {
          final expiryDate = DateTime.fromMillisecondsSinceEpoch(sessionExpiry * 1000);
          final sessionStart = expiryDate.subtract(const Duration(days: 25));
          if (now.isAfter(sessionStart) && now.isBefore(expiryDate)) {
            // Session is valid, go to landing page
            setState(() {
              _initialRoute = '/';
            });
          }
        }
      } else {
        // No session, show auth screen first
        setState(() {
          _initialRoute = '/auth';
        });
      }
    } catch (e) {
      // If there's an error checking auth, default to auth screen
      print('Auth check failed: $e');
      setState(() {
        _initialRoute = '/auth';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final locale = ref.watch(localeProvider);

    return MaterialApp(
      title: 'DRI Survey App',
      debugShowCheckedModeBanner: false,
      locale: locale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'), // English
        Locale('hi'), // Hindi
      ],
      routes: {
        '/': (context) => const LandingScreen(),
        '/auth': (context) => const AuthScreen(),
        '/survey': (context) => const SurveyScreen(),
        '/village-survey': (context) => const VillageSurveyScreen(),
      },
      initialRoute: _initialRoute,
      theme: ThemeData(
        fontFamily: GoogleFonts.poppins().fontFamily,
        primarySwatch: Colors.green,
        brightness: Brightness.light,
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.green,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.green, width: 2),
          ),
        ),
      ),
    );
  }
}
