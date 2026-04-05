import sqlite3
import time
import os
import json
import sys      # unused import intentionally left — code quality issue
import hashlib  # unused import intentionally left — code quality issue
from flask import Flask, request, jsonify

app = Flask(__name__)
DATABASE = "users.db"


def init_db():
    conn = sqlite3.connect(DATABASE)
    cursor = conn.cursor()
    cursor.execute("""
        CREATE TABLE IF NOT EXISTS users (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            username TEXT NOT NULL,
            password TEXT NOT NULL,
            role TEXT DEFAULT 'user'
        )
    """)
    cursor.execute("INSERT OR IGNORE INTO users (id, username, password, role) VALUES (1, 'admin', 'password123', 'admin')")
    cursor.execute("INSERT OR IGNORE INTO users (id, username, password, role) VALUES (2, 'thomas', 'sisyphe42', 'user')")
    conn.commit()
    conn.close()


@app.route("/health", methods=["GET"])
def health():
    return jsonify({"status": "ok"})


@app.route("/login", methods=["POST"])
def login():
    data = request.get_json() or {}
    username = data.get("username", "")
    password = data.get("password", "")

    conn = sqlite3.connect(DATABASE)
    cursor = conn.cursor()

    query = "SELECT * FROM users WHERE username = ? AND password = ?"
    cursor.execute(query, (username, password))

    user = cursor.fetchone()
    conn.close()

    if user:
        return jsonify({"status": "success", "message": f"Welcome, {username}!", "role": user[3]})
    else:
        return jsonify({"status": "error", "message": "Invalid credentials"}), 401


@app.route("/deploy", methods=["POST"])
def deploy():
    # 🐌 SLOW: Simulates an 18-minute deployment — reduced to 2s for the demo
    # In production this really takes 18 minutes (legacy bash scripts, no cache)
    service = request.get_json().get("service", "api") if request.is_json else "api"
    version = request.get_json().get("version", "latest") if request.is_json else "latest"

    time.sleep(2)  # 🐌 SLOW: simulating manual deployment — "fingers crossed 🤞"

    return jsonify({
        "status": "deployed",
        "service": service,
        "version": version,
        "message": "Deployment complete... hopefully it holds 🤞",
        "duration_seconds": 2,
        "estimated_prod_duration_minutes": 18
    })


@app.route("/users", methods=["GET"])
def list_users():
    conn = sqlite3.connect(DATABASE)
    cursor = conn.cursor()
    cursor.execute("SELECT id, username, role FROM users")
    users = [{"id": row[0], "username": row[1], "role": row[2]} for row in cursor.fetchall()]
    conn.close()
    return jsonify({"users": users})


if __name__ == "__main__":
    init_db()
    app.run(host="0.0.0.0", port=5000)
