-- Initialiseringsscript for øvelse 12 - Backup og PITR

\c studiebase

-- Gør scriptet genkørbart
DROP TABLE IF EXISTS vigtige_data;

CREATE TABLE vigtige_data (
    id SERIAL PRIMARY KEY,
    tekst VARCHAR(200) NOT NULL,
    oprettet TIMESTAMP DEFAULT NOW()
);

-- Data der findes FØR backuppet (skal kunne gendannes)
INSERT INTO vigtige_data (tekst)
SELECT 'række før backup ' || i FROM generate_series(1, 100) AS i;

VACUUM ANALYZE;

DO $$
DECLARE
    msg TEXT := 'Tabel vigtige_data oprettet med 100 rækker (før backup). Klar til backup/PITR-øvelser.';
BEGIN
  RAISE NOTICE '%', msg;
END $$;
