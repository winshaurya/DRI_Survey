-- Migration: Change shg_members PK from (phone_number, member_name) to (phone_number, sr_no)

-- Step 1: Drop the existing primary key constraint
ALTER TABLE public.shg_members DROP CONSTRAINT IF EXISTS shg_members_pkey;

-- Step 2: Add sr_no column (if it doesn't exist)
ALTER TABLE public.shg_members ADD COLUMN IF NOT EXISTS sr_no INTEGER;

-- Step 3: For existing data, set sr_no based on row order within each phone_number group
-- This ensures existing data gets sequential sr_no values
WITH numbered_rows AS (
  SELECT 
    phone_number, 
    member_name,
    ROW_NUMBER() OVER (PARTITION BY phone_number ORDER BY created_at, member_name) as row_num
  FROM public.shg_members
  WHERE sr_no IS NULL
)
UPDATE public.shg_members
SET sr_no = numbered_rows.row_num
FROM numbered_rows
WHERE public.shg_members.phone_number = numbered_rows.phone_number 
  AND public.shg_members.member_name = numbered_rows.member_name
  AND public.shg_members.sr_no IS NULL;

-- Step 4: Make sr_no NOT NULL
ALTER TABLE public.shg_members ALTER COLUMN sr_no SET NOT NULL;

-- Step 5: Add new primary key constraint
ALTER TABLE public.shg_members ADD CONSTRAINT shg_members_pkey PRIMARY KEY (phone_number, sr_no);

-- Verification query (optional - shows the updated structure)
-- SELECT * FROM public.shg_members ORDER BY phone_number, sr_no LIMIT 10;
