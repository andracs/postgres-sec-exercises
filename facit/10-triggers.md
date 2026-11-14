# Facit: Øvelse 10 - Triggers og audit-log

## Forventede resultater

### Trin 1-2: audit-trigger
```sql
CREATE OR REPLACE FUNCTION log_aendring() RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO audit_log (tabel, handling, detaljer)
    VALUES (TG_TABLE_NAME, TG_OP, 'id=' || COALESCE(NEW.id::text, OLD.id::text));
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER produkter_audit
AFTER INSERT OR UPDATE OR DELETE ON produkter
FOR EACH ROW EXECUTE FUNCTION log_aendring();
```

### Trin 3: test
```sql
UPDATE produkter SET pris = 249.00 WHERE navn = 'Bog';   -- UPDATE 1
INSERT INTO produkter (navn, pris) VALUES ('Kalender', 89.00);  -- INSERT 0 1
DELETE FROM produkter WHERE navn = 'Pen';               -- DELETE 1
SELECT * FROM audit_log ORDER BY id;
```
**Tjek:** 3 rækker i audit_log: UPDATE id=1, INSERT id=4, DELETE id=3.

### Trin 4: validering med BEFORE-trigger
```sql
UPDATE produkter SET pris = -5 WHERE navn = 'Bog';
-- ERROR:  Pris må ikke være negativ (fandt -5)
-- UPDATE 0  (rækken ændres ikke)
```

### Trin 5: oversigt
```sql
SELECT tgname, tgenabled FROM pg_trigger WHERE NOT tgisinternal;
-- produkter_audit (O), produkter_tjek_pris (O)
```

### Trin 6: disable/enable
Med `produkter_audit` disabled kommer UPDATE ikke i audit_log; efter ENABLE igen gør den. `SELECT count(*) FROM audit_log;` vokser kun når triggeren er aktiv.

## Svar på refleksion

1. Triggeren kører altid — også fra andre klienter, scripts og replikering — så audit kan ikke "glemmes" af app-koden.
2. BEFORE kan ændre/afvise NEW (validering); AFTER kører efter ændringen er lavet (audit).
3. Hvis triggeren fejler (RAISE EXCEPTION), fejler hele statement'en — og i en stor transaktion rulles hele transaktionen tilbage.

## Typisk fejl
- Glemmer `RETURN NEW;` i en BEFORE-trigger → rækken bliver NULL/ikke ændret.
- `FOR EACH STATEMENT` i stedet for `FOR EACH ROW` — audit skal bruge ROW for at få NEW/OLD.
