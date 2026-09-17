"use client";

import Link from "next/link";
import { useSearchParams } from "next/navigation";
import { Suspense } from "react";

function PaymentSuccessContent() {
  const params = useSearchParams();
  const isDev = params.get("dev") === "1";
  const sessionId = params.get("session_id") || "";

  return (
    <div className="min-h-screen flex items-center justify-center bg-cream px-4">
      <div className="max-w-lg w-full bg-white rounded-3xl border border-border shadow-luxury p-10 text-center space-y-6">

        {/* Dev Mode Banner */}
        {isDev && (
          <div className="bg-amber-50 border border-amber-200 rounded-xl px-4 py-3 text-xs text-amber-800 font-medium">
            🔧 <strong>Dev Mode</strong> — Stripe bypassed (fake key detected). Add your real{" "}
            <code className="bg-amber-100 px-1 rounded">STRIPE_SECRET_KEY</code> to{" "}
            <code className="bg-amber-100 px-1 rounded">apps/api/.env</code> to use live Stripe.
          </div>
        )}

        {/* Success Icon */}
        <div className="w-20 h-20 bg-emerald-100 rounded-full flex items-center justify-center mx-auto">
          <svg className="w-10 h-10 text-emerald-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M5 13l4 4L19 7" />
          </svg>
        </div>

        <div className="space-y-2">
          <h1 className="font-serif text-3xl font-bold text-navy">
            {isDev ? "Order Placed (Dev Mode)" : "Payment Successful!"}
          </h1>
          <p className="text-warm-gray text-sm leading-relaxed">
            {isDev
              ? "Your order has been recorded in the system. In production, customers will be redirected to real Stripe checkout."
              : "Thank you for your purchase. Your payment has been processed and your order is being prepared by the artisan."}
          </p>
        </div>

        {sessionId && (
          <div className="bg-cream rounded-xl px-4 py-3 text-xs text-warm-gray font-mono break-all">
            Session: {sessionId}
          </div>
        )}

        <div className="flex flex-col sm:flex-row gap-3 pt-2">
          <Link
            href="/orders"
            className="flex-1 py-3 bg-navy text-white font-semibold text-xs rounded-xl hover:bg-navy-light transition-colors"
          >
            View My Orders
          </Link>
          <Link
            href="/explore"
            className="flex-1 py-3 bg-cream text-navy border border-border font-semibold text-xs rounded-xl hover:bg-white transition-colors"
          >
            Continue Shopping
          </Link>
        </div>
      </div>
    </div>
  );
}

export default function PaymentSuccessPage() {
  return (
    <Suspense fallback={<div className="min-h-screen flex items-center justify-center">Loading...</div>}>
      <PaymentSuccessContent />
    </Suspense>
  );
}
