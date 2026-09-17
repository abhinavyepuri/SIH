# Stripe Payment Gateway Integration with FastAPI

## Overview

The simplest Stripe integration for a web application is **Stripe Checkout**. Stripe hosts the payment page, so your application does not directly handle raw card details.

Recommended architecture:

```text
React / Frontend
      |
      | POST /api/payment/create-checkout-session
      v
FastAPI Backend
      |
      | Stripe secret key
      v
Stripe Checkout
      |
      | Customer pays
      v
Stripe
      |
      | Webhook
      v
FastAPI /api/payment/webhook
      |
      v
Update Database -> Payment Successful
```

---

## 1. Create a Stripe Account

Create or access your Stripe account and get your API keys from the Stripe Dashboard.

For development, use **Stripe Test Mode**.

### Important for India

Stripe currently has specific availability and payment-method restrictions for India-based accounts. Check Stripe's current India documentation before deploying to production.

---

## 2. Install Stripe

For a FastAPI/Python backend:

```bash
pip install stripe
```

---

## 3. Configure Environment Variables

Create a `.env` file:

```env
STRIPE_SECRET_KEY=sk_test_xxxxxxxxxxxxx
STRIPE_WEBHOOK_SECRET=whsec_xxxxxxxxxxxxx
```

### Security

Never expose:

```text
STRIPE_SECRET_KEY
```

in frontend code.

The Stripe secret key must remain on the backend.

---

# 4. Create a Stripe Checkout Session

Example FastAPI endpoint:

```python
import stripe
from fastapi import FastAPI

app = FastAPI()

stripe.api_key = "sk_test_xxxxxxxxxxxxx"


@app.post("/api/payment/create-checkout-session")
async def create_checkout_session():

    session = stripe.checkout.Session.create(
        payment_method_types=["card"],
        line_items=[
            {
                "price_data": {
                    "currency": "inr",
                    "product_data": {
                        "name": "Premium Plan"
                    },
                    "unit_amount": 49900,
                },
                "quantity": 1,
            }
        ],
        mode="payment",
        success_url="http://localhost:3000/payment-success",
        cancel_url="http://localhost:3000/payment-cancelled",
    )

    return {
        "checkout_url": session.url
    }
```

## Understanding `unit_amount`

Stripe expects the amount in the smallest currency unit.

For INR:

```text
₹499  -> 49900 paise
₹100  -> 10000 paise
₹999  -> 99900 paise
```

Therefore:

```python
unit_amount=49900
```

means ₹499.

---

# 5. Frontend Payment Button

For React:

```jsx
async function handlePayment() {
    const response = await fetch(
        "http://localhost:8000/api/payment/create-checkout-session",
        {
            method: "POST"
        }
    );

    const data = await response.json();

    window.location.href = data.checkout_url;
}
```

Button:

```jsx
<button onClick={handlePayment}>
    Pay ₹499
</button>
```

The flow is:

```text
User clicks "Pay ₹499"
        |
        v
React calls FastAPI
        |
        v
FastAPI creates Stripe Checkout Session
        |
        v
Stripe returns Checkout URL
        |
        v
Browser redirects to Stripe
        |
        v
User enters payment details
        |
        v
Payment is processed
        |
        v
Stripe redirects to success/cancel page
```

---

# 6. Do Not Trust the Success URL

Do **not** assume that a user reaching:

```text
/payment-success
```

means the payment was successful.

A user could potentially navigate directly to that URL.

Instead, use a **Stripe webhook** to verify payment completion on the backend.

---

# 7. Create a Stripe Webhook

FastAPI example:

```python
from fastapi import Request, HTTPException


@app.post("/api/payment/webhook")
async def stripe_webhook(request: Request):

    payload = await request.body()

    signature = request.headers.get("stripe-signature")

    try:
        event = stripe.Webhook.construct_event(
            payload,
            signature,
            "whsec_xxxxxxxxxxxxx"
        )

    except ValueError:
        raise HTTPException(status_code=400)

    except stripe.error.SignatureVerificationError:
        raise HTTPException(status_code=400)

    if event["type"] == "checkout.session.completed":

        session = event["data"]["object"]

        session_id = session["id"]

        customer_email = session["customer_details"]["email"]

        # Update your database here
        # mark_payment_as_successful(session_id, customer_email)

        print("Payment successful!")
        print("Session:", session_id)
        print("Customer:", customer_email)

    return {"status": "success"}
```

The important event is:

```text
checkout.session.completed
```

Your backend should process this event and update your database.

---

# 8. Local Webhook Testing

Install the Stripe CLI and forward Stripe events to your local FastAPI server:

```bash
stripe listen --forward-to localhost:8000/api/payment/webhook
```

Stripe will provide a webhook signing secret similar to:

```text
whsec_xxxxxxxxxxxxx
```

Put it in your `.env`:

```env
STRIPE_WEBHOOK_SECRET=whsec_xxxxxxxxxxxxx
```

Then test the payment flow.

---

# 9. Database Design

A basic payments table can contain:

```text
payments
--------------------------------
id
user_id
stripe_session_id
amount
currency
status
created_at
```

When the Checkout Session is created:

```text
status = pending
```

After Stripe sends:

```text
checkout.session.completed
```

update it to:

```text
status = paid
```

Recommended flow:

```text
User
 |
 v
Create Checkout Session
 |
 v
Database -> pending
 |
 v
Stripe Payment
 |
 v
Stripe Webhook
 |
 v
FastAPI
 |
 v
Database -> paid
 |
 v
Give user access to product/service
```

---

# 10. Subscriptions

If your application has recurring payments such as:

```text
Free
₹0/month

Pro
₹499/month

Enterprise
₹1999/month
```

use Stripe subscriptions.

Change:

```python
mode="payment"
```

to:

```python
mode="subscription"
```

For a subscription, it is common to create Products and Prices in Stripe and reference the Stripe Price ID:

```python
session = stripe.checkout.Session.create(
    mode="subscription",
    line_items=[
        {
            "price": "price_xxxxxxxxx",
            "quantity": 1
        }
    ],
    success_url="http://localhost:3000/success",
    cancel_url="http://localhost:3000/cancel"
)
```

---

# 11. Recommended API Structure

For a FastAPI application, use approximately these endpoints:

```text
POST /api/payment/create-checkout-session
POST /api/payment/webhook
GET  /api/payment/status/{payment_id}
```

### Endpoint responsibilities

#### `POST /api/payment/create-checkout-session`

Creates a Stripe Checkout Session.

#### `POST /api/payment/webhook`

Receives payment events directly from Stripe and updates the database.

#### `GET /api/payment/status/{payment_id}`

Allows the frontend to retrieve the current payment status.

---

# 12. Recommended Project Architecture

For a typical FastAPI + React application:

```text
project/
│
├── apps/
│   ├── api/
│   │   ├── src/
│   │   │   ├── app/
│   │   │   │   ├── main.py
│   │   │   │   ├── routes/
│   │   │   │   │   └── payment.py
│   │   │   │   ├── services/
│   │   │   │   │   └── stripe_service.py
│   │   │   │   └── models/
│   │   │   │       └── payment.py
│   │   │   └── ...
│   │   └── .env
│   │
│   └── web/
│       ├── src/
│       │   ├── pages/
│       │   │   ├── PaymentSuccess.jsx
│       │   │   └── PaymentCancelled.jsx
│       │   └── components/
│       │       └── PaymentButton.jsx
│       └── ...
```

This keeps Stripe-specific logic inside the backend instead of mixing it into your frontend.

---

# 13. Complete Payment Flow

The final production-style flow should look like:

```text
                     ┌─────────────────┐
                     │     React       │
                     │    Frontend     │
                     └────────┬────────┘
                              │
                              │ Create Checkout Session
                              v
                     ┌─────────────────┐
                     │     FastAPI     │
                     │     Backend     │
                     └────────┬────────┘
                              │
                              │ Stripe Secret Key
                              v
                     ┌─────────────────┐
                     │     Stripe      │
                     │    Checkout     │
                     └────────┬────────┘
                              │
                              │ Customer Payment
                              v
                     ┌─────────────────┐
                     │     Stripe      │
                     │     Webhook     │
                     └────────┬────────┘
                              │
                              v
                     ┌─────────────────┐
                     │     FastAPI     │
                     │  Webhook Route  │
                     └────────┬────────┘
                              │
                              v
                     ┌─────────────────┐
                     │   PostgreSQL    │
                     │ Payment Record  │
                     └─────────────────┘
```

---

# 14. Important Security Rules

1. Never put the Stripe secret key in React.
2. Store keys in environment variables.
3. Never trust the frontend to confirm payment.
4. Verify Stripe webhook signatures.
5. Use Stripe webhooks to update payment status.
6. Store the Stripe Checkout Session ID in your database.
7. Use Stripe Test Mode during development.
8. Make webhook processing idempotent so duplicate webhook events do not create duplicate fulfillment.
9. Validate the product/price on the backend instead of trusting an amount sent by the frontend.
10. Use HTTPS in production.

---

# 15. Recommended Implementation

For a normal web application, start with:

```text
React
   |
   | POST /api/payment/create-checkout-session
   v
FastAPI
   |
   v
Stripe Checkout
   |
   v
Payment
   |
   v
Stripe Webhook
   |
   v
FastAPI
   |
   v
PostgreSQL
```

This is considerably simpler than implementing your own card-payment form and gives Stripe responsibility for the payment UI and sensitive card-data handling.

For a project using **FastAPI + React + PostgreSQL**, this is the architecture I would recommend starting with.
