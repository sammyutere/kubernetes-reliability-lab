import os
import socket
import time
from typing import Dict

from fastapi import FastAPI, Response, status
from prometheus_client import Counter, Histogram, generate_latest, CONTENT_TYPE_LATEST


APP_NAME = os.getenv("APP_NAME", "reliability-app")
APP_VERSION = os.getenv("APP_VERSION", "0.1.0")
APP_ENV = os.getenv("APP_ENV", "local")

app = FastAPI(
    title="Kubernetes Reliability Lab App",
    version=APP_VERSION,
    description="A small production-style API for Kubernetes reliability experiments.",
)

REQUEST_COUNT = Counter(
    "reliability_app_requests_total",
    "Total number of requests received by the reliability app",
    ["endpoint"],
)

REQUEST_LATENCY = Histogram(
    "reliability_app_request_latency_seconds",
    "Request latency in seconds",
    ["endpoint"],
)


@app.get("/")
def root() -> Dict[str, str]:
    REQUEST_COUNT.labels(endpoint="/").inc()

    return {
        "app": APP_NAME,
        "version": APP_VERSION,
        "environment": APP_ENV,
        "hostname": socket.gethostname(),
        "message": "Kubernetes Reliability Lab app is running",
    }


@app.get("/healthz")
def healthz() -> Dict[str, str]:
    REQUEST_COUNT.labels(endpoint="/healthz").inc()

    return {
        "status": "ok",
        "check": "liveness",
    }


@app.get("/readyz")
def readyz() -> Dict[str, str]:
    REQUEST_COUNT.labels(endpoint="/readyz").inc()

    return {
        "status": "ready",
        "check": "readiness",
    }


@app.get("/slow")
def slow() -> Dict[str, str]:
    endpoint = "/slow"
    REQUEST_COUNT.labels(endpoint=endpoint).inc()

    with REQUEST_LATENCY.labels(endpoint=endpoint).time():
        time.sleep(2)

    return {
        "status": "ok",
        "message": "This endpoint intentionally waited for 2 seconds.",
    }


@app.get("/fail")
def fail(response: Response) -> Dict[str, str]:
    REQUEST_COUNT.labels(endpoint="/fail").inc()

    response.status_code = status.HTTP_500_INTERNAL_SERVER_ERROR

    return {
        "status": "error",
        "message": "This endpoint intentionally returns HTTP 500.",
    }


@app.get("/cpu")
def cpu() -> Dict[str, str]:
    endpoint = "/cpu"
    REQUEST_COUNT.labels(endpoint=endpoint).inc()

    with REQUEST_LATENCY.labels(endpoint=endpoint).time():
        result = 0
        for number in range(1, 2_000_000):
            result += number * number

    return {
        "status": "ok",
        "message": "CPU load simulation completed.",
        "result": str(result),
    }


@app.get("/metrics")
def metrics() -> Response:
    return Response(
        content=generate_latest(),
        media_type=CONTENT_TYPE_LATEST,
    )
