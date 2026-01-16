# Backend/run.py
from app import create_app

app = create_app()

if __name__ == '__main__':
    # Rulăm pe 0.0.0.0 pentru a fi accesibil din rețeaua locală (telefon/simulator)
    app.run(host='0.0.0.0', port=5001, debug=True)