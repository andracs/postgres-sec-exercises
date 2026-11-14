# Facit - PostgreSQL Øvelsessamling

Dette dokument indeholder løsninger og forventede resultater for øvelserne 01–03 (facit for 04–11 er ikke skrevet endnu) i PostgreSQL-øvelsessamlingen.

## Indeks

| Nr | Titel | Niveau | Tid | Docker | Beskrivelse |
|----|-------|--------|-----|--------|-------------|
| 01 | [Benchmarking og hukommelseskonfiguration med pgbench](../oevelser/01-kanariefuglen/OEVELSE.md) | Let | 30-45 min | 🐳 | Performance-tuning med pgbench og konfiguration |
| 02 | [Statistik og ANALYZE til bedre query-planer](../oevelser/02-statistik-er-ikke-et-fyord/OEVELSE.md) | Let | 30 min | 🐳 | ANALYZE og query-planlægning |
| 03 | [Læsning af eksekveringsplaner med EXPLAIN](../oevelser/03-eksekveringsplan/OEVELSE.md) | Let | 45 min | 🐳 | EXPLAIN, seq scan, nested loop, hash join |

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
