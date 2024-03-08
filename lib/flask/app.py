from flask import Flask, request, abort, session, jsonify
import sqlite3
from flask_session import Session
from datetime import timedelta
import datetime
import json
import random
import os 

app = Flask(__name__)
# Generate a random secret key and set it as a configuration
app.config['SECRET_KEY'] = os.urandom(24)

# Session configuration
app.config['SESSION_TYPE'] = 'filesystem'
app.config['PERMANENT_SESSION_LIFETIME'] = timedelta(minutes=30) 
Session(app)
# Initialize the SQLite database
db = sqlite3.connect('battleships.db', check_same_thread=False)
cursor = db.cursor()
cursor.execute('''
CREATE TABLE IF NOT EXISTS users (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    username TEXT NOT NULL UNIQUE,
    password TEXT NOT NULL,
    session_token TEXT
)
''')
cursor.execute('''
CREATE TABLE IF NOT EXISTS games (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    player1 INTEGER NOT NULL,
    player2 INTEGER,
    status INTEGER,
    turn INTEGER,
    FOREIGN KEY (player1) REFERENCES users (id),
    FOREIGN KEY (player2) REFERENCES users (id)
)
''')
db.commit()

# Session token generator
def generate_session_token():
    token_length = 20
    characters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
    return ''.join(random.choice(characters) for _ in range(token_length))

# Login decorator
def login_required(func):
    def decorated_function(*args, **kwargs):
        if 'user_id' not in session:
            abort(401)
        return func(*args, **kwargs)
    return decorated_function

# User registration
@app.route('/register', methods=['POST'])
def register():
    if request.method == 'POST':
        data = request.get_json()
        username = data.get('username')
        password = data.get('password')

        # Check if the username already exists
        cursor.execute('SELECT * FROM users WHERE username=?', (username,))
        existing_user = cursor.fetchone()

        if existing_user:
            # Username already exists, return a conflict response
            return jsonify({'error': 'Username already taken'}), 409

        # Username is available, proceed with registration
        try:
            cursor.execute('INSERT INTO users (username,password) VALUES (?,?)',
                            (username, password))
            db.commit()
            user_id = cursor.lastrowid
            session['user_id'] = user_id
            return jsonify({'status': 'success', 'message': 'User created successfully'})
        except sqlite3.Error as e:
            return jsonify({'status': 'error', 'message': 'Failed to register user'})


# User login
@app.route('/login', methods=['POST'])
def login():
    data = request.get_json()
    username = data.get('username')
    password = data.get('password')
    cursor.execute('SELECT id, password FROM users WHERE username=?', (username,))
    user = cursor.fetchone()
    if user and user[1] == password:
        session_token = generate_session_token()
        cursor.execute('UPDATE users SET session_token=? WHERE id=?', (session_token, user[0]))
        db.commit()
        session['user_id'] = user[0]
        return jsonify({'message': 'Login successful', 'session_token': session_token, 'user_id': session['user_id']})
    else:
        abort(401)

# Logout
@app.route('/logout', methods=['POST'])
@login_required
def logout():
    try:
        user_id = session['user_id']
        cursor.execute('UPDATE users SET session_token=? WHERE id=?', ('', user_id))
        db.commit()
        session.pop('user_id', None)
        return jsonify({'message': 'Logout successful'})
    except Exception as e:
        return jsonify({'message': str(e)})

# Create a new game
# @app.route('/games', methods=['POST'])
# @login_required
# def create_game():
#     user_id1 = session['user_id']
#     cursor.execute('INSERT INTO games (user_id1, user_id2, status, turn) VALUES (?, NULL, 0, ?)',
#                    (user_id1, user_id1))
#     db.commit()
#     return jsonify({'message': 'Game created successfully'})

# # List games
# @app.route('/games', methods=['GET'])
# @login_required
# def list_games():
#     user_id = session['user_id']
#     cursor.execute('SELECT id, user_id2, status, turn FROM games WHERE user_id1=? OR user_id2=?', (user_id, user_id))
#     games = cursor.fetchall()
#     game_list = []
#     for game in games:
#         game_id = game[0]
#         user_id2 = game[1]
#         status = game[2]
#         turn = game[3]

#         if user_id2 is not None:
#             cursor.execute('SELECT username FROM users WHERE id=?', (user_id2,))
#             opponent = cursor.fetchone()[0]
#         else:
#             opponent = None

#         game_list.append({
#             'id': game_id,
#             'opponent': opponent,
#             'status': status,
#             'turn': turn,
#         })

#     return jsonify(game_list)

# def check_session_expiry():
#     if 'user_id' in session and 'permanent' in session:
#         now = datetime.utcnow()
#         last_activity = session.get('permanent', now)
#         if now - last_activity > timedelta(minutes=30):
#             # Session expired, logout the user
#             session.pop('user_id', None)
#             session.pop('permanent', None)
HOSTNAME = '0.0.0.0'
PORT = 5002

if __name__ == '__main__':
    app.run(host=HOSTNAME, port=PORT, debug=True)

