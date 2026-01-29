import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' show Platform;

import 'l10n/app_localizations.dart';
import 'providers/locale_provider.dart';
import 'services/sync_service.dart';
import 'screens/auth/auth_screen.dart';
import 'screens/landing/landing_screen.dart';
import 'screens/family_survey/survey_screen.dart';
import 'screens/village_survey_screen.dart';
import 'screens/village_survey/infrastructure_screen.dart';
import 'screens/village_survey/infrastructure_availability_screen.dart';
import 'screens/village_survey/educational_facilities_screen.dart';
import 'screens/village_survey/drainage_waste_screen.dart';
import 'screens/village_survey/irrigation_facilities_screen.dart';
import 'screens/village_survey/seed_clubs_screen.dart';

import 'screens/village_survey/signboards_screen.dart';
import 'screens/village_survey/social_map_screen.dart';
import 'screens/village_survey/survey_details_screen.dart';
import 'screens/village_survey/detailed_map_screen.dart';
import 'screens/village_survey/cadastral_map_screen.dart';
import 'screens/village_survey/forest_map_screen.dart';
import 'screens/village_survey/biodiversity_register_screen.dart';
import 'screens/village_survey/completion_screen.dart';

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

    // Initialize sync service for offline data management
    // This will start monitoring connectivity and syncing data when online
    SyncService.instance; // Access the singleton to initialize it
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
      setState(() {
         // If session exists, go to home. Otherwise go to auth.
        _initialRoute = session != null ? '/' : '/auth';
      });
    } catch (e) {
      // If there's an error checking auth (e.g. Supabase not init), default to auth screen
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
        '/infrastructure': (context) => InfrastructureScreen(),
        '/infrastructure-availability': (context) => InfrastructureAvailabilityScreen(),
        '/educational-facilities': (context) => EducationalFacilitiesScreen(),
        '/drainage-waste': (context) => DrainageWasteScreen(),
        '/irrigation-facilities': (context) => IrrigationFacilitiesScreen(),
        '/seed-clubs': (context) => SeedClubsScreen(),
        '/signboards': (context) => SignboardsScreen(),
        '/social-map': (context) => SocialMapScreen(),
        '/survey-details': (context) => SurveyDetailsScreen(),
        '/detailed-map': (context) => DetailedMapScreen(),
        '/cadastral-map': (context) => CadastralMapScreen(),
        '/forest-map': (context) => ForestMapScreen(),
        '/biodiversity-register': (context) => BiodiversityRegisterScreen(),
        '/completion': (context) => CompletionScreen(),
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
