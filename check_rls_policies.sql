-- Check if the buying_activities table exists
SELECT EXISTS (
  SELECT FROM information_schema.tables 
  WHERE table_schema = 'public' 
  AND table_name = 'buying_activities'
);

-- Check if RLS is enabled on the buying_activities table
SELECT relname, relrowsecurity
FROM pg_class
WHERE relname = 'buying_activities';

-- Check RLS policies on the buying_activities table
SELECT 
  schemaname, 
  tablename, 
  policyname, 
  permissive, 
  roles, 
  cmd, 
  qual, 
  with_check
FROM pg_policies
WHERE tablename = 'buying_activities';

-- Check table permissions
SELECT 
  grantee, 
  table_schema, 
  table_name, 
  privilege_type
FROM information_schema.role_table_grants
WHERE table_name = 'buying_activities'
ORDER BY grantee, privilege_type; 