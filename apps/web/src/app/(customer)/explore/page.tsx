"use client";

import { Suspense, useState, useEffect, useMemo } from "react";
import Link from "next/link";
import { useSearchParams } from "next/navigation";
import { SearchInput, ProductCard } from "@/components/ui";
import { fetchApi } from "@/lib/api/client";
import type { Product } from "@/types";

type SortOption = "featured" | "price-asc" | "price-desc" | "newest";
type PriceFilter = "all" | "under-2000" | "2000-5000" | "above-5000";

function ExploreContent() {
  const searchParams = useSearchParams();
  const [products, setProducts] = useState<Product[]>([]);
  const [loading, setLoading] = useState(true);
  const [categories, setCategories] = useState<string[]>(["All Works"]);

  // Filter States
  const [selectedCategory, setSelectedCategory] = useState(
    searchParams.get("category") || "All Works"
  );
  const [search, setSearch] = useState(searchParams.get("search") || "");
  const [priceFilter, setPriceFilter] = useState<PriceFilter>("all");
  const [inStockOnly, setInStockOnly] = useState(false);
  const [sortBy, setSortBy] = useState<SortOption>("featured");
  const [viewMode, setViewMode] = useState<"grid" | "list">("grid");

  // Sync category param if URL changes
  useEffect(() => {
    const cat = searchParams.get("category");
    if (cat) setSelectedCategory(cat);
  }, [searchParams]);

  useEffect(() => {
    const fetchProducts = async () => {
      setLoading(true);
      try {
        const params = new URLSearchParams();
        if (selectedCategory !== "All Works") params.set("category", selectedCategory);
        if (search) params.set("search", search);

        const res = await fetchApi(`/products/marketplace?${params}`);
        if (res.ok) {
          const data = await res.json();
          let currentProducts: Product[] = [];
          if (data.products) {
            currentProducts = data.products;
          } else if (Array.isArray(data)) {
            currentProducts = data;
          }
          setProducts(currentProducts);
        } else {
          setProducts([]);
        }

        // Fetch categories dynamically from published products in database
        if (categories.length === 1) {
          const allRes = await fetchApi(`/products/marketplace`);
          if (allRes.ok) {
            const allData = await allRes.json();
            const allProds = allData.products || (Array.isArray(allData) ? allData : []);
            const uniqueCats = [
              ...new Set(allProds.map((p: Product) => p.category).filter(Boolean)),
            ] as string[];
            if (uniqueCats.length > 0) {
              setCategories(["All Works", ...uniqueCats]);
            }
          }
        }
      } catch (err) {
        setProducts([]);
      } finally {
        setLoading(false);
      }
    };

    fetchProducts();
  }, [selectedCategory, search, categories.length]);

  // Client-side filtering & sorting
  const filteredAndSortedProducts = useMemo(() => {
    let result = [...products];

    // Price Filter
    if (priceFilter === "under-2000") {
      result = result.filter((p) => p.price < 2000);
    } else if (priceFilter === "2000-5000") {
      result = result.filter((p) => p.price >= 2000 && p.price <= 5000);
    } else if (priceFilter === "above-5000") {
      result = result.filter((p) => p.price > 5000);
    }

    // In Stock Only
    if (inStockOnly) {
      result = result.filter((p) => p.quantity > 0);
    }

    // Search query locally if needed
    if (search.trim()) {
      const q = search.toLowerCase().trim();
      result = result.filter(
        (p) =>
          p.title.toLowerCase().includes(q) ||
          p.category.toLowerCase().includes(q) ||
          (p.artisan_name && p.artisan_name.toLowerCase().includes(q)) ||
          (p.description && p.description.toLowerCase().includes(q))
      );
    }

    // Sorting
    if (sortBy === "price-asc") {
      result.sort((a, b) => a.price - b.price);
    } else if (sortBy === "price-desc") {
      result.sort((a, b) => b.price - a.price);
    } else if (sortBy === "newest") {
      result.sort((a, b) => new Date(b.created_at).getTime() - new Date(a.created_at).getTime());
    }

    return result;
  }, [products, priceFilter, inStockOnly, search, sortBy]);

  const clearAllFilters = () => {
    setSelectedCategory("All Works");
    setSearch("");
    setPriceFilter("all");
    setInStockOnly(false);
    setSortBy("featured");
  };

  return (
    <div className="max-w-7xl mx-auto px-4 sm:px-6 py-8">
      {/* Header & Page Title */}
      <div className="mb-6 flex flex-col md:flex-row md:items-end justify-between gap-4 border-b border-border-light pb-6">
        <div>
          <nav className="text-xs text-warm-gray mb-2 flex items-center gap-1.5">
            <Link href="/" className="hover:text-navy">Home</Link>
            <span>/</span>
            <span className="text-navy font-semibold">Gallery</span>
            {selectedCategory !== "All Works" && (
              <>
                <span>/</span>
                <span className="text-gold font-medium">{selectedCategory}</span>
              </>
            )}
          </nav>
          <h1 className="font-serif text-3xl sm:text-4xl text-navy font-bold">
            Curated Artisan Gallery
          </h1>
          <p className="text-warm-gray text-xs sm:text-sm mt-1 max-w-xl">
            Discover authenticated handcrafted masterworks directly from certified Indian artisans.
          </p>
        </div>

        {/* Global Catalog Search */}
        <div className="w-full md:w-80">
          <SearchInput
            placeholder="Search by title, craft, or artisan..."
            value={search}
            onChange={setSearch}
            className="w-full"
          />
        </div>
      </div>

      {/* Main Catalog Layout (Faceted Sidebar + Products Grid) */}
      <div className="grid grid-cols-1 lg:grid-cols-12 gap-8 items-start">
        {/* Left Filter Sidebar */}
        <aside className="lg:col-span-3 bg-white p-5 rounded-2xl border border-border space-y-6 shadow-luxury">
          <div className="flex items-center justify-between pb-3 border-b border-border-light">
            <h3 className="font-serif text-base font-bold text-navy flex items-center gap-2">
              <svg className="w-4 h-4 text-gold" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M3 4a1 1 0 011-1h16a1 1 0 011 1v2.586a1 1 0 01-.293.707l-6.414 6.414a1 1 0 00-.293.707V17l-4 4v-6.586a1 1 0 00-.293-.707L3.293 7.293A1 1 0 013 6.586V4z" />
              </svg>
              Filter Gallery
            </h3>
            {(selectedCategory !== "All Works" || priceFilter !== "all" || inStockOnly || search) && (
              <button
                onClick={clearAllFilters}
                className="text-xs text-rose-600 hover:underline font-medium"
              >
                Reset
              </button>
            )}
          </div>

          {/* Categories */}
          <div>
            <h4 className="text-xs font-bold uppercase tracking-wider text-warm-gray mb-2.5">
              Craft Category
            </h4>
            <div className="space-y-1">
              {categories.map((cat) => (
                <button
                  key={cat}
                  onClick={() => setSelectedCategory(cat)}
                  className={`w-full text-left px-3 py-1.5 rounded-lg text-xs font-medium transition-colors flex items-center justify-between ${
                    selectedCategory === cat
                      ? "bg-navy text-white font-semibold"
                      : "text-warm-gray hover:bg-cream hover:text-navy"
                  }`}
                >
                  <span>{cat}</span>
                  {selectedCategory === cat && <span className="text-gold text-[10px]">●</span>}
                </button>
              ))}
            </div>
          </div>

          {/* Price Range */}
          <div>
            <h4 className="text-xs font-bold uppercase tracking-wider text-warm-gray mb-2.5">
              Price Range (INR)
            </h4>
            <div className="space-y-1.5 text-xs">
              {[
                { id: "all", label: "All Prices" },
                { id: "under-2000", label: "Under ₹2,000" },
                { id: "2000-5000", label: "₹2,000 to ₹5,000" },
                { id: "above-5000", label: "Above ₹5,000" },
              ].map((opt) => (
                <label
                  key={opt.id}
                  className="flex items-center gap-2.5 p-1.5 rounded hover:bg-cream/60 cursor-pointer text-warm-gray hover:text-navy"
                >
                  <input
                    type="radio"
                    name="priceRange"
                    checked={priceFilter === opt.id}
                    onChange={() => setPriceFilter(opt.id as PriceFilter)}
                    className="accent-navy"
                  />
                  <span>{opt.label}</span>
                </label>
              ))}
            </div>
          </div>

          {/* Stock Availability */}
          <div className="pt-2 border-t border-border-light">
            <h4 className="text-xs font-bold uppercase tracking-wider text-warm-gray mb-2.5">
              Availability
            </h4>
            <label className="flex items-center gap-2.5 p-1.5 rounded hover:bg-cream/60 cursor-pointer text-xs text-warm-gray hover:text-navy">
              <input
                type="checkbox"
                checked={inStockOnly}
                onChange={(e) => setInStockOnly(e.target.checked)}
                className="rounded accent-navy"
              />
              <span>In Stock Only</span>
            </label>
          </div>
        </aside>

        {/* Right Content Stage (Toolbar + Product Grid) */}
        <main className="lg:col-span-9 space-y-6">
          {/* Top Catalog Toolbar */}
          <div className="bg-white p-3.5 rounded-2xl border border-border flex flex-col sm:flex-row items-center justify-between gap-3 shadow-2xs">
            <div className="text-xs text-warm-gray font-medium">
              Showing{" "}
              <span className="font-bold text-navy">
                {filteredAndSortedProducts.length}
              </span>{" "}
              handcrafted creations
            </div>

            <div className="flex items-center gap-3 w-full sm:w-auto justify-between sm:justify-end">
              {/* Sort By Dropdown */}
              <div className="flex items-center gap-2 text-xs">
                <span className="text-warm-gray font-medium hidden sm:inline">Sort by:</span>
                <select
                  value={sortBy}
                  onChange={(e) => setSortBy(e.target.value as SortOption)}
                  className="bg-cream/60 border border-border rounded-lg px-2.5 py-1.5 text-xs text-navy font-medium focus:outline-none focus:border-navy"
                >
                  <option value="featured">Featured Curations</option>
                  <option value="price-asc">Price: Low to High</option>
                  <option value="price-desc">Price: High to Low</option>
                  <option value="newest">Newest Additions</option>
                </select>
              </div>

              {/* View Mode Toggle (Grid / List) */}
              <div className="flex items-center bg-cream/80 border border-border rounded-lg p-0.5">
                <button
                  type="button"
                  onClick={() => setViewMode("grid")}
                  className={`p-1.5 rounded-md transition-colors ${
                    viewMode === "grid" ? "bg-white text-navy shadow-xs" : "text-warm-gray hover:text-navy"
                  }`}
                  title="Grid View"
                >
                  <svg className="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M4 6a2 2 0 012-2h2a2 2 0 012 2v2a2 2 0 01-2 2H6a2 2 0 01-2-2V6zM14 6a2 2 0 012-2h2a2 2 0 012 2v2a2 2 0 01-2 2h-2a2 2 0 01-2-2V6zM4 16a2 2 0 012-2h2a2 2 0 012 2v2a2 2 0 01-2 2H6a2 2 0 01-2-2v-2zM14 16a2 2 0 012-2h2a2 2 0 012 2v2a2 2 0 01-2 2h-2a2 2 0 01-2-2v-2z" />
                  </svg>
                </button>
                <button
                  type="button"
                  onClick={() => setViewMode("list")}
                  className={`p-1.5 rounded-md transition-colors ${
                    viewMode === "list" ? "bg-white text-navy shadow-xs" : "text-warm-gray hover:text-navy"
                  }`}
                  title="List View"
                >
                  <svg className="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M4 6h16M4 12h16M4 18h16" />
                  </svg>
                </button>
              </div>
            </div>
          </div>

          {/* Active Filter Badges */}
          {(selectedCategory !== "All Works" || priceFilter !== "all" || inStockOnly || search) && (
            <div className="flex flex-wrap items-center gap-2 text-xs">
              <span className="text-warm-gray font-medium">Active filters:</span>
              {selectedCategory !== "All Works" && (
                <span className="bg-navy text-white px-2.5 py-1 rounded-full flex items-center gap-1.5 text-xs">
                  {selectedCategory}
                  <button onClick={() => setSelectedCategory("All Works")} className="hover:text-gold">×</button>
                </span>
              )}
              {priceFilter !== "all" && (
                <span className="bg-cream text-navy border border-border px-2.5 py-1 rounded-full flex items-center gap-1.5 text-xs font-medium">
                  {priceFilter === "under-2000" ? "Under ₹2,000" : priceFilter === "2000-5000" ? "₹2,000 - ₹5,000" : "Above ₹5,000"}
                  <button onClick={() => setPriceFilter("all")} className="hover:text-rose-600 font-bold">×</button>
                </span>
              )}
              {inStockOnly && (
                <span className="bg-cream text-navy border border-border px-2.5 py-1 rounded-full flex items-center gap-1.5 text-xs font-medium">
                  In Stock Only
                  <button onClick={() => setInStockOnly(false)} className="hover:text-rose-600 font-bold">×</button>
                </span>
              )}
              {search && (
                <span className="bg-cream text-navy border border-border px-2.5 py-1 rounded-full flex items-center gap-1.5 text-xs font-medium">
                  Search: "{search}"
                  <button onClick={() => setSearch("")} className="hover:text-rose-600 font-bold">×</button>
                </span>
              )}
            </div>
          )}

          {/* Products Grid / List */}
          {filteredAndSortedProducts.length > 0 ? (
            <div
              className={
                viewMode === "grid"
                  ? "grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-6"
                  : "space-y-4"
              }
            >
              {filteredAndSortedProducts.map((product) => (
                <ProductCard
                  key={product.id}
                  product={product}
                  viewMode={viewMode}
                />
              ))}
            </div>
          ) : (
            /* Rich Empty State */
            <div className="bg-white rounded-2xl border border-border p-12 text-center shadow-luxury space-y-4">
              <div className="w-16 h-16 rounded-full bg-cream mx-auto flex items-center justify-center text-warm-gray">
                <svg className="w-8 h-8" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={1.5} d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z" />
                </svg>
              </div>
              <h3 className="font-serif text-2xl font-bold text-navy">
                No Handcrafted Pieces Found
              </h3>
              <p className="text-warm-gray text-sm max-w-md mx-auto">
                We couldn't find any creations matching your selected criteria. Try adjusting your filters or search terms.
              </p>
              <div className="pt-2">
                <button
                  onClick={clearAllFilters}
                  className="px-6 py-2.5 bg-navy text-white rounded-xl text-xs font-semibold hover:bg-navy-light transition-colors"
                >
                  Clear All Filters
                </button>
              </div>
            </div>
          )}
        </main>
      </div>
    </div>
  );
}

export default function ExplorePage() {
  return (
    <Suspense
      fallback={
        <div className="max-w-7xl mx-auto px-6 py-20 text-center">
          <p className="text-warm-gray font-serif text-lg">Loading curated gallery...</p>
        </div>
      }
    >
      <ExploreContent />
    </Suspense>
  );
}
