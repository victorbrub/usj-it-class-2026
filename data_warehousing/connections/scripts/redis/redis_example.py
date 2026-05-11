import os
import redis
from redis.exceptions import ConnectionError, AuthenticationError, ResponseError

HOST     = os.environ.get("REDIS_HOST",     "localhost")
PORT     = int(os.environ.get("REDIS_PORT", 6379))
PASSWORD = os.environ.get("REDIS_PASSWORD", None)   # None means no auth
DB       = int(os.environ.get("REDIS_DB",   0))


def main():
    client = redis.Redis(
        host=HOST,
        port=PORT,
        password=PASSWORD,
        db=DB,
        decode_responses=True,      # return strings instead of bytes
        socket_timeout=5,
        socket_connect_timeout=5,
    )

    try:
        client.ping()
        print("Connected to Redis!")
    except (ConnectionError, AuthenticationError) as e:
        print(f"Connection failed: {e}")
        return

    # --- Strings ---
    client.set("student:1:name", "Alice")
    client.set("student:1:grade", 9)
    client.expire("student:1:name", 300)            # TTL: 300 seconds

    print("String:", client.get("student:1:name"))

    # --- Increment counter ---
    client.set("visits", 0)
    client.incr("visits")
    client.incr("visits")
    print("Visit count:", client.get("visits"))

    # --- Hash (map) ---
    client.hset("student:2", mapping={
        "name":  "Bob",
        "grade": "10",
        "email": "bob@school.edu",
    })
    student = client.hgetall("student:2")
    print("Hash:", student)

    # --- List ---
    client.rpush("queue:homework", "Math", "Physics", "History")
    print("Queue length:", client.llen("queue:homework"))
    print("Dequeued:", client.lpop("queue:homework"))

    # --- Set ---
    client.sadd("subjects:alice", "Math", "Physics", "Chemistry")
    client.sadd("subjects:bob",   "Math", "History")
    common = client.sinter("subjects:alice", "subjects:bob")
    print("Common subjects:", common)

    # --- Sorted set (leaderboard) ---
    client.zadd("leaderboard", {"Alice": 980, "Bob": 870, "Carol": 1020})
    top3 = client.zrevrange("leaderboard", 0, 2, withscores=True)
    print("Top 3:")
    for name, score in top3:
        print(f"  {name}: {int(score)}")

    # Clean up keys
    client.delete("student:1:name", "student:1:grade", "student:2",
                  "queue:homework", "subjects:alice", "subjects:bob",
                  "leaderboard", "visits")
    client.close()


if __name__ == "__main__":
    main()
