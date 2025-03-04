# app.py
from flask import Flask, request, jsonify, redirect, url_for, flash, render_template
import xgboost as xgb
import numpy as np
import pandas as pd
import sys
import os
from flask import Flask, request, jsonify
from flask_sqlalchemy import SQLAlchemy
from datetime import datetime
import sqlite3
from extensions import db 
from flask_login import LoginManager, login_user, logout_user, current_user, UserMixin
from werkzeug.security import check_password_hash, generate_password_hash


# Initialize Flask app
app = Flask(__name__)
app.config['SQLALCHEMY_DATABASE_URI'] = 'sqlite:///database.db'
app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False
app.config['SECRET_KEY'] = 'your_secret_key_here'

db = SQLAlchemy(app)
login_manager = LoginManager(app)
login_manager.login_view = 'login'

# User model
class User(db.Model, UserMixin):
    id = db.Column(db.Integer, primary_key=True)
    username = db.Column(db.String(80), unique=True, nullable=False)
    password = db.Column(db.String(200), nullable=False)


db.init_app(app)
from models import Comment

# Load the pre-trained XGBoost model (assuming you've already trained it and saved it as 'model.json')
model = xgb.Booster()
model.load_model("phishing_detection_model.json")  # Update with the path to your model

# Define a function to process the URL and extract features (simplified example)
def extract_features(url):
    # Dummy feature extraction (you need to implement real feature extraction here)
    # Here, we return a mock feature array for the sake of this example
    
    # Extract features from the URL
    features = {
        'url_length': len(url),
        'n_dots': url.count('.'),
        'n_hypens':url.count('-'),
        'n_underline': url.count('_'),
        'n_slash': url.count('/'),
        'n_questionmark': url.count('?'),
        'n_equal': url.count('='),
        'n_at': url.count('@'),
        'n_and': url.count('&'),
        'n_exclamation': url.count('!'),
        'n_space': url.count(' '),
        'n_tilde': url.count('~'),
        'n_comma': url.count(','),
        'n_plus': url.count('+'),
        'n_asterisk': url.count('*'),
        'n_hastag': url.count('#'),
        'n_dollar': url.count('$'),
        'n_percent': url.count('%'),
        'n_redirection': url.count('//')
    }
    # Convert to Pandas DataFrame
    return pd.DataFrame([features])


@app.route('/', methods=['POST'])
def predict():
    data = request.get_json()  # Get JSON data from the request

    #Check if the data is valid and contains url
    if not data or 'url' not in data:
        return jsonify({"error":"Bad request: 'url' field is required"}),400


    url = data.get('url')  # Get the URL from the request
    
    # Feature extraction
    features_df = extract_features(url)

    # Convert to DMatrix format for XGBoost
    dmatrix = xgb.DMatrix(features_df) # Convert to DMatrix format for XGBoost

    prediction = model.predict(dmatrix)
    print(prediction[0])
    
    # Return prediction (0 for safe, 1 for phishing)
    result = "phishing" if prediction[0] >=0.5 else "safe"

    #Print the result to the terminal
    print(f"URL: {url} -> Prediction:{result}")
    
    return jsonify({'result': result})

# Load user callback for Flask-Login
@login_manager.user_loader
def load_user(user_id):
    return User.query.get(int(user_id))

@app.route('/register', methods=['POST'])
def register():
    data = request.get_json()
    username = data.get('username')
    password = data.get('password')

    if not username or not password:
        return jsonify({'status': 'fail', 'message': 'Username and password are required'}), 400

    existing_user = User.query.filter_by(username=username).first()
    if existing_user:
        return jsonify({'status': 'fail', 'message': 'Username already exists'}), 400

    hashed_password = generate_password_hash(password)
    new_user = User(username=username, password=hashed_password)
    db.session.add(new_user)
    db.session.commit()

    return jsonify({'status': 'success', 'message': 'User registered successfully'}), 201

@app.route('/login', methods=['POST'])
def login():
    data = request.get_json()
    username = data.get('username')
    password = data.get('password')

    if not username or not password:
        return jsonify({'status': 'fail', 'message': 'Username and password are required'}), 400

    user = User.query.filter_by(username=username).first()
    if user and check_password_hash(user.password, password):
        login_user(user)
        return jsonify({'status': 'success', 'message': 'Logged in successfully'}), 200
    else:
        return jsonify({'status': 'fail', 'message': 'Invalid username or password'}), 401

@app.route('/logout', methods=['GET'])
def logout():
    logout_user()
    return jsonify({'status': 'success', 'message': 'Logged out successfully'}), 200




# @app.route('/login', methods=['GET', 'POST'])
# def login():
#     with app.app_context():  
#         if request.method == 'POST':
#             password = request.form['password']
#             if current_user and check_password_hash(current_user.password, password):
#                 login_user(current_user)
#                 flash('Logged in successfully!')
#                 return redirect(url_for('home'))
#             else:
#                 flash('Invalid credentials. Please try again.')
#         return render_template('login.html')


# @app.route('/logout')
# def logout():
#     logout_user()
#     flash('You have been logged out.')
#     return redirect(url_for('login'))


# Function to save a search
def save_search(query, result):
    conn = sqlite3.connect('search_history.db')
    cursor = conn.cursor()
    cursor.execute(
        "INSERT INTO search_history (query, result) VALUES (?, ?)",
        (query, result)
    )
    conn.commit()
    conn.close()

# Endpoint to retrieve the last 15 searches
@app.route('/history', methods=['GET'])
def get_history():
    conn = sqlite3.connect('search_history.db')
    cursor = conn.cursor()
    cursor.execute(
        "SELECT query, result, search_time FROM search_history ORDER BY search_time DESC LIMIT 15"
    )
    history = cursor.fetchall()
    conn.close()
    return jsonify(history)

# Function to add a comment
# @app.route('/add_comment', methods=['POST'])
# def add_comment():
#     data = request.json
#     user_name = data.get('user_name')
#     comment = data.get('comment')
    
#     if not user_name or not comment:
#         return jsonify({"error": "User name and comment are required"}), 400

#     conn = sqlite3.connect('comments.db')
#     cursor = conn.cursor()
#     cursor.execute(
#         "INSERT INTO comments (user_name, comment) VALUES (?, ?)",
#         (user_name, comment)
#     )
#     conn.commit()
#     conn.close()
    
#     return jsonify({"message": "Comment added successfully!"}), 201
# @app.route('/comments', methods=['GET'])
# def get_comments():
#     conn = sqlite3.connect('comments.db')
#     cursor = conn.cursor()
#     cursor.execute(
#         "SELECT user_name, comment, comment_time FROM comments ORDER BY comment_time ASC"
#     )
#     comments = cursor.fetchall()
#     conn.close()
    
#     return jsonify(comments)


# comments section
@app.route('/add_comment', methods=['POST'])
def add_comment():
    data = request.json
    new_comment = Comment(url=data['url'], comment=data['comment'], timestamp=datetime.utcnow())
    db.session.add(new_comment)
    db.session.commit()
    return jsonify({"message": "Comment added successfully"}), 201

@app.route('/get_comments', methods=['GET'])
def get_comments():
    url = request.args.get('url')
    comments = Comment.query.filter_by(url=url).all()
    return jsonify([{"url": c.url, "comment": c.comment, "timestamp": c.timestamp} for c in comments])

# @app.route('/register', methods=['POST'])
# def register():
#     data = request.get_json()
#     username = data.get('username')
#     password = data.get('password')

#     if not username or not password:
#         return jsonify({'status': 'fail', 'message': 'Username and password are required'}), 400

#     if any(user['username'] == username for user in users):
#         return jsonify({'status': 'fail', 'message': 'Username already exists'}), 400

#     hashed_password = generate_password_hash(password)
#     users.append({'username': username, 'password': hashed_password})

#     return jsonify({'status': 'success', 'message': 'User registered successfully'}), 201



if __name__ == '__main__':
    app.run(debug=True,host='0.0.0.0')
