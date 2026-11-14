# Testrapport - PostgreSQL Øvelsessamling

Dette dokument indeholder resultater af test og verifikation af alle 20 øvelser.

## Teststatus

| Øvelse | Status | Testdato | Resultat | Kommentarer |
|--------|--------|----------|----------|-------------|
| 01 | ✅ Testet | 2026-11-14 | PASSED | Container starter, pgbench kører, TPS måles korrekt |
| 02 | ✅ Testet | 2026-11-14 | PASSED | Datafordeling korrekt, ANALYZE forbedrer planen |
| 03 | ✅ Struktureret | 2026-11-14 | PENDING | Skema oprettet, mangler fuld test |
| 04 | ✅ Struktureret | 2026-11-14 | PENDING | Skema oprettet, mangler fuld test |
| 05 | ✅ Struktureret | 2026-11-14 | PENDING | Skema oprettet, mangler fuld test |
| 06 | ⚠️ Stub | - | NOT TESTED | Mangler indhold |
| 07 | ⚠️ Stub | - | NOT TESTED | Mangler indhold |
| 08 | ⚠️ Stub | - | NOT TESTED | Mangler indhold |
| 09 | ⚠️ Stub | - | NOT TESTED | Mangler indhold |
| 10 | ⚠️ Stub | - | NOT TESTED | Mangler indhold |
| 11 | ⚠️ Stub | - | NOT TESTED | Mangler indhold |
| 12 | ⚠️ Stub | - | NOT TESTED | Mangler indhold |
| 13 | ⚠️ Stub | - | NOT TESTED | Mangler indhold |
| 14 | ⚠️ Stub | - | NOT TESTED | Mangler indhold (kræver PostGIS image) |
| 15 | ⚠️ Stub | - | NOT TESTED | Mangler indhold (kræver PgBouncer image) |
| 16 | ⚠️ Stub | - | NOT TESTED | Mangler indhold |
| 17 | ⚠️ Stub | - | NOT TESTED | Mangler indhold (kræver 2 containere) |
| 18 | ⚠️ Stub | - | NOT TESTED | Mangler indhold (kræver 3 containere) |
| 19 | ⚠️ Stub | - | NOT TESTED | Mangler indhold (kræver 2 containere) |
| 20 | ⚠️ Stub | - | NOT TESTED | Mangler indhold (integreret øvelse) |

## Testprocedure

### Fuldt test af øvelse 01

1. **Setup**:
   ```bash
   cd oevelser/01-kanariefuglen
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
   cd oevelser/02-statistik-er-ikke-et-fyord
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

### Høj prioritet:
1. Færdiggør indhold for øvelse 03-05
2. Test alle færdige øvelser fuldt ud
3. Opret to-sessioner.sh scripts for øvelse 09, 10, 11

### Medium prioritet:
1. Færdiggør indhold for øvelse 06-10
2. Opret specielle docker-compose.yml for:
   - Øvelse 14: PostGIS image
   - Øvelse 15: PgBouncer + Postgres
   - Øvelse 17: 2 containere (source + archive)
   - Øvelse 18: 3 containere (primary + 2 replicas)
   - Øvelse 19: 2 containere (old + new version)

### Lav prioritet:
1. Færdiggør indhold for øvelse 11-20
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

- 2026-11-14: Oprettede grundlæggende struktur for alle 20 øvelser
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
