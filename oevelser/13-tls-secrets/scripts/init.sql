-- Initialiseringsscript for øvelse 13 - PostgreSQL Hardening
-- kører i appdb ved første container-start

\c appdb

-- Gør scriptet genkørbart
DROP TABLE IF EXISTS app_data, sensitive_data;

-- app_user oprettes med et LAB-password (Del C viser at det er en SCRAM-verifier;
-- Del E roterer det og flytter det til Docker secret)
DO $$
BEGIN
    IF NOT EXISTS (SELECT FROM pg_roles WHERE rolname = 'app_user') THEN
        CREATE ROLE app_user LOGIN PASSWORD 'lab-app-123';
    END IF;
END $$;

-- Applikationens egen tabel: app_user må kun SELECT/INSERT/UPDATE (least privilege)
CREATE TABLE app_data (
    id SERIAL PRIMARY KEY,
    note TEXT NOT NULL,
    ejer VARCHAR(50) DEFAULT 'app_user'
);
INSERT INTO app_data (note) SELECT 'note ' || i FROM generate_series(1, 20) AS i;
ALTER TABLE app_data OWNER TO app_user;
GRANT SELECT, INSERT, UPDATE ON app_data TO app_user;
GRANT USAGE, SELECT ON SEQUENCE app_data_id_seq TO app_user;

-- Følsom tabel: kun admin (ejeren) — app_user har ingen rettigheder
CREATE TABLE sensitive_data (
    id SERIAL PRIMARY KEY,
    secret TEXT NOT NULL
);
INSERT INTO sensitive_data (secret) VALUES ('lab-hemmelighed-1'), ('lab-hemmelighed-2');

VACUUM ANALYZE;

DO $$
DECLARE
    msg TEXT := 'appdb klar: roller admin + app_user, tabeller app_data (20 rækker) og sensitive_data. password_encryption=' ;
BEGIN
  RAISE NOTICE '%', msg || current_setting('password_encryption');
END $$;
