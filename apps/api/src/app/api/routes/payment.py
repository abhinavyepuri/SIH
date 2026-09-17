import os
import stripe
from pydantic import BaseModel
from fastapi import APIRouter, Depends, HTTPException, Request
from sqlalchemy.orm import Session
from ...database import get_db
from ...models.payment import Payment
from ...models.order import Order
from ...models.artisan import Artisan
from ...schemas.payment import (
    CreateCheckoutSessionRequest,
    CreateCheckoutSessionResponse,
    PaymentStatusResponse,
)

from ...config import settings

router = APIRouter()

STRIPE_SECRET_KEY = settings.STRIPE_SECRET_KEY
STRIPE_WEBHOOK_SECRET = settings.STRIPE_WEBHOOK_SECRET

stripe.api_key = STRIPE_SECRET_KEY

@router.post("/create-checkout-session", response_model=CreateCheckoutSessionResponse)
def create_checkout_session(
    req: CreateCheckoutSessionRequest,
    db: Session = Depends(get_db)
):
    total_amount = sum(item.price * item.quantity for item in req.items)

    # -------------------------------------------------------------------------
    # DEV MODE BYPASS — triggered when using the placeholder/fake Stripe key.
    # Returns a mock checkout URL that goes straight to payment-success.
    # Replace STRIPE_SECRET_KEY in .env with your real key to use live Stripe.
    # -------------------------------------------------------------------------
    is_fake_key = (
        not STRIPE_SECRET_KEY
        or STRIPE_SECRET_KEY.startswith("sk_test_51Mock")
        or "Mock" in STRIPE_SECRET_KEY
    )
    if is_fake_key:
        import uuid
        mock_session_id = f"dev_session_{uuid.uuid4().hex[:16]}"

        # Store a dev payment record so orders still get tracked
        payment_record = Payment(
            order_id=req.order_id,
            stripe_session_id=mock_session_id,
            amount=total_amount,
            currency="inr",
            status="dev_paid",
            customer_email=req.customer_email,
        )
        db.add(payment_record)

        # Mark the order as confirmed in dev mode
        if req.order_id:
            order = db.query(Order).filter(Order.id == req.order_id).first()
            if order:
                order.status = "confirmed"

        db.commit()

        # Redirect to success page with mock session id
        redirect_url = f"{req.success_url}?session_id={mock_session_id}&dev=1"
        return CreateCheckoutSessionResponse(
            checkout_url=redirect_url,
            session_id=mock_session_id,
        )

    # -------------------------------------------------------------------------
    # REAL STRIPE — only runs when a genuine sk_test_ or sk_live_ key is set
    # -------------------------------------------------------------------------
    try:
        stripe_line_items = []
        for item in req.items:
            stripe_line_items.append({
                "price_data": {
                    "currency": "inr",
                    "product_data": {"name": item.name},
                    "unit_amount": int(round(item.price * 100)),
                },
                "quantity": item.quantity,
            })

        session = stripe.checkout.Session.create(
            payment_method_types=["card"],
            line_items=stripe_line_items,
            mode="payment",
            customer_email=req.customer_email or None,
            success_url=f"{req.success_url}?session_id={{CHECKOUT_SESSION_ID}}",
            cancel_url=req.cancel_url,
        )

        payment_record = Payment(
            order_id=req.order_id,
            stripe_session_id=session.id,
            amount=total_amount,
            currency="inr",
            status="pending",
            customer_email=req.customer_email,
        )
        db.add(payment_record)
        db.commit()

        return CreateCheckoutSessionResponse(
            checkout_url=session.url,
            session_id=session.id,
        )

    except stripe.error.AuthenticationError:
        raise HTTPException(
            status_code=400,
            detail="Invalid Stripe secret key. Open apps/api/.env and replace STRIPE_SECRET_KEY with your real key from https://dashboard.stripe.com/test/apikeys"
        )
    except stripe.error.StripeError as e:
        raise HTTPException(status_code=400, detail=f"Stripe error: {str(e)}")
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Checkout session failed: {str(e)}")



@router.post("/webhook")
async def stripe_webhook(request: Request, db: Session = Depends(get_db)):
    payload = await request.body()
    sig_header = request.headers.get("stripe-signature")

    try:
        event = stripe.Webhook.construct_event(
            payload, sig_header, STRIPE_WEBHOOK_SECRET
        )
    except ValueError:
        # Invalid payload
        raise HTTPException(status_code=400, detail="Invalid webhook payload")
    except stripe.error.SignatureVerificationError:
        # Invalid signature
        raise HTTPException(status_code=400, detail="Invalid webhook signature")
    except Exception:
        # Fallback for dev mode testing
        event = stripe.Event.construct_from(
            stripe.json.loads(payload), stripe.api_key
        )

    if event["type"] == "checkout.session.completed":
        session_obj = event["data"]["object"]
        session_id = session_obj.get("id")
        customer_email = session_obj.get("customer_details", {}).get("email")

        payment = db.query(Payment).filter(Payment.stripe_session_id == session_id).first()
        if payment:
            payment.status = "paid"
            if customer_email:
                payment.customer_email = customer_email

            # Update associated Order if order_id is attached
            if payment.order_id:
                order = db.query(Order).filter(Order.id == payment.order_id).first()
                if order:
                    order.status = "confirmed"
                    # Recalculate artisan total revenue
                    if order.artisan_id:
                        artisan = db.query(Artisan).filter(Artisan.id == order.artisan_id).first()
                        if artisan:
                            artisan_orders = db.query(Order).filter(
                                Order.artisan_id == order.artisan_id,
                                Order.status != "pending"
                            ).all()
                            artisan.total_revenue = sum(o.price * o.quantity for o in artisan_orders)
            db.commit()

    return {"status": "success"}


@router.get("/status/{session_id}", response_model=PaymentStatusResponse)
def get_payment_status(session_id: str, db: Session = Depends(get_db)):
    payment = db.query(Payment).filter(Payment.stripe_session_id == session_id).first()
    if not payment:
        raise HTTPException(status_code=404, detail="Payment record not found")
    return payment


# ---------------------------------------------------------------------------
# PhonePe  (stub — activate by adding PHONEPE_MERCHANT_ID + PHONEPE_SALT_KEY)
# ---------------------------------------------------------------------------
class PhonePeRequest(BaseModel):
    order_id: str | None = None
    amount: float
    customer_email: str
    customer_name: str
    success_url: str
    cancel_url: str

@router.post("/phonepe/initiate")
def phonepe_initiate(req: PhonePeRequest, db: Session = Depends(get_db)):
    merchant_id = getattr(settings, "PHONEPE_MERCHANT_ID", None)
    salt_key    = getattr(settings, "PHONEPE_SALT_KEY", None)

    if not merchant_id or not salt_key:
        raise HTTPException(
            status_code=501,
            detail=(
                "PhonePe is not configured. "
                "Add PHONEPE_MERCHANT_ID and PHONEPE_SALT_KEY to apps/api/.env "
                "from https://developer.phonepe.com/v1/reference/pay-api"
            ),
        )

    # TODO: once keys are set, replace the block below with real PhonePe SDK call
    # import phonepesdk  →  phonepesdk.initiate_payment(...)
    raise HTTPException(status_code=501, detail="PhonePe SDK integration pending — keys provided but SDK not wired yet.")


# ---------------------------------------------------------------------------
# Paytm  (stub — activate by adding PAYTM_MID + PAYTM_MERCHANT_KEY)
# ---------------------------------------------------------------------------
class PaytmRequest(BaseModel):
    order_id: str | None = None
    amount: float
    customer_email: str
    customer_name: str
    success_url: str
    cancel_url: str

@router.post("/paytm/initiate")
def paytm_initiate(req: PaytmRequest, db: Session = Depends(get_db)):
    mid          = getattr(settings, "PAYTM_MID", None)
    merchant_key = getattr(settings, "PAYTM_MERCHANT_KEY", None)

    if not mid or not merchant_key:
        raise HTTPException(
            status_code=501,
            detail=(
                "Paytm is not configured. "
                "Add PAYTM_MID and PAYTM_MERCHANT_KEY to apps/api/.env "
                "from https://developer.paytm.com/docs/"
            ),
        )

    # TODO: once keys are set, replace with real Paytm PG SDK call
    # import paytmchecksum  →  paytmchecksum.generateSignature(...)
    raise HTTPException(status_code=501, detail="Paytm SDK integration pending — keys provided but SDK not wired yet.")
