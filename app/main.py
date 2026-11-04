from fastapi import FastAPI

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