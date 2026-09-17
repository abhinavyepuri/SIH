from pydantic import BaseModel
from typing import Optional, List


class LineItem(BaseModel):
    name: str
    price: float
    quantity: int = 1
    image_url: Optional[str] = None


class CreateCheckoutSessionRequest(BaseModel):
    items: List[LineItem]
    order_id: Optional[str] = None
    customer_email: Optional[str] = None
    success_url: Optional[str] = "http://localhost:3000/payment-success"
    cancel_url: Optional[str] = "http://localhost:3000/payment-cancelled"


class CreateCheckoutSessionResponse(BaseModel):
    checkout_url: str
    session_id: str


class PaymentStatusResponse(BaseModel):
    id: str
    order_id: Optional[str] = None
    stripe_session_id: str
    amount: float
    currency: str
    status: str
    customer_email: Optional[str] = None
