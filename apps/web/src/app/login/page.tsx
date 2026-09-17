"use client";

import { Suspense, useState, useEffect } from "react";
import { useRouter, useSearchParams } from "next/navigation";
import Link from "next/link";
import { useAuth } from "@/stores/AuthContext";
import { fetchApi } from "@/lib/api/client";
import { INDIAN_STATES, CRAFT_CATEGORIES, LANGUAGES, BUSINESS_TYPES } from "@/lib/constants";

type Step = "role-email" | "login" | "register";
type Role = "artisan" | "customer" | "admin";

function LoginForm() {
  const router = useRouter();
  const searchParams = useSearchParams();
  const { login } = useAuth();

  const initialRole = (searchParams.get("role") as Role) || "customer";
  const [roleFromUrl, setRoleFromUrl] = useState(!!searchParams.get("role"));
  const [step, setStep] = useState<Step>("role-email");
  const [role, setRole] = useState<Role>(initialRole);
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState("");

  // Registration fields
  const [name, setName] = useState("");
  const [location, setLocation] = useState("");
  const [craftCategory, setCraftCategory] = useState("");
  const [selectedLanguages, setSelectedLanguages] = useState<string[]>([]);
  const [businessType, setBusinessType] = useState("");
  const [phone, setPhone] = useState("");
  const [langError, setLangError] = useState(false);

  const ic =
    "w-full px-4 py-2.5 border border-border rounded-lg text-sm focus:outline-none focus:border-gold focus:ring-1 focus:ring-gold transition-colors bg-white";
  const lc =
    "text-xs font-medium tracking-widest text-warm-gray-light uppercase block mb-1.5";

  const redirect = (r: Role) => {
    if (r === "artisan") router.push("/artisan/dashboard");
    else if (r === "admin") router.push("/admin/dashboard");
    else router.push("/explore");
  };

  const handleCheckEmail = async (e: React.FormEvent) => {
    e.preventDefault();
    setLoading(true);
    setError("");
    const cleanEmail = email.trim().toLowerCase();
    const activeRole = cleanEmail === "admin@gmail.com" ? "admin" : role;
    try {
      const res = await fetchApi("/auth/check-email", {
        method: "POST",
        body: JSON.stringify({ email: cleanEmail, role: activeRole }),
      });
      const data = await res.json();
      if (cleanEmail === "admin@gmail.com") setRole("admin");
      setStep(data.exists ? "login" : "register");
    } catch {
      setError("Could not connect to server. Is the API running?");
    } finally {
      setLoading(false);
    }
  };

  const handleLogin = async (e: React.FormEvent) => {
    e.preventDefault();
    setLoading(true);
    setError("");
    const cleanEmail = email.trim().toLowerCase();
    const activeRole = cleanEmail === "admin@gmail.com" ? "admin" : role;
    try {
      const res = await fetchApi("/auth/login", {
        method: "POST",
        body: JSON.stringify({ email: cleanEmail, password, role: activeRole }),
      });
      if (!res.ok) {
        const d = await res.json();
        setError(d.detail || "Login failed");
        return;
      }
      const user = await res.json();
      login(user);
      redirect(role);
    } catch {
      setError("Could not connect to server. Is the API running?");
    } finally {
      setLoading(false);
    }
  };

  const handleRegister = async (e: React.FormEvent) => {
    e.preventDefault();
    if (role === "artisan" && selectedLanguages.length === 0) {
      setLangError(true);
      return;
    }
    setLangError(false);
    setLoading(true);
    setError("");
    const cleanEmail = email.trim().toLowerCase();
    try {
      const endpoint =
        role === "artisan"
          ? "/auth/register/artisan"
          : "/auth/register/customer";
      const body =
        role === "artisan"
          ? {
              email: cleanEmail,
              password,
              name,
              location,
              craft_category: craftCategory,
              languages: selectedLanguages,
              business_type: businessType,
              phone: phone || null,
            }
          : { email: cleanEmail, password, name, phone: phone || null };

      const res = await fetchApi(endpoint, {
        method: "POST",
        body: JSON.stringify(body),
      });
      if (!res.ok) {
        const d = await res.json();
        setError(d.detail || "Registration failed");
        return;
      }
      const user = await res.json();
      login(user);
      redirect(role);
    } catch {
      setError("Could not connect to server. Is the API running?");
    } finally {
      setLoading(false);
    }
  };

  const toggleLang = (code: string) => {
    setSelectedLanguages((prev) =>
      prev.includes(code) ? prev.filter((l) => l !== code) : [...prev, code]
    );
  };

  const roles = [
    { value: "customer", label: "Buyer", desc: "Browse & buy" },
    { value: "artisan", label: "Artisan", desc: "Create & sell" },
    { value: "admin", label: "Admin", desc: "Manage platform" },
  ] as const;

  return (
    <div className="w-full max-w-lg">
      {/* Logo */}
      <div className="text-center mb-8">
        <Link
          href="/"
          className="block mb-6 group text-center"
        >
          <span className="font-serif text-3xl tracking-[0.15em] font-bold text-navy block">
            AROHA
          </span>
          <span className="text-xs text-warm-gray lowercase font-medium block mt-0.5">
            where artists meet the market
          </span>
        </Link>
        <h1 className="font-serif text-2xl text-navy mb-1">
          {step === "role-email"
            ? "Get Started"
            : step === "login"
            ? "Welcome Back"
            : "Your Details"}
        </h1>
        <p className="text-warm-gray text-sm">
          {step === "role-email"
            ? "Select your role and enter your email to continue"
            : step === "login"
            ? `Sign in to your ${role} account`
            : "Tell us about yourself to get started"}
        </p>
      </div>

      <div className="bg-white rounded-2xl border border-border p-8 shadow-sm">
        {error && (
          <div className="bg-red-50 border border-red-200 text-red-700 px-4 py-3 rounded-lg mb-6 text-sm">
            {error}
          </div>
        )}

        {/* ── Step 1: Role + Email ── */}
        {step === "role-email" && (
          <form onSubmit={handleCheckEmail} className="space-y-5">
            {/* If role came from URL (landing page click), just show a badge */}
            {roleFromUrl ? (
              <div className="flex items-center gap-3 px-4 py-3 bg-cream rounded-lg border border-border">
                <div className="w-8 h-8 rounded-full bg-navy flex items-center justify-center shrink-0">
                  <svg className="w-4 h-4 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M16 7a4 4 0 11-8 0 4 4 0 018 0zM12 14a7 7 0 00-7 7h14a7 7 0 00-7-7z" />
                  </svg>
                </div>
                <div>
                  <p className="text-sm font-medium text-navy capitalize">{role}</p>
                  <p className="text-xs text-warm-gray-light">
                    {role === "artisan" ? "Create & sell handcrafted works" : role === "admin" ? "Manage the platform" : "Browse & purchase"}
                  </p>
                </div>
              </div>
            ) : (
              /* When landing directly on /login (no role param), show role picker */
              <div>
                <label className={lc}>Select Role</label>
                <div className="grid grid-cols-3 gap-2">
                  {roles.map((r) => (
                    <button
                      key={r.value}
                      type="button"
                      onClick={() => setRole(r.value)}
                      className={`py-3 px-4 rounded-lg border text-center transition-all ${
                        role === r.value
                          ? "border-navy bg-navy text-white"
                          : "border-border bg-white text-warm-gray hover:border-navy"
                      }`}
                    >
                      <div className="text-sm font-medium">{r.label}</div>
                      <div className={`text-xs mt-0.5 ${role === r.value ? "text-gray-300" : "text-warm-gray-light"}`}>
                        {r.desc}
                      </div>
                    </button>
                  ))}
                </div>
              </div>
            )}

            <div>
              <label className={lc}>Email Address</label>
              <input
                type="email"
                value={email}
                onChange={(e) => setEmail(e.target.value)}
                placeholder="you@example.com"
                required
                className={ic}
                autoFocus
              />
            </div>

            <button
              type="submit"
              disabled={loading}
              className="w-full py-3 bg-navy text-white rounded-lg font-medium text-sm hover:bg-navy-light transition-colors disabled:opacity-50"
            >
              {loading ? "Checking..." : "Continue →"}
            </button>
          </form>
        )}

        {/* ── Step 2: Sign In ── */}
        {step === "login" && (
          <form onSubmit={handleLogin} className="space-y-5">
            <div>
              <label className={lc}>Email</label>
              <input
                type="email"
                value={email}
                readOnly
                className={ic + " bg-cream cursor-default"}
              />
            </div>
            <div>
              <label className={lc}>Password</label>
              <input
                type="password"
                value={password}
                onChange={(e) => setPassword(e.target.value)}
                placeholder="Enter your password"
                required
                className={ic}
              />
            </div>
            <button
              type="submit"
              disabled={loading}
              className="w-full py-3 bg-navy text-white rounded-lg font-medium text-sm hover:bg-navy-light transition-colors disabled:opacity-50"
            >
              {loading ? "Signing in..." : "Sign In"}
            </button>
            <button
              type="button"
              onClick={() => { setStep("role-email"); setError(""); setPassword(""); }}
              className="w-full py-2 text-sm text-warm-gray hover:text-navy"
            >
              ← Use a different email
            </button>
          </form>
        )}

        {/* ── Step 3: Register ── */}
        {step === "register" && (
          <form onSubmit={handleRegister} className="space-y-5">
            <p className="text-xs text-center text-warm-gray bg-cream rounded-lg py-2 px-4">
              No account found for <strong>{email}</strong>. Fill in your details below.
            </p>

            {/* Name — all roles */}
            <div>
              <label className={lc}>Name</label>
              <input
                type="text"
                value={name}
                onChange={(e) => setName(e.target.value)}
                placeholder="Enter your name"
                required
                className={ic}
              />
            </div>

            {/* Artisan-specific fields */}
            {role === "artisan" && (
              <>
                <div>
                  <label className={lc}>Location</label>
                  <select
                    value={location}
                    onChange={(e) => setLocation(e.target.value)}
                    required
                    className={ic}
                  >
                    <option value="">Select your state</option>
                    {INDIAN_STATES.map((s) => (
                      <option key={s} value={s}>{s}</option>
                    ))}
                  </select>
                </div>

                <div>
                  <label className={lc}>Craft Category</label>
                  <select
                    value={craftCategory}
                    onChange={(e) => setCraftCategory(e.target.value)}
                    required
                    className={ic}
                  >
                    <option value="">Select craft category</option>
                    {CRAFT_CATEGORIES.map((c) => (
                      <option key={c} value={c}>{c}</option>
                    ))}
                  </select>
                </div>

                <div>
                  <label className={lc}>Languages</label>
                  <div className="flex flex-wrap gap-2 mt-1">
                    {LANGUAGES.map((lang) => (
                      <button
                        key={lang.code}
                        type="button"
                        onClick={() => toggleLang(lang.code)}
                        className={`px-3 py-1.5 rounded-full text-xs border transition-all ${
                          selectedLanguages.includes(lang.code)
                            ? "bg-navy text-white border-navy"
                            : "bg-white text-warm-gray border-border hover:border-navy"
                        }`}
                      >
                        {lang.label}
                      </button>
                    ))}
                  </div>
                  {langError && (
                    <p className="text-red-500 text-xs mt-1">
                      Please select at least one language
                    </p>
                  )}
                </div>

                <div>
                  <label className={lc}>Business Type</label>
                  <select
                    value={businessType}
                    onChange={(e) => setBusinessType(e.target.value)}
                    required
                    className={ic}
                  >
                    <option value="">Select business type</option>
                    {BUSINESS_TYPES.map((b) => (
                      <option key={b} value={b}>{b}</option>
                    ))}
                  </select>
                </div>
              </>
            )}

            {/* Phone — buyer + artisan */}
            {role !== "admin" && (
              <div>
                <label className={lc}>Phone (optional)</label>
                <input
                  type="tel"
                  value={phone}
                  onChange={(e) => setPhone(e.target.value)}
                  placeholder="+91 XXXXXXXXXX"
                  className={ic}
                />
              </div>
            )}

            <div>
              <label className={lc}>Password</label>
              <input
                type="password"
                value={password}
                onChange={(e) => setPassword(e.target.value)}
                placeholder="Choose a password (min 6 chars)"
                required
                minLength={6}
                className={ic}
              />
            </div>

            <button
              type="submit"
              disabled={loading}
              className="w-full py-3 bg-navy text-white rounded-lg font-medium text-sm hover:bg-navy-light transition-colors disabled:opacity-50"
            >
              {loading ? "Creating account..." : "Create Account →"}
            </button>
            <button
              type="button"
              onClick={() => { setStep("role-email"); setError(""); setPassword(""); }}
              className="w-full py-2 text-sm text-warm-gray hover:text-navy"
            >
              ← Back
            </button>
          </form>
        )}
      </div>
    </div>
  );
}

export default function LoginPage() {
  return (
    <div className="min-h-screen flex items-center justify-center bg-cream px-6 py-12">
      <Suspense fallback={<div className="text-warm-gray">Loading...</div>}>
        <LoginForm />
      </Suspense>
    </div>
  );
}
