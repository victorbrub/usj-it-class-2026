# Author: Víctor Barceló
# The Whitechapel Poisoning - A Graph Database Murder Investigation

**Duration**: 90 minutes  
**Tool**: Neo4j Desktop  
**Setup file**: `holmes_mystery_setup.cypher`  
**Difficulty**: Introductory - Intermediate  

---

## The Case

**London, November 17th, 1895.**

At half past ten in the evening, Miss Adelaide Hartwell arrives at her father's house at 23 Montague Street, Whitechapel, for her customary evening visit. She finds Edmund Hartwell — respected clockmaker, patent holder, and senior partner of Fitch & Hartwell Clockworks — slumped dead in his study armchair.

Dr. Watson's post-mortem at St. Bartholomew's Hospital confirms arsenic poisoning. The victim's prized mechanical pocket watch, containing the drawings of a patented escapement mechanism valued at several thousand pounds, is missing from his desk.

Inspector Lestrade, at a loss, summons **Sherlock Holmes**. Holmes hands the case to you.

The victim had enemies. He was dissolving a long-standing business partnership, was owed money by a socialite widow, had a young apprentice with a violent past, and had received threatening letters from a rival inventor in Greenwich. The household housekeeper reports seeing a black hansom cab outside the house at 21:30 that she had never seen before.

**Your mission**: Use graph database queries to trace the connections between persons, communications, carriages, financial records, and physical evidence — and deduce the murderer.

---

## Graph Model

### Node Labels

| Label | Represents |
|---|---|
| `Person` | Everyone involved: victim, investigators, suspects, witnesses — 19 persons total |
| `Location` | Places across London relevant to the case — 15 locations total |
| `Carriage` | Horse-drawn vehicles linked to persons and sightings |
| `Communication` | Telegrams, letters, and notes sent around the time of the murder |
| `FinancialTransaction` | Payments and transfers made in November 1895 |
| `Evidence` | Physical evidence found at the crime scene |
| `CriminalRecord` | Prior offenses on record at Scotland Yard |

#### Persons at a Glance

| Name | Role | Status |
|---|---|---|
| Edmund Hartwell | Victim / Clockmaker | Victim |
| Sherlock Holmes | Consulting Detective | Investigator |
| Dr. John Watson | Police Surgeon | Investigator |
| Inspector Lestrade | Lead Investigator | Investigator |
| Constable Briggs | Crime Scene Officer | Investigator |
| Reginald Fitch | Business Partner | Suspect |
| Lady Vivienne Ashworth | Socialite / Widow | Suspect |
| Thomas Morrow | Clockmaker's Apprentice | Suspect |
| Cornelius Vane | Apothecary | Suspect |
| Jack Finch | Street Dealer | Suspect |
| Professor Aldous Cray | Rival Inventor | Suspect |
| Nathaniel Greaves | Solicitor | Suspect |
| Harriet Bowden | Lodging House Keeper | Suspect |
| Edwin Locket | Insurance Broker | Suspect |
| Miriam Vane | Apothecary's Assistant | Suspect |
| Sebastian Morrow | Dockworker / Petty Criminal | Suspect |
| Adelaide Hartwell | Victim's Daughter | Witness |
| Mrs. Agnes Doyle | Housekeeper | Witness |
| Father Donahue | Parish Priest | Witness |

### Relationship Types

| Relationship | Meaning |
|---|---|
| `(:Person)-[:KNOWS]->(:Person)` | Two people are acquainted |
| `(:Person)-[:WORKS_AT]->(:Location)` | Person is employed at a location |
| `(:Person)-[:VISITED {date, time, purpose}]->(:Location)` | Person visited a location |
| `(:Person)-[:OWNS]->(:Carriage)` | Person owns or hired a carriage |
| `(:Carriage)-[:SPOTTED_AT {date, time}]->(:Location)` | Carriage was seen at a location |
| `(:Person)-[:SENT_MESSAGE]->(:Communication)` | Person sent a letter or telegram |
| `(:Communication)-[:ADDRESSED_TO]->(:Person)` | Communication was addressed to a person |
| `(:Person)-[:SENT_TRANSACTION]->(:FinancialTransaction)` | Person made a payment or transfer |
| `(:FinancialTransaction)-[:RECEIVED_BY]->(:Person)` | Person received the money |
| `(:Evidence)-[:FOUND_AT]->(:Location)` | Evidence was found at a location |
| `(:Evidence)-[:LINKED_TO {confidence, basis}]->(:Person)` | Evidence is forensically linked to a person |
| `(:Person)-[:HAS_RECORD]->(:CriminalRecord)` | Person has a prior criminal record |
| `(:Person)-[:EMPLOYED_BY {position, since}]->(:Person)` | Person works directly for another person |
| `(:Person)-[:RELATED_TO {relation}]->(:Person)` | Family relationship between two persons |
| `(:Person)-[:REPRESENTED_BY {matter, since}]->(:Person)` | Person has legal counsel from a solicitor |
| `(:Person)-[:OWES_DEBT_TO {amount, context}]->(:Person)` | Person carries an outstanding financial debt |
| `(:Person)-[:INSURED_BY {policy, sum_insured}]->(:Person)` | Person holds an insurance policy through a broker |
| `(:Person)-[:PROVIDES_ALIBI_FOR {date, statement}]->(:Person)` | Person corroborates the whereabouts of another |

---

## Part 0 - Setup (10 minutes)

### Step 0.1 - Open Neo4j Desktop

1. Open Neo4j Desktop.
2. Start your local database instance from the Projects panel.
3. Click **Open** to open the built-in query editor.

### Step 0.2 - Load the Investigation Database

Open the file `holmes_mystery_setup.cypher` and paste its entire contents into the Neo4j Desktop query editor. Click **Run**.

Alternatively, paste and run each numbered section separately.

### Step 0.3 - Verify the Data

```cypher
MATCH (n)
RETURN labels(n) AS label, count(n) AS count
ORDER BY count DESC;
```

Expected output:

| label | count |
|---|---|
| Person | 19 |
| Location | 15 |
| Communication | 8 |
| FinancialTransaction | 7 |
| Evidence | 6 |
| Carriage | 5 |
| CriminalRecord | 4 |

**Total nodes: 64**

```cypher
MATCH ()-[r]->()
RETURN type(r) AS relationship_type, count(r) AS count
ORDER BY count DESC;
```

> **Checkpoint**: Confirm 56 nodes and a full set of relationships before proceeding. If any count is unexpected, re-run the setup file from the beginning.

---

## Part 1 - Acquainting Yourself with Victorian London (15 minutes)

Before investigating, explore the database to understand what you are working with.

### Exercise 1.1 - View the Full Graph

```cypher
MATCH (n)
RETURN n
LIMIT 80;
```

Click on nodes in the Neo4j Desktop visualization to read their properties. Notice how the graph forms clusters around locations and people.

### Exercise 1.2 - List All Persons and Their Roles

Write a query that returns each person's name, role, and address, ordered alphabetically by name.

```cypher
// Your query here — MATCH all Person nodes and RETURN their properties
```

Which persons could you classify as suspects? Which are clearly investigators or witnesses?

### Exercise 1.3 - List All Locations by District

Return all locations in the graph — name, type, and district — ordered by district.

```cypher
// Your query here
```

> **Discussion**: Which district has the most relevant locations for this case?

### Exercise 1.4 - Communications Overview

Return all communications in the investigation: their id, type, date, time, and content.

```cypher
MATCH (c:Communication)
RETURN c.id, c.type, c.date, c.time, c.content
ORDER BY c.date, c.time;
```

Read through the content. Note any messages that are threatening, suspicious, or forged.

### Exercise 1.5 - Evidence Summary

Return all evidence items with their linked person and the stated basis for the link.

```cypher
MATCH (e:Evidence)-[l:LINKED_TO]->(p:Person)
RETURN e.id, e.type, e.description, l.confidence AS confidence, p.name AS linked_to
ORDER BY l.confidence DESC;
```

> **Discussion**: Does the evidence consistently point to one person, or is it scattered across multiple suspects?

---

## Part 2 - Establishing the Scene (20 minutes)

### Exercise 2.1 - Who Was Present at the Victim's Address?

Find all persons who visited 23 Montague Street — the crime scene — with the date, time, and stated purpose of each visit.

```cypher
// Hint: match a Person to a Location by a specific property value, and access relationship properties
MATCH (a:NodeType)-[r:RELATIONSHIP]->(b:NodeType {property: "value"})
RETURN a.name, a.role, r.date, r.time, r.purpose
ORDER BY r.date, r.time;
```

> **Question**: Who visited the house on the night of the murder (1895-11-17)?

### Exercise 2.2 - Alibi Check

Find all persons who have a visit recorded at a location other than 23 Montague Street on the night of November 17th.

```cypher
// Hint: use WHERE with AND to filter by a relationship property and exclude a specific node value with <>
MATCH (a:NodeType)-[r:RELATIONSHIP]->(b:NodeType)
WHERE r.date = "YYYY-MM-DD"
  AND b.name <> "Excluded Location"
RETURN a.name, b.name, r.time, r.purpose
ORDER BY r.time;
```

> **Investigation note**: An alibi at a different location at the same time does not automatically clear a suspect — consider whether the timings overlap with the estimated time of death (between 21:00 and 22:30).

### Exercise 2.3 - The Apothecary Connection

The post-mortem confirms arsenic poisoning. Find all persons who have a known relationship with the apothecary Cornelius Vane, and what context connects them.

```cypher
// Hint: match to a specific person by name and access properties on the relationship
MATCH (a:NodeType)-[r:RELATIONSHIP]->(b:NodeType {name: "Specific Person"})
RETURN a.name, a.role, r.since, r.context;
```

### Exercise 2.4 - Who Has a Criminal Record?

Find all persons with prior offenses on record at Scotland Yard, including the nature and year of the offense.

```cypher
// Your query here — match Person nodes linked to CriminalRecord via HAS_RECORD
```

> **Question**: Which suspect has a record most relevant to this type of crime?

### Exercise 2.5 - Suspects with Motive (Known Connections to the Victim)

Find all persons who directly knew Edmund Hartwell, along with the context and year they became acquainted.

```cypher
// Hint: similar to 2.3 — match to a specific person and sort by a relationship property
MATCH (a:NodeType)-[r:RELATIONSHIP]->(b:NodeType {name: "Specific Person"})
RETURN a.name, a.role, r.since, r.context
ORDER BY r.since;
```

Who knew the victim longest? Who had a financial or legal dispute with him?

---

## Part 3 - Following the Communications (15 minutes)

### Exercise 3.1 - Map Every Communication

For each telegram and letter, find who sent it and who received it, along with the date and content.

```cypher
// Hint: chain two relationships through an intermediate node to connect sender → message → receiver
MATCH (a:NodeType)-[:RELATIONSHIP1]->(b:NodeType)-[:RELATIONSHIP2]->(c:NodeType)
RETURN a.name, b.type, b.date, b.content, c.name
ORDER BY b.date, b.time;
```

### Exercise 3.2 - Threatening Messages

Filter the communications to find only those that contain threatening or suspicious language. Use a case-insensitive `WHERE` filter on the content field.

```cypher
// Hint: use toLower() and CONTAINS to do case-insensitive text search, combine terms with OR
MATCH (a:NodeType)-[:RELATIONSHIP1]->(b:NodeType)-[:RELATIONSHIP2]->(c:NodeType)
WHERE toLower(b.text_property) CONTAINS "keyword1"
   OR toLower(b.text_property) CONTAINS "keyword2"
RETURN a.name, b.type, b.date, b.text_property;
```

> **Discussion**: How many threatening messages were sent by the same person? What does this pattern suggest?

### Exercise 3.3 - Identify the Forged Note

One communication in the database is categorized as a `Forged Note`. Find it and identify who sent it and who it was addressed to.

```cypher
// Hint: filter a node in the middle of a path by a property value using inline {property: "value"} syntax
MATCH (a:NodeType)-[:RELATIONSHIP1]->(b:NodeType {property: "value"})-[:RELATIONSHIP2]->(c:NodeType)
RETURN a.name, b.content, b.date, c.name;
```

> **Key question**: If this note is forged, what did it enable the sender to do? Read the content carefully.

### Exercise 3.4 - Communications Sent After the Murder

The murder occurred on the evening of November 17th. Find all communications dated November 18th or later.

```cypher
// Hint: use > on a date string to filter for events after a given date
MATCH (a:NodeType)-[:RELATIONSHIP1]->(b:NodeType)-[:RELATIONSHIP2]->(c:NodeType)
WHERE b.date > "YYYY-MM-DD"
RETURN a.name, c.name, b.type, b.date, b.content
ORDER BY b.date, b.time;
```

> **Question**: Who sent messages after the murder? What was the purpose, and does it suggest guilt, panic, or routine behavior?

---

## Part 4 - Following the Money (15 minutes)

### Exercise 4.1 - All Financial Transactions in Chronological Order

Return every financial transaction with the sender, receiver, amount, date, and concept.

```cypher
// Hint: chain two relationships through a transaction node (sender → transaction → receiver)
MATCH (a:NodeType)-[:RELATIONSHIP1]->(b:NodeType)-[:RELATIONSHIP2]->(c:NodeType)
RETURN a.name, c.name, b.amount, b.date, b.concept
ORDER BY b.date;
```

### Exercise 4.2 - Large Transactions After the Murder

Find all transactions dated November 18th or later, ordered by amount descending.

```cypher
// Hint: filter by date on the intermediate node and sort by amount
MATCH (a:NodeType)-[:RELATIONSHIP1]->(b:NodeType)-[:RELATIONSHIP2]->(c:NodeType)
WHERE b.date >= "YYYY-MM-DD"
RETURN a.name, c.name, b.amount, b.date, b.concept
ORDER BY b.amount DESC;
```

> **Question**: Who moved the most money after the murder? What is listed as the concept for those transfers?

### Exercise 4.3 - The Pharmaceutical Payment

Find the transaction with concept "Pharmaceutical supplies" and return who paid, who received, how much, and when.

```cypher
// Your query here — filter FinancialTransaction by concept
```

Cross-reference this result with the arsenic found in the teacup (EVD-003). What does the timing tell you?

### Exercise 4.4 - Insurance and Inheritance

Find all transactions where the concept contains the words "insurance" or "bequest" or "will" or "estate".

```cypher
// Hint: use toLower() and CONTAINS with OR to search a text property for multiple keywords
MATCH (a:NodeType)-[:RELATIONSHIP1]->(b:NodeType)-[:RELATIONSHIP2]->(c:NodeType)
WHERE toLower(b.text_property) CONTAINS "keyword1"
   OR toLower(b.text_property) CONTAINS "keyword2"
RETURN a.name, c.name, b.amount, b.date, b.text_property;
```

> **Discussion**: Who stood to profit financially from the death of Edmund Hartwell, and by how much?

---

## Part 5 - The Carriage Trail (10 minutes)

### Exercise 5.1 - Which Carriages Were Seen at the Crime Scene?

Find all carriages spotted at 23 Montague Street, and who owns each carriage.

```cypher
// Hint: chain three nodes — owner → vehicle → location — and filter the location by name
MATCH (a:NodeType)-[:RELATIONSHIP1]->(b:NodeType)-[r:RELATIONSHIP2]->(c:NodeType {name: "value"})
RETURN a.name, b.id, b.type, b.color, r.date, r.time
ORDER BY r.time;
```

### Exercise 5.2 - Full Carriage Movement Map

For every carriage, return all locations where it was spotted, with the date and time. This reconstructs movement across the city.

```cypher
// Hint: string concatenation uses + in Cypher; order by multiple columns separating them with commas
MATCH (a:NodeType)-[:RELATIONSHIP1]->(b:NodeType)-[r:RELATIONSHIP2]->(c:NodeType)
RETURN a.name, b.property1 + " " + b.property2 AS label, c.name, r.date, r.time
ORDER BY a.name, r.date, r.time;
```

### Exercise 5.3 - The Hired Black Hansom

The housekeeper Mrs. Doyle reported a black hansom cab outside the house at 21:30. Trace it:

```cypher
// Hint: use two separate MATCH clauses to first find the specific carriage, then all its sightings
MATCH (a:NodeType)-[:RELATIONSHIP1]->(b:NodeType {id: "specific-id"})
MATCH (b)-[r:RELATIONSHIP2]->(c:NodeType)
RETURN a.name, b.description, c.name, r.date, r.time
ORDER BY r.date, r.time;
```

Where did this carriage go after leaving the crime scene?

---

## Part 6 - Connecting the Dots (10 minutes)

### Exercise 6.1 - Social Network of Suspects

Visualize the `KNOWS` relationships among all persons who are not investigators.

```cypher
// Hint: exclude multiple role values using <> with AND; assign the pattern to a variable to return the visual graph
MATCH path = (a:NodeType)-[:RELATIONSHIP]-(b:NodeType)
WHERE a.property <> "value1"
  AND a.property <> "value2"
  AND b.property <> "value1"
  AND b.property <> "value2"
RETURN path;
```

Who is the most connected node in this social web?

### Exercise 6.2 - Count Evidence Against Each Suspect

Count how many pieces of evidence are linked to each person, ordered by count descending.

```cypher
// Hint: use count() to aggregate, and collect() to gather values into a list per group
MATCH (a:NodeType)-[:RELATIONSHIP]->(b:NodeType)
RETURN b.name, count(a) AS total, collect(a.property) AS list
ORDER BY total DESC;
```

### Exercise 6.3 - Full Incriminating Profile

Combine all investigative threads: evidence, crime scene visits, threatening communications sent, and financial movements after the murder.

```cypher
// Hint: use multiple OPTIONAL MATCH clauses — one per signal — then WITH to aggregate counts per person
// Filter with WHERE on the date or content inside each OPTIONAL MATCH
// Use count(DISTINCT x) to avoid duplicates; arithmetic in RETURN creates a total score
MATCH (a:NodeType)
OPTIONAL MATCH (b:NodeType)-[:RELATIONSHIP1]->(a)
OPTIONAL MATCH (a)-[r1:RELATIONSHIP2]->(c:NodeType {name: "value"})
  WHERE r1.date = "YYYY-MM-DD"
OPTIONAL MATCH (a)-[:RELATIONSHIP3]->(d:NodeType)
  WHERE d.date > "YYYY-MM-DD"
WITH a,
     count(DISTINCT b) AS signal1,
     count(DISTINCT r1) AS signal2,
     count(DISTINCT d) AS signal3
WHERE signal1 > 0 OR signal2 > 0 OR signal3 > 0
RETURN a.name, signal1, signal2, signal3,
       (signal1 + signal2 + signal3) AS total_score
ORDER BY total_score DESC
LIMIT 5;
```

> **Discussion**: Who appears at the top of this table with the highest total score?

---

## Part 7 - The Verdict (5 minutes)

### Exercise 7.1 - Holmes's Deduction Chain

In the spirit of Holmes, build the chain of inference using a multi-hop path query. Trace the full path from physical evidence at the crime scene, through the murderer, to their financial motive.

```cypher
// Hint: chain four or more nodes in a single MATCH to build a multi-hop path
// A second MATCH can add another branch from the same central node
// Use WHERE to filter the second branch by date
MATCH (a:NodeType)-[:REL1]->(b:NodeType)
      -[:REL2]->(c:NodeType {property: "value"})
      -[:REL3]->(d:NodeType)
MATCH (b)-[:REL4]->(e:NodeType)
WHERE e.date > "YYYY-MM-DD"
RETURN b.name, a.type, a.description, c.content, d.name, e.concept, e.amount
ORDER BY e.amount DESC
LIMIT 3;
```

### The Murderer

> **SPOILER - Only read after completing all exercises**

<details>
<summary>Click to reveal Holmes's conclusion</summary>

The murderer is **Reginald Fitch**, business partner of Edmund Hartwell.

Holmes's deduction, as Watson recorded it:

**Motive**: Hartwell had informed Fitch he intended to dissolve their seventeen-year partnership and transfer ownership of the escapement mechanism patent to his daughter Adelaide. Fitch stood to lose both his livelihood and his claim to the £8,000 life-partnership insurance policy — which he promptly claimed the morning after the murder.

**Method**: Three days before the murder, Fitch paid Cornelius Vane — his long-standing apothecary contact — £12 for "pharmaceutical supplies." Arsenic was found in Hartwell's teacup. Vane's ledger, obtained by Holmes, shows a sale of white arsenic powder on November 14th.

**Access**: Fitch could not walk in through the front door — Hartwell had warned Morrow not to admit him after their quarrel. So he wrote a forged note (COMM-004) in Hartwell's handwriting, instructing the apprentice Morrow to admit him at any hour. Holmes identified the forgery immediately: the pen pressure was inconsistent with Hartwell's known hand, and the note was written on Fitch's personal stationery.

**Carriage**: Fitch hired a black hansom cab from Chiswick Carriage Co. that evening (TXN-007). Mrs. Doyle reported it outside the house at 21:30. The same cab was spotted the following morning near the Dockside Warehouse in Limehouse.

**Stolen watch**: After killing Hartwell, Fitch took the pocket watch containing the patent drawings. He instructed Jack Finch — his underworld contact — to collect it at the Dockside Warehouse (COMM-007) and paid him £25 for the service (TXN-004). Holmes recovered the watch there.

**Flight money**: On the morning of November 18th, Fitch transferred £3,000 to a Belgian bank account (TXN-003), intending to flee. Holmes and Lestrade apprehended him at Paddington Station before the noon train.

**Red herrings**:
- Lady Ashworth had motive (unpaid debt) but a confirmed dining alibi until 22:00; her carriage left the scene at 18:30.
- Professor Cray had written a threatening letter about the patent but departed London on the 17:00 train to Oxford, confirmed by the Paddington stationmaster.
- Thomas Morrow had a prior assault conviction but was entirely deceived by the forged note and cooperated fully with Holmes.

</details>

---

## Reflection Questions

Answer these individually after completing the lab:

1. In Exercise 3.3 you identified a forged communication. How does a graph model make it easy to trace the chain from forger to deceived party to physical location access?

2. In Exercise 6.3 you combined evidence, location visits, communications, and financial data into a single scoring query. What would this query look like in SQL? How many JOIN operations would it require?

3. The `KNOWS` relationship has properties `since` and `context`. How did those properties help you distinguish strong suspects from peripheral characters?

4. The `confidence` property on `LINKED_TO` relationships allowed you to weight forensic evidence. What other properties could you add to relationship types to make the investigation richer?

5. Reginald Fitch has the most incriminating profile, yet some evidence only has `confidence: "medium"`. What does this teach us about the difference between a complete proof and a strong inference in graph data?

---

## Bonus Challenges

### Bonus A - Shortest Path Between Fitch and Arsenic

Find all shortest paths connecting Reginald Fitch to any `Evidence` node of type "Toxicology".

```cypher
// Hint: shortestPath() takes a variable-length relationship pattern [*] between two anchored nodes
MATCH path = shortestPath(
  (a:NodeType {name: "..."})-[*]-(b:NodeType {property: "value"})
)
RETURN path;
```

How many hops separate Fitch from the poison? What nodes appear along that path?

### Bonus B - Degree Centrality

Calculate how many total relationships each person has. This is a crude measure of how central each person is to the investigation.

```cypher
// Hint: use an anonymous node () and undirected relationship to count all neighbours regardless of direction
MATCH (a:NodeType)
OPTIONAL MATCH (a)-[r]-()
RETURN a.name, a.role, count(r) AS connections
ORDER BY connections DESC;
```

Is the most connected person the murderer, or is it someone else? What does that tell you about centrality versus guilt?

### Bonus C - Full Timeline Reconstruction

Reconstruct a single chronological timeline of all trackable events across carriages, visits, and communications, using `UNION ALL`.

```cypher
// Hint: UNION ALL merges results from multiple MATCH clauses — all sub-queries must return the same column names
// Use + to concatenate date and time strings into one sortable column
// A list comprehension [(n)-[:REL]->(m) | m.property][0] retrieves one value from a sub-pattern
MATCH (a)-[r1]->(b)
RETURN r1.date + " " + r1.time AS datetime, "Type A" AS event_type, a.name AS actor, b.name AS location

UNION ALL

MATCH (c)-[r2]->(d)
RETURN r2.date + " " + r2.time AS datetime, "Type B" AS event_type, c.name AS actor, d.name AS location

ORDER BY datetime;
```

### Bonus D - Could Jack Finch Have Acted Alone?

Determine whether Jack Finch is reachable from the crime scene evidence through the graph, and within how many hops.

```cypher
// Hint: [*1..4] is a variable-length relationship that traverses between 1 and 4 hops in any direction
MATCH path = (a:NodeType)-[*1..4]-(b:NodeType {name: "..."})
RETURN path, length(path) AS hops
ORDER BY hops
LIMIT 3;
```

Is there a path? What does it pass through? Does it implicate Jack Finch directly, or only as an accessory?

---

## Summary

In this lab you:

- Loaded a Victorian murder mystery with 64 nodes and 18 relationship types
- Explored persons, locations, carriages, and communications in a historical setting
- Used date and content filtering to identify threatening and forged messages
- Traced carriage movements across the city to place suspects at the scene
- Followed financial flows to establish motive and flight planning
- Combined multiple data types into a single scoring query to rank suspects
- Used `shortestPath` and `UNION ALL` for advanced graph traversal
- Identified the murderer through a chain of converging evidence: physical, documentary, financial, and testimonial
