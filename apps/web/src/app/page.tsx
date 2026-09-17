"use client";

import { useEffect, useState } from "react";
import Link from "next/link";
import { Footer, ProductCard, TrustBadges } from "@/components/ui";
import { fetchApi } from "@/lib/api/client";
import { useAuth } from "@/stores/AuthContext";
import { useCart } from "@/stores/CartContext";
import { useWishlist } from "@/stores/WishlistContext";
import type { Product, Artisan } from "@/types";

const categoryHighlights = [
  {
    name: "Ceramics & Pottery",
    category: "Ceramics",
    desc: "Glazed stoneware & terracotta from Khurja & Jaipur",
    bgGradient: "from-stone-800 to-amber-950",
    badge: "Hand-thrown",
  },
  {
    name: "Handloom Textiles",
    category: "Textiles",
    desc: "Pure mulberry silk, Pashmina & block prints",
    bgGradient: "from-rose-900 to-amber-950",
    badge: "Heritage Weaves",
  },
  {
    name: "Master Woodcraft",
    category: "Woodworking",
    desc: "Teakwood carving & intricate Saharanpur inlay",
    bgGradient: "from-amber-900 to-stone-900",
    badge: "Solid Hardwood",
  },
  {
    name: "Metal & Dhokra",
    category: "Metalwork",
    desc: "4,000-year lost-wax casting & hammered brass",
    bgGradient: "from-zinc-800 to-amber-950",
    badge: "Lost-Wax Cast",
  },
  {
    name: "Regional Handicrafts",
    category: "Handicrafts",
    desc: "Authentic folk arts, Madhubani & Bidriware",
    bgGradient: "from-stone-900 to-rose-950",
    badge: "GI Tagged",
  },
];

const spotlightItems = [
  {
    id: "spot-1",
    title: "Jaipur Royal Blue Pottery",
    subtitle: "Cobalt Floral Quartz Glazed Vase",
    artisan: "Ram Narayan Sharma",
    category: "Ceramics",
    desc: "Crafted with pulverized quartz and fuller's earth rather than clay, fired once in traditional wood kilns with natural cobalt oxide glaze.",
    gradient: "from-navy via-navy-light to-blue-950",
    badge: "Master Work 1/5",
    link: "/explore?category=Ceramics",
  },
  {
    id: "spot-2",
    title: "Pure Mulberry Chanderi Silk",
    subtitle: "Heritage Zari Bordered Saree",
    artisan: "Meenakshi Devi",
    category: "Textiles",
    desc: "Hand-spun pure silk woven on traditional pit looms with intricate real gold-plated zari weaves passed down generations.",
    gradient: "from-rose-950 via-rose-900 to-amber-950",
    badge: "Master Work 2/5",
    link: "/explore?category=Textiles",
  },
  {
    id: "spot-3",
    title: "Saharanpur Brass Inlaid Teakwood",
    subtitle: "Carved Artisan Keepsake Box",
    artisan: "Iqbal Ahmed",
    category: "Woodworking",
    desc: "Carved from seasoned teakwood with hand-hammered floral sheet brass inlay work crafted by master woodcarvers.",
    gradient: "from-amber-950 via-amber-900 to-stone-900",
    badge: "Master Work 3/5",
    link: "/explore?category=Woodworking",
  },
  {
    id: "spot-4",
    title: "Ancient Lost-Wax Dhokra Cast",
    subtitle: "4,000-Year Metal Artistry",
    artisan: "Bastar Tribal Guild",
    category: "Metalwork",
    desc: "Non-ferrous metal casting using beeswax models and clay molds, maintaining an unbroken tribal legacy dating to Mohenjo-daro.",
    gradient: "from-zinc-900 via-stone-900 to-amber-950",
    badge: "Master Work 4/5",
    link: "/explore?category=Metalwork",
  },
  {
    id: "spot-5",
    title: "Khurja Glazed Terracotta",
    subtitle: "Hand-Painted Ceremonial Vessel",
    artisan: "Kamla Devi",
    category: "Handicrafts",
    desc: "Terracotta crafted with natural earthenware clay and hand-painted with mineral pigments, celebrating regional heritage.",
    gradient: "from-stone-900 via-red-950 to-navy",
    badge: "Master Work 5/5",
    link: "/explore?category=Handicrafts",
  },
];

const fallbackFeaturedProducts: Product[] = [
  {
    id: "feat-1",
    artisan_id: "art-1",
    artisan_name: "Ram Narayan Sharma",
    title: "Hand-Turned Blue Pottery Decorative Vase",
    description: "Traditional Jaipur quartz & fuller's earth glazed ceramic vase with cobalt floral motifs.",
    category: "Ceramics",
    materials: "Quartz Stone, Raw Glazes",
    price: 3450,
    currency: "INR",
    quantity: 4,
    tags: "pottery,jaipur,blue-glaze",
    images: "",
    status: "published",
    created_at: new Date().toISOString(),
  },
  {
    id: "feat-2",
    artisan_id: "art-2",
    artisan_name: "Meenakshi Devi",
    title: "Pure Mulberry Handloom Chanderi Silk Saree",
    description: "Hand-spun pure silk with antique zari borders crafted on traditional pit looms.",
    category: "Textiles",
    materials: "Chanderi Silk, Antique Zari",
    price: 8900,
    currency: "INR",
    quantity: 2,
    tags: "silk,chanderi,handloom",
    images: "",
    status: "published",
    created_at: new Date().toISOString(),
  },
  {
    id: "feat-3",
    artisan_id: "art-3",
    artisan_name: "Iqbal Ahmed",
    title: "Floral Brass Inlaid Teakwood Keepsake Box",
    description: "Carved from sustainably sourced seasoned teak with hand-hammered brass inlay work.",
    category: "Woodworking",
    materials: "Seasoned Teakwood, Sheet Brass",
    price: 2600,
    currency: "INR",
    quantity: 6,
    tags: "teak,brass-inlay,carved",
    images: "",
    status: "published",
    created_at: new Date().toISOString(),
  },
  {
    id: "feat-4",
    artisan_id: "art-4",
    artisan_name: "Bastar Tribal Guild",
    title: "Authentic Lost-Wax Cast Dhokra Brass Figurine",
    description: "Ancient 4,000-year tribal metal casting technique preserving generational motifs.",
    category: "Metalwork",
    materials: "Recycled Brass, Beeswax Core",
    price: 4200,
    currency: "INR",
    quantity: 3,
    tags: "dhokra,tribal,lost-wax",
    images: "",
    status: "published",
    created_at: new Date().toISOString(),
  },
];

export default function LandingPage() {
  const { user, logout } = useAuth();
  const { items } = useCart();
  const { wishlistCount } = useWishlist();
  const [featuredProducts, setFeaturedProducts] = useState<Product[]>([]);
  const [artisans, setArtisans] = useState<Artisan[]>([]);
  const [loading, setLoading] = useState(true);
  const [spotlightIndex, setSpotlightIndex] = useState(0);

  const totalCartCount = items.reduce((sum, item) => sum + item.cartQuantity, 0);

  useEffect(() => {
    const timer = setInterval(() => {
      setSpotlightIndex((prev) => (prev + 1) % spotlightItems.length);
    }, 4000);
    return () => clearInterval(timer);
  }, []);

  useEffect(() => {
    const loadMarketplaceData = async () => {
      try {
        const [prodRes, artRes] = await Promise.all([
          fetchApi("/products/marketplace"),
          fetchApi("/artisans/"),
        ]);

        if (prodRes.ok) {
          const pData = await prodRes.json();
          const list = Array.isArray(pData) ? pData : pData.products || [];
          if (list.length > 0) {
            setFeaturedProducts(list.slice(0, 8));
          } else {
            setFeaturedProducts(fallbackFeaturedProducts);
          }
        } else {
          setFeaturedProducts(fallbackFeaturedProducts);
        }

        if (artRes.ok) {
          const aData = await artRes.json();
          const aList = Array.isArray(aData) ? aData : aData.artisans || [];
          setArtisans(aList.slice(0, 4));
        }
      } catch (e) {
        setFeaturedProducts(fallbackFeaturedProducts);
      } finally {
        setLoading(false);
      }
    };

    loadMarketplaceData();
  }, []);

  return (
    <div className="min-h-screen flex flex-col bg-background selection:bg-gold-muted selection:text-navy">
      {/* Main Header */}
      <header className="sticky top-0 z-50 bg-white/95 backdrop-blur-md border-b border-border-light shadow-2xs">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 py-4 flex items-center justify-between gap-4">
          <div className="flex items-center gap-8">
            <Link href="/" className="flex flex-col group">
              <span className="font-serif text-2xl sm:text-3xl tracking-[0.15em] font-bold text-navy group-hover:text-gold transition-colors">
                AROHA
              </span>
              <span className="text-[10px] tracking-wide text-warm-gray lowercase font-medium -mt-1">
                where artists meet the market
              </span>
            </Link>
            <nav className="hidden lg:flex items-center gap-7 text-xs uppercase tracking-widest font-medium text-warm-gray">
              <Link href="/explore" className="hover:text-navy transition-colors">
                Explore Gallery
              </Link>
              <Link href="/artisans" className="hover:text-navy transition-colors">
                Master Artisans
              </Link>
              <Link href="/collections" className="hover:text-navy transition-colors">
                Curated Collections
              </Link>
            </nav>
          </div>

          <div className="hidden md:flex flex-1 max-w-md mx-4">
            <Link
              href="/explore"
              className="w-full flex items-center gap-2.5 px-4 py-2 bg-cream/80 hover:bg-cream border border-border rounded-full text-xs text-warm-gray transition-colors"
            >
              <svg className="w-4 h-4 text-warm-gray" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z" />
              </svg>
              <span>Search authentic pottery, silk, woodcraft, brass...</span>
            </Link>
          </div>

          <div className="flex items-center gap-3">
            {/* Wishlist */}
            <Link
              href="/wishlist"
              className="p-2 text-warm-gray hover:text-navy hover:bg-cream rounded-full transition-colors relative"
              title="Saved Items"
            >
              <svg className="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={1.5} d="M4.318 6.318a4.5 4.5 0 000 6.364L12 20.364l7.682-7.682a4.5 4.5 0 00-6.364-6.364L12 7.636l-1.318-1.318a4.5 4.5 0 00-6.364 0z" />
              </svg>
              {wishlistCount > 0 && (
                <span className="absolute top-1 right-1 w-4 h-4 bg-rose-600 text-white text-[10px] font-bold rounded-full flex items-center justify-center">
                  {wishlistCount}
                </span>
              )}
            </Link>

            {/* Cart */}
            <Link
              href="/cart"
              className="p-2 text-warm-gray hover:text-navy hover:bg-cream rounded-full transition-colors relative"
              title="Your Bag"
            >
              <svg className="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={1.5} d="M16 11V7a4 4 0 00-8 0v4M5 9h14l1 12H4L5 9z" />
              </svg>
              {totalCartCount > 0 && (
                <span className="absolute top-1 right-1 w-4 h-4 bg-navy text-gold text-[10px] font-bold rounded-full flex items-center justify-center border border-gold">
                  {totalCartCount}
                </span>
              )}
            </Link>

            {/* Auth Button */}
            {user ? (
              <div className="flex items-center gap-2">
                {user.role === "artisan" ? (
                  <Link
                    href="/artisan/dashboard"
                    className="px-3 py-1.5 bg-navy text-gold text-xs font-semibold rounded-lg hover:bg-navy-light transition-colors border border-gold/40"
                  >
                    Studio
                  </Link>
                ) : (
                  <Link
                    href="/orders"
                    className="px-3 py-1.5 text-xs font-medium text-navy hover:bg-cream rounded-lg transition-colors"
                  >
                    Orders
                  </Link>
                )}
                <button
                  onClick={() => logout()}
                  className="text-xs text-warm-gray hover:text-rose-600 px-2 py-1"
                >
                  Log Out
                </button>
              </div>
            ) : (
              <Link
                href="/login?role=customer"
                className="px-4 py-2 bg-navy text-white text-xs font-medium rounded-lg hover:bg-navy-light transition-colors shadow-sm"
              >
                Sign In
              </Link>
            )}
          </div>
        </div>
      </header>

      {/* Hero Showcase Section */}
      <section className="relative bg-gradient-to-b from-cream via-beige/40 to-background pt-12 pb-16 px-4 sm:px-6 overflow-hidden border-b border-border-light">
        <div className="max-w-7xl mx-auto grid grid-cols-1 lg:grid-cols-12 gap-10 items-center">
          {/* Hero Narrative */}
          <div className="lg:col-span-7 space-y-6 text-left">
            <div className="inline-flex items-center gap-2 px-3 py-1 rounded-full bg-gold/15 border border-gold/30 text-navy text-xs font-medium tracking-wide">
              <span className="w-2 h-2 rounded-full bg-gold animate-pulse" />
              Direct from India's Master Craft Guilds
            </div>

            <h1 className="font-serif text-4xl sm:text-5xl lg:text-6xl text-navy leading-[1.15] font-bold">
              Treasures of Generational Craftsmanship.
            </h1>

            <p className="text-warm-gray text-base sm:text-lg max-w-xl leading-relaxed">
              Experience the finest hand-thrown ceramics, heirloom silk textiles, and hand-chiseled woodcraft directly from the master artisans who shape them.
            </p>

            <div className="flex flex-wrap items-center gap-4 pt-2">
              <Link
                href="/explore"
                className="px-7 py-3.5 bg-navy hover:bg-navy-light text-white text-sm font-semibold rounded-xl transition-all shadow-luxury hover:scale-[1.02] flex items-center gap-2"
              >
                <span>Explore Marketplace</span>
                <span>→</span>
              </Link>
              <Link
                href="/collections"
                className="px-7 py-3.5 bg-white hover:bg-cream border border-border text-navy text-sm font-medium rounded-xl transition-colors shadow-sm"
              >
                Curated Collections
              </Link>
              <Link
                href="/login?role=artisan"
                className="px-5 py-3.5 text-xs text-warm-gray hover:text-navy font-medium underline transition-colors"
              >
                Are you an Artisan? Join as Creator →
              </Link>
            </div>

            {/* Quick Metrics */}
            <div className="grid grid-cols-3 gap-4 pt-6 border-t border-border-light max-w-md">
              <div>
                <span className="font-serif text-2xl font-bold text-navy">100%</span>
                <p className="text-xs text-warm-gray">Handcrafted</p>
              </div>
              <div>
                <span className="font-serif text-2xl font-bold text-navy">0%</span>
                <p className="text-xs text-warm-gray">Middlemen Fees</p>
              </div>
              <div>
                <span className="font-serif text-2xl font-bold text-navy">500+</span>
                <p className="text-xs text-warm-gray">Guild Masters</p>
              </div>
            </div>
          </div>

          {/* Hero Visual Feature Carousel (5 Spotlight Works) */}
          <div className="lg:col-span-5 relative">
            {spotlightItems.map((item, idx) => {
              if (idx !== spotlightIndex) return null;
              return (
                <div
                  key={item.id}
                  className={`relative rounded-3xl overflow-hidden bg-gradient-to-br ${item.gradient} p-8 text-white shadow-2xl border border-navy/20 transition-all duration-500 min-h-[380px] flex flex-col justify-between`}
                >
                  <div className="absolute top-0 right-0 p-8 opacity-15">
                    <svg className="w-48 h-48 text-gold" fill="currentColor" viewBox="0 0 24 24">
                      <path d="M12 2l3.09 6.26L22 9.27l-5 4.87 1.18 6.88L12 17.77l-6.18 3.25L7 14.14 2 9.27l6.91-1.01L12 2z" />
                    </svg>
                  </div>

                  <div className="relative z-10 space-y-5">
                    <div className="flex items-center justify-between">
                      <div className="inline-block px-3.5 py-1 bg-gold text-navy rounded-full text-xs font-bold uppercase tracking-wider shadow-sm">
                        Curator's Spotlight
                      </div>
                      <span className="text-xs font-mono text-gold/90 font-medium px-2.5 py-0.5 rounded-full bg-white/10 backdrop-blur-md">
                        {item.badge}
                      </span>
                    </div>

                    <div className="space-y-2">
                      <p className="text-xs text-gold uppercase tracking-widest font-semibold">{item.subtitle}</p>
                      <h3 className="font-serif text-2xl sm:text-3xl font-bold text-white">
                        {item.title}
                      </h3>
                      <p className="text-xs sm:text-sm text-gray-300 leading-relaxed line-clamp-3">
                        {item.desc}
                      </p>
                    </div>
                  </div>

                  <div className="relative z-10 space-y-4 pt-4">
                    <div className="p-4 rounded-xl bg-white/10 backdrop-blur-md border border-white/15 flex items-center justify-between">
                      <div>
                        <span className="text-[10px] text-gray-300 uppercase tracking-widest block">Master Artisan</span>
                        <span className="text-sm font-semibold text-white">{item.artisan}</span>
                      </div>
                      <Link
                        href={item.link}
                        className="px-4 py-2 bg-gold hover:bg-gold-light text-navy text-xs font-bold rounded-lg transition-colors shadow-sm"
                      >
                        View Series →
                      </Link>
                    </div>

                    {/* Carousel Controls & Slide Indicators */}
                    <div className="flex items-center justify-between pt-1">
                      <div className="flex items-center gap-1.5">
                        {spotlightItems.map((_, dotIdx) => (
                          <button
                            key={dotIdx}
                            onClick={() => setSpotlightIndex(dotIdx)}
                            className={`h-2 rounded-full transition-all duration-300 ${
                              dotIdx === spotlightIndex ? "w-6 bg-gold" : "w-2 bg-white/30 hover:bg-white/60"
                            }`}
                            aria-label={`Go to slide ${dotIdx + 1}`}
                          />
                        ))}
                      </div>

                      <div className="flex items-center gap-2">
                        <button
                          onClick={() => setSpotlightIndex((prev) => (prev === 0 ? spotlightItems.length - 1 : prev - 1))}
                          className="w-7 h-7 rounded-full bg-white/15 hover:bg-white/30 flex items-center justify-between justify-center text-white text-xs transition-colors"
                          title="Previous Spotlight"
                        >
                          ‹
                        </button>
                        <button
                          onClick={() => setSpotlightIndex((prev) => (prev + 1) % spotlightItems.length)}
                          className="w-7 h-7 rounded-full bg-white/15 hover:bg-white/30 flex items-center justify-between justify-center text-white text-xs transition-colors"
                          title="Next Spotlight"
                        >
                          ›
                        </button>
                      </div>
                    </div>
                  </div>
                </div>
              );
            })}
          </div>
        </div>
      </section>

      {/* Trust & Guarantees Value Strip */}
      <TrustBadges />

      {/* Category Explorer Grid */}
      <section className="py-14 px-4 sm:px-6 max-w-7xl mx-auto w-full">
        <div className="flex flex-col sm:flex-row sm:items-end justify-between mb-8 gap-4">
          <div>
            <span className="text-xs font-bold uppercase tracking-widest text-gold block mb-1">
              Disciplines of Craft
            </span>
            <h2 className="font-serif text-3xl text-navy font-bold">
              Shop by Heritage Medium
            </h2>
          </div>
          <Link
            href="/collections"
            className="text-xs font-semibold text-navy hover:text-gold uppercase tracking-wider flex items-center gap-1"
          >
            All Disciplines &amp; Regions →
          </Link>
        </div>

        <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-5 gap-4">
          {categoryHighlights.map((cat) => (
            <Link
              key={cat.category}
              href={`/explore?category=${cat.category}`}
              className="group relative rounded-2xl overflow-hidden p-6 h-56 flex flex-col justify-between shadow-luxury shadow-luxury-hover border border-border transition-all"
            >
              <div className={`absolute inset-0 bg-gradient-to-br ${cat.bgGradient} transition-transform duration-500 group-hover:scale-105`} />
              <div className="absolute inset-0 bg-black/25 group-hover:bg-black/10 transition-colors" />

              <div className="relative z-10 flex justify-between items-start">
                <span className="text-[10px] font-bold uppercase tracking-wider px-2 py-0.5 rounded-full bg-white/20 text-white backdrop-blur-md">
                  {cat.badge}
                </span>
                <span className="text-white/60 group-hover:text-gold transition-colors text-sm font-bold">
                  →
                </span>
              </div>

              <div className="relative z-10 text-white">
                <h3 className="font-serif text-lg font-bold group-hover:text-gold-muted transition-colors">
                  {cat.name}
                </h3>
                <p className="text-[11px] text-white/80 line-clamp-2 mt-1 leading-snug">
                  {cat.desc}
                </p>
              </div>
            </Link>
          ))}
        </div>
      </section>

      {/* Featured Works & Trending Curations */}
      <section className="py-14 px-4 sm:px-6 bg-cream/50 border-t border-border-light">
        <div className="max-w-7xl mx-auto">
          <div className="flex flex-col sm:flex-row sm:items-end justify-between mb-8 gap-4">
            <div>
              <span className="text-xs font-bold uppercase tracking-widest text-gold block mb-1">
                Handpicked Masterworks
              </span>
              <h2 className="font-serif text-3xl text-navy font-bold">
                Featured Marketplace Works
              </h2>
            </div>
            <Link
              href="/explore"
              className="px-5 py-2 rounded-lg border border-navy text-navy hover:bg-navy hover:text-white text-xs font-semibold tracking-wide transition-colors self-start sm:self-auto"
            >
              Browse Full Catalog ({featuredProducts.length}+)
            </Link>
          </div>

          <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-6">
            {featuredProducts.map((product) => (
              <ProductCard key={product.id} product={product} />
            ))}
          </div>
        </div>
      </section>

      {/* Master Artisan Spotlight */}
      <section className="py-16 px-4 sm:px-6 max-w-7xl mx-auto w-full">
        <div className="bg-navy rounded-3xl p-8 sm:p-12 text-white relative overflow-hidden shadow-2xl">
          <div className="max-w-3xl space-y-6 relative z-10">
            <span className="text-xs font-bold tracking-widest uppercase text-gold bg-gold/20 px-3 py-1 rounded-full">
              Guild Masters &amp; Creators
            </span>

            <h2 className="font-serif text-3xl sm:text-4xl lg:text-5xl font-bold leading-tight">
              Empowering 500+ Generational Artisans Across India
            </h2>

            <p className="text-gray-300 text-sm sm:text-base leading-relaxed">
              Every purchase on Aesthete directly supports master artisans, their families, and local craft guilds. We provide digital tools, AI-assisted cataloging, and direct buyer connections to keep ancient craft heritage alive.
            </p>

            <div className="flex flex-wrap items-center gap-4 pt-2">
              <Link
                href="/artisans"
                className="px-6 py-3 bg-gold hover:bg-gold-light text-navy font-bold text-xs uppercase tracking-wider rounded-xl transition-colors shadow-sm"
              >
                Meet the Artisans
              </Link>
              <Link
                href="/login?role=artisan"
                className="px-6 py-3 bg-white/10 hover:bg-white/20 border border-white/20 text-white font-medium text-xs rounded-xl transition-colors"
              >
                Artisan Login &amp; Studio Portal
              </Link>
            </div>
          </div>
        </div>
      </section>

      {/* Footer */}
      <Footer />
    </div>
  );
}
