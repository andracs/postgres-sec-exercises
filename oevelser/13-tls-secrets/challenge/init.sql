-- Del F init: app_user får bevidst for mange rettigheder
\c appdb

DROP TABLE IF EXISTS app_data, sensitive_data;

DO $$
BEGIN
    IF NOT EXISTS (SELECT FROM pg_roles WHERE rolname = 'app_user') THEN
        CREATE ROLE app_user LOGIN PASSWORD 'app123';
    END IF;
END $$;

-- PROBLEM: app_user er superuser (kan alt, også læse sensitive_data)
ALTER ROLE app_user SUPERUSER;

CREATE TABLE app_data (
    id SERIAL PRIMARY KEY,
    note TEXT NOT NULL
);
INSERT INTO app_data (note) SELECT 'note ' || i FROM generate_series(1, 10) AS i;
ALTER TABLE app_data OWNER TO app_user;

CREATE TABLE sensitive_data (
    id SERIAL PRIMARY KEY,
    secret TEXT NOT NULL
);
INSERT INTO sensitive_data (secret) VALUES ('hemmelig-1');

VACUUM ANALYZE;
