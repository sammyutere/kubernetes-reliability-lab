import os
import time
import random
from fastapi import FastAPI, Response
from prometheus_client import Counter, Histogram, generate_latest, CONTENT_TYPE_LATEST

app = FastAPI(title="dependency-service")

SERVICE_NAME = "dependency"
FAILURE_MODE = os.getenv("FAILURE_MODE", "none")
LATENCY_MS = int(os.getenv("LATENCY_MS", "0"))

REQUESTS = Counter(
    "dependency_http_requests_total",
    "Total HTTP requests handled by dependency service",
    ["path", "status"],
)

LATENCY = Histogram(
    "dependency_http_request_duration_seconds",
    "Dependency service request duration",
    ["path"],
)


@app.get("/")
def root():
    return {"service": SERVICE_NAME, "status": "ok"}


@app.get("/healthz")
def healthz():
    return {"service": SERVICE_NAME, "status": "healthy"}


@app.get("/readyz")
def readyz(response: Response):
    if FAILURE_MODE == "not_ready":
        response.status_code = 503
        REQUESTS.labels(path="/readyz", status="503").inc()
        return {"service": SERVICE_NAME, "ready": False}

    REQUESTS.labels(path="/readyz", status="200").inc()
    return {"service": SERVICE_NAME, "ready": True}


@app.get("/data")
def data(response: Response):
    with LATENCY.labels(path="/data").time():
        if LATENCY_MS > 0:
            time.sleep(LATENCY_MS / 1000)

        if FAILURE_MODE == "error":
            response.status_code = 500
            REQUESTS.labels(path="/data", status="500").inc()
            return {"service": SERVICE_NAME, "error": "simulated dependency failure"}

        if FAILURE_MODE == "flaky" and random.random() < 0.5:
            response.status_code = 500
            REQUESTS.labels(path="/data", status="500").inc()
            return {"service": SERVICE_NAME, "error": "simulated flaky failure"}

        REQUESTS.labels(path="/data", status="200").inc()
        return {"service": SERVICE_NAME, "data": "dependency response"}


@app.get("/metrics")
def metrics():
    return Response(generate_latest(), media_type=CONTENT_TYPE_LATEST)
