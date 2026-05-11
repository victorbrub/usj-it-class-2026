import os
import psycopg2
from psycopg2 import sql, OperationalError

# Load credentials from environment variables — never hardcode passwords
HOST     = os.environ.get("PG_HOST", "localhost")
PORT     = int(os.environ.get("PG_PORT", 5432))
DATABASE = os.environ.get("PG_DATABASE", "postgres")
USER     = os.environ.get("PG_USER", "postgres")
PASSWORD = os.environ.get("PG_PASSWORD", "")

def connect():
    try:
        conn = psycopg2.connect(
            host=HOST,
            port=PORT,
            dbname=DATABASE,
            user=USER,
            password=PASSWORD,
            connect_timeout=10,
            sslmode="prefer",           # upgrade to SSL when the server supports it
        )
        conn.autocommit = False         # use explicit transactions
        return conn
    except OperationalError as e:
        print(f"Connection failed: {e}")
        raise


def main():
    conn = connect()
    try:
        with conn.cursor() as cur:
            # Read server version
            cur.execute("SELECT version();")
            row = cur.fetchone()
            print("Connected to:", row[0])

            # Create a table
            cur.execute("""
                CREATE TABLE IF NOT EXISTS students (
                    id      SERIAL PRIMARY KEY,
                    name    VARCHAR(100) NOT NULL,
                    grade   INTEGER
                );
            """)

            # Insert a row using parameterized query (prevents SQL injection)
            cur.execute(
                "INSERT INTO students (name, grade) VALUES (%s, %s) RETURNING id;",
                ("Alice", 9),
            )
            new_id = cur.fetchone()[0]
            print(f"Inserted student with id={new_id}")

            # Query rows
            cur.execute("SELECT id, name, grade FROM students ORDER BY id;")
            for record in cur.fetchall():
                print(record)

        conn.commit()
    except Exception as e:
        conn.rollback()
        print(f"Error: {e}")
        raise
    finally:
        conn.close()


if __name__ == "__main__":
    main()
