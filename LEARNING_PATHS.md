# PostgreSQL Security & Administration - 5 Hour Learning Paths

This document suggests three focused paths through the 20 exercises, each designed for approximately 5 hours of study. Choose based on your experience level and interests.

---

## Path 1: Foundation Fundamentals (Beginner)
**Focus:** Core PostgreSQL concepts and query optimization  
**Total Time:** ~5 hours  
**Difficulty:** Let → Middel  
**Best for:** New to PostgreSQL administration

### Exercises to Complete:

1. **01 - Kanariefuglen** (30-45 min)
   - Introduces performance-tuning with pgbench
   - Understand baseline measurement and configuration impact
   
2. **02 - Statistik er ikke et fyord** (30 min)
   - Learn why ANALYZE matters
   - See how statistics affect query planning
   
3. **03 - At læse eksekveringsplan** (45 min)
   - Develop critical skill: reading EXPLAIN output
   - Understand seq scans, nested loops, hash joins
   
4. **04 - Indeksøkonomi** (45 min)
   - Learn the cost/benefit tradeoff of indexes
   - Balance read performance vs. write performance
   
5. **06 - pg_stat_activity som reality show** (45 min)
   - Monitor active connections
   - Find and troubleshoot slow queries

6. **08 - VACUUM dagbogen** (45 min)
   - Understand bloat and autovacuum
   - Essential maintenance knowledge

**Why this path?** These exercises build foundational knowledge: you learn how to measure performance, understand query planning, optimize with indexes, maintain the database, and monitor activity. Each step builds on previous understanding.

---

## Path 2: Concurrency & Data Integrity (Intermediate)
**Focus:** Transactions, locking, and concurrent access patterns  
**Total Time:** ~5 hours  
**Difficulty:** Middel  
**Best for:** Developers building multi-user applications

### Exercises to Complete:

1. **02 - Statistik er ikke et fyord** (30 min)
   - Quick foundation on query planning
   
2. **09 - Transaktionsteateret** (60 min)
   - Isolation levels: READ COMMITTED, REPEATABLE READ, SERIALIZABLE
   - Understand dirty reads, phantom reads, serialization anomalies
   
3. **10 - Dødlåsens koreografi** (45 min)
   - See deadlocks in action with two sessions
   - Learn detection and recovery patterns
   
4. **11 - Kødisciplin: lock_timeout som moral** (45 min)
   - Implement lock timeout strategies
   - Backoff patterns for resilience
   
5. **12 - Adgangskontrollens cirkulære beslutning** (45 min)
   - Roles, grants, and permission hierarchies
   - Access control design
   
6. **13 - Hukommelsesøkonomien under pres** (45 min)
   - work_mem tuning and memory pressure
   - Understand when queries spill to disk

**Why this path?** If you're building applications, this covers the critical concerns: isolation levels prevent data corruption, deadlock avoidance patterns prevent hangs, role-based access controls security, and memory tuning prevents cascade failures.

---

## Path 3: Operations & Advanced Features (Advanced)
**Focus:** Production readiness, extensions, and scaling  
**Total Time:** ~5 hours  
**Difficulty:** Middel → Svær  
**Best for:** DBAs and operations engineers

### Exercises to Complete:

1. **05 - Datamodellederens anger** (60 min)
   - Normalization vs. denormalization tradeoffs
   - Design decisions with long-term impact
   
2. **07 - Journalterminalen: JSON uden dom** (60 min)
   - jsonb data type and operations
   - When to use relational vs. semi-structured storage
   
3. **14 - Extensionsbiografen: købe eller bygge?** (60 min)
   - Popular extensions: pg_trgm, pgcrypto, PostGIS
   - Extend PostgreSQL safely
   
4. **15 - Forbindelsespoolens venteværelse** (60 min)
   - PgBouncer connection pooling
   - Handle high concurrency applications
   
5. **16 - At partitionere fortiden** (60 min)
   - Declarative partitioning
   - Scale large tables effectively

**Why this path?** This path covers decisions that enable production success: data modeling shapes application performance, extensions add capabilities, connection pooling handles load, and partitioning scales to large datasets.

---

## Quick Reference: Exercise Duration

| Approx 30-45 min | Approx 45-60 min | Approx 60-75 min |
|---|---|---|
| 01 (30-45 min) | 03 (45 min) | 05 (60 min) |
| 02 (30 min) | 04 (45 min) | 07 (60 min) |
| 06 (45 min) | 08 (45 min) | 09 (60 min) |
| 10 (45 min) | 11 (45 min) | 14 (60 min) |
| 12 (45 min) | 13 (45 min) | 15 (60 min) |
|  |  | 16 (60 min) |
|  |  | 17 (75 min) |

---

## Tips for Success

1. **Start with docker setup**: Each exercise needs Docker running. Start early to avoid delays.
   ```bash
   cd oevelser/[exercise-number]
   docker compose up -d
   docker compose exec postgres pg_isready -U studie
   ```

2. **Clean up between exercises**: Always run `docker compose down -v` to free resources.

3. **Refer to facit (solutions)**: The [facit/](/facit/) folder has solutions and expected outputs. Use these to verify your answers.

4. **Reproducible results**: All exercises use `SET seed = 42;` so results are deterministic.

5. **Two-session exercises** (09, 10, 11): Run two psql sessions in parallel to simulate concurrent activity.

---

## Progression After 5 Hours

Once you complete a path:

- **Foundation path graduates** → Move to Path 2 or 3 based on your role
- **Concurrency path graduates** → Try Path 1 (core tuning) or Path 3 (extensions)
- **Operations path graduates** → Tackle advanced exercises: 17 (Backup/PITR), 18 (Replication), 19 (Upgrade), 20 (Capstone)

The remaining exercises (17-20) are for production environments:
- **17** (75 min): WAL archiving and point-in-time recovery
- **18** (75 min): Primary + replica setup and failover
- **19** (75 min): Major version upgrades
- **20** (90 min): Integrated diagnosis capstone

---

## System Requirements

- Docker Desktop or Podman
- 8 GB RAM minimum (16 GB recommended for exercises 18+)
- ~30 seconds per exercise for container startup
- About 2 GB disk space total for all exercise images

Enjoy the learning!
