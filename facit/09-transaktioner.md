# Facit: Øvelse 09 - Transaktioner, isolation og savepoints

## Forventede resultater

Seed: Konto A = 1000.00, Konto B = 1000.00.

### Trin 1: COMMIT
```sql
BEGIN;
UPDATE konti SET saldo = saldo - 100 WHERE navn = 'Konto A';  -- UPDATE 1
COMMIT;                                                        -- COMMIT
-- saldo for Konto A = 900.00 permanent
```

### Trin 2: ROLLBACK
```sql
BEGIN;
UPDATE konti SET saldo = saldo - 500 WHERE navn = 'Konto A';  -- viser 400 i transaktionen
ROLLBACK;                                                      -- ROLLBACK
-- saldo er igen 900.00
```

### Trin 3: READ COMMITTED (default)
Session 2 ser ikke session 1's ucommittede ændringer. Først efter COMMIT i session 1 ser session 2 den nye saldo.

### Trin 4: REPEATABLE READ
Session 2 med `SET TRANSACTION ISOLATION LEVEL REPEATABLE READ; BEGIN;` ser samme snapshot ved hver SELECT i transaktionen — også efter session 1 committer.

### Trin 5: SAVEPOINT
```sql
BEGIN;
UPDATE konti SET saldo = saldo - 10 WHERE navn = 'Konto A';   -- 890
SAVEPOINT efter_fahlen;
UPDATE konti SET saldo = saldo - 9999 WHERE navn = 'Konto A'; -- -9109
ROLLBACK TO SAVEPOINT efter_fahlen;                           -- tilbage til 890
COMMIT;                                                       -- kun 10 kr trukket
```

### Trin 6: overvågning
```sql
SELECT pid, state, left(query,60), xact_start FROM pg_stat_activity
WHERE datname = 'studiebase' AND state <> 'idle';
```

## Svar på refleksion

1. Uden transaktioner kunne to samtidige overførsler læse samme saldo og miste en af ændringerne (lost update).
2. SERIALIZABLE når flere rækker skal være konsistente samtidig (f.eks. beholdning må ikke gå under nul på tværs af rækker); det koster flere serialiseringsfejl.
3. `idle in transaction` holder låse og forhindrer VACUUM — sæt `idle_in_transaction_session_timeout` i produktion.
