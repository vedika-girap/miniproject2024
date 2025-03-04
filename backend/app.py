from flask import Flask, request, jsonify
from flask_sqlalchemy import SQLAlchemy
from flask_login import LoginManager, login_user, logout_user,login_required, current_user, UserMixin
from werkzeug.security import check_password_hash, generate_password_hash
from datetime import datetime
import xgboost as xgb
import pandas as pd
import sqlite3
from flask_jwt_extended import create_access_token, jwt_required, JWTManager, get_jwt_identity
from datetime import timedelta
# App configuration
app = Flask(__name__)
app.config['SQLALCHEMY_DATABASE_URI'] = 'sqlite:///new_database.db'
app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False
app.config['SECRET_KEY'] = 'your_secret_key_here'

#jwt cconfigure
app.config['JWT_SECRET_KEY'] = '1111'  #  secure key
app.config['JWT_ACCESS_TOKEN_EXPIRES'] = timedelta(hours=1)
jwt = JWTManager(app)
# Extensions
db = SQLAlchemy()
db.init_app(app)
login_manager = LoginManager(app)
login_manager.login_view = 'login'

# Models
class User(db.Model, UserMixin):
    id = db.Column(db.Integer, primary_key=True)
    username = db.Column(db.String(80), unique=True, nullable=False)
    password = db.Column(db.String(200), nullable=False)

class Comment(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    url = db.Column(db.String(255), nullable=False)
    comment = db.Column(db.Text, nullable=False)
    timestamp = db.Column(db.DateTime, default=datetime.utcnow)

# Add a Post model for community posts
class CommunityPost(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    user_id = db.Column(db.Integer, db.ForeignKey('user.id'), nullable=False)
    username = db.Column(db.String(80), nullable=False)
    message = db.Column(db.Text, nullable=False)
    timestamp = db.Column(db.DateTime, default=datetime.utcnow)

class SearchHistory(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    query = db.Column(db.String(500), nullable=False)
    result = db.Column(db.String(50), nullable=False)
    search_time = db.Column(db.DateTime, default=datetime.utcnow)

# Routes

# Load the pre-trained XGBoost model (assuming you've already trained it and saved it as 'model.json')
model = xgb.Booster()
model.load_model("phishing_detection_model.json")  # Update with the path to your model

# Define a function to process the URL and extract features (simplified example)
def extract_features(url):
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

@app.route('/register', methods=['POST'])
def register():
    try:
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

    except Exception as e:
        return jsonify({'status': 'fail', 'message': str(e)}), 500
    

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



@login_manager.user_loader
def load_user(user_id):
    return User.query.get(user_id)



#Community post
@app.route('/community_post', methods=['POST']) 
@login_required
def community_post():
    data = request.get_json()
    message = data.get('message')

    # Validate the message content
    if not message or not message.strip():
        return jsonify({'status': 'fail', 'message': 'Message cannot be empty'}), 400

    # Create a new post
    new_post = CommunityPost(
        user_id=current_user.id,
        username=current_user.username,
        message=message.strip()
    )
    db.session.add(new_post)
    db.session.commit()

    return jsonify({'status': 'success', 'message': 'Post shared successfully'}), 201

# Route to fetch all community posts
@app.route('/get_community_posts', methods=['GET'])
def get_community_posts():
    posts = CommunityPost.query.order_by(CommunityPost.timestamp.desc()).all()
    return jsonify([
        {
            'id': post.id,
            'username': post.username,
            'message': post.message,
            'timestamp': post.timestamp
        }
        for post in posts
    ]), 200



def save_search(query, result):
    new_entry = SearchHistory(query=query, result=result)
    db.session.add(new_entry)
    db.session.commit()

@app.route('/history', methods=['GET'])
def get_history():
    history = SearchHistory.query.order_by(SearchHistory.search_time.desc()).limit(15).all()
    return jsonify([{
        "query": entry.query,
        "result": entry.result,
        "search_time": entry.search_time
    } for entry in history])

@app.route('/get_profile', methods=['GET'])
def get_profile():
    user = get_current_user()  # You need to implement logic for retrieving the current logged-in user
    if user:
        return jsonify({
            'status': 'success',
            'username': user.username,
            'profile_pic': user.profile_pic_url,  # Optional: If you store a profile picture
        }), 200
    else:
        return jsonify({'status': 'fail', 'message': 'User not found'}), 404

@app.route('/update_profile', methods=['POST'])
def update_profile():
    data = request.get_json()
    username = data.get('username')
    password = data.get('password')

    user = get_current_user()  # Implement logic to get current user
    if user:
        if username:
            user.username = username
        if password:
            user.password = generate_password_hash(password)  # Assuming you're hashing passwords
        db.session.commit()
        return jsonify({'status': 'success', 'message': 'Profile updated successfully'}), 200
    else:
        return jsonify({'status': 'fail', 'message': 'User not found'}), 404


# Database initialization
if __name__ == "__main__":
    try:
        with app.app_context():
            db.create_all()
        print("Database initialized successfully.")
    except Exception as e:
        print(f"Error initializing database: {e}")
    app.run(debug=True, host='0.0.0.0')


