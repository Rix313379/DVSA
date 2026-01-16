# Backend/app/routes.py
from flask import Blueprint, request, jsonify, make_response, current_app
from .models import User, VaultItem, db
from functools import wraps
import jwt
import datetime

# Definim un Blueprint numit 'api'
api = Blueprint('api', __name__)

# --- DECORATOR PENTRU AUTH (Middleware) ---
def token_required(f):
    @wraps(f)
    def decorated(*args, **kwargs):
        token = request.headers.get('Authorization')
        
        if not token:
            return jsonify({'message': 'Token is missing!'}), 401
        
        try:
            if token.startswith('Bearer '):
                token = token.split(" ")[1]
            
            # VULNERABILITY: Decodare fără verificare strictă a algoritmului (uneori)
            data = jwt.decode(token, current_app.config['SECRET_KEY'], algorithms=["HS256"])
            current_user = User.query.filter_by(id=data['user_id']).first()
        except Exception as e:
            return jsonify({'message': 'Token is invalid!', 'error': str(e)}), 401
            
        return f(current_user, *args, **kwargs)
    return decorated

# --- AUTH ROUTES ---

@api.route('/register', methods=['POST'])
def register():
    data = request.get_json()
    
    # VULNERABILITY: Input Validation insuficient
    if not data or not data.get('username') or not data.get('password'):
        return make_response('Bad Request', 400)

    if User.query.filter_by(username=data['username']).first():
         return make_response('User already exists', 409)

    new_user = User(username=data['username'], password=data['password'])
    db.session.add(new_user)
    db.session.commit()
    
    return jsonify({'message': 'User registered successfully!'})

@api.route('/login', methods=['POST'])
def login():
    auth = request.get_json()

    if not auth or not auth.get('username') or not auth.get('password'):
        return make_response('Could not verify', 401)

    user = User.query.filter_by(username=auth['username']).first()

    # VULNERABILITY: Lipsa Rate Limiting (permite Bruteforce)
    if user and user.password == auth['password']:
        # VULNERABILITY: Token cu durată excesivă (10 ani)
        token = jwt.encode({
            'user_id': user.id,
            'exp': datetime.datetime.utcnow() + datetime.timedelta(days=3650)
        }, current_app.config['SECRET_KEY'], algorithm="HS256")

        return jsonify({'token': token})

    return make_response('Could not verify', 401)

# --- VAULT ROUTES ---

@api.route('/vault', methods=['GET'])
@token_required
def get_vault(current_user):
    items = VaultItem.query.filter_by(user_id=current_user.id).all()
    output = []
    for item in items:
        output.append({
            'id': item.id,
            'service': item.service_name,
            'username': item.service_username,
            'password': item.service_password # Trimis în clar
        })
    return jsonify({'vault': output})

@api.route('/vault', methods=['POST'])
@token_required
def add_vault_item(current_user):
    data = request.get_json()
    new_item = VaultItem(
        user_id=current_user.id,
        service_name=data['service'],
        service_username=data['username'],
        service_password=data['password']
    )
    db.session.add(new_item)
    db.session.commit()
    return jsonify({'message': 'Item added to vault!'})

# --- VULNERABLE ADMIN ROUTE ---

@api.route('/admin/users', methods=['GET'])
def get_all_users():
    # VULNERABILITY: Broken Access Control (Endpoint public care expune tot)
    users = User.query.all()
    output = []
    for user in users:
        output.append({'username': user.username, 'password': user.password})
    return jsonify({'users': output})