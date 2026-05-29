# Author: Víctor Barceló

# Teacher Guide: Group Work — Data Warehouse Architecture Design

**For teacher use only. Do not distribute to students.**

---

## Assignment Summary

Students design a complete data warehouse pipeline for an assigned business domain. Each group must design their own source databases — PostgreSQL relational model (ER diagram), MongoDB document schema, and Redis data model — and then build the ETL pipeline and dimensional model in BigQuery. 15 distinct scenarios prevent groups from sharing solutions while keeping assessment criteria equivalent.

---

## Group Assignment

There are 15 scenarios. Assign one per group. If groups exceed 15, scenarios can repeat but only for groups unlikely to collaborate.

| Scenario | Domain | MongoDB Enrichment Source | Redis Structure |
|----------|--------|--------------------------|----------------|
| 01 | GameVerse — Video Game Store | RAWG API (critic/community metadata) | Sorted set: daily trending game scores |
| 02 | StreamSound — Music Streaming | MusicBrainz / mock audio features | Hash per user: real-time session state |
| 03 | BookNest — Online Bookstore | Open Library API (bibliographic data) | Sorted set: bestsellers by genre |
| 04 | FlyEasy — Airline Booking | Open-Meteo API (weather at departure) | Hash per flight: operational state |
| 05 | EduTrack — Online Learning | Mock Coursera-style course reviews | Sorted set: active learners per course |
| 06 | HealthPulse — Clinic Management | WHO ICD API (diagnosis terminology) | Sorted set: waiting queue per clinic |
| 07 | RetailHub — E-commerce Marketplace | Open Food Facts / mock product specs | Hash per product: inventory state |
| 08 | HotelBlue — Hotel Chain | Mock TripAdvisor-style sentiment | Hash per property: occupancy state |
| 09 | FinTrack — Personal Finance App | Mock MCC merchant classification | Hash per user: budget alert state |
| 10 | CinemaPlus — Movie Theater Chain | OMDb / TMDB API (film metadata) | Sorted set: trending films per cinema |
| 11 | FoodDash — Food Delivery Platform | Mock health inspection scores | Sorted set: restaurants by delivery time |
| 12 | SportStats — Sports League | API-Football / mock player profiles | Sorted set: live standings + top scorers |
| 13 | PropertyNow — Real Estate | Mock neighbourhood quality data | Sorted set: most-viewed listings |
| 14 | CarShare — Vehicle Sharing | Mock EV manufacturer specifications | Hash per station: real-time availability |
| 15 | EventPulse — Event Ticketing | Mock Songkick-style artist profiles | Sorted set: ticket availability per event |

**Difficulty guidance:**
- Most constrained (good for weaker groups): 03 (BookNest), 10 (CinemaPlus), 08 (HotelBlue) — clear domain, familiar entities.
- Intermediate: 01 (GameVerse — reference schema available), 07 (RetailHub), 04 (FlyEasy).
- Most open-ended (good for stronger groups): 09 (FinTrack — financial data adds SCD and privacy complexity), 11 (FoodDash — dual Redis structures), 15 (EventPulse — dynamic pricing SCD challenge).

---

## Sizing and Effort Estimate

- Subject: 4 months, 8 hours/week ≈ 128 hours total
- This work is 10% → approximately 12-13 hours per student, 38-40 hours per group
- 4-week timeline is intentional: 1 week design, 2 weeks content, 1 week polish
- Implementation bonus is achievable in ~4-6 additional hours for a motivated group

---

## Key Pedagogical Objectives

By completing this work students will:

1. Design a normalised relational schema from a business description and produce a correct ER diagram.
2. Apply dimensional modeling (Kimball methodology) to a realistic dataset.
3. Understand why different storage technologies (relational, document, in-memory) serve different data shapes and choose structures accordingly.
4. Design ETL pipelines with failure handling, quality checks, and idempotency.
5. Apply access control using the principle of least privilege across a multi-component system.
6. Reason about data freshness SLAs and pipeline reliability.
7. Develop understanding of a major cloud analytical platform (GCP BigQuery).

---

## Grading Notes

### Common mistakes to watch for

**Source systems section (new — schema design):**
- PostgreSQL schema not in 3NF: transitive dependencies left in (e.g., storing both `category_id` and `category_name` in the same table as non-key columns).
- Missing foreign keys or foreign keys defined in the wrong direction.
- ER diagram not matching the actual SQL schema (drawn separately without checking consistency).
- MongoDB example document missing a realistic nested/array field — if everything is flat, the student has not engaged with the document model.
- Redis key naming convention not defined, or students only describe one key without explaining the full pattern.
- TTL policy not addressed for Redis keys that are updated periodically (e.g., hourly trending scores should expire if the update job fails).

**Dimensional model section:**
- Grain not defined or defined incorrectly (a fact table with multiple grains is a very common error).
- Missing surrogate keys — students often want to use the natural key (e.g., `game_id`) directly as the primary key of the dimension, which breaks SCD Type 2.
- Confusing additive vs. non-additive measures. For example, a `rating` (1-10) from `reviews` is semi-additive; it cannot be summed across games but can be averaged.
- SCD Type 2 without a `valid_from` / `valid_to` / `is_current` pattern.

**ETL section:**
- "We clean the data" without specifying what cleaning means, what is checked, and what the failure action is.
- Ignoring entity resolution entirely. This is the hardest part: matching `game_id` from PostgreSQL to a `name` field in MongoDB. Expect most groups to propose exact-string matching; push them to acknowledge this is brittle and suggest fuzzy matching or a lookup table as an improvement.
- No mention of idempotency or exactly-once semantics.

**Access control section:**
- Granting `roles/bigquery.admin` or `roles/owner` to the ETL service account (over-privileged).
- Storing passwords in the code or in plaintext environment variables without mentioning Secret Manager.

**Reliability section:**
- Stating "BigQuery is always available" without explaining the impact of a MongoDB or PostgreSQL outage.
- No mention of dead letter queues or error tables.

### Differentiation between grade levels

| Grade range | Typical characteristics |
|-------------|------------------------|
| 9-10 | Correct grain definition, SCD Type 2 with surrogate keys, entity resolution strategy explained, idempotency addressed, access control is specific and role-based, monitoring metrics are concrete |
| 7-8 | Most sections complete, minor errors in grain or SCD, access control mostly correct but missing one layer, some vagueness in ETL failure handling |
| 5-6 | Architecture diagram is correct but sections lack detail, SCD attempted but incorrect, access control mentions roles but not least privilege, missing data quality checks |
| Below 5 | Missing major sections, fact table grain not defined, no access control design, diagram missing key components |

---

## Presentation Assessment Tips

- Each member must speak. If one member speaks for the entire 10 minutes and cannot answer questions, reduce that member's grade.
- Good questions to ask during Q&A:
  - "Why did you normalise that relationship into a separate table rather than denormalising it?"
  - "Why is that field nested inside the MongoDB document instead of being a separate collection?"
  - "How would you query your Redis key if you needed all trending items across all categories at once?"
  - "Why did you choose SCD Type 2 instead of Type 1 for that dimension?"
  - "Your ETL runs daily. What happens if BigQuery is down for 36 hours — what does your backfill look like?"
  - "How would you know if your pipeline silently dropped 10% of records?"
  - "If the MongoDB enrichment source changes its schema, which part of your pipeline breaks first?"
  - "Why is your fact table grain at the transaction level rather than the daily level?"
  - "What is the cost implication of not partitioning your fact table in BigQuery?"

- Groups tend to prepare much better for technical questions about their own variation than for general BigQuery/architecture questions. The GCP overview section specifically targets this gap.

---

## Scenario-Specific Notes

### Scenario 01 — GameVerse

A reference SQL schema with scripts exists in the repository at `databases/postgresql/game-database/`. Students may use and extend it. Remind them they must still document whatever schema they actually use — they cannot just reference the file without including an ER diagram in their report.

### Scenario 02 — StreamSound

The listening event table is the most interesting design challenge: a single play event can fire multiple times per second in production. Students should capture enough fields to differentiate a complete play from a skip (e.g., `duration_played_seconds`, `total_track_seconds`, `was_skipped`). Watch for groups who conflate the track (a recording) with the song (a composition) — both can be modelled as separate entities.

### Scenario 03 — BookNest

The Open Library API is genuinely usable and free. Works API: `https://openlibrary.org/works/{OLID}.json`. This is a good group for students who need a familiar domain. The SCD challenge (price changes, author-publisher relationship) is clear and well-scoped.

### Scenario 04 — FlyEasy

Airline schemas have a well-known pitfall: confusing `route` (a city-pair definition) with `flight` (a scheduled instance of a route on a specific date). Students must model both. The booking model also needs to distinguish the booking (contract) from the segment (one leg of a multi-leg journey). Push them to think about connecting flights.

### Scenario 05 — EduTrack

The quiz attempt table is frequently over-simplified. Encourage students to think about multiple attempts per lesson, partial scores per question, and time taken. The SCD challenge (course version changes) is a good introduction to the difference between updating a dimension (Type 1) and adding a new row (Type 2).

### Scenario 06 — HealthPulse

Remind students that patient data is sensitive. Their access control section should explicitly mention data privacy considerations (even if this is a course project). The ICD-10 enrichment is genuinely available — a simple CSV or the WHO API both work. The appointment-to-diagnosis link is the most important relationship to model correctly in PostgreSQL.

### Scenario 07 — RetailHub

The order / order item split is the foundational retail schema pattern. Students who conflate them into a single table have not grasped normalisation. The promotion model (promotions applied to orders) is often left out — check for it. The Redis inventory model (stock count vs. reserved count for items in active carts) is a good test of whether students understand the difference between a persistent store and a transient cache.

### Scenario 08 — HotelBlue

A reservation can span multiple nights and include multiple rooms. The bridge between reservation and room (the `reservation_rooms` table) is commonly missed. The RevPAR (Revenue Per Available Room) metric requires students to know the number of available rooms per property per night, which implies a calendar-aware dimension design.

### Scenario 09 — FinTrack

This is the highest privacy-sensitivity scenario. Students should discuss pseudonymisation of user identifiers in the warehouse and restrict analyst access to aggregated views rather than raw transactions. The SCD challenge (category reassignment) is subtle: when a user recategorises past transactions, does the warehouse reflect the original categorisation or the new one? Both are valid answers if justified.

### Scenario 10 — CinemaPlus

The OMDb API is free with a key (registration at http://www.omdbapi.com). TMDB is also free with registration. Both return JSON responses easily ingested into MongoDB. The seat dimension is interesting: individual seat identifiers (row, seat number) can be modelled as a dimension, which illustrates fine-grained grain choices.

### Scenario 11 — FoodDash

This scenario intentionally has two Redis structures (one for restaurant status, one for driver status). Students must design both. The dual Redis model is more work but reinforces the pattern of using Redis for different real-time entities. The entity resolution challenge (linking a restaurant in MongoDB health inspection data to a restaurant record in PostgreSQL by name + address) is realistic and worth discussing in Q&A.

### Scenario 12 — SportStats

The player contract / transfer model is the most complex relational design in this batch. A player has a series of contracts with clubs, each with start/end dates. This is directly analogous to SCD Type 2 in the warehouse layer, so students who design this correctly in PostgreSQL will have an easier time with the warehouse dimension. Match event granularity (one row per event type per match) is fine for a transactional fact table.

### Scenario 13 — PropertyNow

Listing price history is the SCD at the source level: the operational system itself tracks price changes. This makes it a good discussion about when SCD handling belongs in the operational database vs. the warehouse. The neighbourhood enrichment document is deliberately qualitative (walkability scores, tags) — this is a good test of whether students understand the MongoDB document model vs. a lookup table in PostgreSQL.

### Scenario 14 — CarShare

The trip table must capture both start and end station/zone to support origin-destination analysis. Students who only record the start location have an incomplete model. The vehicle condition tier changes are a good SCD Type 2 candidate: a vehicle that degrades from Good to Fair mid-year should be associated with the correct tier for each trip.

### Scenario 15 — EventPulse

Dynamic ticket pricing (SCD challenge) is the most commercially realistic SCD scenario. The fact table must capture the price paid, not the current price on the ticket dimension. Students often want to store the current price in the dimension and derive the historical price from it — this is incorrect. The resale market (secondary market) adds a second business process that maps naturally to a second fact table, which reinforces the galaxy schema pattern.

---

## Implementation Bonus Guidance

If a group implements any part:

- Accept Python scripts that connect to a local PostgreSQL instance and insert to BigQuery via the `google-cloud-bigquery` Python client.
- Accept dbt models (even plain SQL files with `{{ ref() }}` macros) as a valid transformation layer implementation.
- A Looker Studio dashboard screenshot with real data counts as implementation.
- MongoDB schema implemented as a `mongoimport`-ready JSON file with sample documents counts as implementation.
- Do NOT require a live environment — screenshots and code are sufficient.
- The bonus is generous: even a single working Python script that inserts rows into a BigQuery staging table counts.

The virtual environment in `databases/azure_postgresql/scripts/.venv` has `psycopg2` available. The `google-cloud-bigquery` package can be added with `pip install google-cloud-bigquery`.

---

## Suggested Scenario Assignments by Class Composition

If you do not have information about individual skill levels, assign scenarios in numerical order to groups as they form.

If you want to challenge stronger groups: assign 09 (FinTrack), 11 (FoodDash), 12 (SportStats), or 15 (EventPulse).

If you want to support weaker groups: assign 03 (BookNest), 08 (HotelBlue), or 10 (CinemaPlus).

Scenario 01 (GameVerse) is the only one with a reference schema in the repository. Assign it to a group of average ability — it provides a safety net without being a trivial scenario.
