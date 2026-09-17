import jwt
from datetime import datetime, timedelta
from typing import Optional
from fastapi import Depends, HTTPException, status
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials
from sqlalchemy.orm import Session
from ..database import get_db
from ..models.artisan import Artisan
from ..models.customer import Customer
from ..config import settings

security = HTTPBearer()
ALGORITHM = settings.JWT_ALGORITHM
SECRET_KEY = settings.JWT_SECRET

def create_access_token(data: dict, expires_delta: Optional[timedelta] = None):
    to_encode = data.copy()
    if expires_delta:
        expire = datetime.utcnow() + expires_delta
    else:
        expire = datetime.utcnow() + timedelta(days=7)
    to_encode.update({"exp": expire})
    encoded_jwt = jwt.encode(to_encode, SECRET_KEY, algorithm=ALGORITHM)
    return encoded_jwt

def decode_token(token: str):
    try:
        payload = jwt.decode(token, SECRET_KEY, algorithms=[ALGORITHM])
        return payload
    except jwt.ExpiredSignatureError:
        raise HTTPException(status_code=401, detail="Token has expired")
    except jwt.InvalidTokenError:
        raise HTTPException(status_code=401, detail="Invalid token")

def get_current_user(credentials: HTTPAuthorizationCredentials = Depends(security)):
    token = credentials.credentials
    payload = decode_token(token)
    user_id: str = payload.get("sub")
    role: str = payload.get("role")
    if user_id is None or role is None:
        raise HTTPException(status_code=401, detail="Invalid token payload")
    return {"id": user_id, "role": role}

def get_current_artisan(user: dict = Depends(get_current_user), db: Session = Depends(get_db)):
    if user["role"] != "artisan":
        raise HTTPException(status_code=403, detail="Not authorized as an artisan")
    artisan = db.query(Artisan).filter(Artisan.id == user["id"]).first()
    if not artisan:
        raise HTTPException(status_code=401, detail="Artisan not found")
    return artisan

def get_current_customer(user: dict = Depends(get_current_user), db: Session = Depends(get_db)):
    if user["role"] != "customer":
        raise HTTPException(status_code=403, detail="Not authorized as a customer")
    customer = db.query(Customer).filter(Customer.id == user["id"]).first()
    if not customer:
        raise HTTPException(status_code=401, detail="Customer not found")
    return customer
