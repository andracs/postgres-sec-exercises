# Status - PostgreSQL Øvelsessamling

## Oversigt

13 øvelser (01-13). Øvelse 07-20 fra den oprindelige struktur er fjernet og erstattet af nye øvelser: 07-11 (logging, roller, transaktioner, triggers, kryptering) samt 12-13 (backup/PITR, TLS/secrets).

## Status pr. øvelse

| Øvelse | Titel | OEVELSE.md | init.sql | facit |
|--------|-------|-----------|----------|-------|
| 01 | Benchmarking og hukommelseskonfiguration med pgbench | ✅ | ✅ (pgbench) | ✅ |
| 02 | Statistik og ANALYZE til bedre query-planer | ✅ | ✅ | ✅ |
| 03 | Læsning af eksekveringsplaner med EXPLAIN | ✅ | ✅ | ✅ |
| 04 | Indekser: hurtigere læsning, langsommere skrivning | ✅ | ✅ | ❌ mangler |
| 05 | Normalisering til 3NF og bevidst denormalisering | ✅ | ✅ | ❌ mangler |
| 06 | Overvågning af forbindelser og queries med pg_stat_activity | ✅ | ✅ | ❌ mangler |
| 07 | Logging og audit af databaseaktivitet | ✅ (ny) | ✅ (ny) | ❌ mangler |
| 08 | Brugeradministration og rettigheder (roller, GRANT/REVOKE, RLS) | ✅ (ny) | ✅ (ny) | ❌ mangler |
| 09 | Transaktioner, isolation og savepoints | ✅ (ny) | ✅ (ny) + to-sessioner.sh | ❌ mangler |
| 10 | Triggers og audit-log | ✅ (ny) | ✅ (ny) | ❌ mangler |
| 11 | Kryptering med pgcrypto | ✅ (ny) | ✅ (ny, kræver contrib — følger med i postgres:18-imagen) | ❌ mangler |
| 12 | Backup og point-in-time recovery (PITR) | ✅ (ny) | ✅ (ny) + pitr-restore.sh | ❌ mangler |
| 13 | PostgreSQL Hardening: Network Access, Authentication, TLS & Secrets (Del A-F + challenge) | ✅ udvidet | ✅ + setup.sh/test-connections.sh/challenge/ | ✅ facit |

## Verificeret

- Alle 13 init.sql kører fejlfrit to gange hver (entrypoint-stil med ON_ERROR_STOP=1 + idempotent genkørsel) på lokal PostgreSQL.
- Alle init-scripts har `DROP TABLE IF EXISTS` (idempotente) og gyldig `SET seed = 0.42`.

## Privat evaluering
Afsluttende 60-min test (DroneTransport Næstved) ligger lokalt i `private-evaluering/` (gitignored, må aldrig pushes).

## Kendte mangler

- Facit for øvelse 04-11
- `docker-compose.yml` for alle øvelser er standard postgres:18 (ingen special-setup nødvendig længere)
