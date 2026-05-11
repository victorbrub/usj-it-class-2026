#include <iostream>
#include <string>
#include <cstdlib>
#include <stdexcept>
#include <hiredis/hiredis.h>

static std::string get_env(const char* name, const char* def) {
    const char* v = std::getenv(name);
    return v ? v : def;
}

// RAII wrapper for redisContext
struct RedisConn {
    redisContext* ctx;

    RedisConn(const std::string& host, int port) {
        ctx = redisConnect(host.c_str(), port);
        if (!ctx || ctx->err) {
            std::string msg = ctx ? ctx->errstr : "allocation failed";
            if (ctx) redisFree(ctx);
            throw std::runtime_error("Connection failed: " + msg);
        }
    }
    ~RedisConn() { if (ctx) redisFree(ctx); }
};

// Execute a command and return the reply; throws on error
static redisReply* exec(redisContext* ctx, const char* fmt, ...) {
    va_list args;
    va_start(args, fmt);
    redisReply* reply = (redisReply*)redisvCommand(ctx, fmt, args);
    va_end(args);
    if (!reply) throw std::runtime_error("No reply from Redis");
    if (reply->type == REDIS_REPLY_ERROR) {
        std::string err = reply->str;
        freeReplyObject(reply);
        throw std::runtime_error("Redis error: " + err);
    }
    return reply;
}

int main() {
    const std::string host     = get_env("REDIS_HOST",     "localhost");
    const int         port     = std::stoi(get_env("REDIS_PORT", "6379"));
    const std::string password = get_env("REDIS_PASSWORD", "");

    try {
        RedisConn redis(host, port);
        std::cout << "Connected to Redis!\n";

        // Authenticate if password is set
        if (!password.empty()) {
            redisReply* r = exec(redis.ctx, "AUTH %s", password.c_str());
            freeReplyObject(r);
        }

        // --- String: SET and GET ---
        redisReply* r = exec(redis.ctx, "SET student:1:name Alice");
        freeReplyObject(r);

        r = exec(redis.ctx, "EXPIRE student:1:name 300");
        freeReplyObject(r);

        r = exec(redis.ctx, "GET student:1:name");
        std::cout << "String: " << (r->str ? r->str : "(nil)") << "\n";
        freeReplyObject(r);

        // --- Counter ---
        r = exec(redis.ctx, "SET visits 0");
        freeReplyObject(r);
        r = exec(redis.ctx, "INCR visits");
        freeReplyObject(r);
        r = exec(redis.ctx, "INCR visits");
        freeReplyObject(r);
        r = exec(redis.ctx, "GET visits");
        std::cout << "Visit count: " << r->str << "\n";
        freeReplyObject(r);

        // --- Hash ---
        r = exec(redis.ctx, "HSET student:2 name Bob grade 10 email bob@school.edu");
        freeReplyObject(r);
        r = exec(redis.ctx, "HGETALL student:2");
        std::cout << "Hash fields:\n";
        for (size_t i = 0; i + 1 < r->elements; i += 2) {
            std::cout << "  " << r->element[i]->str
                      << " = " << r->element[i + 1]->str << "\n";
        }
        freeReplyObject(r);

        // --- List ---
        r = exec(redis.ctx, "RPUSH queue:homework Math Physics History");
        freeReplyObject(r);
        r = exec(redis.ctx, "LLEN queue:homework");
        std::cout << "Queue length: " << r->integer << "\n";
        freeReplyObject(r);
        r = exec(redis.ctx, "LPOP queue:homework");
        std::cout << "Dequeued: " << (r->str ? r->str : "(nil)") << "\n";
        freeReplyObject(r);

        // --- Sorted set ---
        r = exec(redis.ctx, "ZADD leaderboard 980 Alice");
        freeReplyObject(r);
        r = exec(redis.ctx, "ZADD leaderboard 870 Bob");
        freeReplyObject(r);
        r = exec(redis.ctx, "ZADD leaderboard 1020 Carol");
        freeReplyObject(r);
        r = exec(redis.ctx, "ZREVRANGE leaderboard 0 2 WITHSCORES");
        std::cout << "Top 3:\n";
        for (size_t i = 0; i + 1 < r->elements; i += 2) {
            std::cout << "  " << r->element[i]->str
                      << ": " << r->element[i + 1]->str << "\n";
        }
        freeReplyObject(r);

        // Clean up
        r = exec(redis.ctx, "DEL student:1:name student:2 queue:homework leaderboard visits");
        freeReplyObject(r);

    } catch (const std::exception& e) {
        std::cerr << "Error: " << e.what() << "\n";
        return 1;
    }
    return 0;
}
