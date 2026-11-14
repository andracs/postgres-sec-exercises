# Facit: Øvelse 12 - Backup og point-in-time recovery (PITR)

## Forventede resultater

### Trin 1: WAL-arkivering
```sql
SHOW wal_level;        -- replica
SHOW archive_mode;    -- on
CHECKPOINT;
SELECT archived_count, failed_count FROM pg_stat_archiver;  -- archived_count > 0
```
```bash
docker compose exec postgres ls /var/lib/postgresql/archive   -- WAL-filer (000000010000000000000001 ...)
```

### Trin 2: logisk backup
```bash
docker compose exec postgres pg_dump -U studie -Fc studiebase > backup/logisk.dump
# katastrofe:
#   DROP TABLE vigtige_data;
docker compose exec postgres createdb -U studie gendannelse
docker compose exec -T postgres pg_restore -U studie -d gendannelse backup/logisk.dump
docker compose exec postgres psql -U studie -d gendannelse -c "SELECT count(*) FROM vigtige_data;"  -- 100
```

### Trin 3-5: markør + base backup + katastrofe
```sql
INSERT INTO vigtige_data (tekst) VALUES ('MARKØR før katastrofe');
CHECKPOINT;
SELECT now();  -- gem dette tidspunkt
```
```bash
docker compose exec postgres pg_basebackup -U studie -D /backup -Ft -z -X stream -P
ls backup/   -- base.tar.gz, pg_wal.tar.gz
```
```sql
INSERT INTO vigtige_data (tekst) SELECT 'EFTER katastrofe ' || i FROM generate_series(1,50) i;
DROP TABLE vigtige_data;
CHECKPOINT;
```

### Trin 6: PITR-gendannelse
```bash
./scripts/pitr-restore.sh "<tidspunkt fra trin 3>"
sleep 5
docker exec oevelse12-pitr psql -U studie -d studiebase -c "SELECT count(*), max(tekst) FROM vigtige_data;"
-- 101 rækker, max(tekst) = 'MARKØR før katastrofe' (ingen EFTER-rækker)
```
Ryd op: `docker rm -f oevelse12-pitr && rm -rf restore_data`

## Svar på refleksion

1. Fordi backup-filer kan være korrupte, forkerte eller ufuldstændige — kun en testet restore garanterer gendannelse.
2. RPO = hvor meget data du må miste (WAL-arkivering → næsten nul); arkiveringsintervallet bestemmer det.
3. Logisk backup ved enkelt-tabel/database-gendannelse og mellem versioner; fysisk ved hele clusteret og PITR.

## Typisk fejl
- `docker compose down -v` sletter også `pgdata` — men `archive/` og `backup/` er bind mounts og overlever, så PITR stadig har WAL.
- Glemmer `recovery.signal` → serveren starter bare normalt på base backuppet uden at afspille WAL til target.
