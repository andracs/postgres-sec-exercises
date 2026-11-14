# Øvelse 04: Indeksøkonomi - fart er ikke gratis

## Formål
At demonstrere, at indeks forbedrer læseperformance men forringes skriveperformance. Du vil måle query-tider med og uden indeks, og observere omkostningerne ved INSERT/UPDATE.

## Forudsætninger
- Docker Desktop eller Podman installeret
- Minimum 4 GB RAM til rådighed for Docker
- Grundlæggende kendskab til SQL og psql

## Start

1. Naviger til øvelsens mappe:
   ```bash
   cd oevelser/04-indeksokonomi
   ```

2. Start Postgres-containeren:
   ```bash
   docker compose up -d
   ```

3. Vent på, at databasen er klar:
   ```bash
   docker compose exec postgres pg_isready -U studie
   ```

4. Koble til databasen:
   ```bash
   docker compose exec postgres psql -U studie -d studiebase
   ```

## Opgaver

### 1. Opret testtabel og data
Seed-scriptet opretter en tabel med 1 million ordrer. Verificér:
```sql
SELECT count(*) FROM ordrer;
```
**Tjek:** 1.000.000 rækker

### 2. Mål query-performance UDEN indeks
Aktivér timing:
```sql
\timing on
```

Kør query uden indeks:
```sql
SELECT * FROM ordrer WHERE kunde_id = 5000 AND status = 'afsluttet';
```
**Notér:** Eksekveringstiden (typisk 50-200 ms med seq scan)

Aflæs planen:
```sql
EXPLAIN (ANALYZE) SELECT * FROM ordrer WHERE kunde_id = 5000 AND status = 'afsluttet';
```
**Tjek:** Seq Scan

### 3. Opret indeks og måle forbedring
Opret indeks på kunde_id:
```sql
CREATE INDEX idx_ordrer_kunde ON ordrer(kunde_id);
```

Mål query igen:
```sql
SELECT * FROM ordrer WHERE kunde_id = 5000 AND status = 'afsluttet';
```
**Notér:** Forbedret tid (typisk 1-5 ms)

Aflæs planen:
```sql
EXPLAIN (ANALYZE) SELECT * FROM ordrer WHERE kunde_id = 5000 AND status = 'afsluttet';
```
**Tjek:** Index Scan

### 4. Opret sammensat indeks
Opret indeks på begge kolonner:
```sql
CREATE INDEX idx_ordrer_kunde_status ON ordrer(kunde_id, status);
```

Mål query igen. Bør være endnu hurtigere.

### 5. Mål skrive-performance
Mål INSERT-tid UDEN indeks (fjern indeksene først):
```sql
DROP INDEX IF EXISTS idx_ordrer_kunde;
DROP INDEX IF EXISTS idx_ordrer_kunde_status;

\timing on
INSERT INTO ordrer (kunde_id, status, beloeb, ordre_dato)
SELECT 
    (random() * 10000)::INTEGER + 1,
    CASE WHEN random() > 0.5 THEN 'afsluttet' ELSE 'pendende' END,
    (random() * 10000)::NUMERIC(10,2),
    NOW()
FROM generate_series(1, 10000) AS i;
```
**Notér:** Tid for 10.000 INSERTs

### 6. Mål skrive-performance MED indeks
Opret indeksene igen og måle INSERT-tid:
```sql
CREATE INDEX idx_ordrer_kunde ON ordrer(kunde_id);
CREATE INDEX idx_ordrer_kunde_status ON ordrer(kunde_id, status);

INSERT INTO ordrer (kunde_id, status, beloeb, ordre_dato)
SELECT 
    (random() * 10000)::INTEGER + 1,
    CASE WHEN random() > 0.5 THEN 'afsluttet' ELSE 'pendende' END,
    (random() * 10000)::NUMERIC(10,2),
    NOW()
FROM generate_series(1, 10000) AS i;
```
**Notér:** Tid for 10.000 INSERTs med indeks (typisk 2-5x langsommere)

### 7. Find ubrugte indekser
Kør et load af queries og tjek derefter:
```sql
-- Kør nogle queries
SELECT * FROM ordrer WHERE kunde_id = 100;
SELECT * FROM ordrer WHERE status = 'afsluttet';

-- Tjek indeksbrug
SELECT 
    schemaname,
    relname,
    indexrelname,
    idx_scan,
    idx_tup_read,
    idx_tup_fetch
FROM pg_stat_user_indexes 
WHERE schemaname = 'public';
```
**Tjek:** idx_scan viser, hvor mange gange indekset er blevet brugt

### 8. Ryd op
Fjern testdata:
```sql
DELETE FROM ordrer WHERE id > 1000000;
VACUUM;
```

## Refleksion

1. Hvorfor er et sammensat indeks (kunde_id, status) mere effektivt end to separate indeks?
2. Hvilke faktorer bør du overveje, når du beslutter, om et indeks er værd at oprette?
3. Hvordan kan du identificere ubrugte indeks i en produktionsdatabase?

## Det har du lært

- Indekser forbedrer læseperformance væsentligt
- Indekser forringes skriveperformance (INSERT/UPDATE/DELETE)
- Sammensatte indeks er ofte mere effektive end separate indeks
- Ubrugte indeks spilder plads og forringer skriveperformance
- pg_stat_user_indexes viser, hvilke indeks der bliver brugt
- Indeksvalg er et kompromis mellem læse- og skriveperformance