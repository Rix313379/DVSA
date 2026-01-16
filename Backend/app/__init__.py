# Backend/app/__init__.py
from flask import Flask
from flask_sqlalchemy import SQLAlchemy

db = SQLAlchemy()

def create_app():
    app = Flask(__name__)
    
    # Importăm configurația
    from .config import Config
    app.config.from_object(Config)
    
    db.init_app(app)
    
    # Înregistrăm rutele (Blueprint)
    from .routes import api
    app.register_blueprint(api)
    
    # Creăm tabelele dacă nu există (doar pt dev)
    with app.app_context():
        db.create_all()
        
    return app