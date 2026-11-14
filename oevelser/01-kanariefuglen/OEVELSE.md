# Øvelse 01: Benchmarking og hukommelseskonfiguration med pgbench

## Formål
At demonstrere, at performance-tuning skal baseres på målinger, ikke gætteri. Du vil måle ydeevnen med `pgbench` på et datasæt, der er **større end hukommelsen**, justere hukommelsesparametre og observere en reel, målbar effekt.

**Vigtigt:** Tuning kan kun ses, hvis data ikke allerede passer i hukommelsen. Derfor bruger denne øvelse et pgbench-datasæt på skala 30 (ca. 400 MB) og en bevidst sulten startkonfiguration.

## Forudsætninger
- Docker Desktop eller Podman installeret
- Minimum 4 GB RAM til rådighed for Docker
- Minimum 2 GB ledig diskplads
- Grundlæggende kendskab til terminal/kommandolinje

## Start

1. Naviger til øvelsens mappe:
   ```bash
   cd oevelser/01-kanariefuglen
   ```

2. Start Postgres-containeren:
   ```bash
   docker compose up -d
   ```

3. Vent på, at databasen er klar (ca. 10-15 sekunder):
   ```bash
   docker compose exec postgres pg_isready -U studie
   ```
   Forventet output: `/var/run/postgresql:5432 - accepting connections`

## Opgaver

### 1. Initialisér testdata
Containeren starter med en **sulten** konfiguration (se `command:` i `docker-compose.yml`). Indlæs et pgbench-datasæt på skala 30 — ca. 3 millioner konti, godt 400 MB:

```bash
docker compose exec postgres pgbench -U studie -i -s 30 studiebase
```

Dette tager typisk 1-3 minutter. Har du under 4 GB RAM fri, brug i stedet skala 10 (`pgbench -U studie -i -s 10 studiebase`, ca. 130 MB) — øvelsen virker også der. Til sidst står der `done.` og tabellerne `pgbench_accounts`, `pgbench_branches`, `pgbench_tellers` og `pgbench_history` er oprettet.

**Bemærk:** Data ligger i Docker-volumenet `pgdata` og overlever `docker compose down`. Kør kun `-i` én gang. Skal du starte helt forfra, brug `docker compose down -v` (sletter dataene).

### 2. Mål baseline-ydeevne
Kør et standard `pgbench`-test med 4 klienter i 30 sekunder:
```bash
docker compose exec postgres pgbench -U studie -c 4 -T 30 studiebase
```
Notér den rapporterede **TPS (transactions per second)**. Dette er din baseline.

**Tjek:** TPS-værdien skal være markant lavere end på et lille datasæt — arbejdssættet overstiger `shared_buffers`, så databasen skal konstant læse fra disk.

### 3. Inspektér nuværende konfiguration
Kør fra psql:
```bash
docker compose exec postgres psql -U studie -d studiebase
```
```sql
SHOW shared_buffers;
SHOW work_mem;
SHOW effective_cache_size;
SHOW maintenance_work_mem;
```
Notér de nuværende værdier. Baseline er sat bevidst lavt: typisk `16MB`, `64kB`, `32MB`, `16MB`.

### 4. Se work_mem-efekten direkte (sortering på disk)
`work_mem` styrer, hvor meget hukommelse en enkelt sortering/hash må bruge, før den spilder til disk. Test det med `EXPLAIN ANALYZE` i psql:

```sql
EXPLAIN ANALYZE SELECT aid, abalance FROM pgbench_accounts ORDER BY abalance DESC;
```

Kig på linjen `Sort Method:` i outputtet. Med `work_mem=64kB` sorteres alle 3 mio. rækker — og sorteringen **spilder til disk** (`external merge Disk`). Notér `Execution Time`.

**Bemærk:** Fjern `LIMIT 10`! Med LIMIT ville planlæggeren vælge top-N heapsort, der kun holder 10 rækker i hukommelsen — så ville du slet ikke se disk-spill.

### 5. Justér konfigurationen
Rediger `docker-compose.yml` og find afsnittet under `command:`. Ændr følgende parametre:
- `shared_buffers=512MB`
- `work_mem=64MB`
- `effective_cache_size=2GB`
- `maintenance_work_mem=256MB`

Gem filen og genstart containeren:
```bash
docker compose down
docker compose up -d
```

### 6. Mål ydeevne med nye indstillinger
Når databasen er klar igen, kør pgbench-testen igen:
```bash
docker compose exec postgres pgbench -U studie -c 4 -T 30 studiebase
```
Notér den nye TPS-værdi.

Kør også sorteringsforespørgslen fra trin 4 igen:
```sql
EXPLAIN ANALYZE SELECT aid, abalance FROM pgbench_accounts ORDER BY abalance DESC LIMIT 10;
```
`Sort Method:` skulle nu være **quicksort Memory** (sorteringen foregår i RAM). Sammenlign `Execution Time` med trin 4.

### 7. Sammenlign resultater
Sammenlign TPS-værdierne fra trin 2 og 6. Beregn forbedringsprocenten:
```
Forbedring (%) = ((Ny TPS - Baseline TPS) / Baseline TPS) * 100
```
Med et arbejdssæt på ca. 400 MB og `shared_buffers` fra 16MB til 512MB kan du typisk se en målbar forbedring. Den præcise gevinst afhænger helt af din maskine (disk-type, RAM, page cache) — derfor måler vi i stedet for at gætte, og du må ikke forvente et bestemt tal.

### 8. Prøv at skrue for højt
Ændr `shared_buffers=8GB` (for højt for en container med 4 GB). Genstart:
```bash
docker compose down
docker compose up -d
```
Tjek status:
```bash
docker compose ps
docker compose logs postgres | tail -20
```
Observer fejlmeddelelsen (typisk `could not map anonymous shared memory`). Postgres starter ikke.

Gendan de fungerende indstillinger fra trin 5.

## Refleksion
1. Hvorfor kunne tuning først ses, da datasættet var større end hukommelsen?
2. Hvilke faktorer bør man overveje, når man justerer `shared_buffers`?
3. Hvorfor kan for høje hukommelsesindstillinger være problematiske?
4. Hvad er forskellen på `shared_buffers` (fysisk hukommelse) og `effective_cache_size` (planner-hint)?

## Det har du lært
- `pgbench -i -s N` opretter et testdatasæt; effekten af tuning afhænger af forholdet mellem arbejdssæt og hukommelse
- `shared_buffers` skal dimensioneres efter datastørrelsen — tuning af et datasæt, der allerede passer i RAM, ændrer intet
- `work_mem` ses direkte i `EXPLAIN`-output som Sort Method: external merge Disk vs. quicksort Memory
- `effective_cache_size` er et hint til planlæggeren, ikke allokeret hukommelse
- `shared_buffers` er Postgres' egen cache i RAM; resten af maskinens RAM går til operativsystemets page cache, som også cacher datafiler — derfor kan en query være hurtig uden at ramme `shared_buffers`, og derfor bør du køre hver måling flere gange
- Performance-tuning skal altid baseres på målinger, ikke antagelser
- For høje hukommelsesindstillinger kan føre til, at Postgres ikke starter
