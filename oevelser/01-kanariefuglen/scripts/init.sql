-- Initialiseringsscript for øvelse 01
-- Opret database og pgbench-tabel

-- Skift til studiebase
\c studiebase

-- Opret pgbench standardtabeller
CREATE TABLE pgbench_accounts (
    aid INTEGER NOT NULL,
    bid INTEGER,
    abalance INTEGER,
    filler CHAR(84)
);

CREATE TABLE pgbench_branches (
    bid INTEGER NOT NULL,
    bbalance INTEGER,
    filler CHAR(88)
);

CREATE TABLE pgbench_history (
    tid INTEGER NOT NULL,
    bid INTEGER,
    aid INTEGER,
    delta INTEGER,
    mtime TIMESTAMP,
    filler CHAR(22)
);

CREATE TABLE pgbench_tellers (
    tid INTEGER NOT NULL,
    bid INTEGER,
    tbalance INTEGER,
    filler CHAR(84)
);

-- Indsæt testdata (standard pgbench skala 10 = 100.000 konti)
INSERT INTO pgbench_branches (bid, bbalance, filler)
SELECT 
    i,
    0,
    md5(random()::text) || md5(random()::text)
FROM generate_series(1, 10) AS i;

INSERT INTO pgbench_tellers (tid, bid, tbalance, filler)
SELECT 
    i,
    (i % 10) + 1,
    0,
    md5(random()::text) || md5(random()::text)
FROM generate_series(1, 100) AS i;

INSERT INTO pgbench_accounts (aid, bid, abalance, filler)
SELECT 
    i,
    (i % 10) + 1,
    0,
    md5(random()::text) || md5(random()::text)
FROM generate_series(1, 100000) AS i;

-- Opret primærnøgler
ALTER TABLE pgbench_branches ADD PRIMARY KEY (bid);
ALTER TABLE pgbench_tellers ADD PRIMARY KEY (tid);
ALTER TABLE pgbench_accounts ADD PRIMARY KEY (aid);

-- Opret indeks for pgbench
CREATE INDEX pgbench_accounts_bid_idx ON pgbench_accounts (bid);
CREATE INDEX pgbench_tellers_bid_idx ON pgbench_tellers (bid);

-- VACUUM for at sikre ren start
VACUUM ANALYZE;

-- Logbesked (korrekt syntaks for psql)
DO $$
BEGIN
  RAISE NOTICE 'pgbench-tabeller oprettet med 100.000 konti. Klargjort til benchmarking.';
END $$;
