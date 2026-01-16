class Config:
    # VULNERABILITY: Hardcoded Secret Key (CWE-798)
    # Atacatorii pot găsi această cheie dacă au acces la cod (ex: GitHub public)
    # și pot semna propriile token-uri JWT.
    SECRET_KEY = 'authguard_super_static_secret_key_2025'
    
    # Database config
    SQLALCHEMY_DATABASE_URI = 'sqlite:///authguard.db'
    SQLALCHEMY_TRACK_MODIFICATIONS = False