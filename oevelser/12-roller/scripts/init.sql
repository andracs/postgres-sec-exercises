-- Initialiseringsscript for øvelse 12 - [Title]

\c studiebase

-- Opret test tabel for Roller og tilladelser
CREATE TABLE roller_test (
    id SERIAL PRIMARY KEY,
    data VARCHAR(100),
    oprettet TIMESTAMP DEFAULT NOW()
);

-- Seed data
SET seed = 42;
INSERT INTO roller_test (data)
SELECT md5(random()::text)
FROM generate_series(1, 100000) AS i;

VACUUM ANALYZE;

DO $$
DECLARE
    msg TEXT := 'Tabel roller_test oprettet. Klargjort for Roller og tilladelser.';
BEGIN
  RAISE NOTICE '%', msg;
END $$;
