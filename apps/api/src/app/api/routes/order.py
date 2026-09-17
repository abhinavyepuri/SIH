from fastapi import APIRouter, Depends, HTTPException
from typing import Optional
from sqlalchemy.orm import Session

from ...database import get_db
from ...models.order import Order
from ...models.customer import Customer
from ...schemas.order import OrderCreate, OrderResponse, OrderListResponse

router = APIRouter()


from ...core.security import get_current_customer

from ...models.product import Product

@router.post("/", response_model=OrderResponse)
def create_order(
    data: OrderCreate, 
    db: Session = Depends(get_db),
    customer: Customer = Depends(get_current_customer)
):
    # Stock availability check
    if data.product_id:
        product = db.query(Product).filter(Product.id == data.product_id, Product.is_active == True).first()
        if not product:
            raise HTTPException(status_code=404, detail="Product not found or inactive")
        if product.quantity < data.quantity:
            raise HTTPException(
                status_code=400, 
                detail=f"Only {product.quantity} items available in stock (requested {data.quantity})"
            )

    dump_data = data.model_dump()
    dump_data["customer_name"] = customer.name
    dump_data["customer_email"] = customer.email
    order = Order(**dump_data)
    db.add(order)
    db.commit()
    db.refresh(order)
    return order


from ...core.security import get_current_user

@router.get("/", response_model=OrderListResponse)
def list_orders(
    status: Optional[str] = None,
    db: Session = Depends(get_db),
    user: dict = Depends(get_current_user),
):
    query = db.query(Order).filter(Order.is_active == True)
    
    if user["role"] == "artisan":
        query = query.filter(Order.artisan_id == user["id"])
    elif user["role"] == "customer":
        # Match by email for customers since customer_id wasn't in original schema
        customer = db.query(Customer).filter(Customer.id == user["id"]).first()
        if customer:
            query = query.filter(Order.customer_email == customer.email)
    elif user["role"] == "admin":
        pass # Admin sees all
    else:
        raise HTTPException(status_code=403, detail="Unauthorized role")
        
    if status:
        query = query.filter(Order.status == status)
        
    orders = query.order_by(Order.created_at.desc()).all()
    return OrderListResponse(orders=orders, total=len(orders))


@router.get("/stats")
def order_stats(db: Session = Depends(get_db)):
    total = db.query(Order).filter(Order.is_active == True).count()
    pending = db.query(Order).filter(Order.is_active == True, Order.status == "pending").count()
    confirmed = db.query(Order).filter(Order.is_active == True, Order.status == "confirmed").count()
    revenue = db.query(Order).filter(Order.is_active == True).with_entities(
        Order.price * Order.quantity
    ).all()
    total_revenue = sum(r[0] for r in revenue) if revenue else 0
    return {
        "total": total,
        "pending": pending,
        "confirmed": confirmed,
        "total_revenue": total_revenue,
    }


from ...models.product import Product

@router.get("/{order_id}", response_model=OrderResponse)
def get_order(order_id: str, db: Session = Depends(get_db)):
    order = db.query(Order).filter(Order.id == order_id).first()
    if not order:
        raise HTTPException(status_code=404, detail="Order not found")
    return order


from ...models.artisan import Artisan

@router.put("/{order_id}/status")
def update_order_status(order_id: str, status: str, db: Session = Depends(get_db)):
    order = db.query(Order).filter(Order.id == order_id).first()
    if not order:
        raise HTTPException(status_code=404, detail="Order not found")
    
    old_status = order.status
    order.status = status

    # When transitioning from 'pending' to non-pending ('confirmed', 'dispatched', 'delivered'):
    # Automatically decrement product stock by the sold quantity
    if old_status == "pending" and status != "pending" and order.product_id:
        product = db.query(Product).filter(Product.id == order.product_id).first()
        if product:
            product.quantity = max(0, product.quantity - order.quantity)
    # If reverted back to 'pending', restore product stock
    elif old_status != "pending" and status == "pending" and order.product_id:
        product = db.query(Product).filter(Product.id == order.product_id).first()
        if product:
            product.quantity = product.quantity + order.quantity

    # Update artisan's total_revenue column in DB
    if order.artisan_id:
        artisan = db.query(Artisan).filter(
            (Artisan.id == order.artisan_id) |
            (Artisan.email == order.artisan_id) |
            (Artisan.name == order.artisan_id)
        ).first()
        if artisan:
            artisan_orders = db.query(Order).filter(
                (Order.artisan_id == artisan.id) |
                (Order.artisan_id == artisan.email) |
                (Order.artisan_id == artisan.name),
                Order.status != "pending"
            ).all()
            artisan.total_revenue = sum(o.price * o.quantity for o in artisan_orders)

    db.commit()
    return {"message": f"Order status updated to {status}"}
