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