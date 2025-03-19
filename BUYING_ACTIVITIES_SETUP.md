# Buying Activities Tracking System

This document provides instructions on how to set up and use the buying activities tracking system for the My Forex Funding application.

## Overview

The buying activities tracking system allows administrators to track and manage all challenge purchase attempts made by users. Each purchase attempt is recorded in a dedicated Supabase table and displayed in a user-friendly interface.

## Database Setup

1. Create the buying_activities table in your Supabase project by running the SQL script in `supabase/migrations/20240102000000_create_buying_activities_table.sql`.

2. You can run this script in the Supabase SQL Editor or use the Supabase CLI to apply the migration.

### Using the Supabase SQL Editor:

1. Log in to your Supabase dashboard
2. Navigate to the SQL Editor
3. Copy and paste the contents of the SQL file
4. Click "Run" to execute the script

### Using the Supabase CLI:

```bash
supabase migration up
```

## Features

The buying activities tracking system includes the following features:

1. **Automatic Recording**: When a user attempts to purchase a challenge, a record is automatically created in the buying_activities table.

2. **Buying Activities Page**: Administrators can view all purchase attempts in the `/buying-activities` page.

3. **Status Management**: Administrators can update the status of each purchase attempt (pending, completed, failed).

4. **Filtering**: Purchase attempts can be filtered by status to quickly find relevant records.

5. **Detailed Information**: Each record includes detailed information about the purchase attempt, including user email, challenge details, payment amount, and wallet address.

## Code Structure

The buying activities tracking system consists of the following components:

1. **Buying Activity Service** (`src/lib/buying-activity-service.ts`): Contains functions for creating, retrieving, and updating buying activities.

2. **Buying Activities Page** (`src/pages/BuyingActivitiesPage.tsx`): Displays all buying activities with options to filter and update their status.

3. **Dashboard Layout** (`src/components/layout/DashboardLayout.tsx`): Includes the navigation link to the buying activities page.

4. **Payment Page** (`src/pages/PaymentPage.tsx`): Records buying activities when users attempt to purchase challenges.

## Testing

To test the buying activities tracking system:

1. Start the development server:
   ```bash
   npm run dev
   ```

2. Navigate to a challenge page and attempt to purchase it.

3. Log in as an administrator and check the buying activities page to see if the purchase attempt was recorded.

4. Try updating the status of a purchase attempt to see if the changes are saved correctly.

## Troubleshooting

If buying activities are not being recorded:

1. Check the browser console for any errors.

2. Verify that the buying_activities table was created correctly in Supabase.

3. Ensure that the user has the necessary permissions to insert and select from the buying_activities table.

4. Check that the Supabase client is properly initialized and authenticated.

## Accessing Buying Activities in Supabase

To directly view the buying activities data in Supabase:

1. Log in to your Supabase dashboard
2. Navigate to the Table Editor
3. Select the "buying_activities" table
4. You can view, filter, and export the data as needed

You can also run SQL queries in the SQL Editor to analyze the data:

```sql
-- Get all buying activities
SELECT * FROM buying_activities ORDER BY created_at DESC;

-- Get buying activities for a specific user
SELECT * FROM buying_activities WHERE user_email = 'user@example.com' ORDER BY created_at DESC;

-- Get buying activities with a specific status
SELECT * FROM buying_activities WHERE status = 'pending' ORDER BY created_at DESC;

-- Get count of buying activities by status
SELECT status, COUNT(*) FROM buying_activities GROUP BY status;
``` 