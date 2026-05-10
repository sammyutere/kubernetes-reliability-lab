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


## Build container image

```bash
docker build -t reliability-app:local ./app
```

## Run container

```bash
docker run --rm -p 8000:8000 reliability-app:local
```

## Test container

```bash
curl http://127.0.0.1:8000/healthz
curl http://127.0.0.1:8000/readyz
curl http://127.0.0.1:8000/metrics
```

## Run container in background

```bash
docker run -d --name reliability-app-test -p 8000:8000 reliability-app:local
docker logs reliability-app-test
docker stop reliability-app-test
docker rm reliability-app-test
```
