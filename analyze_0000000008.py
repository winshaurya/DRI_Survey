import json

# Raw data from the query output for phone number 0000000008
data = {
    "phone_number": "0000000008",
    "surveyor_email": "mr.shaurya25@gmail.com",
    "village_name": "Barua",
    "village_number": None,
    "panchayat": "Banka",
    "block": "Majhgawan",
    "tehsil": "Majhgawan",
    "district": "Satna",
    "postal_address": "durid",
    "pin_code": "76446656",
    "shine_code": None,
    "latitude": None,
    "longitude": None,
    "location_accuracy": None,
    "location_timestamp": None,
    "survey_date": "2026-02-11T19:50:37.576039",
    "surveyor_name": None,
    "status": "completed",
    "created_at": "2026-02-11T19:50:37.576134",
    "updated_at": "2026-02-11T20:18:36.494136",
    "device_info": None,
    "app_version": None,
    "created_by": "fa3439d5-3b80-4eef-82ad-8348f7c56dad",
    "updated_by": None,
    "is_deleted": 0,
    "last_synced_at": None,
    "current_version": 1,
    "last_edited_at": "2026-02-11 14:20:41.351116+00",
    "family_members": [
        {
            "sr_no": 1,
            "name": "djfjfj",
            "fathers_name": "ejdjj",
            "mothers_name": "jdj",
            "relationship_with_head": "Spouse",
            "age": 15,
            "sex": "female",
            "physically_fit": "fit",
            "physically_fit_cause": "",
            "educational_qualification": "Graduate",
            "inclination_self_employment": "yes",
            "occupation": "cr",
            "days_employed": 52,
            "income": 2.00,
            "awareness_about_village": "medium",
            "participate_gram_sabha": "",
            "insured": "no",
            "insurance_company": ""
        },
        {
            "sr_no": 2,
            "name": "gg",
            "fathers_name": "rr",
            "mothers_name": "gt",
            "relationship_with_head": "Spouse",
            "age": 85,
            "sex": "female",
            "physically_fit": "fit",
            "physically_fit_cause": "",
            "educational_qualification": "Higher Secondary (11-12)",
            "inclination_self_employment": "no",
            "occupation": "n5qb4g",
            "days_employed": 55,
            "income": 88.00,
            "awareness_about_village": "low",
            "participate_gram_sabha": "",
            "insured": "yes",
            "insurance_company": "brv1"
        }
    ],
    "agriculture_data": {
        "land_holding": {
            "irrigated_area": 22.00,
            "cultivable_area": 22.00,
            "unirrigated_area": None,
            "barren_land": None,
            "mango_trees": 0,
            "guava_trees": 1,
            "lemon_trees": 1,
            "pomegranate_trees": None,
            "other_fruit_trees_name": None,
            "other_fruit_trees_count": 0
        },
        "irrigation_facilities": {
            "primary_source": None,
            "canal": None,
            "tube_well": None,
            "river": None,
            "pond": None,
            "well": None,
            "hand_pump": None,
            "submersible": None,
            "rainwater_harvesting": None,
            "check_dam": None,
            "other_sources": None
        },
        "crop_productivity": None,
        "fertilizer_usage": {
            "urea_fertilizer": None,
            "organic_fertilizer": None,
            "fertilizer_types": None,
            "fertilizer_expenditure": None
        },
        "animals": None,
        "agricultural_equipment": {
            "tractor": None,
            "tractor_condition": None,
            "thresher": None,
            "thresher_condition": None,
            "seed_drill": None,
            "seed_drill_condition": None,
            "sprayer": None,
            "sprayer_condition": None,
            "duster": None,
            "duster_condition": None,
            "diesel_engine": None,
            "diesel_engine_condition": None,
            "other_equipment": None
        }
    },
    "infrastructure_data": {
        "entertainment_facilities": {
            "smart_mobile": None,
            "smart_mobile_count": None,
            "analog_mobile": None,
            "analog_mobile_count": None,
            "television": None,
            "radio": None,
            "games": None,
            "other_entertainment": None,
            "other_specify": None
        },
        "transport_facilities": {
            "car_jeep": None,
            "motorcycle_scooter": None,
            "e_rickshaw": None,
            "cycle": None,
            "pickup_truck": None,
            "bullock_cart": None
        },
        "drinking_water_sources": {
            "hand_pumps": None,
            "hand_pumps_distance": None,
            "hand_pumps_quality": None,
            "well": None,
            "well_distance": None,
            "well_quality": None,
            "tubewell": None,
            "tubewell_distance": None,
            "tubewell_quality": None,
            "nal_jaal": None,
            "nal_jaal_quality": None,
            "other_source": None,
            "other_distance": None,
            "other_sources_quality": None
        },
        "medical_treatment": {
            "allopathic": None,
            "ayurvedic": None,
            "homeopathy": None,
            "traditional": None,
            "other_treatment": None,
            "preferred_treatment": None
        },
        "house_conditions": {
            "katcha": "true",
            "pakka": "true",
            "katcha_pakka": "false",
            "hut": "false",
            "toilet_in_use": None,
            "toilet_condition": None
        },
        "house_facilities": {
            "toilet": "false",
            "toilet_in_use": None,
            "drainage": "false",
            "soak_pit": "false",
            "cattle_shed": "false",
            "compost_pit": "false",
            "nadep": "false",
            "lpg_gas": "false",
            "biogas": "true",
            "solar_cooking": "true",
            "electric_connection": "false",
            "nutritional_garden_available": "false",
            "tulsi_plants_available": "yes"
        }
    },
    "social_health_data": {
        "disputes": {
            "family_disputes": None,
            "family_registered": None,
            "family_period": None,
            "revenue_disputes": None,
            "revenue_registered": None,
            "revenue_period": None,
            "criminal_disputes": None,
            "criminal_registered": None,
            "criminal_period": None,
            "other_disputes": None,
            "other_description": None,
            "other_registered": None,
            "other_period": None
        },
        "diseases": None,
        "social_consciousness": {
            "clothes_frequency": None,
            "clothes_other_specify": None,
            "food_waste_exists": None,
            "food_waste_amount": None,
            "waste_disposal": None,
            "waste_disposal_other": None,
            "separate_waste": None,
            "compost_pit": None,
            "recycle_used_items": None,
            "led_lights": None,
            "turn_off_devices": None,
            "fix_leaks": None,
            "avoid_plastics": None,
            "family_prayers": None,
            "family_meditation": None,
            "meditation_members": None,
            "family_yoga": None,
            "yoga_members": None,
            "community_activities": None,
            "spiritual_discourses": None,
            "discourses_members": None,
            "personal_happiness": None,
            "family_happiness": None,
            "happiness_family_who": None,
            "financial_problems": None,
            "family_disputes": None,
            "illness_issues": None,
            "unhappiness_reason": None,
            "addiction_smoke": None,
            "addiction_drink": None,
            "addiction_gutka": None,
            "addiction_gamble": None,
            "addiction_tobacco": None,
            "addiction_details": None
        },
        "children_data": {
            "births_last_3_years": None,
            "infant_deaths_last_3_years": None,
            "malnourished_children": None
        },
        "migration_data": {
            "family_members_migrated": None,
            "reason": None,
            "duration": None,
            "destination": None
        },
        "health_programmes": {
            "vaccination_pregnancy": None,
            "child_vaccination": None,
            "family_planning_awareness": None,
            "contraceptive_applied": None
        }
    },
    "government_schemes_summary": {
        "aadhaar_info": None,
        "ayushman_card": None,
        "ration_card": None,
        "pm_kisan_nidhi": None,
        "pm_kisan_samman_nidhi": None,
        "tribal_card": None,
        "samagra_id": None,
        "family_id": None,
        "handicapped_allowance": None,
        "pension_allowance": None,
        "widow_allowance": None,
        "vb_gram": None
    },
    "government_scheme_members": {
        "aadhaar_scheme_members": None,
        "ayushman_scheme_members": None,
        "ration_scheme_members": None,
        "pm_kisan_members": None,
        "pm_kisan_samman_members": None,
        "tribal_scheme_members": None,
        "samagra_scheme_members": None,
        "handicapped_scheme_members": None,
        "pension_scheme_members": None,
        "widow_scheme_members": None,
        "vb_gram_members": None
    },
    "financial_organizational_data": {
        "bank_accounts": None,
        "shg_members": None,
        "fpo_members": None,
        "training_data": None
    },
    "additional_health_nutrition_data": {
        "child_diseases": None,
        "malnourished_children_data": None,
        "malnutrition_data": None,
        "folklore_medicine": None,
        "nutritional_garden": {
            "has_garden": "false",
            "garden_size": None,
            "vegetables_grown": None
        },
        "tulsi_plants": {
            "has_plants": "yes",
            "plant_count": None
        },
        "tribal_questions": None,
        "merged_govt_schemes": None
    }
}

def count_filled_fields(obj, path=""):
    """Recursively count filled vs null fields in nested JSON structure"""
    filled = 0
    total = 0

    if isinstance(obj, dict):
        for key, value in obj.items():
            current_path = f"{path}.{key}" if path else key
            if isinstance(value, (dict, list)):
                sub_filled, sub_total = count_filled_fields(value, current_path)
                filled += sub_filled
                total += sub_total
            else:
                total += 1
                if value is not None and value != "" and value != [] and value != {}:
                    filled += 1
    elif isinstance(obj, list):
        for i, item in enumerate(obj):
            current_path = f"{path}[{i}]"
            sub_filled, sub_total = count_filled_fields(item, current_path)
            filled += sub_filled
            total += sub_total

    return filled, total

print("=== COMPREHENSIVE FAMILY SURVEY COMPLETENESS REPORT ===")
print(f"Phone Number: {data['phone_number']}")
print("=" * 60)

filled, total = count_filled_fields(data)

print("\n" + "=" * 60)
print("SUMMARY:")
print(f"Total Columns: {total}")
print(f"Filled Columns: {filled}")
print(f"Empty Columns: {total - filled}")
percentage = (filled / total) * 100 if total > 0 else 0
print(".1f")
print("=" * 60)