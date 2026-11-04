from fastapi import FastAPI
import sqlite3

AWS_ACCESS_KEY_ID = "AKIAIOSFODNN7EXAMPLE"
GITHUB_TOKEN = "ghp_123sdgklsj34fgksdjsdsdf"

app = FastAPI(
    title="test app",
    description="test app for lab",
    version="1.0.0",
)


@app.get("/")
def root():
    return {
        "application": "test app",
        "status": "running",
    }


@app.get("/health")
def health():
    return {
        "status": "ok",
    }

@app.get("/user")
def get_user(user_id: str):
    conn = sqlite3.connect("test.db")
    cursor = conn.cursor()
    cursor.execute(f"SELECT * FROM users WHERE id = {user_id}")
    return {"user": cursor.fetchone()}