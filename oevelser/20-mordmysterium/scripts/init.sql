-- Initialiseringsscript for øvelse 20 - [Title]

\c studiebase

-- Opret test tabel for Mordmysterium database
-- Gør scriptet genkørbart (ellers fejler CREATE TABLE ved gentagelse)
DROP TABLE IF EXISTS mystery_db;

CREATE TABLE mystery_db (
    id SERIAL PRIMARY KEY,
    data VARCHAR(100),
    oprettet TIMESTAMP DEFAULT NOW()
);

-- Seed data
SET seed = 0.42;
INSERT INTO mystery_db (data)
SELECT md5(random()::text)
FROM generate_series(1, 100000) AS i;

VACUUM ANALYZE;

DO $$
DECLARE
    msg TEXT := 'Tabel mystery_db oprettet. Klargjort for Mordmysterium database.';
BEGIN
  RAISE NOTICE '%', msg;
END $$;
