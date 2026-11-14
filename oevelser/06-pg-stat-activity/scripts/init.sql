-- Initialiseringsscript for øvelse 06 - pg_stat_activity

\c studiebase

-- Opret en stor tabel til at simulere langkørende queries
CREATE TABLE store_data (
    id SERIAL PRIMARY KEY,
    data_value VARCHAR(100),
    numero INTEGER,
    oprettet TIMESTAMP DEFAULT NOW(),
    gruppe VARCHAR(20)
);

-- Seed data med fast seed for determinisme
SET seed = 42;

-- 5.000.000 rækker for at gøre queries langsomme
INSERT INTO store_data (data_value, numero, gruppe)
SELECT 
    md5(random()::text) || md5(random()::text),
    i,
    CASE (i % 5)
        WHEN 0 THEN 'Gruppe A'
        WHEN 1 THEN 'Gruppe B'
        WHEN 2 THEN 'Gruppe C'
        WHEN 3 THEN 'Gruppe D'
        ELSE 'Gruppe E'
    END
FROM generate_series(1, 5000000) AS i;

-- Opret et indeks for nogle queries
CREATE INDEX idx_store_data_id ON store_data(id);
CREATE INDEX idx_store_data_gruppe ON store_data(gruppe);

-- VACUUM ANALYZE for at opdatere statistik
VACUUM ANALYZE;

DO $$
DECLARE
    msg TEXT := 'Tabel store_data oprettet med 5.000.000 rækker. Klargjort til overvågningsøvelser.';
BEGIN
  RAISE NOTICE '%', msg;
END $$;
