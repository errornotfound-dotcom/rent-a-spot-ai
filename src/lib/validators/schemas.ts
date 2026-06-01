import { z } from "zod";

// ===== Auth / Profile =====
export const roleSchema = z.enum(["user", "owner", "admin"]);

export const updateProfileSchema = z.object({
  full_name: z.string().trim().min(1).max(120).optional(),
  phone: z.string().trim().max(20).optional(),
  profile_image: z.string().trim().max(500).url().optional().or(z.literal("")),
});

export const setRoleSchema = z.object({
  role: z.enum(["user", "owner"]),
});

// ===== Vehicles =====
export const vehicleSchema = z.object({
  vehicle_number: z
    .string()
    .trim()
    .min(2)
    .max(20)
    .regex(/^[A-Za-z0-9 -]+$/, "Invalid vehicle number"),
  vehicle_type: z.enum(["car", "bike", "suv", "truck", "ev"]).default("car"),
});

// ===== Parking =====
export const createParkingSchema = z.object({
  parking_name: z.string().trim().min(2).max(120),
  description: z.string().trim().max(1000).optional().or(z.literal("")),
  address: z.string().trim().min(3).max(300),
  latitude: z.number().min(-90).max(90).optional().nullable(),
  longitude: z.number().min(-180).max(180).optional().nullable(),
  hourly_price: z.number().min(0).max(100000),
  total_slots: z.number().int().min(1).max(10000),
  amenities: z.array(z.string().trim().max(40)).max(20).default([]),
  images: z.array(z.string().trim().max(500)).max(10).default([]),
  payment_qr_code: z.string().trim().max(500).optional().or(z.literal("")),
});

export const updateParkingSchema = createParkingSchema.partial().extend({
  id: z.string().uuid(),
});

export const searchParkingSchema = z.object({
  query: z.string().trim().max(120).optional(),
  maxPrice: z.number().min(0).max(100000).optional(),
  minAvailable: z.number().int().min(0).optional(),
  // user location for distance sorting / filtering
  lat: z.number().min(-90).max(90).optional(),
  lng: z.number().min(-180).max(180).optional(),
  maxDistanceKm: z.number().min(0).max(50000).optional(),
  sortBy: z.enum(["price", "distance", "availability"]).default("price"),
});

// ===== Bookings =====
export const createBookingSchema = z.object({
  parking_id: z.string().uuid(),
  vehicle_number: z
    .string()
    .trim()
    .min(2)
    .max(20)
    .regex(/^[A-Za-z0-9 -]+$/, "Invalid vehicle number"),
  start_time: z.string().datetime(),
  end_time: z.string().datetime(),
});

export const bookingIdSchema = z.object({ id: z.string().uuid() });

export const extendBookingSchema = z.object({
  id: z.string().uuid(),
  end_time: z.string().datetime(),
});

export const availabilitySchema = z.object({
  parking_id: z.string().uuid(),
  start_time: z.string().datetime(),
  end_time: z.string().datetime(),
});

export const validateQrSchema = z.object({
  qr_code: z.string().trim().min(4).max(80),
  action: z.enum(["entry", "exit"]),
});

// ===== Payments =====
export const confirmPaymentSchema = z.object({
  booking_id: z.string().uuid(),
  payment_reference: z.string().trim().min(2).max(120),
  payment_method: z.enum(["upi", "card", "cash", "netbanking"]).default("upi"),
});

// ===== Favorites / Notifications =====
export const parkingIdSchema = z.object({ parking_id: z.string().uuid() });
export const notificationIdSchema = z.object({ id: z.string().uuid() });

// ===== Admin =====
export const adminSetRoleSchema = z.object({
  user_id: z.string().uuid(),
  role: roleSchema,
});

export const moderateParkingSchema = z.object({
  id: z.string().uuid(),
  status: z.enum(["approved", "rejected"]),
});
