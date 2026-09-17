import uuid
from datetime import datetime
from sqlalchemy import Column, String, DateTime, Boolean, JSON, Float
from sqlalchemy.dialects.postgresql import ARRAY

from ..database import Base


def generate_artisan_id():
    return f"ART{uuid.uuid4().hex[:6].upper()}"


class Artisan(Base):
    __tablename__ = "artisans"

    id = Column(String, primary_key=True, default=generate_artisan_id)
    name = Column(String(255), nullable=False)
    location = Column(String(255), nullable=False)
    craft_category = Column(String(100), nullable=False)
    languages = Column(ARRAY(String), nullable=False, default=[])
    business_type = Column(String(50), nullable=False)
    verification_status = Column(String(20), default="pending")
    phone = Column(String(20), nullable=True)
    email = Column(String(255), unique=True, nullable=True)
    password_hash = Column(String(255), nullable=True)
    profile_image = Column(String(500), nullable=True)
    total_revenue = Column(Float, default=0.0)
    created_at = Column(DateTime, default=datetime.utcnow)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)
    is_active = Column(Boolean, default=True)
