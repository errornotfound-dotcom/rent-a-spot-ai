CREATE OR REPLACE FUNCTION public.recompute_parking_slots(_parking_id UUID)
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_total INTEGER;
  v_used INTEGER;
BEGIN
  SELECT total_slots INTO v_total FROM public.parking_spaces WHERE id = _parking_id;
  IF v_total IS NULL THEN RETURN; END IF;
  SELECT count(*) INTO v_used
  FROM public.bookings
  WHERE parking_id = _parking_id
    AND booking_status IN ('pending','confirmed','active')
    AND tstzrange(start_time, end_time) && tstzrange(now(), now() + interval '100 years');
  UPDATE public.parking_spaces
  SET available_slots = GREATEST(v_total - v_used, 0)
  WHERE id = _parking_id;
END;
$$;

CREATE OR REPLACE FUNCTION public.create_booking(
  _parking_id UUID,
  _vehicle_number TEXT,
  _start_time TIMESTAMPTZ,
  _end_time TIMESTAMPTZ
)
RETURNS public.bookings
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_uid UUID := auth.uid();
  v_total INTEGER;
  v_price NUMERIC;
  v_status public.parking_status;
  v_overlap INTEGER;
  v_hours NUMERIC;
  v_amount NUMERIC;
  v_qr TEXT;
  v_booking public.bookings;
BEGIN
  IF v_uid IS NULL THEN
    RAISE EXCEPTION 'Not authenticated';
  END IF;
  IF _end_time <= _start_time THEN
    RAISE EXCEPTION 'End time must be after start time';
  END IF;

  SELECT total_slots, hourly_price, status
    INTO v_total, v_price, v_status
  FROM public.parking_spaces
  WHERE id = _parking_id
  FOR UPDATE;

  IF v_total IS NULL THEN
    RAISE EXCEPTION 'Parking space not found';
  END IF;
  IF v_status <> 'approved' THEN
    RAISE EXCEPTION 'Parking space is not available for booking';
  END IF;

  SELECT count(*) INTO v_overlap
  FROM public.bookings
  WHERE parking_id = _parking_id
    AND booking_status IN ('pending','confirmed','active')
    AND tstzrange(start_time, end_time) && tstzrange(_start_time, _end_time);

  IF v_overlap >= v_total THEN
    RAISE EXCEPTION 'No slots available for the selected time window';
  END IF;

  v_hours := GREATEST(CEIL(EXTRACT(EPOCH FROM (_end_time - _start_time)) / 3600.0), 1);
  v_amount := ROUND(v_hours * v_price, 2);
  v_qr := 'PE-' || replace(gen_random_uuid()::text, '-', '');

  INSERT INTO public.bookings (user_id, parking_id, vehicle_number, booking_date, start_time, end_time, total_amount, booking_status, qr_code)
  VALUES (v_uid, _parking_id, _vehicle_number, _start_time::date, _start_time, _end_time, v_amount, 'pending', v_qr)
  RETURNING * INTO v_booking;

  UPDATE public.parking_spaces
  SET available_slots = GREATEST(v_total - (v_overlap + 1), 0)
  WHERE id = _parking_id;

  RETURN v_booking;
END;
$$;

REVOKE EXECUTE ON FUNCTION public.recompute_parking_slots(UUID) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.create_booking(UUID, TEXT, TIMESTAMPTZ, TIMESTAMPTZ) TO authenticated;