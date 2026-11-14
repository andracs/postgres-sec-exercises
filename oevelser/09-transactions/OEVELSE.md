# Øvelse 09: Transaktioner, isolation og savepoints

## Formål
At lære ACID-princippet i praksis: hvad der sker ved COMMIT/ROLLBACK, hvordan to samtidige sessioner ser hinandens ændringer ved forskellige isolationsniveauer, og hvordan savepoints redder delvist arbejde.

## Forudsætninger
- Docker Desktop eller Podman installeret
- Grundlæggende kendskab til SQL og psql

## Start

1. `cd oevelser/09-transactions`
2. `docker compose up -d`
3. `docker compose exec postgres pg_isready -U studie`
4. `docker compose exec postgres psql -U studie -d studiebase`

To samtidige sessioner: kør `./scripts/to-sessioner.sh` (eller åbn to terminaler med hver sin `docker compose exec -it postgres psql -U studie -d studiebase`).

## Opgaver

### 1. COMMIT gør ændringen permanent
```sql
BEGIN;
UPDATE konti SET saldo = saldo - 100 WHERE navn = 'Konto A';
SELECT navn, saldo FROM konti;
COMMIT;
SELECT navn, saldo FROM konti;   -- ændringen er gemt
```

### 2. ROLLBACK fortryder alt siden BEGIN
```sql
BEGIN;
UPDATE konti SET saldo = saldo - 500 WHERE navn = 'Konto A';
SELECT saldo FROM konti WHERE navn = 'Konto A';  -- viser 500 inden for transaktionen
ROLLBACK;
SELECT saldo FROM konti WHERE navn = 'Konto A';  -- viser igen 1000
```

### 3. To sessioner og READ COMMITTED (standard)
Session 1: `BEGIN; UPDATE konti SET saldo = 0 WHERE navn = 'Konto B';` (ikke commit endnu)
Session 2: `SELECT saldo FROM konti WHERE navn = 'Konto B';` → viser stadig 1000 (ser ikke ucommittede ændringer)
Session 1: `COMMIT;` → Session 2 ser nu 0 ved næste SELECT.

### 4. REPEATABLE READ: samme snapshot hele transaktionen
Session 1: `BEGIN; UPDATE konti SET saldo = 5 WHERE navn = 'Konto B'; COMMIT;`
Session 2: `BEGIN; SET TRANSACTION ISOLATION LEVEL REPEATABLE READ;` — bemærk: `SET TRANSACTION` skal stå **først i transaktionen** (lige efter BEGIN; før BEGIN virker også og gælder for næste transaktion). Så: `SELECT saldo FROM konti WHERE navn='Konto B';`
Session 1 ændrer igen og committer. Session 2's næste SELECT viser stadig den gamle værdi.

### 5. SAVEPOINT: fortryd kun en del
```sql
BEGIN;
UPDATE konti SET saldo = saldo - 10 WHERE navn = 'Konto A';
SAVEPOINT efter_fahlen;
UPDATE konti SET saldo = saldo - 9999 WHERE navn = 'Konto A';
ROLLBACK TO SAVEPOINT efter_fahlen;
COMMIT;
```
**Tjek:** Kun de 10 kr er trukket, ikke 9999.

### 6. Se aktive transaktioner
I en anden session:
```sql
SELECT pid, state, query, xact_start FROM pg_stat_activity WHERE state = 'idle in transaction';
```

## Refleksion

1. Hvad ville der ske uden transaktioner, hvis to overførsler kørte samtidig?
2. Hvornår vælger man SERIALIZABLE frem for REPEATABLE READ?
3. Hvorfor er "idle in transaction" farligt i produktion?

## Det har du lært

- BEGIN/COMMIT/ROLLBACK og hvad de betyder for synlighed
- Isolationsniveauer: READ COMMITTED, REPEATABLE READ, SERIALIZABLE
- SAVEPOINT til delvis rollback
- At overvåge transaktioner i pg_stat_activity
