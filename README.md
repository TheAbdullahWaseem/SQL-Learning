# SQL Learning: The Data Foundation for Data Science and Machine Learning

**Abdullah Waseem** | Data Analyst | Building toward Data Science and Machine Learning Engineering

Every model is only as good as the data it is trained on. That data often needs to be extracted, joined, cleaned, and validated with SQL first. I learned SQL to build that foundation because I want to become a data scientist and machine learning engineer, and I want to be able to prepare and verify trustworthy data independently.

This repository documents that learning journey through three stages of PostgreSQL practice, from basic queries to window functions and CTEs, culminating in a 10-query advanced assessment that I solved independently.

|              |                                                                            |
| ------------ | -------------------------------------------------------------------------- |
| **Focus**    | SQL for data analysis, data science, and machine learning data preparation |
| **Level**    | Advanced SQL learning and practice                                         |
| **Database** | PostgreSQL, `dvdrental` sample database                                    |
| **Tools**    | PostgreSQL, DBeaver, Git and GitHub                                        |
| **Content**  | SQL scripts across three learning stages, plus an advanced assessment      |

---

## Contents

1. [Why I Learned SQL](#why-i-learned-sql)
2. [Skill Map](#skill-map)
3. [The Advanced SQL Assessment](#the-advanced-sql-assessment)
4. [From SQL to a Real Project: Superstore Sales Analysis](#from-sql-to-a-real-project-superstore-sales-analysis)
5. [Mistakes I Made and What They Taught Me](#mistakes-i-made-and-what-they-taught-me)
6. [How I Check My Results](#how-i-check-my-results)
7. [How I Learn](#how-i-learn)
8. [Dataset](#dataset)
9. [Repository Structure](#repository-structure)
10. [Run It Yourself](#run-it-yourself)
11. [Work With Me](#work-with-me)

---

## Repository Contents

This repository is organized into three SQL learning stages, supported by a practical assessment and the dataset used for query practice.

- [Basic SQL](<01.%20Basic%20SQL/>)
- [Intermediate SQL](<02.%20Intermediate%20SQL/>)
- [Advanced SQL](<03.%20Advanced%20SQL/>)
- [Advanced SQL Assessment](<SQL%20Assessment/Advanced%20SQL%20Assessment.sql>)
- [Dataset — dvdrental](<Dataset/dvdrental/>)

---

## Why I Learned SQL

My goal is to work as a Machine Learning Engineer. SQL is an important part of that path because data needs to be retrieved, prepared, and checked before it can be used reliably in analysis or machine learning.

```text
Where SQL fits into a data science or ML workflow
│
├── Extracting the right data
│   └── Joins across tables, filters, and aggregations
│
├── Building features
│   ├── Window functions for lags, rolling averages, and running totals
│   ├── Aggregations by customer, product, or time period
│   └── CASE logic for segments, flags, and labels
│
├── Cleaning and preparing data
│   ├── Type conversion and date handling
│   ├── String cleaning
│   └── NULL handling and de-duplication
│
└── Validating the data
    ├── Checking row counts and grain after joins
    ├── Reconciling totals against source data
    └── Catching errors that could compromise downstream analysis

```

The last point matters. A join that multiplies rows or a filter that removes records unexpectedly may not produce an error. The result can look perfectly reasonable while containing incorrect numbers. Understanding how to detect and prevent these problems is an important part of working with data.

---

## Skill Map

```text
SQL Skills
│
├── 01. Basic SQL: querying and filtering
│   ├── SELECT, aliases, LIMIT, ORDER BY
│   ├── WHERE with comparison operators
│   ├── AND, OR, NOT
│   ├── IN, BETWEEN, IS NULL
│   ├── LIKE and pattern matching
│   └── GROUP BY
│
├── 02. Intermediate SQL: aggregation and relational data
│   ├── COUNT, SUM, AVG, MIN, MAX
│   ├── HAVING and DISTINCT
│   ├── CASE and conditional logic
│   ├── Joins
│   │   ├── INNER, LEFT, RIGHT, FULL OUTER
│   │   ├── WHERE vs ON in outer joins
│   │   ├── Multiple-key joins
│   │   ├── Comparison-based (non-equi) joins
│   │   └── Self joins
│   └── UNION
│
└── 03. Advanced SQL: analytical querying
    ├── Data types and type conversion
    ├── Date and time operations
    ├── Data wrangling
    ├── String functions
    ├── Subqueries
    │   ├── In SELECT and WHERE
    │   └── Multi-stage problems
    ├── Window functions
    │   ├── Aggregate windows: running totals and moving averages
    │   ├── Ranking: ROW_NUMBER, RANK, DENSE_RANK, NTILE
    │   ├── Value functions: LAG, LEAD, FIRST_VALUE, LAST_VALUE
    │   ├── Frame clause: ROWS and RANGE
    │   └── Advanced combinations
    └── Common Table Expressions (CTEs)
        ├── Foundations and chained CTEs
        ├── CTEs combined with window functions and joins
        └── Patterns for readable, structured queries

```

---

## The Advanced SQL Assessment

[**Open the Advanced SQL Assessment**](SQL%20Assessment/Advanced%20SQL%20Assessment.sql)

The topic scripts show how I studied individual concepts. The assessment tests whether I can combine those concepts to solve more involved problems.

It contains **10 advanced SQL queries**, approached as analytical questions rather than isolated syntax exercises. Each requires interpreting the problem, identifying the relevant tables and techniques, and building the query in a logical sequence.

### What the assessment covers

- Multi-table joins and the importance of preserving the correct row counts
- CTEs for breaking complex problems into understandable steps
- Window functions for ranking, running totals, and comparisons
- Subqueries for filtering against calculated values
- CASE expressions for conditional logic and segmentation
- Date and time operations for time-based analysis

### How I approached it

- Solved the questions independently, without following a provided solution.
- Considered what one row of the result should represent before constructing the query.
- Built queries step by step and checked intermediate results where appropriate.
- Reviewed the final output against the original question.

The assessment is a practical checkpoint in my learning. It brings together concepts from all three stages and provides a more comprehensive view of my current SQL skills than an individual topic exercise.

---

## From SQL to a Real Project: Superstore Sales Analysis

SQL is most useful when it contributes to practical analysis. My **Superstore Sales Analysis** project is where I apply related data-analysis skills beyond isolated SQL exercises.

The connection appears in three areas:

- **Preparing data:** Understanding joins, aggregation, and the correct level of detail helps prevent incorrect figures from carrying into reports and visualizations.
- **Checking results:** Row counts, totals, and data grain are important checks when working with analytical datasets.
- **Answering business questions:** Revenue, profit, ranking, and period-over-period comparisons are examples of analytical tasks that connect with the SQL concepts practiced here.

This repository documents my SQL learning, while the Superstore project demonstrates how data-analysis techniques can be applied in a broader project.

*The project link can be added here once its GitHub repository is published.*

---

## Mistakes I Made and What They Taught Me

Learning SQL also means understanding why a query can return an incorrect result even when it executes successfully. These are some of the lessons I recorded during practice.

```text
Lessons from SQL Practice
│
├── Join fan-out
│   ├── Problem: Joining multiple one-to-many tables can multiply rows
│   └── Fix: Aggregate at the appropriate grain before joining results
│
├── WHERE vs ON in a LEFT JOIN
│   ├── Problem: A WHERE condition on the right table can remove unmatched rows
│   └── Fix: Use ON when the condition must preserve unmatched left-side rows
│
├── Casting timestamps too early
│   ├── Problem: Converting timestamps to dates can collapse distinct events
│   └── Fix: Preserve timestamp precision until date-level aggregation is needed
│
├── Window frame behavior
│   ├── Problem: Default frames and peer rows can produce unexpected results
│   └── Fix: Understand the frame and specify it explicitly when needed
│
└── Reading the question precisely
    ├── Problem: A wrong boundary operator, sort direction, or column can change the answer
    └── Fix: Check the final query against the exact requirements

```

These lessons reinforced a principle I apply throughout SQL practice: a query executing without an error does not prove that its result is correct.

---

## How I Check My Results

Before trusting a query result, I consider the following checks:

- **Row counts:** Compare counts before and after joins to identify unexpected row multiplication or loss.
- **Totals:** Reconcile sums against the source data or an independent calculation.
- **Grain:** Establish what one row represents and whether the result preserves that level of detail.
- **NULLs:** Check how missing values and outer joins affect the intended output.
- **Ties:** Use appropriate tie-breakers when deterministic ranking or ordering is required.
- **Reasonableness:** Consider whether the results make sense in the context of the question and underlying data.

The checks depend on the query, but their purpose is the same: validate the result rather than trusting execution alone.

---

## How I Learn

My approach is to **attempt each query independently before consulting a solution**. I compare my answer with a reference only after completing my attempt. This helps me distinguish what I can solve myself from what I still need to understand.

```text
My Learning Process
│
├── 1. Learn      Study the concept
├── 2. Attempt    Write queries using dvdrental
├── 3. Compare    Review a reference after attempting the problem
├── 4. Record     Understand the cause of mistakes
├── 5. Combine    Apply concepts in larger problems
└── 6. Assess     Test my understanding without assistance

```

---

## Dataset

All exercises and the assessment use PostgreSQL's **`dvdrental` sample database**, which represents a DVD rental business with related customers, films, rentals, payments, and operational records.

```text
dvdrental
│
├── Customers and locations
│   └── customer, address, city, country
│
├── Film catalog
│   └── film, actor, category, language,
│       film_actor, film_category
│
├── Operations
│   └── store, staff, inventory
│
└── Transactions
    └── rental, payment

```

Working across related tables provided practice with joins, aggregation, subqueries, window functions, and time-based analysis. The PostgreSQL directory-format backup used during practice is included in the repository under `Dataset/dvdrental/`.

---

## Repository Structure

The links below open the corresponding files or folders in this GitHub repository. The file links are relative, so they work when this README is displayed on GitHub.

- [02. Select.sql](01.%20Basic%20SQL/02.%20Select.sql)
- [03. Limit.sql](01.%20Basic%20SQL/03.%20Limit.sql)
- [04. Where.sql](01.%20Basic%20SQL/04.%20Where.sql)
- [05. Comparison Operators.sql](01.%20Basic%20SQL/05.%20Comparison%20Operators.sql)
- [06. Group by.sql](01.%20Basic%20SQL/06.%20Group%20by.sql)
- [07. Like and Inlike.sql](01.%20Basic%20SQL/07.%20Like%20and%20Inlike.sql)
- [08. IN Queries.sql](01.%20Basic%20SQL/08.%20IN%20Queries.sql)
- [09. Between.sql](01.%20Basic%20SQL/09.%20Between.sql)
- [10. IS NULL.sql](01.%20Basic%20SQL/10.%20IS%20NULL.sql)
- [11. AND.sql](01.%20Basic%20SQL/11.%20AND.sql)
- [12. OR.sql](01.%20Basic%20SQL/12.%20OR.sql)
- [13. Not.sql](01.%20Basic%20SQL/13.%20Not.sql)
- [14. Order By.sql](01.%20Basic%20SQL/14.%20Order%20By.sql)

* [02. Count.sql](02.%20Intermediate%20SQL/02.%20Count.sql)
* [03. Sum.sql](02.%20Intermediate%20SQL/03.%20Sum.sql)
* [04. Min Max.sql](02.%20Intermediate%20SQL/04.%20Min%20Max.sql)
* [05. Avg.sql](02.%20Intermediate%20SQL/05.%20Avg.sql)
* [06. Having.sql](02.%20Intermediate%20SQL/06.%20Having.sql)
* [07. Case Problems.sql](02.%20Intermediate%20SQL/07.%20Case%20Problems.sql)
* [08. Case.sql](02.%20Intermediate%20SQL/08.%20Case.sql)
* [09. Distinct.sql](02.%20Intermediate%20SQL/09.%20Distinct.sql)

**10–15. Joins**

- [10. Joins.sql](02.%20Intermediate%20SQL/10-15.%20Joins/10.%20Joins.sql)
- [11. Inner Join.sql](02.%20Intermediate%20SQL/10-15.%20Joins/11.%20Inner%20Join.sql)
- [12-13. Left Join and Right Join.sql](02.%20Intermediate%20SQL/10-15.%20Joins/12-13.%20Left%20Join%20and%20Right%20Join.sql)
- [14. Full Outer Join.sql](02.%20Intermediate%20SQL/10-15.%20Joins/14.%20Full%20Outer%20Join.sql)
- [15. Where vs On.sql](02.%20Intermediate%20SQL/10-15.%20Joins/15.%20Where%20vs%20On.sql)

**Set operations and additional joins**

- [16. Union.sql](02.%20Intermediate%20SQL/16.%20Union.sql)
- [17. Sql joins with comparison operators.sql](02.%20Intermediate%20SQL/17.%20Sql%20joins%20with%20comparison%20operators.sql)
- [18. SQL Joins on Multiple Keys.sql](02.%20Intermediate%20SQL/18.%20SQL%20Joins%20on%20Multiple%20Keys.sql)
- [19. SQL Self Join.sql](02.%20Intermediate%20SQL/19.%20SQL%20Self%20Join.sql)

**Foundations**

- [01. Data Types.sql](03.%20Advanced%20SQL/01.%20Data%20Types.sql)
- [02. DateTime Formatting.sql](03.%20Advanced%20SQL/02.%20DateTime%20Formatting.sql)
- [03. Data Wrangling.sql](03.%20Advanced%20SQL/03.%20Data%20Wrangling.sql)

**04. String Functions**

- [04. String Functions Level 1.sql](03.%20Advanced%20SQL/04%20String%20Functions/04.%20String%20Functions%20Level%201.sql)
- [04. String Functions Level 2.sql](03.%20Advanced%20SQL/04%20String%20Functions/04.%20String%20Functions%20Level%202.sql)

**05. Subquery**

- [5. Subquery Day 1.sql](03.%20Advanced%20SQL/05.%20Subquery/5.%20Subquery%20Day%201.sql)
- [5. Subquery Day 2.sql](03.%20Advanced%20SQL/05.%20Subquery/5.%20Subquery%20Day%202.sql)
- [5. Subquery Day 3.sql](03.%20Advanced%20SQL/05.%20Subquery/5.%20Subquery%20Day%203.sql)
- [5. Subquery Day 4.sql](03.%20Advanced%20SQL/05.%20Subquery/5.%20Subquery%20Day%204.sql)
- [5. Subquery in Select Clause.sql](03.%20Advanced%20SQL/05.%20Subquery/5.%20Subquery%20in%20Select%20Clause.sql)
- [5. Subquery in where clause.sql](03.%20Advanced%20SQL/05.%20Subquery/5.%20Subquery%20in%20where%20clause.sql)
- [5. Subquery Test All Topics.sql](03.%20Advanced%20SQL/05.%20Subquery/5.%20Subquery%20Test%20All%20Topics.sql)

**06. Window Functions**

- [6.1 Window Functions Foundations.sql](03.%20Advanced%20SQL/06.%20Window%20Functions/6.1%20Window%20Functions%20Foundations.sql)
- [6.2 Window Functions Aggregate Functions.sql](03.%20Advanced%20SQL/06.%20Window%20Functions/6.2%20Window%20Functions%20Aggregate%20Functions.sql)
- [6.3 Window Functions Ranking Functions.sql](03.%20Advanced%20SQL/06.%20Window%20Functions/6.3%20Window%20Functions%20Ranking%20Functions.sql)
- [6.4 Window Functions Value Functions.sql](03.%20Advanced%20SQL/06.%20Window%20Functions/6.4%20Window%20Functions%20Value%20Functions.sql)
- [6.5 Window Function Frame Clause.sql](03.%20Advanced%20SQL/06.%20Window%20Functions/6.5%20Window%20Function%20Frame%20Clause.sql)
- [6.6 Window Functions Advanced Combinations.sql](03.%20Advanced%20SQL/06.%20Window%20Functions/6.6%20Window%20Functions%20Advanced%20Combinations.sql)

**07. CTEs**

- [7.1 CTEs Foundations.sql](03.%20Advanced%20SQL/07.%20CTEs/7.1%20CTEs%20Foundations.sql)
- [7.2 CTEs Intermediate.sql](03.%20Advanced%20SQL/07.%20CTEs/7.2%20CTEs%20Intermediate.sql)
- [7.3 CTEs Advanced.sql](03.%20Advanced%20SQL/07.%20CTEs/7.3%20CTEs%20Advanced.sql)
- [7.4 CTEs Professional Patterns.sql](03.%20Advanced%20SQL/07.%20CTEs/7.4%20CTEs%20Professional%20Patterns.sql)

**Dataset and assessment**

- [Dataset folder](Dataset/)
- [Advanced SQL Assessment.sql](SQL%20Assessment/Advanced%20SQL%20Assessment.sql)

---

## Run It Yourself

1. Install PostgreSQL and a client such as DBeaver or `psql`.
2. Create a database named `dvdrental`:
   ```bash
   createdb -U postgres dvdrental

   ```
3. Restore the included directory-format backup from the repository root:
   ```bash
   pg_restore -U postgres -d dvdrental "Dataset/dvdrental"

   ```
   If your PostgreSQL username differs from `postgres`, replace it accordingly. You can also restore the backup through a PostgreSQL client that supports directory-format backups.
4. Open a SQL file in DBeaver or another SQL client connected to the restored database and execute the queries.

Start with `01. Basic SQL` and work through the levels, or open the assessment to review the more comprehensive problems.

---

## Work With Me

I am building toward professional work in data analysis, with an interest in SQL querying and reporting, data cleaning, Python analysis, and Power BI dashboards.

For professional inquiries, you can connect with me through [my GitHub profile](https://github.com/TheAbdullahWaseem). Additional portfolio and contact links can be added as they become available.

---

## Closing Note

Learning SQL involves more than memorizing syntax. It also means questioning the data, testing the result, and checking whether the numbers can be trusted. That is the habit I aim to carry into every analysis and, eventually, every model I help build.

*This repository will keep growing as I do.*