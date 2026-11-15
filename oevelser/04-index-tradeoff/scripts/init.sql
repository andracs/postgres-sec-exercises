-- Initialiseringsscript for øvelse 04 - Indeksøkonomi

\c studiebase

-- Opret ordrer-tabel
-- Gør scriptet genkørbart (ellers fejler CREATE TABLE ved gentagelse)
DROP TABLE IF EXISTS ordrer;

CREATE TABLE ordrer (
    id SERIAL PRIMARY KEY,
    kunde_id INTEGER NOT NULL,
    status VARCHAR(20) NOT NULL,  -- 'pendende', 'afsluttet', 'annulleret'
    beloeb NUMERIC(10,2) NOT NULL,
    ordre_dato TIMESTAMP NOT NULL DEFAULT NOW(),
    leveringsdato TIMESTAMP,
    betalingsmetode VARCHAR(20)
);

-- Seed data med fast seed for determinisme
SET seed = 0.42;

-- 1 million ordrer
INSERT INTO ordrer (kunde_id, status, beloeb, ordre_dato, leveringsdato, betalingsmetode)
SELECT 
    floor(random() * 10000)::INTEGER + 1,
    CASE 
        WHEN random() < 0.7 THEN 'afsluttet'
        WHEN random() < 0.2 THEN 'pendende'
        ELSE 'annulleret'
    END,
    (random() * 10000)::NUMERIC(10,2),
    '2020-01-01'::TIMESTAMP + floor(random() * 1095)::INTEGER * INTERVAL '1 day',
    '2020-01-01'::TIMESTAMP + floor(random() * 1095)::INTEGER * INTERVAL '1 day' + INTERVAL '3 days',
    CASE (floor(random() * 4))::INTEGER
        WHEN 0 THEN 'Kort'
        WHEN 1 THEN 'MobilePay'
        WHEN 2 THEN 'Overførsel'
        ELSE 'Kontant'
    END
FROM generate_series(1, 1000000) AS i;

-- Opret et basalt indeks (kun for at undgå seq scan i alle queries)
CREATE INDEX idx_ordrer_id ON ordrer(id);

-- VACUUM ANALYZE for at opdatere statistik
VACUUM ANALYZE;

DO $$
DECLARE
    msg TEXT := 'Tabel ordrer oprettet med 1.000.000 rækker. Klargjort til indeksøvelser.';
BEGIN
  RAISE NOTICE '%', msg;
END $$;
