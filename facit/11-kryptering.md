# Facit: Øvelse 11 - Kryptering med pgcrypto

## Forventede resultater

### Trin 1: extension
```sql
SELECT extname, extversion FROM pg_extension WHERE extname = 'pgcrypto';
-- pgcrypto | 1.3  (følger med i postgres:18-imagen)
```

### Trin 2-3: krypteret felt og dekryptering
```sql
SELECT brugernavn, cpr_krypteret FROM brugere_krypteret LIMIT 3;
-- cpr_krypteret vises som bytea (\x...), ikke læsbart
SELECT brugernavn, pgp_sym_decrypt(cpr_krypteret, 'hemmelig-nøgle') AS cpr
FROM brugere_krypteret WHERE brugernavn = 'bruger1';
-- cpr = 010190-0001
```

### Trin 4: forkert nøgle
```sql
SELECT pgp_sym_decrypt(cpr_krypteret, 'forkert-nøgle') FROM brugere_krypteret LIMIT 1;
-- ERROR:  Wrong key or corrupt data
```

### Trin 5: password-hash
```sql
SELECT crypt('kode1', kodehash) = kodehash AS korrekt_kode
FROM brugere_krypteret WHERE brugernavn = 'bruger1';
-- korrekt_kode = t   (envvejs: kan tjekkes, ikke læses)
```

### Trin 6: søgning på krypteret felt
```sql
SELECT count(*) FROM brugere_krypteret
WHERE pgp_sym_decrypt(cpr_krypteret, 'hemmelig-nøgle') = '010190-0001';
-- 1 — men uden index på klarteksten; til opslag brug en separat hash-kolonne
```

## Svar på refleksion

1. Nøglen bør ligge uden for databasen (Vault, KMS, miljøvariabel) — ligger nøgle og data samme sted, er krypteringen værdiløs.
2. Kryptering i DB beskytter mod læsning af data-at-rest (backup-læk, fysisk disk) — ikke mod en angriber med DB-adgang eller imod datatransit (der skal TLS til).
3. TLS (`sslmode=verify-full`) beskytter trafikken mellem klient og server.

## Typisk fejl
- `CREATE EXTENSION pgcrypto` fejler hvis contrib ikke er installeret — i den officielle postgres:18 Docker-image er den med.
- Gemme passwords som pgp_sym_encrypt (tovejs) i stedet for crypt-hash (envvejs).
