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
  # inde i postgres-containeren kører serveren som uid 999 — giv den læserettighed
  chown 999:999 certs/server.key 2>/dev/null || echo "NB: chown 999 fejlede (f.eks. Windows uden WSL) — kør så: docker compose exec postgres chown 999:999 /certs/server.key && docker compose restart postgres"
  echo "Genererede self-signed certifikat i certs/"
fi

echo "Klar: kør 'docker compose up -d'"
echo "Platform: kræver openssl (indbygget på macOS/Linux; på Windows brug WSL eller Git Bash)."
