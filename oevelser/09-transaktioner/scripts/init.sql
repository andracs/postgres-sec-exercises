-- Initialiseringsscript for øvelse 09 - Transaktioner, isolation og savepoints

\c studiebase

-- Gør scriptet genkørbart
DROP TABLE IF EXISTS transaktion_log, konti;

-- Konti-tabel til transaktionsøvelser
CREATE TABLE konti (
    id SERIAL PRIMARY KEY,
    navn VARCHAR(100) NOT NULL,
    saldo NUMERIC(12,2) NOT NULL DEFAULT 0.00,
    oprettet TIMESTAMP DEFAULT NOW(),
    sidst_opdateret TIMESTAMP DEFAULT NOW()
);

-- Log-tabel til at spore transaktioner
CREATE TABLE transaktion_log (
    id SERIAL PRIMARY KEY,
    fra_konto INTEGER REFERENCES konti(id),
    til_konto INTEGER REFERENCES konti(id),
    beloeb NUMERIC(12,2) NOT NULL,
    transaktion_tid TIMESTAMP DEFAULT NOW(),
    status VARCHAR(20) DEFAULT 'startet',
    session_id VARCHAR(50)
);

-- Seed data med to konti
INSERT INTO konti (navn, saldo) VALUES
    ('Konto A', 1000.00),
    ('Konto B', 1000.00);

VACUUM ANALYZE;

DO $$
DECLARE
    msg TEXT := 'Tabeller konti (2 rækker) og transaktion_log oprettet. Klar til transaktionsøvelser.';
BEGIN
  RAISE NOTICE '%', msg;
END $$;
