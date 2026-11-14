-- Initialiseringsscript for øvelse 09 - Transaktionsteateret

\c studiebase

-- Opret konti-tabel til isolationsniveau test
CREATE TABLE konti (
    id SERIAL PRIMARY KEY,
    navn VARCHAR(100) NOT NULL,
    saldo NUMERIC(10,2) NOT NULL DEFAULT 0.00,
    oprettet TIMESTAMP DEFAULT NOW(),
    sidst_opdateret TIMESTAMP DEFAULT NOW()
);

-- Opret en log-tabel til at tracke transaktioner
CREATE TABLE transaktion_log (
    id SERIAL PRIMARY KEY,
    fra_konto INTEGER REFERENCES konti(id),
    til_konto INTEGER REFERENCES konti(id),
    beloeb NUMERIC(10,2) NOT NULL,
    transaktion_tid TIMESTAMP DEFAULT NOW(),
    status VARCHAR(20) DEFAULT 'startet',
    session_id VARCHAR(50)
);

-- Seed data med to konti
INSERT INTO konti (navn, saldo) VALUES
    ('Konto A', 1000.00),
    ('Konto B', 1000.00);

-- VACUUM ANALYZE
VACUUM ANALYZE;

DO $$
DECLARE
    msg TEXT := 'Tabeller konti (2 rækker) og transaktion_log oprettet. Klargjort til isolationsniveau test.';
BEGIN
  RAISE NOTICE '%', msg;
END $$;
