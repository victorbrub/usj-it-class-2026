# MongoDB - Introduction and Guide

## What is MongoDB?

**MongoDB** is a document-oriented NoSQL database that stores data in flexible, JSON-like documents. It's one of the most popular NoSQL databases, designed for scalability, performance, and ease of development.

### Key Features

- **Document-based**: Data stored as BSON (Binary JSON) documents
- **Schema-flexible**: No rigid schema required
- **Scalable**: Horizontal scaling through sharding
- **High performance**: Indexing, aggregation, and caching
- **Rich query language**: Powerful queries and aggregations
- **ACID transactions**: Multi-document transactions supported
- **Replication**: Built-in replication for high availability

---

## MongoDB Architecture

### Documents

Documents are the basic unit of data in MongoDB, similar to rows in SQL:

```json
{
  "_id": ObjectId("507f1f77bcf86cd799439011"),
  "name": "Alice Johnson",
  "email": "alice@example.com",
  "age": 30,
  "address": {
    "street": "123 Main St",
    "city": "Boston",
    "state": "MA",
    "zip": "02101"
  },
  "interests": ["reading", "coding", "travel"],
  "registered": ISODate("2024-01-15T10:30:00Z")
}
```

### Collections

Collections are groups of documents, similar to tables in SQL:

```
Database: myapp
  ├─ Collection: users
  ├─ Collection: products
  ├─ Collection: orders
  └─ Collection: reviews
```

### Databases

A MongoDB server can host multiple databases, each with its own collections.

---

## BSON Data Types

MongoDB uses BSON (Binary JSON) with additional data types:

```javascript
{
  // String
  "name": "Alice",
  
  // Number
  "age": 30,
  "price": 99.99,
  
  // Boolean
  "active": true,
  
  // Array
  "tags": ["electronics", "computers"],
  
  // Object (embedded document)
  "address": {
    "city": "Boston",
    "state": "MA"
  },
  
  // Date
  "created": ISODate("2024-01-15"),
  
  // ObjectId (unique identifier)
  "_id": ObjectId("507f1f77bcf86cd799439011"),
  
  // Null
  "middleName": null,
  
  // Binary data
  "thumbnail": BinData(0, "base64encodeddata"),
  
  // Regular expression
  "pattern": /^[A-Z]/,
  
  // 32-bit integer
  "count": NumberInt(100),
  
  // 64-bit integer
  "bigCount": NumberLong(9223372036854775807),
  
  // Decimal128 (precise decimal)
  "exactPrice": NumberDecimal("99.99")
}
```

---

## CRUD Operations

### Create (Insert)

**Insert Single Document**:
```javascript
db.users.insertOne({
  name: "Alice Johnson",
  email: "alice@example.com",
  age: 30,
  registered: new Date()
});
```

**Insert Multiple Documents**:
```javascript
db.users.insertMany([
  {
    name: "Bob Smith",
    email: "bob@example.com",
    age: 25
  },
  {
    name: "Charlie Brown",
    email: "charlie@example.com",
    age: 35
  }
]);
```

### Read (Find)

**Find All Documents**:
```javascript
db.users.find();
```

**Find with Filter**:
```javascript
// Find users older than 25
db.users.find({ age: { $gt: 25 } });

// Find by exact match
db.users.find({ name: "Alice Johnson" });

// Find with multiple conditions
db.users.find({
  age: { $gte: 25, $lte: 35 },
  active: true
});
```

**Find One Document**:
```javascript
db.users.findOne({ email: "alice@example.com" });
```

**Projection (Select Specific Fields)**:
```javascript
// Include only name and email
db.users.find({}, { name: 1, email: 1 });

// Exclude _id
db.users.find({}, { name: 1, email: 1, _id: 0 });

// Exclude specific fields
db.users.find({}, { password: 0 });
```

### Update

**Update Single Document**:
```javascript
db.users.updateOne(
  { email: "alice@example.com" },
  { $set: { age: 31 } }
);
```

**Update Multiple Documents**:
```javascript
db.users.updateMany(
  { city: "Boston" },
  { $set: { state: "MA" } }
);
```

**Update Operators**:
```javascript
// Set field value
{ $set: { age: 31 } }

// Increment numeric field
{ $inc: { age: 1 } }

// Multiply numeric field
{ $mul: { price: 1.1 } }

// Rename field
{ $rename: { "name": "fullName" } }

// Remove field
{ $unset: { middleName: "" } }

// Set value if field doesn't exist
{ $setOnInsert: { created: new Date() } }

// Update current date
{ $currentDate: { lastModified: true } }
```

**Array Update Operators**:
```javascript
// Add to array
{ $push: { tags: "new-tag" } }

// Add multiple to array
{ $push: { tags: { $each: ["tag1", "tag2"] } } }

// Add to array if not exists
{ $addToSet: { tags: "unique-tag" } }

// Remove from array
{ $pull: { tags: "old-tag" } }

// Remove first/last element
{ $pop: { tags: 1 } }  // 1 = last, -1 = first
```

**Replace Entire Document**:
```javascript
db.users.replaceOne(
  { _id: ObjectId("...") },
  {
    name: "Alice Johnson",
    email: "alice.new@example.com",
    age: 31
  }
);
```

**Upsert (Update or Insert)**:
```javascript
db.users.updateOne(
  { email: "new@example.com" },
  { $set: { name: "New User", age: 25 } },
  { upsert: true }
);
```

### Delete

**Delete Single Document**:
```javascript
db.users.deleteOne({ email: "alice@example.com" });
```

**Delete Multiple Documents**:
```javascript
db.users.deleteMany({ age: { $lt: 18 } });
```

**Delete All Documents in Collection**:
```javascript
db.users.deleteMany({});
```

---

## Query Operators

### Comparison Operators

```javascript
// Equal
{ age: 30 }
{ age: { $eq: 30 } }

// Not equal
{ age: { $ne: 30 } }

// Greater than
{ age: { $gt: 25 } }

// Greater than or equal
{ age: { $gte: 25 } }

// Less than
{ age: { $lt: 40 } }

// Less than or equal
{ age: { $lte: 40 } }

// In array
{ status: { $in: ["active", "pending"] } }

// Not in array
{ status: { $nin: ["deleted", "banned"] } }
```

### Logical Operators

```javascript
// AND (implicit)
db.users.find({
  age: { $gte: 25 },
  city: "Boston"
});

// AND (explicit)
db.users.find({
  $and: [
    { age: { $gte: 25 } },
    { city: "Boston" }
  ]
});

// OR
db.users.find({
  $or: [
    { city: "Boston" },
    { city: "New York" }
  ]
});

// NOT
db.users.find({
  age: { $not: { $lt: 18 } }
});

// NOR (not or)
db.users.find({
  $nor: [
    { city: "Boston" },
    { age: { $lt: 18 } }
  ]
});
```

### Element Operators

```javascript
// Field exists
db.users.find({ phone: { $exists: true } });

// Field doesn't exist
db.users.find({ phone: { $exists: false } });

// Field type
db.users.find({ age: { $type: "number" } });
db.users.find({ age: { $type: 16 } });  // 16 = 32-bit integer
```

### Array Operators

```javascript
// Array contains element
db.products.find({ tags: "electronics" });

// Array contains all elements
db.products.find({
  tags: { $all: ["electronics", "sale"] }
});

// Array size
db.products.find({
  tags: { $size: 3 }
});

// Match array element
db.products.find({
  "reviews.rating": { $gte: 4 }
});

// $elemMatch (all conditions on same array element)
db.products.find({
  reviews: {
    $elemMatch: {
      rating: { $gte: 4 },
      user: "Alice"
    }
  }
});
```

### String Operators

```javascript
// Regular expression
db.users.find({ name: /^Alice/ });
db.users.find({ name: { $regex: /^Alice/, $options: "i" } });

// Text search (requires text index)
db.products.find({ $text: { $search: "laptop computer" } });
```

---

## Sorting, Limiting, and Skipping

```javascript
// Sort ascending (1) or descending (-1)
db.users.find().sort({ age: 1 });
db.users.find().sort({ age: -1, name: 1 });

// Limit results
db.users.find().limit(10);

// Skip results (pagination)
db.users.find().skip(20).limit(10);

// Count documents
db.users.countDocuments({ age: { $gte: 18 } });

// Chain methods
db.users
  .find({ city: "Boston" })
  .sort({ age: -1 })
  .limit(10)
  .skip(0);
```

---

## Indexes

Indexes improve query performance:

### Create Indexes

```javascript
// Single field index
db.users.createIndex({ email: 1 });  // 1 = ascending, -1 = descending

// Compound index
db.users.createIndex({ city: 1, age: -1 });

// Unique index
db.users.createIndex({ email: 1 }, { unique: true });

// Text index (for text search)
db.products.createIndex({ description: "text" });

// Multi-key index (on array fields)
db.products.createIndex({ tags: 1 });

// TTL index (auto-delete after time)
db.sessions.createIndex(
  { createdAt: 1 },
  { expireAfterSeconds: 3600 }
);

// Partial index (index subset of documents)
db.users.createIndex(
  { email: 1 },
  { partialFilterExpression: { active: true } }
);
```

### View Indexes

```javascript
// List all indexes
db.users.getIndexes();

// Get index stats
db.users.stats();
```

### Drop Indexes

```javascript
// Drop specific index
db.users.dropIndex("email_1");

// Drop all indexes except _id
db.users.dropIndexes();
```

---

## Aggregation Framework

Powerful data processing pipeline:

### Basic Aggregation

```javascript
db.orders.aggregate([
  // Stage 1: Filter documents
  { $match: { status: "completed" } },
  
  // Stage 2: Group and calculate
  { $group: {
      _id: "$customerId",
      totalSpent: { $sum: "$amount" },
      orderCount: { $sum: 1 },
      avgOrder: { $avg: "$amount" }
  }},
  
  // Stage 3: Sort results
  { $sort: { totalSpent: -1 } },
  
  // Stage 4: Limit results
  { $limit: 10 }
]);
```

### Aggregation Stages

```javascript
// $match - Filter documents
{ $match: { age: { $gte: 18 } } }

// $group - Group documents and accumulate
{ $group: {
    _id: "$category",
    count: { $sum: 1 },
    avgPrice: { $avg: "$price" }
}}

// $project - Reshape documents
{ $project: {
    name: 1,
    fullName: { $concat: ["$firstName", " ", "$lastName"] },
    ageGroup: {
      $cond: {
        if: { $gte: ["$age", 18] },
        then: "adult",
        else: "minor"
      }
    }
}}

// $sort - Sort documents
{ $sort: { age: -1, name: 1 } }

// $limit - Limit number of documents
{ $limit: 10 }

// $skip - Skip documents
{ $skip: 20 }

// $unwind - Deconstruct array field
{ $unwind: "$tags" }

// $lookup - Join with another collection
{ $lookup: {
    from: "products",
    localField: "productId",
    foreignField: "_id",
    as: "productDetails"
}}

// $addFields - Add new fields
{ $addFields: {
    totalPrice: { $multiply: ["$price", "$quantity"] }
}}

// $count - Count documents
{ $count: "total" }
```

### Accumulator Operators

```javascript
{ $group: {
    _id: "$category",
    
    // Sum
    total: { $sum: "$amount" },
    count: { $sum: 1 },
    
    // Average
    avgPrice: { $avg: "$price" },
    
    // Min/Max
    minPrice: { $min: "$price" },
    maxPrice: { $max: "$price" },
    
    // First/Last
    firstOrder: { $first: "$orderDate" },
    lastOrder: { $last: "$orderDate" },
    
    // Push (create array)
    products: { $push: "$productName" },
    
    // Add to set (unique array)
    uniqueTags: { $addToSet: "$tag" }
}}
```

### Example: Complex Aggregation

```javascript
// Find top 5 customers by spending in 2024
db.orders.aggregate([
  // Filter by date
  {
    $match: {
      orderDate: {
        $gte: ISODate("2024-01-01"),
        $lt: ISODate("2025-01-01")
      },
      status: "completed"
    }
  },
  
  // Lookup customer details
  {
    $lookup: {
      from: "customers",
      localField: "customerId",
      foreignField: "_id",
      as: "customer"
    }
  },
  
  // Unwind customer array
  { $unwind: "$customer" },
  
  // Group by customer
  {
    $group: {
      _id: "$customerId",
      customerName: { $first: "$customer.name" },
      totalOrders: { $sum: 1 },
      totalSpent: { $sum: "$amount" },
      avgOrderValue: { $avg: "$amount" }
    }
  },
  
  // Sort by total spent
  { $sort: { totalSpent: -1 } },
  
  // Top 5
  { $limit: 5 },
  
  // Format output
  {
    $project: {
      _id: 0,
      customerName: 1,
      totalOrders: 1,
      totalSpent: { $round: ["$totalSpent", 2] },
      avgOrderValue: { $round: ["$avgOrderValue", 2] }
    }
  }
]);
```

---

## Data Modeling

### Embedding vs Referencing

**Embedding (Denormalization)**:
```javascript
// User with embedded addresses
{
  _id: ObjectId("..."),
  name: "Alice",
  addresses: [
    { type: "home", street: "123 Main St", city: "Boston" },
    { type: "work", street: "456 Office Blvd", city: "Cambridge" }
  ]
}
```

**Referencing (Normalization)**:
```javascript
// User document
{
  _id: ObjectId("user123"),
  name: "Alice"
}

// Separate addresses collection
{
  _id: ObjectId("addr123"),
  userId: ObjectId("user123"),
  type: "home",
  street: "123 Main St",
  city: "Boston"
}
```

### When to Embed

- Data accessed together
- One-to-few relationships
- Data doesn't change often
- Need atomic updates
- Bounded arrays (won't grow indefinitely)

### When to Reference

- One-to-many or many-to-many
- Data accessed separately
- Data changes frequently
- Unbounded arrays
- Need to share data across documents
- Document size concerns (16MB limit)

---

## Transactions

MongoDB supports multi-document ACID transactions:

```javascript
const session = db.getMongo().startSession();
session.startTransaction();

try {
  const ordersCol = session.getDatabase("mydb").orders;
  const inventoryCol = session.getDatabase("mydb").inventory;
  
  // Insert order
  ordersCol.insertOne({
    customerId: "C123",
    productId: "P456",
    quantity: 5,
    amount: 99.99
  }, { session });
  
  // Update inventory
  inventoryCol.updateOne(
    { productId: "P456" },
    { $inc: { quantity: -5 } },
    { session }
  );
  
  // Commit transaction
  session.commitTransaction();
  
} catch (error) {
  // Rollback on error
  session.abortTransaction();
  throw error;
} finally {
  session.endSession();
}
```

---

## Best Practices

### 1. Schema Design

- Model for your query patterns
- Embed related data accessed together
- Limit embedded array growth
- Consider document size (16MB limit)
- Use references for many-to-many relationships

### 2. Indexing

- Index fields used in queries
- Create compound indexes for multiple fields
- Monitor index usage with explain()
- Remove unused indexes
- Use covered queries when possible

### 3. Performance

```javascript
// Use projection to limit returned fields
db.users.find({}, { name: 1, email: 1 });

// Use lean queries (if using Mongoose)
// Returns plain JavaScript objects instead of Mongoose documents

// Limit results
db.users.find().limit(100);

// Analyze query performance
db.users.find({ email: "test@example.com" }).explain("executionStats");
```

### 4. Security

```javascript
// Create user with specific role
db.createUser({
  user: "appUser",
  pwd: "securePassword",
  roles: [
    { role: "readWrite", db: "mydb" }
  ]
});

// Field-level encryption for sensitive data
// Use MongoDB Client-Side Field Level Encryption
```

### 5. Validation

```javascript
db.createCollection("users", {
  validator: {
    $jsonSchema: {
      bsonType: "object",
      required: ["name", "email", "age"],
      properties: {
        name: {
          bsonType: "string",
          description: "must be a string and is required"
        },
        email: {
          bsonType: "string",
          pattern: "^.+@.+$",
          description: "must be a valid email"
        },
        age: {
          bsonType: "int",
          minimum: 0,
          maximum: 150,
          description: "must be an integer between 0 and 150"
        }
      }
    }
  }
});
```

---

## MongoDB Atlas (Cloud)

MongoDB Atlas is the fully managed cloud database service:

### Features

- Automatic backups and recovery
- Global clusters and replication
- Built-in security
- Performance monitoring
- Serverless option
- Free tier available

### Connection

```javascript
const MongoClient = require('mongodb').MongoClient;
const uri = "mongodb+srv://<username>:<password>@cluster0.mongodb.net/mydb?retryWrites=true&w=majority";

const client = new MongoClient(uri);

async function run() {
  try {
    await client.connect();
    const database = client.db('mydb');
    const collection = database.collection('users');
    
    // Perform operations
    const result = await collection.findOne({ name: "Alice" });
    console.log(result);
  } finally {
    await client.close();
  }
}

run();
```

---

## Common Use Cases

1. **Content Management**: Flexible schema for varying content types
2. **E-commerce Catalogs**: Products with different attributes
3. **Real-time Analytics**: High write throughput
4. **Mobile Applications**: Offline sync, flexible data
5. **User Profiles**: Nested data structures
6. **IoT Applications**: Time-series data ingestion
7. **Gaming**: Player states, leaderboards
8. **Logs and Events**: High-volume write operations

---

## Tools and Ecosystem

- **MongoDB Compass**: GUI for MongoDB
- **MongoDB Shell**: mongosh command-line interface
- **Mongoose**: ODM for Node.js
- **PyMongo**: Python driver
- **Spring Data MongoDB**: Java integration
- **MongoDB Charts**: Data visualization

---

**Last Updated**: March 1, 2026  
**Course**: USJ IT Class 2026  
**Module**: MongoDB
