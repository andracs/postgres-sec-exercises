# Facit: Øvelse 06 - Overvågning af forbindelser og queries med pg_stat_activity

## Forventede resultater

### Aktive forbindelser og tilstande
```sql
SELECT pid, usename, state, query, query_start
FROM pg_stat_activity
WHERE datname = 'studiebase'
ORDER BY query_start;
```
Tilstander: `active` (kører nu), `idle` (tom), `idle in transaction` (åben transaktion uden commit — farlig).

### Langkørende query
```sql
-- Session 1:
SELECT pg_sleep(30), count(*) FROM store_data;
-- Session 2: rækken dukker op i pg_stat_activity med state='active'
```

### Idle in transaction
```sql
-- Session 1:
BEGIN;
UPDATE store_data SET data_value = data_value + 1 WHERE id = 1;
-- uden COMMIT bliver state 'idle in transaction'
```

### Dræb en forbindelse
```sql
SELECT pg_terminate_backend(<pid>);  -- true
```
Sessionen får `FATAL: terminating connection due to administrator command`.

### Blokeringer
```sql
SELECT blocked.pid, blocking.pid AS blocking_pid, blocked.query
FROM pg_blocking_pids(blocked.pid) blocking
JOIN pg_stat_activity blocked ON blocked.pid = ... ;
```
Klassisk join på pg_locks (se OEVELSE) eller `pg_blocking_pids()`.

### Custom monitoring-view
```sql
CREATE VIEW v_langsomme_queries AS
SELECT pid, usename, now() - query_start AS varighed, query
FROM pg_stat_activity
WHERE state = 'active' AND now() - query_start > interval '5 seconds';
```

## Svar på refleksion

1. En hængende query holder låse og forbindelser og kan få hele DB til at virke død.
2. `idle in transaction` holder row locks og forhindrer VACUUM i at rydde op (bloat).
3. `pg_terminate_backend` er hård (hele forbindelsen dør); `pg_cancel_backend` annullerer kun den aktive query.
