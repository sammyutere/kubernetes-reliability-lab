import os
import requests
from fastapi import FastAPI, Response
from prometheus_client import Counter, Histogram, generate_latest, CONTENT_TYPE_LATEST

app = FastAPI(title="frontend-service")

SERVICE_NAME = "frontend"
API_URL = os.getenv("API_URL", "http://api:80")
REQUEST_TIMEOUT_SECONDS = float(os.getenv("REQUEST_TIMEOUT_SECONDS", "2"))

REQUESTS = Counter(
    "frontend_http_requests_total",
    "Total HTTP requests handled by frontend service",
    ["path", "status"],
)

LATENCY = Histogram(
    "frontend_http_request_duration_seconds",
    "Frontend request duration",
    ["path"],
)

UPSTREAM_FAILURES = Counter(
    "frontend_upstream_failures_total",
    "Total upstream failures observed by frontend service",
)


@app.get("/")
def root(response: Response):
    with LATENCY.labels(path="/").time():
        try:
            api_response = requests.get(
                f"{API_URL}/api",
                timeout=REQUEST_TIMEOUT_SECONDS,
            )

            if api_response.status_code >= 500:
                UPSTREAM_FAILURES.inc()
                response.status_code = 502
                REQUESTS.labels(path="/", status="502").inc()
                return {
                    "service": SERVICE_NAME,
                    "status": "degraded",
                    "api_status": api_response.status_code,
                }

            REQUESTS.labels(path="/", status="200").inc()
            return {
                "service": SERVICE_NAME,
                "status": "ok",
                "api": api_response.json(),
            }

        except Exception as exc:
            UPSTREAM_FAILURES.inc()
            response.status_code = 504
            REQUESTS.labels(path="/", status="504").inc()
            return {
                "service": SERVICE_NAME,
                "status": "timeout_or_unreachable",
                "error": str(exc),
            }


@app.get("/healthz")
def healthz():
    return {"service": SERVICE_NAME, "status": "healthy"}


@app.get("/readyz")
def readyz():
    return {"service": SERVICE_NAME, "ready": True}


@app.get("/metrics")
def metrics():
    return Response(generate_latest(), media_type=CONTENT_TYPE_LATEST)
