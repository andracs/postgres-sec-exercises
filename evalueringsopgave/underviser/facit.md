# Underviserfacit: DroneTransport Næstved (60 min)

## De tilsigtede sikkerhedsproblemer (7)

| # | Problem | Hvor det ses | Risiko | Mulig løsning |
|---|---------|--------------|--------|---------------|
| 1 | `pg_hba.conf`: `trust` for alle på `0.0.0.0/0` og `::/0` | pg_hba.conf | Enhver på netværket kan logge ind som enhver bruger uden password | `hostssl` + `scram-sha-256` kun fra app-subnet; `hostnossl ... reject`; fjern `trust` |
| 2 | Ingen TLS (`ssl=off`) | compose command | Trafik (inkl. passwords) kan aflyttes (MITM) | `ssl=on` + certifikater; kræv `hostssl` |
| 3 | Port bundet til `0.0.0.0:5432` | compose ports | DB eksponeret på hele netværket | `127.0.0.1:5432:5432` eller kun internt Docker-net |
| 4 | Hardcoded svagt password (`postgres123`) i offentlig compose-fil | compose env | Password lækket i repo/historik | Docker secret / `POSTGRES_PASSWORD_FILE`; stærkt password; rotation |
| 5 | `app_user` er SUPERUSER | init.sql (`ALTER ROLE app_user SUPERUSER`) | App-kompromitering = total adgang incl. `staff`/`customers` | `NOSUPERUSER` + kun nødvendige GRANTs på egne tabeller |
| 6 | `reader` har `GRANT ALL` på customers/orders/staff (PII) | init.sql | Læk af persondata ved kontoudnyttelse | Minimer privilegier (kun SELECT på nødvendige kolonner/tabeller, evt. RLS) |
| 7 | Ingen logging (`log_connections=off`, `log_statement=none`) og ingen backup (`archive_mode=off`) | compose command | Ingen spor ved incident; ingen recovery | `log_connections=on`, `log_statement=ddl`, WAL-arkivering + testet backup |

## Realistiske forbedringer en studerende kan nå på 25 min (mindst 2)
1. Stram `pg_hba.conf` (hostssl + scram kun fra app-subnet, reject resten) + `pg_reload_conf()` + positiv/negativ test.
2. `ALTER ROLE app_user NOSUPERUSER;` + smalle GRANTs; vis at app_user ikke længere kan læse `staff` (negativ test).
3. TLS til: generer cert, `ssl=on`, `hostssl`, test `sslmode=require` vs `sslmode=disable` (afvises).
4. Fjern hardcoded password → Docker secret; vis login med nyt password.

## Verifikation
Kør `underviser/verify.sh` før (viser usikker tilstand) og efter studentens ændringer.
