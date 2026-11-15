-- Initialiseringsscript for øvelse 01
-- pgbench-tabellerne oprettes AF DELTAGEREN i trin 1 med:
--   pgbench -U studie -i -s 30 studiebase
-- Dette script gør kun opmærksom på det ved første initialisering.

DO $$
BEGIN
    RAISE NOTICE 'Øvelse 01: Kør pgbench -i -s 30 studiebase for at oprette testdata (se OEVELSE.md trin 1).';
END $$;
