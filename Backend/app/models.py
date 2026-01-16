# Backend/app/models.py
from . import db

class User(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    username = db.Column(db.String(50), unique=True, nullable=False)
    # VULNERABILITY: Stocăm parola direct (sau cu hashing slab), nu folosim bcrypt/argon2
    password = db.Column(db.String(100), nullable=False) 

class VaultItem(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    user_id = db.Column(db.Integer, db.ForeignKey('user.id'), nullable=False)
    service_name = db.Column(db.String(100), nullable=False)
    service_username = db.Column(db.String(100), nullable=False)
    # VULNERABILITY: Parolele salvate sunt text clar (CWE-312)
    service_password = db.Column(db.String(100), nullable=False)