-- =====================================================================
-- 1. PROFILES: remove public read of PII (email/phone/name)
-- =====================================================================
DROP POLICY IF EXISTS "Profiles are viewable by everyone" ON public.profiles;

CREATE POLICY "Users view own profile"
ON public.profiles FOR SELECT TO authenticated
USING (auth.uid() = id);

CREATE POLICY "Admins view all profiles"
ON public.profiles FOR SELECT TO authenticated
USING (public.has_role(auth.uid(), 'admin'::app_role));

-- =====================================================================
-- 2. USER_ROLES: explicit admin-only write policies (prevent escalation)
-- =====================================================================
CREATE POLICY "Admins insert roles"
ON public.user_roles FOR INSERT TO authenticated
WITH CHECK (public.has_role(auth.uid(), 'admin'::app_role));

CREATE POLICY "Admins update roles"
ON public.user_roles FOR UPDATE TO authenticated
USING (public.has_role(auth.uid(), 'admin'::app_role))
WITH CHECK (public.has_role(auth.uid(), 'admin'::app_role));

CREATE POLICY "Admins delete roles"
ON public.user_roles FOR DELETE TO authenticated
USING (public.has_role(auth.uid(), 'admin'::app_role));

-- =====================================================================
-- 3. PAYMENT QR CODE: move to a separate, access-controlled table
-- =====================================================================
CREATE TABLE public.parking_payment_details (
  id uuid NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  parking_id uuid NOT NULL UNIQUE,
  owner_id uuid NOT NULL,
  payment_qr_code text,
  created_at timestamptz NOT NULL DEFAULT now()
);

GRANT SELECT, INSERT, UPDATE, DELETE ON public.parking_payment_details TO authenticated;
GRANT ALL ON public.parking_payment_details TO service_role;

ALTER TABLE public.parking_payment_details ENABLE ROW LEVEL SECURITY;

-- migrate existing QR data
INSERT INTO public.parking_payment_details (parking_id, owner_id, payment_qr_code)
SELECT id, owner_id, payment_qr_code
FROM public.parking_spaces
WHERE payment_qr_code IS NOT NULL;

CREATE POLICY "Owners manage own parking payment details"
ON public.parking_payment_details FOR ALL TO authenticated
USING (auth.uid() = owner_id)
WITH CHECK (auth.uid() = owner_id);

CREATE POLICY "Admins view all parking payment details"
ON public.parking_payment_details FOR SELECT TO authenticated
USING (public.has_role(auth.uid(), 'admin'::app_role));

CREATE POLICY "Bookers view parking payment details"
ON public.parking_payment_details FOR SELECT TO authenticated
USING (EXISTS (
  SELECT 1 FROM public.bookings b
  WHERE b.parking_id = parking_payment_details.parking_id
    AND b.user_id = auth.uid()
));

ALTER TABLE public.parking_spaces DROP COLUMN payment_qr_code;

-- =====================================================================
-- 4. STORAGE: allow users to delete own avatars
-- =====================================================================
CREATE POLICY "Users delete own avatar"
ON storage.objects FOR DELETE TO authenticated
USING (
  bucket_id = 'avatars'
  AND (auth.uid())::text = (storage.foldername(name))[1]
);

-- =====================================================================
-- 5. STORAGE: stop broad listing of public buckets
--    (public file URLs still work because the buckets are public)
-- =====================================================================
DROP POLICY IF EXISTS "Avatar images are publicly accessible" ON storage.objects;
DROP POLICY IF EXISTS "Parking images are publicly accessible" ON storage.objects;

CREATE POLICY "Users view own avatar objects"
ON storage.objects FOR SELECT TO authenticated
USING (
  bucket_id = 'avatars'
  AND (auth.uid())::text = (storage.foldername(name))[1]
);

CREATE POLICY "Owners view own parking image objects"
ON storage.objects FOR SELECT TO authenticated
USING (
  bucket_id = 'parking-images'
  AND (auth.uid())::text = (storage.foldername(name))[1]
);

-- =====================================================================
-- 6. Tighten EXECUTE on internal SECURITY DEFINER helpers
--    (has_role must stay executable by anon/authenticated for RLS)
-- =====================================================================
REVOKE EXECUTE ON FUNCTION public.recompute_parking_slots(uuid) FROM PUBLIC, anon, authenticated;
REVOKE EXECUTE ON FUNCTION public.create_booking(uuid, text, timestamptz, timestamptz) FROM PUBLIC, anon;