from fastapi.testclient import TestClient

from src.main import app


client = TestClient(app)


def test_root_returns_app_info():
    response = client.get("/")

    assert response.status_code == 200

    body = response.json()

    assert body["app"] == "reliability-app"
    assert body["environment"] == "local"
    assert "hostname" in body


def test_healthz_returns_ok():
    response = client.get("/healthz")

    assert response.status_code == 200
    assert response.json()["status"] == "ok"
    assert response.json()["check"] == "liveness"


def test_readyz_returns_ready():
    response = client.get("/readyz")

    assert response.status_code == 200
    assert response.json()["status"] == "ready"
    assert response.json()["check"] == "readiness"


def test_fail_returns_500():
    response = client.get("/fail")

    assert response.status_code == 500
    assert response.json()["status"] == "error"


def test_metrics_endpoint_returns_prometheus_metrics():
    response = client.get("/metrics")

    assert response.status_code == 200
    assert "reliability_app_requests_total" in response.text
