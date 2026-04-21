# MongoDB - Practical Exercises

Complete these exercises to practice MongoDB concepts and operations. Work through them in order, as they build on each other.

---

## Exercise 1: Database and Collection Setup

**Objective**: Create a database and collections for a library management system.

**Tasks**:

1. Create a database named `library`
2. Create the following collections:
   - `books`
   - `members`
   - `loans`
3. List all databases to verify creation
4. Show all collections in the `library` database

**MongoDB Commands**:
```javascript
// Write your commands here
```

**Expected Outcome**: Database and collections created successfully.

---

## Exercise 2: Insert Documents

**Objective**: Practice inserting single and multiple documents.

**Tasks**:

1. Insert one book document with the following structure:
```javascript
{
  title: "The Great Gatsby",
  author: "F. Scott Fitzgerald",
  isbn: "978-0-7432-7356-5",
  publicationYear: 1925,
  genre: ["Fiction", "Classic"],
  availableCopies: 3,
  totalCopies: 3
}
```

2. Insert multiple books at once:
```javascript
[
  {
    title: "To Kill a Mockingbird",
    author: "Harper Lee",
    isbn: "978-0-06-112008-4",
    publicationYear: 1960,
    genre: ["Fiction", "Classic"],
    availableCopies: 2,
    totalCopies: 2
  },
  {
    title: "1984",
    author: "George Orwell",
    isbn: "978-0-452-28423-4",
    publicationYear: 1949,
    genre: ["Fiction", "Dystopian", "Classic"],
    availableCopies: 4,
    totalCopies: 4
  },
  {
    title: "Clean Code",
    author: "Robert C. Martin",
    isbn: "978-0-13-235088-4",
    publicationYear: 2008,
    genre: ["Technology", "Programming"],
    availableCopies: 5,
    totalCopies: 5
  },
  {
    title: "The Pragmatic Programmer",
    author: "Andrew Hunt",
    isbn: "978-0-13-595705-9",
    publicationYear: 2019,
    genre: ["Technology", "Programming"],
    availableCopies: 3,
    totalCopies: 3
  }
]
```

3. Insert at least 5 member documents with:
   - name
   - email (unique)
   - phone
   - membershipDate
   - active status

**Your Solution**:
```javascript
// Write your insert commands here
```

---

## Exercise 3: Find Operations

**Objective**: Practice various query patterns.

**Tasks**:

1. Find all books
2. Find all books published after 1950
3. Find books in the "Classic" genre
4. Find books with more than 2 available copies
5. Find the book with ISBN "978-0-452-28423-4"
6. Find all "Technology" books published after 2000
7. Find books where title contains "The"
8. Find all active members

**Your Solution**:
```javascript
// Write your find queries here
```

---

## Exercise 4: Projections

**Objective**: Practice selecting specific fields.

**Tasks**:

1. Find all books but return only title and author
2. Find all books excluding the _id field
3. Find members showing only name and email
4. Find all books showing title, author, and availableCopies only

**Your Solution**:
```javascript
// Write your projection queries here
```

---

## Exercise 5: Update Operations

**Objective**: Practice updating documents.

**Tasks**:

1. Update "The Great Gatsby" to decrease availableCopies by 1 (book was loaned)
2. Update all books published before 1950 to add a tag "vintage" to their genre array
3. Update the member with email "john@example.com" to set active to false
4. Add a field "lastLoanDate" to "Clean Code" with today's date
5. Increment availableCopies by 1 for "1984" (book was returned)
6. Update all "Programming" books to increase totalCopies by 2

**Your Solution**:
```javascript
// Write your update commands here
```

---

## Exercise 6: Array Operations

**Objective**: Practice working with arrays in documents.

**Tasks**:

1. Add "Science Fiction" to the genre array of "1984"
2. Remove "Classic" from the genre array of "The Great Gatsby"
3. Add a "reviews" array to one book with at least 2 review objects:
```javascript
{
  reviewer: "Alice Johnson",
  rating: 5,
  comment: "Excellent book!",
  date: new Date()
}
```

4. Add a new review to the reviews array
5. Remove a specific review from the array

**Your Solution**:
```javascript
// Write your array operation commands here
```

---

## Exercise 7: Delete Operations

**Objective**: Practice deleting documents.

**Tasks**:

1. Delete one book by ISBN
2. Delete all books with 0 available copies
3. Delete all inactive members
4. Delete all books published before 1930

**Your Solution**:
```javascript
// Write your delete commands here
```

---

## Exercise 8: Sorting and Limiting

**Objective**: Practice result ordering and pagination.

**Tasks**:

1. Find all books sorted by publication year (oldest first)
2. Find all books sorted by title (A-Z)
3. Find the 3 newest books
4. Find the 5 oldest books
5. Find books sorted by availableCopies (highest first), limited to 3
6. Implement pagination: Get the second page of results (10 per page) for all books

**Your Solution**:
```javascript
// Write your sorting and limiting queries here
```

---

## Exercise 9: Query Operators

**Objective**: Practice advanced query operators.

**Tasks**:

1. Find books where availableCopies is between 2 and 5
2. Find books published in 1949, 1960, or 1925 (use $in)
3. Find books that are NOT in the "Classic" genre
4. Find books where the genre array contains both "Fiction" AND "Classic"
5. Find books where the author field exists
6. Find all members where phone field does not exist
7. Find books with exactly 2 genres

**Your Solution**:
```javascript
// Write your queries with operators here
```

---

## Exercise 10: Aggregation Basics

**Objective**: Introduction to aggregation pipeline.

**Tasks**:

1. Count the total number of books
2. Group books by genre and count how many books in each
3. Calculate the average publication year of all books
4. Find the book with the maximum totalCopies
5. Calculate the total of all availableCopies across all books

**Your Solution**:
```javascript
// Write your aggregation queries here
```

---

## Exercise 11: Advanced Aggregation

**Objective**: Practice complex aggregation pipelines.

**Tasks**:

Create loan documents first:
```javascript
db.loans.insertMany([
  {
    bookId: ObjectId("..."),  // Use actual book _id
    memberId: ObjectId("..."), // Use actual member _id
    loanDate: ISODate("2024-01-15"),
    dueDate: ISODate("2024-02-15"),
    returnDate: null,
    status: "active"
  }
  // Add more loan documents
]);
```

Now create aggregations:

1. Group loans by status and count each
2. Find the total number of active loans per book
3. Calculate the average number of days books are loaned (for returned books)
4. Find the top 3 members with the most loans
5. Create a report showing:
   - Book title
   - Total times loaned
   - Average loan duration
   - Currently on loan (yes/no)

**Your Solution**:
```javascript
// Write your advanced aggregation pipelines here
```

---

## Exercise 12: Indexes

**Objective**: Practice creating and using indexes.

**Tasks**:

1. Create an index on the `isbn` field (unique)
2. Create an index on `author` field
3. Create a compound index on (`publicationYear`, `genre`)
4. Create a text index on `title` field
5. List all indexes on the books collection
6. Use explain() to analyze a query performance before and after indexing
7. Drop the index on author

**Your Solution**:
```javascript
// Write your index commands here
```

---

## Exercise 13: Text Search

**Objective**: Practice full-text search.

**Tasks**:

1. Create a text index on book title and author:
```javascript
db.books.createIndex({ title: "text", author: "text" });
```

2. Search for books containing "code"
3. Search for books containing "Gatsby" or "Orwell"
4. Search for the exact phrase "Clean Code"
5. Sort text search results by text score (relevance)

**Your Solution**:
```javascript
// Write your text search queries here
```

---

## Exercise 14: Embedded Documents

**Objective**: Practice working with nested documents.

**Tasks**:

1. Add an embedded address document to a member:
```javascript
{
  street: "123 Main St",
  city: "Boston",
  state: "MA",
  zipCode: "02101"
}
```

2. Query members by city
3. Update a member's zip code
4. Find members where the state is "MA"
5. Add an embedded "ratings" object to each book:
```javascript
{
  average: 4.5,
  count: 120,
  distribution: {
    "5": 80,
    "4": 30,
    "3": 8,
    "2": 1,
    "1": 1
  }
}
```

6. Find books with average rating above 4.0
7. Update the rating count for a specific book

**Your Solution**:
```javascript
// Write your embedded document operations here
```

---

## Exercise 15: Lookup (Joins)

**Objective**: Practice joining collections.

**Tasks**:

1. Create an aggregation that joins loans with books to show:
   - Loan details
   - Full book information

2. Create an aggregation that joins loans with members to show:
   - Member name
   - Books they have borrowed
   - Loan status

3. Create a comprehensive report joining all three collections:
   - Member name
   - Book title
   - Loan date
   - Due date
   - Status

**Your Solution**:
```javascript
// Example structure
db.loans.aggregate([
  {
    $lookup: {
      from: "books",
      localField: "bookId",
      foreignField: "_id",
      as: "bookDetails"
    }
  },
  // Add more stages
]);
```

---

## Exercise 16: Schema Validation

**Objective**: Add validation rules to ensure data quality.

**Tasks**:

1. Add validation to the `books` collection:
   - title: required string
   - author: required string
   - isbn: required string matching ISBN pattern
   - publicationYear: required integer between 1000 and current year
   - genre: required array with at least one element
   - availableCopies: required integer >= 0
   - totalCopies: required integer >= availableCopies

2. Add validation to the `members` collection:
   - name: required string
   - email: required string matching email pattern
   - membershipDate: required date
   - active: required boolean

3. Test the validation by trying to insert invalid documents

**Your Solution**:
```javascript
// Write your validation schema here
// Use db.runCommand({ collMod: "books", validator: {...} })
```

---

## Exercise 17: Transactions

**Objective**: Practice multi-document ACID transactions.

**Tasks**:

Create a transaction that:
1. Inserts a new loan document
2. Decreases the availableCopies of the borrowed book by 1
3. Adds the loan ID to a "currentLoans" array in the member document

If any operation fails, the entire transaction should roll back.

**Your Solution**:
```javascript
// Write your transaction code here
const session = db.getMongo().startSession();
// ... transaction code
```

---

## Exercise 18: Data Modeling Challenge

**Objective**: Design a schema for a real-world scenario.

**Scenario**: An e-commerce platform needs to store:
- Products (with categories, variants, pricing, inventory)
- Customers (with addresses, payment methods, preferences)
- Orders (with line items, shipping, payment)
- Reviews (product reviews with ratings, comments, helpful votes)

**Tasks**:

1. Design the schema deciding when to embed vs reference
2. Create sample documents for each collection
3. Write queries for common operations:
   - Find all orders for a customer
   - Get product details with reviews
   - Update inventory after an order
   - Calculate total revenue by category

**Your Solution**:
```javascript
// Design your schema and write example documents
```

**Justification**: Explain your embedding vs referencing decisions.

---

## Exercise 19: Performance Optimization

**Objective**: Analyze and optimize query performance.

**Tasks**:

1. Run this query and analyze with explain():
```javascript
db.books.find({ genre: "Fiction", publicationYear: { $gte: 1950 } });
```

2. Create an appropriate index to optimize the query
3. Run explain() again and compare the execution stats
4. Find queries that could benefit from covered queries (projection + index)
5. Identify a slow query and optimize it with proper indexing

**Metrics to compare**:
- executionTimeMillis
- totalDocsExamined
- totalKeysExamined
- executionStages

**Your Solution**:
```javascript
// Write your optimization steps and analysis here
```

---

## Exercise 20: Real-World Application

**Objective**: Build a complete mini-application.

**Scenario**: Create a simple blog system.

**Requirements**:

1. **Collections**:
   - users (authors and readers)
   - posts (blog posts with embedded comments)
   - tags

2. **Implement these features**:
   - Create a new blog post
   - Add comments to a post (embedded)
   - Tag posts with multiple tags
   - Find all posts by an author
   - Find all posts with a specific tag
   - Get the 10 most recent posts
   - Calculate comment count per post
   - Find top 5 most commented posts
   - Implement post pagination
   - Search posts by title or content

3. **Add**:
   - Indexes for common queries
   - Validation rules
   - A transaction for creating a post and updating user's post count

**Your Solution**:
```javascript
// Write your complete blog system implementation here
// Include all collections, indexes, queries, and operations
```

---

## Bonus Challenge: Time-Series Data

**Objective**: Work with time-series collections (MongoDB 5.0+).

**Scenario**: Store sensor data from IoT devices.

**Tasks**:

1. Create a time-series collection:
```javascript
db.createCollection("sensor_data", {
  timeseries: {
    timeField: "timestamp",
    metaField: "sensorId",
    granularity: "minutes"
  }
});
```

2. Insert sensor readings
3. Query data for a specific time range
4. Calculate average temperature per hour
5. Find maximum reading for each sensor

**Your Solution**:
```javascript
// Write your time-series operations here
```

---

## Solutions Note

Work through these exercises using the MongoDB shell (mongosh) or MongoDB Compass. Test your solutions and compare them with classmates. Multiple approaches are often valid - focus on understanding the concepts and trade-offs.

**Hints**:
- Use `.pretty()` to format output: `db.books.find().pretty()`
- Use `.explain("executionStats")` to analyze performance
- MongoDB documentation is your friend: [docs.mongodb.com](https://docs.mongodb.com)
- Practice with MongoDB Atlas free tier for cloud experience

---

**Estimated Time**: 4-6 hours for all exercises  
**Difficulty Progression**: Beginner → Intermediate → Advanced  
**Prerequisites**: MongoDB installed and running, or MongoDB Atlas account  

**Last Updated**: March 1, 2026  
**Course**: USJ IT Class 2026  
**Module**: MongoDB Exercises
