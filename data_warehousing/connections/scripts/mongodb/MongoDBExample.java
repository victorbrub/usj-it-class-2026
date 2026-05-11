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
