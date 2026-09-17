import uuid
from datetime import datetime
from sqlalchemy import Column, String, DateTime, Float
from ..database import Base


def generate_payment_id():
    return f"PAY{uuid.uuid4().hex[:6].upper()}"


class Payment(Base):
    __tablename__ = "payments"

    id = Column(String, primary_key=True, default=generate_payment_id)
    order_id = Column(String, nullable=True)
    stripe_session_id = Column(String(255), unique=True, nullable=False)
    amount = Column(Float, nullable=False)
    currency = Column(String(10), default="inr")
    status = Column(String(20), default="pending")  # pending, paid, failed, cancelled
    customer_email = Column(String(255), nullable=True)
    created_at = Column(DateTime, default=datetime.utcnow)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)
