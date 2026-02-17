# SQL Practice Exercises - GameVerse Database
## Entry Level SQL & Data Modeling
**Duration:** 1.5 hours  
**Database:** GameVerse (Game Store Database)

---

## Database Overview

The GameVerse database contains information about video games, publishers, developers, users, and their interactions. Here are the main tables:

- **publishers**: Game publishing companies
- **developers**: Game development studios
- **genres**: Game categories (Action, RPG, etc.)
- **platforms**: Gaming platforms (PlayStation, Xbox, PC, etc.)
- **games**: Video game titles with ratings and prices
- **game_platforms**: Which games are available on which platforms
- **users**: Registered users of the platform
- **user_library**: Games owned by each user
- **reviews**: User reviews and ratings for games
- **achievements**: In-game achievements
- **user_achievements**: Achievements unlocked by users

---

## Part 1: Basic SELECT Queries (15 minutes)

### Exercise 1.1: View All Data
Write a query to display all columns from the `genres` table.

<details>
<summary>Hint</summary>
Use SELECT * FROM table_name
</details>

---

### Exercise 1.2: Select Specific Columns
Write a query to display only the `title` and `price` columns from the `games` table.

<details>
<summary>Hint</summary>
List column names separated by commas after SELECT
</details>

---

### Exercise 1.3: Select with Calculated Column
Write a query to display the `title` and `price` from the `games` table, and add a third column called `discounted_price` that shows the price reduced by 20%.

<details>
<summary>Hint</summary>
Use: price * 0.80 AS discounted_price
</details>

---

## Part 2: Filtering Data with WHERE (20 minutes)

### Exercise 2.1: Simple Condition
Write a query to find all games with a `price` greater than $50.00.

<details>
<summary>Hint</summary>
Use WHERE price > 50.00
</details>

---

### Exercise 2.2: Text Matching
Write a query to find all publishers from 'Japan'.

<details>
<summary>Hint</summary>
Use WHERE country = 'Japan'
</details>

---

### Exercise 2.3: Pattern Matching
Write a query to find all games whose title starts with 'The'.

<details>
<summary>Hint</summary>
Use WHERE title LIKE 'The%'
</details>

---

### Exercise 2.4: Multiple Conditions (AND)
Write a query to find all games that have a `metacritic_score` greater than 90 AND a `price` less than $60.

<details>
<summary>Hint</summary>
Combine conditions with AND
</details>

---

### Exercise 2.5: Multiple Conditions (OR)
Write a query to find all users who are either from 'USA' OR have `is_premium` set to TRUE.

<details>
<summary>Hint</summary>
Combine conditions with OR
</details>

---

### Exercise 2.6: Using IN
Write a query to find all developers from 'USA', 'Canada', or 'Poland'.

<details>
<summary>Hint</summary>
Use WHERE country IN ('USA', 'Canada', 'Poland')
</details>

---

### Exercise 2.7: Using BETWEEN
Write a query to find all games with a `metacritic_score` between 80 and 90 (inclusive).

<details>
<summary>Hint</summary>
Use WHERE metacritic_score BETWEEN 80 AND 90
</details>

---

## Part 3: Sorting and Limiting Results (10 minutes)

### Exercise 3.1: Sort Ascending
Write a query to display all games sorted by `price` from lowest to highest.

<details>
<summary>Hint</summary>
Use ORDER BY price ASC (or just ORDER BY price)
</details>

---

### Exercise 3.2: Sort Descending
Write a query to display all games sorted by `metacritic_score` from highest to lowest.

<details>
<summary>Hint</summary>
Use ORDER BY metacritic_score DESC
</details>

---

### Exercise 3.3: Multiple Sort Columns
Write a query to display all games sorted first by `genre_id`, then by `price` (highest to lowest within each genre).

<details>
<summary>Hint</summary>
Use ORDER BY genre_id, price DESC
</details>

---

### Exercise 3.4: Limiting Results
Write a query to display the top 5 most expensive games (title and price only).

<details>
<summary>Hint</summary>
Use ORDER BY price DESC LIMIT 5
</details>

---

## Part 4: Aggregate Functions (15 minutes)

### Exercise 4.1: Count Records
Write a query to count how many games are in the database.

<details>
<summary>Hint</summary>
Use SELECT COUNT(*) FROM games
</details>

---

### Exercise 4.2: Average Value
Write a query to calculate the average price of all games.

<details>
<summary>Hint</summary>
Use SELECT AVG(price) FROM games
</details>

---

### Exercise 4.3: Maximum and Minimum
Write a query to find the highest and lowest `metacritic_score` in the games table.

<details>
<summary>Hint</summary>
Use MAX() and MIN() functions
</details>

---

### Exercise 4.4: Sum Total
Write a query to calculate the total amount of money spent by all users (use `total_spent` column from `users` table).

<details>
<summary>Hint</summary>
USE SELECT SUM(total_spent) FROM users
</details>

---

### Exercise 4.5: Count with Condition
Write a query to count how many users have `is_premium` set to TRUE.

<details>
<summary>Hint</summary>
Combine COUNT(*) with WHERE is_premium = TRUE
</details>

---

## Part 5: GROUP BY (20 minutes)

### Exercise 5.1: Simple Grouping
Write a query to count how many games exist for each `genre_id`. Display the genre_id and the count.

<details>
<summary>Hint</summary>
Use GROUP BY genre_id with COUNT(*)
</details>

---

### Exercise 5.2: Group with Average
Write a query to calculate the average price of games for each `genre_id`.

<details>
<summary>Hint</summary>
Use GROUP BY genre_id with AVG(price)
</details>

---

### Exercise 5.3: Group with Multiple Aggregates
Write a query to show for each `publisher_id`:
- The count of games
- The average metacritic score
- The maximum price

<details>
<summary>Hint</summary>
Use multiple aggregate functions with GROUP BY publisher_id
</details>

---

### Exercise 5.4: HAVING Clause
Write a query to find which `publisher_id` has published more than 5 games.

<details>
<summary>Hint</summary>
Use GROUP BY with HAVING COUNT(*) > 5
</details>

---

### Exercise 5.5: Group by Country
Write a query to count how many developers are in each country, but only show countries with more than 2 developers.

<details>
<summary>Hint</summary>
GROUP BY country, then use HAVING COUNT(*) > 2
</details>

---

## Part 6: JOINS (25 minutes)

### Exercise 6.1: Simple INNER JOIN
Write a query to display game titles along with their genre names (not just genre_id). Show `title` and `name` (from genres).

<details>
<summary>Hint</summary>
JOIN games and genres tables ON genre_id
</details>

---

### Exercise 6.2: Three Table JOIN
Write a query to display:
- Game title
- Publisher name
- Developer name

Join the `games`, `publishers`, and `developers` tables.

<details>
<summary>Hint</summary>
Use two JOIN clauses - one for publishers and one for developers
</details>

---

### Exercise 6.3: JOIN with WHERE
Write a query to find all games in the 'RPG' genre (show title, genre name, and price).

<details>
<summary>Hint</summary>
JOIN games and genres, then use WHERE genres.name = 'RPG'
</details>

---

### Exercise 6.4: JOIN with Aggregation
Write a query to show each genre name and the count of games in that genre, sorted by count (highest first).

<details>
<summary>Hint</summary>
JOIN games and genres, GROUP BY genre name, ORDER BY count DESC
</details>

---

### Exercise 6.5: Complex JOIN
Write a query to show:
- Publisher name
- Number of games they've published
- Average metacritic score of their games
Only show publishers with an average score above 85.

<details>
<summary>Hint</summary>
JOIN games and publishers, GROUP BY publisher, use HAVING for average filter
</details>

---

### Exercise 6.6: Many-to-Many Relationship
Write a query to show which games are available on 'PC'. Display game title and platform name.

<details>
<summary>Hint</summary>
You need to join three tables: games, game_platforms, and platforms
</details>

---

## Part 7: Challenge Problems (15 minutes)

### Challenge 7.1: User Library Analysis
Write a query to find the username and total number of games owned for users who own more than 3 games.

<details>
<summary>Hint</summary>
JOIN users and user_library, GROUP BY username, use HAVING
</details>

---

### Challenge 7.2: Popular Games
Write a query to find the top 5 most reviewed games. Show:
- Game title
- Number of reviews
- Average rating from reviews

<details>
<summary>Hint</summary>
JOIN games and reviews, use COUNT() and AVG(), GROUP BY game title, LIMIT 5
</details>

---

### Challenge 7.3: Publisher Performance
Write a query to find publishers who have:
- Published more than 3 games
- Average game price above $40
- Average metacritic score above 80

Show publisher name, game count, average price, and average score.

<details>
<summary>Hint</summary>
JOIN publishers and games, use multiple aggregate functions, and multiple HAVING conditions
</details>

---

### Challenge 7.4: User Engagement
Write a query to find users who have:
- Purchased at least one game
- Written at least one review
- Unlocked at least one achievement

Show username and count of each activity.

<details>
<summary>Hint</summary>
This requires multiple JOINs (user_library, reviews, user_achievements)
You may want to use LEFT JOINs and COUNT(DISTINCT ...)
</details>

---

## Bonus: Data Modeling Questions

1. **Explain the relationship** between `games` and `platforms`. Why is there a `game_platforms` table?

2. **Identify the foreign keys** in the `games` table and explain what they reference.

3. **Why use SERIAL** for primary key columns instead of INT?

4. **What does the CHECK constraint** do in the `reviews` table for the rating column?

5. **Design a new table**: If we wanted to track "game sales by region", what columns would you include? What would be the primary key?

---

## Notes for Students

- Always test your queries on small datasets first
- Use meaningful column aliases with `AS`
- Remember that SQL is case-insensitive for keywords (SELECT = select)
- String values are case-sensitive and must be in quotes
- Practice reading error messages - they often tell you exactly what's wrong!

---

## Additional Resources

- Check `sample-queries.sql` for query examples
- Review `create_tables.sql` to understand the full schema
- Practice makes perfect - try to solve each problem without looking at hints first!

**Good luck!**
