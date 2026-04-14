# Author: Víctor Barceló
# The Valencia VRS-26 Outbreak - A Graph Database Epidemiological Investigation

**Duration**: 90 minutes  
**Tool**: Neo4j Desktop  
**Difficulty**: Introductory  

---

## The Story

On **February 14, 2026**, the Hospital General de Valencia reported an unusual cluster of respiratory cases. Within two weeks, at least nine people across the city had tested positive for VRS-26, a novel respiratory pathogen.

The Valencia Regional Health Authority has opened an epidemiological investigation. Contact tracers have collected travel records, test results, symptom reports, and location visit data from all confirmed cases and their close contacts.

**Your mission**: Use graph database queries to trace the chain of transmission and determine:

1. **Who** is Patient Zero (the first person to introduce VRS-26 into Valencia)?
2. **Where** did the initial transmission event most likely occur?
3. **When** did Patient Zero arrive and become contagious?

You will need to reason across multiple node types and follow relationships to build your case. There are several plausible candidates — read the data carefully.

---

## Graph Model

### Node Labels

| Label | Represents |
|---|---|
| `Person` | Everyone involved: cases, contacts, investigators, healthcare workers |
| `Location` | Gyms, hospitals, markets, schools, conference halls, residences |
| `TravelRecord` | Flights, trains, buses used by persons before or during the outbreak |
| `ContactEvent` | A specific gathering where multiple people were present at the same time |
| `TestResult` | A diagnostic test (PCR or antigen) and its result |
| `SymptomReport` | When a person first reported symptoms and how severe they were |
| `MedicalHistory` | Pre-existing conditions for persons with relevant health background |

### Relationship Types

| Relationship | Meaning |
|---|---|
| `(:Person)-[:WORKS_AT]->(:Location)` | Person is employed at a location |
| `(:Person)-[:VISITED {date, purpose}]->(:Location)` | Person visited a location on a specific date |
| `(:Person)-[:BOARDED]->(:TravelRecord)` | Person took a specific travel segment |
| `(:TravelRecord)-[:ARRIVED_AT]->(:Location)` | Where a travel segment ended |
| `(:TravelRecord)-[:DEPARTED_FROM]->(:Location)` | Where a travel segment started |
| `(:Person)-[:WAS_PRESENT_AT {role}]->(:ContactEvent)` | Person attended a contact event |
| `(:Person)-[:TOOK_TEST]->(:TestResult)` | Person underwent a diagnostic test |
| `(:Person)-[:MAY_HAVE_INFECTED {confidence, route, date}]->(:Person)` | Likely transmission event between two people |
| `(:SymptomReport)-[:REPORTED_BY]->(:Person)` | Symptom report belongs to a person |
| `(:SymptomReport)-[:RECORDED_AT]->(:Location)` | Where/by whom symptoms were recorded |
| `(:Person)-[:KNOWS]->(:Person)` | Social connection between two people |
| `(:Person)-[:SELF_ISOLATED_AT]->(:Location)` | Where a person isolated after a positive result |

---

## Part 0 - Setup (10 minutes)

### Step 0.1 - Open Neo4j Desktop

1. Open Neo4j Desktop.
2. Start your local database instance from the Projects panel.
3. Click **Open** to open the built-in query editor.

### Step 0.2 - Load the Dataset

Open the file `epidemic_spread_setup.cypher` from the course materials and paste its full contents into the Neo4j Desktop query editor. Click **Run**.

> The script clears any existing data, creates constraints, and loads all nodes and relationships automatically.

### Step 0.3 - Verify the Data Loaded Correctly

```cypher
MATCH (n)
RETURN labels(n) AS label, count(n) AS count
ORDER BY count DESC;
```

Expected output:

| label | count |
|---|---|
| Person | 27 |
| Location | 20 |
| ContactEvent | 19 |
| TestResult | 19 |
| SymptomReport | 16 |
| TravelRecord | 11 |
| MedicalHistory | 11 |

**Total nodes: 123**

> **Checkpoint**: Confirm you have 123 nodes before continuing. If the count is different, re-run the setup script from the beginning.

---

## Part 1 - Exploring the Data (10 minutes)

Before investigating, get familiar with the database. These queries do not require you to write anything — run them and observe the results.

### Exercise 1.1 - Who Is Involved?

List all persons, their role, and their current health status.

```cypher
MATCH (p:Person)
RETURN p.name AS name, p.role AS role, p.status AS status
ORDER BY p.status, p.name;
```

> **Question**: How many people have a status of "recovered"? How many are "hospitalised"? How many appear "healthy"?

### Exercise 1.2 - What Locations Are in the Database?

```cypher
MATCH (l:Location)
RETURN l.name AS location, l.type AS type, l.district AS district
ORDER BY l.type, l.name;
```

> **Question**: What types of locations appear most often? Which districts have the most activity?

### Exercise 1.3 - Visualize the Full Graph

Run the following query in Neo4j Desktop to see the entire graph visually. This gives you a first impression of the network structure.

```cypher
MATCH (n)-[r]->(m)
RETURN n, r, m
LIMIT 150;
```

Look at the visualization. Do you notice any nodes that appear especially well-connected? Take note of them.

---

## Part 2 - Identifying All Cases (20 minutes)

### Exercise 2.1 - Who Tested Positive?

Find all persons who received a positive test result, sorted by test date.

```cypher
// Hint: follow a relationship from Person to TestResult and filter by a property
MATCH (a:NodeType)-[:RELATIONSHIP]->(b:NodeType)
WHERE b.property = "value"
RETURN a.name, b.property1, b.property2
ORDER BY b.date;
```

> **Note**: The `ct_value` property applies only to PCR tests. A lower ct_value means higher viral load (more virus detected). Values below 25 indicate high infectivity. A `null` means the test was not a PCR test.

> **Question**: Who tested positive first? Who has the lowest ct_value (highest viral load)?

### Exercise 2.2 - Who Reported Symptoms First?

Find all symptom reports and order them by the date symptoms first appeared (`onset_date`).

```cypher
// Hint: match from SymptomReport to Person, return properties from both nodes
MATCH (a:NodeType)-[:RELATIONSHIP]->(b:NodeType)
RETURN b.name, a.property1, a.property2
ORDER BY a.date
LIMIT n;
```

> **Question**: Who reported the earliest symptom onset? How many days before the hospital raised the alert (February 14)?

### Exercise 2.3 - Confirmed Cases and Their Tests

For each person with a positive result, also show when they first reported symptoms.

```cypher
// Hint: use OPTIONAL MATCH when a related node may not always exist
MATCH (a:NodeType)-[:RELATIONSHIP]->(b:NodeType {property: "value"})
OPTIONAL MATCH (c:NodeType)-[:OTHER_RELATIONSHIP]->(a)
RETURN a.name, b.date, c.date
ORDER BY c.date;
```

> **Question**: Is there a person who had symptoms significantly earlier than everyone else?

### Exercise 2.4 - Who Was Hospitalised or Isolated?

Find all persons who self-isolated or were hospitalised, and where.

```cypher
// Hint: match a specific relationship type and return properties from both ends
MATCH (a:NodeType)-[:RELATIONSHIP]->(b:NodeType)
RETURN a.name, a.status, b.name, b.type;
```

---

## Part 3 - Tracing the Origin (30 minutes)

### Exercise 3.1 - Who Traveled Internationally Before the Outbreak?

The outbreak was first detected on February 14. Look for people who completed an international flight before that date.

```cypher
// Hint: filter with multiple conditions using AND, and compare dates as strings
MATCH (a:NodeType)-[:RELATIONSHIP]->(b:NodeType)
WHERE b.property = "value"
  AND b.date < "YYYY-MM-DD"
RETURN a.name, b.origin, b.destination, b.date
ORDER BY b.date;
```

> **Question**: How many people traveled internationally? Where did they come from? Pay attention to those who arrived in Valencia specifically.

### Exercise 3.2 - Who Attended the Same Events?

A critical question in epidemiology is whether multiple cases shared the same location at the same time. Find all contact events and list who was present.

```cypher
// Hint: use collect() to aggregate multiple values into a list per event
MATCH (a:NodeType)-[:RELATIONSHIP]->(b:NodeType)
RETURN b.id, b.date, collect(a.name) AS participants
ORDER BY b.date;
```

> **Question**: Are there any events where multiple confirmed cases were present?

### Exercise 3.3 - Where Was Patient Zero Before the First Cases Appeared?

Look at the location visits of people who tested positive, during the first week of February. Use the date range February 5 to February 14.

```cypher
// Hint: chain two MATCH clauses to link Person → TestResult and Person → Location
// Filter the visit date with a range using >= and <=
MATCH (a:NodeType)-[:RELATIONSHIP1]->(b:NodeType {property: "value"})
MATCH (a)-[r:RELATIONSHIP2]->(c:NodeType)
WHERE r.date >= "YYYY-MM-DD" AND r.date <= "YYYY-MM-DD"
RETURN a.name, c.name, r.date
ORDER BY r.date;
```

> **Question**: Which confirmed case visited the most locations at the start of the outbreak window? Can you spot someone who arrived in Valencia and immediately visited a high-attendance location?

### Exercise 3.4 - The Transmission Chain

The `MAY_HAVE_INFECTED` relationship records suspected transmission events between people. Explore this network.

First, list all direct suspected transmissions:

```cypher
// Hint: assign a variable to a relationship to access its properties
MATCH (a:NodeType)-[r:RELATIONSHIP]->(b:NodeType)
RETURN a.name, b.name, r.property1, r.property2
ORDER BY r.date, r.confidence DESC;
```

> **Question**: Which person appears most often as `likely_source`? Are there any persons who appear as source but never as a case (i.e., they spread the virus without being infected by anyone in the dataset)?

### Exercise 3.5 - Follow the Full Chain

Try to trace multi-hop transmission paths — who infected whom, who then infected others.

```cypher
// Hint: use a variable-length relationship pattern to follow chains of any depth
// nodes(path) returns all nodes along a path; use a list comprehension to extract a property
MATCH path = (a:NodeType)-[:RELATIONSHIP*1..4]->(b:NodeType)
RETURN a.name,
       [n IN nodes(path) | n.name] AS chain,
       length(path) AS hops
ORDER BY hops DESC
LIMIT 10;
```

> **Question**: Which person is at the start of the longest chains? Is that the same person you identified in Exercise 3.4?

### Exercise 3.6 - Cross-Check: Did the Suspected Source Have High Viral Load?

Retrieve the test result for the person you believe is Patient Zero. Check: was the ct_value very low (high viral load), consistent with being the first case? Then do the same for another strong candidate you identified in earlier exercises and compare both results.

```cypher
// Hint: match a node by a specific property value to look up one person
MATCH (a:NodeType {name: "Name Here"})-[:RELATIONSHIP]->(b:NodeType)
RETURN a.name, b.date, b.result, b.ct_value;
```

> **Question**: You found two people who traveled from Geneva and attended the same conference. What differences in the data (dates, ct_value, transmission links) help you determine which one introduced the virus into Valencia?

---

## Part 4 - The Verdict (10 minutes)

### Exercise 4.1 - Build a Suspicion Score

Write a query that scores every person based on: whether they arrived in Valencia by international flight, whether they tested positive, how many people they directly infected, and when their symptoms first appeared. Use `OPTIONAL MATCH` for each signal and `WITH` to aggregate before filtering.

```cypher
// Hint: use multiple OPTIONAL MATCH clauses and WITH to calculate counts per person
// count(DISTINCT x) avoids duplicates; arithmetic in RETURN creates a computed column
MATCH (a:NodeType)
OPTIONAL MATCH (a)-[:RELATIONSHIP1]->(b:NodeType)
WHERE b.property = "value"
OPTIONAL MATCH (a)-[:RELATIONSHIP2]->(c:NodeType)
WITH a,
     count(DISTINCT b) AS signal1,
     count(DISTINCT c) AS signal2
WHERE signal2 > 0
RETURN a.name,
       signal1,
       signal2,
       (signal1 * 2 + signal2) AS score
ORDER BY score DESC;
```

> **Final question**: Based on all the evidence gathered, who is Patient Zero? Where did the initial infection most likely occur, and on what date did they first arrive in Valencia?

Write your three-part answer before reading the solution:

| | Your Answer |
|---|---|
| Patient Zero (name) | |
| Place of first infection (city or event) | |
| Date of arrival in Valencia | |

---

### The Answer

> **SPOILER - Only read after completing all exercises**

<details>
<summary>Click to reveal the answer</summary>

**Patient Zero: Ramin Tehrani**

**Place of infection: Geneva WHO Symposium (February 7-9, 2026)**  
The symposium was hosted at the WHO Geneva Conference Centre. Ramin Tehrani attended and was in close contact with **Prof. Wei Chen**, a virologist from Beijing who carried VRS-26. Prof. Wei Chen is the upstream source of the entire Valencia cluster.

**Date of arrival in Valencia: February 10, 2026** (flight VY6621, Geneva to Valencia)

**Why Ramin, not Ivanenko?**

Dr. Vasyl Ivanenko is the main red herring. He also attended the Geneva symposium and arrived in Valencia one day earlier than Ramin (February 9, flight TRV-010). However:

- Ivanenko's symptom onset was **February 11**, which coincides with the day of the Ateneo conference where he first met other cases. His symptoms appeared the same day he became a contact — meaning he could not have been contagious before that event.
- Ramin's symptom onset was **February 12**, but his PCR ct_value is **18** (very high viral load). A ct_value of 18 on February 13 means he was shedding virus heavily on February 11 and 12 — he was contagious before his own symptoms appeared.
- All confirmed high-confidence `MAY_HAVE_INFECTED` edges trace back to Ramin, not Ivanenko. Ivanenko's edges are all marked `confidence: "low"`.
- Ramin visited the Mercado Central on **February 13** and the Centro Deportivo Ruzafa on **February 11-12**, seeding the market and gym transmission chains independently.

**The transmission chain:**

Geneva: Prof. Wei Chen → Ramin Tehrani (symposium, ~Feb 8)

Valencia (first generation):
- Ramin → Sofía Blanco (yoga class, Feb 11)
- Ramin → Jordi Mas (Ateneo conference, Feb 11)
- Ramin → Khalid Amrani (Mercado Central, Feb 13)

Valencia (second generation):
- Sofía → Laia Ferrer (gym, Feb 12)
- Khalid → Omar Hassan (Mercado Central, Feb 14)
- Jordi → Cristina Llopis (office, Feb 12)

Valencia (third generation):
- Laia → Neus Boix (school pickup area, Feb 13) → hospitalised
- Omar → Pau Giner (restaurant, Feb 14)

</details>

---

## Reflection Questions

Answer these individually after completing the lab:

1. How did the `MAY_HAVE_INFECTED` relationship help you trace connections that would be very difficult to represent in a relational database?

2. What is the difference between a person being a *contact* of a case and being the *source* of a case? How did the graph help you distinguish these?

3. In Exercise 3.5, you traced paths up to 4 hops long. How many SQL JOIN operations would that equivalent query require in a relational schema?

4. The `confidence` property on `MAY_HAVE_INFECTED` relationships proved important. What other relationship properties from this dataset were most useful for making decisions?

5. Why is it not enough to find the person who traveled internationally? What additional signals were needed to confirm Patient Zero?

---

## Bonus Challenges

These are optional for students who finish early.

### Bonus A - Shortest Path Between Two Cases

Find the shortest connection in the graph between Neus Boix (the hospitalised case) and Prof. Wei Chen (the upstream Geneva source), using any relationship type.

```cypher
// Hint: shortestPath() finds the minimum-hop path between two nodes
// Use a CASE expression inside a list comprehension to handle mixed node types
MATCH path = shortestPath(
  (a:NodeType {name: "..."})-[*]-(b:NodeType {name: "..."})
)
RETURN [n IN nodes(path) |
  CASE WHEN n:Label1 THEN n.property
       WHEN n:Label2 THEN n.other_property
       ELSE toString(id(n))
  END] AS path_nodes,
  length(path) AS hops;
```

How many hops separate the most severe case in Valencia from the original source in Geneva?

### Bonus B - Degree Centrality

Calculate how many direct relationships each person has. This reveals who is the most "connected" node in the outbreak network.

```cypher
// Hint: use an anonymous node () to match any neighbour, regardless of label or direction
MATCH (a:NodeType)
OPTIONAL MATCH (a)-[r]-()
RETURN a.name, count(r) AS connections
ORDER BY connections DESC;
```

Does the most connected person match your Patient Zero conclusion, or is it someone else? What does high connectivity mean in an epidemiological context?

### Bonus C - Timeline of the Outbreak

Reconstruct the full chronological timeline by combining travel arrivals, contact events, test dates, and symptom onsets into a single ordered result.

```cypher
// Hint: UNION ALL combines results from multiple MATCH clauses into one result set
// All sub-queries must return the same column names
MATCH (a)-[r]->(b)
RETURN r.date AS date, "Event Type A" AS event_type, a.name AS description

UNION ALL

MATCH (c)-[s]->(d)
RETURN s.date AS date, "Event Type B" AS event_type, c.name AS description

ORDER BY date;
```

### Bonus D - Find All Persons Not Yet Linked to the Main Chain

Are there any persons in the database who have a positive test result but are not connected to the main transmission chain through `MAY_HAVE_INFECTED`?

```cypher
// Hint: use NOT with a pattern to exclude nodes that participate in a relationship
MATCH (a:NodeType)-[:RELATIONSHIP]->(b:NodeType {property: "value"})
WHERE NOT ()-[:OTHER_RELATIONSHIP]->(a)
  AND NOT (a)-[:OTHER_RELATIONSHIP]->()
RETURN a.name, b.date;
```

> What might explain isolated positive cases with no recorded transmission links? What would a real epidemiologist do next with these cases?
