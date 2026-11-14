#!/bin/bash
# Script til at åbne to interaktive psql-sessioner for øvelse 09
# Dette script startes to separate psql-sessioner i to separate terminaler

# Åbn først session
echo "Åbner session 1..."
docker compose exec -it postgres psql -U studie -d studiebase -v session_id=session1 &

# Vent lidt for at sikre den første session er klar
sleep 2

# Åbn anden session
echo "Åbner session 2..."
docker compose exec -it postgres psql -U studie -d studiebase -v session_id=session2
