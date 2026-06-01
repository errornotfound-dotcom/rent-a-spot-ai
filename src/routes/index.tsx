import { createFileRoute, Link } from "@tanstack/react-router";
import { Car, ShieldCheck, QrCode, MapPin, LayoutDashboard, CreditCard } from "lucide-react";

export const Route = createFileRoute("/")({
  head: () => ({
    meta: [
      { title: "PARK EASY — Smart Parking Booking & Rental Platform" },
      {
        name: "description",
        content:
          "PARK EASY lets drivers book parking, owners rent out spaces, and admins manage it all — with QR passes and scan-to-pay.",
      },
      { property: "og:title", content: "PARK EASY — Smart Parking Booking" },
      {
        property: "og:description",
        content:
          "Book parking, rent your space, scan-to-pay and manage everything from one dashboard.",
      },
    ],
  }),
  component: Index,
});

const features = [
  { icon: MapPin, title: "Find & Book", desc: "Search nearby parking, filter by price, distance and availability." },
  { icon: Car, title: "List Your Space", desc: "Owners list spaces, set pricing and manage slots in real time." },
  { icon: QrCode, title: "QR Passes", desc: "Every booking gets a QR pass validated on entry and exit." },
  { icon: CreditCard, title: "Scan-to-Pay", desc: "Owners upload their own payment QR; drivers pay and add a reference." },
  { icon: ShieldCheck, title: "Secure Roles", desc: "Driver, Owner and Admin roles with row-level security." },
  { icon: LayoutDashboard, title: "Dashboards", desc: "Owner revenue & occupancy stats plus admin analytics." },
];

function Index() {
  return (
    <div className="min-h-screen bg-background text-foreground">
      <header className="border-b">
        <div className="mx-auto flex max-w-6xl items-center justify-between px-6 py-4">
          <div className="flex items-center gap-2 font-bold text-lg">
            <Car className="h-6 w-6 text-primary" /> PARK EASY
          </div>
          <nav className="text-sm text-muted-foreground">Engineering Mini Project</nav>
        </div>
      </header>

      <main className="mx-auto max-w-6xl px-6">
        <section className="py-20 text-center">
          <h1 className="text-4xl font-bold tracking-tight sm:text-5xl">
            Smart Parking Booking & Space Rental
          </h1>
          <p className="mx-auto mt-4 max-w-2xl text-muted-foreground">
            A full backend powering drivers, parking owners and administrators —
            bookings, QR passes, scan-to-pay, notifications and analytics.
          </p>
          <div className="mt-8 inline-flex rounded-lg border bg-muted px-4 py-2 text-sm text-muted-foreground">
            Backend is set up. The connected app screens are being built next.
          </div>
        </section>

        <section className="grid gap-5 pb-24 sm:grid-cols-2 lg:grid-cols-3">
          {features.map((f) => (
            <div key={f.title} className="rounded-xl border bg-card p-6 shadow-sm">
              <f.icon className="h-7 w-7 text-primary" />
              <h3 className="mt-3 font-semibold">{f.title}</h3>
              <p className="mt-1 text-sm text-muted-foreground">{f.desc}</p>
            </div>
          ))}
        </section>
      </main>

      <footer className="border-t py-6 text-center text-sm text-muted-foreground">
        PARK EASY · Built on Lovable Cloud
      </footer>
    </div>
  );
}
