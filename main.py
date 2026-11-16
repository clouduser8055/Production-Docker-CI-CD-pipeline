from fastapi import FastAPI

app = FastAPI()


@app.get("/")
def home():
    return {
        "message": "Hello from my Dockerized Python web service!"
    }


@app.get("/health")
def health():
    return {
        "status": "healthy"
    }