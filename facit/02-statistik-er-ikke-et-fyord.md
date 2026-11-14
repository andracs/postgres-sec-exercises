# Facit: Øvelse 02 - Statistik og ANALYZE til bedre query-planer

## Forventede resultater

### Datafordeling
```sql
SELECT status, count(*) FROM kunder GROUP BY status ORDER BY count(*) DESC;
```
**Output:**
```
 status  | count  
---------+--------
 aktiv   | 900000
 inaktiv | 100000
(2 rows)
```

### Query uden statistik (trin 2)
```sql
EXPLAIN (ANALYZE, BUFFERS) 
SELECT * FROM kunder WHERE status = 'inaktiv' AND aldersgruppe = '30-40';
```
**Forventet plan (uden statistik):**
- **Seq Scan** på kunder (konservativ tilgang, når statistik mangler)
- Filter: status = 'inaktiv' AND aldersgruppe = '30-40'
- Estimeret rækker: ~500.000 (gæt baseret på tabelstørrelse)
- Faktisk rækker: ~16.667 (100.000 inaktive / 6 aldersgrupper)
- Execution time: ~100-500 ms

**Typisk output:**
```
Seq Scan on kunder  (cost=0.00..17308.00 rows=500000 width=64) (actual time=0.012..85.423 rows=16667 loops=1)
  Filter: ((status = 'inaktiv') AND (aldersgruppe = '30-40'))
  Rows Removed by Filter: 983333
  Buffers: shared hit=1 read=4230
Planning Time: 0.123 ms
Execution Time: 88.756 ms
```

### Efter ANALYZE (trin 4)
```sql
ANALYZE kunder;
EXPLAIN (ANALYZE, BUFFERS) 
SELECT * FROM kunder WHERE status = 'inaktiv' AND aldersgruppe = '30-40';
```
**Forventet plan (med statistik):**
- **Index Scan** using idx_kunder_status
- Index Cond: status = 'inaktiv'
- Filter: aldersgruppe = '30-40'
- Estimeret rækker: ~16.667 (nøjagtigt estimat baseret på statistik)
- Faktisk rækker: 16.667
- Execution time: ~10-20 ms (væsentligt hurtigere)

**Typisk output:**
```
Index Scan using idx_kunder_status on kunder  (cost=0.42..3437.09 rows=16667 width=64) (actual time=0.045..11.313 rows=16667 loops=1)
  Index Cond: (status = 'inaktiv')
  Filter: (aldersgruppe = '30-40')
  Rows Removed by Filter: 83333
  Buffers: shared hit=80 read=1237
Planning Time: 0.224 ms
Execution Time: 11.762 ms
```

### Statistik-inspektion (trin 6)
```sql
SELECT attname, n_distinct, most_common_vals, most_common_freqs
FROM pg_stats 
WHERE tablename = 'kunder' AND attname IN ('status', 'aldersgruppe');
```

**Forventet output for status:**
```
 attname | n_distinct | most_common_vals | most_common_freqs
---------+------------+------------------+--------------------
 status  | 2          | {aktiv}          | {0.9}
```

**Forventet output for aldersgruppe:**
```
 attname    | n_distinct | most_common_vals                     | most_common_freqs
------------+------------+-------------------------------------+--------------------
 aldersgruppe | 6          | {18-25,26-35,30-40,41-50,51-65,65+} | {0.166667,0.166667,0.166667,0.166667,0.166667,0.166667}
```

## Komandoer og forklaringer

### ANALYZE
```sql
ANALYZE kunder;
```
- Indsamler statistik for alle kolonner i tablen
- Opdaterer `pg_stats` med: n_distinct, most_common_vals, most_common_freqs, correlation, etc.
- Kører automatisk af autovacuum, men kan køres manuelt

### VACUUM vs ANALYZE
- **VACUUM**: Rydder op i dead tuples (MVCC affald)
- **ANALYZE**: Opdaterer statistik
- **VACUUM ANALYZE**: Begge to (hvilket init-scriptet IKKE gør for at demonstrere effekten)

### Manuel statistik-indstilling
```sql
-- Sæt statistik-niveau for en kolonne
ALTER TABLE kunder ALTER COLUMN status SET STATISTICS 100;

-- Standard er 100 for de fleste kolonner
-- Højere værdier (op til 1000) giver mere præcis statistik for komplekse fordelinger
```

## Svar på refleksionsspørgsmål

1. **Hvorfor bruger planlæggeren en sequential scan, når statistikken mangler?**
   Når planlæggeren mangler statistik, kender den ikke datafordelingen. For en tabel med 1 million rækker gætter den konservativt på, at filtreringen vil returnere ca. 50% af rækkerne (default estimat). Med en så høj estimering på 500.000 rækker, konkluderer planlæggeren, at en sequential scan er mere effektiv end en index scan, fordi index lookup for hver række ville være for dyrt for et så stort resultat.

2. **Hvordan kan skæv datafordeling påvirke query-performance?**
   Med skæv datafordeling (90% aktiv, 10% inaktiv) vil:
   - Uden statistik: Planlæggeren estimatorer 50% af rækkerne returneres → seq scan
   - Med statistik: Planlæggeren ved, at kun 10% er inaktive, og at filtrering på aldersgruppe yderligere reducerer til ~1.67% → index scan
   
   Resultat: Med statistik vælges den korrekte plan (index scan), hvilket reducerer eksekveringstiden fra ~100ms til ~10ms - en forbedring på 10x.

3. **Hvornår bør man manuelt køre ANALYZE i en produktionsdatabase?**
   - **Efter bulk data-indsættelse**: Store INSERT/UPDATE/DELETE operationer, der ændrer datafordelingen væsentligt
   - **Efter skemaændringer**: Nye kolonner, indeks eller tabeller har ingen statistik
   - **Når autovacuum er deaktiveret**: I specialiserede miljøer
   - **Før kritiske queries**: Før store batch jobs eller rapporter køres
   - **Når query-performance forværres**: Hvis queries pludselig bliver langsommere
   
   **Autovacuum** kører normalt ANALYZE automatisk, men i nogle tilfælde er manuel intervention nødvendig.

## Typiske fejl og løsninger

### Fejl: Query bruger stadig seq scan efter ANALYZE
**Årsag:** Autovacuum har endnu ikke kørt, eller statistikken er for grov.
**Løsning:** Kør `ANALYZE kunder;` manuelt, eller øg statistik-niveauet:
```sql
ALTER TABLE kunder ALTER COLUMN status SET STATISTICS 1000;
ANALYZE kunder;
```

### Fejl: Planlæggeren vælger forkert indeks
**Årsag:** Statistikken viser, at en kolonne har lav selektivitet.
**Løsning:** Tjek korrelationen mellem kolonner og overvej et sammensat indeks.

### Fejl: ANALYZE tager for lang tid
**Årsag:** Store tabeller med mange kolonner.
**Løsning:** Øg autovacuum_work_mem, eller kør ANALYZE på specifikke kolonner:
```sql
ANALYZE kunder (status, aldersgruppe);
```

## Læringsmål - tjekliste

✅ Planlæggeren bruger statistik til at vælge eksekveringsplaner
✅ Uden statistik bruger planlæggeren konservative estimater (ofte 50% selektivitet)
✅ Skæv datafordeling kræver præcis statistik for optimal planlægning
✅ ANALYZE opdaterer statistikken i pg_stats
✅ Statistik-niveau kan konfigureres pr. kolonne
✅ autovacuum kører normalt ANALYZE automatisk, men manuel intervention kan være nødvendig