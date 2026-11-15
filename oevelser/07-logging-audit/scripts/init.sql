-- Initialiseringsscript for øvelse 07 - Logging og audit

\c studiebase

-- Gør scriptet genkørbart
DROP TABLE IF EXISTS konto_log;

CREATE TABLE konto_log (
    id SERIAL PRIMARY KEY,
    konto VARCHAR(50) NOT NULL,
    beloeb NUMERIC(12,2) NOT NULL,
    oprettet TIMESTAMP DEFAULT NOW()
);

INSERT INTO konto_log (konto, beloeb) VALUES
    ('kasse', 1000.00),
    ('reserve', 5000.00),
    ('løn', 42000.00);

VACUUM ANALYZE;

DO $$
DECLARE
    msg TEXT := 'Tabel konto_log oprettet med 3 rækker. Klar til logningsøvelser.';
BEGIN
  RAISE NOTICE '%', msg;
END $$;
