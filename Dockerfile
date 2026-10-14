FROM python:3.14-slim@sha256:a2b82f3c48559aa0a8446d9af49826b6e2b2016f4cd2afabfe6013ec53729170 AS builder

WORKDIR /build

RUN apt-get update \
    && apt-get upgrade -y \
    && rm -rf /var/lib/apt/lists/* \
    && python -m venv /venv

ENV PATH="/venv/bin:$PATH"

COPY requirements.txt .

RUN pip install --no-cache-dir -r requirements.txt

RUN pip install --no-cache-dir --upgrade \
    "urllib3==2.8.0" \
    "msgpack==1.2.1" \
    "setuptools==83.0.0"

RUN pip show urllib3 msgpack setuptools


FROM python:3.14-slim@sha256:a2b82f3c48559aa0a8446d9af49826b6e2b2016f4cd2afabfe6013ec53729170

RUN apt-get update \
    && apt-get upgrade -y \
    && python -m pip install --no-cache-dir --upgrade setuptools \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY --from=builder /venv /venv
COPY --chown=10001:10001 app ./app

ENV PATH="/venv/bin:$PATH" PYTHONDONTWRITEBYTECODE=1 PYTHONUNBUFFERED=1

USER 10001:10001

EXPOSE 8000

CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]
