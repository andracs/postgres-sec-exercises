# Facit: Øvelse 04 - Indekser: hurtigere læsning, langsommere skrivning

## Forventede resultater

### Trin 1: data
```sql
SELECT count(*) FROM ordrer;  -- 1.000.000
```

### Trin 2: uden indeks (seq scan)
```sql
EXPLAIN (ANALYZE) SELECT * FROM ordrer WHERE kunde_id = 5000 AND status = 'afsluttet';
```
Planen viser `Seq Scan on ordrer` — typisk 50-200 ms.

### Trin 3: med indeks på kunde_id
```sql
CREATE INDEX idx_ordrer_kunde ON ordrer(kunde_id);
EXPLAIN (ANALYZE) SELECT * FROM ordrer WHERE kunde_id = 5000 AND status = 'afsluttet';
```
Planen viser `Index Scan using idx_ordrer_kunde` (eller Bitmap Heap Scan) — typisk 1-5 ms.

### Trin 4: sammensat indeks
```sql
CREATE INDEX idx_ordrer_kunde_status ON ordrer(kunde_id, status);
```
Både kunde_id og status bruges i én lookup — ofte hurtigst af alle.

### Trin 5-6: skriveperformance
10.000 INSERTs uden indeks vs. med to indeks: med indeks typisk **2-5x langsommere**, fordi hver INSERT også skal opdatere indekserne.

### Trin 7: indeksbrug
```sql
SELECT indexrelname, idx_scan FROM pg_stat_user_indexes WHERE schemaname = 'public';
```
Et indeks med `idx_scan = 0` efter normal belastning er et kandidat til at blive droppet.

## Svar på refleksion

1. Et sammensat indeks `(kunde_id, status)` dækker begge kolonner i én lookup og kan også bruges til søgning på `kunde_id` alene (venstre-prefix-reglen) — to separate indekser koster hver deres vedligeholdelse ved skrivning.
2. Overvej: hvor ofte læses der på kolonnen? hvor selektiv er den? hvad koster hver INSERT/UPDATE? Lav `idx_scan` i `pg_stat_user_indexes` → overvej at droppe indekset.
3. `pg_stat_user_indexes.idx_scan = 0` over en repræsentativ periode. Bemærk at statistikken nulstilles ved restart — mål over tid.

## Typiske fejl (rettet i init.sql)
- `SET seed = 42` fejler — seed skal være -1..1 (`0.42`).
- `(random()*N)::int` runder og kan give N+1 — brug `floor(random()*N)::int`.
