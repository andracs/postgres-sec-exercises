#!/bin/bash
# Gendanner base backuppet i en NY container på port 5433 op til et valgt tidspunkt (PITR).
# Kør på hosten fra øvelsens mappe:  ./scripts/pitr-restore.sh "2026-11-14 14:00:00"
set -e

TARGET_TIME="${1:?Angiv recovery_target_time, f.eks. './scripts/pitr-restore.sh \"2026-11-14 14:00:00\"'}"

mkdir -p restore_data
tar -xzf backup/base.tar.gz -C restore_data
tar -xzf backup/pg_wal.tar.gz -C restore_data/pg_wal 2>/dev/null || true
touch restore_data/recovery.signal

docker run -d --name oevelse12-pitr -p 5433:5432 \
  -e PGDATA=/var/lib/postgresql/data \
  -e POSTGRES_PASSWORD=studie \
  -v "$PWD/restore_data":/var/lib/postgresql/data \
  -v "$PWD/archive":/archive \
  postgres:18 \
  -c restore_command='cp /archive/%f %p' \
  -c recovery_target_time="$TARGET_TIME" \
  -c recovery_target_action=promote

echo "PITR-container kører på port 5433. Tjek med:"
echo "  docker exec oevelse12-pitr psql -U studie -d studiebase -c 'SELECT count(*), max(oprettet) FROM vigtige_data;'"
echo "Ryd op med:  docker rm -f oevelse12-pitr && rm -rf restore_data"
