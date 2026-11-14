-- Initialiseringsscript for øvelse 15 - [Title]

\c studiebase

-- Opret test tabel for Connection pool test
-- Gør scriptet genkørbart (ellers fejler CREATE TABLE ved gentagelse)
DROP TABLE IF EXISTS pool_test;

CREATE TABLE pool_test (
    id SERIAL PRIMARY KEY,
    data VARCHAR(100),
    oprettet TIMESTAMP DEFAULT NOW()
);

-- Seed data
SET seed = 0.42;
INSERT INTO pool_test (data)
SELECT md5(random()::text)
FROM generate_series(1, 100000) AS i;

VACUUM ANALYZE;

DO $$
DECLARE
    msg TEXT := 'Tabel pool_test oprettet. Klargjort for Connection pool test.';
BEGIN
  RAISE NOTICE '%', msg;
END $$;
