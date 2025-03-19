-- Insert a test record into the buying_activities table
INSERT INTO public.buying_activities (
  user_email, 
  challenge_name, 
  account_size, 
  amount, 
  currency, 
  wallet_address, 
  payment_id, 
  status, 
  metadata
) VALUES (
  'test@example.com',
  'Manual Test Challenge',
  '$25,000',
  199.00,
  'USDT',
  '0xManualTestWalletAddress',
  'manual-test-payment-id',
  'pending',
  '{"timestamp": "2023-01-01T00:00:00Z", "ipAddress": "127.0.0.1", "userAgent": "Manual Test", "source": "SQL Script"}'
);

-- Verify the record was inserted
SELECT * FROM public.buying_activities WHERE payment_id = 'manual-test-payment-id'; 