# Praktisk test (60 min): Sikkerhedsvurdering af DroneTransport Næstved

> **Case:** DroneTransport Næstved transporterer pakker med droner mellem adresser i Næstved.
> Virksomheden har en hjemmeside (kundebestillinger), en administrationsapp, en backend-service
> og en PostgreSQL-database med `customers`, `orders` og `staff`.
>
> **Du er sikkerhedskonsulent.** Databasen er lige blevet installeret, men sikkerheden er ikke
> gennemgået. Din opgave er at undersøge installationen, identificere de væsentligste
> sikkerhedsrisici og demonstrere, hvordan den bør sikres.
>
> ⚠️ Casen kører kun i dit lokale, isolerede Docker-lab. Brug aldrig offentlig
> netværkseksponering, rigtige kundeoplysninger eller produktions-credentials.
> Alle data i casen er syntetiske.

## Din opgave på 60 minutter

1. **Undersøg** databasen og identificer **mindst tre** relevante sikkerhedsproblemer.
2. **Beskriv**, hvilke modforanstaltninger der bør implementeres, og hvorfor.
3. **Demonstrér mindst to konkrete sikkerhedsforbedringer** med SQL, konfiguration eller kommandoer.
4. **Dokumentér**, at forbedringerne virker — med både positive og negative adgangstests.
5. **Beskriv kort** tilbageværende risici og din prioritering.

Ikke alle problemer skal rettes på én time — prioritér.

## Tidsramme

| Aktivitet | Tid |
|---|---|
| Undersøgelse af installationen | 15 min |
| Vurdering og prioritering | 10 min |
| Demonstration af sikkerhedstiltag | 25 min |
| Dokumentation og konklusion | 10 min |

## Sådan kører du casen

```bash
unzip student-pakke.zip && cd dronetransport-case
docker compose up -d
docker compose exec db psql -U postgres -d dronetransport
# login i casen er bevidst svagt — det er en del af opgaven
```

## Aflevering
Udfyld `afleveringsskabelon.md` (maks 1-2 sider ekskl. SQL/kommandoer) og aflever sammen med
SQL/kommandoer du kørte.

Du må bruge officiel dokumentation og AI-værktøjer, men du skal selv kunne demonstrere og
forklare de tiltag, du vælger. Der gives ikke ekstra point for mængden af kode.
