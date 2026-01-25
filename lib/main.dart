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
import 'screens/auth/auth_screen.dart';
import 'screens/landing/landing_screen.dart';
import 'screens/family_survey/survey_screen.dart';
import 'screens/village_survey_screen.dart';
import 'screens/village_survey/population_form_screen.dart';
import 'screens/village_survey/farm_families_screen.dart';
import 'screens/village_survey/housing_screen.dart';
import 'screens/village_survey/infrastructure_screen.dart';
import 'screens/village_survey/infrastructure_availability_screen.dart';
import 'screens/village_survey/educational_facilities_screen.dart';
import 'screens/village_survey/drainage_waste_screen.dart';
import 'screens/village_survey/crop_productivity_screen.dart';
import 'screens/village_survey/bpl_families_screen.dart';
import 'screens/village_survey/traditional_occupations_screen.dart';
import 'screens/village_survey/children_not_in_school_screen.dart';
import 'screens/village_survey/orchards_plants_screen.dart';
import 'screens/village_survey/kitchen_gardens_screen.dart';
import 'screens/village_survey/irrigation_facilities_screen.dart';
import 'screens/village_survey/animals_fisheries_screen.dart';
import 'screens/village_survey/transportation_screen.dart';
import 'screens/village_survey/panchavati_trees_screen.dart';
import 'screens/village_survey/organic_manure_screen.dart';
import 'screens/village_survey/seed_clubs_screen.dart';
import 'screens/village_survey/agricultural_technology_screen.dart';
import 'screens/village_survey/agricultural_implements_screen.dart';
import 'screens/village_survey/signboards_screen.dart';
import 'screens/village_survey/unemployment_screen.dart';
import 'screens/village_survey/disputes_screen.dart';
import 'screens/village_survey/social_consciousness_screen.dart';
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
        '/population': (context) => PopulationFormScreen(),
        '/farm-families': (context) => FarmFamiliesScreen(),
        '/housing': (context) => HousingScreen(),
        '/infrastructure': (context) => InfrastructureScreen(),
        '/infrastructure-availability': (context) => InfrastructureAvailabilityScreen(),
        '/educational-facilities': (context) => EducationalFacilitiesScreen(),
        '/drainage-waste': (context) => DrainageWasteScreen(),
        '/crop-productivity': (context) => CropProductivityScreen(),
        '/bpl-families': (context) => BPLFamiliesScreen(),
        '/traditional-occupations': (context) => TraditionalOccupationsScreen(),
        '/children-not-in-school': (context) => ChildrenNotInSchoolScreen(),
        '/orchards-plants': (context) => OrchardsPlantsScreen(),
        '/kitchen-gardens': (context) => KitchenGardensScreen(),
        '/irrigation-facilities': (context) => IrrigationFacilitiesScreen(),
        '/animals-fisheries': (context) => AnimalsFisheriesScreen(),
        '/transportation': (context) => TransportationScreen(),
        '/panchavati-trees': (context) => PanchavatiTreesScreen(),
        '/organic-manure': (context) => OrganicManureScreen(),
        '/seed-clubs': (context) => SeedClubsScreen(),
        '/agricultural-technology': (context) => AgriculturalTechnologyScreen(),
        '/agricultural-implements': (context) => AgriculturalImplementsScreen(),
        '/signboards': (context) => SignboardsScreen(),
        '/unemployment': (context) => UnemploymentScreen(),
        '/disputes': (context) => DisputesScreen(),
        '/social-consciousness': (context) => SocialConsciousnessScreen(),
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
