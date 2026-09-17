"use client";

import { useState, useEffect } from "react";
import Link from "next/link";
import { fetchApi } from "@/lib/api/client";

export default function AdminAnalyticsPage() {
  const [loading, setLoading] = useState(true);
  const [totalGMV, setTotalGMV] = useState(0);
  const [totalOrders, setTotalOrders] = useState(0);
  const [totalArtisans, setTotalArtisans] = useState(0);
  const [totalProducts, setTotalProducts] = useState(0);
  const [categoryBreakdown, setCategoryBreakdown] = useState<any[]>([]);
  const [regionalDistribution, setRegionalDistribution] = useState<any[]>([]);
  const [topProducts, setTopProducts] = useState<any[]>([]);

  useEffect(() => {
    async function loadAnalytics() {
      try {
        const [artisansRes, productsRes, ordersRes] = await Promise.all([
          fetchApi("/artisans/"),
          fetchApi("/products/"),
          fetchApi("/orders/"),
        ]);

        let artisans: any[] = [];
        if (artisansRes.ok) {
          const data = await artisansRes.json();
          artisans = Array.isArray(data) ? data : [];
          setTotalArtisans(artisans.length);
        }

        let products: any[] = [];
        if (productsRes.ok) {
          const pData = await productsRes.json();
          products = pData.products || [];
          setTotalProducts(products.length || pData.total || 0);
          setTopProducts(products.slice(0, 5));
        }

        let orders: any[] = [];
        if (ordersRes.ok) {
          const oData = await ordersRes.json();
          orders = Array.isArray(oData) ? oData : oData.orders || [];
          setTotalOrders(orders.length);
          const gmv = orders
            .filter((o: any) => o.status !== "pending")
            .reduce((acc: number, curr: any) => acc + (curr.price * curr.quantity), 0);
          setTotalGMV(gmv);
        }

        // Category breakdown
        const catCount: Record<string, { count: number; value: number }> = {};
        products.forEach((p) => {
          const cat = p.category || "Handicrafts";
          if (!catCount[cat]) catCount[cat] = { count: 0, value: 0 };
          catCount[cat].count += 1;
          catCount[cat].value += p.price || 0;
        });

        const catArray = Object.entries(catCount).map(([name, stat]) => ({
          name,
          count: stat.count,
          value: stat.value,
          pct: products.length > 0 ? Math.round((stat.count / products.length) * 100) : 0,
        })).sort((a, b) => b.count - a.count);
        setCategoryBreakdown(catArray);

        // Regional distribution
        const regMap: Record<string, number> = {};
        artisans.forEach((a) => {
          const loc = a.location || "India";
          regMap[loc] = (regMap[loc] || 0) + 1;
        });
        const regArray = Object.entries(regMap).map(([region, count]) => ({
          region,
          count,
          pct: artisans.length > 0 ? Math.round((count / artisans.length) * 100) : 0,
        })).sort((a, b) => b.count - a.count);
        setRegionalDistribution(regArray);

      } catch (err) {
        console.error("Failed to load admin analytics:", err);
      } finally {
        setLoading(false);
      }
    }
    loadAnalytics();
  }, []);

  const avgOrderValue = totalOrders > 0 ? Math.round(totalGMV / totalOrders) : 0;

  return (
    <div className="space-y-8 max-w-7xl mx-auto">
      {/* Header */}
      <div className="flex flex-col sm:flex-row justify-between items-start sm:items-center gap-4 border-b border-border-light pb-6">
        <div>
          <nav className="text-xs text-warm-gray mb-1.5 flex items-center gap-1.5">
            <Link href="/admin/dashboard" className="hover:text-navy">Admin</Link>
            <span>/</span>
            <span className="text-navy font-semibold">Analytics &amp; Intelligence</span>
          </nav>
          <h1 className="font-serif text-3xl font-bold text-navy">
            Marketplace Analytics &amp; Guild Performance
          </h1>
          <p className="text-xs text-warm-gray mt-1">
            Real-time sales gross volume, artisan coverage, and craft category distribution.
          </p>
        </div>
        <div className="flex items-center gap-2">
          <span className="inline-flex items-center gap-1.5 px-3 py-1.5 rounded-full bg-emerald-50 text-emerald-700 text-xs font-semibold border border-emerald-200">
            <span className="w-2 h-2 rounded-full bg-emerald-500 animate-pulse" />
            Live DB Telemetry
          </span>
        </div>
      </div>

      {/* KPI Cards */}
      <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-5">
        <div className="bg-white rounded-2xl border border-border p-5 shadow-luxury">
          <p className="text-xs text-warm-gray font-medium uppercase tracking-wider">Gross Merchandise Value</p>
          <p className="font-serif text-3xl font-bold text-navy mt-2">₹{totalGMV.toLocaleString()}</p>
          <p className="text-[11px] text-emerald-700 font-medium mt-1">✓ 100% Direct Artisan Payouts</p>
        </div>

        <div className="bg-white rounded-2xl border border-border p-5 shadow-luxury">
          <p className="text-xs text-warm-gray font-medium uppercase tracking-wider">Average Order Value</p>
          <p className="font-serif text-3xl font-bold text-navy mt-2">₹{avgOrderValue.toLocaleString()}</p>
          <p className="text-[11px] text-warm-gray mt-1">Across {totalOrders} total orders</p>
        </div>

        <div className="bg-white rounded-2xl border border-border p-5 shadow-luxury">
          <p className="text-xs text-warm-gray font-medium uppercase tracking-wider">Verified Master Artisans</p>
          <p className="font-serif text-3xl font-bold text-navy mt-2">{totalArtisans}</p>
          <p className="text-[11px] text-gold font-medium mt-1">🌟 Across {regionalDistribution.length} Craft Hubs</p>
        </div>

        <div className="bg-white rounded-2xl border border-border p-5 shadow-luxury">
          <p className="text-xs text-warm-gray font-medium uppercase tracking-wider">Cataloged Masterpieces</p>
          <p className="font-serif text-3xl font-bold text-navy mt-2">{totalProducts}</p>
          <p className="text-[11px] text-warm-gray mt-1">{categoryBreakdown.length} craft disciplines</p>
        </div>
      </div>

      {/* Category Breakdown & Regional Hubs Grid */}
      <div className="grid grid-cols-1 lg:grid-cols-2 gap-8">
        {/* Category Share */}
        <div className="bg-white rounded-3xl border border-border p-6 shadow-luxury space-y-6">
          <div className="flex items-center justify-between border-b border-border-light pb-4">
            <h2 className="font-serif text-xl font-bold text-navy">Craft Category Share</h2>
            <span className="text-xs text-warm-gray font-medium">{totalProducts} active listings</span>
          </div>

          <div className="space-y-4">
            {categoryBreakdown.map((cat) => (
              <div key={cat.name} className="space-y-1.5">
                <div className="flex justify-between text-xs">
                  <span className="font-medium text-navy">{cat.name}</span>
                  <span className="text-warm-gray font-mono">{cat.count} works ({cat.pct}%)</span>
                </div>
                <div className="w-full bg-cream rounded-full h-2.5 overflow-hidden">
                  <div
                    className="bg-navy h-full rounded-full transition-all duration-500"
                    style={{ width: `${Math.max(5, cat.pct)}%` }}
                  />
                </div>
              </div>
            ))}
          </div>
        </div>

        {/* Regional Craft Hubs */}
        <div className="bg-white rounded-3xl border border-border p-6 shadow-luxury space-y-6">
          <div className="flex items-center justify-between border-b border-border-light pb-4">
            <h2 className="font-serif text-xl font-bold text-navy">Regional Craft Clusters</h2>
            <span className="text-xs text-warm-gray font-medium">{totalArtisans} artisans mapped</span>
          </div>

          <div className="space-y-4">
            {regionalDistribution.map((reg) => (
              <div key={reg.region} className="space-y-1.5">
                <div className="flex justify-between text-xs">
                  <span className="font-medium text-navy">📍 {reg.region}</span>
                  <span className="text-warm-gray font-mono">{reg.count} masters ({reg.pct}%)</span>
                </div>
                <div className="w-full bg-cream rounded-full h-2.5 overflow-hidden">
                  <div
                    className="bg-gold h-full rounded-full transition-all duration-500"
                    style={{ width: `${Math.max(5, reg.pct)}%` }}
                  />
                </div>
              </div>
            ))}
          </div>
        </div>
      </div>

      {/* Top Cataloged Works */}
      <div className="bg-white rounded-3xl border border-border p-6 shadow-luxury space-y-4">
        <h2 className="font-serif text-xl font-bold text-navy border-b border-border-light pb-4">
          Featured Catalog Works
        </h2>
        <div className="overflow-x-auto">
          <table className="w-full text-left text-xs">
            <thead>
              <tr className="border-b border-border-light text-warm-gray uppercase tracking-wider font-semibold">
                <th className="py-3 px-4">Title</th>
                <th className="py-3 px-4">Category</th>
                <th className="py-3 px-4">Price</th>
                <th className="py-3 px-4">Inventory</th>
                <th className="py-3 px-4">Status</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-border-light">
              {topProducts.map((p) => (
                <tr key={p.id} className="hover:bg-cream/40 transition-colors">
                  <td className="py-3.5 px-4 font-medium text-navy">{p.title}</td>
                  <td className="py-3.5 px-4 text-warm-gray">{p.category}</td>
                  <td className="py-3.5 px-4 font-serif font-bold text-navy">₹{p.price?.toLocaleString()}</td>
                  <td className="py-3.5 px-4">{p.quantity} units</td>
                  <td className="py-3.5 px-4">
                    <span className="px-2 py-0.5 rounded-full bg-emerald-100 text-emerald-800 text-[10px] font-bold uppercase">
                      {p.status || "published"}
                    </span>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </div>
    </div>
  );
}
