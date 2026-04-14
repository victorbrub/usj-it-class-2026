# Author:
# The Valencia Museum Heist - Answer Sheet

**Name**:
**Date**:

---

## Part 2 - Getting Acquainted with the Data

### Exercise 2.2 - Count People by Role

```cypher
// Your query here
```

### Exercise 2.3 - List All Locations

```cypher
// Your query here
```

### Exercise 2.4 - Explore Suspects

```cypher
// Your query here
```

### Exercise 2.5 - View Evidence Summary

**What do you notice about which person appears most in the evidence linkage?**

> Your answer here

---

## Part 3 - First Lines of Investigation

### Exercise 3.1 - Who Was at the Museum?

```cypher
// Your query here
```

### Exercise 3.2 - Alibi Check

```cypher
// Your query here
```

**Which suspects have a recorded alibi elsewhere that night? Do the timings clear them?**

> Your answer here

### Exercise 3.3 - Phone Activity Near the Museum

```cypher
// Your query here
```

**Which suspects were making calls in the Ciutat Vella district that night?**

> Your answer here

### Exercise 3.4 - The Warehouse Connection

```cypher
// Part A: persons who visited the warehouse
```

```cypher
// Part B: vehicles spotted at the warehouse
```

**Is there overlap between the people and the vehicle owners?**

> Your answer here

### Exercise 3.5 - Suspects with Criminal Records

```cypher
// Your query here
```

---

## Part 4 - Following the Money

### Exercise 4.1 - Large Transactions After the Theft

```cypher
// Your query here
```

**Who received the largest sums after the theft? What does the concept say?**

> Your answer here

### Exercise 4.2 - Follow the Money Chain

```cypher
// Your query here
```

**How many steps separate Iván Bosch from Félix Castillo through social connections?**

> Your answer here

### Exercise 4.3 - Who Paid for Services Before the Theft?

```cypher
// Your query here
```

**Who received a payment for "Electrical services"? What does this mean for the investigation?**

> Your answer here

### Exercise 4.4 - Transportation Payment

```cypher
// Your query here
```

---

## Part 5 - Connecting the Dots

### Exercise 5.1 - Suspect Network Map

```cypher
// Your query here
```

**Who is the most connected node in this social web?**

> Your answer here

### Exercise 5.2 - The White Van

```cypher
// Your query here
```

**Where was the white van spotted and in what order?**

> Your answer here

### Exercise 5.3 - Full Evidence Fingerprint

```cypher
// Your query here
```

**Which person has the most pieces of evidence pointing to them?**

> Your answer here

### Exercise 5.4 - Complete Path from Evidence to Money

```cypher
// Your query here
```

**Who executed the theft? Who organized transport? Who received the stolen goods?**

> Your answer here

---

## Part 6 - The Verdict

### Exercise 6.1 - Build the Case

```cypher
// Your query here
```

**My conclusion - who is the thief and why?**

> Your answer here

**Chain of evidence supporting your conclusion:**

> Your answer here

---

## Reflection Questions

**1. How did the graph model help you trace connections that would have been difficult in a relational database?**

> Your answer here

**2. What is the difference between a MATCH path and a raw WHERE filter when investigating linked data?**

> Your answer here

**3. In Exercise 5.4 you traced a path across 4 node types. How many JOIN operations would that have required in SQL?**

> Your answer here

**4. Which relationship properties proved most useful during the investigation?**

> Your answer here

**5. Which single Cypher query gave you the most useful investigative insight, and why?**

> Your answer here

---

## Bonus Challenges (optional)

### Bonus A - Shortest Path Between Suspects

```cypher
// Your query here
```

### Bonus B - Degree Centrality

```cypher
// Your query here
```

### Bonus C - Timeline Reconstruction

```cypher
// Your query here
```

### Bonus D - Isolated Suspect

```cypher
// Your query here
```

**Is Rosa Ferrer connected to the criminal network within 3 hops of Iván Bosch?**

> Your answer here
