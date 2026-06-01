ALTER TABLE public.parking_spaces ADD COLUMN IF NOT EXISTS payment_qr_code TEXT;
ALTER TABLE public.payments ADD COLUMN IF NOT EXISTS payment_reference TEXT;
ALTER TABLE public.payments DROP COLUMN IF EXISTS razorpay_order_id;