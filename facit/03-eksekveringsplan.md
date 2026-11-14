# Facit: Øvelse 03 - At læse en eksekveringsplan er at læse poesi

## Forventede resultater

### Dataverifikation
```sql
SELECT count(*) FROM forfattere;  -- 10.000
SELECT count(*) FROM boeger;     -- 100.000
SELECT count(*) FROM laan;        -- 1.000.000
```

### Trin 2: Sequential Scan (EXTRACT-funktion)
```sql
EXPLAIN (ANALYZE, BUFFERS)
SELECT * FROM laan WHERE EXTRACT(YEAR FROM laan_dato) = 2023;
```

**Forventet plan:**
```
Seq Scan on laan  (cost=0.00..22408.00 rows=295843 width=32) (actual time=0.012..123.456 rows=288333 loops=1)
  Filter: (date_part('year'::text, laan_dato) = 2023)
  Rows Removed by Filter: 711667
  Buffers: shared hit=1 read=12345
Planning Time: 0.123 ms
Execution Time: 156.789 ms
```

**Forklaring:**
- `Seq Scan`: Sequential scan af hele tablen (1M rækker)
- `Filter`: Kun rækker, hvor EXTRACT(YEAR FROM laan_dato) = 2023 bevares
- `Rows Removed`: ~711.667 rækker filtreres fra (fordi datoer er spredt over 3 år: 2020-2023)
- Ingen indeks kan bruges på funktioner som EXTRACT

### Trin 3: Nested Loop Join
```sql
EXPLAIN (ANALYZE, BUFFERS)
SELECT f.navn, b.titel 
FROM forfattere f
JOIN boeger b ON f.id = b.forfatter_id
WHERE f.navn LIKE 'A%';
```

**Forventet plan:**
```
Nested Loop  (cost=4.30..123.45 rows=1000 width=132) (actual time=0.045..1.234 rows=987 loops=1)
  ->  Seq Scan on forfattere f  (cost=0.00..17.00 rows=1000 width=68) (actual time=0.012..0.345 rows=1000 loops=1)
        Filter: (navn ~~ 'A%'::text)
        Rows Removed by Filter: 9000
  ->  Index Scan using idx_boeger_forfatter on boeger b  (cost=0.29..0.12 rows=10 width=64) (actual time=0.001..0.001 rows=10 loops=1000)
        Index Cond: (forfatter_id = f.id)
  Buffers: shared hit=45 read=12
Planning Time: 0.234 ms
Execution Time: 1.456 ms
```

**Forklaring:**
- `Nested Loop`: God til små ydre resultater
- `Seq Scan on forfattere`: Scanner forfattere, filtrerer med LIKE 'A%' (ca. 1000 rækker)
- `Index Scan on boeger`: For hver forfatter, finder bøger via indeks
- Effektiv, når det ydre dataset er lille

### Trin 4: Hash Join
```sql
EXPLAIN (ANALYZE, BUFFERS)
SELECT count(*) 
FROM laan l
JOIN boeger b ON l.bog_id = b.id
WHERE l.laan_dato > '2023-01-01';
```

**Forventet plan:**
```
Hash Join  (cost=1234.56..5678.90 rows=123456 width=0) (actual time=12.345..45.678 rows=123456 loops=1)
  Hash Cond: (l.bog_id = b.id)
  ->  Seq Scan on laan l  (cost=0.00..22408.00 rows=288333 width=8) (actual time=0.012..15.678 rows=288333 loops=1)
        Filter: (laan_dato > '2023-01-01'::timestamp)
        Rows Removed by Filter: 711667
  ->  Hash  (cost=890.12..890.12 rows=100000 width=4) (actual time=11.234..11.234 rows=100000 loops=1)
        Buckets: 131072  Batches: 1  Memory Usage: 5120kB
        ->  Seq Scan on boeger b  (cost=0.00..890.12 rows=100000 width=4) (actual time=0.012..4.567 rows=100000 loops=1)
  Buffers: shared hit=123 read=4567
Planning Time: 1.234 ms
Execution Time: 47.890 ms
```

**Forklaring:**
- `Hash Join`: God til store datasets
- `Seq Scan on laan`: Filtrerer laan (288.333 rækker med dato > 2023-01-01)
- `Hash`: Bygger hash-tabel af boeger
- `Memory Usage`: 5120kB til hash-tabel
- Mere effektiv end nested loop for store joins

### Trin 5: Sort med spill til disk
```sql
SET work_mem = '64KB';
EXPLAIN (ANALYZE, BUFFERS)
SELECT * FROM laan ORDER BY laan_dato, bog_id;
```

**Forventet plan:**
```
Sort  (cost=45678.90..47890.12 rows=1000000 width=32) (actual time=123.456..234.567 rows=1000000 loops=1)
  Sort Key: laan_dato, bog_id
  Sort Method: external merge  Disk: 45678kB
  Buffers: shared hit=123 read=4567 temp read=1234 temp written=5678
  ->  Seq Scan on laan  (cost=0.00..17308.00 rows=1000000 width=32) (actual time=0.012..23.456 rows=1000000 loops=1)
        Buffers: shared hit=123 read=4567
Planning Time: 0.123 ms
Execution Time: 256.789 ms
```

**Forklaring:**
- `Sort Method: external merge`: Data spilles til disk, fordi work_mem er for lav (64KB)
- `Disk: 45678kB`: Mængde data skrevet til disk
- `temp read/written`: Midlertidige I/O operationer
- Spill til disk er langsommere end in-memory sort

### Trin 6: Merge Join
```sql
SET work_mem = '64KB';
EXPLAIN (ANALYZE, BUFFERS)
SELECT f.navn, b.titel
FROM forfattere f
JOIN boeger b ON f.id = b.forfatter_id
ORDER BY f.navn, b.titel;
```

**Forventet plan:**
```
Merge Join  (cost=1234.56..5678.90 rows=100000 width=132) (actual time=12.345..45.678 rows=100000 loops=1)
  Merge Cond: (f.id = b.forfatter_id)
  ->  Sort  (cost=17.00..19.00 rows=10000 width=68) (actual time=1.234..2.345 rows=10000 loops=1)
        Sort Key: f.navn
        Sort Method: external merge  Disk: 456kB
        ->  Seq Scan on forfattere f  (cost=0.00..17.00 rows=10000 width=68) (actual time=0.012..0.345 rows=10000 loops=1)
  ->  Sort  (cost=890.12..912.34 rows=100000 width=64) (actual time=10.123..11.234 rows=100000 loops=1)
        Sort Key: b.forfatter_id, b.titel
        Sort Method: external merge  Disk: 4567kB
        ->  Seq Scan on boeger b  (cost=0.00..890.12 rows=100000 width=64) (actual time=0.012..4.567 rows=100000 loops=1)
  Buffers: shared hit=123 read=456 temp read=1234 temp written=5678
Planning Time: 0.456 ms
Execution Time: 48.789 ms
```

**Forklaring:**
- `Merge Join`: Kræver sorterede inputs
- Begge tabeller sorteres først (med spill til disk på grund af lav work_mem)
- `Merge Cond`: Join på f.id = b.forfatter_id
- Effektiv, når inputs allerede er sorterede

## Komandoer og forklaringer

### EXPLAIN varianter

1. **Basis EXPLAIN**:
   ```sql
   EXPLAIN SELECT * FROM laan WHERE bog_id = 1;
   ```
   Viser planen uden at køre query'en

2. **EXPLAIN ANALYZE**:
   ```sql
   EXPLAIN ANALYZE SELECT * FROM laan WHERE bog_id = 1;
   ```
   Kører query'en og viser faktisk tid og rækker

3. **EXPLAIN (ANALYZE, BUFFERS)**:
   ```sql
   EXPLAIN (ANALYZE, BUFFERS) SELECT * FROM laan WHERE bog_id = 1;
   ```
   Inkluderer buffer-brug (shared hit/read, temp read/write)

4. **EXPLAIN (ANALYZE, BUFFERS, VERBOSE)**:
   ```sql
   EXPLAIN (ANALYZE, BUFFERS, VERBOSE) SELECT * FROM laan WHERE bog_id = 1;
   ```
   Vis detaljeret information

### Plan-typer forklaring

#### Scan-typer:
- **Seq Scan**: Lineær scanning af hele tablen
  - God til: Små tabeller, store resultater (>30% af tablen)
  - Dårlig til: Store tabeller med lille selektivitet

- **Index Scan**: Brug indeks til at finde rækker
  - God til: Store tabeller med høj selektivitet (<5% af tablen)
  - Dårlig til: Mangler indeks, lav selektivitet

- **Index Only Scan**: Hent kun fra indeks (uden at gå til tabellen)
  - God til: Queries, der kun har brug for kolonner i indekset
  - Kræver: INCLUDE kolonne eller covering index

#### Join-typer:
- **Nested Loop**:
  - For hver række i ydre tabel, find matchende rækker i indre tabel
  - God til: Lille ydre tabel, indeks på join-kolonne
  - Kompleksitet: O(n*m), hvor n=ydre, m=indre

- **Hash Join**:
  - Byg hash-tabel af en tabel, scan den anden
  - God til: Store tabeller, ingen indeks, = operator
  - Kompleksitet: O(n+m)
  - Kræver: work_mem til hash-tabel

- **Merge Join**:
  - Kræver sorterede inputs på join-kolonne
  - God til: Store tabeller, allerede sorterede data
  - Kompleksitet: O(n+m)
  - Kræver: Sort af inputs, hvis ikke allerede sorteret

### Buffer-typer

- **shared hit**: Blokke fundet i shared buffers (hukommelse)
- **shared read**: Blokke læst fra disk til shared buffers
- **temp read**: Midlertidige blokke læst fra disk (spill)
- **temp written**: Midlertidige blokke skrevet til disk (spill)

## Svar på refleksionsspørgsmål

1. **Hvornår er en Sequential Scan bedre end en Index Scan?**
   
   En Sequential Scan er bedre end en Index Scan i følgende situationer:
   
   - **Store resultater**: Når query'en returnerer mere end ~30-40% af tablen. Index scan kræver en ekstra disk-I/O for hver række (indeks lookup + tabel access), mens sequential scan kan læse blokke mere effektivt.
   
   - **Mangler indeks**: Hvis der ikke er et relevant indeks, er sequential scan den eneste mulighed.
   
   - **Små tabeller**: For tabeller, der er mindre end en eller to disk-blokke, er det hurtigere at læse hele tablen end at bruge indekset.
   
   - **Funktionsbaserede queries**: Når query'en bruger funktioner på kolonner (f.eks. EXTRACT(YEAR FROM dato)), kan indeks ikke bruges, og sequential scan er nødvendig.
   
   - **Sekventiel I/O**: Moderne disk-drev er optimere til sekventiel I/O. Sequential scan læser data sekventielt, hvilket er hurtigere end random I/O for index scans.
   
   - **Organiseret data**: Hvis data er fysisk organiseret på disken (clustered), kan sequential scan være mere effektiv.

2. **Hvordan påvirker work_mem indstillingerne planlæggerens valg af join-metoder?**
   
   `work_mem` påvirker planlæggerens beslutning om, hvilken join-metode der skal bruges, på følgende måder:
   
   - **Nested Loop**: Bruger minimalt work_mem. Valgt, når:
     - Det ydre dataset er lille
     - Der er indeks på join-kolonne i den indre tabel
     - work_mem er lavt (Nested Loop kræver ikke meget hukommelse)
   
   - **Hash Join**: Kræver work_mem til hash-tabel. Valgt, når:
     - Der er nok work_mem til at bygge hash-tabelen
     - Joinen involverer store datasets
     - Der ikke er indeks på join-kolonne
     - Hvis work_mem er for lavt, kan hash join spille til disk (external hash)
   
   - **Merge Join**: Kræver work_mem til sortering. Valgt, når:
     - Inputs allerede er sorterede, eller der er nok work_mem til at sortere dem
     - Joinen involverer store datasets
     - Der er ORDER BY klausul, der matcher join-kolonne
     - Hvis work_mem er for lavt, sorterer den til disk (external merge)
   
   **Eksempel:**
   - `work_mem = '64KB'`: Planlæggeren vælger sandsynligvis Nested Loop, fordi Hash og Merge Join ville kræve for meget hukommelse
   - `work_mem = '16MB'`: Planlæggeren kan vælge Hash Join for store joins
   - `work_mem = '256MB'`: Planlæggeren kan vælge Merge Join med in-memory sortering

3. **Hvordan kan du se, om en query spilder data til disk?**
   
   Du kan se, om en query spiller data til disk ved at kigge på:
   
   - **Sort Method**: I EXPLAIN ANALYZE output, kig efter:
     - `Sort Method: external merge` - Data spilles til disk for sortering
     - `Sort Method: external sort` - Alternative spill-metode
     - `Sort Method: quicksort` - In-memory sortering (ingen spill)
   
   - **Hash Join Method**:
     - `Hash Cond: ...` med `Batches: >1` - Hash-tabel er for stor til work_mem, spiller til disk
     - `Memory Usage: XkB` - Hvis dette er tæt på work_mem, er der risiko for spill
   
   - **Buffer-statistik**:
     - `temp read: >0` - Midlertidige blokke læst fra disk
     - `temp written: >0` - Midlertidige blokke skrevet til disk
     - `Disk: XkB` - Mængde data skrevet til disk for sort/join
   
   - **Performance**: Spill til disk manifesterer sig som:
     - Langsommere eksekveringstid
     - Høj disk-I/O under query'en
     - Disk-aktivitetslys blinker intensivt

## Typiske fejl og løsninger

### Fejl: Planen ændrer sig mellem kørsler
**Årsag:** Statistikken opdateres automatisk af autovacuum
**Løsning:** Deaktivér autovacuum midlertidigt for tabellen:
```sql
ALTER TABLE laan SET (autovacuum_enabled = off);
-- Kør dine tests
ALTER TABLE laan SET (autovacuum_enabled = on);
```

### Fejl: "external merge" vises, selv med høj work_mem
**Årsag:** Dataene er for store til at blive sorteret i hukommelse
**Løsning:** Øg work_mem yderligere, eller overvej at bruge et indeks, der allerede er sorteret

### Fejl: Hash Join bruger mange batches
**Årsag:** Hash-tabelen er for stor til work_mem
**Løsning:** Øg work_mem, eller overvej at bruge en anden join-metode

### Fejl: Planlæggeren vælger forkert plan
**Årsag:** Manglende statistik eller forældet statistik
**Løsning:** Kør ANALYZE:
```sql
ANALYZE laan;
ANALYZE forfattere;
ANALYZE boeger;
```

## Læringsmål - tjekliste

✅ Kan aflæse og forstå EXPLAIN output
✅ Kender forskel på Seq Scan, Index Scan, Index Only Scan
✅ Forstår Nested Loop, Hash Join, Merge Join
✅ Kan identificere, hvornår data spilles til disk
✅ Forstår, hvordan work_mem påvirker planlægningen
✅ Kan bruge BUFFERS til at analysere I/O-patterns
✅ Forstår forskellen mellem estimerede og faktiske værdier
✅ Kan forudsige planer baseret på data og indeks