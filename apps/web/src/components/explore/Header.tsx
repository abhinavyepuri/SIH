"use client";

import Link from "next/link";
import { usePathname } from "next/navigation";
import { useAuth } from "@/stores/AuthContext";
import { useCart } from "@/stores/CartContext";
import { useWishlist } from "@/stores/WishlistContext";

const navLinks = [
  { href: "/explore", label: "Gallery" },
  { href: "/artisans", label: "Artisans" },
  { href: "/collections", label: "Collections" },
];

const categoryPills = [
  { name: "All Works", href: "/explore" },
  { name: "Ceramics & Pottery", href: "/explore?category=Ceramics" },
  { name: "Handloom Textiles", href: "/explore?category=Textiles" },
  { name: "Woodworking", href: "/explore?category=Woodworking" },
  { name: "Metal & Brass", href: "/explore?category=Metalwork" },
  { name: "Regional Crafts", href: "/explore?category=Handicrafts" },
];

export default function CustomerHeader() {
  const pathname = usePathname();
  const { user, logout } = useAuth();
  const { items } = useCart();
  const { wishlistCount } = useWishlist();

  const totalCartCount = items.reduce((sum, item) => sum + item.cartQuantity, 0);

  return (
    <header className="sticky top-0 z-50 bg-white/95 backdrop-blur-md border-b border-border-light shadow-sm">
      {/* Main Navigation Bar */}
      <div className="max-w-7xl mx-auto px-4 sm:px-6 py-3.5 flex items-center justify-between gap-4">
        {/* Brand Logo */}
        <div className="flex items-center gap-8">
          <Link href="/" className="flex flex-col group">
            <span className="font-serif text-2xl tracking-[0.15em] font-bold text-navy group-hover:text-gold transition-colors">
              AROHA
            </span>
            <span className="text-[9px] tracking-wider text-warm-gray lowercase font-medium -mt-1">
              where artists meet the market
            </span>
          </Link>

          {/* Primary Nav Links */}
          <nav className="hidden lg:flex items-center gap-7">
            {navLinks.map((link) => {
              const isActive = pathname === link.href || (link.href === "/explore" && pathname?.startsWith("/explore"));
              return (
                <Link
                  key={link.href}
                  href={link.href}
                  className={`text-xs uppercase tracking-widest transition-all pb-1 ${
                    isActive
                      ? "text-navy font-bold border-b-2 border-gold"
                      : "text-warm-gray hover:text-navy font-medium"
                  }`}
                >
                  {link.label}
                </Link>
              );
            })}
          </nav>
        </div>

        {/* Search Bar Shortcut */}
        <div className="hidden md:flex flex-1 max-w-md mx-6">
          <Link
            href="/explore"
            className="w-full flex items-center gap-2.5 px-3.5 py-2 bg-cream/70 hover:bg-cream border border-border rounded-full text-xs text-warm-gray transition-colors shadow-inner"
          >
            <svg className="w-4 h-4 text-warm-gray" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z" />
            </svg>
            <span className="truncate">Search pottery, handloom silk, woodwork, brass...</span>
          </Link>
        </div>

        {/* User Actions (Wishlist, Cart, Profile) */}
        <div className="flex items-center gap-3 sm:gap-4">
          {/* Wishlist Link with Live Counter */}
          <Link
            href="/wishlist"
            className="p-2 text-warm-gray hover:text-navy hover:bg-cream rounded-full transition-colors relative"
            title="Saved Items"
          >
            <svg className="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={1.5} d="M4.318 6.318a4.5 4.5 0 000 6.364L12 20.364l7.682-7.682a4.5 4.5 0 00-6.364-6.364L12 7.636l-1.318-1.318a4.5 4.5 0 00-6.364 0z" />
            </svg>
            {wishlistCount > 0 && (
              <span className="absolute 0 top-1 right-1 w-4 h-4 bg-rose-600 text-white text-[10px] font-bold rounded-full flex items-center justify-center shadow-sm">
                {wishlistCount}
              </span>
            )}
          </Link>

          {/* Cart Link with Live Counter */}
          <Link
            href="/cart"
            className="p-2 text-warm-gray hover:text-navy hover:bg-cream rounded-full transition-colors relative"
            title="Your Bag"
          >
            <svg className="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={1.5} d="M16 11V7a4 4 0 00-8 0v4M5 9h14l1 12H4L5 9z" />
            </svg>
            {totalCartCount > 0 && (
              <span className="absolute top-1 right-1 w-4 h-4 bg-navy text-gold text-[10px] font-bold rounded-full flex items-center justify-center shadow-sm border border-gold">
                {totalCartCount}
              </span>
            )}
          </Link>

          {/* User Account / Artisan Switcher */}
          {user?.role === "artisan" ? (
            <Link
              href="/artisan/dashboard"
              className="px-3 py-1.5 bg-navy text-gold text-xs font-semibold rounded-lg hover:bg-navy-light transition-colors border border-gold/40 shadow-sm"
            >
              Artisan Studio
            </Link>
          ) : user ? (
            <div className="flex items-center gap-2">
              <Link
                href="/orders"
                className="text-xs font-semibold text-navy hover:text-gold px-2.5 py-1.5 rounded-md hover:bg-cream transition-colors"
              >
                Orders
              </Link>
              <button
                onClick={() => logout()}
                className="text-xs text-warm-gray hover:text-rose-600 transition-colors px-2 py-1"
                title="Log Out"
              >
                Log Out
              </button>
            </div>
          ) : (
            <Link
              href="/login?role=customer"
              className="px-3.5 py-1.5 bg-navy text-white text-xs font-medium rounded-lg hover:bg-navy-light transition-colors shadow-sm"
            >
              Sign In
            </Link>
          )}
        </div>
      </div>

      {/* Category Pills Strip */}
      <div className="border-t border-border-light bg-cream/40 px-4 sm:px-6 py-2 overflow-x-auto no-scrollbar">
        <div className="max-w-7xl mx-auto flex items-center gap-2 min-w-max text-xs">
          <span className="text-[11px] font-bold uppercase tracking-wider text-warm-gray-light mr-1">
            Browse:
          </span>
          {categoryPills.map((pill) => (
            <Link
              key={pill.name}
              href={pill.href}
              className="px-3 py-1 rounded-full bg-white border border-border/80 text-warm-gray hover:text-navy hover:border-gold hover:bg-white text-xs font-medium transition-colors shadow-2xs"
            >
              {pill.name}
            </Link>
          ))}
        </div>
      </div>
    </header>
  );
}
