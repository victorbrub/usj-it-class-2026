# Individual Work I - RELATIONAL DATABASES
# Author: Víctor Barceló

**Student**: Miguel Climente Lopez
**Model**: Pokemon Battle — Trainers, Pokemon Species, Owned Pokemon, Moves and Battles

## Introduction
In Information Technologies, we are working on the practical aspects of database-based application design, putting into practice what we have learned in other subjects and getting a little closer to the real work of an Information Systems Engineer. To do this, we will take a journey that will take us little by little from the simplest database systems to the most complex systems that exist today.

In this first individual work, we will practice the design of relational databases for use in client server applications. This will allow us to remember (or recover) basic concepts while we put them into practice with a design example that we will increase in complexity and functionality throughout the different topics of the first block of the course (Relational Databases).

A client-server environment is characterized by the presence of several clients trying to access concurrently shared resources: the records stored in the database. The DataBase Management System (DBMS) must control situations in which several clients try to simultaneously update the same register, in the same way, that an Operating System must control when several processes try to simultaneously update the same file. But the situation in Databases is more complex than in Operating Systems, since there may be sets of SQL statements that access several records in the database and must be executed together, or not executed at all. The archetypal example is one of the bank transfers, in which an amount of money from a checking account must be discounted (UPDATE) and increase (UPDATE) the balance of another current account in that same amount. If for some reason the second transaction is not possible (for example, the balance of the second account has been changed from another client, or the current account has been dropped or locked), changes in the first account must be rolled back or Money "will be gone."

To achieve this behavior, the DBMS must establish some kind of concurrency control so that two clients cannot mutually interfere when attempting to perform operations on the same database records. But at the same time, the DBMS must ensure maximum concurrency among all clients that access it, so that none of them is unnecessarily waiting. Clearly, these are two opposing concepts: maximum concurrency and minimum conflicts in access to records. Increasing the concurrent execution of groups of SQL statements from multiple clients increases the likelihood of conflicts. If we eliminate the possibility of conflicts (using locks and semaphores, as in concurrent programming), we will also increase the number of clients that may be blocked waiting their turn to use those records.

Specifically, this practical work is divided into three main parts:
1. Accessing the database.
2. Managing transactions and concurrency control.
3. Optimization.

The database to be used is the one designed and refined in the "Define your database" task.

## 1. Creating the database (1 points)
This first part is about creating and populating the database in PostgreSQL. This part is intended for you to get into the creation of a database relational model, and checking what we can and cannot achieve with your model.

**Exercises**

1. **Create** a single `create_database.sql` script that creates all the tables from the model you defined. (0.2 points)
    * Output: Working `create_database.sql` file.

2. **Create** a single `populate_database.sql` script that **populates** (adds data) to all the tables, in a meaningful way. At least 100 records per table. (0.2 points)
    * Output: Working `populate_database.sql` file.

3. **Write** a functional example on the application of the model. That is, a documentation to understand the scope of application, what covers and what not, with examples. (0.6 points)
    * Output: `scope.md` file with thoughtful explanation.


## 2. Accessing the database (2 points)

The main objective of this topic is the acquisition and reinforcement of the following concepts and skills:

* Control the access considering different roles for the users using standard SQL Data Control Language (DCL) and views.

* Inserting data into the database using standard SQL Data Manipulation Language (DML).

### Description of the problem

Your database must be accessible to different types of users, each with specific permissions and access levels.

**Exercises**:

1. **Define User Access**: Think about who can access what information. (0.3 points)
    * Output: External views for each type of user.

2. **Create Users**: Set up user accounts in the database. (0.3 points)
    * Output: Screenshot of the SQL command to create each user.

3. **Assign Privileges**: Grant appropriate permissions using different methods. (0.5 points)
    * Output: Screenshot of the assigned permissions.

4. **Verify User Access**: Ensure that each user can only access the authorized data. (0.3 points)
    * Output: Screenshot demonstrating the verification process, showing authorized access to permitted data and denial of access to restricted data.

5. **Create a View for a Derived or Composite Attribute**: Create an SQL view that either calculates the value of a derived attribute or combines multiple fields into a single attribute for a composite attribute. **This view should be accessed only by a subset of users.** (0.6 points)
    * Output: Screenshot of the view properties or SQL to declare the view.


## 3. Managing transactions and concurrency control (3 points)

The main objective of this topic is the acquisition of the following concepts and skills:

* Understand how concurrency control is implemented in PostgreSQL.
* Apply transaction concepts, such as schedules or serializability.
* To deepen the property of isolation for transactions.

**Exercises**:
1. Given the following schedule, is this statement **true** or **false**? *The schedule is not serial because it is serializable.* Justify your answer. (0.5 points)

The following schedule involves two transactions concurrently accessing the `owned_pokemon` table of the Pokemon battle model:

- **T1**: A Pokedex synchronisation service reads owned Pokemon #15's `level` during a stats report. It reads the level twice: once at the start and once before closing the report.
- **T2**: A training event updates owned Pokemon #15's `level` from 18 to 21 and commits between T1's two reads.
- Initial value: `owned_pokemon[owned_pokemon_id=15].level = 18`.

| Step | T1 (Pokedex stats report)                          | T2 (Training event: +3 levels)                |
|------|-----------------------------------------------------|-----------------------------------------------|
| t1   | BEGIN                                               |                                               |
| t2   | READ(owned_pokemon[15].level) = 18                  |                                               |
| t3   |                                                     | BEGIN                                         |
| t4   |                                                     | WRITE(owned_pokemon[15].level) = 21           |
| t5   |                                                     | COMMIT                                        |
| t6   | READ(owned_pokemon[15].level) = 21 (DIFFERENT VALUE!)|                                              |
| t7   | COMMIT (report shows inconsistent level data)       |                                               |

T1 read the same `level` field within the same transaction and obtained different values (18 then 21) because T2 committed an update between T1's two reads.

* Output: Answer the question with adequate justification.

2. What **concurrency problems** are happening in the previous schedule? Justify your answer. (0.75 point)
    * Output: Answer the question with proper reasoning, identifying the concurrency problems in the schedule.

3. **Correct the previous schedule** to avoid the concurrency problem. (0.25 point)
    * Outputs: The corrected schedule without any concurrency problems

4. Is the corrected schedule **serial or serializable?** Justify your answer. (0.5 points)
    * Output: Answer the question with adequate justification.

5. **Verify and demonstrate ONE concurrency problem** within an isolation level. Set the isolation level in PostgreSQL and demonstrate a concurrency issue that is not prevented by this level. To do this, insert some data into the database (you can create test data). Then, record a video of no more than 3 minutes explaining what is happening. (1 points)
    * Output: A video demonstrating how you set the isolation level in the created database, and showing whether a concurrency problem still occurs or is avoided by the selected isolation level.

## 4. Optimization (4)

The main objective of this topic is the acquisition of the following concepts and skills:
* Understand query processing.
* Apply different forms of query and database optimization.

**Description of the problem**

```sql

SELECT name, nickname, level WHERE trainer_id < 10 AND level > 20
FROM trainer NATURAL JOIN owned_pokemon
JOIN pokemon ON pokemon_id = pokemon.pokemon_id;

```

**Exercises**:

1. The above query **will fail** when executed. Identify and describe the possible errors in the query. (0.3 points)
    * Output: Explanation of the errors.

2. **Relate each identified error** to the specific step of query processing where it is detected. (0.4 points)
    * Output: Explanation of which step in the query processing pipeline is responsible for detecting each error.

3. Modify the query to **fix the identified errors** and ensure correct execution. (0.3 points)
    * Output: The corrected query.


4. Calculate the execution cost for the most optimized query tree using the following parameters (1 points):
- All the tables have 300 records.
- The blocking factor for all the tables is 3.
- The number of levels of an index is 3.
- The number of buffers is 3.
- The data is sorted.

    * Outputs: Detailed calculations for the execution cost.

5. Design and create a **full optimization plan** for your model. Create an `optimization.md` file explaining all the things you want to make to each table (indexing, partitioning, clustering and so on). Create a `optimize_database.sql` file that applies all those modifications in a single execution. (1.5 points)
    * Outputs: `optimization.md` and a working `optimize_database.sql` file.

6. **Create a SQL query** for your model that takes advantages from some of the optimizations you made, looking at the execution time (You may need to add more records for this to be meaningful). (0.5 points)
    * Outputs: Query and screenshots of the execution plan before and after optimizations.
