-- Initialiseringsscript for øvelse 10 - Triggers og audit-log

\c studiebase

-- Gør scriptet genkørbart
DROP TABLE IF EXISTS audit_log, produkter;

CREATE TABLE produkter (
    id SERIAL PRIMARY KEY,
    navn VARCHAR(100) NOT NULL,
    pris NUMERIC(10,2) NOT NULL
);

-- Audit-log: hvem ændrede hvad, hvornår
CREATE TABLE audit_log (
    id SERIAL PRIMARY KEY,
    tabel VARCHAR(50) NOT NULL,
    handling VARCHAR(10) NOT NULL,
    detaljer TEXT,
    tid TIMESTAMP DEFAULT NOW()
);

INSERT INTO produkter (navn, pris) VALUES
    ('Bog', 199.00),
    ('Notesbog', 49.00),
    ('Pen', 12.50);

VACUUM ANALYZE;

DO $$
DECLARE
    msg TEXT := 'Tabeller produkter (3 rækker) og audit_log oprettet. Klar til trigger-øvelser.';
BEGIN
  RAISE NOTICE '%', msg;
END $$;
