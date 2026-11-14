# PostgreSQL sikkerhed - øvelsessamling

En samling af 13 øvelser til undervisning i PostgreSQL-administration, -optimering og -udvikling.

## Du skal bruge
- Docker Desktop eller Podman
- Minimum 8 GB RAM anbefalet

## Øvelser

| Nr | Titel | Niveau | Tid | Docker | Beskrivelse | Sikkerhedsaspekt |
|----|-------|--------|-----|--------|-------------|------------------|
| 01 | [Benchmarking og hukommelseskonfiguration med pgbench](./oevelser/01-kanariefuglen/OEVELSE.md) | Let | 30-45 min | 🐳 | CIA-A · ressource/DoS | Performance-tuning med pgbench og konfiguration |
| 02 | [Statistik og ANALYZE til bedre query-planer](./oevelser/02-statistik-er-ikke-et-fyord/OEVELSE.md) | Let | 30 min | 🐳 | — fundament | ANALYZE og query-planlægning |
| 03 | [Læsning af eksekveringsplaner med EXPLAIN](./oevelser/03-eksekveringsplan/OEVELSE.md) | Let | 45 min | 🐳 | — fundament | EXPLAIN, seq scan, nested loop, hash join |
| 04 | [Indekser: hurtigere læsning, langsommere skrivning](./oevelser/04-indeksokonomi/OEVELSE.md) | Let | 45 min | 🐳 | CIA-A · skrive-DoS | Indekser, læse- vs skriveperformance |
| 05 | [Normalisering til 3NF og bevidst denormalisering](./oevelser/05-datamodellering/OEVELSE.md) | Middel | 60 min | 🐳 | CIA-I · dataintegritet | Normalisering, denormalisering |
| 06 | [Overvågning af forbindelser og queries med pg_stat_activity](./oevelser/06-pg-stat-activity/OEVELSE.md) | Middel | 45 min | 🐳 | NIST AU · overvågning | Overvågning af aktive forbindelser |
| 07 | [Logging og audit af databaseaktivitet](./oevelser/07-logging/OEVELSE.md) | Middel | 45 min | 🐳 | NIST AU-2/AU-9 · audit & log | PostgreSQL-log, log_statement, fejlfinding |
| 08 | [Brugeradministration og rettigheder](./oevelser/08-roller/OEVELSE.md) | Middel | 45 min | 🐳 | NIST AC-3/AC-6 · least privilege, RLS | Roller, GRANT/REVOKE, Row Level Security |
| 09 | [Transaktioner, isolation og savepoints](./oevelser/09-transactions/OEVELSE.md) | Middel | 60 min | 🐳 | CIA-I · NIST SI-7 (ACID) | ACID, isolationsniveauer, to sessioner |
| 10 | [Triggers og audit-log](./oevelser/10-triggers/OEVELSE.md) | Middel | 45 min | 🐳 | NIST AU+SI · audit via triggers | Trigger-funktioner, BEFORE/AFTER |
| 11 | [Kryptering med pgcrypto](./oevelser/11-kryptering/OEVELSE.md) | Middel | 45 min | 🐳 | CIA-C · NIST SC-28 (kryptering i hvile) | pgp_sym_encrypt, password-hash med crypt |
| 12 | [Backup og point-in-time recovery (PITR)](./oevelser/12-backup-pitr/OEVELSE.md) | Svær | 75 min | 🐳🐳 | NIST CP-9/CP-10 · backup/PITR (CIA-A) | pg_basebackup, WAL-arkivering, recovery_target_time |
| 13 | [TLS på forbindelsen og secrets management](./oevelser/13-tls-secrets/OEVELSE.md) | Svær | 60 min | 🐳🐳 | NIST SC-8 TLS · IA-5 secrets (CIA-C) | SSL-certifikater, pg_hba hostnossl, Docker secrets |

*Sikkerhedsaspekt: CIA = fortrolighed (C), integritet (I), tilgængelighed (A). NIST henviser til kontrolfamilier i NIST SP 800-53: AU (audit/log), AC (adgangskontrol), SC (system & kommunikationsbeskyttelse), CP (beredskab/backup), SI (system- & informationsintegritet), IA (identifikation & autentifikation).*

## 🧭 Læringsstier (ca. 5 timer)

Usikker på hvor du skal starte? Vælg en sti. Detaljer findes i [LEARNING_PATHS.md](./LEARNING_PATHS.md).

```mermaid
flowchart LR
    Start([Vælg din sti]) --> P1["🌱 Sti 1: Fundament<br/>01 · 02 · 03 · 04 · 06 · 07"]
    Start --> P2["🔒 Sti 2: Sikkerhed<br/>07 · 08 · 10 · 11 · 13"]
    Start --> P3["⚙️ Sti 3: Drift & data<br/>05 · 09 · 12 · 13"]
    P1 --> Done([Alle 13 øvelser])
    P2 --> Done
    P3 --> Done
```

| | Sti | Målgruppe | Øvelser | Tid |
|---|-----|-----------|---------|-----|
| 🌱 | [Sti 1: Fundament](./LEARNING_PATHS.md#sti-1-fundament) | Nybegyndere | 01 · 02 · 03 · 04 · 06 · 07 | ~4 t |
| 🔒 | [Sti 2: Sikkerhed](./LEARNING_PATHS.md#sti-2-sikkerhed) | Alle | 07 · 08 · 10 · 11 · 13 | ~3,5 t |
| ⚙️ | [Sti 3: Drift & data](./LEARNING_PATHS.md#sti-3-drift--data) | DBA'er / udviklere | 05 · 09 · 12 · 13 | ~4,5 t |

## Brugsanvisning

### For studerende:

1. **Vælg en øvelse** fra listen ovenfor
2. Naviger til den ønskede øvelsesmappe:
   ```bash
   cd oevelser/07-logging   # eller en anden øvelse fra tabellen ovenfor
   ```

3. Start øvelsen:
   ```bash
   docker compose up -d
   ```

4. Vent på, at databasen er klar (ca. 10-15 sekunder):
   ```bash
   docker compose exec postgres pg_isready -U studie
   ```
   Forventet output: `/var/run/postgresql:5432 - accepting connections`

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

### Facit (løsninger) til alle øvelser
- Facit findes i `facit/` mappen
- Hver facit-fil indeholder forventede outputs og svar på refleksionsspørgsmål
- Al data er deterministiske (fast seed), så resultater kan reproduceres

### Generelle tips

- **Alle øvelser** bruger det samme login:
  - Bruger: `studie`
  - Password: `studie`
  - Database: `studiebase`
  - Port: `5432`

- **Port konflikter**: Kør kun én øvelse ad gangen, da alle bruger port 5432

- **Ventetid**: Containerne tager 10-30 sekunder at starte, afhængigt af om Docker images allerede er downloadet

- **Deterministiske data**: Alle seed-scripts bruger `SET seed = 0.42;` for at sikre reproducerbare resultater

### For øvelser med to sessioner (09):

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

- **PostgreSQL**: `postgres:18` til alle øvelser (øvelse 11 bruger også `pgcrypto` fra contrib, som følger med i imagen)

## Bidrag og rapportering

- Rapportér fejl via [GitHub Issues](https://github.com/andracs/postgres-sec-exercises/issues)
- Alle init-scripts er verificeret automatisk (køres to gange uden fejl); øvelserne er testet med Docker på macOS/Linux/Windows
- 8 GB RAM anbefalet

## Versioner

- PostgreSQL: 18.7
- Docker Compose: v2+
- Sidst opdateret: November 2026

---

*Lavet med kærlighed til databaseundervisning*
