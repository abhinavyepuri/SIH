import bcrypt
from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from sqlalchemy import func

from ...database import get_db
from ...models.artisan import Artisan
from ...models.customer import Customer
from ...schemas.auth import (
    CheckEmailRequest, CheckEmailResponse,
    ArtisanRegisterRequest, CustomerRegisterRequest,
    LoginRequest, AuthResponse,
)
from ...config import settings
from ...core.security import create_access_token

router = APIRouter()

ADMIN_EMAIL = settings.ADMIN_EMAIL
ADMIN_PASSWORD = settings.ADMIN_PASSWORD


def hash_password(password: str) -> str:
    return bcrypt.hashpw(password.encode(), bcrypt.gensalt()).decode()


def verify_password(password: str, hashed: str) -> bool:
    return bcrypt.checkpw(password.encode(), hashed.encode())


@router.post("/check-email", response_model=CheckEmailResponse)
def check_email(req: CheckEmailRequest, db: Session = Depends(get_db)):
    email = req.email.strip().lower()
    if req.role == "admin" or email == ADMIN_EMAIL.lower():
        exists = email == ADMIN_EMAIL.lower()
    elif req.role == "artisan":
        exists = (
            db.query(Artisan)
            .filter(func.lower(Artisan.email) == email, Artisan.is_active == True)
            .first() is not None
        )
    elif req.role == "customer":
        exists = (
            db.query(Customer)
            .filter(func.lower(Customer.email) == email, Customer.is_active == True)
            .first() is not None
        )
    else:
        raise HTTPException(status_code=400, detail="Invalid role")
    return CheckEmailResponse(exists=exists, role=req.role)


@router.post("/register/artisan", response_model=AuthResponse)
def register_artisan(req: ArtisanRegisterRequest, db: Session = Depends(get_db)):
    email = req.email.strip().lower()
    if db.query(Artisan).filter(func.lower(Artisan.email) == email).first():
        raise HTTPException(status_code=400, detail="Email already registered")
    artisan = Artisan(
        name=req.name,
        email=email,
        password_hash=hash_password(req.password),
        location=req.location,
        craft_category=req.craft_category,
        languages=req.languages,
        business_type=req.business_type,
        phone=req.phone,
    )
    db.add(artisan)
    db.commit()
    db.refresh(artisan)
    token = create_access_token({"sub": str(artisan.id), "role": "artisan"})
    return AuthResponse(id=artisan.id, name=artisan.name, email=artisan.email, role="artisan", token=token)


@router.post("/register/customer", response_model=AuthResponse)
def register_customer(req: CustomerRegisterRequest, db: Session = Depends(get_db)):
    email = req.email.strip().lower()
    if db.query(Customer).filter(func.lower(Customer.email) == email).first():
        raise HTTPException(status_code=400, detail="Email already registered")
    customer = Customer(
        name=req.name,
        email=email,
        password_hash=hash_password(req.password),
        phone=req.phone,
    )
    db.add(customer)
    db.commit()
    db.refresh(customer)
    token = create_access_token({"sub": str(customer.id), "role": "customer"})
    return AuthResponse(id=customer.id, name=customer.name, email=customer.email, role="customer", token=token)


@router.post("/login", response_model=AuthResponse)
def login(req: LoginRequest, db: Session = Depends(get_db)):
    email = req.email.strip().lower()
    if req.role == "admin" or email == ADMIN_EMAIL.lower():
        if email != ADMIN_EMAIL.lower() or req.password != ADMIN_PASSWORD:
            raise HTTPException(status_code=401, detail="Invalid admin credentials")
        token = create_access_token({"sub": "ADMIN001", "role": "admin"})
        return AuthResponse(id="ADMIN001", name="Admin", email=email, role="admin", token=token)
    if req.role == "artisan":
        user = (
            db.query(Artisan)
            .filter(func.lower(Artisan.email) == email, Artisan.is_active == True)
            .first()
        )
        if not user or not user.password_hash:
            raise HTTPException(status_code=401, detail="Account not found")
        if not verify_password(req.password, user.password_hash):
            raise HTTPException(status_code=401, detail="Invalid password")
        token = create_access_token({"sub": str(user.id), "role": "artisan"})
        return AuthResponse(id=user.id, name=user.name, email=user.email, role="artisan", token=token)
    if req.role == "customer":
        user = (
            db.query(Customer)
            .filter(func.lower(Customer.email) == email, Customer.is_active == True)
            .first()
        )
        if not user:
            raise HTTPException(status_code=401, detail="Account not found")
        if not verify_password(req.password, user.password_hash):
            raise HTTPException(status_code=401, detail="Invalid password")
        token = create_access_token({"sub": str(user.id), "role": "customer"})
        return AuthResponse(id=user.id, name=user.name, email=user.email, role="customer", token=token)
    raise HTTPException(status_code=400, detail="Invalid role")
