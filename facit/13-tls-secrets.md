# Facit: Øvelse 13 - TLS på forbindelsen og secrets management

## Forventede resultater

### Trin 1-2: TLS slået til
```bash
docker compose exec postgres psql -U studie -d studiebase -c "SHOW ssl;"   -- on
```
```bash
PGPASSWORD=$(cat secrets/db_password.txt) psql "host=localhost dbname=studiebase user=studie sslmode=require" \
  -c "SELECT ssl, version, cipher FROM pg_stat_ssl WHERE pid = pg_backend_pid();"
-- ssl = t, version = TLSv1.3
```

### Trin 3: verify-full
```bash
PGPASSWORD=$(cat secrets/db_password.txt) psql "host=localhost dbname=studiebase user=studie sslmode=verify-full sslrootcert=certs/server.crt" -c "SELECT 1;"
-- virker (CN=localhost i certifikatet)
# uden sslrootcert fejler verify-full: "certificate verify failed" (self-signed = ukendt CA)
```

### Trin 4: tving TLS via pg_hba
```bash
docker compose exec postgres bash -c "sed -i '1i hostnossl all all 0.0.0.0/0 reject' /var/lib/postgresql/data/pg_hba.conf && psql -U studie -d studiebase -c 'SELECT pg_reload_conf();'"
PGPASSWORD=$(cat secrets/db_password.txt) psql "host=localhost dbname=studiebase user=studie sslmode=disable" -c "SELECT 1;"
-- ERROR: no pg_hba.conf entry for host ..., user "studie", database "studiebase", SSL off
```

### Trin 5-6: secrets uden for git + rotation
```bash
grep -c studie docker-compose.yml   # password står IKKE i filen (kun POSTGRES_PASSWORD_FILE)
git status --short                   # certs/ og secrets/ vises ikke (i .gitignore)
# rotation:
echo "nyt-$(openssl rand -base64 12)" > secrets/db_password.txt
docker compose down -v && docker compose up -d
```

## Svar på refleksion

1. TLS beskytter data i transit (netværk) mod aflytning/MITM — ikke data i hvile i databasen (der skal kryptering til, jf. øvelse 11).
2. Certifikater og passwords i git ender i historik, forks og leaks — brug secrets/vault og .gitignore.
3. I produktion: HashiCorp Vault, AWS Secrets Manager, Kubernetes Secrets — med rotation og adgangslog.

## Typiske fejl
- `POSTGRES_PASSWORD` og `POSTGRES_PASSWORD_FILE` samtidig → entrypoint fejler; brug kun _FILE.
- server.key skal være chmod 600 og ejes af postgres (uid 999 i imagen) — ellers nægter serveren at starte med ssl=on.
- `hostnossl ... reject` skal stå FØR den generelle `host all all all` regel (første match vinder) — derfor `sed -i '1i ...'`.
