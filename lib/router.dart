import 'package:flutter/material.dart';
import 'screens/auth/auth_screen.dart';
import 'screens/landing/landing_screen.dart';
import 'screens/family_survey/survey_screen.dart';
import 'screens/history/history_screen.dart';
import 'screens/village_survey_screen.dart';
import 'screens/village_survey/village_form_screen.dart';
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
import 'screens/village_survey/forest_map_screen.dart';
import 'screens/village_survey/biodiversity_register_screen.dart';
import 'screens/village_survey/completion_screen.dart';

class AppRouter {
  static const String landing = '/';
  static const String auth = '/auth';
  static const String survey = '/survey';
  static const String history = '/history';
  static const String villageSurvey = '/village-survey';
  static const String villageForm = '/village-form';
  static const String infrastructure = '/infrastructure';
  static const String infrastructureAvailability = '/infrastructure-availability';
  static const String educationalFacilities = '/educational-facilities';
  static const String drainageWaste = '/drainage-waste';
  static const String irrigationFacilities = '/irrigation-facilities';
  static const String seedClubs = '/seed-clubs';
  static const String signboards = '/signboards';
  static const String socialMap = '/social-map';
  static const String surveyDetails = '/survey-details';
  static const String detailedMap = '/detailed-map';
  static const String forestMap = '/forest-map';
  static const String biodiversityRegister = '/biodiversity-register';
  static const String completion = '/completion';

  static Map<String, WidgetBuilder> get routes => {
    landing: (context) => const LandingScreen(),
    auth: (context) => const AuthScreen(),
    survey: (context) => const SurveyScreen(),
    history: (context) => const HistoryScreen(),
    villageSurvey: (context) => const VillageSurveyScreen(),
    villageForm: (context) => const VillageFormScreen(),
    infrastructure: (context) => InfrastructureScreen(),
    infrastructureAvailability: (context) => InfrastructureAvailabilityScreen(),
    educationalFacilities: (context) => EducationalFacilitiesScreen(),
    drainageWaste: (context) => const DrainageWasteScreen(),
    irrigationFacilities: (context) => IrrigationFacilitiesScreen(),
    seedClubs: (context) => SeedClubsScreen(),
    signboards: (context) => SignboardsScreen(),
    socialMap: (context) => SocialMapScreen(),
    surveyDetails: (context) => SurveyDetailsScreen(),
    detailedMap: (context) => DetailedMapScreen(),
    forestMap: (context) => ForestMapScreen(),
    biodiversityRegister: (context) => BiodiversityRegisterScreen(),
    completion: (context) => CompletionScreen(),
  };

  // Navigation methods
  static void navigateTo(BuildContext context, String routeName, {Object? arguments}) {
    Navigator.pushNamed(context, routeName, arguments: arguments);
  }

  static void navigateToAndReplace(BuildContext context, String routeName, {Object? arguments}) {
    Navigator.pushReplacementNamed(context, routeName, arguments: arguments);
  }

  static void navigateToAndRemoveUntil(BuildContext context, String routeName, {Object? arguments}) {
    Navigator.pushNamedAndRemoveUntil(
      context,
      routeName,
      (route) => false, // Remove all previous routes
      arguments: arguments,
    );
  }

  static void goBack(BuildContext context) {
    Navigator.pop(context);
  }

  static void goBackWithResult(BuildContext context, dynamic result) {
    Navigator.pop(context, result);
  }

  // Village survey flow navigation
  static const List<String> villageSurveyFlow = [
    villageForm,
    infrastructure,
    infrastructureAvailability,
    educationalFacilities,
    drainageWaste,
    irrigationFacilities,
    seedClubs,
    signboards,
    socialMap,
    surveyDetails,
    detailedMap,
    forestMap,
    biodiversityRegister,
    completion,
  ];

  static void navigateToNextInFlow(BuildContext context, String currentRoute) {
    final currentIndex = villageSurveyFlow.indexOf(currentRoute);
    if (currentIndex != -1 && currentIndex < villageSurveyFlow.length - 1) {
      navigateTo(context, villageSurveyFlow[currentIndex + 1]);
    }
  }

  static void navigateToPreviousInFlow(BuildContext context, String currentRoute) {
    final currentIndex = villageSurveyFlow.indexOf(currentRoute);
    if (currentIndex > 0) {
      navigateToAndReplace(context, villageSurveyFlow[currentIndex - 1]);
    }
  }

  static bool canNavigateNext(String currentRoute) {
    final currentIndex = villageSurveyFlow.indexOf(currentRoute);
    return currentIndex != -1 && currentIndex < villageSurveyFlow.length - 1;
  }

  static bool canNavigatePrevious(String currentRoute) {
    final currentIndex = villageSurveyFlow.indexOf(currentRoute);
    return currentIndex > 0;
  }

  static String? getNextRoute(String currentRoute) {
    final currentIndex = villageSurveyFlow.indexOf(currentRoute);
    if (currentIndex != -1 && currentIndex < villageSurveyFlow.length - 1) {
      return villageSurveyFlow[currentIndex + 1];
    }
    return null;
  }

  static String? getPreviousRoute(String currentRoute) {
    final currentIndex = villageSurveyFlow.indexOf(currentRoute);
    if (currentIndex > 0) {
      return villageSurveyFlow[currentIndex - 1];
    }
    return null;
  }

  static String getRouteTitle(String route) {
    switch (route) {
      case landing:
        return 'DRI Survey App';
      case auth:
        return 'Authentication';
      case survey:
        return 'Family Survey';
      case villageSurvey:
        return 'Village Survey';
      case villageForm:
        return 'Village Information';
      case infrastructure:
        return 'Infrastructure';
      case infrastructureAvailability:
        return 'Infrastructure Availability';
      case educationalFacilities:
        return 'Educational Facilities';
      case drainageWaste:
        return 'Drainage & Waste';
      case irrigationFacilities:
        return 'Irrigation Facilities';
      case seedClubs:
        return 'Seed Clubs';
      case signboards:
        return 'Signboards';
      case socialMap:
        return 'Social Map';
      case surveyDetails:
        return 'Survey Details';
      case detailedMap:
        return 'Detailed Map';
      case forestMap:
        return 'Forest Map';
      case biodiversityRegister:
        return 'Biodiversity Register';
      case completion:
        return 'Survey Complete';
      default:
        return 'Unknown Route';
    }
  }

  static IconData getRouteIcon(String route) {
    switch (route) {
      case landing:
        return Icons.home;
      case auth:
        return Icons.login;
      case survey:
        return Icons.family_restroom;
      case villageSurvey:
        return Icons.location_city;
      case villageForm:
        return Icons.info;
      case infrastructure:
        return Icons.engineering;
      case infrastructureAvailability:
        return Icons.business;
      case educationalFacilities:
        return Icons.school;
      case drainageWaste:
        return Icons.water_drop;
      case irrigationFacilities:
        return Icons.agriculture;
      case seedClubs:
        return Icons.grass;
      case signboards:
        return Icons.signpost;
      case socialMap:
        return Icons.map;
      case surveyDetails:
        return Icons.description;
      case detailedMap:
        return Icons.map_outlined;
      case forestMap:
        return Icons.forest;
      case biodiversityRegister:
        return Icons.eco;
      case completion:
        return Icons.check_circle;
      default:
        return Icons.help;
    }
  }
}