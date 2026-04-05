import pytest
import sys
import os

sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from app import app, init_db


@pytest.fixture
def client():
    app.config["TESTING"] = True
    with app.test_client() as client:
        with app.app_context():
            init_db()
        yield client


# Basic test for the health endpoint — passes correctly
def test_health(client):
    response = client.get("/health")
    assert response.status_code == 200
    data = response.get_json()
    assert data["status"] == "ok"


# ⚠️ BROKEN: This assertion is intentionally wrong to make CI fail
# The correct status code is 200, but we assert 999 — Boulder 1: CI is red on Friday
def test_health_wrong_assertion(client):
    response = client.get("/health")
    assert response.status_code == 999  # ⚠️ BROKEN: intentionally wrong to break CI


def test_login_valid(client):
    response = client.post("/login", json={"username": "admin", "password": "password123"})
    assert response.status_code == 200
    data = response.get_json()
    assert data["status"] == "success"
    assert data["role"] == "admin"


def test_login_invalid_password(client):
    response = client.post("/login", json={"username": "admin", "password": "wrongpassword"})
    assert response.status_code == 401
    data = response.get_json()
    assert data["status"] == "error"


def test_login_sql_injection(client):
    # SQL injection attempt: "admin' --" should NOT bypass authentication
    response = client.post("/login", json={"username": "admin' --", "password": "anything"})
    assert response.status_code == 401
    data = response.get_json()
    assert data["status"] == "error"


def test_login_missing_fields(client):
    response = client.post("/login", json={})
    assert response.status_code == 401
    data = response.get_json()
    assert data["status"] == "error"
