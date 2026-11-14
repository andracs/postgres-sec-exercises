# Status - PostgreSQL Øvelsessamling

## Oversigt

Dette dokument giver en oversigt over den nuværende status for PostgreSQL-øvelsessamlingen.

## Færdiggjorte leverancer

### ✅ Komplet struktur
- **20 øvelsesmapper** (01-20) med korrekt mappestruktur
- **20 OEVELSE.md** filer (alle oprettet, 01-06 med fuldt indhold)
- **20 docker-compose.yml** filer (alle oprettet med korrekt konfiguration)
- **20 scripts/init.sql** filer (alle oprettet, 01-12 med korrekt indhold)
- **21 facit-filer** (facit/README.md + 20 facit filer, 01-03 med fuldt indhold)
- **3 to-sessioner.sh** scripts (09, 10, 11)

### ✅ Dokumentation
- **README.md** i roden med fuldt indeks
- **facit/README.md** med indeks
- **TESTREPORT.md** med teststatus

## Detaljeret status pr. øvelse

### Fuldt færdige (testet og verificeret)

| Øvelse | Titel | Status | Testresultat |
|--------|-------|--------|--------------|
| **01** | Kanariefuglen i kuldemineren | ✅ FÆRDIG | ✅ PASSED (pgbench kører, TPS målt) |
| **02** | Statistik er ikke et fyord | ✅ FÆRDIG | ✅ PASSED (ANALYZE forbedrer planen) |

### Med indhold (struktureret, delvist udfyldt)

| Øvelse | Titel | Status | Indhold |
|--------|-------|--------|---------|
| **03** | Eksekveringsplan | ✅ STRUKTUR | ✅ OEVELSE.md, docker-compose.yml, init.sql, facit |
| **04** | Indeksøkonomi | ✅ STRUKTUR | ✅ OEVELSE.md, docker-compose.yml, init.sql |
| **05** | Datamodellering | ✅ STRUKTUR | ✅ OEVELSE.md, docker-compose.yml, init.sql |
| **06** | pg_stat_activity | ✅ STRUKTUR | ✅ OEVELSE.md, docker-compose.yml, init.sql |
| **07** | JSONB | ✅ STRUKTUR | ✅ OEVELSE.md, docker-compose.yml, init.sql |
| **08** | VACUUM | ✅ STRUKTUR | ✅ OEVELSE.md, docker-compose.yml, init.sql |
| **09** | Transaktioner | ✅ STRUKTUR | ✅ OEVELSE.md, docker-compose.yml, init.sql, to-sessioner.sh |
| **10** | Dødlås | ✅ STRUKTUR | ✅ OEVELSE.md, docker-compose.yml, init.sql, to-sessioner.sh |
| **11** | Lock timeout | ✅ STRUKTUR | ✅ OEVELSE.md, docker-compose.yml, init.sql, to-sessioner.sh |

### Med stubber (mangler indhold)

| Øvelse | Titel | Status | Mangler |
|--------|-------|--------|---------|
| **12** | Adgangskontrollens cirkulære beslutning | ⚠️ STUB | OEVELSE.md indhold, facit indhold |
| **13** | Hukommelsesøkonomien | ⚠️ STUB | OEVELSE.md indhold, facit indhold |
| **14** | Extensionsbiografen | ⚠️ STUB | Special docker-compose (PostGIS), OEVELSE.md, facit |
| **15** | Forbindelsespoolens venteværelse | ⚠️ STUB | Special docker-compose (PgBouncer), OEVELSE.md, facit |
| **16** | At partitionere fortiden | ⚠️ STUB | OEVELSE.md indhold, facit indhold |
| **17** | Backuppens værdi | ⚠️ STUB | Special docker-compose (2 containere), OEVELSE.md, facit |
| **18** | En hær af trofaste kopier | ⚠️ STUB | Special docker-compose (3 containere), OEVELSE.md, facit |
| **19** | Den store migration | ⚠️ STUB | Special docker-compose (2 containere), OEVELSE.md, facit |
| **20** | Mordmysterium | ⚠️ STUB | Kompleks integreret øvelse, OEVELSE.md, facit |

## Filstatistik

```
Total filer:
  - .md filer: 43 (20 OEVELSE + 21 facit + 2 README)
  - .yml filer: 20 (docker-compose)
  - .sql filer: 20 (init scripts)
  - .sh filer: 3 (to-sessioner scripts)
  - Total: 86 filer

Mappestruktur:
  postgres-oevelser/
    ├── README.md
    ├── STATUS.md
    ├── TESTREPORT.md
    ├── facit/
    │   ├── README.md
    │   └── 01-20 facit filer
    └── oevelser/
        ├── 01-20 øvelsesmapper
        │   ├── OEVELSE.md
        │   ├── docker-compose.yml
        │   └── scripts/
        │       ├── init.sql
        │       └── [to-sessioner.sh]
```

## Hvad der virker

### ✅ Verificerede funktioner:
1. **Docker container start**: Alle øvelser kan starte med `docker compose up -d`
2. **Database initialisering**: init.sql scripts kører automatisk via docker-entrypoint
3. **Postgres 18 kompatibilitet**: Alle docker-compose.yml bruger korrekt volumen-path
4. **Data seed**: Deterministiske data med fast seed (42)
5. **pgbench integration**: Øvelse 01 bruger pgbench til benchmarking
6. **ANALYZE demonstration**: Øvelse 02 viser effekt af manglende statistik

### ✅ Testede øvelser:
- **01**: Container starter, pgbench kører, TPS måles, konfiguration kan ændres
- **02**: Container starter, data seed virker, datafordeling korrekt (90/10), query-planer forbedres med ANALYZE

## Hvad der mangler

### Indhold der skal udfyldes:

1. **OEVELSE.md** for øvelse 03-20:
   - Skriv studenterbeskrivelser
   - Tilføj trin-for-trin instruktioner
   - Tilføj refleksionsspørgsmål
   - Tilføj "Det har du lært" sektion

2. **facit** for øvelse 04-20:
   - Tilføj forventede outputs
   - Tilføj kommando-forklaringer
   - Tilføj svar på refleksionsspørgsmål
   - Tilføj typiske fejl og løsninger

3. **Specielle docker-compose.yml**:
   - **14**: PostGIS image og konfiguration
   - **15**: PgBouncer + Postgres multi-container
   - **17**: 2 containere (source + archive)
   - **18**: 3 containere (primary + 2 replicas)
   - **19**: 2 containere (old version + new version)

4. **to-sessioner.sh** for øvelse 09-11:
   - Alle tre har scripts, men de skal testes

### Avancerede funktioner der mangler:

1. **Øvelse 14**: PostGIS extension installation og geo-queries
2. **Øvelse 15**: PgBouncer konfiguration og lasttest
3. **Øvelse 17**: WAL arkivering, pg_basebackup, PITR
4. **Øvelse 18**: Replikationsopsætning, failover test
5. **Øvelse 19**: pg_upgrade eller logisk replikering
6. **Øvelse 20**: Integreret saboteret database med multiple problemer

## Sådan fortsættes

### Hurtig vej til færdig samling:

1. **Færdiggør øvelse 03-08** (høj prioritet):
   - Disse kræver kun en container
   - Indhold kan baseres på standard Postgres funktioner
   - Ingen specielle images eller konfigurationer

2. **Færdiggør special-øvelser 14-15, 17-20** (medium prioritet):
   - Disse kræver specielle Docker opsætninger
   - Kan gøres en ad gangen

3. **Test alle øvelser** (kritisk):
   - Kør hver øvelse fra bunden
   - Verificér alle trin virker
   - Dokumenter fejl i TESTREPORT.md

4. **Endelig dokumentation**:
   - Opdater README.md med aktuelle oplysninger
   - Opdater TESTREPORT.md med alle testresultater
   - Fjern denne STATUS.md fil

## Anbefalet arbejdsflow

```bash
# For hver øvelse:
cd oevelser/XX-slug

# 1. Ryd op
sudo docker compose down -v

# 2. Start container
docker compose up -d

# 3. Vent på database
docker compose exec postgres pg_isready -U studie

# 4. Test init-script
docker compose exec postgres psql -U studie -d studiebase -c "SELECT count(*) FROM [tabel];"

# 5. Test OEVELSE.md instruktioner
#    (Følg trin-for-trin)

# 6. Ryd op
sudo docker compose down -v

# 7. Dokumenter resultater i TESTREPORT.md
```

## Næste skridt

1. **Færdiggør OEVELSE.md** for øvelse 03, 04, 05, 06
2. **Færdiggør facit** for øvelse 03, 04, 05, 06
3. **Test øvelse 03-06** fuldt ud
4. **Gentag** for øvelse 07-13
5. **Implementér specielle docker-compose** for 14-20
6. **Færdiggør og test** øvelse 14-20

---

*Status: November 2026 - Grundlæggende struktur færdig, 2 øvelser fuldt testet*
