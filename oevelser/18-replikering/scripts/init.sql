-- Initialiseringsscript for øvelse 18 - [Title]

\c studiebase

-- Opret test tabel for Replikering test
CREATE TABLE repl_test (
    id SERIAL PRIMARY KEY,
    data VARCHAR(100),
    oprettet TIMESTAMP DEFAULT NOW()
);

-- Seed data
SET seed = 42;
INSERT INTO repl_test (data)
SELECT md5(random()::text)
FROM generate_series(1, 100000) AS i;

VACUUM ANALYZE;

DO $$
DECLARE
    msg TEXT := 'Tabel repl_test oprettet. Klargjort for Replikering test.';
BEGIN
  RAISE NOTICE '%', msg;
END $$;
