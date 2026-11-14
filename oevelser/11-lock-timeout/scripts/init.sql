-- Initialiseringsscript for øvelse 11 - Lock Timeout

\c studiebase

-- Opret en tabel til lock timeout test
-- Gør scriptet genkørbart (ellers fejler CREATE TABLE ved gentagelse)
DROP TABLE IF EXISTS kø, reserveret_ressource;

CREATE TABLE reserveret_ressource (
    id SERIAL PRIMARY KEY,
    navn VARCHAR(100) NOT NULL,
    status VARCHAR(20) DEFAULT 'ledig',
    reserveret_af INTEGER,
    reserveret_tid TIMESTAMP,
    lock_token VARCHAR(50)
);

-- Opret en kø-tabel
CREATE TABLE kø (
    id SERIAL PRIMARY KEY,
    ressource_id INTEGER REFERENCES reserveret_ressource(id),
    bruger_id INTEGER,
    anmodning_tid TIMESTAMP DEFAULT NOW(),
    status VARCHAR(20) DEFAULT 'venter'
);

-- Seed med 10 ressourcer
INSERT INTO reserveret_ressource (navn) VALUES
    ('Ressource 1'), ('Ressource 2'), ('Ressource 3'),
    ('Ressource 4'), ('Ressource 5'), ('Ressource 6'),
    ('Ressource 7'), ('Ressource 8'), ('Ressource 9'), ('Ressource 10');

-- VACUUM ANALYZE
VACUUM ANALYZE;

DO $$
DECLARE
    msg TEXT := 'Tabeller reserveret_ressource (10 rækker) og kø oprettet. Klargjort til lock timeout test.';
BEGIN
  RAISE NOTICE '%', msg;
END $$;
