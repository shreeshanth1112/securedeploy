FROM docker.io/library/python:3.12-slim

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

RUN apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get upgrade -y \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt \
    && python -m pip uninstall -y pip

COPY app ./app
COPY run.py .

RUN groupadd --system --gid 10001 appgroup \
    && useradd --system --uid 10001 --gid 10001 \
       --no-create-home --shell /usr/sbin/nologin appuser

USER 10001:10001

LABEL org.opencontainers.image.source="https://github.com/shreeshanth1112/securedeploy"

EXPOSE 5000

CMD ["gunicorn", "-b", "0.0.0.0:5000", "-w", "2", "--access-logfile", "-", "--no-control-socket", "run:app"]
