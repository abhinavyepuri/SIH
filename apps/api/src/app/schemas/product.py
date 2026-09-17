from pydantic import BaseModel
from typing import List, Optional
from datetime import datetime


class ProductCreate(BaseModel):
    artisan_id: str
    title: str
    description: Optional[str] = None
    category: str
    materials: Optional[str] = None
    price: float
    currency: str = "INR"
    quantity: int = 1
    tags: Optional[str] = None
    images: Optional[str] = None
    status: str = "draft"
    crafting_process: Optional[str] = None


class ProductResponse(BaseModel):
    id: str
    artisan_id: str
    title: str
    description: Optional[str] = None
    category: str
    materials: Optional[str] = None
    price: float
    currency: str
    quantity: int
    tags: Optional[str] = None
    images: Optional[str] = None
    status: str
    crafting_process: Optional[str] = None
    created_at: datetime
    is_active: bool

    model_config = {"from_attributes": True}


class ProductListResponse(BaseModel):
    products: List[ProductResponse]
    total: int
