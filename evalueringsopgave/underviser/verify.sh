#!/bin/bash
# Underviser-verifikation af DroneTransport-casen. Kør før og efter studentens ændringer:
#   ./underviser/verify.sh
# Udskriver BEFORE/AFTER-relevante værdier fra den kørende case.
set -u
cd "$(dirname "$0")/.."

PSQL="docker compose exec -T db psql -U postgres -d dronetransport -tA -c"

echo "== 1) Autentifikation i pg_hba (trust = USIKKERT) =="
docker compose exec -T db cat /etc/postgresql/pg_hba.conf | grep -v '^#' | grep -v '^$'

echo "== 2) TLS =="
$PSQL "SHOW ssl;"

echo "== 3) Logging =="
$PSQL "SHOW log_connections; SHOW log_statement;"

echo "== 4) Backup/WAL =="
$PSQL "SHOW archive_mode;"

echo "== 5) Roller og privilegier =="
$PSQL "SELECT rolname || ': superuser=' || rolsuper FROM pg_roles WHERE rolname IN ('app_user','reader');"
$PSQL "SELECT grantee || ' -> ' || table_name || ': ' || string_agg(privilege_type, ',') FROM information_schema.role_table_grants WHERE table_name IN ('customers','orders','staff') GROUP BY 1,2;"

echo "== 6) Data findes (syntetiske) =="
$PSQL "SELECT 'customers=' || count(*) FROM customers;"
$PSQL "SELECT 'orders=' || count(*) FROM orders;"
$PSQL "SELECT 'staff=' || count(*) FROM staff;"

echo "== 7) Negativ adgangstest (hvis trust stadig står): forbind uden password =="
docker compose exec -T db psql -U postgres -d dronetransport -c "SELECT 'login uden password lykkedes' AS problem;" 2>&1 | tail -2
