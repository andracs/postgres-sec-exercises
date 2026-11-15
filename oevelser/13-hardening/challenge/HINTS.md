# Del F: hints (gradvise — prøv selv først)

## Hint 1
Kig på `challenge/pg_hba.conf` og `challenge/docker-compose.yml`. Hvad kan en hvilken som helst IP gøre lige nu?

## Hint 2
Tjek rollerne: `SELECT rolname, rolsuper, rolcanlogin FROM pg_roles;` — hvad kan `app_user`?

## Hint 3
Tjek TLS og logging: `SHOW ssl; SHOW log_connections;` — og port-publishing `0.0.0.0:5432`.

## Mulige løsninger (læs først efter eget forsøg)
1. pg_hba: `hostssl appdb app_user <kun app-subnet> scram-sha-256` + `hostnossl ... reject`; fjern `trust`.
2. `ALTER ROLE app_user NOSUPERUSER;` + kun SELECT/INSERT/UPDATE på app_data; ingen adgang til sensitive_data.
3. `ssl=on` med certifikat, `ports: 127.0.0.1:5432:5432`, password via secret (ikke i filen), `log_connections=on`.
