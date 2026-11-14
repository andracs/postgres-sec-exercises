# PostgreSQL Security & Administration - Læringsstier

Tre fokuserede stier gennem de 11 øvelser. Vælg efter niveau og interesse.

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
**Fokus:** Adgangskontrol, audit, integritet og kryptering
**Tid:** ~3 timer

1. **07 - Logging og audit af databaseaktivitet** (45 min)
2. **08 - Brugeradministration og rettigheder (roller, GRANT/REVOKE, RLS)** (45 min)
3. **10 - Triggers og audit-log** (45 min)
4. **11 - Kryptering med pgcrypto** (45 min)

---

## Sti 3: Data & samtidighed (Udviklere)
**Fokus:** Datamodellering og transaktioner
**Tid:** ~2 timer

1. **05 - Normalisering til 3NF og bevidst denormalisering** (60 min)
2. **09 - Transaktioner, isolation og savepoints** (60 min, brug to sessioner)

---

## Tips

- Start hver øvelse med `docker compose up -d`, vent på `pg_isready`, og ryd op med `docker compose down -v` bagefter.
- Alle init-scripts er idempotente (DROP TABLE IF EXISTS), så du kan køre dem igen med `\i /docker-entrypoint-initdb.d/01-init.sql`.
- Øvelse 09 bruger to samtidige psql-sessioner (`./scripts/to-sessioner.sh`).
- Facit findes i [facit/](/facit/) for øvelse 01-03.

## Systemkrav

- Docker Desktop eller Podman
- 8 GB RAM anbefalet
- Ca. 2 GB ledig diskplads
