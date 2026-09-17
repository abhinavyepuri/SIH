# SIH26090 — AESTHETE Marketplace — Project Status

## Project Overview

An AI-powered artisan marketplace where artisans can list their handcrafted products, and buyers can explore, order, and support local craftsmanship.

**Tech Stack:**
- **Mobile:** Flutter (apps/mobile/)
- **Web:** Next.js 16 + Tailwind CSS (apps/web/)
- **Backend:** FastAPI + Python (apps/api/)
- **Database:** PostgreSQL (localhost:5432/sih26090)
- **AI Services:** Placeholder in services/ai/ (not yet built)

---

## What Has Been Built

### Backend (FastAPI + PostgreSQL)

| File | Purpose | Status |
|---|---|---|
| `apps/api/src/app/main.py` | FastAPI app with CORS, lifespan, routes | ✅ Done |
| `apps/api/src/app/config.py` | Pydantic Settings from .env | ✅ Done |
| `apps/api/src/app/database.py` | SQLAlchemy engine + session | ✅ Done |
| `apps/api/src/app/models/artisan.py` | Artisan table | ✅ Done |
| `apps/api/src/app/models/product.py` | Product table | ✅ Done |
| `apps/api/src/app/models/order.py` | Order table | ✅ Done |
| `apps/api/src/app/schemas/artisan.py` | Pydantic schemas for artisan | ✅ Done |
| `apps/api/src/app/schemas/product.py` | Pydantic schemas for product | ✅ Done |
| `apps/api/src/app/schemas/order.py` | Pydantic schemas for order | ✅ Done |
| `apps/api/src/app/api/routes/artisan.py` | Artisan CRUD + stats + products-by-artisan | ✅ Done |
| `apps/api/src/app/api/routes/product.py` | Product CRUD + marketplace + stats | ✅ Done |
| `apps/api/src/app/api/routes/order.py` | Order CRUD + stats | ✅ Done |
| `apps/api/src/app/seed.py` | Seed 5 artisans + 10 products | ✅ Done |

**API Endpoints:**
```
POST   /api/v1/artisans/               — Create artisan
GET    /api/v1/artisans/               — List all artisans
GET    /api/v1/artisans/stats          — Artisan counts
GET    /api/v1/artisans/{id}           — Get single artisan
GET    /api/v1/artisans/{id}/products  — Products by this artisan

POST   /api/v1/products/              — Create product
GET    /api/v1/products/              — List all products (with filters)
GET    /api/v1/products/stats         — Product counts
GET    /api/v1/products/marketplace   — Published products only (public)
GET    /api/v1/products/{id}          — Get single product
PUT    /api/v1/products/{id}          — Update product
DELETE /api/v1/products/{id}          — Soft delete product

POST   /api/v1/orders/                — Create order
GET    /api/v1/orders/                — List orders (with filters)
GET    /api/v1/orders/stats           — Order counts + revenue
GET    /api/v1/orders/{id}            — Get single order
PUT    /api/v1/orders/{id}/status     — Update order status
```

---

### Web Frontend (Next.js)

#### Shared Infrastructure

| File | Purpose | Status |
|---|---|---|
| `apps/web/src/lib/api/client.ts` | Centralized API client (uses `NEXT_PUBLIC_API_URL` env var, defaults to `http://127.0.0.1:8000/api/v1`) | ✅ Done |
| `apps/web/src/stores/CartContext.tsx` | React Context for cart, persisted to localStorage | ✅ Done |
| `apps/web/src/components/explore/Header.tsx` | Customer nav header (Gallery / Artisans / Collections / Cart) | ✅ Done |

> All hardcoded `http://localhost:8000` URLs have been removed from every page. All data comes from the real PostgreSQL database via FastAPI. No mock arrays or fake data remain.

#### Pages

| Route | Page | Data Source | Status |
|---|---|---|---|
| `/` | Landing page — 3 portal cards | Static | ✅ Done |
| `/login` | Role-based login (Buyer/Artisan/Admin) | localStorage | ✅ Done |
| `/explore` | Product gallery — dynamic categories from DB, search & filters | FastAPI `/products/marketplace` | ✅ Done |
| `/products/[id]` | Product detail — full description, materials, real image, Add to Bag | FastAPI `/products/{id}` | ✅ Done |
| `/artisans` | All artisans directory listing | FastAPI `/artisans/` | ✅ Done |
| `/artisans/[id]` | Individual artisan public profile + their published works | FastAPI `/artisans/{id}` + `/artisans/{id}/products` | ✅ Done |
| `/collections` | Curated collections — dynamically built from distinct product categories in DB | FastAPI `/products/marketplace` | ✅ Done |
| `/cart` | Cart page — shows items, calculates total, places order via API | FastAPI `/orders/` | ✅ Done |
| `/artisan/dashboard` | KPIs from real DB — total products, real revenue from sold items, dynamic timestamp | FastAPI `/artisans/` + `/artisans/{id}/products` | ✅ Done |
| `/artisan/products/new` | List New Work form — saves to DB, fetches real artisan ID dynamically | FastAPI `/products/` POST | ✅ Done |
| `/admin/dashboard` | Artisan counts + table from real DB | FastAPI `/artisans/` + `/products/` | ✅ Done |

**Shared Components (apps/web/src/components/ui/):**
- Button, Badge, Card, SearchInput, StatCard, Footer

**Design System:**
- Fonts: Playfair Display (serif) + Inter (sans)
- Colors: Navy #0f172a, Gold #c5a55a, Beige #f5f0eb

---

### Mobile App (Flutter)

| File | Purpose | Status |
|---|---|---|
| `lib/main.dart` | App entry → WelcomeScreen | ✅ Done |
| `lib/features/onboarding/welcome_screen.dart` | Welcome page | ✅ Done |
| `lib/features/onboarding/onboarding_screen.dart` | Artisan onboarding form | ✅ Done |
| `lib/core/network/api_client.dart` | HTTP client (platform-aware URL) | ✅ Done |
| `lib/core/constants/app_constants.dart` | States, categories, languages | ✅ Done |

---

## How to Start Everything

### Terminal 1 — Backend API
```bash
cd apps/api
.venv\Scripts\activate
uvicorn src.app.main:app --reload --port 8000
```

### Terminal 2 — Seed Database (one-time, skipped if already seeded)
```bash
cd apps/api
.venv\Scripts\activate
python src/app/seed.py
```

### Terminal 3 — Web Frontend
```bash
cd apps/web
npm run dev
```
Opens at → http://localhost:3000

### Terminal 4 — Mobile App
```bash
cd apps/mobile
flutter run
```

---

## Environment Variables

### Backend (`apps/api/.env`)
```
DATABASE_URL=postgresql+psycopg://postgres:admin@localhost:5432/sih26090
REDIS_URL=redis://localhost:6379
JWT_SECRET=change-this-to-a-random-secret-in-production
```

### Frontend (`apps/web/.env.local`) — optional, defaults shown
```
NEXT_PUBLIC_API_URL=http://127.0.0.1:8000/api/v1
```

---

## Full End-to-End Flow (Verified Working ✅)

1. **Artisan logs in** → redirected to `/artisan/dashboard`
2. **Dashboard shows** real product count, real revenue (sum of "sold" products) from DB
3. **Artisan posts new work** via `/artisan/products/new` → saved to PostgreSQL
4. **Buyer visits** `/explore` → sees all published products from DB, with dynamic category filters extracted from real data
5. **Buyer clicks artisan name** → goes to `/artisans/[id]` profile with all their works
6. **Buyer clicks product** → full product detail page at `/products/[id]` with Add to Bag
7. **Buyer opens cart** at `/cart` → reviews items, clicks "Place Order (Demo)" → order created in PostgreSQL
8. **Admin at** `/admin/dashboard` → sees real artisan count and artisan table from DB

---

## Database Schema

### artisans
| Column | Type | Notes |
|---|---|---|
| id | TEXT PK | Auto: ART001XXXX |
| name | VARCHAR(255) | Required |
| location | VARCHAR(255) | Required |
| craft_category | VARCHAR(100) | Required |
| languages | TEXT[] | PostgreSQL array |
| business_type | VARCHAR(50) | individual/small_business |
| verification_status | VARCHAR(20) | pending/approved/rejected |
| phone | VARCHAR(20) | Nullable |
| email | VARCHAR(255) | Nullable |
| profile_image | VARCHAR(500) | Nullable |
| created_at | TIMESTAMP | Auto |
| is_active | BOOLEAN | Default true |

### products
| Column | Type | Notes |
|---|---|---|
| id | TEXT PK | Auto: PRD001XXXX |
| artisan_id | TEXT FK | References artisans |
| title | VARCHAR(255) | Required |
| description | TEXT | Nullable |
| category | VARCHAR(100) | Required |
| materials | VARCHAR(500) | Nullable |
| price | FLOAT | Required |
| currency | VARCHAR(10) | Default INR |
| quantity | INTEGER | Default 1 |
| tags | TEXT | Comma-separated |
| images | TEXT | Comma-separated URLs |
| status | VARCHAR(20) | draft/published/sold |
| crafting_process | TEXT | Nullable |
| created_at | TIMESTAMP | Auto |
| is_active | BOOLEAN | Default true |

### orders
| Column | Type | Notes |
|---|---|---|
| id | TEXT PK | Auto: ORD001XXXX |
| customer_name | VARCHAR(255) | Required |
| customer_email | VARCHAR(255) | Nullable |
| product_id | TEXT FK | References products |
| product_title | VARCHAR(255) | Denormalized |
| artisan_id | TEXT FK | References artisans |
| quantity | INTEGER | Default 1 |
| price | FLOAT | Required |
| status | VARCHAR(20) | pending/confirmed/shipped/delivered |
| created_at | TIMESTAMP | Auto |
| is_active | BOOLEAN | Default true |

---

## Build Status

```
✓ Next.js build passes with 0 errors, 0 warnings
✓ TypeScript checks pass
✓ All 14 routes generated successfully
```

---

## What Comes Next (Future Work)

### Phase 2 — AI Integration
- AI Image Studio (background removal, enhancement)
- Voice Catalog (speech-to-text → product listing)
- AI Price Recommendation
- pgvector for semantic search

### Phase 3 — Advanced Features
- Real JWT authentication (replace demo localStorage auth)
- Payment integration (Razorpay)
- Delivery tracking
- Redis caching
- Object storage for images (S3/Cloudflare R2)
- Admin moderation panel
- Analytics dashboard with charts

### Phase 4 — Hardening
- Error handling + loading states on all pages
- Offline drafts (mobile)
- Security review
- Performance optimization
- Real device testing
- SIH demo preparation
