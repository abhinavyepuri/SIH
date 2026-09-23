# Aroha — Where Artists Meet the Market

<div align="center">

[![FastAPI](https://img.shields.io/badge/FastAPI-0.110+-009688.svg?style=flat&logo=FastAPI&logoColor=white)](https://fastapi.tiangolo.com)
[![Next.js](https://img.shields.io/badge/Next.js-16.3+-black.svg?style=flat&logo=next.js&logoColor=white)](https://nextjs.org/)
[![Flutter](https://img.shields.io/badge/Flutter-3.x+-02569B.svg?style=flat&logo=flutter&logoColor=white)](https://flutter.dev)
[![PostgreSQL](https://img.shields.io/badge/PostgreSQL-16+-316192.svg?style=flat&logo=postgresql&logoColor=white)](https://www.postgresql.org/)
[![Python](https://img.shields.io/badge/Python-3.12+-3776AB.svg?style=flat&logo=python&logoColor=white)](https://www.python.org/)
[![TypeScript](https://img.shields.io/badge/TypeScript-5.x+-3178C6.svg?style=flat&logo=typescript&logoColor=white)](https://www.typescriptlang.org/)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

**A decentralized, AI-empowered digital commerce ecosystem bridging rural master artisans and global connoisseurs.**

[Features](#2-features) • [Architecture](#4-project-architecture) • [App Flow](#5-application-flow) • [Installation](#7-installation-and-setup) • [API Docs](#9-api-documentation) • [Database Design](#10-database-design)

</div>

---

## Table of Contents

- [1. Project Title and Description](#1-project-title-and-description)
- [2. Features](#2-features)
- [3. Tech Stack](#3-tech-stack)
- [4. Project Architecture](#4-project-architecture)
- [5. Application Flow](#5-application-flow)
- [6. Project Structure](#6-project-structure)
- [7. Installation and Setup](#7-installation-and-setup)
- [8. Environment Variables](#8-environment-variables)
- [9. API Documentation](#9-api-documentation)
- [10. Database Design](#10-database-design)
- [11. How to Use](#11-how-to-use)
- [12. Security](#12-security)
- [13. Future Improvements](#13-future-improvements)
- [14. Contributing](#14-contributing)
- [15. License](#15-license)

---

## 1. Project Title and Description

### Overview
**Aroha** (*where artists meet the market*) is an authentic digital marketplace engineered to preserve cultural heritage by connecting master craftsmen, handloom weavers, and folk artists directly with collectors and consumers worldwide.

### The Problem It Solves
1. **Exploitative Middlemen**: Traditional artisans often earn less than 15-20% of the retail price of their handcrafts due to layered broker networks.
2. **Lack of Provenance & GI Authentication**: Counterfeit industrial mass-manufactures dilute authentic Geographical Indication (GI) crafts (e.g., Jaipur Blue Pottery, Chanderi Silk, Bastar Dhokra).
3. **Digital Divide & Complex Onboarding**: Rural craftsmen struggle with complex e-commerce interfaces, foreign languages, and intricate cataloging pipelines.
4. **Opaque Fulfillment**: Customers lack visibility into authentic craft timelines and direct atelier dispatch tracking.

### Purpose and Target Users
- **Master Artisans & Guilds**: Direct studio access to list handcrafted items, manage inventory, track order fulfillment, and withdraw earned revenues with 0% middleman fees.
- **Connoisseurs & Buyers**: A curated luxury marketplace with verified GI heritage provenance, transparent craft stories, individual piece checkout, and live order tracking.
- **Cultural Administrators & Platform Admins**: Centralized inspection tools for artisan approvals, listing moderation, compliance verification, and ecosystem analytics.

---

## 2. Features

### 🎨 Curated Gallery & Marketplace
- **Heritage Categories**: Categorized exploration across Ceramics & Pottery, Handloom Textiles, Master Woodcraft, Metal & Dhokra casting, and Regional Handicrafts.
- **GI Certification Badges**: Clear badges on authentic regional Geographical Indication crafts with verified provenance.
- **Dynamic Search & Filtering**: Multi-criteria filtering by category, price ranges, in-stock availability, and instant keyword search.

### 🛍️ Flexible Purchasing & Bag Management
- **Instant "Buy Now" Direct Checkout**: Single-click modal checkout for purchasing an individual piece directly without checking out unrelated cart items.
- **Item-Level Cart Checkout**: Each cart card features a dedicated `Order This Piece` action that dispatches the order to the artisan and automatically clears that specific item from the bag.
- **Wishlist Management**: Real-time persistent favoriting system for connoisseurs to curate personal collections.

### 💳 Secure Multi-Gateway Payment System
- **Stripe Checkout Integration**: Seamless card and international payment processing via secure Stripe Checkout Sessions and automatic signature-verified webhooks.
- **Dev-Mode Mock Gateway**: Zero-friction local development bypass allowing end-to-end testing without mandatory external API keys.
- **Cash on Delivery (COD)**: First-class support for verified cash-on-delivery orders.
- **India Payment Gateway Architecture**: Pluggable backend architecture with ready schemas and stubs for PhonePe and Paytm.

### 📦 Interactive Live Order Tracking
- **Handcrafting Lifecycle Timeline**: Step-by-step tracking from *Order Placed* → *Handcrafting in Atelier* → *Shipped with GI Seal* → *Delivered to Connoisseur*.
- **Role-Aware Order Views**: Customers track their personal purchases, while artisans manage fulfillment stages with direct status updates (`pending`, `confirmed`, `shipped`, `delivered`).

### 🧑‍🎨 Artisan Creator Studio & Atelier Dashboard
- **KPI Metrics Grid**: Live tracking of Gross Revenue, Active Handcrafts, Pending Fulfillments, and Atelier Views.
- **Product Cataloging**: Rapid item creation with image upload support (Cloudinary cloud storage with automatic local filesystem fallback), material tagging, and crafting stories.
- **Earnings & Financial Insights**: 6-month visual revenue bar charts, recent transactions list, and instant payout withdrawal modals.

### 🛡️ Administrative Portal
- **Ecosystem Analytics**: High-level platform metrics tracking verified artisans, active products, total transaction volumes, and order fulfillment ratios.
- **Artisan & Product Moderation**: Approval workflow for incoming artisan registrations and catalog submissions.

---

## 3. Tech Stack

| Layer | Technology | Purpose |
|:---|:---|:---|
| **Web Frontend** | Next.js 16 (App Router), React 19, TypeScript, Tailwind CSS, Turbopack | Responsive web marketplace, customer checkout, artisan studio & admin portal |
| **Mobile Frontend** | Flutter 3.x, Dart | Cross-platform mobile app with heritage luxury UI palette (Terracotta `#9E3A33`, Navy `#1A2B4C`, Gold `#C5A059`) |
| **Backend API** | FastAPI (Python 3.12+), Pydantic v2, Uvicorn | High-performance asynchronous REST API, business logic, route handlers |
| **Database & ORM** | PostgreSQL 16 / SQLite, SQLAlchemy ORM | Relational schema modeling, automated table generation, migrations |
| **Authentication** | Role-based JWT (PyJWT), bcrypt | Secure password hashing, stateless Bearer token authorization across customer, artisan, and admin roles |
| **Payments** | Stripe API, Stripe Webhooks | Secure card checkout sessions, transaction ledger, webhook event verification |
| **Media Storage** | Cloudinary API, Local File System | Optimized cloud CDN media storage with automated fallback for local dev |
| **Tooling & DevOps**| Docker Compose, ESLint, Flutter Test | Containerized database and cache orchestration, automated linting and test suites |

---

## 4. Project Architecture

```mermaid
graph TB
    subgraph Clients["Client Layer"]
        Web["Next.js 16 Web Application<br/>(Marketplace, Studio, Admin)"]
        Mobile["Flutter Mobile Application<br/>(iOS & Android)"]
    end

    subgraph Gateway["API & Security Layer"]
        API["FastAPI REST API Server<br/>(Port 8000)"]
        AuthGuard["JWT Auth & Role Guard<br/>(Customer / Artisan / Admin)"]
        CORS["CORS & Static Files Middleware"]
    end

    subgraph Services["Core Business Services"]
        AuthService["Auth & Registration Service<br/>(bcrypt)"]
        ProductService["Product & Catalog Engine"]
        OrderService["Order & Fulfillment Engine"]
        PaymentService["Stripe Payment Service<br/>(Sessions & Webhooks)"]
        MediaService["Cloudinary / Storage Service"]
    end

    subgraph Data["Persistence & External Services"]
        DB[(PostgreSQL 16 / SQLite<br/>SQLAlchemy ORM)]
        StripeExt["Stripe API & Webhook Service"]
        CloudinaryExt["Cloudinary CDN"]
    end

    Web -->|HTTP / REST| API
    Mobile -->|HTTP / REST| API

    API --> CORS
    CORS --> AuthGuard
    AuthGuard --> AuthService
    AuthGuard --> ProductService
    AuthGuard --> OrderService
    AuthGuard --> PaymentService
    AuthGuard --> MediaService

    AuthService --> DB
    ProductService --> DB
    OrderService --> DB
    PaymentService --> DB

    PaymentService --> StripeExt
    MediaService --> CloudinaryExt
```

---

## 5. Application Flow

### Complete Order & Payment Lifecycle Flow

```mermaid
sequenceDiagram
    autonumber
    actor Customer as Connoisseur (Customer)
    participant Client as Web / Mobile Client
    participant API as FastAPI Backend (/api/v1)
    participant DB as Relational Database
    participant Stripe as Stripe Payment Gateway
    actor Artisan as Master Artisan

    Customer->>Client: Selects piece & clicks "Buy Now" / "Order This Piece"
    Client->>API: POST /api/v1/orders/ (with customer info, product_id, price, qty)
    API->>DB: Check stock availability & insert Order record (status: 'pending')
    DB-->>API: Returns new Order (id: ORD-XXXX)
    
    alt Stripe Card Checkout
        Client->>API: POST /api/v1/payment/create-checkout-session
        API->>Stripe: stripe.checkout.Session.create(...)
        Stripe-->>API: Returns session.url & session_id
        API->>DB: Insert Payment record (status: 'pending')
        API-->>Client: Returns checkout URL
        Client->>Customer: Redirects to Stripe Checkout
        Customer->>Stripe: Completes payment
        Stripe->>API: POST /api/v1/payment/webhook (checkout.session.completed)
        API->>DB: Update Payment (status: 'paid') & Order (status: 'confirmed')
        API->>DB: Decrement product stock & update artisan revenue
    else Cash on Delivery (COD)
        API->>DB: Insert Order directly (status: 'confirmed')
        API-->>Client: Order confirmed immediately
    end

    Client->>Client: Remove purchased item from local Cart
    Client->>Customer: Displays Confirmation Dialog with tracking link
    
    Artisan->>API: GET /api/v1/orders/ (artisan authenticated)
    API->>DB: Query orders where artisan_id = current_artisan.id
    DB-->>API: Returns order records
    API-->>Artisan: Displays in Artisan Studio Orders Dashboard
    
    Artisan->>API: PUT /api/v1/orders/{order_id}/status (status: 'shipped')
    API->>DB: Updates order status
    Customer->>API: GET /api/v1/orders/
    API-->>Customer: Returns updated timeline ('Shipped with GI Seal')
```

---

## 6. Project Structure

```text
SIH_basic/
├── apps/
│   ├── api/                        # FastAPI Python backend application
│   │   ├── src/
│   │   │   ├── app/
│   │   │   │   ├── api/routes/     # REST API route handlers
│   │   │   │   │   ├── artisan.py  # Artisan profiles, stats, and catalog
│   │   │   │   │   ├── auth.py     # Auth check, login, and registration (JWT + bcrypt)
│   │   │   │   │   ├── order.py    # Order creation, list, and status transitions
│   │   │   │   │   ├── payment.py  # Stripe sessions, webhooks, and PG stubs
│   │   │   │   │   └── product.py  # Product listings, marketplace search, uploads
│   │   │   │   ├── core/
│   │   │   │   │   └── security.py # JWT token creation/decoding and role dependencies
│   │   │   │   ├── models/         # SQLAlchemy database models
│   │   │   │   │   ├── artisan.py  # Artisan table model
│   │   │   │   │   ├── customer.py # Customer table model
│   │   │   │   │   ├── order.py    # Order table model
│   │   │   │   │   ├── payment.py  # Payment table model
│   │   │   │   │   └── product.py  # Product table model
│   │   │   │   ├── schemas/        # Pydantic request and response schemas
│   │   │   │   │   ├── artisan.py
│   │   │   │   │   ├── auth.py
│   │   │   │   │   ├── order.py
│   │   │   │   │   ├── payment.py
│   │   │   │   │   └── product.py
│   │   │   │   ├── services/       # Cloudinary and external service adapters
│   │   │   │   │   └── cloudinary_service.py
│   │   │   │   ├── config.py       # Pydantic settings loading from .env
│   │   │   │   ├── database.py     # Database engine & session maker
│   │   │   │   └── main.py         # App factory, CORS, static mounts, lifespan
│   │   │   └── ...
│   │   ├── requirements.txt        # Python backend dependencies
│   │   └── uploads/                # Local file fallback directory for uploads
│   │
│   ├── web/                        # Next.js 16 Web Application
│   │   ├── src/
│   │   │   ├── app/                # Next.js App Router pages
│   │   │   │   ├── (artisan)/      # Artisan Atelier routes (dashboard, products, orders)
│   │   │   │   ├── (customer)/     # Connoisseur marketplace routes (explore, cart, wishlist)
│   │   │   │   ├── admin/          # Admin management routes (artisans, products, analytics)
│   │   │   │   ├── login/          # Role-based login and registration page
│   │   │   │   ├── payment-success/# Post-checkout payment verification page
│   │   │   │   ├── layout.tsx      # Root layout with Playfair/Inter typography and providers
│   │   │   │   └── page.tsx        # Public landing page with curator spotlights
│   │   │   ├── components/         # Modular React UI components
│   │   │   │   ├── admin/          # Admin sidebar and verification widgets
│   │   │   │   ├── artisan/        # Artisan studio sidebar, earnings, and product forms
│   │   │   │   ├── explore/        # Customer header, category pills, and filters
│   │   │   │   └── ui/             # ProductCard, Footer, TrustBadges
│   │   │   ├── stores/             # React Context State Providers
│   │   │   │   ├── AuthContext.tsx # User session, JWT storage, role state
│   │   │   │   ├── CartContext.tsx # Persistent shopping bag state
│   │   │   │   └── WishlistContext.tsx # Persistent wishlist state
│   │   │   └── types/              # TypeScript data contract interfaces
│   │   ├── package.json
│   │   └── tailwind.config.ts
│   │
│   └── mobile/                     # Flutter Native Mobile Application
│       ├── lib/
│       │   ├── core/               # App constants, luxury colors, themes, API client
│       │   │   ├── constants/      # AppColors (Terracotta, Navy, Gold) & AppConstants
│       │   │   ├── network/        # ApiClient with base URL and error handlers
│       │   │   ├── state/          # AppState, AuthProvider, CartProvider, WishlistProvider
│       │   │   └── theme/          # AppTheme ThemeData definitions
│       │   ├── features/           # Feature-first Flutter modules
│       │   │   ├── artisan/        # ArtisanDashboard, Posts, Orders, Earnings
│       │   │   ├── auth/           # Login / Registration screens
│       │   │   ├── cart/           # Shopping Cart with per-item checkout
│       │   │   ├── explore/        # Curated Gallery with search & filters
│       │   │   ├── home/           # CustomerMainNav with bottom tab navigation
│       │   │   ├── onboarding/     # WelcomeScreen with dual role switcher
│       │   │   ├── orders/         # OrdersScreen with interactive timeline tracking
│       │   │   ├── products/       # ProductDetailScreen with direct Buy Now sheet
│       │   │   └── wishlist/       # WishlistScreen
│       │   ├── models/             # Product, Order, Artisan data models
│       │   ├── shared/widgets/     # AppDrawer, CustomButton, CustomTextField
│       │   └── main.dart           # ArohaApp Flutter entrypoint
│       ├── pubspec.yaml
│       └── test/                   # Automated widget test suites
│
├── database/                       # Database schema definition files
├── infrastructure/                 # Nginx, Docker, and deployment infrastructure
├── docker-compose.yml              # Local PostgreSQL 16 & Redis 7 services
└── README.md                       # Project master documentation
```

---

## 7. Installation and Setup

### Prerequisites
Make sure the following tools are installed on your workstation:
- **Python**: `3.11+` or `3.12+`
- **Node.js**: `18.x+` (LTS) or `20.x+` and `npm` / `pnpm`
- **Flutter SDK**: `3.x+` (with Android Studio / Xcode for emulators)
- **Docker & Docker Compose**: (Optional, for running containerized PostgreSQL)

---

### Step 1: Clone the Repository
```bash
git clone https://github.com/likhithsai007/SIH_basic.git
cd SIH_basic
```

---

### Step 2: Start Infrastructure (PostgreSQL & Redis)
If using Docker, start the database service:
```bash
docker compose up -d
```
> *Note: If running without Docker, you can use a local PostgreSQL instance or configure SQLite in `.env`.*

---

### Step 3: Backend API Setup (FastAPI)

1. Navigate to the API directory:
   ```bash
   cd apps/api
   ```

2. Create and activate a Python virtual environment:
   ```bash
   # Windows (PowerShell)
   python -m venv .venv
   .venv\Scripts\activate

   # macOS / Linux
   python3 -m venv .venv
   source .venv/bin/activate
   ```

3. Install required Python packages:
   ```bash
   pip install -r requirements.txt
   ```

4. Configure environment variables:
   ```bash
   cp ../../.env.example .env
   # Edit .env with your database credentials and secrets (or use defaults)
   ```

5. Launch the FastAPI development server:
   ```bash
   uvicorn src.app.main:app --reload --host 0.0.0.0 --port 8000
   ```

- **API Base URL**: `http://localhost:8000`
- **Interactive Swagger Documentation**: `http://localhost:8000/docs`
- **Health Check Endpoint**: `http://localhost:8000/health`

---

### Step 4: Web Application Setup (Next.js 16)

1. Open a new terminal and navigate to `apps/web`:
   ```bash
   cd apps/web
   ```

2. Install Node dependencies:
   ```bash
   npm install
   ```

3. Start the Next.js development server:
   ```bash
   npm run dev
   ```

- **Web Marketplace URL**: `http://localhost:3000`
- **Artisan Studio Portal**: `http://localhost:3000/artisan/dashboard`
- **Admin Inspector Portal**: `http://localhost:3000/admin/dashboard`

---

### Step 5: Mobile Application Setup (Flutter)

1. Open a new terminal and navigate to `apps/mobile`:
   ```bash
   cd apps/mobile
   ```

2. Fetch Flutter dependencies:
   ```bash
   flutter pub get
   ```

3. Verify codebase health and tests:
   ```bash
   flutter analyze
   flutter test
   ```

4. Run the app on a connected device or emulator:
   ```bash
   flutter run
   ```

---

## 8. Environment Variables

Create a `.env` file in the root directory and/or `apps/api/.env`. Here are the configuration variables:

| Variable | Required | Default / Example | Purpose |
|:---|:---:|:---|:---|
| `APP_ENV` | No | `development` | Environment mode (`development`, `production`, `test`) |
| `DATABASE_URL` | Yes | `postgresql+psycopg://postgres:postgres@localhost:5432/sih26090` | Full PostgreSQL / SQLite database connection URI |
| `JWT_SECRET` | Yes | `your-secret-key-min-32-chars` | Cryptographic secret for signing and verifying JWT tokens |
| `JWT_ALGORITHM` | No | `HS256` | Algorithm used for JWT encoding |
| `ADMIN_EMAIL` | Yes | `admin@gmail.com` | Master administrative superuser email |
| `ADMIN_PASSWORD` | Yes | `admin123` | Master administrative superuser password |
| `STRIPE_SECRET_KEY` | Yes | `sk_test_...` (or mock key) | Stripe secret API key for creating Checkout Sessions |
| `STRIPE_PUBLISHABLE_KEY` | Yes | `pk_test_...` | Stripe publishable client key |
| `STRIPE_WEBHOOK_SECRET` | Yes | `whsec_...` | Stripe webhook signing secret for event verification |
| `CLOUDINARY_CLOUD_NAME` | Optional | `your_cloud_name` | Cloudinary account cloud name for media storage |
| `CLOUDINARY_API_KEY` | Optional | `your_api_key` | Cloudinary API key |
| `CLOUDINARY_API_SECRET` | Optional | `your_api_secret` | Cloudinary API secret |
| `PHONEPE_MERCHANT_ID` | Optional | `MERCHANTUAT` | Merchant identifier for PhonePe PG |
| `PHONEPE_SALT_KEY` | Optional | `your_salt_key` | Salt key for PhonePe payload hashing |
| `PAYTM_MID` | Optional | `YOUR_MID` | Paytm Merchant Identifier |
| `PAYTM_MERCHANT_KEY` | Optional | `your_paytm_key` | Paytm merchant security key |

---

## 9. API Documentation

All endpoints are versioned under the `/api/v1` prefix.

### 1. Authentication Endpoints (`/api/v1/auth`)

| Method | Endpoint | Auth | Description |
|:---|:---|:---:|:---|
| `POST` | `/api/v1/auth/check-email` | None | Check whether an email already exists for a specified role (`artisan`, `customer`, `admin`) |
| `POST` | `/api/v1/auth/register/artisan` | None | Register a new master artisan with category, location, languages, and password |
| `POST` | `/api/v1/auth/register/customer` | None | Register a new customer account |
| `POST` | `/api/v1/auth/login` | None | Authenticate user credentials and receive a role-aware JWT token |

#### Example: Register Artisan Request
```json
POST /api/v1/auth/register/artisan
Content-Type: application/json

{
  "name": "Ram Narayan Sharma",
  "email": "ram.sharma@aroha.in",
  "password": "SecurePassword123!",
  "location": "Jaipur, Rajasthan",
  "craft_category": "Ceramics",
  "languages": ["Hindi", "English", "Rajasthani"],
  "business_type": "Master Craftsman",
  "phone": "+91 98765 43210"
}
```

---

### 2. Products & Catalog Endpoints (`/api/v1/products`)

| Method | Endpoint | Auth | Description |
|:---|:---|:---:|:---|
| `GET` | `/api/v1/products/marketplace` | None | Public marketplace listing (filtered by `category`, `search`, `status=published`) |
| `GET` | `/api/v1/products/` | None | List products with query filtering (`status`, `category`, `artisan_id`) |
| `GET` | `/api/v1/products/{product_id}` | None | Retrieve full details of a specific handcrafted piece |
| `POST` | `/api/v1/products/` | Artisan | Create a new product listing (enforces artisan identity from JWT) |
| `PUT` | `/api/v1/products/{product_id}` | Artisan | Update existing product details (artisan ownership verified) |
| `DELETE` | `/api/v1/products/{product_id}` | Artisan | Soft delete product (`is_active = False`) |
| `POST` | `/api/v1/products/upload` | None | Upload product imagery to Cloudinary CDN (with local fallback) |
| `GET` | `/api/v1/products/stats` | None | Aggregate count of published and draft products |

---

### 3. Orders & Tracking Endpoints (`/api/v1/orders`)

| Method | Endpoint | Auth | Description |
|:---|:---|:---:|:---|
| `POST` | `/api/v1/orders/` | Customer | Create a new purchase order for a piece with automatic stock check |
| `GET` | `/api/v1/orders/` | User | List orders scoped to the authenticated role (Customer sees their purchases, Artisan sees incoming atelier orders, Admin sees all) |
| `GET` | `/api/v1/orders/{order_id}` | None | Get specific order metadata |
| `PUT` | `/api/v1/orders/{order_id}/status` | None | Transition fulfillment status (`pending` → `confirmed` → `shipped` → `delivered`) with automatic inventory decrement |
| `GET` | `/api/v1/orders/stats` | None | Get platform-wide order counts and total transaction volume |

---

### 4. Payments Endpoints (`/api/v1/payment`)

| Method | Endpoint | Auth | Description |
|:---|:---|:---:|:---|
| `POST` | `/api/v1/payment/create-checkout-session` | None | Initialize Stripe Checkout Session (or Dev Mode instant payment) |
| `POST` | `/api/v1/payment/webhook` | Stripe Sig | Handle `checkout.session.completed` to mark orders confirmed |
| `GET` | `/api/v1/payment/status/{session_id}` | None | Check payment settlement status by Stripe session ID |

---

## 10. Database Design

```mermaid
erDiagram
    ARTISANS {
        string id PK "ART-XXXXXX"
        string name
        string email UK
        string password_hash
        string location
        string craft_category
        array languages
        string business_type
        string verification_status "pending | approved"
        string phone
        string profile_image
        float total_revenue
        datetime created_at
        boolean is_active
    }

    CUSTOMERS {
        string id PK "CUS-XXXXXX"
        string name
        string email UK
        string password_hash
        string phone
        datetime created_at
        boolean is_active
    }

    PRODUCTS {
        string id PK "PRD-XXXXXX"
        string artisan_id FK
        string title
        text description
        string category
        string materials
        float price
        string currency
        int quantity
        text tags
        text images
        string status "draft | published | sold"
        text crafting_process
        datetime created_at
        boolean is_active
    }

    ORDERS {
        string id PK "ORD-XXXXXX"
        string customer_name
        string customer_email
        string product_id FK
        string product_title
        string artisan_id FK
        int quantity
        float price
        string status "pending | confirmed | shipped | delivered"
        datetime created_at
        boolean is_active
    }

    PAYMENTS {
        string id PK "PAY-XXXXXX"
        string order_id FK
        string stripe_session_id UK
        float amount
        string currency
        string status "pending | paid | failed"
        string customer_email
        datetime created_at
    }

    ARTISANS ||--o{ PRODUCTS : "creates & catalogs"
    ARTISANS ||--o{ ORDERS : "receives & fulfills"
    CUSTOMERS ||--o{ ORDERS : "places"
    PRODUCTS ||--o{ ORDERS : "ordered in"
    ORDERS ||--o| PAYMENTS : "settled via"
```

---

## 11. How to Use

### A. Connoisseur (Customer) Workflow
1. **Explore**: Open the marketplace at `http://localhost:3000` (or the mobile app) and browse curated categories like *Ceramics & Pottery*, *Handloom Textiles*, and *Woodworking*.
2. **Inspect Heritage Details**: Open any product to review authentic crafting processes, GI certifications, materials, and artisan provenance.
3. **Instant Purchase**:
   - Click **Buy Now** to open the single-piece direct checkout sheet.
   - Enter your delivery name and select payment method (Stripe card or Cash on Delivery).
   - Upon confirmation, the item is ordered and automatically removed from your cart.
4. **Live Tracking**: Open the **Orders** tab to monitor your order moving through *Handcrafting in Atelier*, *Shipped with GI Seal*, and *Delivered*.

### B. Master Artisan Workflow
1. **Onboarding**: Navigate to `/login?role=artisan` and register with your craft category, region, and spoken languages.
2. **Cataloging Handcrafts**: Go to **Artisan Studio** → **Add New Work**. Upload high-resolution photos of your piece, specify materials, and publish to the public gallery.
3. **Order Fulfillment**: Review incoming orders under the **Orders** tab. Update status to `confirmed` as you begin crafting and `shipped` upon handover to insured logistics.
4. **Earnings & Analytics**: Monitor gross craft revenue and monthly trends in the **Earnings** tab.

### C. Administrator Workflow
1. **Sign In**: Login via `/login?role=admin` with the configured administrative credentials.
2. **Verify & Moderate**: Review pending artisan onboarding requests and approve legitimate GI craft masters.
3. **Platform Oversight**: Inspect high-level metrics, active order fulfillment rates, and transaction volume.

---

## 12. Security

- **Role-Based Access Control (RBAC)**: Enforced via FastAPI dependency injection (`get_current_user`, `get_current_artisan`, `get_current_customer`). Endpoints mutating products or orders strictly verify the owner's identity against the decoded JWT subject.
- **Cryptographic Password Hashing**: Passwords are never stored in plaintext and are hashed using industry-standard `bcrypt` with automatic salt generation.
- **Stateless Bearer Tokens**: JSON Web Tokens (JWT) signed with `HS256` and configurable expiration timeframes.
- **Strict Input Validation**: All payloads are validated using Pydantic v2 schemas on the backend and TypeScript interfaces / Dart models on the clients.
- **SQL Injection Defense**: All database queries utilize SQLAlchemy ORM parameterized queries to prevent SQL injection vulnerabilities.
- **Stripe Webhook Verification**: Stripe webhook endpoints verify incoming cryptographic signatures (`Stripe-Signature`) using `STRIPE_WEBHOOK_SECRET` before processing fulfillment webhooks.

---

## 13. Future Improvements

- [ ] **Vernacular AI Voice Studio**: Direct voice-to-text craft listing in 8+ Indian regional languages (Hindi, Telugu, Tamil, Bengali, Marathi, Gujarati) using multilingual speech recognition.
- [ ] **Real-Time Atelier Messaging**: WebSocket-based secure communication between connoisseurs and master artisans for bespoke custom commissions.
- [ ] **On-Chain GI Authenticity Certificates**: Tamper-proof digital certificates of authenticity minted on a low-carbon public ledger for verified GI artifacts.
- [ ] **Full Indian Payment SDK Integration**: Production wiring for PhonePe and Paytm SDKs alongside Stripe.
- [ ] **Offline-First Artisan Sync**: Local SQLite sync on the Flutter mobile client for artisans working in remote areas with intermittent connectivity.

---

## 14. Contributing

Contributions to Aroha are warmly welcomed! Please follow these steps:

1. **Fork the Repository**
2. **Create a Feature Branch**:
   ```bash
   git checkout -b feature/heritage-craft-enhancement
   ```
3. **Commit Your Changes**:
   ```bash
   git commit -m "feat: add regional craft tag filter"
   ```
4. **Run Verification Suites**:
   ```bash
   # In apps/mobile
   flutter analyze && flutter test

   # In apps/web
   npm run build
   ```
5. **Push to Your Branch**:
   ```bash
   git push origin feature/heritage-craft-enhancement
   ```
6. **Open a Pull Request** with a detailed summary of your changes.

---

## 15. License

This project is licensed under the **MIT License** — see the [LICENSE](LICENSE) file for details.

---

<div align="center">

**Aroha** — *where artists meet the market*  
Crafted with passion to preserve generational artistry and empower rural creators.

</div>

