# Øvelse 03: Læsning af eksekveringsplaner med EXPLAIN

## Formål
At lære at aflæse og forstå PostgreSQL eksekveringsplaner. Du vil oprette data, der tvinger forskellige plan-typer (seq scan, nested loop, hash join, sort spill), og forudsige planen før du kører den.

## Forudsætninger
- Docker Desktop eller Podman installeret
- Minimum 4 GB RAM til rådighed for Docker
- Grundlæggende kendskab til SQL og psql

## Start

1. Naviger til øvelsens mappe:
   ```bash
   cd oevelser/03-eksekveringsplan
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

> **Bemærk:** Planer kan variere med PostgreSQL-version og statistik. Tjek at planen indeholder den forventede nodetype (f.eks. "Hash Join"), ikke eksakte cost-/tidstal.

### 1. Opret testdata
Seed-scriptet opretter automatisk tabellerne. 

```sql
\i /docker-entrypoint-initdb.d/01-init.sql
```

Verificér:
```sql
SELECT count(*) FROM forfattere;
SELECT count(*) FROM boeger;
SELECT count(*) FROM laan;
```
**Tjek:** 10.000 forfattere, 100.000 bøger, 1.000.000 lånetransaktioner

### 2. Tving en Sequential Scan
Kør en query, der IKKE kan bruge indeks:
```sql
EXPLAIN (ANALYZE, BUFFERS)
SELECT * FROM laan WHERE EXTRACT(YEAR FROM laan_dato) = 2023;
```
**Forudsigelse:** Sequential Scan (ingen indeks på EXTRACT-funktion)
**Tjek:** Planen indeholder "Seq Scan on laan" (typisk som "Parallel Seq Scan")

### 3. Tving en Nested Loop Join
Kør en query med en lille filtreret tabel og en stor tabel (alle navne er 'Forfatter N', så filtrer på id for at få et lille resultat):
```sql
EXPLAIN (ANALYZE, BUFFERS)
SELECT f.navn, b.titel 
FROM forfattere f
JOIN boeger b ON f.id = b.forfatter_id
WHERE f.id <= 100;
```
**Forudsigelse:** Nested Loop (godt til små resultater — her kun 100 forfattere)
**Tjek:** Planen indeholder "Nested Loop"

### 4. Tving en Hash Join
Kør en query med store tabeller og ingen indeks:
```sql
EXPLAIN (ANALYZE, BUFFERS)
SELECT count(*) 
FROM laan l
JOIN boeger b ON l.bog_id = b.id
WHERE l.laan_dato > '2023-01-01';
```
**Forudsigelse:** Hash Join (godt til store datasets)
**Tjek:** Planen indeholder "Hash Join"

### 5. Tving en Sort (med spill til disk)
Sæt work_mem meget lavt og kør. Bemærk to ting: PostgreSQL accepterer kun små 'kB' (ikke '64KB'), og sorter på den ikke-indekserede `laaner_id` — sortering på `laan_dato` ville bruge `idx_laan_laan_dato` og ikke spilde til disk:
```sql
SET work_mem = '64kB';
EXPLAIN (ANALYZE, BUFFERS)
SELECT * FROM laan ORDER BY laaner_id, bog_id;
```
**Forudsigelse:** Sort med "external merge" (spill til disk)
**Tjek:** Planen indeholder "Sort Method: external merge" og "temp read/written"

### 6. Tving en Merge Join
Deaktivér de andre join-metoder, så planlæggeren må bruge Merge Join. Input bliver sorteret af indekserne (`forfattere_pkey` og `idx_boeger_forfatter`):
```sql
SET work_mem = '64kB';
SET enable_hashjoin = off;
SET enable_nestloop = off;
EXPLAIN (ANALYZE, BUFFERS)
SELECT f.navn, b.titel
FROM forfattere f
JOIN boeger b ON f.id = b.forfatter_id;
```
**Forudsigelse:** Merge Join (når input er sorteret)
**Tjek:** Planen indeholder "Merge Join"

### 7. Analyser buffer-brug
Gentag trin 4 med EXPLAIN (ANALYZE, BUFFERS) og notér:
- shared hit: Blokke fundet i shared buffers
- shared read: Blokke læst fra disk
- temp read/write: Midlertidige filer (ved spill)

### 8. Sammenlign estimater vs. faktisk
For enhver query, sammenlign:
- Estimated rows (i planen før EXPLAIN ANALYZE)
- Actual rows (i ANALYZE output)

## Refleksion

1. Hvornår er en Sequential Scan bedre end en Index Scan?
2. Hvordan påvirker work_mem indstillingerne planlæggerens valg af join-metoder?
3. Hvordan kan du se, om en query spilder data til disk?

## Det har du lært

- At aflæse eksekveringsplaner med EXPLAIN (ANALYZE, BUFFERS)
- At genkende forskellige scan-typer: Sequential, Index, Index Only
- At genkende join-typer: Nested Loop, Hash Join, Merge Join
- At forstå buffer-brug og hukommelsesforbrug
- At estimere vs. faktiske rækker kan afsløre manglende statistik
- At work_mem påvirker, om sorteringer spiller til disk
