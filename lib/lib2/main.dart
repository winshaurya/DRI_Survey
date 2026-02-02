import 'package:flutter/material.dart';
import 'screens/village_form_screen.dart';
import 'screens/population_form_screen.dart';
import 'screens/farm_families_screen.dart';
import 'screens/housing_screen.dart';
import 'screens/infrastructure_screen.dart';
import 'screens/infrastructure_availability_screen.dart';
import 'screens/educational_facilities_screen.dart';
import 'screens/drainage_waste_screen.dart';
import 'screens/completion_screen.dart';
import 'screens/crop_productivity_screen.dart';
import 'screens/bpl_families_screen.dart';
import 'screens/traditional_occupations_screen.dart';
import 'screens/children_not_in_school_screen.dart';
import 'screens/orchards_plants_screen.dart';
import 'screens/kitchen_gardens_screen.dart';
import 'screens/irrigation_facilities_screen.dart';
import 'screens/animals_fisheries_screen.dart';
import 'screens/transportation_screen.dart';
import 'screens/panchavati_trees_screen.dart';
import 'screens/organic_manure_screen.dart';
import 'screens/seed_clubs_screen.dart';
import 'screens/agricultural_technology_screen.dart';
import 'screens/agricultural_implements_screen.dart';
import 'screens/signboards_screen.dart';
import 'screens/unemployment_screen.dart';
import 'screens/disputes_screen.dart';
import 'screens/social_consciousness_screen.dart';
import 'screens/social_map_screen.dart';
import 'screens/survey_details_screen.dart';
import 'screens/detailed_map_screen.dart';
import 'screens/forest_map_screen.dart';
import 'screens/biodiversity_register_screen.dart';

void main() {
  runApp(VillageDataCollectionApp());
}

class VillageDataCollectionApp extends StatelessWidget {
  const VillageDataCollectionApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Village Data Collection - Digital India',
      theme: ThemeData(
        primarySwatch: Colors.purple,
        scaffoldBackgroundColor: Color(0xFFF5F5F5),
        appBarTheme: AppBarTheme(
          backgroundColor: Color(0xFF800080),
          elevation: 3,
          centerTitle: true,
          titleTextStyle: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Color(0xFF800080),
            foregroundColor: Colors.white,
            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            textStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Color(0xFF800080), width: 2),
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
        textTheme: TextTheme(
          titleLarge: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Color(0xFF800080),
          ),
        ),
      ),
      home: VillageFormScreen(),
      routes: {
        '/population': (context) => PopulationFormScreen(),
        '/farm': (context) => FarmFamiliesScreen(),
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
        '/forest-map': (context) => ForestMapScreen(),
        '/biodiversity-register': (context) => BiodiversityRegisterScreen(),
        '/completion': (context) => CompletionScreen(),
      },
      debugShowCheckedModeBanner: false,
      // Responsive wrapper for all screens
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: TextScaler.linear(1.0), // Prevent text scaling issues
          ),
          child: child!,
        );
      },
    );
  }
}