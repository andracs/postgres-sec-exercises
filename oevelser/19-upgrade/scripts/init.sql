-- Initialiseringsscript for øvelse 19 - [Title]

\c studiebase

-- Opret test tabel for Upgrade test
CREATE TABLE upgrade_test (
    id SERIAL PRIMARY KEY,
    data VARCHAR(100),
    oprettet TIMESTAMP DEFAULT NOW()
);

-- Seed data
SET seed = 42;
INSERT INTO upgrade_test (data)
SELECT md5(random()::text)
FROM generate_series(1, 100000) AS i;

VACUUM ANALYZE;

DO $$
DECLARE
    msg TEXT := 'Tabel upgrade_test oprettet. Klargjort for Upgrade test.';
BEGIN
  RAISE NOTICE '%', msg;
END $$;
