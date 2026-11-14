-- Initialiseringsscript for øvelse 08 - VACUUM

\c studiebase

-- Opret en tabel til at generere dead tuples
CREATE TABLE bloat_test (
    id SERIAL PRIMARY KEY,
    data VARCHAR(100),
    counter INTEGER DEFAULT 0,
    oprettet TIMESTAMP DEFAULT NOW(),
    opdateret TIMESTAMP DEFAULT NOW()
);

-- Seed med 1 million rækker
SET seed = 42;

INSERT INTO bloat_test (data, counter)
SELECT 
    md5(random()::text) || md5(random()::text),
    (random() * 1000)::INTEGER
FROM generate_series(1, 1000000) AS i;

-- Opret indeks
CREATE INDEX idx_bloat_test_data ON bloat_test(data);

-- VACUUM ANALYZE for at starte med ren state
VACUUM ANALYZE;

DO $$
DECLARE
    msg TEXT := 'Tabel bloat_test oprettet med 1.000.000 rækker. Klargjort til VACUUM øvelser.';
BEGIN
  RAISE NOTICE '%', msg;
END $$;
