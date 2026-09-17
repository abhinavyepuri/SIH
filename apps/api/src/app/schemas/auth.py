from pydantic import BaseModel
from typing import Optional


class CheckEmailRequest(BaseModel):
    email: str
    role: str


class CheckEmailResponse(BaseModel):
    exists: bool
    role: str


class ArtisanRegisterRequest(BaseModel):
    email: str
    password: str
    name: str
    location: str
    craft_category: str
    languages: list[str]
    business_type: str
    phone: Optional[str] = None


class CustomerRegisterRequest(BaseModel):
    email: str
    password: str
    name: str
    phone: Optional[str] = None


class LoginRequest(BaseModel):
    email: str
    password: str
    role: str


class AuthResponse(BaseModel):
    id: str
    name: str
    email: str
    role: str
    token: str
