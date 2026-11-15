#!/bin/bash
# Øvelse 13: generer lab-certifikat (self-signed) og secrets. Kør FØR docker compose up.
# certs/ og secrets/ ligger i .gitignore og må aldrig committes.
set -e

mkdir -p certs secrets

# --- secrets ---
if [ ! -f secrets/db_password.txt ]; then
  openssl rand -base64 24 > secrets/db_password.txt
  echo "Nyt admin-password i secrets/db_password.txt"
fi
if [ ! -f secrets/app_password.txt ]; then
  # skal matche lab-passwordet i scripts/init.sql (Del E roterer det)
  echo -n 'lab-app-123' > secrets/app_password.txt
  echo "app_user lab-password i secrets/app_password.txt"
fi

# --- TLS-certifikat (self-signed, kun til lab) ---
if [ ! -f certs/server.crt ]; then
  openssl req -newkey rsa:2048 -nodes \
    -keyout certs/server.key -x509 -days 365 \
    -subj "/CN=oevelse13-db" \
    -addext "subjectAltName=DNS:localhost,DNS:oevelse13-db,IP:127.0.0.1,IP:172.28.0.10" \
    -out certs/server.crt
  chmod 600 certs/server.key
  # inde i containeren kører postgres som uid 999 — giv læserettighed til nøglen
  chown 999:999 certs/server.key 2>/dev/null || \
    echo "NB: chown 999 fejlede (f.eks. Windows uden WSL) — kør så: docker compose exec db chown 999:999 /certs/server.key && docker compose restart db"
  echo "Self-signed certifikat i certs/ (SAN: localhost, 127.0.0.1, 172.28.0.10)"
fi

echo "Klar: kør 'docker compose up -d'"
echo "Platform: kræver openssl (macOS/Linux indbygget; Windows: WSL eller Git Bash)."
