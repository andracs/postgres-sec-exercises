# Øvelse 10: Triggers og audit-log via funktioner

## Formål
At lære at lave trigger-funktioner og hægte dem på tabeller, så ændringer automatisk logges (audit) eller valideres — uden at applikationen kan glemme det.

## Forudsætninger
- Docker Desktop eller Podman installeret
- Grundlæggende kendskab til SQL, PL/pgSQL og psql

## Start

1. `cd oevelser/10-triggers`
2. `docker compose up -d`
3. `docker compose exec postgres pg_isready -U studie`
4. `docker compose exec postgres psql -U studie -d studiebase`

## Opgaver

### 1. Opret en trigger-funktion der skriver til audit_log
```sql
CREATE OR REPLACE FUNCTION log_aendring() RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO audit_log (tabel, handling, detaljer)
    VALUES (TG_TABLE_NAME, TG_OP, 'id=' || COALESCE(NEW.id::text, OLD.id::text));
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
```

### 2. Hægt en AFTER INSERT/UPDATE/DELETE trigger på produkter
```sql
CREATE TRIGGER produkter_audit
AFTER INSERT OR UPDATE OR DELETE ON produkter
FOR EACH ROW EXECUTE FUNCTION log_aendring();
```

### 3. Test at triggeren virker
```sql
UPDATE produkter SET pris = 249.00 WHERE navn = 'Bog';
INSERT INTO produkter (navn, pris) VALUES ('Kalender', 89.00);
DELETE FROM produkter WHERE navn = 'Pen';
SELECT * FROM audit_log ORDER BY id;
```
**Tjek:** audit_log har 3 rækker med handling INSERT/UPDATE/DELETE.

### 4. BEFORE-trigger til validering (afvis ugyldige priser)
```sql
CREATE OR REPLACE FUNCTION tjek_pris() RETURNS TRIGGER AS $$
BEGIN
    IF NEW.pris < 0 THEN
        RAISE EXCEPTION 'Pris må ikke være negativ (fandt %)', NEW.pris;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER produkter_tjek_pris
BEFORE INSERT OR UPDATE ON produkter
FOR EACH ROW EXECUTE FUNCTION tjek_pris();
```
```sql
UPDATE produkter SET pris = -5 WHERE navn = 'Bog';  -- fejler med din besked
```

### 5. Se hvilke triggers der findes
```sql
SELECT tgname, tgtype, tgenabled FROM pg_trigger WHERE NOT tgisinternal;
```

### 6. Slå en trigger fra og til igen
```sql
ALTER TABLE produkter DISABLE TRIGGER produkter_audit;
UPDATE produkter SET pris = 1.00 WHERE navn = 'Bog';   -- ingen audit-række
ALTER TABLE produkter ENABLE TRIGGER produkter_audit;
UPDATE produkter SET pris = 2.00 WHERE navn = 'Bog';   -- audit igen
SELECT count(*) FROM audit_log;
```

## Refleksion

1. Hvornår er en trigger bedre end at applikationen selv skriver log?
2. Hvad er forskellen på BEFORE og AFTER triggers?
3. Hvad kan gå galt, hvis en trigger fejler midt i en stor transaktion?

## Det har du lært

- `CREATE FUNCTION ... RETURNS TRIGGER` i PL/pgSQL
- `CREATE TRIGGER ... BEFORE/AFTER INSERT/UPDATE/DELETE ... FOR EACH ROW`
- At bruge triggers til audit-log og validering
- `pg_trigger` og DISABLE/ENABLE TRIGGER
