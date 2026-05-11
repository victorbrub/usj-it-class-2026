import os
from neo4j import GraphDatabase
from neo4j.exceptions import ServiceUnavailable, AuthError

URI      = os.environ.get("NEO4J_URI",      "bolt://localhost:7687")
USERNAME = os.environ.get("NEO4J_USER",     "neo4j")
PASSWORD = os.environ.get("NEO4J_PASSWORD", "neo4j")
DATABASE = os.environ.get("NEO4J_DATABASE", "neo4j")


def main():
    driver = GraphDatabase.driver(URI, auth=(USERNAME, PASSWORD))

    try:
        driver.verify_connectivity()
        print("Connected to Neo4j!")
    except (ServiceUnavailable, AuthError) as e:
        print(f"Connection failed: {e}")
        return

    with driver.session(database=DATABASE) as session:
        # Clear existing demo data
        session.run("MATCH (n:Student) DETACH DELETE n")

        # Create nodes
        session.run("""
            CREATE (:Student {name: 'Alice', grade: 9})
            CREATE (:Student {name: 'Bob',   grade: 10})
            CREATE (:Student {name: 'Carol', grade: 9})
        """)
        print("Created student nodes")

        # Create a relationship
        session.run("""
            MATCH (a:Student {name: 'Alice'}), (b:Student {name: 'Bob'})
            CREATE (a)-[:KNOWS {since: 2024}]->(b)
        """)
        print("Created KNOWS relationship")

        # Query all students
        result = session.run("MATCH (s:Student) RETURN s.name AS name, s.grade AS grade ORDER BY s.name")
        print("All students:")
        for record in result:
            print(f"  name={record['name']}  grade={record['grade']}")

        # Query relationships
        result = session.run("""
            MATCH (a:Student)-[r:KNOWS]->(b:Student)
            RETURN a.name AS from, b.name AS to, r.since AS since
        """)
        print("Relationships:")
        for record in result:
            print(f"  {record['from']} KNOWS {record['to']} (since {record['since']})")

        # Parameterized query (prevents injection)
        result = session.run(
            "MATCH (s:Student) WHERE s.grade = $grade RETURN s.name AS name",
            grade=9,
        )
        print("Grade 9 students:")
        for record in result:
            print(f"  {record['name']}")

    driver.close()


if __name__ == "__main__":
    main()
