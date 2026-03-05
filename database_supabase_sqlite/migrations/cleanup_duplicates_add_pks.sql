-- Cleanup Duplicates and Apply PKs for failing tables

-- 1. disputes
DELETE FROM disputes
WHERE ctid NOT IN (
  SELECT MAX(ctid)
  FROM disputes
  GROUP BY phone_number
);
ALTER TABLE disputes ADD CONSTRAINT disputes_pkey PRIMARY KEY (phone_number);

-- 2. drinking_water_sources
DELETE FROM drinking_water_sources
WHERE ctid NOT IN (
  SELECT MAX(ctid)
  FROM drinking_water_sources
  GROUP BY phone_number
);
ALTER TABLE drinking_water_sources ADD CONSTRAINT drinking_water_sources_pkey PRIMARY KEY (phone_number);

-- 3. entertainment_facilities
DELETE FROM entertainment_facilities
WHERE ctid NOT IN (
  SELECT MAX(ctid)
  FROM entertainment_facilities
  GROUP BY phone_number
);
ALTER TABLE entertainment_facilities ADD CONSTRAINT entertainment_facilities_pkey PRIMARY KEY (phone_number);

-- 4. house_conditions
DELETE FROM house_conditions
WHERE ctid NOT IN (
  SELECT MAX(ctid)
  FROM house_conditions
  GROUP BY phone_number
);
ALTER TABLE house_conditions ADD CONSTRAINT house_conditions_pkey PRIMARY KEY (phone_number);

-- 5. house_facilities
DELETE FROM house_facilities
WHERE ctid NOT IN (
  SELECT MAX(ctid)
  FROM house_facilities
  GROUP BY phone_number
);
ALTER TABLE house_facilities ADD CONSTRAINT house_facilities_pkey PRIMARY KEY (phone_number);

-- 6. irrigation_facilities
DELETE FROM irrigation_facilities
WHERE ctid NOT IN (
  SELECT MAX(ctid)
  FROM irrigation_facilities
  GROUP BY phone_number
);
ALTER TABLE irrigation_facilities ADD CONSTRAINT irrigation_facilities_pkey PRIMARY KEY (phone_number);

-- 7. transport_facilities
DELETE FROM transport_facilities
WHERE ctid NOT IN (
  SELECT MAX(ctid)
  FROM transport_facilities
  GROUP BY phone_number
);
ALTER TABLE transport_facilities ADD CONSTRAINT transport_facilities_pkey PRIMARY KEY (phone_number);
