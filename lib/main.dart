import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:provider/provider.dart' as p;

import 'l10n/app_localizations.dart';
import 'providers/locale_provider.dart';
import 'services/sync_service.dart';
import 'services/database_service.dart';
import 'services/supabase_service.dart';
import 'router.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Load environment variables (skip for web)
    if (!kIsWeb) {
      await dotenv.load(fileName: "assets/.env");
    }

    // Initialize Supabase
    await Supabase.initialize(
      url: dotenv.env["SUPABASE_URL"] ?? '',
      anonKey: dotenv.env["SUPABASE_KEY"] ?? '',
    );

    // Initialize sync service for offline data management
    // This will start monitoring connectivity and syncing data when online
    final syncService = SyncService.instance;
    // Ensure connectivity monitoring is initialized by accessing the isOnline getter
    await syncService.isOnline;
  } catch (e) {
    // If Supabase initialization fails, continue without it
  }

  runApp(
    ProviderScope(
      child: p.MultiProvider(
        providers: [
          p.Provider<DatabaseService>(
            create: (_) => DatabaseService(),
          ),
          p.Provider<SupabaseService>(
            create: (_) => SupabaseService.instance,
          ),
          p.Provider<SyncService>(
            create: (_) => SyncService.instance,
          ),
        ],
        child: const FamilySurveyApp(),
      ),
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
      // Auth check failed
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
      routes: AppRouter.routes,
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
