-- Initialiseringsscript for øvelse 05 - Datamodellering
-- Opret et denormaliseret ordreskema med problemer

\c studiebase

-- Gør scriptet genkørbart (ellers fejler CREATE TABLE ved gentagelse)
DROP TABLE IF EXISTS ordrer_denormaliseret;

-- Opret den denormaliserede tabel med alle problemer
-- Gør scriptet genkørbart (ellers fejler CREATE TABLE ved gentagelse)

CREATE TABLE ordrer_denormaliseret (
    ordre_id SERIAL PRIMARY KEY,
    -- Kundeoplysninger (redundant - gentages for hver ordre)
    kunde_id INTEGER,
    kunde_info JSONB,  -- Navn, email, telefon, adresse gemt som JSON
    
    -- Rundeoplysninger (dubletter - gentages for hver ordre i samme runde)
    runde_id INTEGER,
    runde_navn VARCHAR(100),
    runde_dato DATE,
    runde_status VARCHAR(20),
    
    -- Ordreoplysninger
    beloeb NUMERIC(10,2),
    ordre_dato TIMESTAMP DEFAULT NOW(),
    status VARCHAR(20) DEFAULT 'pendende',
    
    -- Ordre-linjer (skal være i separat tabel)
    produkt_id INTEGER,
    produkt_navn VARCHAR(100),
    antal INTEGER DEFAULT 1,
    enhedspris NUMERIC(10,2),
    
    -- Anakronisme: fremtidig dato
    forventet_levering DATE
);

-- Seed data med fast seed for determinisme (seed skal være -1..1, f.eks. 0.42)
SET seed = 0.42;

-- 10.000 kunder
WITH kunder_data AS (
    SELECT 
        i AS kunde_id,
        'Kunde ' || i AS navn,
        'kunde' || i || '@eksempel.dk' AS email,
        '12345678' AS telefon
    FROM generate_series(1, 10000) AS i
)

-- 100under
, runder_data AS (
    SELECT 
        i AS runde_id,
        'Runde ' || i AS runde_navn,
        '2023-01-01'::DATE + (i * 7)::INTEGER AS runde_dato,
        CASE WHEN i % 3 = 0 THEN 'afsluttet' ELSE 'aktiv' END AS runde_status
    FROM generate_series(1, 100) AS i
)

-- 500 produkter
, produkter_data AS (
    SELECT 
        i AS produkt_id,
        'Produkt ' || i AS produkt_navn,
        (random() * 1000)::NUMERIC(10,2) AS pris
    FROM generate_series(1, 500) AS i
)

-- Indsæt data i den denormaliserede tabel
INSERT INTO ordrer_denormaliseret (
    kunde_id, kunde_info,
    runde_id, runde_navn, runde_dato, runde_status,
    beloeb, ordre_dato, status,
    produkt_id, produkt_navn, antal, enhedspris,
    forventet_levering
)
SELECT 
    k.kunde_id,
    jsonb_build_object(
        'navn', k.navn,
        'email', k.email,
        'telefon', k.telefon
    ),
    r.runde_id,
    r.runde_navn,
    r.runde_dato,
    r.runde_status,
    (p.pris * (1 + random() * 5))::NUMERIC(10,2),
    r.runde_dato + (random() * 30)::INTEGER * INTERVAL '1 day',
    CASE 
        WHEN random() < 0.7 THEN 'afsluttet'
        WHEN random() < 0.2 THEN 'pendende'
        ELSE 'annulleret'
    END,
    p.produkt_id,
    p.produkt_navn,
    1 + (random() * 10)::INTEGER,
    p.pris,
    -- Anakronisme: nogle forventede leveringer er i fremtiden
    CASE 
        WHEN random() < 0.1 THEN r.runde_dato + INTERVAL '6 months'
        ELSE r.runde_dato + (random() * 30)::INTEGER * INTERVAL '1 day'
    END
FROM (
    -- Beregn nøgler pr. ordre-række i en subquery; random() i JOIN ON
    -- får ellers planlæggeren til at lægge filteret på CTE-scannet (0 rækker)
    SELECT
        floor(random() * 10000)::INTEGER + 1 AS kunde_key,
        floor(random() * 100)::INTEGER + 1 AS runde_key,
        floor(random() * 500)::INTEGER + 1 AS produkt_key
    FROM generate_series(1, 100000) AS o
) AS ordre_keys
JOIN kunder_data k ON k.kunde_id = ordre_keys.kunde_key
JOIN runder_data r ON r.runde_id = ordre_keys.runde_key
JOIN produkter_data p ON p.produkt_id = ordre_keys.produkt_key;

-- VACUUM ANALYZE
VACUUM ANALYZE;

DO $$
DECLARE
    msg TEXT := 'Denormaliseret tabel ordrer_denormaliseret oprettet med 100.000 rækker. Problemer: dubletter, redundans, anakronismer.';
BEGIN
  RAISE NOTICE '%', msg;
END $$;
