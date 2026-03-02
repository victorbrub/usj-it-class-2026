import psycopg2
from psycopg2 import Error

def connect_to_azure_db():
    """
    Connect to Azure PostgreSQL database and execute queries
    """
    try:
        # Connection parameters - UPDATE THESE WITH YOUR DETAILS!
        connection = psycopg2.connect(
            host="pgtest-clb.postgres.database.azure.com",
            database="gameverse",
            user="postgres",
            password="Abc123**",
            port="5432",
            sslmode="require"
        )
        
        print("Successfully connected to Azure PostgreSQL!")
        print(f"PostgreSQL server version: {connection.get_dsn_parameters()['dbname']}")
        
        # Create a cursor to execute queries
        cursor = connection.cursor()
        
        # Query 1: Get total number of games
        print("\n" + "="*50)
        print("Query 1: Total Number of Games")
        print("="*50)
        cursor.execute("SELECT COUNT(*) FROM games;")
        total_games = cursor.fetchone()[0]
        print(f"Total games in database: {total_games}")
        
        # Query 2: Get top 5 highest-rated games
        print("\n" + "="*50)
        print("Query 2: Top 5 Highest-Rated Games")
        print("="*50)
        query = """
            SELECT title, release_date, metacritic_score 
            FROM games 
            WHERE metacritic_score IS NOT NULL
            ORDER BY metacritic_score DESC 
            LIMIT 5;
        """
        cursor.execute(query)
        games = cursor.fetchall()
        
        print(f"{'Title':<40} {'Release Date':<15} {'Score':<10}")
        print("-" * 65)
        for game in games:
            title, release_date, score = game
            print(f"{title:<40} {str(release_date):<15} {score:<10.2f}")
        
        # Query 3: Get games by genre
        print("\n" + "="*50)
        print("Query 3: Games by Genre")
        print("="*50)
        query = """
            SELECT g.name as genre, COUNT(ga.game_id) as game_count
            FROM genres g
            LEFT JOIN games ga ON g.genre_id = ga.genre_id
            GROUP BY g.name
            ORDER BY game_count DESC;
        """
        cursor.execute(query)
        genres = cursor.fetchall()
        
        print(f"{'Genre':<30} {'Number of Games':<15}")
        print("-" * 45)
        for genre, count in genres:
            print(f"{genre:<30} {count:<15}")
        
        # Query 4: Average game price
        print("\n" + "="*50)
        print("Query 4: Price Statistics")
        print("="*50)
        query = """
            SELECT 
                AVG(price) as avg_price,
                MIN(price) as min_price,
                MAX(price) as max_price
            FROM games
            WHERE price IS NOT NULL;
        """
        cursor.execute(query)
        avg, min_price, max_price = cursor.fetchone()
        
        print(f"Average game price: ${avg:.2f}")
        print(f"Cheapest game: ${min_price:.2f}")
        print(f"Most expensive game: ${max_price:.2f}")
        
        # Query 5: Your Custom Query (EXAMPLE - modify as needed)
        print("\n" + "="*50)
        print("Query 5: Your Custom Query")
        print("="*50)
        query = """
            -- Write your SQL query here!
            -- Example: Find all games released after 2020
            SELECT title, release_date, price 
            FROM games 
            WHERE release_date >= '2020-01-01'
            ORDER BY release_date DESC
            LIMIT 10;
        """
        cursor.execute(query)
        results = cursor.fetchall()
        
        print(f"{'Title':<40} {'Release Date':<15} {'Price':<10}")
        print("-" * 65)
        for title, release_date, price in results:
            print(f"{title:<40} {str(release_date):<15} ${price:<10.2f}")
        
        # Close cursor and connection
        cursor.close()
        connection.close()
        print("\nConnection closed successfully")
        
    except Error as e:
        print(f"Error connecting to Azure PostgreSQL: {e}")

if __name__ == "__main__":
    connect_to_azure_db()
