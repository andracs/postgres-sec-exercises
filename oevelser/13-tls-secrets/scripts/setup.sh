#!/bin/bash
# Genererer self-signed certifikat og en secret-fil med database-password.
# certs/ og secrets/ ligger i .gitignore og bliver aldrig committed.
set -e

mkdir -p certs secrets

if [ ! -f secrets/db_password.txt ]; then
  openssl rand -base64 24 > secrets/db_password.txt
  echo "Genererede nyt password i secrets/db_password.txt"
fi

if [ ! -f certs/server.crt ]; then
  openssl req -newkey rsa:2048 -nodes \
    -keyout certs/server.key -x509 -days 365 \
    -subj "/CN=localhost" \
    -addext "subjectAltName=DNS:localhost,IP:127.0.0.1" \
    -out certs/server.crt
  chmod 600 certs/server.key
  echo "Genererede self-signed certifikat i certs/"
fi

echo "Klar: kør 'docker compose up -d'"
