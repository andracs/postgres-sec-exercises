# Øvelse 08: Brugeradministration og rettigheder (roller, GRANT/REVOKE, RLS)

## Formål
At lære at oprette roller, tildele præcis de rettigheder hver rolle skal have (princippet om mindst mulig adgang) og begrænse rækker med Row Level Security.

## Forudsætninger
- Docker Desktop eller Podman installeret
- Grundlæggende kendskab til SQL og psql

## Start

1. `cd oevelser/08-roller`
2. `docker compose up -d`
3. `docker compose exec postgres pg_isready -U studie`
4. `docker compose exec postgres psql -U studie -d studiebase`

## Opgaver

### 1. Se hvilke roller der findes
```sql
SELECT rolname, rolcanlogin, rolsuper FROM pg_roles ORDER BY rolname;
```
**Tjek:** Du ser `studie` (superuser) samt `app_laeser`, `app_skriver`, `app_admin`.

### 2. Giv læserollen adgang til at læse — og kun det
```sql
GRANT USAGE ON SCHEMA public TO app_laeser;
GRANT SELECT ON hemmelig_data TO app_laeser;
```
Test som læser:
```sql
SET ROLE app_laeser;
SELECT * FROM hemmelig_data;   -- virker
INSERT INTO hemmelig_data (navn, hemmelighed, ejer) VALUES ('x','y','z');  -- fejler: permission denied
RESET ROLE;
```

### 3. Giv skriverollen læse+skrive, men ikke delete
```sql
GRANT SELECT, INSERT, UPDATE ON hemmelig_data TO app_skriver;
GRANT USAGE, SELECT ON SEQUENCE hemmelig_data_id_seq TO app_skriver;
```
Test med `SET ROLE app_skriver;` — INSERT virker, DELETE fejler.

### 4. Giv admin alle rettigheder på tabellen
```sql
GRANT ALL PRIVILEGES ON hemmelig_data TO app_admin;
```

### 5. Tag en rettighed væk igen (REVOKE)
```sql
REVOKE UPDATE ON hemmelig_data FROM app_skriver;
```
Test igen med `SET ROLE app_skriver;` — UPDATE fejler nu.

### 6. Row Level Security: hver må kun se egne rækker
```sql
ALTER TABLE hemmelig_data ENABLE ROW LEVEL SECURITY;
CREATE POLICY ejer_policy ON hemmelig_data
    USING (ejer = current_user);
SET ROLE app_laeser;
SELECT * FROM hemmelig_data;   -- ser kun rækker hvor ejer = 'app_laeser' (ingen)
RESET ROLE;
```

### 7. Se hvad hver rolle må på tabellen
```sql
SELECT grantee, privilege_type FROM information_schema.role_table_grants
WHERE table_name = 'hemmelig_data' ORDER BY grantee, privilege_type;
```

## Refleksion

1. Hvorfor er "mindst mulig adgang" (least privilege) vigtigt?
2. Hvad er forskellen på `GRANT ... TO rolle` og `SET ROLE`?
3. Hvornår er Row Level Security bedre end et almindeligt view?

## Det har du lært

- At oprette login-roller og inspicere dem i `pg_roles`
- `GRANT`/`REVOKE` på tabel- og sekvensniveau
- At teste rettigheder med `SET ROLE` uden ny forbindelse
- Row Level Security med policies
