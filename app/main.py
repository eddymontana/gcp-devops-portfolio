from fastapi import FastAPI
import os
import socket

app = FastAPI(title="GCP DevOps Portfolio API")

@app.get("/")
def read_root():
    return {
        "status": "Online",
        "message": "Welcome to my Cloud Native DevOps Portfolio!",
        "environment": os.getenv("ENV", "Development"),
        "hostname": socket.gethostname()
    }

# Liveness Probe: Checks if the container process is alive
@app.get("/health")
def health_check():
    return {"status": "healthy"}

# Readiness Probe: Checks if app dependencies (like DB or external services) are ready
@app.get("/readiness")
def readiness_check():
    return {"status": "ready"}