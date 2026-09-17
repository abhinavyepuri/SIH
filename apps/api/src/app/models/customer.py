import uuid
from datetime import datetime
from sqlalchemy import Column, String, DateTime, Boolean
from ..database import Base


def generate_customer_id():
    return f"CUS{uuid.uuid4().hex[:6].upper()}"


class Customer(Base):
    __tablename__ = "customers"

    id = Column(String, primary_key=True, default=generate_customer_id)
    name = Column(String(255), nullable=False)
    email = Column(String(255), unique=True, nullable=False)
    phone = Column(String(20), nullable=True)
    password_hash = Column(String(255), nullable=False)
    created_at = Column(DateTime, default=datetime.utcnow)
    is_active = Column(Boolean, default=True)
