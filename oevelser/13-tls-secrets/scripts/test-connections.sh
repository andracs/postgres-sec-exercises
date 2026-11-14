#!/bin/bash
# Øvelse 13, Del B: kører de 4 forbindelsestests og udskriver PASS/FAIL.
# Kør fra øvelsens mappe efter `./scripts/setup.sh && docker compose up -d`.
set -u
cd "$(dirname "$0")/.."

DB=172.28.0.10
APP_PW=$(cat secrets/app_password.txt)
DB_PW=$(cat secrets/db_password.txt)
PASS=0; FAIL=0

t() { # navn, forventet(ok|fail), faktisk exit-kode
  local name="$1" expected="$2" rc="$3"
  if { [ "$expected" = ok ] && [ "$rc" = 0 ]; } || { [ "$expected" = fail ] && [ "$rc" != 0 ]; }; then
    echo "PASS  $name"; PASS=$((PASS+1))
  else
    echo "FAIL  $name (forventede $expected, fik exit=$rc)"; FAIL=$((FAIL+1))
  fi
}

echo "== 1) Autoriseret app (app-net, TLS, korrekt password) skal ACCEPTES =="
docker compose exec -T app psql "host=$DB user=app_user dbname=appdb sslmode=require password=$APP_PW" -c "SELECT count(*) FROM app_data;" >/dev/null 2>&1
t "app fra app-net med TLS + korrekt password" ok $?

echo "== 2) Uautoriseret klient (attack-net) skal AFVISES =="
docker compose exec -T attacker psql "host=172.29.0.10 user=app_user dbname=appdb sslmode=require password=$APP_PW" -c "SELECT 1;" >/dev/null 2>&1
t "attacker fra attack-net (172.29.x) afvises af pg_hba" fail $?

echo "== 3) Forkert password skal AFVISES (SCRAM) =="
docker compose exec -T app psql "host=$DB user=app_user dbname=appdb sslmode=require password=forkert" -c "SELECT 1;" >/dev/null 2>&1
t "forkert password afvises" fail $?

echo "== 4) Forbindelse uden TLS skal AFVISES =="
docker compose exec -T app psql "host=$DB user=app_user dbname=appdb sslmode=disable password=$APP_PW" -c "SELECT 1;" >/dev/null 2>&1
t "sslmode=disable afvises (hostnossl/reject)" fail $?

echo
echo "Resultat: $PASS PASS, $FAIL FAIL (forvent 4 PASS)"
[ "$FAIL" = 0 ]
