-- Fix permissions for user_mt5_accounts table

-- First, check if the table exists
SELECT EXISTS (
   SELECT FROM information_schema.tables 
   WHERE table_schema = 'public'
   AND table_name = 'user_mt5_accounts'
);

-- Drop existing policies for user_mt5_accounts
DROP POLICY IF EXISTS "Users can view their own MT5 accounts" ON public.user_mt5_accounts;
DROP POLICY IF EXISTS "Admins can manage all MT5 accounts" ON public.user_mt5_accounts;
DROP POLICY IF EXISTS "Anyone can view MT5 accounts" ON public.user_mt5_accounts;

-- Create policies for user_mt5_accounts (only if they don't exist)
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT FROM pg_policies WHERE tablename = 'user_mt5_accounts' AND policyname = 'Anyone can view MT5 accounts'
  ) THEN
    CREATE POLICY "Anyone can view MT5 accounts" 
      ON public.user_mt5_accounts 
      FOR SELECT 
      USING (true);
  END IF;

  IF NOT EXISTS (
    SELECT FROM pg_policies WHERE tablename = 'user_mt5_accounts' AND policyname = 'Admins can manage all MT5 accounts'
  ) THEN
    CREATE POLICY "Admins can manage all MT5 accounts" 
      ON public.user_mt5_accounts 
      FOR ALL
      USING (true);
  END IF;
END
$$;

-- Drop existing policies for mt5_account_data
DROP POLICY IF EXISTS "Users can view their own MT5 account data" ON public.mt5_account_data;
DROP POLICY IF EXISTS "Admins can view all MT5 account data" ON public.mt5_account_data;
DROP POLICY IF EXISTS "Anyone can view MT5 account data" ON public.mt5_account_data;

-- Create policies for mt5_account_data (only if they don't exist)
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT FROM pg_policies WHERE tablename = 'mt5_account_data' AND policyname = 'Anyone can view MT5 account data'
  ) THEN
    CREATE POLICY "Anyone can view MT5 account data" 
      ON public.mt5_account_data 
      FOR SELECT 
      USING (true);
  END IF;

  IF NOT EXISTS (
    SELECT FROM pg_policies WHERE tablename = 'mt5_account_data' AND policyname = 'Admins can manage all MT5 account data'
  ) THEN
    CREATE POLICY "Admins can manage all MT5 account data" 
      ON public.mt5_account_data 
      FOR ALL
      USING (true);
  END IF;
END
$$;

-- Make sure the users table exists
CREATE TABLE IF NOT EXISTS public.users (
  id UUID PRIMARY KEY,
  email TEXT NOT NULL UNIQUE,
  first_name TEXT,
  last_name TEXT,
  role TEXT DEFAULT 'user',
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

-- Enable Row Level Security on users table
ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;

-- Insert the admin user if not exists
INSERT INTO public.users (id, email, role)
SELECT 
  COALESCE((SELECT id FROM auth.users WHERE email = 'ali.asghar.mwm@gmail.com'), uuid_generate_v4()),
  'ali.asghar.mwm@gmail.com',
  'admin'
ON CONFLICT (email) DO UPDATE
SET role = 'admin';

-- Add a test MT5 account for the user
INSERT INTO public.user_mt5_accounts (
  user_email,
  account_number,
  account_name,
  server,
  account_type,
  target_profit_percent,
  max_daily_drawdown_percent,
  max_overall_drawdown_percent,
  initial_balance
) VALUES (
  'ali.asghar.mwm@gmail.com',
  12345678,
  'Test MT5 Account',
  'Exness-MT5Trial',
  'Demo',
  10,
  5,
  10,
  10000
) ON CONFLICT (account_number) DO UPDATE
SET 
  user_email = EXCLUDED.user_email,
  account_name = EXCLUDED.account_name,
  server = EXCLUDED.server,
  account_type = EXCLUDED.account_type;

-- Add test MT5 account data
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
  profit_target_progress
) VALUES (
  12345678,
  10500,
  10600,
  500,
  95,
  2,
  3,
  5,
  5,
  50
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
  profit_target_progress = EXCLUDED.profit_target_progress;

-- Verify the data was inserted
SELECT * FROM public.user_mt5_accounts WHERE user_email = 'ali.asghar.mwm@gmail.com';
SELECT * FROM public.mt5_account_data WHERE account_number = 12345678; 