import os
from pymongo import MongoClient
from pymongo.errors import ConnectionFailure, OperationFailure

HOST     = os.environ.get("MONGO_HOST",     "localhost")
PORT     = int(os.environ.get("MONGO_PORT", 27017))
USERNAME = os.environ.get("MONGO_USER",     "")
PASSWORD = os.environ.get("MONGO_PASSWORD", "")
DATABASE = os.environ.get("MONGO_DATABASE", "school")

def build_uri() -> str:
    if USERNAME and PASSWORD:
        return f"mongodb://{USERNAME}:{PASSWORD}@{HOST}:{PORT}/{DATABASE}"
    return f"mongodb://{HOST}:{PORT}/"


def main():
    client = MongoClient(
        build_uri(),
        serverSelectionTimeoutMS=5000,
        connectTimeoutMS=10000,
    )

    # Verify connection
    try:
        client.admin.command("ping")
        print("Connected to MongoDB!")
    except ConnectionFailure as e:
        print(f"Connection failed: {e}")
        return

    db = client[DATABASE]
    students = db["students"]

    # Insert a document
    result = students.insert_one({"name": "Alice", "grade": 9, "subjects": ["Math", "Physics"]})
    print(f"Inserted document with _id={result.inserted_id}")

    # Insert multiple documents
    students.insert_many([
        {"name": "Bob",     "grade": 10, "subjects": ["History", "Biology"]},
        {"name": "Charlie", "grade": 11, "subjects": ["Math", "Chemistry"]},
    ])

    # Query — find all documents
    print("All students:")
    for doc in students.find():
        print(f"  {doc}")

    # Query with filter
    print("Grade 10 students:")
    for doc in students.find({"grade": 10}):
        print(f"  {doc['name']}")

    # Update a document
    students.update_one({"name": "Alice"}, {"$set": {"grade": 10}})
    print("Updated Alice's grade to 10")

    # Delete a document
    students.delete_one({"name": "Charlie"})
    print("Deleted Charlie")

    # Drop the collection after the demo
    students.drop()
    client.close()


if __name__ == "__main__":
    main()
