# Facit - PostgreSQL Øvelsessamling

Dette dokument indeholder løsninger og forventede resultater for alle 13 øvelser i PostgreSQL-øvelsessamlingen.

## Indeks

| Nr | Titel | Niveau | Tid | Docker | Beskrivelse |
|----|-------|--------|-----|--------|-------------|
| 01 | [Benchmarking og hukommelseskonfiguration med pgbench](../oevelser/01-kanariefuglen/OEVELSE.md) | Let | 30-45 min | 🐳 | Performance-tuning med pgbench og konfiguration |
| 02 | [Statistik og ANALYZE til bedre query-planer](../oevelser/02-statistik-er-ikke-et-fyord/OEVELSE.md) | Let | 30 min | 🐳 | ANALYZE og query-planlægning |
| 03 | [Læsning af eksekveringsplaner med EXPLAIN](../oevelser/03-eksekveringsplan/OEVELSE.md) | Let | 45 min | 🐳 | EXPLAIN, seq scan, nested loop, hash join |
| 04 | [Indekser: hurtigere læsning, langsommere skrivning](../oevelser/04-indeksokonomi/OEVELSE.md) | Let | 45 min | 🐳 | Indekser, læse- vs skriveperformance |
| 05 | [Normalisering til 3NF og bevidst denormalisering](../oevelser/05-datamodellering/OEVELSE.md) | Middel | 60 min | 🐳 | Normalisering, denormalisering |
| 06 | [Overvågning af forbindelser og queries med pg_stat_activity](../oevelser/06-pg-stat-activity/OEVELSE.md) | Middel | 45 min | 🐳 | pg_stat_activity, idle in transaction |
| 07 | [Logging og audit af databaseaktivitet](../oevelser/07-logging/OEVELSE.md) | Middel | 45 min | 🐳 | PostgreSQL-log, fejlfinding |
| 08 | [Brugeradministration og rettigheder](../oevelser/08-roller/OEVELSE.md) | Middel | 45 min | 🐳 | Roller, GRANT/REVOKE, RLS |
| 09 | [Transaktioner, isolation og savepoints](../oevelser/09-transactions/OEVELSE.md) | Middel | 60 min | 🐳 | ACID, savepoints |
| 10 | [Triggers og audit-log](../oevelser/10-triggers/OEVELSE.md) | Middel | 45 min | 🐳 | Triggers, audit |
| 11 | [Kryptering med pgcrypto](../oevelser/11-kryptering/OEVELSE.md) | Middel | 45 min | 🐳 | pgp_sym_encrypt, crypt |
| 12 | [Backup og point-in-time recovery (PITR)](../oevelser/12-backup-pitr/OEVELSE.md) | Svær | 75 min | 🐳🐳 | pg_basebackup, WAL, PITR |
| 13 | [TLS på forbindelsen og secrets management](../oevelser/13-tls-secrets/OEVELSE.md) | Svær | 60 min | 🐳🐳 | TLS, pg_hba, Docker secrets |

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
