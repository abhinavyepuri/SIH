import uuid
from datetime import datetime
from sqlalchemy import Column, String, DateTime, Boolean, Float, Integer, Text

from ..database import Base


def generate_product_id():
    return f"PRD{uuid.uuid4().hex[:6].upper()}"


class Product(Base):
    __tablename__ = "products"

    id = Column(String, primary_key=True, default=generate_product_id)
    artisan_id = Column(String, nullable=False)
    title = Column(String(255), nullable=False)
    description = Column(Text, nullable=True)
    category = Column(String(100), nullable=False)
    materials = Column(String(500), nullable=True)
    price = Column(Float, nullable=False)
    currency = Column(String(10), default="INR")
    quantity = Column(Integer, default=1)
    tags = Column(Text, nullable=True)  # comma-separated
    images = Column(Text, nullable=True)  # comma-separated URLs
    status = Column(String(20), default="draft")  # draft, published, sold
    crafting_process = Column(Text, nullable=True)
    created_at = Column(DateTime, default=datetime.utcnow)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)
    is_active = Column(Boolean, default=True)
