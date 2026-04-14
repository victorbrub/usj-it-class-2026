# Author:
# The Valencia VRS-26 Outbreak - Answer Sheet

**Name**:
**Date**:

---

## Part 1 - Exploring the Data

### Exercise 1.1 - Who Is Involved?

**How many people have a status of "recovered"? How many are "hospitalised"? How many appear "healthy"?**

> Your answer here

### Exercise 1.2 - What Locations Are in the Database?

**What types of locations appear most often? Which districts have the most activity?**

> Your answer here

### Exercise 1.3 - Visualize the Full Graph

**Which nodes appear especially well-connected?**

> Your answer here

---

## Part 2 - Identifying All Cases

### Exercise 2.1 - Who Tested Positive?

```cypher
// Your query here
```

**Who tested positive first? Who has the lowest ct_value (highest viral load)?**

> Your answer here

### Exercise 2.2 - Who Reported Symptoms First?

```cypher
// Your query here
```

**Who reported the earliest symptom onset? How many days before February 14?**

> Your answer here

### Exercise 2.3 - Confirmed Cases and Their Tests

```cypher
// Your query here
```

**Is there a person who had symptoms significantly earlier than everyone else?**

> Your answer here

### Exercise 2.4 - Who Was Hospitalised or Isolated?

```cypher
// Your query here
```

---

## Part 3 - Tracing the Origin

### Exercise 3.1 - Who Traveled Internationally Before the Outbreak?

```cypher
// Your query here
```

**How many people traveled internationally? Where did they come from? Who arrived in Valencia specifically?**

> Your answer here

### Exercise 3.2 - Who Attended the Same Events?

```cypher
// Your query here
```

**Are there any events where multiple confirmed cases were present?**

> Your answer here

### Exercise 3.3 - Where Was Patient Zero Before the First Cases?

```cypher
// Your query here
```

**Which confirmed case visited the most locations at the start of the outbreak window? Can you spot someone who arrived in Valencia and immediately visited a high-attendance location?**

> Your answer here

### Exercise 3.4 - The Transmission Chain

```cypher
// Your query here
```

**Which person appears most often as the likely source? Does any person spread the virus without being recorded as a case themselves?**

> Your answer here

### Exercise 3.5 - Follow the Full Chain

```cypher
// Your query here
```

**Which person is at the start of the longest chains? Is that the same person you identified in Exercise 3.4?**

> Your answer here

### Exercise 3.6 - Cross-Check: Did the Suspected Source Have High Viral Load?

```cypher
// Your query here (first candidate)
```

```cypher
// Your query here (second candidate)
```

**What differences in the data (dates, ct_value, transmission links) help you determine which person introduced the virus?**

> Your answer here

---

## Part 4 - The Verdict

### Exercise 4.1 - Build a Suspicion Score

```cypher
// Your query here
```

**Based on all the evidence gathered, fill in your conclusion:**

| | Your Answer |
|---|---|
| Patient Zero (name) | |
| Place of first infection (city or event) | |
| Date of arrival in Valencia | |

---

## Reflection Questions

**1. How did the MAY_HAVE_INFECTED relationship help you trace connections that would be very difficult to represent in a relational database?**

> Your answer here

**2. What is the difference between a person being a contact of a case and being the source of a case? How did the graph help you distinguish these?**

> Your answer here

**3. In Exercise 3.5 you traced paths up to 4 hops long. How many SQL JOIN operations would that equivalent query require?**

> Your answer here

**4. Which relationship properties from this dataset were most useful for making decisions?**

> Your answer here

**5. Why is it not enough to find the person who traveled internationally? What additional signals were needed to confirm Patient Zero?**

> Your answer here

---

## Bonus Challenges (optional)

### Bonus A - Shortest Path Between Two Cases

```cypher
// Your query here
```

**How many hops separate the most severe case in Valencia from the original source in Geneva?**

> Your answer here

### Bonus B - Degree Centrality

```cypher
// Your query here
```

**Does the most connected person match your Patient Zero conclusion? What does high connectivity mean in an epidemiological context?**

> Your answer here

### Bonus C - Timeline of the Outbreak

```cypher
// Your query here
```

### Bonus D - Persons Not Linked to the Main Chain

```cypher
// Your query here
```

**What might explain isolated positive cases with no recorded transmission links?**

> Your answer here
