# Facit: Øvelse 13 - PostgreSQL Hardening (Netværk, autentifikation, TLS & secrets)

## Del A - adgangsmodellen (forventede værdier)
```sql
SHOW listen_addresses;     -- *
SHOW hba_file;             -- /etc/postgresql/pg_hba.conf (monteret fra repo-mappen)
SHOW password_encryption;  -- scram-sha-256
SHOW ssl;                  -- on
SELECT rolname, rolcanlogin FROM pg_roles;  -- admin + app_user (login)
```
Regler: første match vinder; `local`=socket, `host`=TCP, `hostssl`=kun TLS, `hostnossl`=kun uden TLS.

## Del B - netværk (forventet resultat af ./scripts/test-connections.sh)
```
PASS  app fra app-net med TLS + korrekt password
PASS  attacker fra attack-net (172.29.x) afvises af pg_hba
PASS  forkert password afvises
PASS  sslmode=disable afvises
Resultat: 4 PASS, 0 FAIL
```
Afvisningsfejl ser sådan ud: `ERROR: no pg_hba.conf entry for host "172.29.0.20" ...` og `... SSL off`.

## Del C - SCRAM
```sql
SELECT rolname, rolpassword LIKE 'SCRAM-SHA-256$%' AS er_scram FROM pg_authid WHERE rolname='app_user';
-- er_scram = t
```
`password_encryption` gælder kun ved næste password-SET; eksisterende verifiers migreres ikke automatisk — kør `ALTER ROLE x PASSWORD 'samme'` igen for at konvertere.

## Del D - TLS
- `sslmode=require`: `pg_stat_ssl.ssl = t`, version TLSv1.3.
- `sslmode=verify-full sslrootcert=certs/server.crt`: virker (certifikatets SAN indeholder localhost og 172.28.0.10).
- Uden TLS afvises af `host ... reject`.
- Kryptering uden certifikat-validering beviser ikke serverens identitet (MITM mulig) — derfor verify-full.

## Del E - secrets
- `grep -ri password docker-compose.yml` må kun vise `POSTGRES_PASSWORD_FILE`/secret-navne.
- Rotation: `ALTER ROLE app_user PASSWORD 'nyt-lab-password-456';` + opdater `secrets/app_password.txt` — ingen `down -v`, data bevares. test-connections.sh giver igen 4 PASS; gammelt password FAIL.

## Del F - challenge (3 problemer og løsninger)
1. `pg_hba.conf` med `trust` for alle + `0.0.0.0/0` → skift til `hostssl appdb app_user <app-subnet> scram-sha-256` + `hostnossl all all 0.0.0.0/0 reject`.
2. `app_user` er SUPERUSER → `ALTER ROLE app_user NOSUPERUSER;` + GRANT kun SELECT/INSERT/UPDATE på app_data; ingen adgang til sensitive_data.
3. `ssl=off`, port på `0.0.0.0:5432`, hardcoded password, ingen logging → `ssl=on` med cert, `127.0.0.1:5432:5432`, password via secret, `log_connections=on`.

## Typiske fejl
- `hba_file` monteret forkert sti → brug `SHOW hba_file` først.
- server.key uden læserettigheder for uid 999 → serveren starter ikke med ssl=on (setup.sh sætter chown 999).
- glemmer at `SET`/hba-ændringer kræver `SELECT pg_reload_conf();`.
