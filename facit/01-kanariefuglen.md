# Facit: Øvelse 01 - Kanariefuglen i kuldemineren

## Forventede resultater

### Baseline TPS
Med standardkonfiguration (`shared_buffers=128MB`, `work_mem=4MB`, `effective_cache_size=512MB`):
- **TPS**: ~8.000-12.000 (varierer afhængigt af hardware)
- Typisk output:
  ```
  tps = 10630.752940 (without initial connection time)
  latency average = 0.376 ms
  ```

### Nuværende konfiguration (trin 2)
```sql
SHOW shared_buffers;              -- 128MB
SHOW work_mem;                    -- 4MB
SHOW effective_cache_size;        -- 512MB
SHOW maintenance_work_mem;        -- 64MB
```

### Justerede parametre (trin 3)
```
shared_buffers=256MB
work_mem=16MB
effective_cache_size=768MB
maintenance_work_mem=128MB
```

### Forbedret TPS
- **TPS**: ~12.000-16.000 (typisk 20-30% forbedring)
- Forbedringsprocent: ~25-40%

## Komandoer og forklaringer

### pgbench baseline
```bash
docker compose exec postgres pgbench -U studie -c 4 -T 30 studiebase
```
- `-c 4`: 4 klienter
- `-T 30`: 30 sekunders test
- Standard TPC-B-lignende benchmark

### Konfigurationsændring
Rediger `docker-compose.yml` og ændr `command:` afsnittet:
```yaml
command: 
  -c shared_buffers=256MB
  -c work_mem=16MB
  -c effective_cache_size=768MB
  -c maintenance_work_mem=128MB
```

Genstart med:
```bash
docker compose down
docker compose up -d
```

### Parameterforklaringer
- **shared_buffers**: Hukommelse til disk-caching. Standard 128MB er lavt for moderne systemer.
- **work_mem**: Hukommelse pr. operation (sortering, hash joins). Standard 4MB er meget konservativ.
- **effective_cache_size**: Estimering af OS cache. Postgres bruger dette til at vurdere, om disk-I/O er nødvendig.
- **maintenance_work_mem**: Hukommelse til VACUUM, index opbygning mv.

## Svar på refleksionsspørgsmål

1. **Hvorfor er Postgres' standardindstillinger konservative?**
   Standardindstillingerne skal virke på det bredest mulige udvalg af hardware - fra små VM'er med 512MB RAM til store servere. Konservative værdier sikrer, at Postgres kan starte og køre stabilt på alle systemer, uanset ressourcer. Det er op til administratoren at tune til den specifikke hardware.

2. **Hvilke faktorer bør man overveje, når man justerer `shared_buffers`?**
   - **Fysisk RAM**: `shared_buffers` bør typisk være 25% af den tilgængelige RAM (op til ~8GB)
   - **OS cache**: Postgres og OS deler hukommelse. `effective_cache_size` bør inkludere OS cache
   - **Workload**: OLTP-systemer (mange små queries) drager mere fordel af høj `shared_buffers` end OLAP (få store queries)
   - **Antal forbindelser**: Hver forbindelse bruger hukommelse, så `shared_buffers` skal tage højde for det

3. **Hvorfor kan for høje hukommelsesindstillinger være problematiske?**
   - **Postgres starter ikke**: Hvis summen af alle hukommelsesparametre overstiger systemets RAM, fehler start
   - **Swapping**: For høj hukommelsesallokering kan føre til swapping, hvilket drastisk forringer performance
   - **OS stabilitet**: For aggressiv allokering kan destabilisere operativsystemet
   - **Ineffektivt**: Hukommelse ud over, hvad systemet fysisk har, bliver aldrig brugt effektivt

## Typiske fejl og løsninger

### Fejl: Container starter ikke med for høje værdier
```
shared_buffers=2GB
```
**Løsning**: Sæt værdien ned. For en container med begrænset hukommelse (typisk 2-4GB), bør `shared_buffers` maks være 512MB-1GB.

### Fejl: pgbench fehler med "could not connect to server"
**Årsag**: Databasen er ikke klar endnu.
**Løsning**: Vent 10-15 sekunder og tjek med:
```bash
docker compose exec postgres pg_isready -U studie
```

### Fejl: init-script fehler
**Årsag**: Forkert SQL-syntaks i init-scriptet.
**Løsning**: Brug `DO $$ BEGIN RAISE NOTICE 'besked'; END $$;` i stedet for direkte `RAISE NOTICE`.

## Læringsmål - tjekliste

✅ Standardkonfiguration er designet til kompatibilitet, ikke performance
✅ `pgbench` er et effektivt benchmark-værktøj
✅ Hukommelsesparametre har direkte indflydelse på transaktionsydeevne
✅ Performance-tuning kræver måling og iteration
✅ For høje indstillinger kan være værre end for lave