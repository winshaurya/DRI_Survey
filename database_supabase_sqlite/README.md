# Database Schemas for DRI Survey App

This folder contains Supabase-compatible database schemas for both Village Survey and Family Survey applications. These schemas are designed to be idempotent (can be run multiple times safely) and work with both Supabase and SQLite.

## Files

- `village_survey_schema.sql` - Complete schema for village-level survey data
- `family_survey_schema.sql` - Complete schema for family-level survey data

## Features

### ✅ Idempotent Design
- All `CREATE TABLE` statements use `IF NOT EXISTS`
- All `CREATE INDEX` statements use `IF NOT EXISTS`
- All `CREATE POLICY` statements use `IF NOT EXISTS` (where supported)
- Safe to run multiple times without errors

### ✅ Supabase Compatibility
- Uses `UUID` primary keys with `uuid_generate_v4()`
- Includes Row Level Security (RLS) policies
- Uses `TIMESTAMPTZ` for timestamps
- Includes `JSONB` for flexible metadata storage
- PostGIS extension support for GPS coordinates

### ✅ SQLite Compatibility
- All Supabase-specific features gracefully degrade for SQLite
- Uses standard SQL types where possible
- Maintains referential integrity with foreign keys

### ✅ GPS & SHINE Integration
- GPS coordinates with accuracy tracking
- SHINE code integration for village auto-fill
- Location timestamp tracking

### ✅ Comprehensive Data Model
- **Village Survey**: 25+ tables covering population, housing, agriculture, infrastructure, etc.
- **Family Survey**: 50+ tables covering family members, government schemes, health, education, etc.

## Usage Instructions

### For Supabase

1. **Create a new Supabase project** or use existing one
2. **Open Supabase SQL Editor**
3. **Run the schemas in order:**
   ```sql
   -- Run village survey schema first
   \i database_supabase_sqlite/village_survey_schema.sql

   -- Then run family survey schema
   \i database_supabase_sqlite/family_survey_schema.sql
   ```
4. **Verify tables were created** in the Table Editor

### For Local SQLite Development

1. **Use the schemas directly** in your SQLite database
2. **Remove Supabase-specific parts** if needed:
   - Remove `CREATE EXTENSION` statements
   - Replace `UUID` with `TEXT` or `INTEGER`
   - Remove RLS policies
   - Replace `TIMESTAMPTZ` with `TEXT` or `DATETIME`

### Testing Multiple Runs

You can safely run these schemas multiple times:

```sql
-- This will work without errors (idempotent)
\i database_supabase_sqlite/village_survey_schema.sql
\i database_supabase_sqlite/village_survey_schema.sql
\i database_supabase_sqlite/village_survey_schema.sql
```

## Schema Overview

### Village Survey Tables
- `village_survey_sessions` - Main session table
- `village_population` - Population demographics
- `village_farm_families` - Farm family categorization
- `village_housing` - Housing conditions and facilities
- `village_crop_productivity` - Agricultural production data
- `village_animals` - Livestock information
- `village_irrigation_facilities` - Water management
- `village_drinking_water` - Water sources
- `village_transport` - Transportation facilities
- `village_entertainment` - Media and entertainment
- `village_medical_treatment` - Healthcare preferences
- `village_disputes` - Legal dispute information
- `village_educational_facilities` - Schools and training
- `village_social_consciousness` - Community behavior data
- And 10+ more specialized tables...

### Family Survey Tables
- `family_survey_sessions` - Main session table
- `family_members` - Detailed family member information
- `land_holding` - Agricultural land data
- `crop_productivity` - Crop production details
- `animals` - Livestock with breeds
- `fertilizer_usage` - Agricultural inputs
- `house_conditions` - Housing quality
- `house_facilities` - Home amenities
- `medical_treatment` - Healthcare access
- `diseases` - Health condition tracking
- **Government Schemes** (15+ tables):
  - Aadhaar, Ayushman, Family ID, Ration Card
  - Samagra, Tribal Card, Pension, Widow Allowance
  - PM Kisan, Kisan Credit Card, Fasal Bima, etc.
- `social_consciousness` - Lifestyle and behavior data
- `training_data` - Education and skill development
- `self_help_groups` - Community organization participation
- And 30+ more specialized tables...

## Key Design Decisions

### 1. UUID Primary Keys
- Ensures global uniqueness across distributed systems
- Better for data synchronization
- Supabase native support

### 2. Session-Based Architecture
- Village surveys use `session_id` (unique per survey)
- Family surveys use `phone_number` (unique per family)
- Enables multiple survey instances per entity

### 3. Referential Integrity
- Foreign key constraints ensure data consistency
- CASCADE deletes maintain referential integrity
- UNIQUE constraints prevent duplicate entries

### 4. Flexible Data Types
- `TEXT` for open-ended responses
- `DECIMAL` for precise numeric data
- `INTEGER` for counts and IDs
- `BOOLEAN` for yes/no questions
- `JSONB` for complex metadata

### 5. Performance Optimization
- Strategic indexes on commonly queried columns
- Generated columns for calculated totals
- Efficient foreign key relationships

### 6. Security
- Row Level Security enabled on all tables
- Policies restrict access to authenticated users
- Extensible for more granular permissions

## Migration Notes

### From Existing Schema
If migrating from the current `schema.sql`:

1. **Backup existing data**
2. **Run new schemas** (they're additive)
3. **Update application code** to use new table names
4. **Test data integrity**

### Field Mapping
- `survey_sessions` → `family_survey_sessions`
- `village_survey_sessions` → `village_survey_sessions` (same name)
- Most field names remain consistent
- New GPS and SHINE fields added

## Troubleshooting

### Common Issues

1. **Extension Not Found**
   ```
   ERROR: extension "uuid-ossp" does not exist
   ```
   **Solution**: Run schemas in Supabase (extensions pre-installed)

2. **Permission Denied**
   ```
   ERROR: permission denied for schema public
   ```
   **Solution**: Ensure you're using database admin credentials

3. **Table Already Exists**
   ```
   ERROR: relation "table_name" already exists
   ```
   **Solution**: Schemas are idempotent - this shouldn't happen with `IF NOT EXISTS`

### Verification Queries

Check if schemas loaded correctly:

```sql
-- Count tables created
SELECT COUNT(*) FROM information_schema.tables
WHERE table_schema = 'public';

-- Check specific table
\d village_survey_sessions;

-- Verify RLS is enabled
SELECT tablename, rowsecurity
FROM pg_tables
WHERE schemaname = 'public'
ORDER BY tablename;
```

## Support

These schemas are designed to work seamlessly with the existing Flutter application code. All table and column names match the current database service implementation.