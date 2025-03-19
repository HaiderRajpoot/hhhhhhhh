# Administrator Guide: Managing User MT5 Accounts

This guide provides detailed instructions for administrators on how to manage user MT5 accounts in the My Forex Funding application. As an administrator, you have the ability to add, view, and delete MT5 accounts for any user in the system.

## Accessing the Admin Accounts Page

1. **Log in with an admin account**
   - Navigate to the login page at `/auth`
   - Enter your admin credentials

2. **Navigate to the Admin Accounts page**
   - Once logged in, you'll see the "Admin Accounts" option in the sidebar
   - Click on this option to access the admin accounts management page
   - The URL for this page is `/admin/accounts`

## Managing MT5 Accounts

### Viewing All User Accounts

The Admin Accounts page displays a table with all MT5 accounts across all users in the system. For each account, you can see:

- User Email
- Account Number
- Account Name
- Server
- Account Type
- Creation Date
- Actions (Delete)

### Adding an MT5 Account for a User

1. **Click the "Add Account" button** at the top right of the page

2. **Fill in the account details form**:
   - **User Email**: Enter the email address of the user who will own this account
   - **Account Number**: Enter the MT5 account number (must be unique)
   - **Account Name**: Enter a descriptive name for the account
   - **Server**: Enter the MT5 server name (default: Exness-MT5Trial)
   - **Account Type**: Enter the account type (default: Demo)

3. **Click "Add Account"** to save the new account
   - The system will verify that the user exists
   - If successful, the account will be added and appear in the table
   - If there's an error, you'll see a notification with details

### Deleting an MT5 Account

1. **Locate the account** you want to delete in the table

2. **Click the delete icon** (trash can) in the Actions column

3. **Confirm deletion** when prompted
   - This action cannot be undone
   - Once deleted, the account will be removed from the table

## Adding Accounts via Supabase Table Editor

As an administrator, you can also add accounts directly in the Supabase Table Editor:

1. **Access Supabase Dashboard**
   - Log in to your Supabase account
   - Select your project

2. **Navigate to Table Editor**
   - Go to Database → Table Editor
   - Select the `user_mt5_accounts` table

3. **Add a new account**
   - Click "Insert Row"
   - Fill in the following fields:
     - `user_id`: The UUID of the user (you can find this in the `users` table)
     - `account_number`: The MT5 account number
     - `account_name`: A descriptive name for the account
     - `server`: The MT5 server name
     - `account_type`: The type of account (Demo, Real, etc.)
     - `target_profit_percent`: The profit target percentage (default: 10)
     - `max_daily_drawdown_percent`: The maximum daily drawdown percentage (default: 5)
     - `max_overall_drawdown_percent`: The maximum overall drawdown percentage (default: 10)
   - Click "Save"

## Troubleshooting

### Common Issues

1. **User Not Found**
   - Ensure the email address is correct and the user exists in the system
   - Check the `users` table in Supabase to verify the user's email

2. **Duplicate Account Number**
   - Each MT5 account number must be unique in the system
   - If you receive a duplicate error, check if the account already exists

3. **Permission Issues**
   - Ensure your admin account has the correct permissions
   - Check the Row Level Security policies in Supabase

## Best Practices

1. **Verify User Information**
   - Always double-check the user's email before adding an account
   - Ensure the MT5 account details are accurate

2. **Document Account Changes**
   - Keep a record of accounts you add or delete
   - Communicate with users when making changes to their accounts

3. **Regular Audits**
   - Periodically review the accounts in the system
   - Remove unused or inactive accounts

## Security Considerations

1. **Admin Access Control**
   - Limit the number of admin accounts
   - Use strong passwords for admin accounts
   - Consider implementing two-factor authentication

2. **Data Privacy**
   - Only access user account information when necessary
   - Respect user privacy and data protection regulations

3. **Audit Logging**
   - All admin actions are logged
   - These logs can be reviewed in case of security incidents

## Support and Assistance

If you encounter any issues or have questions about managing MT5 accounts:

1. Contact the technical support team
2. Refer to the developer documentation
3. Check the application logs for error details

---

By following this guide, administrators can effectively manage MT5 accounts for all users in the My Forex Funding application, ensuring a smooth experience for traders using the platform. 