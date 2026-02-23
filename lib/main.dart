import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:provider/provider.dart' as p;
import 'package:provider/single_child_widget.dart';

import 'l10n/app_localizations.dart';
import 'providers/locale_provider.dart';
import 'services/sync_service.dart';
import 'services/database_service.dart';
import 'services/supabase_service.dart';
import 'router.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Track whether Supabase was initialized successfully
  var supabaseInitialized = false;

  try {
    // Load environment variables (skip for web)
    if (!kIsWeb) {
      await dotenv.load(fileName: "assets/.env");
    }

    // Initialize Supabase
    final supabaseUrl = kIsWeb
        ? const String.fromEnvironment('SUPABASE_URL', defaultValue: '')
        : (dotenv.env["SUPABASE_URL"] ?? '');
    final supabaseKey = kIsWeb
        ? const String.fromEnvironment('SUPABASE_KEY', defaultValue: '')
        : (dotenv.env["SUPABASE_KEY"] ?? '');

    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseKey,
    );
    supabaseInitialized = true;

    // Initialize sync service for offline data management
    // This will start monitoring connectivity and syncing data when online
    final syncService = SyncService.instance;
    // Ensure connectivity monitoring is initialized by accessing the isOnline getter
    await syncService.isOnline;
  } catch (e) {
    // If Supabase initialization fails, continue without it
  }

  // Build provider list conditionally: only add Supabase-dependent providers
  final providers = <SingleChildWidget>[
    p.Provider<DatabaseService>(create: (_) => DatabaseService()),
  ];
  if (supabaseInitialized) {
    providers.addAll([
      p.Provider<SupabaseService>(create: (_) => SupabaseService.instance),
      p.Provider<SyncService>(create: (_) => SyncService.instance),
    ]);
  }

  runApp(
    ProviderScope(
      child: p.MultiProvider(
        providers: providers,
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
    // If Supabase wasn't initialized, skip checking and go to auth
    try {
      // Accessing Supabase.instance when it hasn't been initialized throws an assertion.
      // Guard by checking whether it's initialized via Supabase.instance (catch will handle it).
      final session = Supabase.instance.client.auth.currentSession;
      setState(() {
        _initialRoute = session != null ? '/' : '/auth';
      });
    } catch (e) {
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
