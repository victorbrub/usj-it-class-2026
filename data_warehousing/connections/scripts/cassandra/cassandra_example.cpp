#include <cassandra.h>
#include <iostream>
#include <string>
#include <cstdlib>

static std::string get_env(const char* name, const char* def) {
    const char* v = std::getenv(name);
    return v ? v : def;
}

int main() {
    const std::string hosts    = get_env("CASS_HOSTS",    "127.0.0.1");
    const std::string username = get_env("CASS_USER",     "cassandra");
    const std::string password = get_env("CASS_PASSWORD", "cassandra");
    const std::string keyspace = get_env("CASS_KEYSPACE", "test_keyspace");

    // Build cluster configuration
    CassCluster* cluster = cass_cluster_new();
    CassSession* session = cass_session_new();

    cass_cluster_set_contact_points(cluster, hosts.c_str());
    cass_cluster_set_credentials(cluster, username.c_str(), password.c_str());
    cass_cluster_set_protocol_version(cluster, 4);

    // Connect
    CassFuture* connect_future = cass_session_connect(session, cluster);
    cass_future_wait(connect_future);

    if (cass_future_error_code(connect_future) != CASS_OK) {
        const char* msg;
        size_t msg_len;
        cass_future_error_message(connect_future, &msg, &msg_len);
        std::cerr << "Connection failed: " << std::string(msg, msg_len) << "\n";
        cass_future_free(connect_future);
        cass_session_free(session);
        cass_cluster_free(cluster);
        return 1;
    }
    cass_future_free(connect_future);
    std::cout << "Connected to Cassandra!\n";

    // Helper lambda to execute a simple statement and check for errors
    auto exec = [&](const std::string& query) -> bool {
        CassStatement* stmt = cass_statement_new(query.c_str(), 0);
        CassFuture* fut = cass_session_execute(session, stmt);
        cass_future_wait(fut);
        bool ok = (cass_future_error_code(fut) == CASS_OK);
        if (!ok) {
            const char* msg; size_t len;
            cass_future_error_message(fut, &msg, &len);
            std::cerr << "Query failed: " << std::string(msg, len) << "\n";
        }
        cass_future_free(fut);
        cass_statement_free(stmt);
        return ok;
    };

    // Create keyspace
    exec("CREATE KEYSPACE IF NOT EXISTS " + keyspace +
         " WITH replication = {'class':'SimpleStrategy','replication_factor':1}");

    // Create table
    exec("CREATE TABLE IF NOT EXISTS " + keyspace + ".students ("
         " id UUID PRIMARY KEY, name TEXT, grade INT)");

    // Insert using a prepared statement (prevents injection, more efficient)
    const std::string insert_cql =
        "INSERT INTO " + keyspace + ".students (id, name, grade) VALUES (uuid(), ?, ?)";

    CassFuture* prep_future = cass_session_prepare(session, insert_cql.c_str());
    cass_future_wait(prep_future);
    if (cass_future_error_code(prep_future) != CASS_OK) {
        std::cerr << "Prepare failed\n";
        cass_future_free(prep_future);
        cass_session_free(session);
        cass_cluster_free(cluster);
        return 1;
    }
    const CassPrepared* prepared = cass_future_get_prepared(prep_future);
    cass_future_free(prep_future);

    CassStatement* insert_stmt = cass_prepared_bind(prepared);
    cass_statement_bind_string_by_name(insert_stmt, "name",  "Charlie");
    cass_statement_bind_int32_by_name(insert_stmt, "grade", 11);
    CassFuture* insert_future = cass_session_execute(session, insert_stmt);
    cass_future_wait(insert_future);
    if (cass_future_error_code(insert_future) == CASS_OK) {
        std::cout << "Inserted student Charlie\n";
    }
    cass_future_free(insert_future);
    cass_statement_free(insert_stmt);
    cass_prepared_free(prepared);

    // Query rows
    const std::string select_cql =
        "SELECT id, name, grade FROM " + keyspace + ".students";
    CassStatement* sel_stmt = cass_statement_new(select_cql.c_str(), 0);
    CassFuture* sel_future = cass_session_execute(session, sel_stmt);
    cass_future_wait(sel_future);
    if (cass_future_error_code(sel_future) == CASS_OK) {
        const CassResult* result = cass_future_get_result(sel_future);
        CassIterator* iter = cass_iterator_from_result(result);
        while (cass_iterator_next(iter)) {
            const CassRow* row = cass_iterator_get_row(iter);
            const char* name; size_t name_len;
            cass_int32_t grade;
            cass_value_get_string(cass_row_get_column_by_name(row, "name"),  &name, &name_len);
            cass_value_get_int32(cass_row_get_column_by_name(row, "grade"), &grade);
            std::cout << "  name=" << std::string(name, name_len)
                      << "  grade=" << grade << "\n";
        }
        cass_iterator_free(iter);
        cass_result_free(result);
    }
    cass_future_free(sel_future);
    cass_statement_free(sel_stmt);

    // Disconnect
    CassFuture* close_future = cass_session_close(session);
    cass_future_wait(close_future);
    cass_future_free(close_future);
    cass_session_free(session);
    cass_cluster_free(cluster);
    return 0;
}
