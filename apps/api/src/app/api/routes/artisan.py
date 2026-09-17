from fastapi import APIRouter, Depends, HTTPException
from typing import Optional
from sqlalchemy.orm import Session
from sqlalchemy import func

from ...database import get_db
from ...models.artisan import Artisan
from ...models.product import Product
from ...schemas.artisan import ArtisanCreate, ArtisanResponse

router = APIRouter()


@router.post("/", response_model=ArtisanResponse)
def create_artisan(artisan: ArtisanCreate, db: Session = Depends(get_db)):
    db_artisan = Artisan(
        name=artisan.name,
        location=artisan.location,
        craft_category=artisan.craft_category,
        languages=artisan.languages,
        business_type=artisan.business_type,
    )
    db.add(db_artisan)
    db.commit()
    db.refresh(db_artisan)
    return db_artisan


@router.get("/")
def list_artisans(skip: int = 0, limit: int = 100, db: Session = Depends(get_db)):
    artisans = db.query(Artisan).offset(skip).limit(limit).all()
    existing_ids = {a.id.lower() for a in artisans if a.id}
    existing_emails = {a.email.lower() for a in artisans if a.email}
    existing_names = {a.name.lower() for a in artisans if a.name}

    # Cross-reference products table to ensure no artisan is omitted
    product_artisans = db.query(Product.artisan_id).distinct().all()
    for (art_id,) in product_artisans:
        if not art_id:
            continue
        art_id_clean = str(art_id).strip().lower()
        if art_id_clean not in existing_ids and art_id_clean not in existing_emails and art_id_clean not in existing_names:
            sample_product = db.query(Product).filter(Product.artisan_id == art_id).first()
            category = sample_product.category if sample_product else "Handicrafts"
            artisans.append(
                Artisan(
                    id=art_id,
                    name=art_id if not art_id.startswith("ART") else f"Artisan {art_id}",
                    email=f"{str(art_id).lower()}@aroha.in",
                    location="India",
                    craft_category=category,
                    languages=["en"],
                    business_type="Individual Artisan",
                    verification_status="approved",
                    is_active=True,
                    total_revenue=0.0,
                )
            )
    return artisans


@router.get("/stats")
def artisan_stats(db: Session = Depends(get_db)):
    total = db.query(Artisan).count()
    approved = db.query(Artisan).filter(Artisan.verification_status == "approved").count()
    pending = db.query(Artisan).filter(Artisan.verification_status == "pending").count()
    return {"total": total, "approved": approved, "pending": pending}


@router.get("/{artisan_id}")
def get_artisan(artisan_id: str, db: Session = Depends(get_db)):
    artisan = db.query(Artisan).filter(
        (Artisan.id == artisan_id) |
        (func.lower(Artisan.email) == artisan_id.lower()) |
        (func.lower(Artisan.name) == artisan_id.lower())
    ).first()

    if not artisan:
        sample = db.query(Product).filter(
            (Product.artisan_id == artisan_id) |
            (func.lower(Product.artisan_id) == artisan_id.lower())
        ).first()
        if sample:
            return Artisan(
                id=artisan_id,
                name=sample.artisan_id if not sample.artisan_id.startswith("ART") else f"Artisan {sample.artisan_id}",
                email=f"{str(sample.artisan_id).lower()}@aroha.in",
                location="India",
                craft_category=sample.category or "Handicrafts",
                languages=["en"],
                business_type="Individual Artisan",
                verification_status="approved",
                is_active=True,
                total_revenue=0.0,
            )
        raise HTTPException(status_code=404, detail="Artisan not found")
    return artisan


@router.get("/{artisan_id}/products")
def get_artisan_products(artisan_id: str, db: Session = Depends(get_db)):
    artisan = db.query(Artisan).filter(Artisan.id == artisan_id).first()
    if not artisan:
        raise HTTPException(status_code=404, detail="Artisan not found")
    products = db.query(Product).filter(
        Product.artisan_id == artisan_id,
        Product.is_active == True,
    ).order_by(Product.created_at.desc()).all()
    return {
        "artisan": {
            "id": artisan.id,
            "name": artisan.name,
            "location": artisan.location,
            "craft_category": artisan.craft_category,
            "languages": artisan.languages,
            "business_type": artisan.business_type,
            "verification_status": artisan.verification_status,
            "email": artisan.email,
        },
        "products": products,
        "total_products": len(products),
    }
