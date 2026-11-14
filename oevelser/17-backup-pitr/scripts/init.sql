-- Initialiseringsscript for øvelse 17 - [Title]

\c studiebase

-- Opret test tabel for Backup test
-- Gør scriptet genkørbart (ellers fejler CREATE TABLE ved gentagelse)
DROP TABLE IF EXISTS backup_test;

CREATE TABLE backup_test (
    id SERIAL PRIMARY KEY,
    data VARCHAR(100),
    oprettet TIMESTAMP DEFAULT NOW()
);

-- Seed data
SET seed = 0.42;
INSERT INTO backup_test (data)
SELECT md5(random()::text)
FROM generate_series(1, 100000) AS i;

VACUUM ANALYZE;

DO $$
DECLARE
    msg TEXT := 'Tabel backup_test oprettet. Klargjort for Backup test.';
BEGIN
  RAISE NOTICE '%', msg;
END $$;
