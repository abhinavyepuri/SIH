import os
import uuid
import shutil
from fastapi import APIRouter, Depends, HTTPException, File, UploadFile
from typing import Optional
from sqlalchemy.orm import Session
from sqlalchemy import func

from ...database import get_db
from ...models.product import Product
from ...models.artisan import Artisan
from ...schemas.product import ProductCreate, ProductResponse, ProductListResponse

router = APIRouter()


from ...core.security import get_current_artisan

@router.post("/", response_model=ProductResponse)
def create_product(
    data: ProductCreate, 
    db: Session = Depends(get_db),
    artisan: Artisan = Depends(get_current_artisan)
):
    # Override artisan_id in case they try to forge it
    dump_data = data.model_dump()
    dump_data["artisan_id"] = artisan.id
    product = Product(**dump_data)
    db.add(product)
    db.commit()
    db.refresh(product)
    return product


from fastapi import Request
from ...services.cloudinary_service import is_cloudinary_configured, upload_image_to_cloudinary

@router.post("/upload")
def upload_image(
    request: Request,
    file: UploadFile = File(...),
):
    try:
        if is_cloudinary_configured():
            secure_url = upload_image_to_cloudinary(file.file, folder="artisan_products")
            return {"url": secure_url, "provider": "cloudinary"}
        else:
            # Fallback for local development if Cloudinary keys are missing
            ext = file.filename.split('.')[-1] if '.' in file.filename else 'jpg'
            filename = f"{uuid.uuid4().hex}.{ext}"
            file_path = os.path.join("uploads", filename)
            
            with open(file_path, "wb") as buffer:
                shutil.copyfileobj(file.file, buffer)
                
            base_url = str(request.base_url).rstrip("/")
            return {
                "url": f"{base_url}/uploads/{filename}", 
                "provider": "local",
                "warning": "Cloudinary credentials not configured. Uploaded to local storage fallback. Set CLOUDINARY_CLOUD_NAME, CLOUDINARY_API_KEY, CLOUDINARY_API_SECRET in .env"
            }
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Upload failed: {str(e)}")

@router.get("/", response_model=ProductListResponse)
def list_products(
    status: Optional[str] = None,
    category: Optional[str] = None,
    artisan_id: Optional[str] = None,
    db: Session = Depends(get_db),
):
    query = db.query(Product).filter((Product.is_active == True) | (Product.is_active == None))
    if status:
        query = query.filter(Product.status == status)
    if category:
        query = query.filter(Product.category == category)
    if artisan_id:
        query = query.filter(Product.artisan_id == artisan_id)
    products = query.order_by(Product.created_at.desc()).all()
    return ProductListResponse(products=products, total=len(products))


@router.get("/marketplace", response_model=ProductListResponse)
def marketplace_products(
    category: Optional[str] = None,
    search: Optional[str] = None,
    db: Session = Depends(get_db),
):
    query = db.query(Product).filter(
        Product.is_active == True,
        Product.status == "published",
    )
    if category and category != "All Works":
        query = query.filter(Product.category == category)
    if search:
        query = query.filter(Product.title.ilike(f"%{search}%"))
    products = query.order_by(Product.created_at.desc()).all()
    return ProductListResponse(products=products, total=len(products))


@router.get("/stats")
def product_stats(db: Session = Depends(get_db)):
    total = db.query(Product).filter(Product.is_active == True).count()
    published = db.query(Product).filter(Product.is_active == True, Product.status == "published").count()
    draft = db.query(Product).filter(Product.is_active == True, Product.status == "draft").count()
    return {"total": total, "published": published, "draft": draft}


@router.get("/{product_id}")
def get_product(product_id: str, db: Session = Depends(get_db)):
    product = db.query(Product).filter(Product.id == product_id).first()
    if not product:
        raise HTTPException(status_code=404, detail="Product not found")
    return product


@router.put("/{product_id}", response_model=ProductResponse)
def update_product(
    product_id: str, 
    data: ProductCreate, 
    db: Session = Depends(get_db),
    artisan: Artisan = Depends(get_current_artisan)
):
    product = db.query(Product).filter(Product.id == product_id).first()
    if not product:
        raise HTTPException(status_code=404, detail="Product not found")
    if product.artisan_id != artisan.id:
        raise HTTPException(status_code=403, detail="Not authorized to edit this product")
    
    dump = data.model_dump()
    dump["artisan_id"] = artisan.id
    for key, value in dump.items():
        setattr(product, key, value)
    db.commit()
    db.refresh(product)
    return product


@router.delete("/{product_id}")
def delete_product(
    product_id: str, 
    db: Session = Depends(get_db),
    artisan: Artisan = Depends(get_current_artisan)
):
    product = db.query(Product).filter(Product.id == product_id).first()
    if not product:
        raise HTTPException(status_code=404, detail="Product not found")
    if product.artisan_id != artisan.id:
        raise HTTPException(status_code=403, detail="Not authorized to delete this product")
    product.is_active = False
    db.commit()
    return {"message": "Product deleted"}
