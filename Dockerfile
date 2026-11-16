FROM python:3.13-slim AS base

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

RUN apt-get update \
    && apt-get upgrade -y --no-install-recommends \
    && rm -rf /var/lib/apt/lists/*

FROM base AS builder

WORKDIR /app

RUN python -m venv /opt/venv

ENV PATH="/opt/venv/bin:$PATH"

COPY requirements.txt .

RUN python -m pip install --no-cache-dir -r requirements.txt \
    && python -m pip check \
    && python -m pip uninstall -y pip setuptools

FROM base AS runtime

WORKDIR /app

RUN python -m pip uninstall -y pip setuptools

ENV PATH="/opt/venv/bin:$PATH"

COPY --from=builder /opt/venv /opt/venv

COPY main.py .

EXPOSE 8000

HEALTHCHECK --interval=10s --timeout=3s --start-period=10s --retries=3 \
    CMD [ "python","-c", "import json, urllib.request; r = urllib.request.urlopen('http://127.0.0.1:8000/health', timeout=2); data = json.load(r); assert data.get('status') == 'healthy'" ]

CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]