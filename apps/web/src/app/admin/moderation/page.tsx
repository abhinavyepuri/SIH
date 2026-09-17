"use client";

import { useState, useEffect } from "react";
import Link from "next/link";
import { fetchApi } from "@/lib/api/client";

export default function AdminModerationPage() {
  const [products, setProducts] = useState<any[]>([]);
  const [loading, setLoading] = useState(true);
  const [filter, setFilter] = useState<"all" | "published" | "draft">("all");
  const [actionMessage, setActionMessage] = useState<string | null>(null);

  const loadProducts = async () => {
    try {
      const res = await fetchApi("/products/");
      if (res.ok) {
        const data = await res.json();
        setProducts(data.products || []);
      }
    } catch (e) {
      console.error("Failed to load products for moderation:", e);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    loadProducts();
  }, []);

  const handleUpdateStatus = async (productId: string, newStatus: string) => {
    try {
      // Find current product details
      const p = products.find((item) => item.id === productId);
      if (!p) return;

      const res = await fetchApi(`/products/${productId}`, {
        method: "PUT",
        body: JSON.stringify({
          title: p.title,
          description: p.description || "",
          category: p.category,
          materials: p.materials || "",
          price: p.price,
          currency: p.currency || "INR",
          quantity: p.quantity || 1,
          tags: p.tags || "",
          images: p.images || "",
          status: newStatus,
          crafting_process: p.crafting_process || "",
        }),
      });

      if (res.ok) {
        setActionMessage(`Product ${productId} marked as ${newStatus}.`);
        setTimeout(() => setActionMessage(null), 3000);
        loadProducts();
      } else {
        alert("Failed to update status.");
      }
    } catch (e) {
      console.error("Error updating product moderation status:", e);
    }
  };

  const filteredProducts = products.filter((p) => {
    if (filter === "all") return true;
    return (p.status || "published") === filter;
  });

  return (
    <div className="space-y-8 max-w-7xl mx-auto">
      {/* Header */}
      <div className="flex flex-col sm:flex-row justify-between items-start sm:items-center gap-4 border-b border-border-light pb-6">
        <div>
          <nav className="text-xs text-warm-gray mb-1.5 flex items-center gap-1.5">
            <Link href="/admin/dashboard" className="hover:text-navy">Admin</Link>
            <span>/</span>
            <span className="text-navy font-semibold">Moderation Queue</span>
          </nav>
          <h1 className="font-serif text-3xl font-bold text-navy">
            Craft Authenticity &amp; Moderation
          </h1>
          <p className="text-xs text-warm-gray mt-1">
            Review handcrafted artisan listings, verify origin authenticity, and approve/flag works for the public gallery.
          </p>
        </div>

        <div className="flex gap-2 bg-cream p-1 rounded-xl border border-border">
          <button
            onClick={() => setFilter("all")}
            className={`px-3 py-1.5 rounded-lg text-xs font-semibold transition-all ${
              filter === "all" ? "bg-navy text-white" : "text-warm-gray hover:text-navy"
            }`}
          >
            All Works ({products.length})
          </button>
          <button
            onClick={() => setFilter("published")}
            className={`px-3 py-1.5 rounded-lg text-xs font-semibold transition-all ${
              filter === "published" ? "bg-navy text-white" : "text-warm-gray hover:text-navy"
            }`}
          >
            Published
          </button>
          <button
            onClick={() => setFilter("draft")}
            className={`px-3 py-1.5 rounded-lg text-xs font-semibold transition-all ${
              filter === "draft" ? "bg-navy text-white" : "text-warm-gray hover:text-navy"
            }`}
          >
            Pending / Drafts
          </button>
        </div>
      </div>

      {actionMessage && (
        <div className="p-4 bg-emerald-50 border border-emerald-200 text-emerald-800 text-xs font-semibold rounded-2xl animate-fade-in flex items-center gap-2">
          <span>✓</span>
          <span>{actionMessage}</span>
        </div>
      )}

      {/* Moderation Table */}
      <div className="bg-white rounded-3xl border border-border shadow-luxury overflow-hidden">
        <div className="overflow-x-auto">
          <table className="w-full text-left text-xs">
            <thead>
              <tr className="bg-cream/40 border-b border-border-light text-warm-gray uppercase tracking-wider font-semibold">
                <th className="py-3.5 px-6">Work / Title</th>
                <th className="py-3.5 px-6">Artisan ID</th>
                <th className="py-3.5 px-6">Category</th>
                <th className="py-3.5 px-6">Price</th>
                <th className="py-3.5 px-6">Status</th>
                <th className="py-3.5 px-6 text-right">Moderation Action</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-border-light">
              {filteredProducts.length === 0 ? (
                <tr>
                  <td colSpan={6} className="py-12 text-center text-warm-gray">
                    No products matching this moderation filter.
                  </td>
                </tr>
              ) : (
                filteredProducts.map((p) => (
                  <tr key={p.id} className="hover:bg-cream/30 transition-colors">
                    <td className="py-4 px-6 font-medium text-navy">
                      <Link href={`/products/${p.id}`} className="hover:text-gold transition-colors font-serif font-bold text-sm block">
                        {p.title}
                      </Link>
                      <span className="text-[11px] text-warm-gray truncate max-w-xs block mt-0.5">
                        {p.materials || "Natural craft materials"}
                      </span>
                    </td>
                    <td className="py-4 px-6 font-mono text-[11px] text-warm-gray">
                      {p.artisan_id || "ART_GUILD"}
                    </td>
                    <td className="py-4 px-6">
                      <span className="px-2.5 py-1 rounded-full bg-cream border border-border text-navy text-[10px] font-bold uppercase">
                        {p.category}
                      </span>
                    </td>
                    <td className="py-4 px-6 font-serif font-bold text-navy text-sm">
                      ₹{p.price?.toLocaleString()}
                    </td>
                    <td className="py-4 px-6">
                      <span
                        className={`px-2.5 py-0.5 rounded-full text-[10px] font-bold uppercase ${
                          p.status === "published"
                            ? "bg-emerald-100 text-emerald-800"
                            : "bg-amber-100 text-amber-800"
                        }`}
                      >
                        {p.status || "published"}
                      </span>
                    </td>
                    <td className="py-4 px-6 text-right space-x-2">
                      {p.status === "draft" ? (
                        <button
                          onClick={() => handleUpdateStatus(p.id, "published")}
                          className="px-3 py-1.5 bg-emerald-600 hover:bg-emerald-700 text-white rounded-lg font-semibold text-xs shadow-sm transition-colors"
                        >
                          Approve &amp; Publish
                        </button>
                      ) : (
                        <button
                          onClick={() => handleUpdateStatus(p.id, "draft")}
                          className="px-3 py-1.5 bg-cream hover:bg-amber-50 text-amber-800 border border-amber-200 rounded-lg font-semibold text-xs transition-colors"
                        >
                          Flag / Unpublish
                        </button>
                      )}
                      <Link
                        href={`/products/${p.id}`}
                        target="_blank"
                        className="px-3 py-1.5 bg-white border border-border hover:bg-cream text-navy rounded-lg font-semibold text-xs transition-colors"
                      >
                        Inspect ↗
                      </Link>
                    </td>
                  </tr>
                ))
              )}
            </tbody>
          </table>
        </div>
      </div>
    </div>
  );
}
