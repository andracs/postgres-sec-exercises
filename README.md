# PostgreSQL Øvelsessamling

En komplet samling af 20 øvelser til undervisning i PostgreSQL-administration, -optimering og -udvikling.

## Forudsætninger

- Docker Desktop eller Podman installeret
- Minimum 8 GB RAM anbefalet (16 GB for øvelse 18+)
- Grundlæggende kendskab til terminal/kommandolinje

## Struktur

```
postgres-oevelser/
  README.md                    # Dette dokument
  oevelser/
    01-kanariefuglen/           # Hver øvelse har:
      OEVELSE.md               # Studenterbeskrivelse
      docker-compose.yml       # Docker opsætning
      scripts/                 # Initialiserings- og hjælpescripts
        init.sql              # Data-seed script
        [to-sessioner.sh]      # For øvelser med to sessioner
    02-statistik-er-ikke-et-fyord/
      ...
  facit/
    01-kanariefuglen.md        # Løsninger og forventede outputs
    ...
```

## Øvelser

| Nr | Titel | Niveau | Tid | Docker | Beskrivelse |
|----|-------|--------|-----|--------|-------------|
| 01 | [Kanariefuglen i kuldemineren](./oevelser/01-kanariefuglen/OEVELSE.md) | Let | 30-45 min | 🐳 | Performance-tuning med pgbench og konfiguration |
| 02 | [Statistik er ikke et fyord](./oevelser/02-statistik-er-ikke-et-fyord/OEVELSE.md) | Let | 30 min | 🐳 | ANALYZE og query-planlægning |
| 03 | [At læse en eksekveringsplan er at læse poesi](./oevelser/03-eksekveringsplan/OEVELSE.md) | Let | 45 min | 🐳 | EXPLAIN, seq scan, nested loop, hash join |
| 04 | [Indeksøkonomi: fart er ikke gratis](./oevelser/04-indeksokonomi/OEVELSE.md) | Let | 45 min | 🐳 | Indekser, læse- vs skriveperformance |
| 05 | [Datamodellederens anger](./oevelser/05-datamodellering/OEVELSE.md) | Middel | 60 min | 🐳 | Normalisering, denormalisering |
| 06 | [pg_stat_activity som reality show](./oevelser/06-pg-stat-activity/OEVELSE.md) | Middel | 45 min | 🐳 | Overvågning af aktive forbindelser |
| 07 | [Journalterminalen: JSON uden dom](./oevelser/07-jsonb/OEVELSE.md) | Middel | 60 min | 🐳 | jsonb vs relationel modellering |
| 08 | [VACUUM dagbogen](./oevelser/08-vacuum/OEVELSE.md) | Middel | 45 min | 🐳 | Bloat, autovacuum, VACUUM FULL |
| 09 | [Transaktionsteateret](./oevelser/09-transaktioner/OEVELSE.md) | Middel | 60 min | 🐳 | Isolationsniveauer: READ COMMITTED, REPEATABLE READ, SERIALIZABLE |
| 10 | [Dødlåsens koreografi](./oevelser/10-deadlock/OEVELSE.md) | Middel | 45 min | 🐳 | Deadlocks med to sessioner |
| 11 | [Kødisciplin: lock_timeout som moral](./oevelser/11-lock-timeout/OEVELSE.md) | Middel | 45 min | 🐳 | Lock timeout og backoff |
| 12 | [Adgangskontrollens cirkulære beslutning](./oevelser/12-roller/OEVELSE.md) | Middel | 45 min | 🐳 | Roller, grants, tilladelsesgraf |
| 13 | [Hukommelsesøkonomien under pres](./oevelser/13-hukommelse/OEVELSE.md) | Middel | 45 min | 🐳 | work_mem, sortering, disk spill |
| 14 | [Extensionsbiografen: købe eller bygge?](./oevelser/14-extensions/OEVELSE.md) | Middel | 60 min | 🐳 | pg_trgm, pgcrypto, PostGIS |
| 15 | [Forbindelsespoolens venteværelse](./oevelser/15-pgbouncer/OEVELSE.md) | Svær | 60 min | 🐳🐳 | PgBouncer, connection pooling |
| 16 | [At partitionere fortiden](./oevelser/16-partitionering/OEVELSE.md) | Svær | 60 min | 🐳 | Deklarativ partitionering |
| 17 | [Backuppens værdi er nul, indtil den er testet](./oevelser/17-backup-pitr/OEVELSE.md) | Svær | 75 min | 🐳🐳 | WAL arkivering, PITR |
| 18 | [En hær af trofaste kopier](./oevelser/18-replikering/OEVELSE.md) | Ekspert | 75 min | 🐳🐳🐳 | Primary + replika, failover |
| 19 | [Den store migration](./oevelser/19-upgrade/OEVELSE.md) | Ekspert | 75 min | 🐳🐳 | Major version upgrade |
| 20 | [Den langsomme app: et afsluttende mordmysterium](./oevelser/20-mordmysterium/OEVELSE.md) | Ekspert | 90 min | 🐳🐳 | Integreret diagnoseøvelse |

## Brugsanvisning

### For studerende:

1. **Vælg en øvelse** fra listen ovenfor
2. Naviger til den ønskede øvelsesmappe:
   ```bash
   cd oevelser/01-kanariefuglen
   ```

3. Start øvelsen:
   ```bash
   docker compose up -d
   ```

4. Vent på, at databasen er klar (ca. 10-15 sekunder):
   ```bash
   docker compose exec postgres pg_isready -U studie
   ```
   Forventet output: `postgres:5432 - accepting connections`

5. Koble til databasen:
   ```bash
   docker compose exec postgres psql -U studie -d studiebase
   ```

6. Følg instruktionerne i `OEVELSE.md`

7. **VIGTIGT**: Ryd op efter hver øvelse:
   ```bash
   docker compose down -v
   ```
   Dette fjerner containere, volumener og netværk.

### For undervisere:

- Facit findes i `facit/` mappen
- Hver facit-fil indeholder forventede outputs og svar på refleksionsspørgsmål
- Distribuer kun `oevelser/` til studerende (uden `facit/`)
- Alle data er deterministiske (fast seed), så resultater kan reproduceres

## Tips og tricks

### Generelle tips:

- **Alle øvelser** bruger det samme login:
  - Bruger: `studie`
  - Password: `studie`
  - Database: `studiebase`
  - Port: `5432`

- **Port konflikter**: Kør kun én øvelse ad gangen, da alle bruger port 5432

- **Ventetid**: Containerne tager 10-30 sekunder at starte, afhængigt af om Docker images allerede er downloadet

- **Deterministiske data**: Alle seed-scripts bruger `SET seed = 42;` for at sikre reproducerbare resultater

### For øvelser med to sessioner (09, 10, 11):

```bash
# Start to sessioner
./scripts/to-sessioner.sh

# Eller manuelt:
docker compose exec -it postgres psql -U studie -d studiebase &
docker compose exec -it postgres psql -U studie -d studiebase
```

## Fejlfinding

### "Port is already allocated"
**Årsag**: En anden container bruger port 5432
**Løsning**: 
```bash
# Stop den forrige øvelse
cd ../[forrige-oevelse]
docker compose down

# Prøv igen
cd ../[ny-oevelse]
docker compose up -d
```

### "Database does not exist"
**Årsag**: Containeren er ikke færdig med at initialisere
**Løsning**: Vent 10-15 sekunder og prøv:
```bash
docker compose exec postgres pg_isready -U studie
```

### "Connection refused"
**Årsag**: Containeren kører ikke
**Løsning**: Tjek status:
```bash
docker compose ps
```
Hvis containeren ikke kører, start den:
```bash
docker compose start
```

### "Permission denied" på scripts
**Løsning**: Gør scriptet eksekverbart:
```bash
chmod +x scripts/to-sessioner.sh
```

## Docker images brugt

- **PostgreSQL**: `postgres:18` (nyeste stabile version) til de fleste øvelser
- **PostGIS**: `postgis/postgis:18` til øvelse 14 (geo-querys)
- **PgBouncer**: `edoburu/pgbouncer:latest` til øvelse 15 (connection pooling)
- **PostgreSQL 17**: `postgres:17` til øvelse 19 (major upgrade)

## Bidrag og rapportering

- Rapportér fejl i `TESTREPORT.md`
- Alle øvelser er testet med Docker Desktop på macOS, Linux og Windows
- For bedste resultater: 8 GB RAM minimum, 16 GB anbefalet til avancerede øvelser

## Versioner

- PostgreSQL: 18.7
- Docker Compose: v2+
- Sidst opdateret: November 2026

---

*Lavet med kærlighed til databaseundervisning*
