import os
from cassandra.cluster import Cluster
from cassandra.auth import PlainTextAuthProvider
from cassandra.policies import DCAwareRoundRobinPolicy

CONTACT_POINTS = os.environ.get("CASS_HOSTS", "127.0.0.1").split(",")
PORT           = int(os.environ.get("CASS_PORT", 9042))
USERNAME       = os.environ.get("CASS_USER", "cassandra")
PASSWORD       = os.environ.get("CASS_PASSWORD", "cassandra")
KEYSPACE       = os.environ.get("CASS_KEYSPACE", "test_keyspace")


def main():
    auth_provider = PlainTextAuthProvider(username=USERNAME, password=PASSWORD)

    cluster = Cluster(
        contact_points=CONTACT_POINTS,
        port=PORT,
        auth_provider=auth_provider,
        load_balancing_policy=DCAwareRoundRobinPolicy(local_dc="datacenter1"),
        protocol_version=4,
    )

    session = cluster.connect()
    print("Connected to Cassandra cluster:", cluster.metadata.cluster_name)

    # Create keyspace if it does not exist
    session.execute(f"""
        CREATE KEYSPACE IF NOT EXISTS {KEYSPACE}
        WITH replication = {{'class': 'SimpleStrategy', 'replication_factor': 1}};
    """)
    session.set_keyspace(KEYSPACE)

    # Create a table
    session.execute("""
        CREATE TABLE IF NOT EXISTS students (
            id    UUID PRIMARY KEY,
            name  TEXT,
            grade INT
        );
    """)

    # Insert a row using a prepared statement (recommended for repeated inserts)
    insert_stmt = session.prepare("""
        INSERT INTO students (id, name, grade) VALUES (uuid(), ?, ?)
    """)
    session.execute(insert_stmt, ("Alice", 9))
    print("Inserted student Alice")

    # Query rows
    rows = session.execute("SELECT id, name, grade FROM students;")
    for row in rows:
        print(f"  id={row.id}  name={row.name}  grade={row.grade}")

    cluster.shutdown()


if __name__ == "__main__":
    main()
