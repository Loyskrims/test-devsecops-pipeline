#!/usr/bin/env bash
set -euo pipefail

docker load -i lab.tar
docker network create zapnet
docker run -d --name app-test --net zapnet lab:ci
sleep 10

ready=0
for i in $(seq 1 30); do
  if docker exec app-test python -c \
    "import urllib.request; print(urllib.request.urlopen('http://127.0.0.1:8000/health', timeout=2).read().decode())"
  then
    echo "Health check passed"
    ready=1
    break
  fi
    sleep 2
done

if [ "$ready" -ne 1 ]; then
  docker logs app-test
  exit 1
fi

docker volume create zap-report
docker run --name zap
    --user root
    --net zapnet
    -v zap-report:/zap/wrk
    ghcr.io/zaproxy/zaproxy:stable@sha256:030d3df57735dacbb83464854758e674dd9ad01d79d12a129a8e58b1fd384238
    zap-baseline.py -t http://app-test:8000 -r report.html -J report.json -I
docker cp zap:/zap/wrk/report.html ./zap.html || true
docker cp zap:/zap/wrk/report.json ./zap.json || true
docker rm zap