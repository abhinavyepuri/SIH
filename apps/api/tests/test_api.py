from fastapi.testclient import TestClient
import sys
import os

# Ensure src is in python path
sys.path.insert(0, os.path.join(os.path.dirname(__file__), "..", "src"))

from app.main import app
from app.config import settings

client = TestClient(app)


def test_health_check():
    response = client.get("/health")
    assert response.status_code == 200
    data = response.json()
    assert data["status"] == "ok"
    assert data["service"] == "sih26090-api"


def test_auth_check_email():
    response = client.post(
        "/api/v1/auth/check-email",
        json={"email": settings.ADMIN_EMAIL, "role": "admin"}
    )
    assert response.status_code == 200
    data = response.json()
    assert data["exists"] is True
    assert data["role"] == "admin"


def test_admin_login():
    response = client.post(
        "/api/v1/auth/login",
        json={
            "email": settings.ADMIN_EMAIL,
            "password": settings.ADMIN_PASSWORD,
            "role": "admin"
        }
    )
    assert response.status_code == 200
    data = response.json()
    assert data["email"] == settings.ADMIN_EMAIL
    assert data["role"] == "admin"
    assert "token" in data


def test_invalid_login():
    response = client.post(
        "/api/v1/auth/login",
        json={
            "email": "wrong@admin.com",
            "password": "wrongpassword",
            "role": "admin"
        }
    )
    assert response.status_code == 401


def test_products_marketplace_endpoint():
    response = client.get("/api/v1/products/marketplace")
    # Endpoint should respond successfully
    assert response.status_code == 200
    data = response.json()
    assert "products" in data
    assert "total" in data


def test_stripe_checkout_dev_bypass():
    response = client.post(
        "/api/v1/payment/create-checkout-session",
        json={
            "items": [
                {"name": "Terracotta Pot", "price": 1200, "quantity": 1}
            ],
            "order_id": "ORD_TEST_001",
            "customer_email": "test@example.com",
            "success_url": "http://localhost:3000/payment-success",
            "cancel_url": "http://localhost:3000/payment-cancelled"
        }
    )
    assert response.status_code == 200
    data = response.json()
    assert "checkout_url" in data
    assert "session_id" in data


if __name__ == "__main__":
    test_health_check()
    test_auth_check_email()
    test_admin_login()
    test_invalid_login()
    test_products_marketplace_endpoint()
    test_stripe_checkout_dev_bypass()
    print("All 6 API unit tests passed successfully!")
