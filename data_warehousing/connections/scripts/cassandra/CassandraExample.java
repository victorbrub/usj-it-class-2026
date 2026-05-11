import com.datastax.oss.driver.api.core.CqlSession;
import com.datastax.oss.driver.api.core.CqlSessionBuilder;
import com.datastax.oss.driver.api.core.cql.*;

import java.net.InetSocketAddress;
import java.util.Arrays;
import java.util.List;
import java.util.UUID;
import java.util.stream.Collectors;

public class CassandraExample {

    private static final String HOSTS    = System.getenv().getOrDefault("CASS_HOSTS", "127.0.0.1");
    private static final int    PORT     = Integer.parseInt(System.getenv().getOrDefault("CASS_PORT", "9042"));
    private static final String USERNAME = System.getenv().getOrDefault("CASS_USER", "cassandra");
    private static final String PASSWORD = System.getenv().getOrDefault("CASS_PASSWORD", "cassandra");
    private static final String KEYSPACE = System.getenv().getOrDefault("CASS_KEYSPACE", "test_keyspace");
    private static final String DC       = System.getenv().getOrDefault("CASS_DC", "datacenter1");

    public static void main(String[] args) {
        List<InetSocketAddress> contactPoints = Arrays.stream(HOSTS.split(","))
            .map(h -> new InetSocketAddress(h.trim(), PORT))
            .collect(Collectors.toList());

        CqlSessionBuilder builder = CqlSession.builder()
            .addContactPoints(contactPoints)
            .withLocalDatacenter(DC)
            .withAuthCredentials(USERNAME, PASSWORD);

        try (CqlSession session = builder.build()) {
            System.out.println("Connected to Cassandra cluster: "
                + session.getMetadata().getClusterName().orElse("unknown"));

            // Create keyspace
            session.execute(String.format("""
                CREATE KEYSPACE IF NOT EXISTS %s
                WITH replication = {'class':'SimpleStrategy','replication_factor':1}
                """, KEYSPACE));

            // Use the keyspace
            session.execute("USE " + KEYSPACE);

            // Create table
            session.execute("""
                CREATE TABLE IF NOT EXISTS students (
                    id    UUID PRIMARY KEY,
                    name  TEXT,
                    grade INT
                )
                """);

            // Prepared statement insert
            PreparedStatement insertStmt = session.prepare(
                "INSERT INTO students (id, name, grade) VALUES (?, ?, ?)");

            BoundStatement bound = insertStmt.bind(UUID.randomUUID(), "Bob", 10);
            session.execute(bound);
            System.out.println("Inserted student Bob");

            // Query
            ResultSet rs = session.execute("SELECT id, name, grade FROM students");
            for (Row row : rs) {
                System.out.printf("  id=%s  name=%-20s  grade=%d%n",
                    row.getUuid("id"), row.getString("name"), row.getInt("grade"));
            }
        }
    }
}
