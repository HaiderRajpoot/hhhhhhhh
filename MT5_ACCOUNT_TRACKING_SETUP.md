# MT5 Account Tracking Setup Guide

This guide explains how to set up and use the MetaTrader 5 (MT5) account tracking feature in the My Forex Funding application. This feature allows users to connect their Exness MT5 demo accounts and view real-time trading data on their dashboard.

## Overview

The MT5 account tracking system consists of three main components:

1. **Python Script**: Runs on a VPS, connects to MT5 accounts, and fetches real-time data
2. **Backend API**: Receives data from the Python script and stores it in Supabase
3. **Frontend Dashboard**: Displays the MT5 account data to users

## Setup Instructions

### 1. Database Setup

First, you need to set up the required tables in your Supabase database:

1. Log in to your Supabase dashboard
2. Go to the SQL Editor
3. Run the following SQL script:

```sql
-- Create table for storing MT5 account data
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

-- Create table for storing historical MT5 account data for charts
CREATE TABLE IF NOT EXISTS public.mt5_account_history (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  account_number BIGINT NOT NULL,
  balance NUMERIC,
  equity NUMERIC,
  profit NUMERIC,
  daily_drawdown NUMERIC,
  overall_drawdown NUMERIC,
  profit_target_progress NUMERIC,
  timestamp TIMESTAMP WITH TIME ZONE DEFAULT now()
);

-- Create table for mapping users to MT5 accounts
CREATE TABLE IF NOT EXISTS public.user_mt5_accounts (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id TEXT NOT NULL,
  account_number BIGINT NOT NULL,
  account_name TEXT,
  server TEXT,
  account_type TEXT,
  target_profit_percent NUMERIC DEFAULT 10,
  max_daily_drawdown_percent NUMERIC DEFAULT 5,
  max_overall_drawdown_percent NUMERIC DEFAULT 10,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
  UNIQUE(user_id, account_number)
);

-- Create indexes for better query performance
CREATE INDEX IF NOT EXISTS idx_mt5_account_data_account_number ON public.mt5_account_data(account_number);
CREATE INDEX IF NOT EXISTS idx_mt5_account_history_account_number ON public.mt5_account_history(account_number);
CREATE INDEX IF NOT EXISTS idx_mt5_account_history_timestamp ON public.mt5_account_history(timestamp DESC);
CREATE INDEX IF NOT EXISTS idx_user_mt5_accounts_user_id ON public.user_mt5_accounts(user_id);

-- Enable Row Level Security
ALTER TABLE public.mt5_account_data ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.mt5_account_history ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_mt5_accounts ENABLE ROW LEVEL SECURITY;

-- Create policies for mt5_account_data
CREATE POLICY "Users can view their own MT5 account data" 
  ON public.mt5_account_data 
  FOR SELECT 
  USING (
    account_number IN (
      SELECT account_number FROM public.user_mt5_accounts WHERE user_id = auth.uid()
    )
  );

-- Create policies for mt5_account_history
CREATE POLICY "Users can view their own MT5 account history" 
  ON public.mt5_account_history 
  FOR SELECT 
  USING (
    account_number IN (
      SELECT account_number FROM public.user_mt5_accounts WHERE user_id = auth.uid()
    )
  );

-- Create policies for user_mt5_accounts
CREATE POLICY "Users can view their own MT5 accounts" 
  ON public.user_mt5_accounts 
  FOR SELECT 
  USING (user_id = auth.uid());

CREATE POLICY "Users can insert their own MT5 accounts" 
  ON public.user_mt5_accounts 
  FOR INSERT 
  WITH CHECK (user_id = auth.uid());

CREATE POLICY "Users can update their own MT5 accounts" 
  ON public.user_mt5_accounts 
  FOR UPDATE 
  USING (user_id = auth.uid());

-- Grant permissions
GRANT SELECT ON public.mt5_account_data TO authenticated;
GRANT SELECT ON public.mt5_account_history TO authenticated;
GRANT ALL ON public.user_mt5_accounts TO authenticated;

-- Service role needs full access for the Python script
GRANT ALL ON public.mt5_account_data TO service_role;
GRANT ALL ON public.mt5_account_history TO service_role;
GRANT ALL ON public.user_mt5_accounts TO service_role;
```

### 2. VPS Setup

You need a VPS (Virtual Private Server) to run the Python script that connects to MT5 and fetches account data:

1. **Choose a VPS Provider**:
   - Google Cloud (Free for 3 months)
   - Amazon AWS (Free for 12 months)
   - Microsoft Azure (Free for 1 month)
   - Oracle Cloud (Forever Free Tier)

2. **Set Up the VPS**:
   - Choose Ubuntu as the operating system
   - Ensure it has at least 1GB RAM and 10GB storage

3. **Install Required Software**:
   ```bash
   sudo apt update
   sudo apt install -y python3 python3-pip
   pip3 install MetaTrader5 requests
   ```

4. **Install MetaTrader 5**:
   - For Linux VPS, you'll need to use Wine to run MT5
   ```bash
   sudo apt install -y wine
   # Download MT5 setup and install using Wine
   ```

### 3. Python Script Setup

1. **Copy the Python Script**:
   - Copy the `mt5_account_tracker.py` script to your VPS
   - Create an `accounts.json` file with the MT5 account details

2. **Configure Environment Variables**:
   ```bash
   export API_ENDPOINT="https://your-api-endpoint.com/api/mt5-data"
   export API_KEY="your-api-key"
   ```

3. **Run the Script**:
   ```bash
   python3 mt5_account_tracker.py
   ```

4. **Set Up Cron Job** (optional):
   - To ensure the script runs automatically, set up a cron job:
   ```bash
   crontab -e
   ```
   - Add the following line to run the script every 5 minutes:
   ```
   */5 * * * * cd /path/to/script && python3 mt5_account_tracker.py
   ```

### 4. Backend API Setup

1. **Deploy the API Server**:
   - The API server is included in the application
   - Ensure the server is running and accessible from the internet

2. **Configure Environment Variables**:
   ```
   SUPABASE_URL=your-supabase-url
   SUPABASE_SERVICE_KEY=your-supabase-service-key
   MT5_API_KEY=your-api-key
   ```

### 5. Frontend Setup

The frontend components are already integrated into the application. You just need to ensure the following:

1. **Update API Endpoint**:
   - Make sure the frontend is configured to use the correct API endpoint

2. **Install Required Dependencies**:
   ```bash
   npm install recharts
   ```

## Using the MT5 Account Tracking Feature

### For Users

1. **Add MT5 Account**:
   - Go to the MT5 Accounts page
   - Click "Add Account"
   - Enter your MT5 account details (account number, name, server, type)

2. **View Account Data**:
   - The dashboard will show a summary of your MT5 accounts
   - Click "View Details" to see comprehensive account information
   - View performance charts, open positions, and recent trades

3. **Monitor Performance**:
   - Track balance, equity, profit, and drawdown
   - Monitor profit target progress
   - Analyze historical performance with charts

### For Administrators

1. **Access Admin Accounts Page**:
   - Log in with an admin account
   - Navigate to "Admin Accounts" in the sidebar
   - This page allows you to manage all user MT5 accounts

2. **Add MT5 Account for Any User**:
   - Click "Add Account" button
   - Enter the user's email address
   - Fill in the MT5 account details (account number, name, server, type)
   - Click "Add Account" to save

3. **View and Manage All Accounts**:
   - See a list of all MT5 accounts across all users
   - Delete accounts that are no longer needed
   - Monitor which users have connected accounts

4. **Manually Add Accounts via Supabase**:
   - You can also add accounts directly in the Supabase Table Editor:
     1. Go to Supabase Dashboard → Database → Table Editor
     2. Select the `user_mt5_accounts` table
     3. Click "Insert Row"
     4. Fill in the user's MT5 Account Details
     5. Click "Save"

## Troubleshooting

### Common Issues

1. **MT5 Connection Issues**:
   - Verify MT5 credentials are correct
   - Check if the MT5 server is accessible
   - Ensure the VPS has internet connectivity

2. **Data Not Updating**:
   - Check if the Python script is running
   - Verify API endpoint is accessible
   - Check for errors in the script logs

3. **Account Not Showing in Dashboard**:
   - Verify the account is added correctly
   - Check if the user has permission to view the account
   - Ensure the account data is being fetched correctly

4. **Admin Cannot Add Account**:
   - Verify the user email exists in the system
   - Check for any validation errors in the form
   - Ensure the account number is unique

## Security Considerations

1. **API Key Protection**:
   - Keep the API key secure
   - Use environment variables instead of hardcoding

2. **MT5 Credentials**:
   - Store MT5 credentials securely
   - Use demo accounts for testing

3. **Data Privacy**:
   - Ensure Row Level Security is enabled in Supabase
   - Users should only see their own account data

## Conclusion

The MT5 account tracking feature provides real-time trading data for users, allowing them to monitor their trading performance from the My Forex Funding dashboard. By following this setup guide, you can enable this feature for your users and provide them with valuable insights into their trading activities.

Administrators have additional capabilities to manage user accounts, making it easy to help users set up their MT5 tracking or add accounts on their behalf. 