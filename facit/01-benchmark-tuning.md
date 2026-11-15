# Facit: Øvelse 01 - Benchmarking og hukommelseskonfiguration med pgbench

## Forventede resultater

### Datasæt (trin 1)
```bash
docker compose exec postgres pgbench -U studie -i -s 30 studiebase
```
- Skala 30 = 3.000.000 konti, ca. 400 MB data + indekser
- Data overlever `docker compose down` (ligger i volumenet `pgdata`); `-i` må kun køres én gang

### Baseline TPS (trin 2)
Med den sultne startkonfiguration (`shared_buffers=16MB`, `work_mem=64kB`, `effective_cache_size=32MB`, `maintenance_work_mem=16MB`):
- **TPS**: typisk et sted mellem nogle hundrede og et par tusinde — arbejdssættet (ca. 400 MB) er ca. 25x større end `shared_buffers`, så der læses konstant fra disk
- **Vigtigt**: Den nøjagtige værdi afhænger meget af disk-type (SSD vs. spinning, Docker Desktop vs. Linux). Det er pointen: måling, ikke gætteri.

### Nuværende konfiguration (trin 3)
```sql
SHOW shared_buffers;              -- 16MB
SHOW work_mem;                    -- 64kB
SHOW effective_cache_size;        -- 32MB
SHOW maintenance_work_mem;        -- 16MB
```

### work_mem-demo (trin 4)
```sql
EXPLAIN ANALYZE SELECT aid, abalance FROM pgbench_accounts ORDER BY abalance DESC LIMIT 10;
```
- Med `work_mem=64kB` (3M rækker skal sorteres):
  ```text
  Sort Method: external merge  Disk: ~40MB
  Execution Time: 3000-6000 ms
  ```
- Efter tuning til `work_mem=64MB`:
  ```text
  Sort Method: quicksort  Memory: ~50MB
  Execution Time: 400-800 ms
  ```
- Gevinsten her er typisk 5-10x — den mest tydelige, målbar effekt i øvelsen

### Justerede parametre (trin 5)
```
shared_buffers=512MB
work_mem=64MB
effective_cache_size=2GB
maintenance_work_mem=256MB
```

### Forbedret TPS (trin 6)
- **TPS**: markant højere end baseline — ofte 2-10x, afhængigt af disk
- Hvis deltageren ser lille/målinglig ændring: tjek at datasættet faktisk er på skala 30 (`SELECT count(*) FROM pgbench_accounts;` skal give 3.000.000), og at containeren blev genstartet efter redigeringen. På maskiner med meget RAM og hurtig SSD kan OS-cache udjævne forskellen — nævn det i refleksionen.

## Kommandoer og forklaringer

### pgbench initialisering og baseline
```bash
docker compose exec postgres pgbench -U studie -i -s 30 studiebase   # opret data (én gang)
docker compose exec postgres pgbench -U studie -c 4 -T 30 studiebase # benchmark
```
- `-i -s 30`: initialisér med skala 30
- `-c 4`: 4 klienter
- `-T 30`: 30 sekunders test
- Standard TPC-B-lignende benchmark (UPDATE-tunge transaktioner med tilfældige primærnøgle-lookups)

### Konfigurationsændring
Rediger `docker-compose.yml` og ændr `command:` afsnittet:
```yaml
command: 
  -c shared_buffers=512MB
  -c work_mem=64MB
  -c effective_cache_size=2GB
  -c maintenance_work_mem=256MB
```

Genstart med:
```bash
docker compose down
docker compose up -d
```
Bemærk: `down` sletter ikke volumenet, så data og dermed benchmark-betingelserne er identiske før/efter tuning. Det gør sammenligningen retvisende.

### Parameterforklaringer
- **shared_buffers**: Fysisk delt hukommelse til disk-caching. Effekt kræver, at arbejdssættet er større end bufferen — ellers er der ingen cache-miss at fjerne.
- **work_mem**: Hukommelse pr. sorterings-/hash-operation, pr. forbindelse. For lav værdig giver external merge til disk (synlig i EXPLAIN).
- **effective_cache_size**: Et *hint* til planlæggeren om tilgængelig cache (Postgres + OS). Allokerer ingen hukommelse.
- **maintenance_work_mem**: Hukommelse til VACUUM, index-opbygning mv. Påvirker ikke transaktions-TPS.

## Svar på refleksionsspørgsmål

1. **Hvorfor kunne tuning først ses, da datasættet var større end hukommelsen?**
   Hvis alle data allerede passer i `shared_buffers` (eller OS-cachen), er der ingen cache-miss at fjerne — så ændrer større buffere intet. Gevinst ved tuning opstår, når arbejdssættet overstiger hukommelsen, og flere data kan holdes varme i RAM. Det er derfor man altid måler på det reelle datasæt, ikke et legetøjs-datasæt.

2. **Hvilke faktorer bør man overveje, når man justerer `shared_buffers`?**
   - **Fysisk RAM**: `shared_buffers` bør typisk være 25% af den tilgængelige RAM (op til ~8GB)
   - **OS cache**: Postgres og OS deler hukommelse; `effective_cache_size` bør afspejle det samlede
   - **Workload**: OLTP (mange små queries) drager fordel af høj `shared_buffers`; store analytiske queries bruger mere `work_mem`
   - **Datastørrelse**: Buffer mindre end arbejdssættet = disk-I/O; buffer større end datasættet = spildt hukommelse

3. **Hvorfor kan for høje hukommelsesindstillinger være problematiske?**
   - **Postgres starter ikke**: Hvis `shared_buffers` overstiger det, containeren må mappe, fejler opstart (`could not map anonymous shared memory`)
   - **Swapping**: For høj allokering kan føre til swapping, hvilket drastisk forringer performance
   - **work_mem er pr. operation og pr. forbindelse**: 100 forbindelser × flere samtidige sorteringer × 64MB kan allokere mange GB
   - **OS stabilitet**: For aggressiv allokering kan destabilisere operativsystemet

4. **Hvad er forskellen på `shared_buffers` og `effective_cache_size`?**
   `shared_buffers` er fysisk allokeret, delt hukommelse i Postgres-processen. `effective_cache_size` er et estimat-hint til planlæggeren om, hvor meget cache (Postgres + OS) den kan regne med ved planlægning — der allokeres intet. En forkert `effective_cache_size` giver dårlige planer, ikke dårligere cache.

## Typiske fejl og løsninger

### Fejl: "table pgbench_accounts already exists" ved pgbench -i
**Årsag**: `pgbench -i` er allerede kørt (data findes i volumenet).
**Løsning**: Spring initialiseringen over, eller start forfra med `docker compose down -v` (sletter dataene).

### Fejl: Container starter ikke efter tuning (trin 8)
```
shared_buffers=8GB
```
**Løsning**: Sæt værdien ned. For en container med 2-4GB RAM bør `shared_buffers` maks være 512MB-1GB. Tjek logs:
```bash
docker compose logs postgres | tail -20
```

### Fejl: pgbench fejler med "could not connect to server"
**Årsag**: Databasen er ikke klar endnu.
**Løsning**: Vent 10-15 sekunder og tjek med:
```bash
docker compose exec postgres pg_isready -U studie
```

### Fejl: Ingen synlig TPS-forskel efter tuning
**Årsag 1**: Datasættet er for lille (fx gammelt skala 10-data i volumenet). Kontrollér med `SELECT count(*) FROM pgbench_accounts;`.
**Årsag 2**: Containeren er ikke genstartet efter redigering af `docker-compose.yml`.
**Årsag 3**: Meget RAM + hurtig SSD gør OS-cachen så god, at forskellen udjævnes. Diskutér det i refleksionen — det er en reel observation fra produktionslivet.

## Læringsmål - tjekliste

✅ Tuning kan kun måles, hvis arbejdssættet overstiger hukommelsen
✅ `pgbench -i -s N` opretter testdata; størrelsen styrer, om tuning kan ses
✅ `work_mem`-effekt ses direkte i EXPLAIN (external merge Disk vs. quicksort Memory)
✅ `effective_cache_size` er et planner-hint, ikke allokeret hukommelse
✅ Performance-tuning kræver måling og iteration
✅ For høje indstillinger kan være værre end for lave
