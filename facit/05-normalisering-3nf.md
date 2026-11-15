# Facit: Øvelse 05 - Normalisering til 3NF og bevidst denormalisering

## Forventede resultater

### Trin 1-2: problemer i det denormaliserede skema
```sql
SELECT count(*) FROM ordrer_denormaliseret;  -- 100.000
SELECT runde_id, runde_navn, count(*) FROM ordrer_denormaliseret GROUP BY 1,2 HAVING count(*) > 1;
-- alle 100 runder vises (hver runde gentages for hver ordre = dubletter)
SELECT count(DISTINCT kunde_info), count(*) FROM ordrer_denormaliseret;
-- 10.000 unikke kunde_info mod 100.000 rækker (redundans)
```

### Trin 3-4: normaliseret skema (3NF) + migration
```sql
CREATE TABLE kunder (
    kunde_id INTEGER PRIMARY KEY,
    navn VARCHAR(100), email VARCHAR(100), telefon VARCHAR(20)
);
CREATE TABLE runder (
    runde_id INTEGER PRIMARY KEY,
    navn VARCHAR(100), dato DATE, status VARCHAR(20)
);
CREATE TABLE ordrer (
    ordre_id INTEGER PRIMARY KEY,
    runde_id INTEGER REFERENCES runder(runde_id),
    kunde_id INTEGER REFERENCES kunder(kunde_id),
    beloeb NUMERIC(10,2), ordre_dato TIMESTAMP, status VARCHAR(20)
);
CREATE TABLE ordre_linjer (
    linje_id SERIAL PRIMARY KEY,
    ordre_id INTEGER REFERENCES ordrer(ordre_id),
    produkt_id INTEGER, produkt_navn VARCHAR(100), antal INTEGER, enhedspris NUMERIC(10,2)
);

INSERT INTO kunder (kunde_id, navn, email, telefon)
SELECT DISTINCT kunde_id, kunde_info->>'navn', kunde_info->>'email', kunde_info->>'telefon'
FROM ordrer_denormaliseret;

INSERT INTO runder (runde_id, navn, dato, status)
SELECT DISTINCT runde_id, runde_navn, runde_dato, runde_status FROM ordrer_denormaliseret;

INSERT INTO ordrer (ordre_id, runde_id, kunde_id, beloeb, ordre_dato, status)
SELECT ordre_id, runde_id, kunde_id, beloeb, ordre_dato, status FROM ordrer_denormaliseret;

INSERT INTO ordre_linjer (ordre_id, produkt_id, produkt_navn, antal, enhedspris)
SELECT ordre_id, produkt_id, produkt_navn, antal, enhedspris FROM ordrer_denormaliseret;
```

**Tjek (tabellen hedder `runder`):**
```sql
SELECT count(*) FROM kunder;       -- 10.000
SELECT count(*) FROM runder;       -- 100
SELECT count(*) FROM ordrer;       -- 100.000
SELECT count(*) FROM ordre_linjer; -- 100.000 (én linje pr. ordre i seed-data)
```

### Trin 6-7: bevidst denormalisering
```sql
ALTER TABLE ordrer ADD COLUMN kunde_navn VARCHAR(100);
UPDATE ordrer o SET kunde_navn = k.navn FROM kunder k WHERE o.kunde_id = k.kunde_id;
```
Ordre-liste uden JOIN på kunder er målbart hurtigere.

### Trin 8: dokumentation
Eksempel: "kunde_navn denormaliseres for at undgå JOIN i den mest læste query; omkostning: vedligehold via trigger ved navneændring."

## Svar på refleksion

1. Dubletter, anakronismer (fremtidige datoer) og risiko for inkonsistens ved opdatering ét sted.
2. Når en meget læst query ellers skal JOIN'e hver gang, og data sjældent ændres.
3. Materialized views, ekstern cache, eller netop en enkelt denormaliseret kolonne.

## Typiske fejl (rettet i init.sql)
- `SET seed = 42` fejler (skal være 0.42) — og fordi docker-entrypoint kører med ON_ERROR_STOP=1, stoppede det gamle script før INSERT, så tabellen blev tom.
- `random()` i JOIN ON gav `INSERT 0 0` — nøgler beregnes nu i en subquery.
