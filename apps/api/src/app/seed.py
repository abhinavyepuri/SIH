"""Seed script — insert sample artisans and products into PostgreSQL."""
import sys
import os

sys.path.insert(0, os.path.join(os.path.dirname(__file__), ".."))

from app.database import engine, SessionLocal, Base
from app.models.artisan import Artisan
from app.models.product import Product
from app.models.order import Order


def seed():
    Base.metadata.create_all(bind=engine)
    db = SessionLocal()

    if db.query(Artisan).count() > 0:
        print("Database already seeded. Skipping.")
        db.close()
        return

    artisans = [
        Artisan(id="ART001", name="Elena Rostova", location="Jaipur, Rajasthan",
                craft_category="Ceramics", languages=["en", "hi"],
                business_type="individual", verification_status="approved", email="elena@example.com"),
        Artisan(id="ART002", name="Mateo Cruz", location="Moradabad, Uttar Pradesh",
                craft_category="Metalwork", languages=["en", "hi", "ur"],
                business_type="individual", verification_status="approved", email="mateo@example.com"),
        Artisan(id="ART003", name="Silas Thorne", location="Saharanpur, Uttar Pradesh",
                craft_category="Woodworking", languages=["en", "hi"],
                business_type="small_business", verification_status="approved", email="silas@example.com"),
        Artisan(id="ART004", name="Anja Klein", location="Varanasi, Uttar Pradesh",
                craft_category="Textiles", languages=["en", "hi", "bn"],
                business_type="individual", verification_status="approved", email="anja@example.com"),
        Artisan(id="ART005", name="Lakshmi Devi", location="Vijayawada, Andhra Pradesh",
                craft_category="Handicrafts", languages=["te", "hi", "en"],
                business_type="individual", verification_status="approved", email="lakshmi@example.com"),
    ]

    products = [
        Product(id="PRD001", artisan_id="ART001", title="Kintsugi Vessel",
                description="A masterful exploration of form and fire. This vessel is thrown from locally sourced stoneware and finished with a wild ash glaze, resulting in a surface that is both coarse and deeply elegant.",
                category="Ceramics", materials="Wild Ash Stoneware", price=450, quantity=1,
                tags="ceramics,minimalist,handmade", status="published"),
        Product(id="PRD002", artisan_id="ART004", title="Merino Weave Throw",
                description="Hand-woven merino wool throw with natural dye patterns. Each piece is unique.",
                category="Textiles", materials="Merino Wool", price=320, quantity=1,
                tags="textiles,wool,handwoven", status="published"),
        Product(id="PRD003", artisan_id="ART001", title="Obsidian Nesting Bowls",
                description="Set of three nesting bowls with a deep obsidian glaze. Perfect for serving or display.",
                category="Ceramics", materials="Stoneware Clay", price=210, quantity=3,
                tags="ceramics,bowls,obsidian", status="published"),
        Product(id="PRD004", artisan_id="ART002", title="Eclipse Sculpture",
                description="Abstract metalwork sculpture exploring the interplay of light and shadow.",
                category="Metalwork", materials="Brushed Brass", price=850, quantity=1,
                tags="metalwork,sculpture,brass", status="published"),
        Product(id="PRD005", artisan_id="ART003", title="Walnut Contours Table",
                description="Hand-carved walnut side table with organic flowing lines. Each piece follows the natural grain of the wood.",
                category="Woodworking", materials="Walnut Wood", price=1200, quantity=1,
                tags="woodworking,furniture,walnut", status="published"),
        Product(id="PRD006", artisan_id="ART003", title="Oak Joinery Chair",
                description="Traditional joinery chair crafted from solid oak. No nails or screws — purely interlocking wood.",
                category="Woodworking", materials="Solid Oak", price=1800, quantity=1,
                tags="woodworking,chair,oak", status="published"),
        Product(id="PRD007", artisan_id="ART005", title="Brass Diya Lamp Set",
                description="Set of 5 hand-hammered brass diyas with intricate floral patterns. Perfect for festivals.",
                category="Handicrafts", materials="Brass", price=150, quantity=5,
                tags="handicrafts,brass,diya", status="published"),
        Product(id="PRD008", artisan_id="ART002", title="Copper Vase",
                description="Hand-beaten copper vase with traditional Moradabad engravings.",
                category="Metalwork", materials="Copper", price=380, quantity=2,
                tags="metalwork,copper,vase", status="published"),
        Product(id="PRD009", artisan_id="ART004", title="Silk Banarasi Saree",
                description="Pure silk Banarasi saree with gold zari work. Takes 45 days to complete.",
                category="Textiles", materials="Pure Silk", price=3500, quantity=1,
                tags="textiles,silk,saree", status="published"),
        Product(id="PRD010", artisan_id="ART001", title="Raku Tea Bowl",
                description="Raku-fired tea bowl with crackle glaze finish. Each firing produces unique patterns.",
                category="Ceramics", materials="Raku Clay", price=280, quantity=2,
                tags="ceramics,raku,tea", status="published"),
    ]

    for a in artisans:
        db.add(a)
    for p in products:
        db.add(p)

    db.commit()
    print(f"Seeded {len(artisans)} artisans and {len(products)} products.")
    db.close()


if __name__ == "__main__":
    seed()
