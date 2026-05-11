import redis.clients.jedis.*;
import redis.clients.jedis.exceptions.JedisConnectionException;

import java.util.Map;
import java.util.Set;

public class RedisExample {

    private static final String HOST     = System.getenv().getOrDefault("REDIS_HOST",     "localhost");
    private static final int    PORT     = Integer.parseInt(System.getenv().getOrDefault("REDIS_PORT", "6379"));
    private static final String PASSWORD = System.getenv("REDIS_PASSWORD"); // null if not set
    private static final int    DB       = Integer.parseInt(System.getenv().getOrDefault("REDIS_DB", "0"));

    public static void main(String[] args) {
        JedisPoolConfig poolConfig = new JedisPoolConfig();
        poolConfig.setMaxTotal(10);
        poolConfig.setMaxIdle(5);
        poolConfig.setTestOnBorrow(true);

        JedisPool pool;
        if (PASSWORD != null && !PASSWORD.isEmpty()) {
            pool = new JedisPool(poolConfig, HOST, PORT, 5000, PASSWORD, DB);
        } else {
            pool = new JedisPool(poolConfig, HOST, PORT, 5000, null, DB);
        }

        try (Jedis jedis = pool.getResource()) {
            jedis.ping();
            System.out.println("Connected to Redis!");

            // --- Strings ---
            jedis.set("student:1:name", "Alice");
            jedis.set("student:1:grade", "9");
            jedis.expire("student:1:name", 300);
            System.out.println("String: " + jedis.get("student:1:name"));

            // --- Counter ---
            jedis.set("visits", "0");
            jedis.incr("visits");
            jedis.incr("visits");
            System.out.println("Visit count: " + jedis.get("visits"));

            // --- Hash ---
            jedis.hset("student:2", Map.of(
                "name",  "Bob",
                "grade", "10",
                "email", "bob@school.edu"
            ));
            Map<String, String> student = jedis.hgetAll("student:2");
            System.out.println("Hash: " + student);

            // --- List ---
            jedis.rpush("queue:homework", "Math", "Physics", "History");
            System.out.println("Queue length: " + jedis.llen("queue:homework"));
            System.out.println("Dequeued: " + jedis.lpop("queue:homework"));

            // --- Set ---
            jedis.sadd("subjects:alice", "Math", "Physics", "Chemistry");
            jedis.sadd("subjects:bob",   "Math", "History");
            Set<String> common = jedis.sinter("subjects:alice", "subjects:bob");
            System.out.println("Common subjects: " + common);

            // --- Sorted set (leaderboard) ---
            jedis.zadd("leaderboard", Map.of("Alice", 980.0, "Bob", 870.0, "Carol", 1020.0));
            System.out.println("Top 3:");
            jedis.zrevrangeWithScores("leaderboard", 0, 2)
                 .forEach(t -> System.out.printf("  %s: %.0f%n", t.getElement(), t.getScore()));

            // Clean up
            jedis.del("student:1:name", "student:1:grade", "student:2",
                      "queue:homework", "subjects:alice", "subjects:bob",
                      "leaderboard", "visits");

        } catch (JedisConnectionException e) {
            System.err.println("Connection failed: " + e.getMessage());
        } finally {
            pool.close();
        }
    }
}
