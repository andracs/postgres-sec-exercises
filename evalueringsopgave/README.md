# DroneTransport Næstved — privat evalueringsmateriale (UNDERVISER ONLY)

## Indhold
- `docker-compose.yml`, `pg_hba.conf`, `scripts/init.sql` — den bevidst usikre case (syntetiske data)
- `opgavebeskrivelse.md` — studenterversion af opgaven (60 min)
- `afleveringsskabelon.md` — afleveringsskabelon
- `underviser/facit.md` — sikkerhedsproblemer, risici, løsninger
- `underviser/rubrik.md` — bedømmelsesrubrik (5 kriterier × 3 niveauer)
- `underviser/verify.sh` — verifikation af før/efter-tilstand
- `dist/student-pakke.zip` — KUN til udlevering til studerende (ingen facit)
- `dist/laerer-pakke.zip` — komplet pakke til underviseren

## Start / reset / udlevering
```bash
# start casen (lokal lab):
docker compose up -d
./underviser/verify.sh          # viser den usikre tilstand

# reset mellem studerende:
docker compose down -v          # sletter volumen + data (frisk case)

# udlevering: kun student-pakke.zip — aldrig denne mappe
```

## Regenerer pakker
```bash
cd private-evaluering
python3 ../scripts/make-packs.py   # eller manuelt med zip, se nedenfor
```
