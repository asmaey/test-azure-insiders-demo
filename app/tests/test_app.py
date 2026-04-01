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


# ✅ Test basique — fonctionne correctement
def test_health(client):
    response = client.get("/health")
    assert response.status_code == 200
    data = response.get_json()
    assert data["status"] == "ok"


# ⚠️ BROKEN: Cette assertion est intentionnellement fausse pour faire échouer la CI
# Le bon status code est 401, mais on teste 200 — Boulder 1: la CI est rouge le vendredi
def test_health_wrong_assertion(client):
    response = client.get("/health")
    assert response.status_code == 999  # ⚠️ BROKEN: intentionnellement faux pour casser la CI


# TODO: add auth tests — Copilot will suggest these
# Les tests pour /login sont manquants — le Coding Agent va les générer automatiquement
# Exemples de cas à tester :
#   - Login valide avec bons identifiants
#   - Login invalide avec mauvais mot de passe
#   - 🚨 SQL Injection : username = "admin' --"
#   - Requête sans body JSON
#   - Champs manquants (username ou password absent)
