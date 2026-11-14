# Øvelse 02: Statistik og ANALYZE til bedre query-planer

## Formål
At demonstrere, hvordan manglende eller forældet statistik kan føre til suboptimale query-planer. Du vil oprette data med skæv fordeling, observere planlæggerens beslutninger uden statistik, og se forbedringen efter ANALYZE.

## Forudsætninger
- Docker Desktop eller Podman installeret
- Minimum 4 GB RAM til rådighed for Docker
- Grundlæggende kendskab til SQL og psql

## Start

1. Naviger til øvelsens mappe:
   ```bash
   cd oevelser/02-statistik-er-ikke-et-fyord
   ```

2. Start Postgres-containeren:
   ```bash
   docker compose up -d
   ```

3. Vent på, at databasen er klar:
   ```bash
   docker compose exec postgres pg_isready -U studie
   ```
   Forventet output: `postgres:5432 - accepting connections`

4. Koble til databasen:
   ```bash
   docker compose exec postgres psql -U studie -d studiebase
   ```

## Opgaver

### 1. Opret tabel med skæv datafordeling
Kør seed-scriptet ( allerede kørt via docker-entrypoint, men du kan køre det manuelt):
```sql
\i /docker-entrypoint-initdb.d/01-init.sql
```

Tjek datafordelingen:
```sql
SELECT status, count(*) FROM kunder GROUP BY status ORDER BY count(*) DESC;
```
**Tjek:** Du skal se, at 90% af kunderne har status = 'aktiv' og 10% har status = 'inaktiv'

> **Bemærk:** Eksekveringsplaner kan variere lidt mellem PostgreSQL-versioner og afhængigt af statistik. Tjek mønsteret (Seq Scan vs Index Scan), ikke de eksakte cost-tal.
>
> Autovacuum er slået fra for `kunder` i init.sql, så statistikken ikke opdateres af sig selv undervejs. Slå det til igen til sidst: `ALTER TABLE kunder SET (autovacuum_enabled = on); ANALYZE kunder;`

### 2. Kør query uden statistik og aflæs planen
Kør følgende query og observér eksekveringsplanen:
```sql
EXPLAIN (ANALYZE, BUFFERS) 
SELECT * FROM kunder WHERE status = 'inaktiv' AND aldersgruppe = '30-40';
```
**Notér:** Planen vil sandsynligvis bruge en **sequential scan** fordi planlæggeren ikke kender datafordelingen.

### 3. Kør ANALYZE
Kør statistik-opdatering:
```sql
ANALYZE kunder;
```

### 4. Kør query igen med statistik
Kør den samme query igen:
```sql
EXPLAIN (ANALYZE, BUFFERS) 
SELECT * FROM kunder WHERE status = 'inaktiv' AND aldersgruppe = '30-40';
```
**Tjek:** Planen burde nu bruge en **index scan** og være væsentligt hurtigere.

### 5. Sammenlign eksekveringstider
Kør begge queries adskillige gange med `\timing on`:
```sql
\timing on
SELECT count(*) FROM kunder WHERE status = 'inaktiv';
-- Kør flere gange
```

### 6. Undersøg statistikken
Tjek den indsamlede statistik:
```sql
SELECT attname, n_distinct, most_common_vals, most_common_freqs
FROM pg_stats 
WHERE tablename = 'kunder' AND attname IN ('status', 'aldersgruppe');
```
**Tjek:** Du skal se, at 'aktiv' har en høj frekvens (ca. 0.9) i most_common_freqs.

### 7. Prøv at slette statistikken
Slet statistik og observer effekten:
```sql
-- Fjern statistik for status kolonnen
ALTER TABLE kunder ALTER COLUMN status SET STATISTICS 0;
ANALYZE kunder;

-- Kør query'en igen
EXPLAIN (ANALYZE, BUFFERS) 
SELECT * FROM kunder WHERE status = 'inaktiv' AND aldersgruppe = '30-40';
```

Gendann statistik:
```sql
ALTER TABLE kunder ALTER COLUMN status SET STATISTICS 100;
ANALYZE kunder;
```

## Refleksion

1. Hvorfor bruger planlæggeren en sequential scan, når statistikken mangler?
2. Hvordan kan skæv datafordeling påvirke query-performance?
3. Hvornår bør man manuelt køre ANALYZE i en produktionsdatabase?

## Det har du lært

- Planlæggeren bruger statistik til at vælge den bedste eksekveringsplan
- Uden statistik gætter planlæggeren konservativt (ofte sequential scan)
- Skæv datafordeling kan føre til dårlige planer, hvis statistikken ikke er opdateret
- ANALYZE opdaterer statistikken og forbedrer planlægningen
- Statistik kan konfigureres pr. kolonne med ALTER TABLE SET STATISTICS