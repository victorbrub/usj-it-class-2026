# Azure PostgreSQL Query Scripts

This directory contains sample scripts for connecting to and querying Azure PostgreSQL database.

## Files

- `azure_db_query.py` - Python script for database queries
- `AzureDBQuery.java` - Java program for database queries
- `student_setup.md` - Complete setup instructions and exercise guide

## Prerequisites

### For Python Script
- Python 3.x installed
- pip (Python package manager)

### For Java Program
- Java 8+ (JDK) installed
- PostgreSQL JDBC driver (download from https://jdbc.postgresql.org/download/)

## Setup Instructions

### Python Setup

1. **Install required library**:
   ```bash
   pip install psycopg2-binary
   ```

2. **Update connection details** in `azure_db_query.py`:
   - Line 11: Replace `<yourname>` with your actual server name
   - Line 13: Replace `YOUR_PASSWORD_HERE` with your password

3. **Run the script**:
   ```bash
   python azure_db_query.py
   ```

### Java Setup

1. **Download PostgreSQL JDBC driver**:
   - Visit https://jdbc.postgresql.org/download/
   - Download the latest `.jar` file (e.g., `postgresql-42.6.0.jar`)
   - Place it in this directory

2. **Update connection details** in `AzureDBQuery.java`:
   - Line 10: Replace `<yourname>` with your actual server name
   - Line 13: Replace `YOUR_PASSWORD_HERE` with your password

3. **Compile**:
   ```bash
   # Linux/Mac
   javac -cp .:postgresql-42.6.0.jar AzureDBQuery.java
   
   # Windows
   javac -cp .;postgresql-42.6.0.jar AzureDBQuery.java
   ```

4. **Run**:
   ```bash
   # Linux/Mac
   java -cp .:postgresql-42.6.0.jar AzureDBQuery
   
   # Windows
   java -cp .;postgresql-42.6.0.jar AzureDBQuery
   ```

## What the Scripts Do

Both scripts execute the following queries:

1. **Query 1**: Count total number of games in database
2. **Query 2**: Get top 5 highest-rated games
3. **Query 3**: Show game count by genre
4. **Query 4**: Calculate price statistics (average, min, max)
5. **Query 5**: Custom query (example: games released after 2020)

## Customizing Query 5

Both scripts include a placeholder Query 5 that you can customize. Some ideas:

- Find all games under $20
- List publishers and their game count
- Get average metacritic score by genre
- Find games released in the last year
- Show most expensive games per platform

Simply replace the SQL query in Query 5 section with your own SQL statement.

## Troubleshooting

### Python Issues

**Error: "No module named 'psycopg2'"**
- Solution: Run `pip install psycopg2-binary`

**Error: "could not connect to server"**
- Check your firewall rules in Azure Portal
- Verify your server name is correct
- Ensure SSL mode is set to "require"

### Java Issues

**Error: "ClassNotFoundException: org.postgresql.Driver"**
- Make sure the JDBC `.jar` file is in your classpath
- Verify the jar filename in your compile/run commands

**Error: "Text block syntax not supported"**
- You need Java 15+ for text blocks (`"""`)
- Alternative: Use regular strings with `+` concatenation

### Connection Issues

**Error: "Connection timed out"**
1. Check Azure firewall rules include your current IP
2. Go to: Azure Portal → Your Server → Networking
3. Click "Add current client IP address"
4. Save changes

**Error: "password authentication failed"**
- Double-check your username and password
- Username should be just `gameadmin` (not including @servername)

**Error: "SSL connection required"**
- Azure PostgreSQL requires SSL
- Python: Ensure `sslmode="require"` in connection string
- Java: Ensure `?sslmode=require` in JDBC URL

## Need More Help?

Refer to the complete `student_setup.md` file for:
- Detailed Azure setup instructions
- pgAdmin connection guide
- Full troubleshooting section
- Bonus challenges

## Resources

- [Azure PostgreSQL Documentation](https://docs.microsoft.com/azure/postgresql/)
- [psycopg2 Documentation](https://www.psycopg.org/docs/)
- [PostgreSQL JDBC Documentation](https://jdbc.postgresql.org/documentation/)
