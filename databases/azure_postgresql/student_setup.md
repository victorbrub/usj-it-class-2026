# Exercise: Deploy and Connect to PostgreSQL in Azure

## Learning Objectives

By the end of this exercise, you will be able to:
- Create and manage an Azure for Students subscription
- Understand different database services available in Azure
- Deploy a PostgreSQL database in the cloud
- Connect to Azure PostgreSQL using pgAdmin
- Create and populate a database
- Query the database from a Python or Java application

## Estimated Time

- 60-90 minutes

## Prerequisites

Before starting, ensure you have:
- [ ] A valid student email address (.edu or institutional email)
- [ ] pgAdmin 4 installed on your computer
- [ ] Python 3.x OR Java 8+ installed
- [ ] A text editor or IDE (VS Code, PyCharm, IntelliJ, etc.)

---

## Exercise Tasks

### Task 1: Create Your Azure for Students Subscription (15 minutes)

Azure for Students provides $100 in free credits and access to many free services, perfect for learning!

#### Steps:

1. **Navigate to Azure for Students**
   - Open your browser and go to: [https://azure.microsoft.com/free/students](https://azure.microsoft.com/free/students)
   - Click "Activate now" or "Start free"

2. **Sign in with Microsoft Account**
   - Use your existing Microsoft account or create a new one
   - **Tip**: Use your student email if possible

3. **Verify Your Student Status**
   - Azure will ask you to verify your student status
   - You may need to provide:
     - Your school email address
     - School name
     - Expected graduation date
   - **Note**: No credit card required for Azure for Students!

4. **Complete Registration**
   - Fill in required information
   - Accept terms and conditions
   - Wait for verification (usually instant, may take up to 24 hours)

5. **Access Azure Portal**
   - Once approved, go to [https://portal.azure.com](https://portal.azure.com)
   - Sign in with your Microsoft account
   - You should see the Azure Portal dashboard

#### Checkpoint 1
- [ ] You can access the Azure Portal
- [ ] Your subscription shows "Azure for Students" with $100 credit
- [ ] You see the main dashboard with "Create a resource" option

**Questions to Answer:**
1. What is your subscription ID? (Find it in: Home → Subscriptions)
2. How much credit do you have remaining?
3. When does your subscription expire?

---

### Task 2: Explore Available Database Services in Azure (10 minutes)

Azure offers multiple database services. Let's explore what's available!

#### Steps:

1. **Search for Database Services**
   - In the Azure Portal, click "+ Create a resource"
   - In the search box, type "database"
   - Browse through the results

2. **Identify Different Database Types**
   
   Look for and note the following services:
   
   | Service | Type | Use Case |
   |---------|------|----------|
   | Azure SQL Database | Relational (SQL Server) | Enterprise applications |
   | Azure Database for PostgreSQL | Relational (PostgreSQL) | Open-source preference |
   | Azure Database for MySQL | Relational (MySQL) | Web applications |
   | Azure Database for MariaDB | Relational (MariaDB) | MySQL alternative |

3. **Explore PostgreSQL Options**
   - Search specifically for "Azure Database for PostgreSQL"
   - Notice there are different deployment options:
     - **Flexible Server** ← We'll use this one!
     - Single Server (deprecated)
     - Hyperscale (Citus)

#### Checkpoint 2

**Questions to Answer:**
1. Name three relational database services available in Azure.
2. Why do you think we're using "Flexible Server" for PostgreSQL? (Hint: check pricing and features)
3. What are some key features of Azure Database for PostgreSQL Flexible Server?

---

### Task 3: Create a PostgreSQL Database in Azure (20 minutes)

Now let's create your own PostgreSQL database server in the cloud!

#### Steps:

1. **Navigate to Create PostgreSQL Flexible Server**
   - Click "+ Create a resource"
   - Search for "Azure Database for PostgreSQL"
   - Select "Azure Database for PostgreSQL Flexible Server"
   - Click "Create"

2. **Configure Basic Settings**
   
   Fill in the following information:
   
   ```
   Project Details:
   ├─ Subscription: Azure for Students
   └─ Resource group: Create new → "rg-student-db-<yourname>"
   
   Server Details:
   ├─ Server name: gameverse-<yourname>-db
   │  (Example: gameverse-john-db)
   │  ⚠️ Must be globally unique!
   │  ⚠️ Write this down - you'll need it!
   ├─ Region: Choose closest to you
   │  (Examples: West Europe, East US, UK South)
   ├─ PostgreSQL version: 15 or 16 (latest)
   ├─ Workload type: Development
   └─ Compute + storage: Click "Configure server"
   ```

3. **Configure Compute and Storage (Important!)**
   
   To stay within budget and free credits:
   
   ```
   Compute Tier: Burstable (cheapest option)
   Compute Size: Standard_B1ms
      ├─ vCores: 1
      └─ Memory: 2 GiB
   
   Storage:
   ├─ Storage size: 32 GiB (minimum)
   ├─ Storage Auto-growth: Enabled
   └─ Backup retention period: 7 days
   ```
   
   **Cost estimate**: ~$13-15/month (well within your $100 credit!)
   
   Click "Save" to apply these settings.

4. **Configure Administrator Account**
   
   **VERY IMPORTANT**: Save these credentials securely!
   
   ```
   Authentication method: PostgreSQL authentication only
   Admin username: gameadmin
   Password: [Create a strong password]
   Confirm password: [Re-enter the same password]
   ```
   
   **Write down your credentials NOW:**
   ```
   Server: gameverse-<yourname>-db.postgres.database.azure.com
   Port: 5432
   Username: gameadmin
   Password: ___________________________
   ```

5. **Configure Networking**
   
   This is crucial for connecting from your computer!
   
   ```
   Connectivity method: Public access (allowed IP addresses)
   
   Firewall rules:
   - Check: Allow public access from any Azure service
   - Check: Add current client IP address (YOUR IP - click this!)
   ```
   
   **What this does**: Allows your computer to connect to the database
   
   Click "Next: Tags >" (leave tags empty for now)

6. **Review and Create**
   
   - Click "Review + create"
   - Review all your settings:
     - Server name
     - Resource group
     - Compute size (B1ms)
     - Storage (32 GiB)
     - Admin username
   - Check the estimated cost
   - Click "Create"

7. **Wait for Deployment**
   
   - Deployment takes 5-10 minutes
   - You'll see a notification when it's complete
   - Click "Go to resource" when deployment is done

8. **Verify Your Database Server**
   
   In the Overview page, confirm:
   - Status: Available
   - Server name: `gameverse-<yourname>-db.postgres.database.azure.com`
   - Version: PostgreSQL 15 or 16
   - Resource group: `rg-student-db-<yourname>`

#### Checkpoint 3
- [ ] PostgreSQL server is created and status shows "Available"
- [ ] You have saved your connection credentials
- [ ] Your IP address is added to the firewall rules
- [ ] You can see the server in your Azure Portal under "All resources"

**Questions to Answer:**
1. What is your complete server name (including `.postgres.database.azure.com`)?
2. What is the estimated monthly cost for your database?
3. In the "Networking" section of your server, what IP address(es) are allowed?
4. Why is it important to add your IP address to the firewall rules?

---

### Task 4: Connect to Azure PostgreSQL with pgAdmin (15 minutes)

Now let's connect to your cloud database using pgAdmin!

#### Steps:

1. **Open pgAdmin 4**
   - Launch pgAdmin on your computer
   - Enter your master password if prompted

2. **Register a New Server**
   - In the left panel, right-click on "Servers"
   - Select "Register" → "Server"

3. **Configure Connection - General Tab**
   ```
   Name: Azure GameVerse (or any descriptive name)
   Server group: Servers (default)
   Connect now: [checked]
   ```

4. **Configure Connection - Connection Tab**
   
   Fill in using the credentials you saved earlier:
   
   ```
   Host name/address: gameverse-<yourname>-db.postgres.database.azure.com
   Port: 5432
   Maintenance database: postgres
   Username: gameadmin
   Password: [Your password from Task 3]
   Save password: [checked] (recommended for convenience)
   ```

5. **Configure Connection - SSL Tab**
   
   **Note**: Azure requires SSL encryption!
   
   ```
   SSL mode: Require
   ```

6. **Save and Connect**
   - Click "Save"
   - pgAdmin will attempt to connect
   - If successful, you'll see your server in the left panel
   - Expand: Servers → Azure GameVerse → Databases

7. **Explore the Default Database**
   - You should see a "postgres" database (default)
   - Expand it: postgres → Schemas → public → Tables
   - It should be empty (no tables yet)

#### Troubleshooting

**Problem: "Could not connect to server: Connection timed out"**
- Solution: Check your firewall rules in Azure Portal
- Add your current IP: Server → Networking → Add current client IP

**Problem: "password authentication failed"**
- Solution: Double-check your username and password
- Username should be just `gameadmin` (not `gameadmin@server`)

**Problem: "SSL connection is required"**
- Solution: Go back to SSL tab and set mode to "Require"

#### Checkpoint 4
- [ ] pgAdmin successfully connects to your Azure PostgreSQL server
- [ ] You can see the "postgres" default database
- [ ] No errors appear in the pgAdmin log

**Questions to Answer:**
1. What PostgreSQL version is shown in pgAdmin? (Right-click server → Properties)
2. How many databases are currently on your server?
3. Take a screenshot of pgAdmin showing your connected Azure server

---

### Task 5: Create the GameVerse Database (15 minutes)

Let's create our game database and load it with data!

#### Steps:

1. **Create the GameVerse Database**
   
   Option A - Using SQL:
   - Right-click on "Databases" under your Azure server
   - Select "Query Tool"
   - Enter and execute:
   ```sql
   CREATE DATABASE gameverse
       WITH 
       ENCODING = 'UTF8'
       LC_COLLATE = 'en_US.utf8'
       LC_CTYPE = 'en_US.utf8'
       TEMPLATE = template0;
   ```
   - Click the Execute button (▶) or press F5
   
   Option B - Using GUI:
   - Right-click "Databases" → "Create" → "Database"
   - Database name: `gameverse`
   - Owner: `gameadmin`
   - Click "Save"

2. **Verify Database Creation**
   - Right-click "Databases" and select "Refresh"
   - You should now see the "gameverse" database
   - Expand it: gameverse → Schemas → public

3. **Create Tables**
   
   - Right-click on the `gameverse` database
   - Select "Query Tool"
   - Copy and paste the contents of the `create_tables.sql` file from your course materials
   - Location: `databases/postgresql/game-database/scripts/create_tables.sql`
   - Execute the script (▶ or F5)
   - You should see "Query returned successfully"

4. **Verify Tables Were Created**
   
   Run this query:
   ```sql
   SELECT table_name 
   FROM information_schema.tables 
   WHERE table_schema = 'public'
   ORDER BY table_name;
   ```
   
   You should see tables like:
   - developers
   - game_platforms
   - games
   - genres
   - platforms
   - publishers
   - reviews
   - users

5. **Load Sample Data**
   
   - In the same Query Tool (on gameverse database)
   - Copy and paste contents of `insert_data.sql`
   - Location: `databases/postgresql/game-database/scripts/insert_data.sql`
   - Execute the script
   - This will populate your tables with game data

6. **Verify Data Was Loaded**
   
   Run these verification queries:
   ```sql
   -- Check number of games
   SELECT COUNT(*) as total_games FROM games;
   
   -- Check number of publishers
   SELECT COUNT(*) as total_publishers FROM publishers;
   
   -- View some sample games
   SELECT title, release_date, price 
   FROM games 
   LIMIT 5;
   ```

#### Checkpoint 5
- [ ] GameVerse database is created
- [ ] All tables are created successfully
- [ ] Sample data is loaded
- [ ] Verification queries return results

**Questions to Answer:**
1. How many total games are in your database?
2. How many publishers are in your database?
3. List the names of 3 games from your database.
4. What is the most expensive game in the database? (Write a query to find it!)

---

### Task 6: Query the Database from Python or Java (20 minutes)

Now let's connect to your Azure database from code!

Choose **ONE** of the following: Python OR Java

---

#### Option A: Python

##### Step 1: Install Required Library

Open your terminal/command prompt:

```bash
# Install psycopg2 (PostgreSQL adapter for Python)
pip install psycopg2-binary
```

##### Step 2: Create a Python Script

Create a new file: `azure_db_query.py`

```python
import psycopg2
from psycopg2 import Error

def connect_to_azure_db():
    """
    Connect to Azure PostgreSQL database and execute queries
    """
    try:
        # Connection parameters - UPDATE THESE WITH YOUR DETAILS!
        connection = psycopg2.connect(
            host="gameverse-<yourname>-db.postgres.database.azure.com",
            database="gameverse",
            user="gameadmin",
            password="YOUR_PASSWORD_HERE",
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
        
        # Close cursor and connection
        cursor.close()
        connection.close()
        print("\nConnection closed successfully")
        
    except Error as e:
        print(f"Error connecting to Azure PostgreSQL: {e}")

if __name__ == "__main__":
    connect_to_azure_db()
```

##### Step 3: Update Connection Details

In the code above, update:
- `host`: Your server name
- `password`: Your actual password

##### Step 4: Run the Script

```bash
python azure_db_query.py
```

##### Step 5: Customize with Your Own Query

Add a 5th query of your choice! Examples:
- Find all games released after 2020
- List publishers and their game count
- Find games priced under $20
- Get average rating by platform

```python
# Add this before closing the cursor:
print("\n" + "="*50)
print("Query 5: Your Custom Query")
print("="*50)
query = """
    -- Write your SQL query here!
"""
cursor.execute(query)
results = cursor.fetchall()
# Print your results
```

---

#### Option B: Java

##### Step 1: Download PostgreSQL JDBC Driver

1. Download from: [https://jdbc.postgresql.org/download/](https://jdbc.postgresql.org/download/)
2. Get the latest `.jar` file (e.g., `postgresql-42.6.0.jar`)
3. Save it in your project directory

##### Step 2: Create a Java Class

Create a new file: `AzureDBQuery.java`

```java
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.ResultSet;
import java.sql.Statement;
import java.sql.SQLException;

public class AzureDBQuery {
    
    // UPDATE THESE WITH YOUR DETAILS!
    private static final String HOST = "gameverse-<yourname>-db.postgres.database.azure.com";
    private static final String DATABASE = "gameverse";
    private static final String USER = "gameadmin";
    private static final String PASSWORD = "YOUR_PASSWORD_HERE";
    private static final String PORT = "5432";
    
    public static void main(String[] args) {
        
        String url = String.format(
            "jdbc:postgresql://%s:%s/%s?sslmode=require",
            HOST, PORT, DATABASE
        );
        
        Connection connection = null;
        
        try {
            // Load PostgreSQL JDBC driver
            Class.forName("org.postgresql.Driver");
            
            // Establish connection
            System.out.println("Connecting to Azure PostgreSQL...");
            connection = DriverManager.getConnection(url, USER, PASSWORD);
            System.out.println("Successfully connected to Azure PostgreSQL!");
            
            Statement statement = connection.createStatement();
            
            // Query 1: Total number of games
            System.out.println("\n" + "=".repeat(50));
            System.out.println("Query 1: Total Number of Games");
            System.out.println("=".repeat(50));
            
            ResultSet rs1 = statement.executeQuery("SELECT COUNT(*) FROM games;");
            if (rs1.next()) {
                System.out.println("Total games in database: " + rs1.getInt(1));
            }
            rs1.close();
            
            // Query 2: Top 5 highest-rated games
            System.out.println("\n" + "=".repeat(50));
            System.out.println("Query 2: Top 5 Highest-Rated Games");
            System.out.println("=".repeat(50));
            
            String query2 = """
                SELECT title, release_date, metacritic_score 
                FROM games 
                WHERE metacritic_score IS NOT NULL
                ORDER BY metacritic_score DESC 
                LIMIT 5;
            """;
            
            ResultSet rs2 = statement.executeQuery(query2);
            System.out.printf("%-40s %-15s %-10s%n", "Title", "Release Date", "Score");
            System.out.println("-".repeat(65));
            
            while (rs2.next()) {
                String title = rs2.getString("title");
                String releaseDate = rs2.getString("release_date");
                double score = rs2.getDouble("metacritic_score");
                System.out.printf("%-40s %-15s %-10.2f%n", title, releaseDate, score);
            }
            rs2.close();
            
            // Query 3: Games by genre
            System.out.println("\n" + "=".repeat(50));
            System.out.println("Query 3: Games by Genre");
            System.out.println("=".repeat(50));
            
            String query3 = """
                SELECT g.name as genre, COUNT(ga.game_id) as game_count
                FROM genres g
                LEFT JOIN games ga ON g.genre_id = ga.genre_id
                GROUP BY g.name
                ORDER BY game_count DESC;
            """;
            
            ResultSet rs3 = statement.executeQuery(query3);
            System.out.printf("%-30s %-15s%n", "Genre", "Number of Games");
            System.out.println("-".repeat(45));
            
            while (rs3.next()) {
                String genre = rs3.getString("genre");
                int count = rs3.getInt("game_count");
                System.out.printf("%-30s %-15d%n", genre, count);
            }
            rs3.close();
            
            // Query 4: Price statistics
            System.out.println("\n" + "=".repeat(50));
            System.out.println("Query 4: Price Statistics");
            System.out.println("=".repeat(50));
            
            String query4 = """
                SELECT 
                    AVG(price) as avg_price,
                    MIN(price) as min_price,
                    MAX(price) as max_price
                FROM games
                WHERE price IS NOT NULL;
            """;
            
            ResultSet rs4 = statement.executeQuery(query4);
            if (rs4.next()) {
                double avg = rs4.getDouble("avg_price");
                double min = rs4.getDouble("min_price");
                double max = rs4.getDouble("max_price");
                
                System.out.printf("Average game price: $%.2f%n", avg);
                System.out.printf("Cheapest game: $%.2f%n", min);
                System.out.printf("Most expensive game: $%.2f%n", max);
            }
            rs4.close();
            
            // Clean up
            statement.close();
            connection.close();
            System.out.println("\nConnection closed successfully");
            
        } catch (ClassNotFoundException e) {
            System.err.println("PostgreSQL JDBC Driver not found!");
            System.err.println("Make sure postgresql-XX.jar is in your classpath");
            e.printStackTrace();
        } catch (SQLException e) {
            System.err.println("Error connecting to Azure PostgreSQL!");
            e.printStackTrace();
        }
    }
}
```

##### Step 3: Update Connection Details

In the code above, update:
- `HOST`: Your server name
- `PASSWORD`: Your actual password

##### Step 4: Compile and Run

```bash
# Compile (make sure JDBC driver is in classpath)
javac -cp .:postgresql-42.6.0.jar AzureDBQuery.java

# Run
java -cp .:postgresql-42.6.0.jar AzureDBQuery
```

**Windows users**: Use semicolon instead of colon:
```bash
javac -cp .;postgresql-42.6.0.jar AzureDBQuery.java
java -cp .;postgresql-42.6.0.jar AzureDBQuery
```

##### Step 5: Add Your Custom Query

Before closing the statement, add your own query:

```java
// Query 5: Your custom query
System.out.println("\n" + "=".repeat(50));
System.out.println("Query 5: Your Custom Query");
System.out.println("=".repeat(50));

String query5 = """
    -- Write your SQL query here!
""";

ResultSet rs5 = statement.executeQuery(query5);
// Process and print your results
rs5.close();
```

---

#### Checkpoint 6
- [ ] Successfully installed database connector library
- [ ] Application connects to Azure PostgreSQL
- [ ] All 4 default queries execute successfully
- [ ] Added and executed a custom 5th query
- [ ] Output shows correct data from gameverse database

**Questions to Answer:**
1. Paste the output from running your script.
2. What was your custom 5th query? (SQL statement)
3. What results did your custom query return?
4. What is one challenge you faced connecting from code? How did you solve it?

---

## Deliverables

Submit the following to your instructor:

### 1. Azure Setup Documentation (PDF or Word)
   - Screenshot of your Azure Portal showing:
     - Your PostgreSQL server in "Available" status
     - Your resource group with all resources
     - Cost Management showing current spending
   - Your server connection details (WITHOUT password):
     - Server name
     - Resource group name
     - Region
     - Compute tier and size

### 2. pgAdmin Connection (Screenshots)
   - Screenshot of pgAdmin connected to Azure PostgreSQL
   - Screenshot showing the gameverse database with all tables
   - Screenshot of a query result in pgAdmin

### 3. Application Code
   - Your complete Python OR Java file
   - Include comments explaining what each query does
   - Make sure your custom 5th query is included

### 4. Application Output
   - Screenshot or text file of your application output
   - Should show results from all 5 queries

### 5. Written Responses (Document)
   - Answers to all questions from each checkpoint
   - Reflection: Write 2-3 paragraphs about:
     - What you learned about cloud databases
     - Differences between local and cloud PostgreSQL
     - Challenges you faced and how you overcame them
     - One practical use case for cloud databases

### 6. Custom Query Explanation
   - SQL statement of your custom query
   - Explanation of what it does
   - Why you chose this query
   - Screenshot of the results

---

## Clean Up (After the Course)

**Important**: To avoid using your Azure credits, remember to:

1. **Stop the Database Server** (when not using it):
   - Go to your PostgreSQL server in Azure Portal
   - Click "Stop" in the top menu
   - Can be stopped for up to 7 days
   - This saves compute costs!

2. **Delete Resources** (when completely done):
   - Go to Resource Groups
   - Select `rg-student-db-<yourname>`
   - Click "Delete resource group"
   - Type the resource group name to confirm
   - Click "Delete"

---

## Bonus Challenges (Optional)

Want to go further? Try these:

### Bonus 1: Create Additional Users
Create a read-only user for your application:
```sql
CREATE USER app_reader WITH PASSWORD 'SecurePassword123';
GRANT CONNECT ON DATABASE gameverse TO app_reader;
GRANT USAGE ON SCHEMA public TO app_reader;
GRANT SELECT ON ALL TABLES IN SCHEMA public TO app_reader;
```

Update your application to use this user instead of admin.

### Bonus 2: Implement Connection Pooling
Research and implement connection pooling in your application for better performance.

### Bonus 3: Create a Simple Web API
Create a REST API using Flask (Python) or Spring Boot (Java) that queries your Azure database.

### Bonus 4: Monitor Performance
- Enable Query Performance Insight in Azure Portal
- Run complex queries and analyze performance
- Identify slow queries and optimize them

### Bonus 5: Backup and Restore
- Create a manual backup of your database
- Simulate data loss (delete some records)
- Restore from backup

---

## Additional Resources

- [Azure Database for PostgreSQL Documentation](https://docs.microsoft.com/azure/postgresql/)
- [pgAdmin Documentation](https://www.pgadmin.org/docs/)
- [Python psycopg2 Tutorial](https://www.psycopg.org/docs/)
- [PostgreSQL JDBC Documentation](https://jdbc.postgresql.org/documentation/)
- [Azure for Students FAQ](https://azure.microsoft.com/free/students/faq/)

---

## Need Help?

### Common Issues

**Issue: Can't verify student status**
- Use your institutional email address
- Contact your school's IT department
- Try using your school's student portal link

**Issue: Connection timeout from application**
- Check firewall rules include your IP
- Verify SSL mode is set correctly
- Make sure server status is "Available"

**Issue: Application library won't install**
- Python: Try `pip3` instead of `pip`
- Java: Verify JDBC driver is in correct location
- Check your Python/Java version

**Issue: Queries return no data**
- Verify you're connected to gameverse database (not postgres)
- Check if data was loaded successfully
- Run verification queries from Task 5

### Getting Support

1. Check with classmates
2. Review the Teacher Setup Guide
3. Search the error message online
4. Ask your instructor
5. Check Azure Status page for service issues

---

**Good luck!**

Remember: Cloud databases are powerful tools used by companies worldwide. By completing this exercise, you're learning real-world, in-demand skills!

---

**Last Updated**: February 2026  
**Course**: IT Class 2026  
**Exercise Type**: Hands-on Lab
