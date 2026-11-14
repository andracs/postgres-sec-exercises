-- Initialiseringsscript for øvelse 02 - Statistik
-- Opret tabel med skæv datafordeling

-- Skift til studiebase
\c studiebase

-- Opret kunder-tabel med skæv datafordeling
CREATE TABLE kunder (
    id SERIAL PRIMARY KEY,
    navn VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    status VARCHAR(20) NOT NULL,  -- 90% 'aktiv', 10% 'inaktiv'
    aldersgruppe VARCHAR(10) NOT NULL, -- Fordelt jævnt
    oprettet TIMESTAMP DEFAULT NOW(),
    saldo NUMERIC(10,2) DEFAULT 0.00
);

-- Opret indeks på status og aldersgruppe
CREATE INDEX idx_kunder_status ON kunder(status);
CREATE INDEX idx_kunder_aldersgruppe ON kunder(aldersgruppe);
CREATE INDEX idx_kunder_status_aldersgruppe ON kunder(status, aldersgruppe);

-- Seed data: 1 million kunder med skæv fordeling
-- 90% aktiv, 10% inaktiv
-- Aldersgrupper: '18-25', '26-35', '30-40', '41-50', '51-65', '65+'
-- Brug fast seed for deterministisk output
SET seed = 0.42;

INSERT INTO kunder (navn, email, status, aldersgruppe, saldo)
SELECT 
    'Kunde ' || i,
    'kunde' || i || '@eksempel.dk',
    CASE 
        WHEN i <= 900000 THEN 'aktiv'
        ELSE 'inaktiv'
    END,
    CASE 
        WHEN i % 6 = 0 THEN '18-25'
        WHEN i % 6 = 1 THEN '26-35'
        WHEN i % 6 = 2 THEN '30-40'
        WHEN i % 6 = 3 THEN '41-50'
        WHEN i % 6 = 4 THEN '51-65'
        ELSE '65+'
    END,
    (random() * 10000)::NUMERIC(10,2)
FROM generate_series(1, 1000000) AS i;

-- VACUUM men IKKE ANALYZE - vi vil demonstrere effekten af manglende statistik
VACUUM kunder;

-- Meddelelse - brug NOTICE med korrekt syntaks
DO $$
DECLARE
    msg TEXT := 'Tabel kunder oprettet med 1.000.000 rækker (90% aktiv, 10% inaktiv). Aldersgrupper jævnt fordelt. Statistik er IKKE opdateret.';
BEGIN
  RAISE NOTICE '%', msg;
END $$;
