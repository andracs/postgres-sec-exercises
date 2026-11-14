-- Initialiseringsscript for øvelse 10 - Dødlås

\c studiebase

-- Opret en tabel til deadlock test
CREATE TABLE konto_deadlock (
    id SERIAL PRIMARY KEY,
    navn VARCHAR(100) NOT NULL,
    saldo NUMERIC(10,2) NOT NULL DEFAULT 0.00,
    version INTEGER DEFAULT 0
);

-- Seed med to konti
INSERT INTO konto_deadlock (navn, saldo) VALUES
    ('Konto X', 1000.00),
    ('Konto Y', 1000.00);

-- VACUUM ANALYZE
VACUUM ANALYZE;

DO $$
DECLARE
    msg TEXT := 'Tabel konto_deadlock (2 rækker) oprettet. Klargjort til deadlock test.';
BEGIN
  RAISE NOTICE '%', msg;
END $$;
