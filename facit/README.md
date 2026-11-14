# Facit - PostgreSQL Øvelsessamling

Dette dokument indeholder løsninger og forventede resultater for alle 20 øvelser i PostgreSQL-øvelsessamlingen.

## Indeks

| Nr | Titel | Niveau | Tid | Docker | Beskrivelse |
|----|-------|--------|-----|--------|-------------|
| 01 | [Kanariefuglen i kuldemineren](../oevelser/01-kanariefuglen/OEVELSE.md) | Let | 30-45 min | 🐳 | Performance-tuning med pgbench og konfiguration |
| 02 | [Statistik er ikke et fyord](../oevelser/02-statistik-er-ikke-et-fyord/OEVELSE.md) | Let | 30 min | 🐳 | ANALYZE og query-planlægning |
| 03 | [At læse en eksekveringsplan er at læse poesi](../oevelser/03-eksekveringsplan/OEVELSE.md) | Let | 45 min | 🐳 | EXPLAIN, seq scan, nested loop, hash join |
| 04 | [Indeksøkonomi: fart er ikke gratis](../oevelser/04-indeksokonomi/OEVELSE.md) | Let | 45 min | 🐳 | Indekser, læse- vs skriveperformance |
| 05 | [Datamodellederens anger](../oevelser/05-datamodellering/OEVELSE.md) | Middel | 60 min | 🐳 | Normalisering, denormalisering |
| 06 | [pg_stat_activity som reality show](../oevelser/06-pg-stat-activity/OEVELSE.md) | Middel | 45 min | 🐳 | Overvågning af aktive forbindelser |
| 07 | [Journalterminalen: JSON uden dom](../oevelser/07-jsonb/OEVELSE.md) | Middel | 60 min | 🐳 | jsonb vs relationel modellering |
| 08 | [VACUUM dagbogen](../oevelser/08-vacuum/OEVELSE.md) | Middel | 45 min | 🐳 | Bloat, autovacuum, VACUUM FULL |
| 09 | [Transaktionsteateret](../oevelser/09-transaktioner/OEVELSE.md) | Middel | 60 min | 🐳 | Isolationsniveauer: READ COMMITTED, REPEATABLE READ, SERIALIZABLE |
| 10 | [Dødlåsens koreografi](../oevelser/10-deadlock/OEVELSE.md) | Middel | 45 min | 🐳 | Deadlocks med to sessioner |
| 11 | [Kødisciplin: lock_timeout som moral](../oevelser/11-lock-timeout/OEVELSE.md) | Middel | 45 min | 🐳 | Lock timeout og backoff |
| 12 | [Adgangskontrollens cirkulære beslutning](../oevelser/12-roller/OEVELSE.md) | Middel | 45 min | 🐳 | Roller, grants, tilladelsesgraf |
| 13 | [Hukommelsesøkonomien under pres](../oevelser/13-hukommelse/OEVELSE.md) | Middel | 45 min | 🐳 | work_mem, sortering, disk spill |
| 14 | [Extensionsbiografen: købe eller bygge?](../oevelser/14-extensions/OEVELSE.md) | Middel | 60 min | 🐳 | pg_trgm, pgcrypto, PostGIS |
| 15 | [Forbindelsespoolens venteværelse](../oevelser/15-pgbouncer/OEVELSE.md) | Svær | 60 min | 🐳🐳 | PgBouncer, connection pooling |
| 16 | [At partitionere fortiden](../oevelser/16-partitionering/OEVELSE.md) | Svær | 60 min | 🐳 | Deklarativ partitionering |
| 17 | [Backuppens værdi er nul, indtil den er testet](../oevelser/17-backup-pitr/OEVELSE.md) | Svær | 75 min | 🐳🐳 | WAL arkivering, PITR |
| 18 | [En hær af trofaste kopier](../oevelser/18-replikering/OEVELSE.md) | Ekspert | 75 min | 🐳🳿🐳 | Primary + replika, failover |
| 19 | [Den store migration](../oevelser/19-upgrade/OEVELSE.md) | Ekspert | 75 min | 🐳🐳 | Major version upgrade |
| 20 | [Den langsomme app: et afsluttende mordmysterium](../oevelser/20-mordmysterium/OEVELSE.md) | Ekspert | 90 min | 🐳🐳 | Integreret diagnoseøvelse |

## Brug af facit

Hver facit-fil indeholder:

1. **Forventede resultater** - Præcise outputs fra queries og kommandoer
2. **Komandoer og forklaringer** - De centrale kommandoer med detaljerede forklaringer
3. **Svar på refleksionsspørgsmål** - Fulde svar på alle refleksionsspørgsmål fra øvelsen
4. **Typiske fejl og løsninger** - Almindelige problemer studerende støder på, og hvordan man løser dem
5. **Læringsmål - tjekliste** - Oversigt over, hvad studerende skal have lært

## Struktur for facit-filer

```
# Facit: Øvelse XX - [Titel]

## Forventede resultater
- Outputs fra alle vigtige queries
- Forventede eksekveringstider
- Forventede eksekveringsplaner

## Komandoer og forklaringer
- SQL kommandoer med forklaringer
- Docker kommandoer
- Konfigurationsændringer

## Svar på refleksionsspørgsmål
- Svar 1
- Svar 2
- Svar 3

## Typiske fejl og løsninger
- Fejl 1: Årsag og løsning
- Fejl 2: Årsag og løsning

## Læringsmål - tjekliste
✅ Læringsmål 1
✅ Læringsmål 2
✅ Læringsmål 3
```

## Noter til undervisere

### Deterministiske resultater

- Alle seed-scripts bruger `SET seed = 42;` for at sikre, at data er identisk hver gang
- Facit kan derfor angive præcise forventede outputs
- Små variationer kan forekomme på forskellig hardware (f.eks. eksekveringstider)

### Performance-variationer

- TPS (transactions per second) og eksekveringstider kan variere baseret på:
  - Hardware (CPU, RAM, disk)
  - Docker konfiguration
  - Andre kørende processer
- Angiv derfor et interval (f.eks. "100-200 ms") i stedet for præcise værdier

### Forventede outputs

- Query-resultater skal matche facit nøjagtigt
- Eksekveringsplaner kan have små variationer i kost-estimater
- Rækkeantal skal være præcist (deterministisch seed)

## Opdateringer

- Facit-filer opdateres, når der findes fejl under test
- Se `TESTREPORT.md` i rod-mappen for en liste af rettelser
- Sidst opdateret: November 2026

## Kontakt

For spørgsmål eller fejlrapporter:
- Opret et issue med øvelsesnummer og beskrivelse af problemet
- Inkluder output fra:
  - `docker compose ps`
  - `docker compose logs postgres`
  - Den specifikke kommando, der fehler

---

*Facit tilhører underviserne - distribuer ikke til studerende*
