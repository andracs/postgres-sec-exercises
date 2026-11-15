-- Initialiseringsscript for øvelse 11 - Kryptering med pgcrypto
-- Bemærk: pgcrypto følger med i den officielle postgres:18 Docker-image (contrib)

\c studiebase

CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Gør scriptet genkørbart
DROP TABLE IF EXISTS brugere_krypteret;

CREATE TABLE brugere_krypteret (
    id SERIAL PRIMARY KEY,
    brugernavn VARCHAR(100) NOT NULL,
    cpr_krypteret BYTEA,   -- pgp_sym_encrypt: kun læsbart med nøglen
    kodehash TEXT          -- crypt(): envvejshashet password, kan ikke læses tilbage
);

SET seed = 0.42;

INSERT INTO brugere_krypteret (brugernavn, cpr_krypteret, kodehash)
SELECT
    'bruger' || i,
    pgp_sym_encrypt('010190-' || LPAD(i::text, 4, '0'), 'hemmelig-nøgle'),
    crypt('kode' || i, gen_salt('bf'))
FROM generate_series(1, 100) AS i;

VACUUM ANALYZE;

DO $$
DECLARE
    msg TEXT := 'Extension pgcrypto og tabel brugere_krypteret (100 rækker) oprettet. Klar til krypteringsøvelser.';
BEGIN
  RAISE NOTICE '%', msg;
END $$;
