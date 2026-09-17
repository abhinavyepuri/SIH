"use client";

import Link from "next/link";

export default function PaymentCancelledPage() {
  return (
    <div className="min-h-screen bg-cream/30 flex items-center justify-center p-6">
      <div className="max-w-md w-full bg-white border border-border rounded-2xl p-8 shadow-luxury text-center space-y-6">
        <div className="w-16 h-16 bg-amber-100 text-amber-800 rounded-full flex items-center justify-center mx-auto text-2xl font-bold shadow-inner">
          ✕
        </div>

        <div className="space-y-2">
          <span className="text-xs uppercase tracking-widest font-bold text-warm-gray block">
            Stripe Checkout Cancelled
          </span>
          <h1 className="font-serif text-3xl text-navy font-bold">
            Payment Not Completed
          </h1>
          <p className="text-sm text-warm-gray leading-relaxed">
            Your checkout session was cancelled. No charges were made to your account.
          </p>
        </div>

        <div className="pt-4 flex flex-col gap-3">
          <Link
            href="/cart"
            className="w-full py-3 bg-navy text-white text-xs font-semibold uppercase tracking-wider rounded-xl hover:bg-navy-light transition-colors shadow-sm"
          >
            Return to Bag &amp; Retry →
          </Link>
          <Link
            href="/explore"
            className="w-full py-2.5 text-xs text-warm-gray hover:text-navy transition-colors font-medium"
          >
            Continue Exploring Gallery
          </Link>
        </div>
      </div>
    </div>
  );
}
