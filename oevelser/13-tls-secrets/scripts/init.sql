-- Initialiseringsscript for øvelse 13 - TLS og secrets

\c studiebase

-- Gør scriptet genkørbart
DROP TABLE IF EXISTS brugere;

CREATE TABLE brugere (
    id SERIAL PRIMARY KEY,
    brugernavn VARCHAR(100) NOT NULL UNIQUE,
    password_hash TEXT NOT NULL,   -- aldrig klartekst; hash gemmes her
    oprettet TIMESTAMP DEFAULT NOW()
);

INSERT INTO brugere (brugernavn, password_hash) VALUES
    ('admin', 'scram-sha-256$4096:<salt>$<hash>'),
    ('lager', 'scram-sha-256$4096:<salt>$<hash>');

VACUUM ANALYZE;

DO $$
DECLARE
    msg TEXT := 'Tabel brugere oprettet (2 rækker, password-hash). Klar til TLS/secrets-øvelser.';
BEGIN
  RAISE NOTICE '%', msg;
END $$;
