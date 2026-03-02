import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.ResultSet;
import java.sql.Statement;
import java.sql.SQLException;

public class AzureDBQuery {
    
    // UPDATE THESE WITH YOUR DETAILS!
    private static final String HOST = "gameverse-<yourname>-db.postgres.database.azure.com";
    private static final String DATABASE = "gameverse";
    private static final String USER = "gameadmin";
    private static final String PASSWORD = "YOUR_PASSWORD_HERE";
    private static final String PORT = "5432";
    
    public static void main(String[] args) {
        
        String url = String.format(
            "jdbc:postgresql://%s:%s/%s?sslmode=require",
            HOST, PORT, DATABASE
        );
        
        Connection connection = null;
        
        try {
            // Load PostgreSQL JDBC driver
            Class.forName("org.postgresql.Driver");
            
            // Establish connection
            System.out.println("Connecting to Azure PostgreSQL...");
            connection = DriverManager.getConnection(url, USER, PASSWORD);
            System.out.println("Successfully connected to Azure PostgreSQL!");
            
            Statement statement = connection.createStatement();
            
            // Query 1: Total number of games
            System.out.println("\n" + "=".repeat(50));
            System.out.println("Query 1: Total Number of Games");
            System.out.println("=".repeat(50));
            
            ResultSet rs1 = statement.executeQuery("SELECT COUNT(*) FROM games;");
            if (rs1.next()) {
                System.out.println("Total games in database: " + rs1.getInt(1));
            }
            rs1.close();
            
            // Query 2: Top 5 highest-rated games
            System.out.println("\n" + "=".repeat(50));
            System.out.println("Query 2: Top 5 Highest-Rated Games");
            System.out.println("=".repeat(50));
            
            String query2 = """
                SELECT title, release_date, metacritic_score 
                FROM games 
                WHERE metacritic_score IS NOT NULL
                ORDER BY metacritic_score DESC 
                LIMIT 5;
            """;
            
            ResultSet rs2 = statement.executeQuery(query2);
            System.out.printf("%-40s %-15s %-10s%n", "Title", "Release Date", "Score");
            System.out.println("-".repeat(65));
            
            while (rs2.next()) {
                String title = rs2.getString("title");
                String releaseDate = rs2.getString("release_date");
                double score = rs2.getDouble("metacritic_score");
                System.out.printf("%-40s %-15s %-10.2f%n", title, releaseDate, score);
            }
            rs2.close();
            
            // Query 3: Games by genre
            System.out.println("\n" + "=".repeat(50));
            System.out.println("Query 3: Games by Genre");
            System.out.println("=".repeat(50));
            
            String query3 = """
                SELECT g.name as genre, COUNT(ga.game_id) as game_count
                FROM genres g
                LEFT JOIN games ga ON g.genre_id = ga.genre_id
                GROUP BY g.name
                ORDER BY game_count DESC;
            """;
            
            ResultSet rs3 = statement.executeQuery(query3);
            System.out.printf("%-30s %-15s%n", "Genre", "Number of Games");
            System.out.println("-".repeat(45));
            
            while (rs3.next()) {
                String genre = rs3.getString("genre");
                int count = rs3.getInt("game_count");
                System.out.printf("%-30s %-15d%n", genre, count);
            }
            rs3.close();
            
            // Query 4: Price statistics
            System.out.println("\n" + "=".repeat(50));
            System.out.println("Query 4: Price Statistics");
            System.out.println("=".repeat(50));
            
            String query4 = """
                SELECT 
                    AVG(price) as avg_price,
                    MIN(price) as min_price,
                    MAX(price) as max_price
                FROM games
                WHERE price IS NOT NULL;
            """;
            
            ResultSet rs4 = statement.executeQuery(query4);
            if (rs4.next()) {
                double avg = rs4.getDouble("avg_price");
                double min = rs4.getDouble("min_price");
                double max = rs4.getDouble("max_price");
                
                System.out.printf("Average game price: $%.2f%n", avg);
                System.out.printf("Cheapest game: $%.2f%n", min);
                System.out.printf("Most expensive game: $%.2f%n", max);
            }
            rs4.close();
            
            // Query 5: Your custom query (EXAMPLE - modify as needed)
            System.out.println("\n" + "=".repeat(50));
            System.out.println("Query 5: Your Custom Query");
            System.out.println("=".repeat(50));
            
            String query5 = """
                SELECT title, release_date, price 
                FROM games 
                WHERE release_date >= '2020-01-01'
                ORDER BY release_date DESC
                LIMIT 10;
            """;
            
            ResultSet rs5 = statement.executeQuery(query5);
            System.out.printf("%-40s %-15s %-10s%n", "Title", "Release Date", "Price");
            System.out.println("-".repeat(65));
            
            while (rs5.next()) {
                String title = rs5.getString("title");
                String releaseDate = rs5.getString("release_date");
                double price = rs5.getDouble("price");
                System.out.printf("%-40s %-15s $%-10.2f%n", title, releaseDate, price);
            }
            rs5.close();
            
            // Clean up
            statement.close();
            connection.close();
            System.out.println("\nConnection closed successfully");
            
        } catch (ClassNotFoundException e) {
            System.err.println("PostgreSQL JDBC Driver not found!");
            System.err.println("Make sure postgresql-XX.jar is in your classpath");
            e.printStackTrace();
        } catch (SQLException e) {
            System.err.println("Error connecting to Azure PostgreSQL!");
            e.printStackTrace();
        }
    }
}
