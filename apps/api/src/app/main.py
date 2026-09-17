from contextlib import asynccontextmanager
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from fastapi.staticfiles import StaticFiles
import os

from .config import settings
from .api.routes import artisan, product, order, auth, payment


@asynccontextmanager
async def lifespan(app: FastAPI):
    try:
        from .database import engine, Base
        from .models import artisan as artisan_model
        from .models import product as product_model
        from .models import order as order_model
        from .models import customer as customer_model
        from .models import payment as payment_model
        Base.metadata.create_all(bind=engine)
        print("Database tables created successfully")
    except Exception as e:
        print(f"Warning: Could not connect to database: {e}")
        print("API will start without database.")
    yield
    print("Shutting down...")


app = FastAPI(
    title="SIH26090 API",
    description="AI-powered Digital Craft Marketplace API",
    version="0.1.0",
    lifespan=lifespan,
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

os.makedirs("uploads", exist_ok=True)
app.mount("/uploads", StaticFiles(directory="uploads"), name="uploads")

@app.get("/health")
def health():
    return {"status": "ok", "service": "sih26090-api"}


app.include_router(artisan.router, prefix="/api/v1/artisans", tags=["artisans"])
app.include_router(product.router, prefix="/api/v1/products", tags=["products"])
app.include_router(order.router, prefix="/api/v1/orders", tags=["orders"])
app.include_router(auth.router, prefix="/api/v1/auth", tags=["auth"])
app.include_router(payment.router, prefix="/api/v1/payment", tags=["payment"])
