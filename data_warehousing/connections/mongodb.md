# Author: Víctor Barceló

# Connecting to MongoDB

## Overview

MongoDB listens on port **27017** by default. Drivers connect using the MongoDB Wire Protocol over TCP. The connection is expressed as a **connection string URI**:

```
mongodb://[username:password@]host[:port][/database][?options]
```

---

## Prerequisites

### Python — pymongo

```bash
pip install pymongo
```

For DNS SRV connection strings (MongoDB Atlas), also install:

```bash
pip install "pymongo[srv]"
```

### Java — MongoDB Java Driver (Sync)

Add to `pom.xml` (Maven):

```xml
<dependency>
    <groupId>org.mongodb</groupId>
    <artifactId>mongodb-driver-sync</artifactId>
    <version>5.1.1</version>
</dependency>
```

Add to `build.gradle` (Gradle):

```groovy
implementation 'org.mongodb:mongodb-driver-sync:5.1.1'
```

### C++ — mongo-cxx-driver (mongocxx)

On Debian/Ubuntu, first install the C driver:

```bash
sudo apt install libmongoc-dev libbson-dev
```

Then build the C++ driver from source:

```bash
git clone https://github.com/mongodb/mongo-cxx-driver.git --branch r3.10.1
cd mongo-cxx-driver/build
cmake .. -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=/usr/local
make -j$(nproc) && sudo make install
```

---

## Python Example

See the full working script: [scripts/mongodb/mongodb_example.py](scripts/mongodb/mongodb_example.py)

### Run

```bash
export MONGO_PASSWORD="your_password"
python mongodb_example.py
```

---

## Java Example

```java
import com.mongodb.client.*;
import com.mongodb.client.model.*;
import com.mongodb.client.result.*;
import org.bson.Document;

import java.util.Arrays;
import java.util.List;

public class MongoDBExample {

    private static final String HOST     = System.getenv().getOrDefault("MONGO_HOST",     "localhost");
    private static final int    PORT     = Integer.parseInt(System.getenv().getOrDefault("MONGO_PORT", "27017"));
    private static final String USERNAME = System.getenv().getOrDefault("MONGO_USER",     "");
    private static final String PASSWORD = System.getenv().getOrDefault("MONGO_PASSWORD", "");
    private static final String DATABASE = System.getenv().getOrDefault("MONGO_DATABASE", "school");

    private static String buildUri() {
        if (!USERNAME.isEmpty() && !PASSWORD.isEmpty()) {
            return String.format("mongodb://%s:%s@%s:%d/%s", USERNAME, PASSWORD, HOST, PORT, DATABASE);
        }
        return String.format("mongodb://%s:%d", HOST, PORT);
    }

    public static void main(String[] args) {
        try (MongoClient client = MongoClients.create(buildUri())) {

            // Ping to verify connection
            client.getDatabase("admin").runCommand(new Document("ping", 1));
            System.out.println("Connected to MongoDB!");

            MongoDatabase db         = client.getDatabase(DATABASE);
            MongoCollection<Document> students = db.getCollection("students");

            // Insert one document
            Document alice = new Document("name", "Alice")
                .append("grade", 9)
                .append("subjects", Arrays.asList("Math", "Physics"));
            InsertOneResult insertResult = students.insertOne(alice);
            System.out.println("Inserted _id=" + insertResult.getInsertedId());

            // Insert many
            students.insertMany(List.of(
                new Document("name", "Bob")    .append("grade", 10).append("subjects", List.of("History")),
                new Document("name", "Charlie").append("grade", 11).append("subjects", List.of("Chemistry"))
            ));

            // Find all
            System.out.println("All students:");
            try (MongoCursor<Document> cursor = students.find().iterator()) {
                while (cursor.hasNext()) {
                    System.out.println("  " + cursor.next().toJson());
                }
            }

            // Find with filter
            System.out.println("Grade 10 students:");
            students.find(Filters.eq("grade", 10))
                    .forEach(d -> System.out.println("  " + d.getString("name")));

            // Update
            students.updateOne(Filters.eq("name", "Alice"), Updates.set("grade", 10));
            System.out.println("Updated Alice's grade");

            // Delete
            students.deleteOne(Filters.eq("name", "Charlie"));
            System.out.println("Deleted Charlie");

            // Clean up
            students.drop();
        }
    }
}
```

### Compile and Run

```bash
mvn compile exec:java -Dexec.mainClass="MongoDBExample"
# Or with assembled jar:
MONGO_PASSWORD=your_password java -jar target/app.jar
```

---

## C++ Example

See the full working script: [scripts/mongodb/mongodb_example.cpp](scripts/mongodb/mongodb_example.cpp)

### Compile and Run

```bash
g++ -std=c++17 -o mongodb_example mongodb_example.cpp \
    $(pkg-config --cflags --libs libmongocxx)
export MONGO_PASSWORD="your_password"
./mongodb_example
```

---

## Common Issues

| Problem | Likely Cause | Fix |
|---------|-------------|-----|
| `ServerSelectionTimeoutError` | MongoDB not running or wrong host | `sudo systemctl start mongod`; check host |
| `Authentication failed` | Wrong credentials | Verify `MONGO_USER` and `MONGO_PASSWORD`; check `mongosh` manually |
| `Connection refused on 27017` | Firewall or mongod not listening | Check `mongod.conf` bindIp setting; open port if needed |
| `NamespaceNotFound` | Collection or DB does not exist yet | MongoDB creates both lazily on first write — this is normal |
| `MongoNetworkError` | Network interruption | Implement retry logic; use `MongoClient` connection pool |
| C++ link error: `undefined reference` | Missing linker flags | Use `pkg-config --libs libmongocxx` to get the correct flags |
