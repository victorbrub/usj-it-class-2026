# Neo4j - Practical Exercises

Complete these exercises to practice Neo4j graph database concepts and Cypher query language. Work through them sequentially as they build upon each other.

---

## Exercise 1: Basic Node Creation

**Objective**: Practice creating nodes with labels and properties.

**Tasks**:

1. Create a Person node for yourself with:
   - name
   - age
   - email
   - city

2. Create 5 more Person nodes with different details

3. Create 3 Company nodes:
   - TechCorp (founded: 2010, industry: "Technology")
   - HealthInc (founded: 2015, industry: "Healthcare")
   - EduLearn (founded: 2018, industry: "Education")

4. Create 4 Skill nodes:
   - Python
   - JavaScript
   - GraphDatabases
   - MachineLearning

5. View all nodes you created

**Your Solution**:
```cypher
// Write your CREATE statements here
```

---

## Exercise 2: Creating Relationships

**Objective**: Practice creating relationships between nodes.

**Tasks**:

1. Create WORKS_AT relationships between people and companies:
   - Include properties: position, since (year)

2. Create KNOWS relationships between people:
   - Include property: since (year)

3. Create HAS_SKILL relationships between people and skills:
   - Include property: level ("beginner", "intermediate", "expert")

4. Create REQUIRES_SKILL relationships between companies and skills:
   - Include property: importance ("required", "preferred")

5. Visualize the entire graph

**Your Solution**:
```cypher
// Write your relationship creation statements here
```

---

## Exercise 3: Basic Pattern Matching

**Objective**: Practice MATCH queries.

**Tasks**:

1. Find all Person nodes

2. Find all companies in the Technology industry

3. Find the person with your email

4. Find all people who work at TechCorp

5. Find all skills that people have

6. Find all people who know each other (both directions)

7. Find what skills are required by HealthInc

**Your Solution**:
```cypher
// Write your MATCH queries here
```

---

## Exercise 4: Filtering with WHERE

**Objective**: Practice filtering results.

**Tasks**:

1. Find all people older than 25

2. Find all people who live in Boston

3. Find companies founded after 2012

4. Find people who have expert-level skills

5. Find people who started working after 2020

6. Find people whose name starts with "A"

7. Find people who have either Python or JavaScript skills

8. Find people who work in Technology industry (query through company)

**Your Solution**:
```cypher
// Write your WHERE clause queries here
```

---

## Exercise 5: Relationship Patterns

**Objective**: Practice more complex pattern matching.

**Tasks**:

1. Find all coworkers (people working at the same company):
```cypher
// Person A -[:WORKS_AT]-> Company <-[:WORKS_AT]- Person B
```

2. Find mutual connections (people who both know the same person)

3. Find people who have the same skills

4. Find people who work at companies that require skills they have

5. Find the chain: Person -> WORKS_AT -> Company -> REQUIRES_SKILL -> Skill

**Your Solution**:
```cypher
// Write your pattern matching queries here
```

---

## Exercise 6: Returning Results

**Objective**: Practice different return formats.

**Tasks**:

1. Return only names of all people

2. Return names and ages of people over 25

3. Return company names and the count of employees

4. Return people with their list of skills

5. Return person name with the name of their company

6. Return DISTINCT cities where people live

7. Use aliases to rename returned properties:
   - name AS fullName
   - age AS years

**Your Solution**:
```cypher
// Write your RETURN statements here
```

---

## Exercise 7: Aggregation

**Objective**: Practice aggregation functions.

**Tasks**:

1. Count total number of people

2. Count how many people work at each company

3. Count how many skills each person has

4. Find the average age of all people

5. Find the oldest and youngest person

6. Group people by city and count per city

7. Find which skill is most common (most people have it)

8. Count how many relationships each person has (total: WORKS_AT + KNOWS + HAS_SKILL)

**Your Solution**:
```cypher
// Write your aggregation queries here
```

---

## Exercise 8: Sorting and Limiting

**Objective**: Practice ORDER BY, LIMIT, and SKIP.

**Tasks**:

1. List all people sorted by age (youngest first)

2. List all people sorted by name alphabetically

3. Find the 3 oldest people

4. Find the 3 newest companies (by founded year)

5. List people sorted by number of skills (most skilled first)

6. Get the second page of results (items 6-10) for people sorted by name

7. Find top 5 people with most connections (KNOWS relationships)

**Your Solution**:
```cypher
// Write your sorting and limiting queries here
```

---

## Exercise 9: Updating Data

**Objective**: Practice SET and REMOVE.

**Tasks**:

1. Update your age (add 1 year)

2. Add a property "verified: true" to your Person node

3. Update a company's founded year

4. Add a new skill to a person

5. Update a relationship property (change skill level from beginner to intermediate)

6. Remove the "verified" property from your node

7. Add multiple properties at once to a person:
   - phone: "555-1234"
   - linkedin: "linkedin.com/in/yourname"

8. Update all Technology companies to add property: remote: true

**Your Solution**:
```cypher
// Write your UPDATE queries here
```

---

## Exercise 10: Deleting Data

**Objective**: Practice DELETE and DETACH DELETE.

**Tasks**:

1. Delete a specific KNOWS relationship

2. Delete a Skill node that has no relationships

3. Try to delete a Company node (will fail if it has relationships)

4. Use DETACH DELETE to remove a Company node and all its relationships

5. Delete all HAS_SKILL relationships where level is "beginner"

6. Create a test node and then delete it

**Your Solution**:
```cypher
// Write your DELETE queries here
// Be careful with deletions!
```

---

## Exercise 11: MERGE Operations

**Objective**: Practice MERGE (create if not exists).

**Tasks**:

1. Use MERGE to create or find a person by email

2. Use MERGE with ON CREATE to set initial properties:
```cypher
MERGE (p:Person {email: "new@example.com"})
ON CREATE SET p.name = "New User", p.createdAt = timestamp()
ON MATCH SET p.lastSeen = timestamp()
RETURN p;
```

3. Create a unique KNOWS relationship using MERGE

4. Add a skill to a person using MERGE (create skill if doesn't exist)

5. Create a social network: ensure KNOWS relationships exist between a group of people

**Your Solution**:
```cypher
// Write your MERGE queries here
```

---

## Exercise 12: Variable Length Paths

**Objective**: Practice variable length relationship patterns.

**Tasks**:

1. Find all people within 2 degrees of connection (friends and friends-of-friends):
```cypher
MATCH path = (person:Person {name: "YourName"})-[:KNOWS*1..2]-(connection)
RETURN connection;
```

2. Find friends of friends who are not direct friends (potential friend suggestions)

3. Find all people connected within 3 degrees

4. Calculate the length of the path between two specific people

5. Find the person who is most distant from you in the KNOWS network

**Your Solution**:
```cypher
// Write your variable length path queries here
```

---

## Exercise 13: Shortest Path

**Objective**: Practice shortest path algorithms.

**Tasks**:

1. Find the shortest path between two people through KNOWS relationships:
```cypher
MATCH (alice:Person {name: "Alice"}),
      (bob:Person {name: "Bob"}),
      path = shortestPath((alice)-[:KNOWS*]-(bob))
RETURN path;
```

2. Find the shortest path with a maximum length of 4

3. Calculate the degrees of separation between two people

4. Find all shortest paths (there might be multiple)

5. Find the shortest path considering multiple relationship types:
```cypher
shortestPath((a)-[:KNOWS|WORKS_AT|HAS_SKILL*]-(b))
```

**Your Solution**:
```cypher
// Write your shortest path queries here
```

---

## Exercise 14: Optional Patterns

**Objective**: Practice OPTIONAL MATCH (like LEFT JOIN).

**Tasks**:

1. List all people and their companies (include people who don't work anywhere):
```cypher
MATCH (p:Person)
OPTIONAL MATCH (p)-[:WORKS_AT]->(c:Company)
RETURN p.name, c.name;
```

2. List all people with their skill count (including people with no skills)

3. Show people with their friends list (including people with no friends)

4. List companies with employee count (including companies with no employees)

5. Show people with optional email property

**Your Solution**:
```cypher
// Write your OPTIONAL MATCH queries here
```

---

## Exercise 15: WITH Clause

**Objective**: Practice query chaining with WITH.

**Tasks**:

1. Find people with more than 2 skills:
```cypher
MATCH (p:Person)-[:HAS_SKILL]->(s:Skill)
WITH p, count(s) AS skillCount
WHERE skillCount > 2
RETURN p.name, skillCount;
```

2. Find the top 3 companies by employee count, then find all their required skills

3. Find people who know more than 3 others, then find their companies

4. Calculate average age by company, then find companies above the overall average

5. Chain multiple WITH clauses to build a complex query:
   - Get people with skills
   - Count their skills
   - Filter to those with 2+ skills
   - Get their companies
   - Sort by skill count

**Your Solution**:
```cypher
// Write your WITH clause queries here
```

---

## Exercise 16: CASE Expressions

**Objective**: Practice conditional logic in queries.

**Tasks**:

1. Categorize people by age group:
```cypher
MATCH (p:Person)
RETURN p.name,
  CASE
    WHEN p.age < 25 THEN "Young"
    WHEN p.age < 40 THEN "Middle"
    ELSE "Senior"
  END AS ageGroup;
```

2. Label skill levels as "Novice", "Competent", or "Expert"

3. Categorize companies by size (count employees):
   - Small: 1-5
   - Medium: 6-20
   - Large: 21+

4. Create a status label for each person:
   - "Employed" if they work somewhere
   - "Unemployed" otherwise

5. Assign a score to people based on multiple criteria:
   - +10 for each skill
   - +5 for each friend
   - +20 if employed

**Your Solution**:
```cypher
// Write your CASE expression queries here
```

---

## Exercise 17: Collections and List Operations

**Objective**: Practice working with lists.

**Tasks**:

1. Collect all skill names for each person into a list

2. Collect friend names for each person

3. Use list comprehension to filter:
```cypher
MATCH (p:Person)-[:HAS_SKILL]->(s:Skill)
WITH p, collect(s.name) AS skills
RETURN p.name, [skill IN skills WHERE skill STARTS WITH "M"] AS mSkills;
```

4. Use list functions:
   - head() - first element
   - tail() - all but first
   - last() - last element
   - size() - count

5. Check if a person has a specific skill using IN:
```cypher
MATCH (p:Person)-[:HAS_SKILL]->(s:Skill)
WITH p, collect(s.name) AS skills
WHERE "Python" IN skills
RETURN p.name;
```

**Your Solution**:
```cypher
// Write your list operations here
```

---

## Exercise 18: Indexes and Constraints

**Objective**: Practice creating indexes and constraints.

**Tasks**:

1. Create an index on Person.email

2. Create an index on Person.name

3. Create a composite index on Company (industry, founded)

4. Create a unique constraint on Person.email

5. Create a unique constraint on Company.name

6. Try to insert a duplicate email (should fail)

7. Show all indexes:
```cypher
SHOW INDEXES;
```

8. Show all constraints:
```cypher
SHOW CONSTRAINTS;
```

9. Drop an index

10. Use EXPLAIN to see if a query uses an index

**Your Solution**:
```cypher
// Write your index and constraint commands here
```

---

## Exercise 19: Complex Social Network Analysis

**Objective**: Build a realistic social network scenario.

**Tasks**:

1. **Friend Recommendations**: Find friends of friends who:
   - You don't already know
   - Share at least 2 skills with you
   - Work in the same industry

2. **Network Influence**: Calculate influence score:
   - Direct friends: 1 point each
   - Friends of friends: 0.5 points each
   - Sort by influence

3. **Skill Gap Analysis**: For each person, find:
   - Skills required by their company
   - Skills they don't have yet
   - (Should learn for career growth)

4. **Team Building**: Find groups of 3 people who:
   - All know each other (triangles)
   - Together have all skills required by a company

5. **Career Path**: Find shortest path from you to a specific company:
   - Through KNOWS relationships
   - Show intermediate connections who could refer you

**Your Solution**:
```cypher
// Write your complex analysis queries here
```

---

## Exercise 20: Movie Database Project

**Objective**: Build a complete movie recommendation system.

**Scenario**: Create a movie database with actors, directors, genres, and user ratings.

**Tasks**:

1. **Create the schema**:
```cypher
// Create movies
CREATE (m:Movie {
  title: "The Matrix",
  released: 1999,
  tagline: "Welcome to the Real World"
})

// Create people
CREATE (p:Person {name: "Keanu Reeves", born: 1964})

// Create relationships
CREATE (p)-[:ACTED_IN {roles: ["Neo"]}]->(m)
```

Add at least:
- 10 movies
- 15 people (actors and directors)
- 5 users who have rated movies

2. **Implement these queries**:
   - Find all movies released after 2000
   - Find all actors in a specific movie
   - Find all movies directed by a specific person
   - Find movies where a person both acted and directed

3. **Rating System**:
   - Users RATED movies with properties: rating (1-5), timestamp
   - Find movies with average rating > 4.0
   - Find users with similar taste (rated same movies similarly)

4. **Recommendations**:
   - Recommend movies based on:
     - Same actors
     - Same director
     - Similar ratings from similar users

5. **Co-Actor Network**:
   - Find actors who have worked together
   - Find the "Kevin Bacon Number" (degrees of separation)
   - Find the most connected actor

6. **Advanced Analytics**:
   - Find prolific directors (most movies)
   - Find actors who worked with most directors
   - Find genre preferences by user
   - Calculate actor collaboration strength

**Your Solution**:
```cypher
// Build your complete movie database system here
```

---

## Exercise 21: Path Traversal Challenge

**Objective**: Master path finding and traversal.

**Tasks**:

1. Find all paths between two people (any length)

2. Find paths with specific constraints:
   - Only through Technology companies
   - Maximum 4 hops
   - Must include at least one specific skill

3. Calculate network diameter (longest shortest path)

4. Find "bridges" in the network (people whose removal would disconnect the graph)

5. Implement breadth-first search manually using Cypher

**Your Solution**:
```cypher
// Write your path traversal queries here
```

---

## Exercise 22: Time-Based Queries

**Objective**: Practice working with dates and time.

**Tasks**:

Add timestamps to your data:

1. Add hire dates to WORKS_AT relationships

2. Add friendship dates to KNOWS relationships

3. Query people hired in 2023

4. Find people who became friends in the last year

5. Calculate tenure (how long people have worked at companies)

6. Find the oldest friendship

7. Track relationship evolution:
```cypher
// Add multiple relationships with different time periods
CREATE (p)-[:WORKED_AT {from: date("2018-01-01"), to: date("2020-12-31")}]->(c1)
CREATE (p)-[:WORKED_AT {from: date("2021-01-01"), to: null}]->(c2)
```

8. Find current employer (where to is null)

9. Calculate career duration across companies

**Your Solution**:
```cypher
// Write your time-based queries here
```

---

## Exercise 23: Graph Algorithms (Conceptual)

**Objective**: Understand graph algorithms available in Neo4j.

**Research and Explain**:

1. **Centrality Algorithms**:
   - Degree Centrality (count relationships)
   - Betweenness Centrality (bridge between groups)
   - PageRank (importance based on connections)

2. **Community Detection**:
   - Label Propagation
   - Louvain Modularity

3. **Path Finding**:
   - Shortest Path
   - All Shortest Paths
   - Dijkstra (weighted paths)

4. **Similarity**:
   - Jaccard Similarity
   - Cosine Similarity

**Task**: Implement degree centrality manually:
```cypher
MATCH (p:Person)
RETURN p.name, 
  size((p)-[:KNOWS]-()) AS degreeCount
ORDER BY degreeCount DESC;
```

Calculate other metrics you can implement with Cypher.

**Your Solution**:
```cypher
// Implement graph metrics with Cypher
```

---

## Exercise 24: Data Import Challenge

**Objective**: Practice bulk data import.

**Tasks**:

1. Create CSV files with data:
   - people.csv
   - companies.csv
   - relationships.csv

2. Use LOAD CSV to import:
```cypher
LOAD CSV WITH HEADERS FROM "file:///people.csv" AS row
CREATE (p:Person {
  name: row.name,
  age: toInteger(row.age),
  email: row.email
});
```

3. Import relationships:
```cypher
LOAD CSV WITH HEADERS FROM "file:///relationships.csv" AS row
MATCH (a:Person {email: row.from})
MATCH (b:Person {email: row.to})
CREATE (a)-[:KNOWS {since: toInteger(row.year)}]->(b);
```

4. Handle errors and duplicates during import

5. Use MERGE instead of CREATE for safe imports

**Your Solution**:
```cypher
// Write your data import queries here
// Include sample CSV structure as comments
```

---

## Exercise 25: Real-World Scenario - LinkedIn Clone

**Objective**: Build a professional network database.

**Requirements**:

1. **Entities**:
   - People (professionals)
   - Companies
   - Skills
   - Jobs (positions at companies)
   - Posts (content sharing)
   - Endorsements

2. **Relationships**:
   - KNOWS (connections)
   - WORKS_AT (current employment)
   - WORKED_AT (past employment)
   - HAS_SKILL
   - ENDORSED_FOR (Person endorsed Person for Skill)
   - POSTED
   - LIKED (Person liked Post)
   - COMMENTED_ON

3. **Implement Features**:

   a) Profile Completeness Score:
   - Has photo: +10
   - Has summary: +10
   - Number of skills: +2 each
   - Number of connections: +1 each
   - Has work history: +20

   b) "People You May Know":
   - 2nd degree connections
   - Same company (current or past)
   - Same skills (3+)
   - Endorsed by mutual connections

   c) Job Recommendations:
   - Match skills with job requirements
   - Consider career level
   - Same industry as past experience
   - Posted by connections

   d) Skill Endorsements:
   - Count endorsements per skill
   - Show who endorsed
   - Weight by endorser's skill level

   e) Content Feed:
   - Posts from connections
   - Posts from followed companies
   - Sorted by engagement (likes + comments)

   f) Network Statistics:
   - Network size (1st + 2nd connections)
   - Most common skills in network
   - Company distribution in network
   - Network growth over time

4. **Performance**:
   - Add appropriate indexes
   - Use PROFILE to optimize queries
   - Handle pagination for large result sets

**Your Solution**:
```cypher
// Build your complete LinkedIn-like system here
// Include schema, sample data, and all feature queries
```

---

## Bonus Challenge: Fraud Detection System

**Objective**: Build a fraud detection graph.

**Scenario**: Detect fraudulent transactions and account patterns.

**Graph Model**:
- Users, Accounts, Transactions, Devices, IP Addresses, Merchants

**Detection Patterns**:
1. Multiple users accessing same device
2. Rapid transactions across locations
3. Circular transaction patterns
4. Newly created accounts with high activity
5. Unusual transaction amounts

**Your Solution**:
```cypher
// Design and implement fraud detection queries
```

---

## Solutions Approach

For each exercise:
1. Write your query
2. Test with Neo4j Browser or Desktop
3. Verify results
4. Try alternative approaches
5. Use PROFILE to check performance

**Tips**:
- Use `:param` to set parameters in Neo4j Browser
- Visualize results to understand the graph structure
- Use `LIMIT` while developing to avoid large result sets
- Check the query plan with `EXPLAIN` or `PROFILE`

**Resources**:
- Neo4j Browser: `:help` for commands
- Cypher Manual: [neo4j.com/docs/cypher-manual](https://neo4j.com/docs/cypher-manual/)
- Practice at: [neo4j.com/sandbox](https://neo4j.com/sandbox/)

---

**Estimated Time**: 6-8 hours for all exercises  
**Difficulty**: Beginner → Advanced  
**Prerequisites**: Neo4j installed or Neo4j Sandbox account  

**Last Updated**: March 1, 2026  
**Course**: USJ IT Class 2026  
**Module**: Neo4j Exercises
