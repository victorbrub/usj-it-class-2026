#include <iostream>
#include <string>
#include <cstdlib>
#include <stdexcept>
#include <neo4j-client.h>

static std::string get_env(const char* name, const char* def) {
    const char* v = std::getenv(name);
    return v ? v : def;
}

// RAII wrapper for neo4j_connection_t
struct Connection {
    neo4j_connection_t* conn;
    explicit Connection(neo4j_connection_t* c) : conn(c) {
        if (!conn) throw std::runtime_error("Failed to connect to Neo4j");
    }
    ~Connection() { neo4j_close(conn); }
};

// Execute a Cypher statement and print result rows
static void run_query(neo4j_connection_t* conn, const std::string& query,
                      const std::string& label = "") {
    neo4j_result_stream_t* results = neo4j_run(conn, query.c_str(), neo4j_null);
    if (!results) {
        std::cerr << "Query failed: " << neo4j_strerror(errno, nullptr, 0) << "\n";
        return;
    }

    if (!label.empty()) {
        std::cout << label << "\n";
    }

    neo4j_result_t* result;
    while ((result = neo4j_fetch_next(results)) != nullptr) {
        unsigned int nfields = neo4j_nfields(results);
        for (unsigned int i = 0; i < nfields; i++) {
            char buf[256];
            neo4j_tostring(neo4j_result_field(result, i), buf, sizeof(buf));
            std::cout << "  " << neo4j_fieldname(results, i) << "=" << buf;
        }
        std::cout << "\n";
    }

    if (neo4j_check_failure(results) != 0) {
        std::cerr << "Stream error\n";
    }
    neo4j_close_results(results);
}

int main() {
    const std::string host     = get_env("NEO4J_HOST",     "localhost");
    const std::string username = get_env("NEO4J_USER",     "neo4j");
    const std::string password = get_env("NEO4J_PASSWORD", "neo4j");

    neo4j_client_init();

    // Build connection URL
    const std::string url = "bolt://" + username + ":" + password + "@" + host + ":7687";

    neo4j_connection_t* raw_conn = neo4j_connect(
        url.c_str(),
        nullptr,
        NEO4J_INSECURE   // omit TLS for local dev; use 0 for TLS in production
    );

    try {
        Connection conn(raw_conn);
        std::cout << "Connected to Neo4j!\n";

        // Clear demo data
        run_query(conn.conn, "MATCH (n:Student) DETACH DELETE n");

        // Create nodes
        run_query(conn.conn, "CREATE (:Student {name:'Alice', grade:9})");
        run_query(conn.conn, "CREATE (:Student {name:'Bob', grade:10})");
        std::cout << "Created student nodes\n";

        // Create relationship
        run_query(conn.conn,
            "MATCH (a:Student {name:'Alice'}), (b:Student {name:'Bob'}) "
            "CREATE (a)-[:KNOWS {since:2024}]->(b)");
        std::cout << "Created KNOWS relationship\n";

        // Query students
        run_query(conn.conn,
            "MATCH (s:Student) RETURN s.name AS name, s.grade AS grade ORDER BY s.name",
            "All students:");

    } catch (const std::exception& e) {
        std::cerr << "Error: " << e.what() << "\n";
        neo4j_client_cleanup();
        return 1;
    }

    neo4j_client_cleanup();
    return 0;
}
