from pydantic import BaseModel
from typing import List, Optional
from datetime import datetime


class ArtisanCreate(BaseModel):
    name: str
    location: str
    craft_category: str
    languages: List[str]
    business_type: str


class ArtisanResponse(BaseModel):
    id: str
    name: str
    location: Optional[str] = "N/A"
    craft_category: Optional[str] = "Artisan"
    languages: Optional[List[str]] = []
    business_type: Optional[str] = "Independent"
    verification_status: Optional[str] = "pending"
    phone: Optional[str] = None
    email: Optional[str] = None
    profile_image: Optional[str] = None
    total_revenue: Optional[float] = 0.0
    created_at: Optional[datetime] = None
    is_active: Optional[bool] = True

    model_config = {"from_attributes": True}
