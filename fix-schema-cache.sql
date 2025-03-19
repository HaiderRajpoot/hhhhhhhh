-- Run this script in the Supabase SQL Editor to fix the schema cache issue

-- 1. First, let's make sure all required columns exist
DO $$
BEGIN
  -- Add last_updated_by column if it doesn't exist
  IF NOT EXISTS (
    SELECT FROM information_schema.columns 
    WHERE table_name = 'mt5_account_data' AND column_name = 'last_updated_by'
  ) THEN
    ALTER TABLE public.mt5_account_data ADD COLUMN last_updated_by TEXT;
  END IF;
  
  -- Add profit_target_left column if it doesn't exist
  IF NOT EXISTS (
    SELECT FROM information_schema.columns 
    WHERE table_name = 'mt5_account_data' AND column_name = 'profit_target_left'
  ) THEN
    ALTER TABLE public.mt5_account_data ADD COLUMN profit_target_left NUMERIC;
  END IF;
  
  -- Add daily_drawdown_left column if it doesn't exist
  IF NOT EXISTS (
    SELECT FROM information_schema.columns 
    WHERE table_name = 'mt5_account_data' AND column_name = 'daily_drawdown_left'
  ) THEN
    ALTER TABLE public.mt5_account_data ADD COLUMN daily_drawdown_left NUMERIC;
  END IF;
  
  -- Add overall_drawdown_left column if it doesn't exist
  IF NOT EXISTS (
    SELECT FROM information_schema.columns 
    WHERE table_name = 'mt5_account_data' AND column_name = 'overall_drawdown_left'
  ) THEN
    ALTER TABLE public.mt5_account_data ADD COLUMN overall_drawdown_left NUMERIC;
  END IF;
  
  -- Add profit_target_progress column if it doesn't exist
  IF NOT EXISTS (
    SELECT FROM information_schema.columns 
    WHERE table_name = 'mt5_account_data' AND column_name = 'profit_target_progress'
  ) THEN
    ALTER TABLE public.mt5_account_data ADD COLUMN profit_target_progress NUMERIC;
  END IF;

  -- Check for and add password column to user_mt5_accounts if it doesn't exist
  IF NOT EXISTS (
    SELECT FROM information_schema.columns 
    WHERE table_name = 'user_mt5_accounts' AND column_name = 'password'
  ) THEN
    ALTER TABLE public.user_mt5_accounts ADD COLUMN password TEXT;
    RAISE NOTICE 'Added password column to user_mt5_accounts table';
  ELSE
    RAISE NOTICE 'Password column already exists in user_mt5_accounts table';
  END IF;
END $$;

-- 2. Force a schema cache refresh
SELECT pg_notify('pgrst', 'reload schema');

-- 3. Verify the columns exist
SELECT column_name, data_type 
FROM information_schema.columns 
WHERE table_name = 'mt5_account_data';

-- 4. Insert a test record to ensure everything works
INSERT INTO public.mt5_account_data (
  account_number,
  balance,
  equity,
  profit,
  margin_level,
  daily_drawdown,
  daily_drawdown_left,
  overall_drawdown,
  overall_drawdown_left,
  profit_target_progress,
  profit_target_left,
  last_updated_by
) VALUES (
  99999999,  -- Use a test account number that doesn't exist
  10000,
  10000,
  0,
  100,
  0,
  5,
  0,
  10,
  0,
  10,
  'test_admin'
) ON CONFLICT (account_number) DO UPDATE
SET 
  balance = EXCLUDED.balance,
  equity = EXCLUDED.equity,
  profit = EXCLUDED.profit,
  margin_level = EXCLUDED.margin_level,
  daily_drawdown = EXCLUDED.daily_drawdown,
  daily_drawdown_left = EXCLUDED.daily_drawdown_left,
  overall_drawdown = EXCLUDED.overall_drawdown,
  overall_drawdown_left = EXCLUDED.overall_drawdown_left,
  profit_target_progress = EXCLUDED.profit_target_progress,
  profit_target_left = EXCLUDED.profit_target_left,
  last_updated_by = EXCLUDED.last_updated_by,
  updated_at = now();

-- 5. Verify the test record was inserted
SELECT * FROM public.mt5_account_data WHERE account_number = 99999999;

-- Verify columns exist
SELECT 
  table_name, 
  column_name, 
  data_type 
FROM 
  information_schema.columns 
WHERE 
  table_name IN ('user_mt5_accounts', 'mt5_account_data') 
  AND column_name IN ('password', 'last_updated_by', 'profit_target_left', 'daily_drawdown_left', 'overall_drawdown_left', 'profit_target_progress')
ORDER BY 
  table_name, 
  column_name; 