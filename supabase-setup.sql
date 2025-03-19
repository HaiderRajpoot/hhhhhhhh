-- Create the exec_sql function
CREATE OR REPLACE FUNCTION exec_sql(sql text)
RETURNS void AS $$
BEGIN
  EXECUTE sql;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Create users table
CREATE TABLE IF NOT EXISTS public.users (
  id UUID PRIMARY KEY,
  email TEXT NOT NULL UNIQUE,
  first_name TEXT,
  last_name TEXT,
  role TEXT DEFAULT 'user',
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

-- Enable Row Level Security
ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;

-- Create policies for users (only if they don't exist)
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT FROM pg_policies WHERE tablename = 'users' AND policyname = 'Users can view their own data'
  ) THEN
    CREATE POLICY "Users can view their own data" 
      ON public.users 
      FOR SELECT 
      USING (auth.uid() = id);
  END IF;

  IF NOT EXISTS (
    SELECT FROM pg_policies WHERE tablename = 'users' AND policyname = 'Users can update their own data'
  ) THEN
    CREATE POLICY "Users can update their own data" 
      ON public.users 
      FOR UPDATE 
      USING (auth.uid() = id);
  END IF;

  IF NOT EXISTS (
    SELECT FROM pg_policies WHERE tablename = 'users' AND policyname = 'Admins can view all data'
  ) THEN
    CREATE POLICY "Admins can view all data" 
      ON public.users 
      USING (role = 'admin');
  END IF;
END
$$;

-- Grant permissions
GRANT ALL ON public.users TO authenticated;
GRANT ALL ON public.users TO service_role;

-- Create a trigger to automatically add new users
CREATE OR REPLACE FUNCTION public.handle_new_user() 
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.users (id, email, role)
  VALUES (NEW.id, NEW.email, 
    CASE 
      WHEN NEW.email = 'ali.asghar.mwm@gmail.com' THEN 'admin'
      ELSE 'user'
    END
  );
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Drop trigger if exists and create it
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- Insert existing users
INSERT INTO public.users (id, email, role)
SELECT id, email, 
  CASE 
    WHEN email = 'ali.asghar.mwm@gmail.com' THEN 'admin'
    ELSE 'user'
  END
FROM auth.users
ON CONFLICT (id) DO UPDATE
SET role = 
  CASE 
    WHEN EXCLUDED.email = 'ali.asghar.mwm@gmail.com' THEN 'admin'
    ELSE users.role
  END;

-- Create notifications table
CREATE TABLE IF NOT EXISTS public.notifications (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  title TEXT NOT NULL,
  message TEXT NOT NULL,
  type TEXT NOT NULL,
  metadata JSONB DEFAULT '{}'::jsonb,
  read BOOLEAN DEFAULT false,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

-- Create indexes for better query performance
CREATE INDEX IF NOT EXISTS idx_notifications_read ON public.notifications(read);
CREATE INDEX IF NOT EXISTS idx_notifications_created_at ON public.notifications(created_at DESC);

-- Enable Row Level Security
ALTER TABLE public.notifications ENABLE ROW LEVEL SECURITY;

-- Grant permissions
GRANT ALL ON public.notifications TO authenticated;
GRANT ALL ON public.notifications TO service_role;

-- Create buying_activities table
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

-- Create policies for buying_activities (only if they don't exist)
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT FROM pg_policies WHERE tablename = 'buying_activities' AND policyname = 'Users can view their own buying activities'
  ) THEN
    CREATE POLICY "Users can view their own buying activities" 
      ON public.buying_activities 
      FOR SELECT 
      USING (user_email = auth.jwt() ->> 'email');
  END IF;

  IF NOT EXISTS (
    SELECT FROM pg_policies WHERE tablename = 'buying_activities' AND policyname = 'Admins can view all buying activities'
  ) THEN
    CREATE POLICY "Admins can view all buying activities" 
      ON public.buying_activities 
      USING (
        EXISTS (
          SELECT 1 FROM users WHERE email = auth.jwt() ->> 'email' AND role = 'admin'
        )
      );
  END IF;
END
$$;

-- Grant permissions
GRANT SELECT ON public.buying_activities TO authenticated;
GRANT ALL ON public.buying_activities TO service_role;

-- Create user_mt5_accounts table
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
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

-- Create indexes for better query performance
CREATE INDEX IF NOT EXISTS idx_user_mt5_accounts_user_email ON public.user_mt5_accounts(user_email);
CREATE INDEX IF NOT EXISTS idx_user_mt5_accounts_account_number ON public.user_mt5_accounts(account_number);

-- Enable Row Level Security
ALTER TABLE public.user_mt5_accounts ENABLE ROW LEVEL SECURITY;

-- Create policies for user_mt5_accounts (only if they don't exist)
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT FROM pg_policies WHERE tablename = 'user_mt5_accounts' AND policyname = 'Users can view their own MT5 accounts'
  ) THEN
    CREATE POLICY "Users can view their own MT5 accounts" 
      ON public.user_mt5_accounts 
      FOR SELECT 
      USING (user_email = auth.jwt() ->> 'email');
  END IF;

  IF NOT EXISTS (
    SELECT FROM pg_policies WHERE tablename = 'user_mt5_accounts' AND policyname = 'Admins can manage all MT5 accounts'
  ) THEN
    CREATE POLICY "Admins can manage all MT5 accounts" 
      ON public.user_mt5_accounts 
      FOR ALL
      USING (
        EXISTS (
          SELECT 1 FROM users WHERE email = auth.jwt() ->> 'email' AND role = 'admin'
        )
      );
  END IF;
END
$$;

-- Grant permissions
GRANT SELECT ON public.user_mt5_accounts TO authenticated;
GRANT ALL ON public.user_mt5_accounts TO service_role;

-- Create mt5_account_data table
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
  open_positions JSONB DEFAULT '[]'::jsonb,
  recent_trades JSONB DEFAULT '[]'::jsonb,
  timestamp TIMESTAMP WITH TIME ZONE DEFAULT now(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

-- Create indexes for better query performance
CREATE INDEX IF NOT EXISTS idx_mt5_account_data_account_number ON public.mt5_account_data(account_number);

-- Enable Row Level Security
ALTER TABLE public.mt5_account_data ENABLE ROW LEVEL SECURITY;

-- Create policies for mt5_account_data (only if they don't exist)
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT FROM pg_policies WHERE tablename = 'mt5_account_data' AND policyname = 'Users can view their own MT5 account data'
  ) THEN
    CREATE POLICY "Users can view their own MT5 account data" 
      ON public.mt5_account_data 
      FOR SELECT 
      USING (
        account_number IN (
          SELECT account_number FROM public.user_mt5_accounts WHERE user_email = auth.jwt() ->> 'email'
        )
      );
  END IF;

  IF NOT EXISTS (
    SELECT FROM pg_policies WHERE tablename = 'mt5_account_data' AND policyname = 'Admins can view all MT5 account data'
  ) THEN
    CREATE POLICY "Admins can view all MT5 account data" 
      ON public.mt5_account_data 
      USING (
        EXISTS (
          SELECT 1 FROM users WHERE email = auth.jwt() ->> 'email' AND role = 'admin'
        )
      );
  END IF;
END
$$;

-- Grant permissions
GRANT SELECT ON public.mt5_account_data TO authenticated;
GRANT ALL ON public.mt5_account_data TO service_role;

-- Check if the user exists and has admin role
SELECT id, email, role FROM public.users WHERE email = 'ali.asghar.mwm@gmail.com';

-- If the user doesn't exist or doesn't have admin role, insert/update them
INSERT INTO public.users (id, email, role)
SELECT id, email, 'admin'
FROM auth.users
WHERE email = 'ali.asghar.mwm@gmail.com'
ON CONFLICT (email) DO UPDATE
SET role = 'admin';

-- Drop existing policies for user_mt5_accounts to recreate them with more permissive settings
DROP POLICY IF EXISTS "Users can view their own MT5 accounts" ON public.user_mt5_accounts;
DROP POLICY IF EXISTS "Admins can manage all MT5 accounts" ON public.user_mt5_accounts;

-- Create more permissive policies for testing
CREATE POLICY "Anyone can view MT5 accounts" 
  ON public.user_mt5_accounts 
  FOR SELECT 
  USING (true);

CREATE POLICY "Admins can manage all MT5 accounts" 
  ON public.user_mt5_accounts 
  FOR ALL
  USING (
    EXISTS (
      SELECT 1 FROM users WHERE email = auth.jwt() ->> 'email' AND role = 'admin'
    )
  );

-- Drop existing policies for mt5_account_data to recreate them with more permissive settings
DROP POLICY IF EXISTS "Users can view their own MT5 account data" ON public.mt5_account_data;
DROP POLICY IF EXISTS "Admins can view all MT5 account data" ON public.mt5_account_data;

-- Create more permissive policies for testing
CREATE POLICY "Anyone can view MT5 account data" 
  ON public.mt5_account_data 
  FOR SELECT 
  USING (true);

CREATE POLICY "Admins can manage all MT5 account data" 
  ON public.mt5_account_data 
  FOR ALL
  USING (
    EXISTS (
      SELECT 1 FROM users WHERE email = auth.jwt() ->> 'email' AND role = 'admin'
    )
  ); 