# Facit: Øvelse 07 - Logging og audit af databaseaktivitet

## Forventede resultater

### Trin 1: aktuel konfiguration (fra compose)
```
log_destination = stderr
log_statement = none
log_min_duration_statement = 500ms
log_connections = on
```

### Trin 2: statement-logning
```sql
SET log_statement = 'all';
SELECT * FROM konto_log;
```
```bash
docker compose logs postgres | tail -20
```
Loggen viser `statement: SELECT * FROM konto_log;` osv.

### Trin 3: duration-log
`SET log_min_duration_statement = 0;` logger alt incl. `SELECT pg_sleep(0.05);` med `duration: 50.xxx ms`. Med 500ms logges kun queries over 500 ms.

### Trin 4: fejl i loggen
```sql
SELECT 1/0;
```
Loggen viser `ERROR:  division by zero` + `STATEMENT:  SELECT 1/0;`.

### Trin 5: forbindelser
Ny `docker compose exec ... psql` giver i loggen:
`LOG:  connection received: host=... ` og `LOG:  connection authenticated: ...` (fordi log_connections=on).

## Svar på refleksion

1. `log_statement=all` fylder disken og lækker følsomme data (parametre) i loggen — brug det kun kort ved fejlfinding.
2. `log_statement` logger ALLE statements; `log_min_duration_statement` logger kun dem over en tærskel — sidstnævnte er standard i produktion.
3. Logfiler bør sendes videre (syslog/ELK) og beskyttes — ellers kan en angriber slette spor, og log + data samme sted giver én kompromittering alt.
