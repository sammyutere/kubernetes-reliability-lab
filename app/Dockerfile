FROM python:3.11-slim

LABEL maintainer="sammyutere"
LABEL app="reliability-app"
LABEL description="FastAPI app for Kubernetes reliability engineering lab"

ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1
ENV APP_NAME=reliability-app
ENV APP_VERSION=0.1.0
ENV APP_ENV=container

WORKDIR /app

RUN addgroup --system appgroup && adduser --system --ingroup appgroup appuser

COPY requirements.txt .

RUN pip install --no-cache-dir --upgrade pip \
    && pip install --no-cache-dir -r requirements.txt

COPY src ./src

USER appuser

EXPOSE 8000

CMD ["uvicorn", "src.main:app", "--host", "0.0.0.0", "--port", "8000"]
