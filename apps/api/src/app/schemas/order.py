from pydantic import BaseModel
from typing import List
from datetime import datetime


class OrderCreate(BaseModel):
    customer_name: str | None = None
    customer_email: str | None = None
    product_id: str
    product_title: str
    artisan_id: str
    quantity: int = 1
    price: float


class OrderResponse(BaseModel):
    id: str
    customer_name: str
    customer_email: str | None = None
    product_id: str
    product_title: str
    artisan_id: str
    quantity: int
    price: float
    status: str
    created_at: datetime
    is_active: bool

    model_config = {"from_attributes": True}


class OrderListResponse(BaseModel):
    orders: List[OrderResponse]
    total: int
