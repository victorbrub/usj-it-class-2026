# Author: Víctor Barceló
# GameVerse MongoDB Compass Lab

**Duration**: 2 hours  
**Tool**: MongoDB Compass  
**Database**: GameVerse (adapted for MongoDB)

## Objectives

By the end of this lab you will be able to:

- Import JSON documents into MongoDB using MongoDB Compass
- Query documents using the Compass filter bar with MongoDB Query Language (MQL)
- Use projection, sorting, and pagination controls
- Build aggregation pipelines using the visual Pipeline Builder
- Query deeply nested embedded documents and arrays
- Compare MongoDB query syntax with its SQL equivalent

## Dataset

This lab uses three collections stored as JSON files in the `gameverse/` folder:

- `games.json` — 31 game documents
- `users.json` — 20 user documents
- `publishers.json` — 6 publisher documents with deeply nested structure

---

## Part 0 - Setup (10 minutes)

### Step 0.1 - Open MongoDB Compass and Connect

1. Open MongoDB Compass on your computer.
2. In the "New Connection" screen, enter the connection string: `mongodb://localhost:27017`
3. Click **Connect**.
4. You should see the MongoDB server home screen listing the system databases (`admin`, `config`, `local`).

### Step 0.2 - Create the Database and Collections

1. In the left sidebar, click the **+** button next to "Databases".
2. In the dialog that opens:
   - **Database Name**: `gameverse`
   - **Collection Name**: `games`
3. Click **Create Database**.
4. The `gameverse` database now appears in the left sidebar.
5. Click on `gameverse` to expand it.
6. Click the **+** button next to `gameverse` to add a second collection:
   - **Collection Name**: `users`
   - Click **Create Collection**.
7. Repeat to create a third collection:
   - **Collection Name**: `publishers`

### Step 0.3 - Import the Data

Repeat the following import steps for each of the three collections.

**Import `games.json` into the `games` collection:**

1. Click on the `games` collection in the sidebar to open it.
2. Click the **Add Data** button (top centre of the screen).
3. Select **Import JSON or CSV file**.
4. Browse to the `gameverse/` folder and select `games.json`.
5. Click **Import**.
6. Compass confirms how many documents were imported.

Repeat for `users.json` into the `users` collection, and `publishers.json` into the `publishers` collection.

### Step 0.4 - Verify the Import

Click on each collection and confirm the document counts:

- `games`: 31 documents
- `users`: 20 documents
- `publishers`: 6 documents

> **Checkpoint**: Click on one document to expand it and inspect its embedded fields. Can you identify which fields are embedded objects and which are arrays?

---

## Part 1 - Basic Queries (15 minutes)

### How Queries Work in MongoDB Compass

In a collection's **Documents** view, there is a **Filter** bar at the top. The filter accepts a **JSON object** describing your query conditions. For example:

```
{ "genre": "RPG" }
```

After entering a filter, press **Enter** or click **Find** to run the query. Leave the filter empty (`{}`) or blank to return all documents.

**Comparison with SQL:**

In SQL, conditions are written after the `WHERE` keyword using natural language operators.
In MongoDB Compass, conditions are written as a JSON object.

| Task | SQL | MongoDB Compass Filter |
|---|---|---|
| All documents | `SELECT * FROM games` | `{}` |
| Exact match | `WHERE genre = 'RPG'` | `{ "genre": "RPG" }` |

---

### Exercise 1.1 - Browse All Documents

In each collection, leave the filter empty and press **Enter**.

- How many documents appear in `games`? In `users`? In `publishers`?
- Expand one game document. What are its top-level fields?
- Which fields contain embedded objects? Which contain arrays?
- In the `publishers` collection, expand one document fully. How many levels of nesting can you find?

---

### Exercise 1.2 - Find a Specific Document

In the `games` collection, use the filter bar to find the document for **"Elden Ring"**:

```
{ "title": "Elden Ring" }
```

In the `users` collection, find the user with username **"rpg_master"**:

```
{ "username": "rpg_master" }
```

> **SQL equivalent:**
> ```sql
> SELECT * FROM games WHERE title = 'Elden Ring';
> SELECT * FROM users WHERE username = 'rpg_master';
> ```

---

### Exercise 1.3 - Comparison Operators

MongoDB uses operator keys prefixed with `$` for comparisons. These go inside a nested object on the field you are filtering.

| Operator | Meaning | SQL equivalent |
|---|---|---|
| `$gte` | >= (greater than or equal) | `>= value` |
| `$gt` | > (greater than) | `> value` |
| `$lte` | <= (less than or equal) | `<= value` |
| `$lt` | < (less than) | `< value` |
| `$ne` | != (not equal) | `<> value` |

Find all games with a metacritic score of **90 or higher**:

```
{ "metacritic_score": { "$gte": 90 } }
```

> **SQL equivalent:** `SELECT * FROM games WHERE metacritic_score >= 90;`

Find all **free-to-play** games (price equal to 0):

```
{ "price": 0 }
```

Find all games **released after January 1, 2022**:

```
{ "release_date": { "$gt": "2022-01-01" } }
```

> **SQL equivalent:** `SELECT * FROM games WHERE release_date > '2022-01-01';`

Find all games with a price **between 20 and 60 (inclusive)**:

```
{ "price": { "$gte": 20, "$lte": 60 } }
```

> **SQL equivalent:** `SELECT * FROM games WHERE price BETWEEN 20 AND 60;`

---

### Exercise 1.4 - Multiple Conditions (AND)

When you include multiple fields in the same filter object, MongoDB treats them as AND conditions — all conditions must be satisfied.

Find all **RPG games with a metacritic score above 90**:

```
{ "genre": "RPG", "metacritic_score": { "$gt": 90 } }
```

> **SQL equivalent:** `SELECT * FROM games WHERE genre = 'RPG' AND metacritic_score > 90;`

Now write your own filters:

Find all **premium users from Japan**:

```
// Write your filter here
```

Find all games with rating **"M"** that cost **less than 30**:

```
// Write your filter here
```

---

## Part 2 - Filtering (20 minutes)

### Exercise 2.1 - The $in and $nin Operators

`$in` matches any value from a given list. It is equivalent to SQL's `IN` clause.

Find all games in the **RPG or Adventure** genres:

```
{ "genre": { "$in": ["RPG", "Adventure"] } }
```

> **SQL equivalent:** `SELECT * FROM games WHERE genre IN ('RPG', 'Adventure');`

Find all users from **USA, Canada, or UK**:

```
{ "country": { "$in": ["USA", "Canada", "UK"] } }
```

Find all games that are **NOT rated "M"** using `$nin` (not in):

```
{ "rating": { "$nin": ["M"] } }
```

> **SQL equivalent:** `SELECT * FROM games WHERE rating NOT IN ('M');`

---

### Exercise 2.2 - Array Queries

If a document field is an array, MongoDB can check whether the array **contains a specific value** using plain equality — no special operator needed.

Find all games available on **Nintendo Switch**:

```
{ "platforms": "Nintendo Switch" }
```

> **SQL equivalent (relational model):**
> ```sql
> SELECT g.title
> FROM games g
> JOIN game_platforms gp ON g.id = gp.game_id
> JOIN platforms p ON gp.platform_id = p.id
> WHERE p.name = 'Nintendo Switch';
> ```
> Notice how much simpler the MongoDB query is — no JOIN is needed because platforms are embedded as an array inside the game document.

Find all games with the tag **"open-world"**:

```
{ "tags": "open-world" }
```

Find all games available on **exactly one platform** using `$size`:

```
{ "platforms": { "$size": 1 } }
```

> **SQL equivalent:** Requires a subquery counting rows in `game_platforms` — significantly more verbose.

---

### Exercise 2.3 - Dot Notation (Embedded Documents)

MongoDB uses **dot notation** to query fields inside embedded objects. Use `"parent.child"` as the field path, always inside quotes.

For example, the `publisher` field inside a game document is an object with `name`, `country`, and `founded_year`. To query `publisher.country`:

```
{ "publisher.country": "Japan" }
```

> **SQL equivalent:**
> ```sql
> SELECT * FROM games g
> JOIN publishers p ON g.publisher_id = p.id
> WHERE p.country = 'Japan';
> ```
> No JOIN is needed in MongoDB — the publisher data is embedded in the document.

Find all games developed by a team with **fewer than 100 employees**:

```
{ "developer.employee_count": { "$lt": 100 } }
```

Find all games developed by **CD Projekt Red**:

```
{ "developer.name": "CD Projekt Red" }
```

Find all games where the **publisher was founded before 1990**:

```
// Write your filter here
```

---

### Exercise 2.4 - Queries on Nested Arrays

The `library` field in a user document is an array of objects (embedded game entries). You can use dot notation to query inside these nested objects.

Find all users who **own "Elden Ring"** in their library:

```
{ "library.title": "Elden Ring" }
```

Find all users who have **written at least one review with rating 10**:

```
{ "reviews.rating": 10 }
```

When you need to match an array element where **multiple conditions apply to the same element** (not spread across different elements), use `$elemMatch`.

Find all users who own a game they played for **more than 100 hours AND purchased for less than 20**:

```
{ "library": { "$elemMatch": { "hours_played": { "$gt": 100 }, "purchase_price": { "$lt": 20 } } } }
```

> **SQL equivalent:**
> ```sql
> SELECT DISTINCT u.username
> FROM users u
> JOIN user_library ul ON u.id = ul.user_id
> WHERE ul.hours_played > 100 AND ul.purchase_price < 20;
> ```

---

### Exercise 2.5 - Regular Expressions ($regex)

MongoDB supports regex pattern matching on string fields using `$regex`.

Find all games whose title **starts with "The"**:

```
{ "title": { "$regex": "^The" } }
```

Find all users whose email contains **"gmail"**:

```
{ "email": { "$regex": "gmail" } }
```

Find all games whose title contains **"2"** (sequels):

```
// Write your filter here
```

> **SQL equivalent:** `SELECT * FROM games WHERE title LIKE '%2%';`  
> MongoDB uses regex patterns; SQL uses `LIKE` with `%` wildcards.

---

## Part 3 - Projection, Sorting, and Pagination (15 minutes)

### How to Use the Options Panel

Below the Filter bar, click **Options** to expand additional controls:

- **Project**: Choose which fields to include or exclude in the output
- **Sort**: Define the sort order
- **Skip**: Number of documents to skip (for pagination)
- **Limit**: Maximum number of documents to return

---

### Exercise 3.1 - Projection (Selecting Fields)

Projection uses `1` to **include** a field and `0` to **exclude** it. The `_id` field is included by default — set it to `0` to hide it.

Show only `username`, `country`, and `is_premium` for all users:

**Filter:** `{}`  
**Project:** `{ "username": 1, "country": 1, "is_premium": 1, "_id": 0 }`

> **SQL equivalent:** `SELECT username, country, is_premium FROM users;`

Show only `title`, `genre`, and `price` for all free-to-play games:

**Filter:** `{ "price": 0 }`  
**Project:** `{ "title": 1, "genre": 1, "price": 1, "_id": 0 }`

> **SQL equivalent:** `SELECT title, genre, price FROM games WHERE price = 0;`

Show only `title` and `metacritic_score` for all games, hiding all other fields:

**Filter:** `{}`  
**Project:** `// Write your projection here`

---

### Exercise 3.2 - Sorting

In the **Sort** bar, use `1` for ascending and `-1` for descending order.

Sort all games by metacritic score from **highest to lowest**:

**Filter:** `{}`  
**Sort:** `{ "metacritic_score": -1 }`

> **SQL equivalent:** `SELECT * FROM games ORDER BY metacritic_score DESC;`

Sort games by **price ascending, then metacritic score descending** (multi-field sort):

**Sort:** `{ "price": 1, "metacritic_score": -1 }`

> **SQL equivalent:** `SELECT * FROM games ORDER BY price ASC, metacritic_score DESC;`

Sort users by **total_spent descending**:

**Filter:** `{}`  
**Sort:** `{ "total_spent": -1 }`

---

### Exercise 3.3 - Pagination (Skip and Limit)

Use **Limit** to control how many results are returned, and **Skip** to jump past results you have already seen.

Show only the **top 5 games** by metacritic score:

**Filter:** `{}`  
**Sort:** `{ "metacritic_score": -1 }`  
**Limit:** `5`

> **SQL equivalent:** `SELECT * FROM games ORDER BY metacritic_score DESC LIMIT 5;`

Show games **ranked 6 to 10** (the second page of 5):

**Filter:** `{}`  
**Sort:** `{ "metacritic_score": -1 }`  
**Skip:** `5`  
**Limit:** `5`

> **SQL equivalent:** `SELECT * FROM games ORDER BY metacritic_score DESC LIMIT 5 OFFSET 5;`

Show only the **3 most expensive games**:

**Filter:** `{}`  
**Sort:** `// Write your sort here`  
**Limit:** `// Write your limit here`

---

## Part 4 - Aggregation Pipeline (25 minutes)

### How to Use the Aggregation Pipeline Builder

1. Click on a collection in the sidebar.
2. Click the **Aggregation** tab at the top (next to the "Documents" tab).
3. Click **Add Stage** to add the first stage.
4. For each stage:
   - Use the **left dropdown** to select the stage type (e.g., `$match`, `$group`, `$sort`).
   - In the **right text area**, enter the **stage body** — this is the JSON content inside the operator, without the operator name.
5. Click **Add Stage** again to chain additional stages.
6. The **output preview** on the right updates automatically as you build the pipeline.

**SQL comparison overview:**

| MongoDB pipeline stage | SQL equivalent |
|---|---|
| `$match` | `WHERE` |
| `$group` | `GROUP BY` + aggregate functions (`COUNT`, `AVG`, `SUM`, etc.) |
| `$project` | `SELECT` (choosing fields, renaming, computed values) |
| `$sort` | `ORDER BY` |
| `$limit` | `LIMIT` |
| `$unwind` | JOIN on a one-to-many relationship |

---

### Exercise 4.1 - $group (Count per Category)

Count how many games exist **per genre**, sorted by count descending.

**Stage 1** — select `$group`, enter in the body:
```
{ "_id": "$genre", "count": { "$sum": 1 } }
```

**Stage 2** — select `$sort`, enter:
```
{ "count": -1 }
```

> **SQL equivalent:**
> ```sql
> SELECT genre, COUNT(*) AS count
> FROM games
> GROUP BY genre
> ORDER BY count DESC;
> ```

Now count how many games each **publisher country** has contributed:

- `$group` body: `{ "_id": "$publisher.country", "total": { "$sum": 1 } }`
- `$sort` body: `{ "total": -1 }`

---

### Exercise 4.2 - $match + $group (Filtered Aggregation)

Compute the **average metacritic score** of all RPG games.

**Stage 1** — `$match`:
```
{ "genre": "RPG" }
```

**Stage 2** — `$group`:
```
{ "_id": null, "avg_score": { "$avg": "$metacritic_score" } }
```

> **SQL equivalent:**
> ```sql
> SELECT AVG(metacritic_score) AS avg_score
> FROM games
> WHERE genre = 'RPG';
> ```

Now find the **minimum and maximum price** of games released after 2020:

**Stage 1** — `$match`:
```
{ "release_date": { "$gt": "2020-01-01" } }
```

**Stage 2** — `$group`:
```
// Write your stage body here
// Hint: use "$min" and "$max" operators
```

---

### Exercise 4.3 - $project (Computed Fields)

Create a result showing only `title` and a new field `publisher_name` extracted from `publisher.name`.

**Stage** — `$project`:
```
{ "_id": 0, "title": 1, "publisher_name": "$publisher.name" }
```

> **SQL equivalent:**
> ```sql
> SELECT g.title, p.name AS publisher_name
> FROM games g
> JOIN publishers p ON g.publisher_id = p.id;
> ```

Create a projection showing `title` and a computed field `score_times_10` (metacritic_score multiplied by 10):

**Stage** — `$project`:
```
{ "_id": 0, "title": 1, "score_times_10": { "$multiply": ["$metacritic_score", 10] } }
```

---

### Exercise 4.4 - $unwind (Flattening Arrays)

`$unwind` deconstructs an array field, creating one output document per array element. This is conceptually similar to a JOIN in SQL — it "expands" an embedded one-to-many relationship.

Count how many **game entries exist per platform** across all games in the collection.

**Stage 1** — `$unwind`, enter in the body:
```
"$platforms"
```

**Stage 2** — `$group`:
```
{ "_id": "$platforms", "game_count": { "$sum": 1 } }
```

**Stage 3** — `$sort`:
```
{ "game_count": -1 }
```

> **SQL equivalent:**
> ```sql
> SELECT p.name AS platform, COUNT(*) AS game_count
> FROM games g
> JOIN game_platforms gp ON g.id = gp.game_id
> JOIN platforms p ON gp.platform_id = p.id
> GROUP BY p.name
> ORDER BY game_count DESC;
> ```

Now, using `$unwind`, count the **total number of achievements** available per game:

```
// Write your pipeline stages here
// Hint: unwind "$achievements", then group by "$title"
```

---

### Exercise 4.5 - Aggregation on the Users Collection

Find the **total hours played** per user (summing all games from their library), sorted descending:

**Stage 1** — `$unwind`: `"$library"`  
**Stage 2** — `$group`: `{ "_id": "$username", "total_hours": { "$sum": "$library.hours_played" } }`  
**Stage 3** — `$sort`: `{ "total_hours": -1 }`

Find the **average review rating** given by each user:

**Stage 1** — `$unwind`: `"$reviews"`  
**Stage 2** — `$group`:
```
// Write your stage body here
```

Find all users with the **number of games in their library**, sorted by library size descending:

**Stage 1** — `$project`:
```
{ "_id": 0, "username": 1, "library_size": { "$size": "$library" } }
```

**Stage 2** — `$sort`: `{ "library_size": -1 }`

> **SQL equivalent:** `SELECT username, COUNT(*) AS library_size FROM user_library GROUP BY username ORDER BY library_size DESC;`

---

## Part 5 - Publishers Collection: Deep Nesting (10 minutes)

The `publishers` collection demonstrates MongoDB's ability to store deeply nested data in a single document. Each publisher document contains a full game catalog, with DLC arrays nested inside each catalog entry, and awards arrays nested inside each DLC. This creates three to four levels of nesting.

Browse one publisher document fully before starting these exercises.

### Exercise 5.1 - Query Publisher-Level Fields

Find all publishers **headquartered in Japan**:

```
{ "headquarters.country": "Japan" }
```

Find all publishers with **more than 5,000 employees**:

```
{ "financials.employees": { "$gt": 5000 } }
```

Find all publishers that are **publicly traded**:

```
{ "financials.publicly_traded": true }
```

Find all publishers whose **headquarters is in Tokyo**:

```
// Write your filter here
```

---

### Exercise 5.2 - Query Catalog and DLC Arrays

Find all publishers that have **a game with metacritic score above 95** in their catalog:

```
{ "catalog.metacritic_score": { "$gt": 95 } }
```

Find all publishers that have **a Strategy game** in their catalog:

```
{ "catalog.genre": "Strategy" }
```

Find all publishers that have **DLC priced above 20**:

```
{ "catalog.dlc.price": { "$gt": 20 } }
```

> This query navigates three levels deep: `publishers` -> `catalog[]` -> `dlc[].price`. MongoDB handles this with simple dot notation — no joins required.

---

### Exercise 5.3 - Advanced Filtering on Nested Arrays

Find all publishers that have **won at least one BAFTA award** in their catalog:

```
{ "catalog.awards": { "$elemMatch": { "ceremony": "BAFTA Games Awards", "won": true } } }
```

Find all publishers whose catalog contains **DLC entries that add new areas** (the `new_areas` array is non-empty):

```
{ "catalog.dlc.new_areas": { "$exists": true, "$ne": [] } }
```

---

## Part 6 - Update Operations (10 minutes)

MongoDB Compass includes an embedded **mongosh** shell for running update operations. Click the **`>_`** button at the bottom of the Compass window to open it.

When the shell opens, switch to your database:

```javascript
use gameverse
```

---

### Exercise 6.1 - Update a Single Document

Set the price of **"Cyberpunk 2077"** to `29.99`:

```javascript
db.games.updateOne(
  { title: "Cyberpunk 2077" },
  { $set: { price: 29.99 } }
)
```

After running this, go back to the Documents tab and use the filter `{ "title": "Cyberpunk 2077" }` to verify the change.

Add the tag `"classic"` to **"The Witcher 3: Wild Hunt"** (using `$push` to append to the array without removing existing tags):

```javascript
db.games.updateOne(
  { title: "The Witcher 3: Wild Hunt" },
  { $push: { tags: "classic" } }
)
```

> **SQL equivalent:** `UPDATE games SET price = 29.99 WHERE title = 'Cyberpunk 2077';`  
> Note: In SQL, arrays do not exist — tags would be stored in a separate table, requiring a JOIN to modify.

---

### Exercise 6.2 - Update Multiple Documents

Increase the `metacritic_score` by 1 for all games developed in **Japan** (use `$inc` to increment):

```javascript
// Write your command here
// Hint: db.games.updateMany( filter, { $inc: { field: value } } )
```

Set `account_status` to `"inactive"` for all users whose `last_login` is before `"2026-01-01T00:00:00Z"`:

```javascript
// Write your command here
```

> **SQL equivalent:** `UPDATE users SET account_status = 'inactive' WHERE last_login < '2026-01-01';`

---

### Exercise 6.3 - Verify Updates

Use the Compass filter bar to verify your changes.

In the `users` collection, filter for all inactive users:

**Filter:** `{ "account_status": "inactive" }`  
**Project:** `{ "username": 1, "last_login": 1, "_id": 0 }`

---

## Bonus Challenges

If you finish early, try these:

**Bonus 1**: Find all users who own at least one game with `hours_played` greater than 300.

**Bonus 2**: Find all games that have more than 3 platforms AND a metacritic score above 90.

**Bonus 3**: Using the Aggregation Pipeline Builder, find the **genre with the highest average metacritic score**. Hint: use `$group`, `$sort`, and `$limit`.

**Bonus 4**: In the `publishers` collection, find all publishers whose annual revenue (`financials.annual_revenue_usd_millions`) is above 1,000 AND who are publicly traded.

**Bonus 5**: Aggregate the `publishers` collection to find the **total number of games across all publishers' catalogs combined**. Hint: `$unwind` the `catalog` field, then use `$count` or `$group`.

---

## Reflection Questions

Answer these after completing the exercise:

1. In the relational GameVerse database, how many tables were needed to store game and publisher information? How many collections does MongoDB need? What does this tell you about the trade-off between normalization and embedding?

2. When would embedding a publisher inside a game document cause problems? Think about a scenario where publisher information needs to be updated across many games.

3. You queried `platforms` as a simple array of strings. What would you need to change if you wanted to store platform-specific data (for example, platform release dates or platform-specific pricing)?

4. Compare the aggregation pipeline with a GROUP BY query in SQL. What are the advantages and disadvantages of each approach?

5. In Exercise 2.4, you used `"library.title": "Elden Ring"` to find users who own a game. How does this compare to the SQL approach? In what situations might the SQL approach be preferable?

6. The `publishers` collection embeds an entire game catalog inside each publisher document. What are the advantages and risks of this design compared to maintaining a separate `games` collection?
