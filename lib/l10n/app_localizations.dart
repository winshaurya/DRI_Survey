import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_hi.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('hi')
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'DRI Survey App'**
  String get appTitle;

  /// No description provided for @startFamilyQuiz.
  ///
  /// In en, this message translates to:
  /// **'Start Family Quiz'**
  String get startFamilyQuiz;

  /// No description provided for @villageName.
  ///
  /// In en, this message translates to:
  /// **'Village Name'**
  String get villageName;

  /// No description provided for @panchayat.
  ///
  /// In en, this message translates to:
  /// **'Panchayat'**
  String get panchayat;

  /// No description provided for @block.
  ///
  /// In en, this message translates to:
  /// **'Block'**
  String get block;

  /// No description provided for @tehsil.
  ///
  /// In en, this message translates to:
  /// **'Tehsil'**
  String get tehsil;

  /// No description provided for @district.
  ///
  /// In en, this message translates to:
  /// **'District'**
  String get district;

  /// No description provided for @postalAddress.
  ///
  /// In en, this message translates to:
  /// **'Postal Address'**
  String get postalAddress;

  /// No description provided for @pinCode.
  ///
  /// In en, this message translates to:
  /// **'Pin Code'**
  String get pinCode;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @previous.
  ///
  /// In en, this message translates to:
  /// **'Previous'**
  String get previous;

  /// No description provided for @submit.
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get submit;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @yes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get yes;

  /// No description provided for @no.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get no;

  /// No description provided for @selectLanguage.
  ///
  /// In en, this message translates to:
  /// **'Select Language'**
  String get selectLanguage;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @hindi.
  ///
  /// In en, this message translates to:
  /// **'हिंदी'**
  String get hindi;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @phoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get phoneNumber;

  /// No description provided for @enterPhoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Enter your phone number'**
  String get enterPhoneNumber;

  /// No description provided for @verify.
  ///
  /// In en, this message translates to:
  /// **'Verify'**
  String get verify;

  /// No description provided for @enterOtp.
  ///
  /// In en, this message translates to:
  /// **'Enter OTP'**
  String get enterOtp;

  /// No description provided for @resendOtp.
  ///
  /// In en, this message translates to:
  /// **'Resend OTP'**
  String get resendOtp;

  /// No description provided for @welcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome'**
  String get welcome;

  /// No description provided for @familyDetails.
  ///
  /// In en, this message translates to:
  /// **'Family Details'**
  String get familyDetails;

  /// No description provided for @memberName.
  ///
  /// In en, this message translates to:
  /// **'Member Name'**
  String get memberName;

  /// No description provided for @age.
  ///
  /// In en, this message translates to:
  /// **'Age'**
  String get age;

  /// No description provided for @sex.
  ///
  /// In en, this message translates to:
  /// **'Sex'**
  String get sex;

  /// No description provided for @male.
  ///
  /// In en, this message translates to:
  /// **'Male'**
  String get male;

  /// No description provided for @female.
  ///
  /// In en, this message translates to:
  /// **'Female'**
  String get female;

  /// No description provided for @other.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get other;

  /// No description provided for @relation.
  ///
  /// In en, this message translates to:
  /// **'Relation'**
  String get relation;

  /// No description provided for @education.
  ///
  /// In en, this message translates to:
  /// **'Education'**
  String get education;

  /// No description provided for @occupation.
  ///
  /// In en, this message translates to:
  /// **'Occupation'**
  String get occupation;

  /// No description provided for @addMember.
  ///
  /// In en, this message translates to:
  /// **'Add Member'**
  String get addMember;

  /// No description provided for @landHolding.
  ///
  /// In en, this message translates to:
  /// **'Land Holding'**
  String get landHolding;

  /// No description provided for @irrigatedArea.
  ///
  /// In en, this message translates to:
  /// **'Irrigated Area (Acres)'**
  String get irrigatedArea;

  /// No description provided for @cultivableArea.
  ///
  /// In en, this message translates to:
  /// **'Cultivable Area (Acres)'**
  String get cultivableArea;

  /// No description provided for @orchardPlants.
  ///
  /// In en, this message translates to:
  /// **'Orchard Plants'**
  String get orchardPlants;

  /// No description provided for @irrigationFacilities.
  ///
  /// In en, this message translates to:
  /// **'Irrigation Facilities'**
  String get irrigationFacilities;

  /// No description provided for @canal.
  ///
  /// In en, this message translates to:
  /// **'Canal'**
  String get canal;

  /// No description provided for @tubeWell.
  ///
  /// In en, this message translates to:
  /// **'Tube Well'**
  String get tubeWell;

  /// No description provided for @ponds.
  ///
  /// In en, this message translates to:
  /// **'Ponds'**
  String get ponds;

  /// No description provided for @otherFacilities.
  ///
  /// In en, this message translates to:
  /// **'Other Facilities'**
  String get otherFacilities;

  /// No description provided for @cropProductivity.
  ///
  /// In en, this message translates to:
  /// **'Crop Productivity'**
  String get cropProductivity;

  /// No description provided for @cropName.
  ///
  /// In en, this message translates to:
  /// **'Crop Name'**
  String get cropName;

  /// No description provided for @areaAcres.
  ///
  /// In en, this message translates to:
  /// **'Area (Acres)'**
  String get areaAcres;

  /// No description provided for @productivity.
  ///
  /// In en, this message translates to:
  /// **'Productivity (Quintal/Acre)'**
  String get productivity;

  /// No description provided for @totalProduction.
  ///
  /// In en, this message translates to:
  /// **'Total Production'**
  String get totalProduction;

  /// No description provided for @quantityConsumed.
  ///
  /// In en, this message translates to:
  /// **'Quantity Consumed'**
  String get quantityConsumed;

  /// No description provided for @quantitySold.
  ///
  /// In en, this message translates to:
  /// **'Quantity Sold'**
  String get quantitySold;

  /// No description provided for @fertilizerUsage.
  ///
  /// In en, this message translates to:
  /// **'Fertilizer Usage'**
  String get fertilizerUsage;

  /// No description provided for @chemical.
  ///
  /// In en, this message translates to:
  /// **'Chemical'**
  String get chemical;

  /// No description provided for @organic.
  ///
  /// In en, this message translates to:
  /// **'Organic'**
  String get organic;

  /// No description provided for @animals.
  ///
  /// In en, this message translates to:
  /// **'Animals'**
  String get animals;

  /// No description provided for @animalType.
  ///
  /// In en, this message translates to:
  /// **'Animal Type'**
  String get animalType;

  /// No description provided for @numberOfAnimals.
  ///
  /// In en, this message translates to:
  /// **'Number of Animals'**
  String get numberOfAnimals;

  /// No description provided for @breed.
  ///
  /// In en, this message translates to:
  /// **'Breed'**
  String get breed;

  /// No description provided for @productionPerAnimal.
  ///
  /// In en, this message translates to:
  /// **'Production per Animal'**
  String get productionPerAnimal;

  /// No description provided for @agriculturalEquipment.
  ///
  /// In en, this message translates to:
  /// **'Agricultural Equipment'**
  String get agriculturalEquipment;

  /// No description provided for @tractor.
  ///
  /// In en, this message translates to:
  /// **'Tractor'**
  String get tractor;

  /// No description provided for @thresher.
  ///
  /// In en, this message translates to:
  /// **'Thresher'**
  String get thresher;

  /// No description provided for @seedDrill.
  ///
  /// In en, this message translates to:
  /// **'Seed Drill'**
  String get seedDrill;

  /// No description provided for @sprayer.
  ///
  /// In en, this message translates to:
  /// **'Sprayer'**
  String get sprayer;

  /// No description provided for @duster.
  ///
  /// In en, this message translates to:
  /// **'Duster'**
  String get duster;

  /// No description provided for @dieselEngine.
  ///
  /// In en, this message translates to:
  /// **'Diesel Engine'**
  String get dieselEngine;

  /// No description provided for @entertainmentFacilities.
  ///
  /// In en, this message translates to:
  /// **'Entertainment Facilities'**
  String get entertainmentFacilities;

  /// No description provided for @smartMobile.
  ///
  /// In en, this message translates to:
  /// **'Smart Mobile'**
  String get smartMobile;

  /// No description provided for @analogMobile.
  ///
  /// In en, this message translates to:
  /// **'Analog Mobile'**
  String get analogMobile;

  /// No description provided for @television.
  ///
  /// In en, this message translates to:
  /// **'Television'**
  String get television;

  /// No description provided for @radio.
  ///
  /// In en, this message translates to:
  /// **'Radio'**
  String get radio;

  /// No description provided for @games.
  ///
  /// In en, this message translates to:
  /// **'Games'**
  String get games;

  /// No description provided for @transportFacilities.
  ///
  /// In en, this message translates to:
  /// **'Transport Facilities'**
  String get transportFacilities;

  /// No description provided for @carJeep.
  ///
  /// In en, this message translates to:
  /// **'Car/Jeep'**
  String get carJeep;

  /// No description provided for @motorcycleScooter.
  ///
  /// In en, this message translates to:
  /// **'Motorcycle/Scooter'**
  String get motorcycleScooter;

  /// No description provided for @eRickshaw.
  ///
  /// In en, this message translates to:
  /// **'E-Rickshaw'**
  String get eRickshaw;

  /// No description provided for @cycle.
  ///
  /// In en, this message translates to:
  /// **'Cycle'**
  String get cycle;

  /// No description provided for @pickupTruck.
  ///
  /// In en, this message translates to:
  /// **'Pickup Truck'**
  String get pickupTruck;

  /// No description provided for @bullockCart.
  ///
  /// In en, this message translates to:
  /// **'Bullock Cart'**
  String get bullockCart;

  /// No description provided for @drinkingWaterSources.
  ///
  /// In en, this message translates to:
  /// **'Drinking Water Sources'**
  String get drinkingWaterSources;

  /// No description provided for @handPumps.
  ///
  /// In en, this message translates to:
  /// **'Hand Pumps'**
  String get handPumps;

  /// No description provided for @well.
  ///
  /// In en, this message translates to:
  /// **'Well'**
  String get well;

  /// No description provided for @tubewell.
  ///
  /// In en, this message translates to:
  /// **'Tubewell'**
  String get tubewell;

  /// No description provided for @nalJaal.
  ///
  /// In en, this message translates to:
  /// **'Nal Jaal'**
  String get nalJaal;

  /// No description provided for @distance.
  ///
  /// In en, this message translates to:
  /// **'Distance (km)'**
  String get distance;

  /// No description provided for @medicalTreatment.
  ///
  /// In en, this message translates to:
  /// **'Medical Treatment'**
  String get medicalTreatment;

  /// No description provided for @allopathic.
  ///
  /// In en, this message translates to:
  /// **'Allopathic'**
  String get allopathic;

  /// No description provided for @ayurvedic.
  ///
  /// In en, this message translates to:
  /// **'Ayurvedic'**
  String get ayurvedic;

  /// No description provided for @homeopathy.
  ///
  /// In en, this message translates to:
  /// **'Homeopathy'**
  String get homeopathy;

  /// No description provided for @traditional.
  ///
  /// In en, this message translates to:
  /// **'Traditional'**
  String get traditional;

  /// No description provided for @jhadPhook.
  ///
  /// In en, this message translates to:
  /// **'Jhad Phook'**
  String get jhadPhook;

  /// No description provided for @disputes.
  ///
  /// In en, this message translates to:
  /// **'Disputes'**
  String get disputes;

  /// No description provided for @familyDisputes.
  ///
  /// In en, this message translates to:
  /// **'Family Disputes'**
  String get familyDisputes;

  /// No description provided for @revenueDisputes.
  ///
  /// In en, this message translates to:
  /// **'Revenue Disputes'**
  String get revenueDisputes;

  /// No description provided for @criminalDisputes.
  ///
  /// In en, this message translates to:
  /// **'Criminal Disputes'**
  String get criminalDisputes;

  /// No description provided for @disputePeriod.
  ///
  /// In en, this message translates to:
  /// **'Dispute Period'**
  String get disputePeriod;

  /// No description provided for @houseConditions.
  ///
  /// In en, this message translates to:
  /// **'House Conditions'**
  String get houseConditions;

  /// No description provided for @katcha.
  ///
  /// In en, this message translates to:
  /// **'Katcha'**
  String get katcha;

  /// No description provided for @pakka.
  ///
  /// In en, this message translates to:
  /// **'Pakka'**
  String get pakka;

  /// No description provided for @katchaPakka.
  ///
  /// In en, this message translates to:
  /// **'Katcha-Pakka'**
  String get katchaPakka;

  /// No description provided for @hut.
  ///
  /// In en, this message translates to:
  /// **'Hut'**
  String get hut;

  /// No description provided for @houseFacilities.
  ///
  /// In en, this message translates to:
  /// **'House Facilities'**
  String get houseFacilities;

  /// No description provided for @toilet.
  ///
  /// In en, this message translates to:
  /// **'Toilet'**
  String get toilet;

  /// No description provided for @drainage.
  ///
  /// In en, this message translates to:
  /// **'Drainage'**
  String get drainage;

  /// No description provided for @soakPit.
  ///
  /// In en, this message translates to:
  /// **'Soak Pit'**
  String get soakPit;

  /// No description provided for @cattleShed.
  ///
  /// In en, this message translates to:
  /// **'Cattle Shed'**
  String get cattleShed;

  /// No description provided for @compostPit.
  ///
  /// In en, this message translates to:
  /// **'Compost Pit'**
  String get compostPit;

  /// No description provided for @nadep.
  ///
  /// In en, this message translates to:
  /// **'NADEP'**
  String get nadep;

  /// No description provided for @lpgGas.
  ///
  /// In en, this message translates to:
  /// **'LPG Gas'**
  String get lpgGas;

  /// No description provided for @biogas.
  ///
  /// In en, this message translates to:
  /// **'Biogas'**
  String get biogas;

  /// No description provided for @solarCooking.
  ///
  /// In en, this message translates to:
  /// **'Solar Cooking'**
  String get solarCooking;

  /// No description provided for @electricConnection.
  ///
  /// In en, this message translates to:
  /// **'Electric Connection'**
  String get electricConnection;

  /// No description provided for @nutritionalGarden.
  ///
  /// In en, this message translates to:
  /// **'Nutritional Kitchen Garden'**
  String get nutritionalGarden;

  /// No description provided for @seriousDiseases.
  ///
  /// In en, this message translates to:
  /// **'Serious Diseases'**
  String get seriousDiseases;

  /// No description provided for @diseaseName.
  ///
  /// In en, this message translates to:
  /// **'Disease Name'**
  String get diseaseName;

  /// No description provided for @sufferingSince.
  ///
  /// In en, this message translates to:
  /// **'Suffering Since'**
  String get sufferingSince;

  /// No description provided for @treatmentFrom.
  ///
  /// In en, this message translates to:
  /// **'Treatment From'**
  String get treatmentFrom;

  /// No description provided for @governmentSchemes.
  ///
  /// In en, this message translates to:
  /// **'Government Schemes'**
  String get governmentSchemes;

  /// No description provided for @haveCard.
  ///
  /// In en, this message translates to:
  /// **'Have Card'**
  String get haveCard;

  /// No description provided for @nameIncluded.
  ///
  /// In en, this message translates to:
  /// **'Name Included'**
  String get nameIncluded;

  /// No description provided for @detailsCorrect.
  ///
  /// In en, this message translates to:
  /// **'Details Correct'**
  String get detailsCorrect;

  /// No description provided for @eligible.
  ///
  /// In en, this message translates to:
  /// **'Eligible'**
  String get eligible;

  /// No description provided for @registered.
  ///
  /// In en, this message translates to:
  /// **'Registered'**
  String get registered;

  /// No description provided for @aadhaar.
  ///
  /// In en, this message translates to:
  /// **'Aadhaar'**
  String get aadhaar;

  /// No description provided for @ayushman.
  ///
  /// In en, this message translates to:
  /// **'Ayushman'**
  String get ayushman;

  /// No description provided for @familyId.
  ///
  /// In en, this message translates to:
  /// **'Family ID'**
  String get familyId;

  /// No description provided for @rationCard.
  ///
  /// In en, this message translates to:
  /// **'Ration Card'**
  String get rationCard;

  /// No description provided for @samagraId.
  ///
  /// In en, this message translates to:
  /// **'Samagra ID'**
  String get samagraId;

  /// No description provided for @tribalCard.
  ///
  /// In en, this message translates to:
  /// **'Tribal Card'**
  String get tribalCard;

  /// No description provided for @handicappedAllowance.
  ///
  /// In en, this message translates to:
  /// **'Handicapped Allowance'**
  String get handicappedAllowance;

  /// No description provided for @pensionAllowance.
  ///
  /// In en, this message translates to:
  /// **'Pension Allowance'**
  String get pensionAllowance;

  /// No description provided for @widowAllowance.
  ///
  /// In en, this message translates to:
  /// **'Widow Allowance'**
  String get widowAllowance;

  /// No description provided for @folkloreMedicine.
  ///
  /// In en, this message translates to:
  /// **'Folklore Medicine'**
  String get folkloreMedicine;

  /// No description provided for @plantLocalName.
  ///
  /// In en, this message translates to:
  /// **'Plant Local Name'**
  String get plantLocalName;

  /// No description provided for @plantBotanicalName.
  ///
  /// In en, this message translates to:
  /// **'Plant Botanical Name'**
  String get plantBotanicalName;

  /// No description provided for @plantUses.
  ///
  /// In en, this message translates to:
  /// **'Plant Uses'**
  String get plantUses;

  /// No description provided for @healthPrograms.
  ///
  /// In en, this message translates to:
  /// **'Health Programs'**
  String get healthPrograms;

  /// No description provided for @vaccination.
  ///
  /// In en, this message translates to:
  /// **'Vaccination'**
  String get vaccination;

  /// No description provided for @familyPlanning.
  ///
  /// In en, this message translates to:
  /// **'Family Planning'**
  String get familyPlanning;

  /// No description provided for @contraceptiveApplied.
  ///
  /// In en, this message translates to:
  /// **'Contraceptive Applied'**
  String get contraceptiveApplied;

  /// No description provided for @childrenData.
  ///
  /// In en, this message translates to:
  /// **'Children\'s Data'**
  String get childrenData;

  /// No description provided for @birthsLast3Years.
  ///
  /// In en, this message translates to:
  /// **'Births in Last 3 Years'**
  String get birthsLast3Years;

  /// No description provided for @infantDeathsLast3Years.
  ///
  /// In en, this message translates to:
  /// **'Infant Deaths in Last 3 Years'**
  String get infantDeathsLast3Years;

  /// No description provided for @malnourishedChildren.
  ///
  /// In en, this message translates to:
  /// **'Malnourished Children'**
  String get malnourishedChildren;

  /// No description provided for @malnutritionData.
  ///
  /// In en, this message translates to:
  /// **'Malnutrition Data'**
  String get malnutritionData;

  /// No description provided for @height.
  ///
  /// In en, this message translates to:
  /// **'Height (feet)'**
  String get height;

  /// No description provided for @weight.
  ///
  /// In en, this message translates to:
  /// **'Weight (kg)'**
  String get weight;

  /// No description provided for @causeDisease.
  ///
  /// In en, this message translates to:
  /// **'Cause/Disease'**
  String get causeDisease;

  /// No description provided for @tulsiPlants.
  ///
  /// In en, this message translates to:
  /// **'Tulsi Plants'**
  String get tulsiPlants;

  /// No description provided for @migration.
  ///
  /// In en, this message translates to:
  /// **'Migration'**
  String get migration;

  /// No description provided for @migrationType.
  ///
  /// In en, this message translates to:
  /// **'Migration Type'**
  String get migrationType;

  /// No description provided for @permanent.
  ///
  /// In en, this message translates to:
  /// **'Permanent'**
  String get permanent;

  /// No description provided for @seasonal.
  ///
  /// In en, this message translates to:
  /// **'Seasonal'**
  String get seasonal;

  /// No description provided for @asNeeded.
  ///
  /// In en, this message translates to:
  /// **'As Needed'**
  String get asNeeded;

  /// No description provided for @jobDescription.
  ///
  /// In en, this message translates to:
  /// **'Job Description'**
  String get jobDescription;

  /// No description provided for @training.
  ///
  /// In en, this message translates to:
  /// **'Training'**
  String get training;

  /// No description provided for @trainingType.
  ///
  /// In en, this message translates to:
  /// **'Training Type'**
  String get trainingType;

  /// No description provided for @institute.
  ///
  /// In en, this message translates to:
  /// **'Institute'**
  String get institute;

  /// No description provided for @yearOfPassing.
  ///
  /// In en, this message translates to:
  /// **'Year of Passing'**
  String get yearOfPassing;

  /// No description provided for @selfHelpGroups.
  ///
  /// In en, this message translates to:
  /// **'Self Help Groups'**
  String get selfHelpGroups;

  /// No description provided for @shgName.
  ///
  /// In en, this message translates to:
  /// **'SHG Name'**
  String get shgName;

  /// No description provided for @purpose.
  ///
  /// In en, this message translates to:
  /// **'Purpose'**
  String get purpose;

  /// No description provided for @agency.
  ///
  /// In en, this message translates to:
  /// **'Agency'**
  String get agency;

  /// No description provided for @fpoMembership.
  ///
  /// In en, this message translates to:
  /// **'FPO Membership'**
  String get fpoMembership;

  /// No description provided for @fpoName.
  ///
  /// In en, this message translates to:
  /// **'FPO Name'**
  String get fpoName;

  /// No description provided for @beneficiaryPrograms.
  ///
  /// In en, this message translates to:
  /// **'Beneficiary Programs'**
  String get beneficiaryPrograms;

  /// No description provided for @vbGram.
  ///
  /// In en, this message translates to:
  /// **'VB GRAM'**
  String get vbGram;

  /// No description provided for @pmKisanNidhi.
  ///
  /// In en, this message translates to:
  /// **'PM Kisan Nidhi'**
  String get pmKisanNidhi;

  /// No description provided for @pmKisanSamman.
  ///
  /// In en, this message translates to:
  /// **'PM Kisan Samman'**
  String get pmKisanSamman;

  /// No description provided for @kisanCreditCard.
  ///
  /// In en, this message translates to:
  /// **'Kisan Credit Card'**
  String get kisanCreditCard;

  /// No description provided for @swachhBharat.
  ///
  /// In en, this message translates to:
  /// **'Swachh Bharat'**
  String get swachhBharat;

  /// No description provided for @fasalBima.
  ///
  /// In en, this message translates to:
  /// **'Fasal Bima'**
  String get fasalBima;

  /// No description provided for @received.
  ///
  /// In en, this message translates to:
  /// **'Received'**
  String get received;

  /// No description provided for @daysWorked.
  ///
  /// In en, this message translates to:
  /// **'Days Worked'**
  String get daysWorked;

  /// No description provided for @bankAccounts.
  ///
  /// In en, this message translates to:
  /// **'Bank Accounts'**
  String get bankAccounts;

  /// No description provided for @hasAccount.
  ///
  /// In en, this message translates to:
  /// **'Has Account'**
  String get hasAccount;

  /// No description provided for @socialConsciousness.
  ///
  /// In en, this message translates to:
  /// **'Social Consciousness'**
  String get socialConsciousness;

  /// No description provided for @tribalQuestions.
  ///
  /// In en, this message translates to:
  /// **'Tribal Questions'**
  String get tribalQuestions;

  /// No description provided for @individualForestClaims.
  ///
  /// In en, this message translates to:
  /// **'Individual Forest Claims'**
  String get individualForestClaims;

  /// No description provided for @claimMap.
  ///
  /// In en, this message translates to:
  /// **'Claim Map'**
  String get claimMap;

  /// No description provided for @palashLeafCollector.
  ///
  /// In en, this message translates to:
  /// **'Palash Leaf Collector'**
  String get palashLeafCollector;

  /// No description provided for @collectionAreas.
  ///
  /// In en, this message translates to:
  /// **'Collection Areas'**
  String get collectionAreas;

  /// No description provided for @honeyGatherer.
  ///
  /// In en, this message translates to:
  /// **'Honey Gatherer'**
  String get honeyGatherer;

  /// No description provided for @honeyCollectionAreas.
  ///
  /// In en, this message translates to:
  /// **'Honey Collection Areas'**
  String get honeyCollectionAreas;

  /// No description provided for @ntfpIdentification.
  ///
  /// In en, this message translates to:
  /// **'NTFP Identification'**
  String get ntfpIdentification;

  /// No description provided for @stakeholderShgs.
  ///
  /// In en, this message translates to:
  /// **'Stakeholder SHGs'**
  String get stakeholderShgs;

  /// No description provided for @skillsIdentification.
  ///
  /// In en, this message translates to:
  /// **'Skills Identification'**
  String get skillsIdentification;

  /// No description provided for @surveyCompleted.
  ///
  /// In en, this message translates to:
  /// **'Survey Completed Successfully!'**
  String get surveyCompleted;

  /// No description provided for @dataSavedLocally.
  ///
  /// In en, this message translates to:
  /// **'Data saved locally'**
  String get dataSavedLocally;

  /// No description provided for @syncPending.
  ///
  /// In en, this message translates to:
  /// **'Sync pending'**
  String get syncPending;

  /// No description provided for @syncCompleted.
  ///
  /// In en, this message translates to:
  /// **'Sync completed'**
  String get syncCompleted;

  /// No description provided for @errorSavingData.
  ///
  /// In en, this message translates to:
  /// **'Error saving data'**
  String get errorSavingData;

  /// No description provided for @pleaseFillRequiredFields.
  ///
  /// In en, this message translates to:
  /// **'Please fill all required fields'**
  String get pleaseFillRequiredFields;

  /// No description provided for @invalidPhoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Invalid phone number'**
  String get invalidPhoneNumber;

  /// No description provided for @invalidOtp.
  ///
  /// In en, this message translates to:
  /// **'Invalid OTP'**
  String get invalidOtp;

  /// No description provided for @networkError.
  ///
  /// In en, this message translates to:
  /// **'Network error'**
  String get networkError;

  /// No description provided for @syncError.
  ///
  /// In en, this message translates to:
  /// **'Sync error'**
  String get syncError;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @gotIt.
  ///
  /// In en, this message translates to:
  /// **'Got It'**
  String get gotIt;

  /// No description provided for @help.
  ///
  /// In en, this message translates to:
  /// **'Help'**
  String get help;

  /// No description provided for @stepOfTotal.
  ///
  /// In en, this message translates to:
  /// **'Step {current} of {total}'**
  String stepOfTotal(Object current, Object total);

  /// No description provided for @exportAllSurveysSuccess.
  ///
  /// In en, this message translates to:
  /// **'All surveys exported successfully'**
  String get exportAllSurveysSuccess;

  /// No description provided for @exportSummarySuccess.
  ///
  /// In en, this message translates to:
  /// **'Summary exported successfully'**
  String get exportSummarySuccess;

  /// No description provided for @exportBackupSuccess.
  ///
  /// In en, this message translates to:
  /// **'Backup exported successfully'**
  String get exportBackupSuccess;

  /// No description provided for @exportFailed.
  ///
  /// In en, this message translates to:
  /// **'Export failed: {error}'**
  String exportFailed(Object error);

  /// No description provided for @exportData.
  ///
  /// In en, this message translates to:
  /// **'Export Data'**
  String get exportData;

  /// No description provided for @exportDataDescription.
  ///
  /// In en, this message translates to:
  /// **'Export survey data'**
  String get exportDataDescription;

  /// No description provided for @exportAllSurveys.
  ///
  /// In en, this message translates to:
  /// **'Export All Surveys'**
  String get exportAllSurveys;

  /// No description provided for @exportAllSurveysDesc.
  ///
  /// In en, this message translates to:
  /// **'Export all survey data'**
  String get exportAllSurveysDesc;

  /// No description provided for @exportSummaryReport.
  ///
  /// In en, this message translates to:
  /// **'Export Summary Report'**
  String get exportSummaryReport;

  /// No description provided for @exportSummaryDesc.
  ///
  /// In en, this message translates to:
  /// **'Export summary report'**
  String get exportSummaryDesc;

  /// No description provided for @exportJSONBackup.
  ///
  /// In en, this message translates to:
  /// **'Export JSON Backup'**
  String get exportJSONBackup;

  /// No description provided for @exportBackupDesc.
  ///
  /// In en, this message translates to:
  /// **'Export JSON backup'**
  String get exportBackupDesc;

  /// No description provided for @exportInfo.
  ///
  /// In en, this message translates to:
  /// **'Export Info'**
  String get exportInfo;

  /// No description provided for @exportInfoDesc.
  ///
  /// In en, this message translates to:
  /// **'Information about export'**
  String get exportInfoDesc;

  /// No description provided for @provideLivestockDetails.
  ///
  /// In en, this message translates to:
  /// **'Provide Livestock Details'**
  String get provideLivestockDetails;

  /// No description provided for @animal.
  ///
  /// In en, this message translates to:
  /// **'Animal'**
  String get animal;

  /// No description provided for @noOfAnimals.
  ///
  /// In en, this message translates to:
  /// **'No. of Animals'**
  String get noOfAnimals;

  /// No description provided for @addAnotherAnimal.
  ///
  /// In en, this message translates to:
  /// **'Add Another Animal'**
  String get addAnotherAnimal;

  /// No description provided for @totalAnimalTypes.
  ///
  /// In en, this message translates to:
  /// **'Total Animal Types: {count}'**
  String totalAnimalTypes(Object count);

  /// No description provided for @animalNumber.
  ///
  /// In en, this message translates to:
  /// **'Animal {number}'**
  String animalNumber(Object number);

  /// No description provided for @removeAnimal.
  ///
  /// In en, this message translates to:
  /// **'Remove Animal'**
  String get removeAnimal;

  /// No description provided for @cropProductivityAndArea.
  ///
  /// In en, this message translates to:
  /// **'Crop Productivity and Area'**
  String get cropProductivityAndArea;

  /// No description provided for @provideCropProductionDetails.
  ///
  /// In en, this message translates to:
  /// **'Provide Crop Production Details'**
  String get provideCropProductionDetails;

  /// No description provided for @crop.
  ///
  /// In en, this message translates to:
  /// **'Crop'**
  String get crop;

  /// No description provided for @productivityQtlAcre.
  ///
  /// In en, this message translates to:
  /// **'Productivity (Qtl/Acre)'**
  String get productivityQtlAcre;

  /// No description provided for @totalProd.
  ///
  /// In en, this message translates to:
  /// **'Total Prod'**
  String get totalProd;

  /// No description provided for @consumed.
  ///
  /// In en, this message translates to:
  /// **'Consumed'**
  String get consumed;

  /// No description provided for @soldQtlRs.
  ///
  /// In en, this message translates to:
  /// **'Sold (Qtl/Rs)'**
  String get soldQtlRs;

  /// No description provided for @addAnotherCrop.
  ///
  /// In en, this message translates to:
  /// **'Add Another Crop'**
  String get addAnotherCrop;

  /// No description provided for @totalCrops.
  ///
  /// In en, this message translates to:
  /// **'Total Crops: {count}'**
  String totalCrops(Object count);

  /// No description provided for @cropNumber.
  ///
  /// In en, this message translates to:
  /// **'Crop {number}'**
  String cropNumber(Object number);

  /// No description provided for @removeCrop.
  ///
  /// In en, this message translates to:
  /// **'Remove Crop'**
  String get removeCrop;

  /// No description provided for @area.
  ///
  /// In en, this message translates to:
  /// **'Area'**
  String get area;

  /// No description provided for @prod.
  ///
  /// In en, this message translates to:
  /// **'Prod'**
  String get prod;

  /// No description provided for @total.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get total;

  /// No description provided for @soldQtlAndRs.
  ///
  /// In en, this message translates to:
  /// **'Sold (Qtl & Rs)'**
  String get soldQtlAndRs;

  /// No description provided for @healthIssuesAndDiseases.
  ///
  /// In en, this message translates to:
  /// **'Health Issues and Diseases'**
  String get healthIssuesAndDiseases;

  /// No description provided for @describeMajorHealthIssues.
  ///
  /// In en, this message translates to:
  /// **'Describe Major Health Issues'**
  String get describeMajorHealthIssues;

  /// No description provided for @describeHealthIssues.
  ///
  /// In en, this message translates to:
  /// **'Describe Health Issues'**
  String get describeHealthIssues;

  /// No description provided for @describeHealthIssuesHint.
  ///
  /// In en, this message translates to:
  /// **'Describe health issues'**
  String get describeHealthIssuesHint;

  /// No description provided for @leaveBlankIfNoIssues.
  ///
  /// In en, this message translates to:
  /// **'Leave blank if no issues'**
  String get leaveBlankIfNoIssues;

  /// No description provided for @healthInfoConfidential.
  ///
  /// In en, this message translates to:
  /// **'Health info is confidential'**
  String get healthInfoConfidential;

  /// No description provided for @commonHealthIssues.
  ///
  /// In en, this message translates to:
  /// **'Common Health Issues'**
  String get commonHealthIssues;

  /// No description provided for @optionalSection.
  ///
  /// In en, this message translates to:
  /// **'Optional Section'**
  String get optionalSection;

  /// No description provided for @healthInfoSensitive.
  ///
  /// In en, this message translates to:
  /// **'Health info is sensitive'**
  String get healthInfoSensitive;

  /// No description provided for @legalDisputesCourtCases.
  ///
  /// In en, this message translates to:
  /// **'Legal Disputes/Court Cases'**
  String get legalDisputesCourtCases;

  /// No description provided for @describeLegalDisputes.
  ///
  /// In en, this message translates to:
  /// **'Describe Legal Disputes'**
  String get describeLegalDisputes;

  /// No description provided for @describeLegalDisputesLabel.
  ///
  /// In en, this message translates to:
  /// **'Describe Legal Disputes'**
  String get describeLegalDisputesLabel;

  /// No description provided for @describeLegalDisputesHint.
  ///
  /// In en, this message translates to:
  /// **'Describe legal disputes'**
  String get describeLegalDisputesHint;

  /// No description provided for @leaveBlankIfNoDisputes.
  ///
  /// In en, this message translates to:
  /// **'Leave blank if no disputes'**
  String get leaveBlankIfNoDisputes;

  /// No description provided for @legalInfoConfidential.
  ///
  /// In en, this message translates to:
  /// **'Legal info is confidential'**
  String get legalInfoConfidential;

  /// No description provided for @commonDisputes.
  ///
  /// In en, this message translates to:
  /// **'Common Disputes'**
  String get commonDisputes;

  /// No description provided for @optionalDisputesSection.
  ///
  /// In en, this message translates to:
  /// **'Optional Disputes Section'**
  String get optionalDisputesSection;

  /// No description provided for @selectEntertainmentFacilities.
  ///
  /// In en, this message translates to:
  /// **'Select Entertainment Facilities'**
  String get selectEntertainmentFacilities;

  /// No description provided for @smartMobilePhone.
  ///
  /// In en, this message translates to:
  /// **'Smart Mobile Phone'**
  String get smartMobilePhone;

  /// No description provided for @androidIosSmartphones.
  ///
  /// In en, this message translates to:
  /// **'Android/iOS Smartphones'**
  String get androidIosSmartphones;

  /// No description provided for @numberOfSmartphones.
  ///
  /// In en, this message translates to:
  /// **'Number of Smartphones'**
  String get numberOfSmartphones;

  /// No description provided for @enterCount.
  ///
  /// In en, this message translates to:
  /// **'Enter Count'**
  String get enterCount;

  /// No description provided for @analogMobilePhone.
  ///
  /// In en, this message translates to:
  /// **'Analog Mobile Phone'**
  String get analogMobilePhone;

  /// No description provided for @basicMobilePhones.
  ///
  /// In en, this message translates to:
  /// **'Basic Mobile Phones'**
  String get basicMobilePhones;

  /// No description provided for @numberOfAnalogPhones.
  ///
  /// In en, this message translates to:
  /// **'Number of Analog Phones'**
  String get numberOfAnalogPhones;

  /// No description provided for @tvEntertainmentNews.
  ///
  /// In en, this message translates to:
  /// **'TV Entertainment/News'**
  String get tvEntertainmentNews;

  /// No description provided for @radioNewsMusic.
  ///
  /// In en, this message translates to:
  /// **'Radio News/Music'**
  String get radioNewsMusic;

  /// No description provided for @gamesGamingDevices.
  ///
  /// In en, this message translates to:
  /// **'Games/Gaming Devices'**
  String get gamesGamingDevices;

  /// No description provided for @videoGamesBoardGames.
  ///
  /// In en, this message translates to:
  /// **'Video Games/Board Games'**
  String get videoGamesBoardGames;

  /// No description provided for @otherEntertainment.
  ///
  /// In en, this message translates to:
  /// **'Other Entertainment'**
  String get otherEntertainment;

  /// No description provided for @newspaperInternetEtc.
  ///
  /// In en, this message translates to:
  /// **'Newspaper/Internet etc'**
  String get newspaperInternetEtc;

  /// No description provided for @specifyOtherEntertainment.
  ///
  /// In en, this message translates to:
  /// **'Specify Other Entertainment'**
  String get specifyOtherEntertainment;

  /// No description provided for @entertainmentExamples.
  ///
  /// In en, this message translates to:
  /// **'Entertainment Examples'**
  String get entertainmentExamples;

  /// No description provided for @entertainmentInfo.
  ///
  /// In en, this message translates to:
  /// **'Entertainment Info'**
  String get entertainmentInfo;

  /// No description provided for @selectEntertainmentFacility.
  ///
  /// In en, this message translates to:
  /// **'Select Entertainment Facility'**
  String get selectEntertainmentFacility;

  /// No description provided for @selectAgriculturalEquipment.
  ///
  /// In en, this message translates to:
  /// **'Select Agricultural Equipment'**
  String get selectAgriculturalEquipment;

  /// No description provided for @otherEquipmentSpecify.
  ///
  /// In en, this message translates to:
  /// **'Other Equipment (Specify)'**
  String get otherEquipmentSpecify;

  /// No description provided for @provideDetailsForEachFamilyMember.
  ///
  /// In en, this message translates to:
  /// **'Provide Details for Each Family Member'**
  String get provideDetailsForEachFamilyMember;

  /// No description provided for @totalFamilyMembers.
  ///
  /// In en, this message translates to:
  /// **'Total Family Members: {count}'**
  String totalFamilyMembers(Object count);

  /// No description provided for @required.
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get required;

  /// No description provided for @removeMember.
  ///
  /// In en, this message translates to:
  /// **'Remove Member'**
  String get removeMember;

  /// No description provided for @pleaseEnterMemberName.
  ///
  /// In en, this message translates to:
  /// **'Please enter member name'**
  String get pleaseEnterMemberName;

  /// No description provided for @pleaseEnterAge.
  ///
  /// In en, this message translates to:
  /// **'Please enter age'**
  String get pleaseEnterAge;

  /// No description provided for @pleaseEnterValidAge.
  ///
  /// In en, this message translates to:
  /// **'Please enter valid age'**
  String get pleaseEnterValidAge;

  /// No description provided for @pleaseSelectGender.
  ///
  /// In en, this message translates to:
  /// **'Please select gender'**
  String get pleaseSelectGender;

  /// No description provided for @selectFertilizerType.
  ///
  /// In en, this message translates to:
  /// **'Select Fertilizer Type'**
  String get selectFertilizerType;

  /// No description provided for @errorSubmittingSurvey.
  ///
  /// In en, this message translates to:
  /// **'Error submitting survey: {error}'**
  String errorSubmittingSurvey(Object error);

  /// No description provided for @thankYouParticipating.
  ///
  /// In en, this message translates to:
  /// **'Thank you for participating'**
  String get thankYouParticipating;

  /// No description provided for @surveySummary.
  ///
  /// In en, this message translates to:
  /// **'Survey Summary'**
  String get surveySummary;

  /// No description provided for @familyInformation.
  ///
  /// In en, this message translates to:
  /// **'Family Information'**
  String get familyInformation;

  /// No description provided for @economicDetails.
  ///
  /// In en, this message translates to:
  /// **'Economic Details'**
  String get economicDetails;

  /// No description provided for @agriculturalData.
  ///
  /// In en, this message translates to:
  /// **'Agricultural Data'**
  String get agriculturalData;

  /// No description provided for @healthEducation.
  ///
  /// In en, this message translates to:
  /// **'Health & Education'**
  String get healthEducation;

  /// No description provided for @migrationTraining.
  ///
  /// In en, this message translates to:
  /// **'Migration & Training'**
  String get migrationTraining;

  /// No description provided for @importantNotes.
  ///
  /// In en, this message translates to:
  /// **'Important Notes'**
  String get importantNotes;

  /// No description provided for @dataStoredSecurely.
  ///
  /// In en, this message translates to:
  /// **'Data stored securely'**
  String get dataStoredSecurely;

  /// No description provided for @personalInfoConfidential.
  ///
  /// In en, this message translates to:
  /// **'Personal info is confidential'**
  String get personalInfoConfidential;

  /// No description provided for @surveyResponsesHelp.
  ///
  /// In en, this message translates to:
  /// **'Survey responses help'**
  String get surveyResponsesHelp;

  /// No description provided for @contactLocalAuthorities.
  ///
  /// In en, this message translates to:
  /// **'Contact local authorities'**
  String get contactLocalAuthorities;

  /// No description provided for @submittingSurvey.
  ///
  /// In en, this message translates to:
  /// **'Submitting Survey'**
  String get submittingSurvey;

  /// No description provided for @submitSurvey.
  ///
  /// In en, this message translates to:
  /// **'Submit Survey'**
  String get submitSurvey;

  /// No description provided for @thankYouContribution.
  ///
  /// In en, this message translates to:
  /// **'Thank you for your contribution'**
  String get thankYouContribution;

  /// No description provided for @failedToGetLocation.
  ///
  /// In en, this message translates to:
  /// **'Failed to get location: {error}'**
  String failedToGetLocation(Object error);

  /// No description provided for @locationInformation.
  ///
  /// In en, this message translates to:
  /// **'Location Information'**
  String get locationInformation;

  /// No description provided for @getCurrentLocation.
  ///
  /// In en, this message translates to:
  /// **'Get Current Location'**
  String get getCurrentLocation;

  /// No description provided for @locationDetectedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Location detected successfully'**
  String get locationDetectedSuccessfully;

  /// No description provided for @selectIrrigationFacilities.
  ///
  /// In en, this message translates to:
  /// **'Select Irrigation Facilities'**
  String get selectIrrigationFacilities;

  /// No description provided for @canalIrrigation.
  ///
  /// In en, this message translates to:
  /// **'Canal Irrigation'**
  String get canalIrrigation;

  /// No description provided for @governmentCanalWaterSupply.
  ///
  /// In en, this message translates to:
  /// **'Government Canal Water Supply'**
  String get governmentCanalWaterSupply;

  /// No description provided for @tubeWellBoreWell.
  ///
  /// In en, this message translates to:
  /// **'Tube Well/Bore Well'**
  String get tubeWellBoreWell;

  /// No description provided for @undergroundWaterExtraction.
  ///
  /// In en, this message translates to:
  /// **'Underground Water Extraction'**
  String get undergroundWaterExtraction;

  /// No description provided for @pondsLakes.
  ///
  /// In en, this message translates to:
  /// **'Ponds/Lakes'**
  String get pondsLakes;

  /// No description provided for @naturalWaterStorageBodies.
  ///
  /// In en, this message translates to:
  /// **'Natural Water Storage Bodies'**
  String get naturalWaterStorageBodies;

  /// No description provided for @otherIrrigationFacilities.
  ///
  /// In en, this message translates to:
  /// **'Other Irrigation Facilities'**
  String get otherIrrigationFacilities;

  /// No description provided for @dripSprinklerEtc.
  ///
  /// In en, this message translates to:
  /// **'Drip/Sprinkler etc'**
  String get dripSprinklerEtc;

  /// No description provided for @selectIrrigationMethodsInfo.
  ///
  /// In en, this message translates to:
  /// **'Select Irrigation Methods Info'**
  String get selectIrrigationMethodsInfo;

  /// No description provided for @pleaseSelectIrrigationFacility.
  ///
  /// In en, this message translates to:
  /// **'Please select irrigation facility'**
  String get pleaseSelectIrrigationFacility;

  /// No description provided for @landHoldingInformation.
  ///
  /// In en, this message translates to:
  /// **'Land Holding Information'**
  String get landHoldingInformation;

  /// No description provided for @totalIrrigatedArea.
  ///
  /// In en, this message translates to:
  /// **'Total Irrigated Area'**
  String get totalIrrigatedArea;

  /// No description provided for @enterAreaInAcres.
  ///
  /// In en, this message translates to:
  /// **'Enter Area in Acres'**
  String get enterAreaInAcres;

  /// No description provided for @pleaseEnterIrrigatedArea.
  ///
  /// In en, this message translates to:
  /// **'Please enter irrigated area'**
  String get pleaseEnterIrrigatedArea;

  /// No description provided for @pleaseEnterValidArea.
  ///
  /// In en, this message translates to:
  /// **'Please enter valid area'**
  String get pleaseEnterValidArea;

  /// No description provided for @totalCultivableArea.
  ///
  /// In en, this message translates to:
  /// **'Total Cultivable Area'**
  String get totalCultivableArea;

  /// No description provided for @pleaseEnterCultivableArea.
  ///
  /// In en, this message translates to:
  /// **'Please enter cultivable area'**
  String get pleaseEnterCultivableArea;

  /// No description provided for @orchardPlantsIfAny.
  ///
  /// In en, this message translates to:
  /// **'Orchard Plants (If Any)'**
  String get orchardPlantsIfAny;

  /// No description provided for @orchardPlantsExample.
  ///
  /// In en, this message translates to:
  /// **'Orchard Plants Example'**
  String get orchardPlantsExample;

  /// No description provided for @landMeasurementInfo.
  ///
  /// In en, this message translates to:
  /// **'Land Measurement Info'**
  String get landMeasurementInfo;

  /// No description provided for @selectDrinkingWaterSources.
  ///
  /// In en, this message translates to:
  /// **'Select Drinking Water Sources'**
  String get selectDrinkingWaterSources;

  /// No description provided for @manualWaterPumps.
  ///
  /// In en, this message translates to:
  /// **'Manual Water Pumps'**
  String get manualWaterPumps;

  /// No description provided for @distanceFromHomeMeters.
  ///
  /// In en, this message translates to:
  /// **'Distance from Home (Meters)'**
  String get distanceFromHomeMeters;

  /// No description provided for @enterDistance.
  ///
  /// In en, this message translates to:
  /// **'Enter Distance'**
  String get enterDistance;

  /// No description provided for @meters.
  ///
  /// In en, this message translates to:
  /// **'Meters'**
  String get meters;

  /// No description provided for @openWellOrBoreWell.
  ///
  /// In en, this message translates to:
  /// **'Open Well or Bore Well'**
  String get openWellOrBoreWell;

  /// No description provided for @poweredWaterExtraction.
  ///
  /// In en, this message translates to:
  /// **'Powered Water Extraction'**
  String get poweredWaterExtraction;

  /// No description provided for @nalJaalPipedWater.
  ///
  /// In en, this message translates to:
  /// **'Nal Jaal/Piped Water'**
  String get nalJaalPipedWater;

  /// No description provided for @governmentPipedWaterSupply.
  ///
  /// In en, this message translates to:
  /// **'Government Piped Water Supply'**
  String get governmentPipedWaterSupply;

  /// No description provided for @otherSources.
  ///
  /// In en, this message translates to:
  /// **'Other Sources'**
  String get otherSources;

  /// No description provided for @riverPondTankerEtc.
  ///
  /// In en, this message translates to:
  /// **'River/Pond/Tanker etc'**
  String get riverPondTankerEtc;

  /// No description provided for @cleanWaterAccessInfo.
  ///
  /// In en, this message translates to:
  /// **'Clean Water Access Info'**
  String get cleanWaterAccessInfo;

  /// No description provided for @selectDrinkingWaterSource.
  ///
  /// In en, this message translates to:
  /// **'Select Drinking Water Source'**
  String get selectDrinkingWaterSource;

  /// No description provided for @familySurvey.
  ///
  /// In en, this message translates to:
  /// **'Family Survey'**
  String get familySurvey;

  /// No description provided for @deendayalResearchInstitute.
  ///
  /// In en, this message translates to:
  /// **'Deendayal Research Institute'**
  String get deendayalResearchInstitute;

  /// No description provided for @helpAndSupport.
  ///
  /// In en, this message translates to:
  /// **'Help & Support'**
  String get helpAndSupport;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @version.
  ///
  /// In en, this message translates to:
  /// **'Version 1.0.0'**
  String get version;

  /// No description provided for @surveyUser.
  ///
  /// In en, this message translates to:
  /// **'Survey User'**
  String get surveyUser;

  /// No description provided for @phoneNumberDisplay.
  ///
  /// In en, this message translates to:
  /// **'Phone: +91 2525252525'**
  String get phoneNumberDisplay;

  /// No description provided for @profileManagementMessage.
  ///
  /// In en, this message translates to:
  /// **'Profile management features will be implemented here.'**
  String get profileManagementMessage;

  /// No description provided for @languageChangedToEnglish.
  ///
  /// In en, this message translates to:
  /// **'Language changed to English'**
  String get languageChangedToEnglish;

  /// No description provided for @languageChangedToHindi.
  ///
  /// In en, this message translates to:
  /// **'भाषा हिंदी में बदल दी गई'**
  String get languageChangedToHindi;

  /// No description provided for @apply.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get apply;

  /// No description provided for @fontSize.
  ///
  /// In en, this message translates to:
  /// **'Font Size'**
  String get fontSize;

  /// No description provided for @resetToDefault.
  ///
  /// In en, this message translates to:
  /// **'Reset to Default'**
  String get resetToDefault;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @darkMode.
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get darkMode;

  /// No description provided for @dataManagement.
  ///
  /// In en, this message translates to:
  /// **'Data Management'**
  String get dataManagement;

  /// No description provided for @userGuide.
  ///
  /// In en, this message translates to:
  /// **'User Guide'**
  String get userGuide;

  /// No description provided for @contactSupport.
  ///
  /// In en, this message translates to:
  /// **'Contact Support'**
  String get contactSupport;

  /// No description provided for @reportIssue.
  ///
  /// In en, this message translates to:
  /// **'Report Issue'**
  String get reportIssue;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @familySurveyApp.
  ///
  /// In en, this message translates to:
  /// **'Family Survey App'**
  String get familySurveyApp;

  /// No description provided for @appDescription.
  ///
  /// In en, this message translates to:
  /// **'Comprehensive family survey application for rural development and government schemes.'**
  String get appDescription;

  /// No description provided for @developedBy.
  ///
  /// In en, this message translates to:
  /// **'Developed by Deendayal Research Institute'**
  String get developedBy;

  /// No description provided for @logoutConfirm.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logoutConfirm;

  /// No description provided for @logoutMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to logout? Your current survey progress will be saved locally.'**
  String get logoutMessage;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'hi'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'hi':
      return AppLocalizationsHi();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
