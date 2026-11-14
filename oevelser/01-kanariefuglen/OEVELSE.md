# Øvelse 01: Kanariefuglen i kuldemineren

## Formål
At demonstrere, at Postgres' standardkonfiguration er konservativ, og at performance-tuning skal baseres på målinger, ikke gætteri. Du vil måle ydeevnen med `pgbench`, justere hukommelsesparametre og observere effekten.

## Forudsætninger
- Docker Desktop eller Podman installeret
- Minimum 4 GB RAM til rådighed for Docker
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
   Forventet output: `postgres:5432 - accepting connections`

4. Koble til databasen med psql:
   ```bash
   docker compose exec postgres psql -U studie -d studiebase
   ```

## Opgaver

### 1. Mål baseline-ydeevne
Kør et standard `pgbench`-test med 4 klienter i 30 sekunder:
```bash
docker compose exec postgres pgbench -U studie -c 4 -T 30 studiebase
```
Notér den rapporterede **TPS (transactions per second)**. Dette er din baseline.

**Tjek:** TPS-værdi skal vises som `latency average = X ms` og `tps = Y` i output.

### 2. Inspektér nuværende konfiguration
Kør fra psql:
```sql
SHOW shared_buffers;
SHOW work_mem;
SHOW effective_cache_size;
SHOW maintenance_work_mem;
```
Notér de nuværende værdier (standard er typisk 128MB, 4MB, 512MB, 64MB).

### 3. Justér konfigurationen
Rediger `docker-compose.yml` og find afsnittet under `command:`. Ændr følgende parametre:
- `shared_buffers=256MB`
- `work_mem=16MB`
- `effective_cache_size=768MB`
- `maintenance_work_mem=128MB`

Gem filen og genstart containeren:
```bash
docker compose down
docker compose up -d
```

### 4. Mål ydeevne med nye indstillinger
Når databasen er klar igen, kør pgbench-testen igen:
```bash
docker compose exec postgres pgbench -U studie -c 4 -T 30 studiebase
```
Notér den nye TPS-værdi.

### 5. Sammenlign resultater
Sammenlign TPS-værdierne fra trin 1 og 4. Beregn forbedringsprocenten:
```
Forbedring (%) = ((Ny TPS - Baseline TPS) / Baseline TPS) * 100
```

### 6. Prøv at skrue for højt
Ændr `shared_buffers=2GB` (for højt for denne container). Genstart og prøv at køre pgbench igen. Observer fejlmeddelelsen.

Gendann de fungerende indstillinger fra trin 3.

## Refleksion

1. Hvorfor er Postgres' standardindstillinger konservative?
2. Hvilke faktorer bør man overveje, når man justerer `shared_buffers`?
3. Hvorfor kan for høje hukommelsesindstillinger være problematiske?

## Det har du lært

- Postgres' standardkonfiguration er designet til at virke på de fleste systemer, ikke til at være optimal
- `pgbench` er et nyttigt værktøj til at måle transaktionsydeevne
- Hukommelsesparametre (`shared_buffers`, `work_mem`, `effective_cache_size`) har direkte indflydelse på performance
- Performance-tuning skal altid baseres på målinger, ikke antagelser
- For høje hukommelsesindstillinger kan føre til, at Postgres ikke starter