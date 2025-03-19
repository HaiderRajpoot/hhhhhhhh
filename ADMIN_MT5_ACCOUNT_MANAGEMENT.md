# Admin-Only MT5 Account Management

This documentation provides a comprehensive guide for administrators on how to manage MT5 accounts within the My Forex Funding application. The system allows administrators to add, view, and delete MT5 accounts for users, while users can view their assigned accounts and track performance metrics.

## Table of Contents

1. [Overview](#overview)
2. [Admin Interface](#admin-interface)
3. [User Dashboard](#user-dashboard)
4. [Database Structure](#database-structure)
5. [Account Management](#account-management)
6. [Best Practices](#best-practices)
7. [Troubleshooting](#troubleshooting)
8. [Security Considerations](#security-considerations)
9. [Conclusion](#conclusion)

## Overview

The MT5 account management system is designed to allow administrators to manage MetaTrader 5 (MT5) accounts for users. This admin-only feature ensures that:

- Only administrators can add, modify, or delete MT5 accounts
- Users can view only their own MT5 accounts
- Account performance metrics are tracked and displayed on user dashboards
- Drawdown limits and profit targets are monitored automatically

This approach provides a secure and controlled environment for managing trading accounts while giving users visibility into their account performance.

## Admin Interface

### Accessing the Admin Accounts Page

1. Log in to the application with an admin account
2. Navigate to the dashboard
3. Click on the "Admin Accounts" link in the sidebar navigation
4. The admin accounts page will display all MT5 accounts in the system

### Admin Accounts Page Features

The admin accounts page provides the following functionality:

- **View All Accounts**: See a table of all MT5 accounts in the system
- **Add New Account**: Add a new MT5 account for any user
- **Delete Account**: Remove an MT5 account from the system
- **Filter Accounts**: Search for accounts by user email or account number

## User Dashboard

When an administrator adds an MT5 account for a user, the account will automatically appear on the user's dashboard. The user dashboard displays:

- A list of all MT5 accounts assigned to the user
- Current balance and equity for each account
- Profit/loss information with visual indicators
- Progress towards profit targets
- Drawdown monitoring with visual indicators
- Account details such as server and account type

Users cannot add, modify, or delete their MT5 accounts. They can only view the accounts that administrators have assigned to them.

## Database Structure

The MT5 account management system uses two main tables in the Supabase database:

### user_mt5_accounts Table

This table stores the MT5 account configuration:

- `id`: Unique identifier for the account record
- `user_email`: Email of the user who owns the account
- `account_number`: MT5 account number (unique)
- `account_name`: Display name for the account
- `server`: MT5 server address (default: 'Exness-MT5Trial')
- `account_type`: Type of account (default: 'Demo')
- `target_profit_percent`: Profit target percentage (default: 10%)
- `max_daily_drawdown_percent`: Maximum allowed daily drawdown (default: 5%)
- `max_overall_drawdown_percent`: Maximum allowed overall drawdown (default: 10%)
- `initial_balance`: Starting balance of the account (default: 10000)
- `created_at`: Timestamp when the account was created
- `updated_at`: Timestamp when the account was last updated

### mt5_account_data Table

This table stores the real-time data for each MT5 account:

- `id`: Unique identifier for the data record
- `account_number`: MT5 account number (links to user_mt5_accounts)
- `balance`: Current account balance
- `equity`: Current account equity
- `profit`: Current profit/loss
- `margin_level`: Current margin level
- `daily_drawdown`: Current daily drawdown
- `daily_drawdown_left`: Remaining daily drawdown allowed
- `overall_drawdown`: Current overall drawdown
- `overall_drawdown_left`: Remaining overall drawdown allowed
- `profit_target_progress`: Progress towards profit target (percentage)
- `open_positions`: JSON array of current open positions
- `recent_trades`: JSON array of recent trades
- `timestamp`: Time when the data was recorded
- `updated_at`: Time when the data was last updated

## Account Management

### Adding an MT5 Account

To add a new MT5 account for a user:

1. Navigate to the Admin Accounts page
2. Click the "Add Account" button
3. Fill in the required fields:
   - User Email: Email of the user who will own the account
   - Account Number: MT5 account number (must be unique)
   - Account Name: Display name for the account
   - Server: MT5 server address (default is provided)
   - Account Type: Type of account (default is provided)
   - Initial Balance: Starting balance of the account
   - Target Profit %: Profit target percentage
   - Max Daily Drawdown %: Maximum allowed daily drawdown
   - Max Overall Drawdown %: Maximum allowed overall drawdown
4. Click "Save" to create the account

### Deleting an MT5 Account

To delete an MT5 account:

1. Navigate to the Admin Accounts page
2. Find the account you want to delete in the table
3. Click the "Delete" button in the actions column
4. Confirm the deletion when prompted

**Note**: Deleting an account will remove it from the user's dashboard and delete all associated data. This action cannot be undone.

## Best Practices

### Account Setup

- **Use Descriptive Account Names**: Include information like account type and purpose in the account name (e.g., "Demo Challenge Account")
- **Set Realistic Targets**: Configure profit targets and drawdown limits based on the user's experience level and account size
- **Verify Account Numbers**: Double-check MT5 account numbers to ensure they are correct before adding them

### Account Management

- **Regular Monitoring**: Periodically review all accounts to ensure they are functioning correctly
- **Communicate with Users**: Inform users when you add or modify their accounts
- **Document Special Configurations**: Keep records of any non-standard account configurations

## Troubleshooting

### Common Issues

#### Account Not Appearing on User Dashboard

- Verify that the user email is correct and matches the user's login email
- Check that the account has been properly added in the admin interface
- Ensure the user has logged out and back in to refresh their session

#### Account Data Not Updating

- Check that the MT5 data collection script is running properly
- Verify that the account number in the database matches the actual MT5 account
- Ensure the MT5 server is accessible and responding

#### Permission Issues

- Verify that the user has the correct role in the auth.users table
- Check that Row Level Security policies are properly configured
- Ensure the user is authenticated before accessing the dashboard

## Security Considerations

### Access Control

- Only administrators can add, modify, or delete MT5 accounts
- Users can only view their own MT5 accounts
- All database operations are protected by Row Level Security policies

### Data Protection

- Sensitive account information is only visible to administrators and the account owner
- All database queries use parameterized statements to prevent SQL injection
- API endpoints validate user permissions before allowing operations

### Audit Trail

- All account creation and deletion actions are logged
- Account data changes are timestamped
- User actions on the admin interface can be tracked for security purposes

## Conclusion

The admin-only MT5 account management system provides a secure and efficient way to manage trading accounts for users. By centralizing account management with administrators, the system ensures that accounts are properly configured and monitored, while giving users visibility into their trading performance.

For any additional questions or support, please contact the system administrator or refer to the technical documentation for more detailed information about the implementation.

---

*Last Updated: July 2024* 