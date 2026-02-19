import 'package:equatable/equatable.dart';

// Main Survey Model
class Survey extends Equatable {
  final int? id;
  final String surveyDate;
  final String? villageName;
  final String? panchayat;
  final String? block;
  final String? tehsil;
  final String? district;
  final String? postalAddress;
  final String? pinCode;
  final String createdAt;
  final String updatedAt;
  final bool synced;

  const Survey({
    this.id,
    required this.surveyDate,
    this.villageName,
    this.panchayat,
    this.block,
    this.tehsil,
    this.district,
    this.postalAddress,
    this.pinCode,
    required this.createdAt,
    required this.updatedAt,
    required this.synced,
  });

  factory Survey.fromMap(Map<String, dynamic> map) {
    return Survey(
      id: map['id'],
      surveyDate: map['survey_date'],
      villageName: map['village_name'],
      panchayat: map['panchayat'],
      block: map['block'],
      tehsil: map['tehsil'],
      district: map['district'],
      postalAddress: map['postal_address'],
      pinCode: map['pin_code'],
      createdAt: map['created_at'],
      updatedAt: map['updated_at'],
      synced: map['synced'] == 1,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'survey_date': surveyDate,
      'village_name': villageName,
      'panchayat': panchayat,
      'block': block,
      'tehsil': tehsil,
      'district': district,
      'postal_address': postalAddress,
      'pin_code': pinCode,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'synced': synced ? 1 : 0,
    };
  }

  Survey copyWith({
    int? id,
    String? surveyDate,
    String? villageName,
    String? panchayat,
    String? block,
    String? tehsil,
    String? district,
    String? postalAddress,
    String? pinCode,
    String? createdAt,
    String? updatedAt,
    bool? synced,
  }) {
    return Survey(
      id: id ?? this.id,
      surveyDate: surveyDate ?? this.surveyDate,
      villageName: villageName ?? this.villageName,
      panchayat: panchayat ?? this.panchayat,
      block: block ?? this.block,
      tehsil: tehsil ?? this.tehsil,
      district: district ?? this.district,
      postalAddress: postalAddress ?? this.postalAddress,
      pinCode: pinCode ?? this.pinCode,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      synced: synced ?? this.synced,
    );
  }

  @override
  List<Object?> get props => [
        id,
        surveyDate,
        villageName,
        panchayat,
        block,
        tehsil,
        district,
        postalAddress,
        pinCode,
        createdAt,
        updatedAt,
        synced,
      ];
}

// Family Member Model
class FamilyMember extends Equatable {
  final String? id;
  final int phoneNumber;
  final String? name;
  final String? fathersName;
  final String? mothersName;
  final String? relationshipWithHead;
  final int? age;
  final String? sex;
  final String? physicallyFit;
  final String? physicallyFitCause;
  final String? educationalQualification;
  final String? inclinationSelfEmployment;
  final String? occupation;
  final int? daysEmployed;
  final double? income;
  final String? awarenessAboutVillage;
  final String? participateGramSabha;
  final String? insured;
  final String? insuranceCompany;
  final String createdAt;

  const FamilyMember({
    this.id,
    required this.phoneNumber,
    this.name,
    this.fathersName,
    this.mothersName,
    this.relationshipWithHead,
    this.age,
    this.sex,
    this.physicallyFit,
    this.physicallyFitCause,
    this.educationalQualification,
    this.inclinationSelfEmployment,
    this.occupation,
    this.daysEmployed,
    this.income,
    this.awarenessAboutVillage,
    this.participateGramSabha,
    this.insured,
    this.insuranceCompany,
    required this.createdAt,
  });

  factory FamilyMember.fromMap(Map<String, dynamic> map) {
    final rawPhone = map['phone_number'];
    final intPhone = rawPhone is int ? rawPhone : int.tryParse(rawPhone?.toString() ?? '') ?? 0;

    return FamilyMember(
      id: map['id'],
      phoneNumber: intPhone,
      name: map['name'],
      fathersName: map['fathers_name'],
      mothersName: map['mothers_name'],
      relationshipWithHead: map['relationship_with_head'],
      age: map['age'],
      sex: map['sex'],
      physicallyFit: map['physically_fit'],
      physicallyFitCause: map['physically_fit_cause'],
      educationalQualification: map['educational_qualification'],
      inclinationSelfEmployment: map['inclination_self_employment'],
      occupation: map['occupation'],
      daysEmployed: map['days_employed'],
      income: map['income']?.toDouble(),
      awarenessAboutVillage: map['awareness_about_village'],
      participateGramSabha: map['participate_gram_sabha'],
      insured: map['insured'],
      insuranceCompany: map['insurance_company'],
      createdAt: map['created_at'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'phone_number': phoneNumber,
      'name': name,
      'fathers_name': fathersName,
      'mothers_name': mothersName,
      'relationship_with_head': relationshipWithHead,
      'age': age,
      'sex': sex,
      'physically_fit': physicallyFit,
      'physically_fit_cause': physicallyFitCause,
      'educational_qualification': educationalQualification,
      'inclination_self_employment': inclinationSelfEmployment,
      'occupation': occupation,
      'days_employed': daysEmployed,
      'income': income,
      'awareness_about_village': awarenessAboutVillage,
      'participate_gram_sabha': participateGramSabha,
      'insured': insured,
      'insurance_company': insuranceCompany,
      'created_at': createdAt,
    };
  }

  @override
  List<Object?> get props => [
        id,
        phoneNumber,
        name,
        fathersName,
        mothersName,
        relationshipWithHead,
        age,
        sex,
        physicallyFit,
        physicallyFitCause,
        educationalQualification,
        inclinationSelfEmployment,
        occupation,
        daysEmployed,
        income,
        awarenessAboutVillage,
        participateGramSabha,
        insured,
        insuranceCompany,
        createdAt,
      ];
}

// Land Holding Model
class LandHolding extends Equatable {
  final int? id;
  final int surveyId;
  final double? irrigatedArea;
  final double? cultivableArea;
  final String? orchardPlants;
  final String createdAt;

  const LandHolding({
    this.id,
    required this.surveyId,
    this.irrigatedArea,
    this.cultivableArea,
    this.orchardPlants,
    required this.createdAt,
  });

  factory LandHolding.fromMap(Map<String, dynamic> map) {
    return LandHolding(
      id: map['id'],
      surveyId: map['survey_id'],
      irrigatedArea: map['irrigated_area']?.toDouble(),
      cultivableArea: map['cultivable_area']?.toDouble(),
      orchardPlants: map['orchard_plants'],
      createdAt: map['created_at'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'survey_id': surveyId,
      'irrigated_area': irrigatedArea,
      'cultivable_area': cultivableArea,
      'orchard_plants': orchardPlants,
      'created_at': createdAt,
    };
  }

  @override
  List<Object?> get props => [
        id,
        surveyId,
        irrigatedArea,
        cultivableArea,
        orchardPlants,
        createdAt,
      ];
}

// Irrigation Facilities Model
class IrrigationFacilities extends Equatable {
  final int? id;
  final int surveyId;
  final bool canal;
  final bool tubeWell;
  final bool ponds;
  final String? otherFacilities;
  final String createdAt;

  const IrrigationFacilities({
    this.id,
    required this.surveyId,
    required this.canal,
    required this.tubeWell,
    required this.ponds,
    this.otherFacilities,
    required this.createdAt,
  });

  factory IrrigationFacilities.fromMap(Map<String, dynamic> map) {
    return IrrigationFacilities(
      id: map['id'],
      surveyId: map['survey_id'],
      canal: map['canal'] == 1,
      tubeWell: map['tube_well'] == 1,
      ponds: map['ponds'] == 1,
      otherFacilities: map['other_facilities'],
      createdAt: map['created_at'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'survey_id': surveyId,
      'canal': canal ? 1 : 0,
      'tube_well': tubeWell ? 1 : 0,
      'ponds': ponds ? 1 : 0,
      'other_facilities': otherFacilities,
      'created_at': createdAt,
    };
  }

  @override
  List<Object?> get props => [
        id,
        surveyId,
        canal,
        tubeWell,
        ponds,
        otherFacilities,
        createdAt,
      ];
}

// Crop Productivity Model
class CropProductivity extends Equatable {
  final int? id;
  final int surveyId;
  final String? cropName;
  final double? areaAcres;
  final double? productivityQuintalPerAcre;
  final double? totalProduction;
  final double? quantityConsumed;
  final double? quantitySoldQuintal;
  final double? quantitySoldRupees;
  final String createdAt;

  const CropProductivity({
    this.id,
    required this.surveyId,
    this.cropName,
    this.areaAcres,
    this.productivityQuintalPerAcre,
    this.totalProduction,
    this.quantityConsumed,
    this.quantitySoldQuintal,
    this.quantitySoldRupees,
    required this.createdAt,
  });

  factory CropProductivity.fromMap(Map<String, dynamic> map) {
    return CropProductivity(
      id: map['id'],
      surveyId: map['survey_id'],
      cropName: map['crop_name'],
      areaAcres: map['area_acres']?.toDouble(),
      productivityQuintalPerAcre: map['productivity_quintal_per_acre']?.toDouble(),
      totalProduction: map['total_production']?.toDouble(),
      quantityConsumed: map['quantity_consumed']?.toDouble(),
      quantitySoldQuintal: map['quantity_sold_quintal']?.toDouble(),
      quantitySoldRupees: map['quantity_sold_rupees']?.toDouble(),
      createdAt: map['created_at'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'survey_id': surveyId,
      'crop_name': cropName,
      'area_acres': areaAcres,
      'productivity_quintal_per_acre': productivityQuintalPerAcre,
      'total_production': totalProduction,
      'quantity_consumed': quantityConsumed,
      'quantity_sold_quintal': quantitySoldQuintal,
      'quantity_sold_rupees': quantitySoldRupees,
      'created_at': createdAt,
    };
  }

  @override
  List<Object?> get props => [
        id,
        surveyId,
        cropName,
        areaAcres,
        productivityQuintalPerAcre,
        totalProduction,
        quantityConsumed,
        quantitySoldQuintal,
        quantitySoldRupees,
        createdAt,
      ];
}

// Animals Model
class Animal extends Equatable {
  final int? id;
  final int surveyId;
  final String? animalType;
  final int? numberOfAnimals;
  final String? breed;
  final double? productionPerAnimal;
  final double? quantitySold;
  final String createdAt;

  const Animal({
    this.id,
    required this.surveyId,
    this.animalType,
    this.numberOfAnimals,
    this.breed,
    this.productionPerAnimal,
    this.quantitySold,
    required this.createdAt,
  });

  factory Animal.fromMap(Map<String, dynamic> map) {
    return Animal(
      id: map['id'],
      surveyId: map['survey_id'],
      animalType: map['animal_type'],
      numberOfAnimals: map['number_of_animals'],
      breed: map['breed'],
      productionPerAnimal: map['production_per_animal']?.toDouble(),
      quantitySold: map['quantity_sold']?.toDouble(),
      createdAt: map['created_at'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'survey_id': surveyId,
      'animal_type': animalType,
      'number_of_animals': numberOfAnimals,
      'breed': breed,
      'production_per_animal': productionPerAnimal,
      'quantity_sold': quantitySold,
      'created_at': createdAt,
    };
  }

  @override
  List<Object?> get props => [
        id,
        surveyId,
        animalType,
        numberOfAnimals,
        breed,
        productionPerAnimal,
        quantitySold,
        createdAt,
      ];
}

// Agricultural Equipment Model
class AgriculturalEquipment extends Equatable {
  final int? id;
  final int surveyId;
  final bool tractor;
  final bool thresher;
  final bool seedDrill;
  final bool sprayer;
  final bool duster;
  final bool dieselEngine;
  final String? otherEquipment;
  final String createdAt;

  const AgriculturalEquipment({
    this.id,
    required this.surveyId,
    required this.tractor,
    required this.thresher,
    required this.seedDrill,
    required this.sprayer,
    required this.duster,
    required this.dieselEngine,
    this.otherEquipment,
    required this.createdAt,
  });

  factory AgriculturalEquipment.fromMap(Map<String, dynamic> map) {
    return AgriculturalEquipment(
      id: map['id'],
      surveyId: map['survey_id'],
      tractor: map['tractor'] == 1,
      thresher: map['thresher'] == 1,
      seedDrill: map['seed_drill'] == 1,
      sprayer: map['sprayer'] == 1,
      duster: map['duster'] == 1,
      dieselEngine: map['diesel_engine'] == 1,
      otherEquipment: map['other_equipment'],
      createdAt: map['created_at'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'survey_id': surveyId,
      'tractor': tractor ? 1 : 0,
      'thresher': thresher ? 1 : 0,
      'seed_drill': seedDrill ? 1 : 0,
      'sprayer': sprayer ? 1 : 0,
      'duster': duster ? 1 : 0,
      'diesel_engine': dieselEngine ? 1 : 0,
      'other_equipment': otherEquipment,
      'created_at': createdAt,
    };
  }

  @override
  List<Object?> get props => [
        id,
        surveyId,
        tractor,
        thresher,
        seedDrill,
        sprayer,
        duster,
        dieselEngine,
        otherEquipment,
        createdAt,
      ];
}

// Entertainment Facilities Model
class EntertainmentFacilities extends Equatable {
  final int? id;
  final int surveyId;
  final bool smartMobile;
  final int? smartMobileCount;
  final bool analogMobile;
  final int? analogMobileCount;
  final bool television;
  final bool radio;
  final bool games;
  final String? otherEntertainment;
  final String createdAt;

  const EntertainmentFacilities({
    this.id,
    required this.surveyId,
    required this.smartMobile,
    this.smartMobileCount,
    required this.analogMobile,
    this.analogMobileCount,
    required this.television,
    required this.radio,
    required this.games,
    this.otherEntertainment,
    required this.createdAt,
  });

  factory EntertainmentFacilities.fromMap(Map<String, dynamic> map) {
    return EntertainmentFacilities(
      id: map['id'],
      surveyId: map['survey_id'],
      smartMobile: map['smart_mobile'] == 1,
      smartMobileCount: map['smart_mobile_count'],
      analogMobile: map['analog_mobile'] == 1,
      analogMobileCount: map['analog_mobile_count'],
      television: map['television'] == 1,
      radio: map['radio'] == 1,
      games: map['games'] == 1,
      otherEntertainment: map['other_entertainment'],
      createdAt: map['created_at'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'survey_id': surveyId,
      'smart_mobile': smartMobile ? 1 : 0,
      'smart_mobile_count': smartMobileCount,
      'analog_mobile': analogMobile ? 1 : 0,
      'analog_mobile_count': analogMobileCount,
      'television': television ? 1 : 0,
      'radio': radio ? 1 : 0,
      'games': games ? 1 : 0,
      'other_entertainment': otherEntertainment,
      'created_at': createdAt,
    };
  }

  @override
  List<Object?> get props => [
        id,
        surveyId,
        smartMobile,
        smartMobileCount,
        analogMobile,
        analogMobileCount,
        television,
        radio,
        games,
        otherEntertainment,
        createdAt,
      ];
}

// Transport Facilities Model
class TransportFacilities extends Equatable {
  final int? id;
  final int surveyId;
  final bool carJeep;
  final bool motorcycleScooter;
  final bool eRickshaw;
  final bool cycle;
  final bool pickupTruck;
  final bool bullockCart;
  final String createdAt;

  const TransportFacilities({
    this.id,
    required this.surveyId,
    required this.carJeep,
    required this.motorcycleScooter,
    required this.eRickshaw,
    required this.cycle,
    required this.pickupTruck,
    required this.bullockCart,
    required this.createdAt,
  });

  factory TransportFacilities.fromMap(Map<String, dynamic> map) {
    return TransportFacilities(
      id: map['id'],
      surveyId: map['survey_id'],
      carJeep: map['car_jeep'] == 1,
      motorcycleScooter: map['motorcycle_scooter'] == 1,
      eRickshaw: map['e_rickshaw'] == 1,
      cycle: map['cycle'] == 1,
      pickupTruck: map['pickup_truck'] == 1,
      bullockCart: map['bullock_cart'] == 1,
      createdAt: map['created_at'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'survey_id': surveyId,
      'car_jeep': carJeep ? 1 : 0,
      'motorcycle_scooter': motorcycleScooter ? 1 : 0,
      'e_rickshaw': eRickshaw ? 1 : 0,
      'cycle': cycle ? 1 : 0,
      'pickup_truck': pickupTruck ? 1 : 0,
      'bullock_cart': bullockCart ? 1 : 0,
      'created_at': createdAt,
    };
  }

  @override
  List<Object?> get props => [
        id,
        surveyId,
        carJeep,
        motorcycleScooter,
        eRickshaw,
        cycle,
        pickupTruck,
        bullockCart,
        createdAt,
      ];
}

// Drinking Water Sources Model
class DrinkingWaterSources extends Equatable {
  final int? id;
  final int surveyId;
  final bool handPumps;
  final double? handPumpsDistance;
  final bool well;
  final double? wellDistance;
  final bool tubewell;
  final double? tubewellDistance;
  final bool nalJaal;
  final String? otherSources;
  final double? otherDistance;
  final String createdAt;

  const DrinkingWaterSources({
    this.id,
    required this.surveyId,
    required this.handPumps,
    this.handPumpsDistance,
    required this.well,
    this.wellDistance,
    required this.tubewell,
    this.tubewellDistance,
    required this.nalJaal,
    this.otherSources,
    this.otherDistance,
    required this.createdAt,
  });

  factory DrinkingWaterSources.fromMap(Map<String, dynamic> map) {
    return DrinkingWaterSources(
      id: map['id'],
      surveyId: map['survey_id'],
      handPumps: map['hand_pumps'] == 1,
      handPumpsDistance: map['hand_pumps_distance']?.toDouble(),
      well: map['well'] == 1,
      wellDistance: map['well_distance']?.toDouble(),
      tubewell: map['tubewell'] == 1,
      tubewellDistance: map['tubewell_distance']?.toDouble(),
      nalJaal: map['nal_jaal'] == 1,
      otherSources: map['other_sources'],
      otherDistance: map['other_distance']?.toDouble(),
      createdAt: map['created_at'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'survey_id': surveyId,
      'hand_pumps': handPumps ? 1 : 0,
      'hand_pumps_distance': handPumpsDistance,
      'well': well ? 1 : 0,
      'well_distance': wellDistance,
      'tubewell': tubewell ? 1 : 0,
      'tubewell_distance': tubewellDistance,
      'nal_jaal': nalJaal ? 1 : 0,
      'other_sources': otherSources,
      'other_distance': otherDistance,
      'created_at': createdAt,
    };
  }

  @override
  List<Object?> get props => [
        id,
        surveyId,
        handPumps,
        handPumpsDistance,
        well,
        wellDistance,
        tubewell,
        tubewellDistance,
        nalJaal,
        otherSources,
        otherDistance,
        createdAt,
      ];
}

// Medical Treatment Model
class MedicalTreatment extends Equatable {
  final int? id;
  final int surveyId;
  final bool allopathic;
  final bool ayurvedic;
  final bool homeopathy;
  final bool traditional;
  final bool jhadPhook;
  final String? otherMethods;
  final String? preferences;
  final String createdAt;

  const MedicalTreatment({
    this.id,
    required this.surveyId,
    required this.allopathic,
    required this.ayurvedic,
    required this.homeopathy,
    required this.traditional,
    required this.jhadPhook,
    this.otherMethods,
    this.preferences,
    required this.createdAt,
  });

  factory MedicalTreatment.fromMap(Map<String, dynamic> map) {
    return MedicalTreatment(
      id: map['id'],
      surveyId: map['survey_id'],
      allopathic: map['allopathic'] == 1,
      ayurvedic: map['ayurvedic'] == 1,
      homeopathy: map['homeopathy'] == 1,
      traditional: map['traditional'] == 1,
      jhadPhook: map['jhad_phook'] == 1,
      otherMethods: map['other_methods'],
      preferences: map['preferences'],
      createdAt: map['created_at'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'survey_id': surveyId,
      'allopathic': allopathic ? 1 : 0,
      'ayurvedic': ayurvedic ? 1 : 0,
      'homeopathy': homeopathy ? 1 : 0,
      'traditional': traditional ? 1 : 0,
      'jhad_phook': jhadPhook ? 1 : 0,
      'other_methods': otherMethods,
      'preferences': preferences,
      'created_at': createdAt,
    };
  }

  @override
  List<Object?> get props => [
        id,
        surveyId,
        allopathic,
        ayurvedic,
        homeopathy,
        traditional,
        jhadPhook,
        otherMethods,
        preferences,
        createdAt,
      ];
}

// House Conditions Model
class HouseConditions extends Equatable {
  final int? id;
  final int surveyId;
  final bool katcha;
  final bool pakka;
  final bool katchaPakka;
  final bool hut;
  final String createdAt;

  const HouseConditions({
    this.id,
    required this.surveyId,
    required this.katcha,
    required this.pakka,
    required this.katchaPakka,
    required this.hut,
    required this.createdAt,
  });

  factory HouseConditions.fromMap(Map<String, dynamic> map) {
    return HouseConditions(
      id: map['id'],
      surveyId: map['survey_id'],
      katcha: map['katcha'] == 1,
      pakka: map['pakka'] == 1,
      katchaPakka: map['katcha_pakka'] == 1,
      hut: map['hut'] == 1,
      createdAt: map['created_at'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'survey_id': surveyId,
      'katcha': katcha ? 1 : 0,
      'pakka': pakka ? 1 : 0,
      'katcha_pakka': katchaPakka ? 1 : 0,
      'hut': hut ? 1 : 0,
      'created_at': createdAt,
    };
  }

  @override
  List<Object?> get props => [
        id,
        surveyId,
        katcha,
        pakka,
        katchaPakka,
        hut,
        createdAt,
      ];
}

// House Facilities Model
class HouseFacilities extends Equatable {
  final int? id;
  final int surveyId;
  final bool toilet;
  final bool toiletInUse;
  final bool drainage;
  final bool soakPit;
  final bool cattleShed;
  final bool compostPit;
  final bool nadep;
  final bool lpgGas;
  final bool biogas;
  final bool solarCooking;
  final bool electricConnection;
  final String createdAt;

  const HouseFacilities({
    this.id,
    required this.surveyId,
    required this.toilet,
    required this.toiletInUse,
    required this.drainage,
    required this.soakPit,
    required this.cattleShed,
    required this.compostPit,
    required this.nadep,
    required this.lpgGas,
    required this.biogas,
    required this.solarCooking,
    required this.electricConnection,
    required this.createdAt,
  });

  factory HouseFacilities.fromMap(Map<String, dynamic> map) {
    return HouseFacilities(
      id: map['id'],
      surveyId: map['survey_id'],
      toilet: map['toilet'] == 1,
      toiletInUse: map['toilet_in_use'] == 1,
      drainage: map['drainage'] == 1,
      soakPit: map['soak_pit'] == 1,
      cattleShed: map['cattle_shed'] == 1,
      compostPit: map['compost_pit'] == 1,
      nadep: map['nadep'] == 1,
      lpgGas: map['lpg_gas'] == 1,
      biogas: map['biogas'] == 1,
      solarCooking: map['solar_cooking'] == 1,
      electricConnection: map['electric_connection'] == 1,
      createdAt: map['created_at'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'survey_id': surveyId,
      'toilet': toilet ? 1 : 0,
      'toilet_in_use': toiletInUse ? 1 : 0,
      'drainage': drainage ? 1 : 0,
      'soak_pit': soakPit ? 1 : 0,
      'cattle_shed': cattleShed ? 1 : 0,
      'compost_pit': compostPit ? 1 : 0,
      'nadep': nadep ? 1 : 0,
      'lpg_gas': lpgGas ? 1 : 0,
      'biogas': biogas ? 1 : 0,
      'solar_cooking': solarCooking ? 1 : 0,
      'electric_connection': electricConnection ? 1 : 0,
      'created_at': createdAt,
    };
  }

  @override
  List<Object?> get props => [
        id,
        surveyId,
        toilet,
        toiletInUse,
        drainage,
        soakPit,
        cattleShed,
        compostPit,
        nadep,
        lpgGas,
        biogas,
        solarCooking,
        electricConnection,
        createdAt,
      ];
}

// Government Schemes Model
class GovernmentScheme extends Equatable {
  final int? id;
  final int surveyId;
  final String? schemeType;
  final bool haveCard;
  final bool nameIncluded;
  final bool detailsCorrect;
  final String? memberName;
  final int? age;
  final String? sex;
  final bool eligible;
  final bool registered;
  final String createdAt;

  const GovernmentScheme({
    this.id,
    required this.surveyId,
    this.schemeType,
    required this.haveCard,
    required this.nameIncluded,
    required this.detailsCorrect,
    this.memberName,
    this.age,
    this.sex,
    required this.eligible,
    required this.registered,
    required this.createdAt,
  });

  factory GovernmentScheme.fromMap(Map<String, dynamic> map) {
    return GovernmentScheme(
      id: map['id'],
      surveyId: map['survey_id'],
      schemeType: map['scheme_type'],
      haveCard: map['have_card'] == 1,
      nameIncluded: map['name_included'] == 1,
      detailsCorrect: map['details_correct'] == 1,
      memberName: map['member_name'],
      age: map['age'],
      sex: map['sex'],
      eligible: map['eligible'] == 1,
      registered: map['registered'] == 1,
      createdAt: map['created_at'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'survey_id': surveyId,
      'scheme_type': schemeType,
      'have_card': haveCard ? 1 : 0,
      'name_included': nameIncluded ? 1 : 0,
      'details_correct': detailsCorrect ? 1 : 0,
      'member_name': memberName,
      'age': age,
      'sex': sex,
      'eligible': eligible ? 1 : 0,
      'registered': registered ? 1 : 0,
      'created_at': createdAt,
    };
  }

  @override
  List<Object?> get props => [
        id,
        surveyId,
        schemeType,
        haveCard,
        nameIncluded,
        detailsCorrect,
        memberName,
        age,
        sex,
        eligible,
        registered,
        createdAt,
      ];
}

// Beneficiary Programs Model
class BeneficiaryProgram extends Equatable {
  final int? id;
  final int surveyId;
  final String? programType;
  final bool beneficiary;
  final bool nameIncluded;
  final bool detailsCorrect;
  final bool received;
  final String? memberName;
  final int? daysWorked;
  final String createdAt;

  const BeneficiaryProgram({
    this.id,
    required this.surveyId,
    this.programType,
    required this.beneficiary,
    required this.nameIncluded,
    required this.detailsCorrect,
    required this.received,
    this.memberName,
    this.daysWorked,
    required this.createdAt,
  });

  factory BeneficiaryProgram.fromMap(Map<String, dynamic> map) {
    return BeneficiaryProgram(
      id: map['id'],
      surveyId: map['survey_id'],
      programType: map['program_type'],
      beneficiary: map['beneficiary'] == 1,
      nameIncluded: map['name_included'] == 1,
      detailsCorrect: map['details_correct'] == 1,
      received: map['received'] == 1,
      memberName: map['member_name'],
      daysWorked: map['days_worked'],
      createdAt: map['created_at'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'survey_id': surveyId,
      'program_type': programType,
      'beneficiary': beneficiary ? 1 : 0,
      'name_included': nameIncluded ? 1 : 0,
      'details_correct': detailsCorrect ? 1 : 0,
      'received': received ? 1 : 0,
      'member_name': memberName,
      'days_worked': daysWorked,
      'created_at': createdAt,
    };
  }

  @override
  List<Object?> get props => [
        id,
        surveyId,
        programType,
        beneficiary,
        nameIncluded,
        detailsCorrect,
        received,
        memberName,
        daysWorked,
        createdAt,
      ];
}

// Bank Account Model
class BankAccount extends Equatable {
  final int? id;
  final int surveyId;
  final int? srNo;
  final String? memberName;
  final String? accountNumber;
  final String? bankName;
  final String? ifscCode;
  final String? branchName;
  final String? accountType;
  final bool? hasAccount;
  final bool? detailsCorrect;
  final String? incorrectDetails;
  final String createdAt;

  const BankAccount({
    this.id,
    required this.surveyId,
    this.srNo,
    this.memberName,
    this.accountNumber,
    this.bankName,
    this.ifscCode,
    this.branchName,
    this.accountType,
    this.hasAccount,
    this.detailsCorrect,
    this.incorrectDetails,
    required this.createdAt,
  });

  factory BankAccount.fromMap(Map<String, dynamic> map) {
    return BankAccount(
      id: map['id'],
      surveyId: map['survey_id'],
      srNo: map['sr_no'],
      memberName: map['member_name'],
      accountNumber: map['account_number'],
      bankName: map['bank_name'],
      ifscCode: map['ifsc_code'],
      branchName: map['branch_name'],
      accountType: map['account_type'],
      hasAccount: map['has_account'] == 1,
      detailsCorrect: map['details_correct'] == 1,
      incorrectDetails: map['incorrect_details'],
      createdAt: map['created_at'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'survey_id': surveyId,
      'sr_no': srNo,
      'member_name': memberName,
      'account_number': accountNumber,
      'bank_name': bankName,
      'ifsc_code': ifscCode,
      'branch_name': branchName,
      'account_type': accountType,
      'has_account': hasAccount == true ? 1 : 0,
      'details_correct': detailsCorrect == true ? 1 : 0,
      'incorrect_details': incorrectDetails,
      'created_at': createdAt,
    };
  }

  BankAccount copyWith({
    int? id,
    int? surveyId,
    int? srNo,
    String? memberName,
    String? accountNumber,
    String? bankName,
    String? ifscCode,
    String? branchName,
    String? accountType,
    bool? hasAccount,
    bool? detailsCorrect,
    String? incorrectDetails,
    String? createdAt,
  }) {
    return BankAccount(
      id: id ?? this.id,
      surveyId: surveyId ?? this.surveyId,
      srNo: srNo ?? this.srNo,
      memberName: memberName ?? this.memberName,
      accountNumber: accountNumber ?? this.accountNumber,
      bankName: bankName ?? this.bankName,
      ifscCode: ifscCode ?? this.ifscCode,
      branchName: branchName ?? this.branchName,
      accountType: accountType ?? this.accountType,
      hasAccount: hasAccount ?? this.hasAccount,
      detailsCorrect: detailsCorrect ?? this.detailsCorrect,
      incorrectDetails: incorrectDetails ?? this.incorrectDetails,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        surveyId,
        srNo,
        memberName,
        accountNumber,
        bankName,
        detailsCorrect,
        incorrectDetails,
        createdAt,
      ];
}

// Social Consciousness Model
class SocialConsciousness extends Equatable {
  final int? id;
  final int surveyId;
  final int? questionNumber;
  final String? response;
  final String createdAt;

  const SocialConsciousness({
    this.id,
    required this.surveyId,
    this.questionNumber,
    this.response,
    required this.createdAt,
  });

  factory SocialConsciousness.fromMap(Map<String, dynamic> map) {
    return SocialConsciousness(
      id: map['id'],
      surveyId: map['survey_id'],
      questionNumber: map['question_number'],
      response: map['response'],
      createdAt: map['created_at'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'survey_id': surveyId,
      'question_number': questionNumber,
      'response': response,
      'created_at': createdAt,
    };
  }

  @override
  List<Object?> get props => [
        id,
        surveyId,
        questionNumber,
        response,
        createdAt,
      ];
}
