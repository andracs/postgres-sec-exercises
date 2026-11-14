-- Initialiseringsscript for øvelse 14 - [Title]

\c studiebase

-- Opret test tabel for Extensions test
-- Gør scriptet genkørbart (ellers fejler CREATE TABLE ved gentagelse)
DROP TABLE IF EXISTS extensions_test;

CREATE TABLE extensions_test (
    id SERIAL PRIMARY KEY,
    data VARCHAR(100),
    oprettet TIMESTAMP DEFAULT NOW()
);

-- Seed data
SET seed = 0.42;
INSERT INTO extensions_test (data)
SELECT md5(random()::text)
FROM generate_series(1, 100000) AS i;

VACUUM ANALYZE;

DO $$
DECLARE
    msg TEXT := 'Tabel extensions_test oprettet. Klargjort for Extensions test.';
BEGIN
  RAISE NOTICE '%', msg;
END $$;
