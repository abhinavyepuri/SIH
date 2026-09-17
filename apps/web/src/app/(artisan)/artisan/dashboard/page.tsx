"use client";

import { useState, useEffect } from "react";
import Link from "next/link";
import { StatCard } from "@/components/ui";
import { fetchApi } from "@/lib/api/client";
import { useAuth } from "@/stores/AuthContext";

import { useRouter } from "next/navigation";

interface Insight {
  title: string;
  description: string;
  type: string;
}

export default function ArtisanDashboard() {
  const { user, loading: authLoading } = useAuth();
  const router = useRouter();
  const [stats, setStats] = useState({ posts: 0, reach: "0", revenue: "₹0" });
  const [insights, setInsights] = useState<Insight[]>([]);
  const [products, setProducts] = useState<any[]>([]);
  const [dataLoading, setDataLoading] = useState(true);

  useEffect(() => {
    if (authLoading) return;
    if (!user?.id) {
      router.push("/login?role=artisan");
      return;
    }

    const fetchData = async () => {
      try {
        const [productsRes, ordersRes] = await Promise.all([
          fetchApi(`/artisans/${user.id}/products`),
          fetchApi("/orders/"),
        ]);

        let artisanProducts: any[] = [];
        if (productsRes.ok) {
          const productsData = await productsRes.json();
          artisanProducts = productsData.products || [];
          setProducts(artisanProducts);
        }

        let totalRevenue = 0;
        if (ordersRes.ok) {
          const ordersData = await ordersRes.json();
          const ordersList = Array.isArray(ordersData) ? ordersData : ordersData.orders || [];

          const artisanIdentifiers = new Set([
            user.id?.toLowerCase().trim(),
            user.email?.toLowerCase().trim(),
            user.name?.toLowerCase().trim(),
          ].filter(Boolean));

          const productIds = new Set(artisanProducts.map((p) => p.id));
          const productTitles = new Set(artisanProducts.map((p) => p.title?.toLowerCase().trim()).filter(Boolean));

          const matchedOrders = ordersList.filter((o: any) => {
            const aid = o.artisan_id?.toLowerCase().trim();
            const ptitle = o.product_title?.toLowerCase().trim();
            return (
              (aid && artisanIdentifiers.has(aid)) ||
              (o.product_id && productIds.has(o.product_id)) ||
              (ptitle && productTitles.has(ptitle))
            );
          });

          totalRevenue = matchedOrders.reduce(
            (acc: number, o: any) => acc + Number(o.price || 0) * Number(o.quantity || 1),
            0
          );
        }

        setStats({
          posts: artisanProducts.length,
          reach: `${artisanProducts.length * 14 + 10}`,
          revenue: `₹${totalRevenue.toLocaleString()}`,
        });
      } catch (err) {
        console.error("Error fetching artisan data:", err);
      } finally {
        setDataLoading(false);
      }
    };

    fetchData();
    setInsights([]);
  }, [user, authLoading, router]);

  return (
    <div>
      {/* Header */}
      <div className="flex items-center justify-between mb-8">
        <div>
          <h1 className="font-serif text-3xl text-navy">Studio Overview</h1>
          <p className="text-warm-gray text-sm mt-1">
            Manage your portfolio and track performance.
          </p>
        </div>
        <div className="flex items-center gap-3">
          <span className="text-xs text-warm-gray-light">
            Last updated: {new Date().toLocaleDateString("en-IN", { hour: "2-digit", minute: "2-digit" })}
          </span>
          <button className="p-2 rounded-lg border border-border hover:bg-white transition-colors">
            <svg className="w-4 h-4 text-warm-gray" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M4 4v5h.582m15.356 2A8.001 8.001 0 004.582 9m0 0H9m11 11v-5h-.581m0 0a8.003 8.003 0 01-15.357-2m15.357 2H15" />
            </svg>
          </button>
        </div>
      </div>

      {/* KPI Cards */}
      <div className="grid grid-cols-1 md:grid-cols-3 gap-6 mb-8">
        <StatCard
          label="Total Posts"
          value={stats.posts.toString()}
          change="+12 this month"
          changeType="positive"
          icon={
            <svg className="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={1.5} d="M4 16l4.586-4.586a2 2 0 012.828 0L16 16m-2-2l1.586-1.586a2 2 0 012.828 0L20 14m-6-6h.01M6 20h12a2 2 0 002-2V6a2 2 0 00-2-2H6a2 2 0 00-2 2v12a2 2 0 002 2z" />
            </svg>
          }
        />
        <StatCard
          label="Monthly Reach"
          value={stats.reach}
          change="+8.2% vs last month"
          changeType="positive"
          icon={
            <svg className="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={1.5} d="M15 12a3 3 0 11-6 0 3 3 0 016 0z" />
              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={1.5} d="M2.458 12C3.732 7.943 7.523 5 12 5c4.478 0 8.268 2.943 9.542 7-1.274 4.057-5.064 7-9.542 7-4.477 0-8.268-2.943-9.542-7z" />
            </svg>
          }
        />
        <StatCard
          label="Total Revenue"
          value={stats.revenue}
          change="→ Stable performance"
          changeType="neutral"
          icon={
            <svg className="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={1.5} d="M12 8c-1.657 0-3 .895-3 2s1.343 2 3 2 3 .895 3 2-1.343 2-3 2m0-8c1.11 0 2.08.402 2.599 1M12 8V7m0 1v8m0 0v1m0-1c-1.11 0-2.08-.402-2.599-1M21 12a9 9 0 11-18 0 9 9 0 0118 0z" />
            </svg>
          }
        />
      </div>

      {/* AI Insights */}
      <div className="bg-white rounded-xl border border-border p-6 mb-8">
        <h2 className="font-serif text-xl text-navy mb-4 flex items-center gap-2">
          <span className="text-gold">✨</span> AI Smart Insights
        </h2>
        {insights.length === 0 ? (
          <div className="text-center py-6 text-warm-gray text-sm">
            No new insights right now. Keep posting to get AI recommendations!
          </div>
        ) : (
          <div className="space-y-3">
            {insights.map((insight, i) => (
              <div key={i} className="bg-cream rounded-lg p-4">
                <h3 className="text-sm font-medium text-navy mb-1">{insight.title}</h3>
                <p className="text-sm text-warm-gray">{insight.description}</p>
              </div>
            ))}
          </div>
        )}
      </div>

      {/* Recent Portfolio */}
      <div className="flex items-center justify-between mb-4">
        <h2 className="font-serif text-xl text-navy">Recent Portfolio</h2>
        <Link href="/artisan/products" className="text-sm text-navy hover:text-gold transition-colors">
          View All →
        </Link>
      </div>
      <div className="grid grid-cols-2 md:grid-cols-4 gap-4">
        {/* Upload Card */}
        <Link
          href="/artisan/products/new"
          className="aspect-square border-2 border-dashed border-border rounded-xl flex flex-col items-center justify-center text-warm-gray hover:border-gold hover:text-gold transition-colors"
        >
          <svg className="w-8 h-8 mb-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={1.5} d="M4 16l4.586-4.586a2 2 0 012.828 0L16 16m-2-2l1.586-1.586a2 2 0 012.828 0L20 14m-6-6h.01M6 20h12a2 2 0 002-2V6a2 2 0 00-2-2H6a2 2 0 00-2 2v12a2 2 0 002 2z" />
          </svg>
          <span className="text-sm">Upload New Work</span>
        </Link>

        {/* Sample portfolio items */}
        {products.slice(0, 3).map((product, i) => (
          <div key={product.id} className="group cursor-pointer">
            {/* If images exist, show the first one, else fallback to colored square */}
            {product.images ? (
              <div 
                className="aspect-square rounded-xl mb-2 bg-cover bg-center" 
                style={{ backgroundImage: `url(${product.images.split(',')[0]})` }} 
              />
            ) : (
              <div className={`aspect-square rounded-xl mb-2 ${["bg-stone-300", "bg-zinc-400", "bg-amber-200"][i % 3]}`} />
            )}
            <p className="text-sm font-medium text-navy truncate">{product.title}</p>
            <p className="text-xs text-warm-gray-light">
              {product.status} • ₹{product.price}
            </p>
          </div>
        ))}
      </div>
    </div>
  );
}
