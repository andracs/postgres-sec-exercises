#!/bin/bash
# Script til at åbne to interaktive psql-sessioner for øvelse 10 (deadlock)

echo "Åbner session 1..."
docker compose exec -it postgres psql -U studie -d studiebase -v session_id=session1 &

sleep 2

echo "Åbner session 2..."
docker compose exec -it postgres psql -U studie -d studiebase -v session_id=session2
