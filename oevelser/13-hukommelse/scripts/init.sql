-- Initialiseringsscript for øvelse 13 - [Title]

\c studiebase

-- Opret test tabel for Hukommelsestest
-- Gør scriptet genkørbart (ellers fejler CREATE TABLE ved gentagelse)
DROP TABLE IF EXISTS sort_test;

CREATE TABLE sort_test (
    id SERIAL PRIMARY KEY,
    data VARCHAR(100),
    oprettet TIMESTAMP DEFAULT NOW()
);

-- Seed data
SET seed = 0.42;
INSERT INTO sort_test (data)
SELECT md5(random()::text)
FROM generate_series(1, 100000) AS i;

VACUUM ANALYZE;

DO $$
DECLARE
    msg TEXT := 'Tabel sort_test oprettet. Klargjort for Hukommelsestest.';
BEGIN
  RAISE NOTICE '%', msg;
END $$;
