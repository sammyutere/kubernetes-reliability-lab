import os
import time
import requests
from fastapi import FastAPI, Response
from prometheus_client import Counter, Histogram, generate_latest, CONTENT_TYPE_LATEST

app = FastAPI(title="api-service")

SERVICE_NAME = "api"
DEPENDENCY_URL = os.getenv("DEPENDENCY_URL", "http://dependency:80")
REQUEST_TIMEOUT_SECONDS = float(os.getenv("REQUEST_TIMEOUT_SECONDS", "2"))

REQUESTS = Counter(
    "api_http_requests_total",
    "Total HTTP requests handled by api service",
    ["path", "status"],
)

LATENCY = Histogram(
    "api_http_request_duration_seconds",
    "API service request duration",
    ["path"],
)

DEPENDENCY_FAILURES = Counter(
    "api_dependency_failures_total",
    "Total dependency call failures observed by api service",
)


@app.get("/")
def root():
    return {"service": SERVICE_NAME, "status": "ok", "dependency_url": DEPENDENCY_URL}


@app.get("/healthz")
def healthz():
    return {"service": SERVICE_NAME, "status": "healthy"}


@app.get("/readyz")
def readyz():
    return {"service": SERVICE_NAME, "ready": True}


@app.get("/api")
def api(response: Response):
    with LATENCY.labels(path="/api").time():
        try:
            dep_response = requests.get(
                f"{DEPENDENCY_URL}/data",
                timeout=REQUEST_TIMEOUT_SECONDS,
            )

            if dep_response.status_code >= 500:
                DEPENDENCY_FAILURES.inc()
                response.status_code = 502
                REQUESTS.labels(path="/api", status="502").inc()
                return {
                    "service": SERVICE_NAME,
                    "status": "degraded",
                    "dependency_status": dep_response.status_code,
                }

            REQUESTS.labels(path="/api", status="200").inc()
            return {
                "service": SERVICE_NAME,
                "status": "ok",
                "dependency": dep_response.json(),
            }

        except Exception as exc:
            DEPENDENCY_FAILURES.inc()
            response.status_code = 504
            REQUESTS.labels(path="/api", status="504").inc()
            return {
                "service": SERVICE_NAME,
                "status": "timeout_or_unreachable",
                "error": str(exc),
            }


@app.get("/metrics")
def metrics():
    return Response(generate_latest(), media_type=CONTENT_TYPE_LATEST)
