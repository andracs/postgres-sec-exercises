# PostgreSQL Security & Administration - Læringsstier

Tre fokuserede stier gennem de 13 øvelser. Vælg efter niveau og interesse.

---

## Sti 1: Fundament (Nybegynder)
**Fokus:** Måling, planlægning og overvågning
**Tid:** ~4 timer

1. **01 - Benchmarking og hukommelseskonfiguration med pgbench** (30-45 min)
2. **02 - Statistik og ANALYZE til bedre query-planer** (30 min)
3. **03 - Læsning af eksekveringsplaner med EXPLAIN** (45 min)
4. **04 - Indekser: hurtigere læsning, langsommere skrivning** (45 min)
5. **06 - Overvågning af forbindelser og queries med pg_stat_activity** (45 min)
6. **07 - Logging og audit af databaseaktivitet** (45 min)

---

## Sti 2: Sikkerhed (Alle)
**Fokus:** Adgangskontrol, audit, integritet, kryptering og TLS
**Tid:** ~3,5 timer

1. **07 - Logging og audit af databaseaktivitet** (45 min)
2. **08 - Brugeradministration og rettigheder (roller, GRANT/REVOKE, RLS)** (45 min)
3. **10 - Triggers og audit-log** (45 min)
4. **11 - Kryptering med pgcrypto** (45 min)
5. **13 - TLS på forbindelsen og secrets management** (60 min)

---

## Sti 3: Drift & data (DBA'er / udviklere)
**Fokus:** Datamodellering, transaktioner, backup og recovery
**Tid:** ~4,5 timer

1. **05 - Normalisering til 3NF og bevidst denormalisering** (60 min)
2. **09 - Transaktioner, isolation og savepoints** (60 min, brug to sessioner)
3. **12 - Backup og point-in-time recovery (PITR)** (75 min)
4. **13 - TLS og secrets** (60 min) — også på denne sti, hvis ikke kørt på Sti 2

---


---

## Sti 4: PBA IT-sikkerhed (5 t i klassen + 3 t hjemme)
**Fokus:** Sikkerhed i praksis for PBA IT-sikkerhed
**Tid:** 5 t i klassen + 3 t hjemme

**I klassen (5 t):**
1. **01 - Benchmarking og hukommelseskonfiguration med pgbench** (45 min)
2. **02 - Statistik og ANALYZE til bedre query-planer** (30 min)
3. **03 - Læsning af eksekveringsplaner med EXPLAIN** (45 min)
4. **04 - Indekser: hurtigere læsning, langsommere skrivning** (45 min)
5. **07 - Logging og audit af databaseaktivitet** (45 min)
6. **08 - Brugeradministration og rettigheder (roller, GRANT/REVOKE, RLS)** (60 min)

**Hjemme (3 t):**
1. **09 - Transaktioner, isolation og savepoints** (60 min)
2. **10 - Triggers og audit-log** (45 min)
3. **11 - Kryptering med pgcrypto** (45 min)
4. Start på **12 - Backup/PITR** og **13 - PostgreSQL Hardening** (30 min)

Ugen efter: den afsluttende 60-minutters praktiske test (udleveres separat af underviseren).

---

## Tips

- Start hver øvelse med `docker compose up -d`, vent på `pg_isready`, og ryd op med `docker compose down -v` bagefter.
- Alle init-scripts er idempotente (DROP TABLE IF EXISTS), så du kan køre dem igen med `\i /docker-entrypoint-initdb.d/01-init.sql`.
- Øvelse 09 bruger to samtidige psql-sessioner (`./scripts/to-sessioner.sh`).
- Øvelse 13 kører `./scripts/setup.sh` først (certifikater + secret).
- Facit findes i [facit/](/facit/) for øvelse 01-03.

## Systemkrav

- Docker Desktop eller Podman
- 8 GB RAM anbefalet
- `openssl` og `psql` på hosten (øvelse 13)
- Ca. 2 GB ledig diskplads
