import java.sql.*;
import java.util.Properties;

public class PostgreSQLExample {

    // Read from environment variables — never hardcode passwords in source code
    private static final String HOST     = System.getenv().getOrDefault("PG_HOST", "localhost");
    private static final String PORT     = System.getenv().getOrDefault("PG_PORT", "5432");
    private static final String DATABASE = System.getenv().getOrDefault("PG_DATABASE", "postgres");
    private static final String USER     = System.getenv().getOrDefault("PG_USER", "postgres");
    private static final String PASSWORD = System.getenv().getOrDefault("PG_PASSWORD", "");

    private static final String URL =
        String.format("jdbc:postgresql://%s:%s/%s", HOST, PORT, DATABASE);

    public static void main(String[] args) {
        Properties props = new Properties();
        props.setProperty("user", USER);
        props.setProperty("password", PASSWORD);
        props.setProperty("sslmode", "prefer");
        props.setProperty("connectTimeout", "10");

        try (Connection conn = DriverManager.getConnection(URL, props)) {
            conn.setAutoCommit(false);

            System.out.println("Connected to PostgreSQL!");

            // Create table
            try (Statement stmt = conn.createStatement()) {
                stmt.execute("""
                    CREATE TABLE IF NOT EXISTS students (
                        id    SERIAL PRIMARY KEY,
                        name  VARCHAR(100) NOT NULL,
                        grade INTEGER
                    )
                """);
            }

            // Insert using a prepared statement (prevents SQL injection)
            String insertSql = "INSERT INTO students (name, grade) VALUES (?, ?) RETURNING id";
            try (PreparedStatement ps = conn.prepareStatement(insertSql)) {
                ps.setString(1, "Bob");
                ps.setInt(2, 10);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        System.out.println("Inserted student with id=" + rs.getInt(1));
                    }
                }
            }

            // Query all rows
            try (Statement stmt = conn.createStatement();
                 ResultSet rs = stmt.executeQuery("SELECT id, name, grade FROM students ORDER BY id")) {
                while (rs.next()) {
                    System.out.printf("id=%d  name=%-20s  grade=%d%n",
                        rs.getInt("id"), rs.getString("name"), rs.getInt("grade"));
                }
            }

            conn.commit();

        } catch (SQLException e) {
            System.err.println("Database error: " + e.getMessage());
            e.printStackTrace();
        }
    }
}
