#include <iostream>
#include <string>
#include <cstdlib>

#include <mongocxx/client.hpp>
#include <mongocxx/instance.hpp>
#include <mongocxx/uri.hpp>
#include <bsoncxx/builder/stream/document.hpp>
#include <bsoncxx/json.hpp>

using bsoncxx::builder::stream::document;
using bsoncxx::builder::stream::finalize;
using bsoncxx::builder::stream::open_array;
using bsoncxx::builder::stream::close_array;

static std::string get_env(const char* name, const char* def) {
    const char* v = std::getenv(name);
    return v ? v : def;
}

static std::string build_uri(const std::string& user, const std::string& pass,
                              const std::string& host, const std::string& port,
                              const std::string& db) {
    if (!user.empty() && !pass.empty()) {
        return "mongodb://" + user + ":" + pass + "@" + host + ":" + port + "/" + db;
    }
    return "mongodb://" + host + ":" + port;
}

int main() {
    const std::string host     = get_env("MONGO_HOST",     "localhost");
    const std::string port     = get_env("MONGO_PORT",     "27017");
    const std::string username = get_env("MONGO_USER",     "");
    const std::string password = get_env("MONGO_PASSWORD", "");
    const std::string db_name  = get_env("MONGO_DATABASE", "school");

    // Required: initialize the mongocxx driver exactly once
    mongocxx::instance instance{};

    mongocxx::uri uri{build_uri(username, password, host, port, db_name)};
    mongocxx::client client{uri};

    std::cout << "Connected to MongoDB!\n";

    auto db         = client[db_name];
    auto collection = db["students"];

    // Insert one document
    auto alice = document{}
        << "name"     << "Alice"
        << "grade"    << 9
        << "subjects" << open_array << "Math" << "Physics" << close_array
        << finalize;

    auto insert_result = collection.insert_one(alice.view());
    if (insert_result) {
        std::cout << "Inserted _id="
                  << insert_result->inserted_id().get_oid().value.to_string() << "\n";
    }

    // Query all documents
    std::cout << "All students:\n";
    auto cursor = collection.find({});
    for (const auto& doc : cursor) {
        std::cout << "  " << bsoncxx::to_json(doc) << "\n";
    }

    // Query with filter
    auto filter = document{} << "grade" << 9 << finalize;
    std::cout << "Grade 9 students:\n";
    for (const auto& doc : collection.find(filter.view())) {
        std::cout << "  " << doc["name"].get_string().value << "\n";
    }

    // Update
    auto update_filter = document{} << "name" << "Alice" << finalize;
    auto update        = document{} << "$set" << open_array
                                    << document{} << "grade" << 10 << finalize
                                    << close_array << finalize;
    collection.update_one(update_filter.view(), update.view());
    std::cout << "Updated Alice's grade\n";

    // Clean up
    collection.drop();
    return 0;
}
