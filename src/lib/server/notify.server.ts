import { supabaseAdmin } from "@/integrations/supabase/client.server";

/**
 * Server-only helper to create an in-app notification.
 * Uses the admin client because the notifications table has no public INSERT policy.
 */
export async function createNotification(
  userId: string,
  title: string,
  message: string,
): Promise<void> {
  const { error } = await supabaseAdmin
    .from("notifications")
    .insert({ user_id: userId, title, message });
  if (error) {
    // Never let a notification failure break the main flow.
    console.error("[notify] failed to create notification:", error.message);
  }
}

/** Check whether a user holds a given role (server-side, bypasses RLS). */
export async function userHasRole(
  userId: string,
  role: "user" | "owner" | "admin",
): Promise<boolean> {
  const { data, error } = await supabaseAdmin
    .from("user_roles")
    .select("id")
    .eq("user_id", userId)
    .eq("role", role)
    .maybeSingle();
  if (error) {
    console.error("[notify] role check failed:", error.message);
    return false;
  }
  return !!data;
}
