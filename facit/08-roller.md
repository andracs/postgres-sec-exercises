# Facit: Øvelse 08 - Brugeradministration og rettigheder (roller, GRANT/REVOKE, RLS)

## Forventede resultater

### Trin 1: roller
```sql
SELECT rolname, rolcanlogin, rolsuper FROM pg_roles ORDER BY rolname;
-- studie (super), app_laeser, app_skriver, app_admin (login, ikke super)
```

### Trin 2: læserolle
```sql
GRANT USAGE ON SCHEMA public TO app_laeser;
GRANT SELECT ON hemmelig_data TO app_laeser;
SET ROLE app_laeser;
SELECT * FROM hemmelig_data;    -- OK, 4 rækker
INSERT INTO hemmelig_data ...;   -- ERROR: permission denied for table hemmelig_data
RESET ROLE;
```

### Trin 3: skriverolle
```sql
GRANT SELECT, INSERT, UPDATE ON hemmelig_data TO app_skriver;
GRANT USAGE, SELECT ON SEQUENCE hemmelig_data_id_seq TO app_skriver;
-- SET ROLE app_skriver: INSERT OK, DELETE -> permission denied
```

### Trin 5: REVOKE
```sql
REVOKE UPDATE ON hemmelig_data FROM app_skriver;
-- nu fejler UPDATE også for app_skriver
```

### Trin 6: RLS
```sql
ALTER TABLE hemmelig_data ENABLE ROW LEVEL SECURITY;
CREATE POLICY ejer_policy ON hemmelig_data USING (ejer = current_user);
SET ROLE app_laeser;
SELECT * FROM hemmelig_data;   -- 0 rækker (ingen rækker har ejer='app_laeser')
RESET ROLE;
```

### Trin 7: oversigt
```sql
SELECT grantee, privilege_type FROM information_schema.role_table_grants
WHERE table_name = 'hemmelig_data' ORDER BY 1,2;
```

## Svar på refleksion

1. Least privilege begrænser skaden ved kompromitterede konti, insider-trusler og fejl — en app med kun SELECT kan ikke slette data.
2. `GRANT` tildeler rettigheden permanent til rollen; `SET ROLE` skifter kun hvilken rolle din nuværende session optræder som (til test).
3. RLS er bedre end views når mange forskellige brugere/roller skal se forskellige rækker af samme tabel — policyn håndhæves af DB'en selv, også for superusers (med FORCE) undtagen.

## Typisk fejl
- Glemmer `GRANT USAGE ON SCHEMA` — så får rollen "permission denied for schema public" selv med tabel-grants.
- Glemmer sekvens-rettigheder — INSERT med SERIAL fejler ellers med permission denied på sekvensen.
