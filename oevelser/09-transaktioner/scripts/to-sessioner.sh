#!/bin/bash
# Åbner to interaktive psql-sessioner til øvelse 09 (kør i to terminaler eller baggrunden)
echo "Åbner session 1..."
docker compose exec -it postgres psql -U studie -d studiebase -v session_id=session1 &

sleep 2

echo "Åbner session 2..."
docker compose exec -it postgres psql -U studie -d studiebase -v session_id=session2
