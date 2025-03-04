from extensions import db

class Comment(db.Model):
    id = db.Column(db.Integer, primary_key=True)  # Auto-incrementing primary key
    url = db.Column(db.String(2083), nullable=False)  # URL being commented on
    comment = db.Column(db.Text, nullable=False)  # The user's comment
    timestamp = db.Column(db.DateTime, nullable=False)  # When the comment was made
    user_id = db.Column(db.Integer, nullable=True)  # Optional: User ID if authentication is implemented

    def __repr__(self):
        return f"<Comment {self.comment[:20]}>"
