-- Initialiseringsscript for øvelse 08 - Brugeradministration og rettigheder

\c studiebase

-- Gør scriptet genkørbart
DROP TABLE IF EXISTS hemmelig_data;

CREATE TABLE hemmelig_data (
    id SERIAL PRIMARY KEY,
    navn VARCHAR(100) NOT NULL,
    hemmelighed VARCHAR(200),
    ejer VARCHAR(50) NOT NULL
);

INSERT INTO hemmelig_data (navn, hemmelighed, ejer) VALUES
    ('Lønnseddel', '32000 kr', 'hr'),
    ('Kundekontrakt', 'ACME A/S', 'salg'),
    ('Serveradgang', 'root@db01', 'drift'),
    ('Personalebudget', '1,2 mio', 'hr'),
    ('app_laeser egne noter', 'ses kun af app_laeser', 'app_laeser'),
    ('app_laeser anden række', 'også kun app_laeser', 'app_laeser');

-- Opret roller idempotent (CREATE ROLE understøtter ikke IF NOT EXISTS)
DO $$
BEGIN
    IF NOT EXISTS (SELECT FROM pg_roles WHERE rolname = 'app_laeser') THEN
        CREATE ROLE app_laeser LOGIN PASSWORD 'laeser123';
    END IF;
    IF NOT EXISTS (SELECT FROM pg_roles WHERE rolname = 'app_skriver') THEN
        CREATE ROLE app_skriver LOGIN PASSWORD 'skriver123';
    END IF;
    IF NOT EXISTS (SELECT FROM pg_roles WHERE rolname = 'app_admin') THEN
        CREATE ROLE app_admin LOGIN PASSWORD 'admin123';
    END IF;
END $$;

VACUUM ANALYZE;

DO $$
DECLARE
    msg TEXT := 'Tabel hemmelig_data (4 rækker) og rollerne app_laeser/app_skriver/app_admin oprettet.';
BEGIN
  RAISE NOTICE '%', msg;
END $$;
