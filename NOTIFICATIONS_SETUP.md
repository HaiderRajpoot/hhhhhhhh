# Notifications System Setup

This document provides instructions on how to set up the notifications system for the My Forex Funding application.

## Overview

The notifications system allows administrators to receive notifications when users attempt to purchase challenges. These notifications are stored in a Supabase database table and displayed in a dedicated notifications page.

## Database Setup

1. Create the notifications table in your Supabase project by running the SQL script in `supabase/migrations/20240101000000_create_notifications_table.sql`.

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

The notifications system includes the following features:

1. **Automatic Notifications**: When a user attempts to purchase a challenge, a notification is automatically created in the database.

2. **Notifications Page**: Administrators can view all notifications in the `/notifications` page.

3. **Notification Badge**: A badge showing the number of unread notifications appears in the navigation menu.

4. **Mark as Read**: Administrators can mark notifications as read to keep track of which ones they've already seen.

## Code Structure

The notifications system consists of the following components:

1. **Notification Service** (`src/lib/notification-service.ts`): Contains functions for creating, retrieving, and updating notifications.

2. **Notifications Page** (`src/pages/NotificationsPage.tsx`): Displays all notifications with options to mark them as read.

3. **Dashboard Layout** (`src/components/layout/DashboardLayout.tsx`): Includes the navigation link with an unread count badge.

4. **Payment Page** (`src/pages/PaymentPage.tsx`): Creates notifications when users attempt to purchase challenges.

## Testing

To test the notifications system:

1. Start the development server:
   ```bash
   npm run dev
   ```

2. Navigate to a challenge page and attempt to purchase it.

3. Check the notifications page to see if the notification was created.

4. Verify that the unread count badge appears in the navigation menu.

## Troubleshooting

If notifications are not appearing:

1. Check the browser console for any errors.

2. Verify that the notifications table was created correctly in Supabase.

3. Ensure that the user has the necessary permissions to insert and select from the notifications table.

4. Check that the Supabase client is properly initialized and authenticated. 