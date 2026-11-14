# Øvelse 13: TLS på forbindelsen og secrets management

## Formål
At lære at slå TLS til på PostgreSQL-forbindelser (så trafikken ikke kan aflyttes), at kræve TLS i `pg_hba.conf`, og at holde passwords/certifikater uden for git via Docker secrets og .gitignore.

## Forudsætninger
- Docker Desktop eller Podman installeret
- `openssl` og `psql` på din host
- Grundlæggende kendskab til SQL

## Start

1. `cd oevelser/13-tls-secrets`
2. `./scripts/setup.sh` — laver `certs/` (self-signed) og `secrets/db_password.txt` (begge i .gitignore)
3. `docker compose up -d`
4. `docker compose exec postgres pg_isready -U studie`

Bemærk: compose-filen indeholder IKKE passwordet — det ligger i Docker secret `db_password` (`POSTGRES_PASSWORD_FILE`).

## Opgaver

### 1. Bekræft at TLS er slået til
```bash
docker compose exec postgres psql -U studie -d studiebase -c "SHOW ssl;"
```
```sql
SELECT ssl, version, cipher FROM pg_stat_ssl WHERE pid = pg_backend_pid();
```

### 2. Forbind fra hosten MED TLS
```bash
PGPASSWORD=$(cat secrets/db_password.txt) psql "host=localhost port=5432 dbname=studiebase user=studie sslmode=require" -c "SELECT ssl, version FROM pg_stat_ssl WHERE pid = pg_backend_pid();"
```
**Tjek:** `ssl` = t (true).

### 3. Strammere validering: verify-full med eget root-certifikat
```bash
PGPASSWORD=$(cat secrets/db_password.txt) psql "host=localhost dbname=studiebase user=studie sslmode=verify-full sslrootcert=certs/server.crt" -c "SELECT 1;"
```
**Tjek:** virker fordi certifikatet har CN=localhost. Prøv `sslmode=verify-full` uden rootcert — det fejler (ukendt CA).

### 4. Kræv TLS for ALLE forbindelser i pg_hba.conf
```bash
docker compose exec postgres bash -c "sed -i '1i hostnossl all all 0.0.0.0/0 reject' /var/lib/postgresql/data/pg_hba.conf && psql -U studie -d studiebase -c 'SELECT pg_reload_conf();'"
```
Test at en forbindelse uden TLS nu afvises:
```bash
PGPASSWORD=$(cat secrets/db_password.txt) psql "host=localhost dbname=studiebase user=studie sslmode=disable" -c "SELECT 1;"
```
**Tjek:** fejler med "no pg_hba.conf entry ... SSL off".

### 5. Secrets ligger ikke i git
```bash
grep -c "studie" docker-compose.yml   # password må IKKE stå her
cat .gitignore
git status --short                     # certs/ og secrets/ må ikke dukke op
```

### 6. Roter password (secret-rotation)
```bash
echo "nyt-$(openssl rand -base64 12)" > secrets/db_password.txt
docker compose down -v && docker compose up -d   # nyt volumen = nyt password ved init
docker compose exec postgres pg_isready -U studie
PGPASSWORD=$(cat secrets/db_password.txt) psql "host=localhost dbname=studiebase user=studie sslmode=require" -c "SELECT current_user;"
```

## Refleksion

1. Hvad beskytter TLS på forbindelsen — og hvad beskytter den IKKE (tænk på data i databasen i hvile)?
2. Hvorfor må certifikater og passwords aldrig i git?
3. Hvad ville du bruge i produktion i stedet for en lokal secrets-fil (f.eks. Vault, AWS Secrets Manager)?

## Det har du lært

- `ssl=on` + cert/key i compose, og at læse dem med `SHOW ssl` / `pg_stat_ssl`
- `sslmode=require` vs `verify-ca`/`verify-full` på klienten
- `hostnossl ... reject` i pg_hba.conf for at tvinge TLS
- Docker secrets (`POSTGRES_PASSWORD_FILE`) + .gitignore til credentials
