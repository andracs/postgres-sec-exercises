-- DroneTransport Næstved — syntetiske testdata (100% fiktive personer)
-- Kører i dronetransport ved første container-start

\c dronetransport

-- Gør scriptet genkørbart
DROP TABLE IF EXISTS orders, customers, staff;

CREATE TABLE customers (
    customer_id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL,
    phone VARCHAR(20),
    address VARCHAR(200)
);

CREATE TABLE orders (
    order_id SERIAL PRIMARY KEY,
    customer_id INTEGER REFERENCES customers(customer_id),
    pickup_address VARCHAR(200),
    delivery_address VARCHAR(200),
    package_description VARCHAR(200),
    order_status VARCHAR(20) DEFAULT 'oprettet',
    created_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE staff (
    staff_id SERIAL PRIMARY KEY,
    username VARCHAR(50) NOT NULL,
    role VARCHAR(30),
    department VARCHAR(30)
);

-- Fiktive danske navne/adresser (syntetiske)
SET seed = 0.42;

INSERT INTO customers (name, email, phone, address)
SELECT
    (ARRAY['Anders Andersen','Bente Bertelsen','Carl Carlsen','Dorthe Dahl','Ejner Eriksen','Freja Frederiksen','Gitte Gundersen','Henrik Hansen','Ida Iversen','Jens Jensen'])[1 + (i % 10)] || ' ' || i,
    'kunde' || i || '@eksempel.dk',
    '2' || LPAD((10000000 + i)::text, 8, '0'),
    (10 + i) || ' Testvej, 4700 Næstved'
FROM generate_series(1, 50) AS i;

INSERT INTO staff (username, role, department) VALUES
    ('admin1', 'admin', 'drift'),
    ('ks1', 'kundeservice', 'kundeservice'),
    ('ks2', 'kundeservice', 'kundeservice'),
    ('drift1', 'drift', 'drift'),
    ('temp1', 'praktikant', 'kundeservice');

INSERT INTO orders (customer_id, pickup_address, delivery_address, package_description, order_status)
SELECT
    1 + (i % 50),
    (10 + (i % 50)) || ' Testvej, 4700 Næstved',
    (100 + i) || ' Pakkevej, 4700 Næstved',
    'Pakke ' || i || ' (fiktiv)',
    CASE WHEN i % 4 = 0 THEN 'leveret' WHEN i % 4 = 1 THEN 'undervejs' ELSE 'oprettet' END
FROM generate_series(1, 200) AS i;

-- PROBLEM: app-bruger med alt for høje rettigheder
DO $$
BEGIN
    IF NOT EXISTS (SELECT FROM pg_roles WHERE rolname = 'app_user') THEN
        CREATE ROLE app_user LOGIN PASSWORD 'app123';
    END IF;
    IF NOT EXISTS (SELECT FROM pg_roles WHERE rolname = 'reader') THEN
        CREATE ROLE reader LOGIN PASSWORD 'reader123';
    END IF;
END $$;
ALTER ROLE app_user SUPERUSER;                 -- PROBLEM: app er superuser
GRANT ALL ON customers TO reader;               -- PROBLEM: bred adgang til PII
GRANT ALL ON orders TO reader;
GRANT ALL ON staff TO reader;

VACUUM ANALYZE;

DO $$
BEGIN
  RAISE NOTICE 'DroneTransport lab klar: 50 kunder, 200 ordrer, 5 staff (alle syntetiske). Roller: app_user (SUPERUSER!), reader.';
END $$;
