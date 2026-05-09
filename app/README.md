# Reliability App

Small FastAPI service used for Kubernetes reliability engineering experiments.

## Endpoints

| Endpoint | Purpose |
|---|---|
| `/` | Returns app metadata and hostname |
| `/healthz` | Liveness probe endpoint |
| `/readyz` | Readiness probe endpoint |
| `/metrics` | Prometheus metrics |
| `/slow` | Simulates latency |
| `/fail` | Simulates HTTP 500 failure |
| `/cpu` | Simulates CPU load |

## Run locally

```bash
python3 -m venv .venv
source .venv/bin/activate
pip install -r app/requirements.txt
cd app
PYTHONPATH=. uvicorn src.main:app --reload --host 127.0.0.1 --port 8000

## Run tests

```bash
cd app
PYTHONPATH=. pytest -v
```

