-- Initialiseringsscript for øvelse 16 - [Title]

\c studiebase

-- Opret test tabel for Partitionering test
CREATE TABLE partition_test (
    id SERIAL PRIMARY KEY,
    data VARCHAR(100),
    oprettet TIMESTAMP DEFAULT NOW()
);

-- Seed data
SET seed = 42;
INSERT INTO partition_test (data)
SELECT md5(random()::text)
FROM generate_series(1, 100000) AS i;

VACUUM ANALYZE;

DO $$
DECLARE
    msg TEXT := 'Tabel partition_test oprettet. Klargjort for Partitionering test.';
BEGIN
  RAISE NOTICE '%', msg;
END $$;
