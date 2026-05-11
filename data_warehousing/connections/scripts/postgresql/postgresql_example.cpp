#include <iostream>
#include <string>
#include <cstdlib>
#include <libpq-fe.h>

// Read connection parameters from environment variables
static std::string get_env(const char* name, const char* default_value) {
    const char* val = std::getenv(name);
    return val ? val : default_value;
}

int main() {
    const std::string host     = get_env("PG_HOST",     "localhost");
    const std::string port     = get_env("PG_PORT",     "5432");
    const std::string dbname   = get_env("PG_DATABASE", "postgres");
    const std::string user     = get_env("PG_USER",     "postgres");
    const std::string password = get_env("PG_PASSWORD", "");

    // Build connection string
    const std::string conninfo =
        "host="     + host     +
        " port="    + port     +
        " dbname="  + dbname   +
        " user="    + user     +
        " password="+ password +
        " sslmode=prefer";

    PGconn* conn = PQconnectdb(conninfo.c_str());

    if (PQstatus(conn) != CONNECTION_OK) {
        std::cerr << "Connection failed: " << PQerrorMessage(conn) << "\n";
        PQfinish(conn);
        return 1;
    }
    std::cout << "Connected to PostgreSQL!\n";

    // Create table
    PGresult* res = PQexec(conn,
        "CREATE TABLE IF NOT EXISTS students ("
        "    id    SERIAL PRIMARY KEY,"
        "    name  VARCHAR(100) NOT NULL,"
        "    grade INTEGER"
        ");");
    if (PQresultStatus(res) != PGRES_COMMAND_OK) {
        std::cerr << "CREATE TABLE failed: " << PQerrorMessage(conn) << "\n";
        PQclear(res);
        PQfinish(conn);
        return 1;
    }
    PQclear(res);

    // Insert using parameterized query (prevents SQL injection)
    const char* params[2] = {"Charlie", "11"};
    res = PQexecParams(conn,
        "INSERT INTO students (name, grade) VALUES ($1, $2) RETURNING id",
        2,       // number of parameters
        nullptr, // parameter types (let PostgreSQL infer)
        params,
        nullptr, // parameter lengths (text format: not needed)
        nullptr, // parameter formats (0 = text)
        0        // result format (0 = text)
    );
    if (PQresultStatus(res) != PGRES_TUPLES_OK) {
        std::cerr << "INSERT failed: " << PQerrorMessage(conn) << "\n";
        PQclear(res);
        PQfinish(conn);
        return 1;
    }
    std::cout << "Inserted student with id=" << PQgetvalue(res, 0, 0) << "\n";
    PQclear(res);

    // Query rows
    res = PQexec(conn, "SELECT id, name, grade FROM students ORDER BY id;");
    if (PQresultStatus(res) != PGRES_TUPLES_OK) {
        std::cerr << "SELECT failed: " << PQerrorMessage(conn) << "\n";
        PQclear(res);
        PQfinish(conn);
        return 1;
    }
    int nrows = PQntuples(res);
    for (int i = 0; i < nrows; i++) {
        std::cout << "id=" << PQgetvalue(res, i, 0)
                  << "  name=" << PQgetvalue(res, i, 1)
                  << "  grade=" << PQgetvalue(res, i, 2) << "\n";
    }
    PQclear(res);

    PQfinish(conn);
    return 0;
}
