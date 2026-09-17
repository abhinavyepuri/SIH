import uuid
from datetime import datetime
from sqlalchemy import Column, String, DateTime, Boolean, Float, Integer, Text

from ..database import Base


def generate_order_id():
    return f"ORD{uuid.uuid4().hex[:6].upper()}"


class Order(Base):
    __tablename__ = "orders"

    id = Column(String, primary_key=True, default=generate_order_id)
    customer_name = Column(String(255), nullable=False)
    customer_email = Column(String(255), nullable=True)
    product_id = Column(String, nullable=False)
    product_title = Column(String(255), nullable=False)
    artisan_id = Column(String, nullable=False)
    quantity = Column(Integer, default=1)
    price = Column(Float, nullable=False)
    status = Column(String(20), default="pending")  # pending, confirmed, shipped, delivered
    created_at = Column(DateTime, default=datetime.utcnow)
    is_active = Column(Boolean, default=True)
