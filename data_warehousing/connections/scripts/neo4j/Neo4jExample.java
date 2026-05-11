import org.neo4j.driver.*;
import org.neo4j.driver.exceptions.AuthenticationException;
import org.neo4j.driver.exceptions.ServiceUnavailableException;

import java.util.Map;

public class Neo4jExample {

    private static final String URI      = System.getenv().getOrDefault("NEO4J_URI",      "bolt://localhost:7687");
    private static final String USERNAME = System.getenv().getOrDefault("NEO4J_USER",     "neo4j");
    private static final String PASSWORD = System.getenv().getOrDefault("NEO4J_PASSWORD", "neo4j");
    private static final String DATABASE = System.getenv().getOrDefault("NEO4J_DATABASE", "neo4j");

    public static void main(String[] args) {
        AuthToken auth = AuthTokens.basic(USERNAME, PASSWORD);

        try (Driver driver = GraphDatabase.driver(URI, auth,
                Config.builder().withMaxConnectionLifetime(30, java.util.concurrent.TimeUnit.MINUTES).build())) {

            driver.verifyConnectivity();
            System.out.println("Connected to Neo4j!");

            try (Session session = driver.session(SessionConfig.forDatabase(DATABASE))) {

                // Clear demo data
                session.run("MATCH (n:Student) DETACH DELETE n");

                // Create nodes
                session.run("CREATE (:Student {name:'Alice', grade:9})");
                session.run("CREATE (:Student {name:'Bob',   grade:10})");
                System.out.println("Created student nodes");

                // Create relationship
                session.run("""
                    MATCH (a:Student {name:'Alice'}), (b:Student {name:'Bob'})
                    CREATE (a)-[:KNOWS {since:2024}]->(b)
                    """);
                System.out.println("Created KNOWS relationship");

                // Query all students
                System.out.println("All students:");
                Result result = session.run("MATCH (s:Student) RETURN s.name AS name, s.grade AS grade ORDER BY s.name");
                while (result.hasNext()) {
                    Record record = result.next();
                    System.out.printf("  name=%-20s grade=%d%n",
                        record.get("name").asString(), record.get("grade").asInt());
                }

                // Parameterized query
                System.out.println("Grade 9 students:");
                result = session.run(
                    "MATCH (s:Student) WHERE s.grade = $grade RETURN s.name AS name",
                    Map.of("grade", 9)
                );
                while (result.hasNext()) {
                    System.out.println("  " + result.next().get("name").asString());
                }
            }

        } catch (ServiceUnavailableException e) {
            System.err.println("Neo4j is unavailable: " + e.getMessage());
        } catch (AuthenticationException e) {
            System.err.println("Authentication failed: " + e.getMessage());
        }
    }
}
