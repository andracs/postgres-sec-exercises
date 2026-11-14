-- Initialiseringsscript for øvelse 03 - Eksekveringsplan

\c studiebase

-- Opret forfattere-tabel
CREATE TABLE forfattere (
    id SERIAL PRIMARY KEY,
    navn VARCHAR(100) NOT NULL,
    foedt INTEGER,
    nationalitet VARCHAR(50)
);

-- Opret boeger-tabel
CREATE TABLE boeger (
    id SERIAL PRIMARY KEY,
    titel VARCHAR(200) NOT NULL,
    forfatter_id INTEGER REFERENCES forfattere(id),
    udgivet INTEGER,
    isbn VARCHAR(20) UNIQUE,
    sideantal INTEGER
);

-- Opret laan-tabel
CREATE TABLE laan (
    id SERIAL PRIMARY KEY,
    bog_id INTEGER REFERENCES boeger(id),
    laaner_id INTEGER,
    laan_dato TIMESTAMP NOT NULL,
    retur_dato TIMESTAMP,
    status VARCHAR(20) DEFAULT 'aktiv'
);

-- Seed data med fast seed for determinisme
SET seed = 0.42;

-- 10.000 forfattere
INSERT INTO forfattere (navn, foedt, nationalitet)
SELECT 
    'Forfatter ' || i,
    1900 + (random() * 100)::INTEGER,
    CASE (i % 5)
        WHEN 0 THEN 'Dansker'
        WHEN 1 THEN 'Svensk'
        WHEN 2 THEN 'Norsk'
        WHEN 3 THEN 'Tysk'
        ELSE 'Engelskmand'
    END
FROM generate_series(1, 10000) AS i;

-- 100.000 boeger (10 boeger pr. forfatter i gennemsnit)
INSERT INTO boeger (titel, forfatter_id, udgivet, isbn, sideantal)
SELECT 
    'Bog ' || i || ' af Forfatter ' || (i % 10000) + 1,
    (i % 10000) + 1,
    1950 + (random() * 70)::INTEGER,
    'ISBN-' || LPAD(i::TEXT, 10, '0'),
    50 + (random() * 450)::INTEGER
FROM generate_series(1, 100000) AS i;

-- 1.000.000 laan-transaktioner
INSERT INTO laan (bog_id, laaner_id, laan_dato, retur_dato)
SELECT 
    floor(random() * 100000)::INTEGER + 1,
    floor(random() * 50000)::INTEGER + 1,
    '2020-01-01'::TIMESTAMP + (random() * 1095)::INTEGER * INTERVAL '1 day',
    '2020-01-01'::TIMESTAMP + (random() * 1095)::INTEGER * INTERVAL '1 day' + INTERVAL '14 days'
FROM generate_series(1, 1000000) AS i;

-- Opret indeks
CREATE INDEX idx_boeger_forfatter ON boeger(forfatter_id);
CREATE INDEX idx_laan_bog ON laan(bog_id);
CREATE INDEX idx_laan_l
aa
n_dato ON laan(laan_dato);

-- VACUUM ANALYZE for at opdatere statistik
VACUUM ANALYZE;

DO $$
DECLARE
    msg TEXT := 'Tabeller oprettet: 10.000 forfattere, 100.000 boeger, 1.000.000 laan. Klargjort til planlaegningsoevelser.';
BEGIN
  RAISE NOTICE '%', msg;
END $$;
