-- Initialiseringsscript for øvelse 07 - JSONB vs Relationel

\c studiebase

-- Opret relationelle tabeller
CREATE TABLE kunder_relationel (
    id SERIAL PRIMARY KEY,
    navn VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    oprettet TIMESTAMP DEFAULT NOW()
);

CREATE TABLE ordrer_relationel (
    id SERIAL PRIMARY KEY,
    kunde_id INTEGER REFERENCES kunder_relationel(id),
    ordre_dato TIMESTAMP DEFAULT NOW(),
    status VARCHAR(20) DEFAULT 'pendende'
);

CREATE TABLE ordre_linjer_relationel (
    id SERIAL PRIMARY KEY,
    ordre_id INTEGER REFERENCES ordrer_relationel(id),
    produkt_id INTEGER NOT NULL,
    produkt_navn VARCHAR(100) NOT NULL,
    antal INTEGER NOT NULL DEFAULT 1,
    pris NUMERIC(10,2) NOT NULL
);

-- Opret JSONB tabel
CREATE TABLE ordrer_jsonb (
    id SERIAL PRIMARY KEY,
    kunde JSONB NOT NULL,
    ordre_dato TIMESTAMP DEFAULT NOW(),
    status VARCHAR(20) DEFAULT 'pendende',
    linjer JSONB NOT NULL,
    metadata JSONB
);

-- Seed data med fast seed
SET seed = 42;

-- 10.000 kunder
INSERT INTO kunder_relationel (navn, email)
SELECT 
    'Kunde ' || i,
    'kunde' || i || '@eksempel.dk'
FROM generate_series(1, 10000) AS i;

-- 100.000 ordrer relationelt
INSERT INTO ordrer_relationel (kunde_id, ordre_dato, status)
SELECT 
    (random() * 10000)::INTEGER + 1,
    '2020-01-01'::TIMESTAMP + (random() * 1095)::INTEGER * INTERVAL '1 day',
    CASE 
        WHEN random() < 0.7 THEN 'afsluttet'
        WHEN random() < 0.2 THEN 'pendende'
        ELSE 'annulleret'
    END
FROM generate_series(1, 100000) AS i;

-- 500.000 ordre-linjer relationelt
INSERT INTO ordre_linjer_relationel (ordre_id, produkt_id, produkt_navn, antal, pris)
SELECT 
    (random() * 100000)::INTEGER + 1,
    (random() * 1000)::INTEGER + 1,
    'Produkt ' || ((random() * 1000)::INTEGER + 1),
    1 + (random() * 10)::INTEGER,
    (random() * 1000)::NUMERIC(10,2)
FROM generate_series(1, 500000) AS i;

-- 100.000 ordrer med JSONB
INSERT INTO ordrer_jsonb (kunde, ordre_dato, status, linjer, metadata)
SELECT 
    jsonb_build_object(
        'id', k.id,
        'navn', k.navn,
        'email', k.email
    ),
    o.ordre_dato,
    o.status,
    (
        SELECT jsonb_agg(
            jsonb_build_object(
                'produkt_id', ol.produkt_id,
                'produkt_navn', ol.produkt_navn,
                'antal', ol.antal,
                'pris', ol.pris
            )
        )
        FROM ordre_linjer_relationel ol
        WHERE ol.ordre_id = o.id
        LIMIT 10  -- Max 10 linjer pr. ordre
    ),
    jsonb_build_object(
        'ip_adresse', '192.168.1.' || (random() * 255)::INTEGER,
        'browser', CASE (floor(random() * 4))::INTEGER
            WHEN 0 THEN 'Chrome'
            WHEN 1 THEN 'Firefox'
            WHEN 2 THEN 'Safari'
            ELSE 'Edge'
        END,
        'session_id', md5(random()::text)
    )
FROM ordrer_relationel o
JOIN kunder_relationel k ON o.kunde_id = k.id
WHERE (SELECT count(*) FROM ordre_linjer_relationel ol2 WHERE ol2.ordre_id = o.id) > 0;

-- Opret indeks
CREATE INDEX idx_ordrer_jsonb_status ON ordrer_jsonb(status);
CREATE INDEX idx_ordrer_jsonb_kunde_email ON ordrer_jsonb USING GIN ((kunde->>'email'));
CREATE INDEX idx_ordrer_jsonb_linjer_produkt ON ordrer_jsonb USING GIN (linjer jsonb_path_ops);

-- VACUUM ANALYZE
VACUUM ANALYZE;

DO $$
DECLARE
    msg TEXT := 'Relationelle tabeller (10K kunder, 100K ordrer, 500K linjer) og JSONB tabel (100K ordrer) oprettet.';
BEGIN
  RAISE NOTICE '%', msg;
END $$;
