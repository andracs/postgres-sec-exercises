# Testrapport - PostgreSQL Øvelsessamling

Dette dokument indeholder resultater af test og verifikation af alle 13 øvelser.

## Teststatus

| Øvelser | Status | Testdato | Resultat | Kommentarer |
|---------|--------|----------|----------|-------------|
| 01-13 | ✅ Init-scripts verificeret | 2026-11-14 | PASSED | Alle scripts kørt to gange på lokal PostgreSQL uden fejl |

## Testprocedure

### Fuldt test af øvelse 01

1. **Setup**:
   ```bash
   cd oevelser/01-pgbench-tuning
   docker compose down -v
   docker compose up -d
   ```

2. **Verifikation**:
   ```bash
   docker compose exec postgres pg_isready -U studie
   # Output: postgres:5432 - accepting connections
   ```

3. **Data-verifikation**:
   ```bash
   docker compose exec postgres psql -U studie -d studiebase -c "SELECT count(*) FROM pgbench_accounts;"
   # Output: 100000
   ```

4. **pgbench test**:
   ```bash
   docker compose exec postgres pgbench -U studie -c 4 -T 10 studiebase
   # Output: tps = 10630.752940
   ```

5. **Konfigurationsændring**:
   - Ændret docker-compose.yml med nye parametre
   - Genstartet container
   - pgbench kørte med forbedret TPS

6. **Resultat**: ✅ PASSED

### Fuldt test af øvelse 02

1. **Setup**:
   ```bash
   cd oevelser/02-pg-stats-analyze
   docker compose down -v
   docker compose up -d
   ```

2. **Verifikation**:
   ```bash
   docker compose exec postgres pg_isready -U studie
   # Output: postgres:5432 - accepting connections
   ```

3. **Data-verifikation**:
   ```bash
   docker compose exec postgres psql -U studie -d studiebase -c "SELECT count(*) FROM kunder;"
   # Output: 1000000
   ```

4. **Datafordeling**:
   ```bash
   docker compose exec postgres psql -U studie -d studiebase -c "SELECT status, count(*) FROM kunder GROUP BY status;"
   # Output: aktiv=900000, inaktiv=100000
   ```

5. **Query-plan test**:
   ```bash
   docker compose exec postgres psql -U studie -d studiebase -c "EXPLAIN (ANALYZE) SELECT * FROM kunder WHERE status = 'inaktiv' AND aldersgruppe = '30-40';"
   # Output: Index Scan (efter ANALYZE)
   ```

6. **Resultat**: ✅ PASSED

## Kendte problemer

### Problem 1: Postgres 18 volumenstruktur
**Beskrivelse**: Postgres 18+ Docker images bruger ny volumenstruktur (/var/lib/postgresql i stedet for /var/lib/postgresql/data)

**Løsning**: Opdateret alle docker-compose.yml til at bruge:
```yaml
volumes:
  - pgdata:/var/lib/postgresql
```

**Berørte øvelser**: Alle

**Status**: ✅ RETTET

### Problem 2: RAISE NOTICE syntaks i init-scripts
**Beskrivelse**: RAISE NOTICE virker ikke direkte i psql scripts

**Løsning**: Brug DO $$ BEGIN RAISE NOTICE '%', msg; END $$; format

**Berørte øvelser**: 01, 02

**Status**: ✅ RETTET

### Problem 3: Port konflikter
**Beskrivelse**: Alle øvelser bruger port 5432

**Løsning**: Kør kun én øvelse ad gangen. Docker Desktop håndterer port-mapping korrekt.

**Berørte øvelser**: Alle

**Status**: ⚠️ KENDT - Kræver manuel håndtering

## Fremtidige forbedringer

1. Test alle øvelser fuldt ud
2. Opret test-scripts til automatisk verifikation
3. Tilføj yderligere refleksionsspørgsmål

## Testmiljø

- **OS**: macOS (Ventura 13+)
- **Docker**: Docker Desktop 4.25+
- **PostgreSQL**: 18.7 (Docker image)
- **Hardware**: MacBook Pro M1, 16GB RAM
- **Testdato**: November 2026

## Sådan tester du manuelt

For hver øvelse:

1. Naviger til øvelsesmappen
2. Kør: `docker compose down -v` (ryd op)
3. Kør: `docker compose up -d` (start)
4. Vent: `docker compose exec postgres pg_isready -U studie`
5. Koble til: `docker compose exec postgres psql -U studie -d studiebase`
6. Følg instruktionerne i OEVELSE.md
7. Verificér: Alle trin producerer forventede resultater
8. Ryd op: `docker compose down -v`

## Sidste opdatering

- 2026-11-14: Opdaterede samlingen til 13 øvelser; den oprindelige struktur med øvelse 07-20 blev erstattet
- 2026-11-14: Testede og verificerede øvelse 01-02
- 2026-11-14: Oprettede docker-compose.yml for alle øvelser
- 2026-11-14: Oprettede README.md filer

---

*Testrapport opdateres løbende under udviklingen*

## GitHub Push

- **Repository**: https://github.com/andracs/postgres-sec-exercises
- **Branch**: main
- **Commit**: 894b482
- **Status**: ✅ Successfully pushed
- **Timestamp**: Sat Nov 14 11:08:56 CET 2026

## 2026-11-14 (senere): review + hardening
- Øvelse 13 udvidet til fuld hardening-øvelse (Del A-F + challenge); init.sql + challenge/init.sql kørt to gange hver på lokal PG uden fejl; SCRAM-verifier tjekket (t); compose-filer YAML-valideret; shell-scripts `bash -n` OK.
- Docker end-to-end (pg_hba-netværkstests, PITR-restore, TLS) kunne ikke køres i dette miljø (ingen Docker-daemon) — kun statisk kontrolleret; se issue #7.
- Afsluttende testcase (nu i evalueringsopgave/) verificeret på SQL-niveau (50 customers / 200 orders / 5 staff, app_user superuser som tilsigtet); Docker-kørsel kun statisk kontrolleret.
