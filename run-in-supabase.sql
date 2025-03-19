-- INSTRUCTIONS:
-- 1. Go to your Supabase dashboard
-- 2. Navigate to the SQL Editor
-- 3. Create a new query
-- 4. Copy and paste this entire script
-- 5. Run the script
-- 6. After running this script, restart your application

-- Check if the exec_sql function exists and create it if it doesn't
CREATE OR REPLACE FUNCTION exec_sql(sql text)
RETURNS void AS $$
BEGIN
  EXECUTE sql;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Create users table if it doesn't exist
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

-- Drop existing policies for users table to avoid conflicts
DROP POLICY IF EXISTS "Users can view their own data" ON public.users;
DROP POLICY IF EXISTS "Users can update their own data" ON public.users;
DROP POLICY IF EXISTS "Admins can view all data" ON public.users;

-- Create policies for users table
CREATE POLICY "Users can view their own data" 
  ON public.users 
  FOR SELECT 
  USING (auth.uid() = id);

CREATE POLICY "Users can update their own data" 
  ON public.users 
  FOR UPDATE 
  USING (auth.uid() = id);

CREATE POLICY "Admins can view all data" 
  ON public.users 
  USING (role = 'admin');

-- Grant permissions
GRANT ALL ON public.users TO authenticated;
GRANT ALL ON public.users TO service_role;

-- Create notifications table if it doesn't exist
CREATE TABLE IF NOT EXISTS public.notifications (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  title TEXT NOT NULL,
  message TEXT NOT NULL,
  type TEXT NOT NULL,
  metadata JSONB DEFAULT '{}'::jsonb,
  read BOOLEAN DEFAULT false,
  for_admin BOOLEAN DEFAULT false,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

-- Add for_admin column to notifications table if it doesn't exist
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT FROM information_schema.columns 
    WHERE table_name = 'notifications' AND column_name = 'for_admin'
  ) THEN
    ALTER TABLE public.notifications ADD COLUMN for_admin BOOLEAN DEFAULT false;
  END IF;
END $$;

-- Create indexes for better query performance
CREATE INDEX IF NOT EXISTS idx_notifications_read ON public.notifications(read);
CREATE INDEX IF NOT EXISTS idx_notifications_created_at ON public.notifications(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_notifications_for_admin ON public.notifications(for_admin);

-- Enable Row Level Security
ALTER TABLE public.notifications ENABLE ROW LEVEL SECURITY;

-- Drop existing policies for notifications
DROP POLICY IF EXISTS "Anyone can view notifications" ON public.notifications;

-- Create policies for notifications
CREATE POLICY "Anyone can view notifications" 
  ON public.notifications 
  FOR SELECT 
  USING (true);

-- Grant permissions
GRANT ALL ON public.notifications TO authenticated;
GRANT ALL ON public.notifications TO service_role;

-- Create buying_activities table if it doesn't exist
CREATE TABLE IF NOT EXISTS public.buying_activities (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_email TEXT NOT NULL,
  challenge_name TEXT NOT NULL,
  account_size TEXT NOT NULL,
  amount NUMERIC NOT NULL,
  currency TEXT NOT NULL,
  wallet_address TEXT,
  status TEXT DEFAULT 'pending',
  metadata JSONB DEFAULT '{}'::jsonb,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

-- Create indexes for better query performance
CREATE INDEX IF NOT EXISTS idx_buying_activities_user_email ON public.buying_activities(user_email);
CREATE INDEX IF NOT EXISTS idx_buying_activities_status ON public.buying_activities(status);
CREATE INDEX IF NOT EXISTS idx_buying_activities_created_at ON public.buying_activities(created_at DESC);

-- Enable Row Level Security
ALTER TABLE public.buying_activities ENABLE ROW LEVEL SECURITY;

-- Drop existing policies for buying_activities
DROP POLICY IF EXISTS "Anyone can view buying activities" ON public.buying_activities;

-- Create policies for buying_activities
CREATE POLICY "Anyone can view buying activities" 
  ON public.buying_activities 
  FOR SELECT 
  USING (true);

-- Grant permissions
GRANT SELECT ON public.buying_activities TO authenticated;
GRANT ALL ON public.buying_activities TO service_role;

-- Create user_mt5_accounts table if it doesn't exist
CREATE TABLE IF NOT EXISTS public.user_mt5_accounts (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_email TEXT NOT NULL,
  account_number BIGINT NOT NULL UNIQUE,
  account_name TEXT NOT NULL,
  server TEXT NOT NULL DEFAULT 'Exness-MT5Trial',
  account_type TEXT NOT NULL DEFAULT 'Demo',
  target_profit_percent NUMERIC DEFAULT 10,
  max_daily_drawdown_percent NUMERIC DEFAULT 5,
  max_overall_drawdown_percent NUMERIC DEFAULT 10,
  initial_balance NUMERIC DEFAULT 10000,
  password TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

-- Create indexes for better query performance
CREATE INDEX IF NOT EXISTS idx_user_mt5_accounts_user_email ON public.user_mt5_accounts(user_email);
CREATE INDEX IF NOT EXISTS idx_user_mt5_accounts_account_number ON public.user_mt5_accounts(account_number);

-- Enable Row Level Security
ALTER TABLE public.user_mt5_accounts ENABLE ROW LEVEL SECURITY;

-- Drop existing policies for user_mt5_accounts
DROP POLICY IF EXISTS "Users can view their own MT5 accounts" ON public.user_mt5_accounts;
DROP POLICY IF EXISTS "Admins can manage all MT5 accounts" ON public.user_mt5_accounts;
DROP POLICY IF EXISTS "Anyone can view MT5 accounts" ON public.user_mt5_accounts;
DROP POLICY IF EXISTS "Anyone can manage MT5 accounts" ON public.user_mt5_accounts;

-- Create policies for user_mt5_accounts
CREATE POLICY "Anyone can view MT5 accounts" 
  ON public.user_mt5_accounts 
  FOR SELECT 
  USING (true);

CREATE POLICY "Anyone can manage MT5 accounts" 
  ON public.user_mt5_accounts 
  FOR ALL
  USING (true);

-- Grant permissions
GRANT ALL ON public.user_mt5_accounts TO authenticated;
GRANT ALL ON public.user_mt5_accounts TO service_role;

-- Create mt5_account_data table if it doesn't exist
CREATE TABLE IF NOT EXISTS public.mt5_account_data (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  account_number BIGINT NOT NULL UNIQUE,
  balance NUMERIC,
  equity NUMERIC,
  profit NUMERIC,
  margin_level NUMERIC,
  daily_drawdown NUMERIC,
  daily_drawdown_left NUMERIC,
  overall_drawdown NUMERIC,
  overall_drawdown_left NUMERIC,
  profit_target_progress NUMERIC,
  profit_target_left NUMERIC,
  open_positions JSONB DEFAULT '[]'::jsonb,
  recent_trades JSONB DEFAULT '[]'::jsonb,
  last_updated_by TEXT,
  timestamp TIMESTAMP WITH TIME ZONE DEFAULT now(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

-- Add missing columns if they don't exist
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
  
  -- Refresh the schema cache
  PERFORM pg_notify('pgrst', 'reload schema');
END $$;

-- Create indexes for better query performance
CREATE INDEX IF NOT EXISTS idx_mt5_account_data_account_number ON public.mt5_account_data(account_number);
CREATE INDEX IF NOT EXISTS idx_mt5_account_data_updated_at ON public.mt5_account_data(updated_at DESC);

-- Enable Row Level Security
ALTER TABLE public.mt5_account_data ENABLE ROW LEVEL SECURITY;

-- Drop existing policies for mt5_account_data
DROP POLICY IF EXISTS "Users can view their own MT5 account data" ON public.mt5_account_data;
DROP POLICY IF EXISTS "Admins can view all MT5 account data" ON public.mt5_account_data;
DROP POLICY IF EXISTS "Anyone can view MT5 account data" ON public.mt5_account_data;
DROP POLICY IF EXISTS "Anyone can manage MT5 account data" ON public.mt5_account_data;

-- Create policies for mt5_account_data
CREATE POLICY "Anyone can view MT5 account data" 
  ON public.mt5_account_data 
  FOR SELECT 
  USING (true);

CREATE POLICY "Anyone can manage MT5 account data" 
  ON public.mt5_account_data 
  FOR ALL
  USING (true);

-- Grant permissions
GRANT ALL ON public.mt5_account_data TO authenticated;
GRANT ALL ON public.mt5_account_data TO service_role;

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
  initial_balance,
  password
) VALUES (
  'ali.asghar.mwm@gmail.com',
  12345678,
  'Test MT5 Account',
  'Exness-MT5Trial',
  'Demo',
  10,
  5,
  10,
  10000,
  'TestPassword123'
) ON CONFLICT (account_number) DO UPDATE
SET 
  user_email = EXCLUDED.user_email,
  account_name = EXCLUDED.account_name,
  server = EXCLUDED.server,
  account_type = EXCLUDED.account_type,
  password = EXCLUDED.password;

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
  profit_target_progress,
  profit_target_left,
  last_updated_by
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
  50,
  5,
  'admin'
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

-- Add a test notification
INSERT INTO public.notifications (
  title,
  message,
  type,
  metadata,
  read,
  for_admin,
  created_at,
  updated_at
) VALUES (
  'Test Notification',
  'This is a test notification',
  'info',
  '{"test": true}'::jsonb,
  false,
  false,
  now(),
  now()
);

-- Verify the data was inserted
SELECT * FROM public.users WHERE email = 'ali.asghar.mwm@gmail.com';
SELECT * FROM public.user_mt5_accounts WHERE user_email = 'ali.asghar.mwm@gmail.com';
SELECT * FROM public.mt5_account_data WHERE account_number = 12345678;
SELECT * FROM public.notifications; 