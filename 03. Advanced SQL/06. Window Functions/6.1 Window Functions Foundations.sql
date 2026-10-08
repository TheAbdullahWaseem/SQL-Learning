--SECTION A1 — FOUNDATION

--Topic 1: What is a Window Function (Concept + Mental Model)

--Before Window Functions — One thing You MUST Understand
--Before window functions, SQL has only two “ways of thinking”:


--1. Row-by-row thinking (Base SQL)
--Each row is independent:

SELECT * FROM payment;

--SQL just returns rows.


--2. Group thinking (GROUP BY)
--Rows collapse into summaries:

SELECT customer_id, SUM(amount)
FROM payment
GROUP BY customer_id;

--Now:
--many rows → one row per group
--detailed data is LOST

--The Problem Window Functions Solve
--Let’s think in real business terms.

/*From dvdrental.payment:

customer_id			amount
1					5
1					3
1					7
2					4
2					8

BUSINESS QUESTION:
“Show each payment, AND also show total spending of that customer next to it.”*/

--Try GROUP BY logic:

SELECT customer_id, SUM(amount)
FROM payment
GROUP BY customer_id;

--Problem:
--You lost individual payments
--You cannot see row-level detail anymore


--Try JOIN logic:
--You can do it, but it becomes complex and inefficient.

SELECT 
    c.customer_id,
    c.first_name,
    p.payment_id,
    p.amount,
    t.total_spent
FROM customer c
JOIN payment p
    ON c.customer_id = p.customer_id
JOIN (
    SELECT customer_id, SUM(amount) AS total_spent
    FROM payment
    GROUP BY customer_id
) t
    ON c.customer_id = t.customer_id
ORDER BY c.customer_id;


--This is where Window Functions are born
--They solve this exact problem:
--“I want aggregation BUT I do NOT want to lose rows.”

--CORE DEFINITION 
--Window Function =

--A function that performs calculations across a set of related rows
--WITHOUT collapsing the result into a single row.

--window functions are about
--enhancing each row with extra information

--Simple Definition
--Window functions allow us to perform calculations across a set of
--rows related to the current row, while preserving row-level detail.

--FIRST REAL EXAMPLE
--Table: payment
--Step 1 — Normal data

select customer_id, payment_id, amount
from payment;

--Step 2 — Add Window Function

select 
	customer_id,
	payment_id,
	amount,
	sum(amount) over (Partition by customer_id) as total_spent_by_customer
from payment;

--In output you can see that rows are still intact.

--THIS IS THE BREAKTHROUGH MOMENT
--You are doing:
--aggregation WITHOUT GROUPING

/*
CORE DIFFERENCE IN ONE LINE

GROUP BY			WINDOW FUNCTION
collapses rows		keeps rows
summary output		enriched rows
loses detail		preserves detail*/



--SECTION A1 — Topic 2
--Difference Between GROUP BY and Window Functions
--
--Both GROUP BY and Window Functions deal with:
--multiple rows → some computation
--BUT they answer TWO completely different questions.

--1. GROUP BY = “Shrink the data”
--Mental Model:
--“I want to collapse rows into summary rows.”

SELECT customer_id, SUM(amount)
FROM payment
GROUP BY customer_id;

--What SQL is doing:
--For each customer:

--collect all rows
--calculate SUM
--return ONE row

--2. WINDOW FUNCTION = “Enhance each row”
--Mental Model:
--“I want to keep all rows but attach group-level intelligence.”

select
	customer_id,
	payment_id,
	amount,
	sum(amount) over (partition by customer_id) as total_spent
from payment;

/*
WHY TWO SYSTEMS EXIST

SQL designers needed TWO tools:

1. GROUP BY = Reporting tool

Used when:

summaries needed
dashboards
totals
KPIs

Example:

total revenue per customer
number of rentals per film

2. WINDOW FUNCTION = Analytics tool

Used when:

comparisons needed
rankings needed
trends needed
row-level insights needed

Example:

customer total next to each transaction
ranking films by revenue
running totals
*/

--REAL BUSINESS DIFFERENCE

--GROUP BY QUESTION:
--“How much did each customer spend?”

--WINDOW FUNCTION QUESTION:
--“For each transaction, show how much the customer has spent so far.”

--GROUP BY:
--memory: lower
--output: smaller table

--WINDOW FUNCTION:
--memory: higher
--output: same size as input

--Can window functions replace GROUP BY?
--
--Answer:
--No
--Because:

--GROUP BY changes structure
--window functions do not
--They are not interchangeable.


--WHEN TO USE WHAT (PRO RULES)
--
--Use GROUP BY when:

--final output is summary
--you do NOT need row details
--KPI/reporting

--Use WINDOW FUNCTION when:

--you need row-level detail
--AND aggregated insight together
--analytics, ranking, trends


--SECTION A1 — Topic 3
--The OVER() Clause — Syntax and Structure
/*
1. What is OVER()?
Simple definition:
OVER() defines the “window” (set of rows) on which a window function operates.

But that’s still abstract.
Let’s make it concrete.

Think Like This:

When you write:

SUM(amount) OVER (...)

You are telling SQL:

“Don’t collapse rows. Instead, define a window of rows and compute
SUM over that window for each row.”

KEY IDEA 
OVER() = “Context builder for each row”

It tells SQL:

which rows to look at
how to group them logically
whether to order them
but NOT to reduce rows
*/

--2. Basic Syntax structure

<function>() OVER (
    [PARTITION BY ...]
    [ORDER BY ...]
    [frame clause]
)

--Example:
--SUM(amount) OVER (PARTITION BY customer_id)

--Break it into 2 parts:
--PART 1 — Function
--SUM(amount)
--What to calculate

--PART 2 — OVER()
--OVER (PARTITION BY customer_id)
--Where to calculate it (the window)

/*3. WHY OVER() EXISTS (CORE CONCEPT)

Without OVER():

SUM(amount)
SQL says:
“You want aggregation → I must collapse rows”

With OVER():

SUM(amount) OVER(...)
SQL says:
“You want aggregation, but don’t collapse rows — okay, I will compute per row”*/

--4. OVER() = WINDOW DEFINITION SYSTEM
--Think of OVER() as defining 3 things:

--1. Partition (GROUP LOGIC)
--PARTITION BY customer_id
--divides data into groups

--2. Order (SEQUENCE LOGIC)
--ORDER BY payment_date
--defines row sequence inside group

--3. Frame (VISIBLE ROW RANGE)
--ROWS BETWEEN ...
--defines how many rows are “visible” to current row

--5. DVD RENTAL EXAMPLE
SELECT
    customer_id,
    payment_id,
    amount,
    SUM(amount) OVER (PARTITION BY customer_id) AS total_spent
FROM payment;

/*What OVER() is doing internally

For each row:

Step 1: Identify partition
Customer = 1
Rows:

5
3
7

Step 2: Apply function
SUM = 15

Step 3: Attach result to EACH row
row	result
5	15
3	15
7	15*/

--7. OVER() WITH ORDER (INTRODUCTION)
SUM(amount) OVER (ORDER BY payment_date)
--
--Now SQL changes behavior:
--
--It starts building a running window

--Example behavior:

--Row 1 → sum of first row
--Row 2 → sum of first + second
--Row 3 → sum of first + second + third

--This is called:
--Running Total

--IMPORTANT INSIGHT
--Adding ORDER BY inside OVER() changes:
--“whole group” → “progressive window”

--8. OVER() STRUCTURE IS FLEXIBLE

--You can mix:

--Only Partition
--OVER (PARTITION BY customer_id)
select
	customer_id, 
	payment_id,
	amount,
	sum(amount) over (partition by customer_id) as total_spent
from payment;

--Only Order
--OVER (ORDER BY customer_id)
select
	customer_id, 
	payment_id,
	amount,
	sum(amount) over (order by customer_id) as total_spent
from payment;

--Both
--OVER (PARTITION BY customer_id ORDER BY amount)
select
	customer_id, 
	payment_id,
	amount,
	sum(amount) over (partition by customer_id order by amount) as total_spent
from payment;

--None
--OVER ()

--9. PROFESSIONAL MENTAL MODEL
--When you see OVER(), think:

--NOT:
--“SQL function syntax”

--BUT:
--“I am defining how SQL should see rows for each calculation”

--10. WHY OVER() IS POWERFUL
--
--Because it allows:
--
--aggregation + detail together
--ranking systems
--running totals
--comparisons
--trends
--time analysis
--
--ALL WITHOUT losing rows

--13. COMMON MISTAKE (INTERVIEW TRAP)
--
--Beginners think:
--OVER() does calculation
--
--❌ WRONG
--
--Correct understanding:
--OVER() defines WHERE calculation happens

--Mini Practice
SELECT
    customer_id,
    payment_id,
    amount,
    SUM(amount) OVER () AS total_all,
    SUM(amount) OVER (PARTITION BY customer_id) AS total_customer
FROM payment;



SECTION A1 — Topic 4
PARTITION BY — Dividing Data into Groups

1. What is PARTITION BY?
--Simple Definition
--
--PARTITION BY divides rows into logical groups (partitions)
--for window function calculations.

--IMPORTANT
--
--This sounds similar to GROUP BY…
--BUT:
--partitions do NOT collapse rows.
--That is the biggest thing to remember.

--GROUP BY:
--“Create one output row per group”

--PARTITION BY:
--“Create temporary logical groups for calculations while keeping all rows.”

--Think Like This
--Imagine SQL saying:

--GROUP BY
--I will MERGE rows together.

--PARTITION BY
--I will KEEP rows separate,
--but calculations will happen inside logical groups.

2. FIRST SIMPLE EXAMPLE

SELECT
    customer_id,
    payment_id,
    amount,
    SUM(amount) OVER (PARTITION BY customer_id) AS total_customer_spending
FROM payment;
/*
What PARTITION BY does here

It divides rows into customer groups.

Partition for customer_id = 1
payment_id	amount
101			5
102			7
103			3

SUM = 15

Partition for customer_id = 2
payment_id	amount
201			4
202			8

SUM = 12

Then SQL attaches result to EACH row
payment_id	amount	total

101			5		15
102			7		15
103			3		15

KEY INSIGHT
The partition is:

NOT a real table
NOT physically separated data

It is:
a logical grouping during computation*/

3. INTERNAL EXECUTION MODEL 
/*
When SQL sees:
PARTITION BY customer_id

it internally thinks:

Step 1
Read rows

Step 2
Group rows logically by customer_id

Step 3
For each partition:
apply window function
return result per row

IMPORTANT

After calculation:
partitions disappear
They only exist temporarily during execution.*/

--Window functions are fundamentally about:
--row context

6. PARTITION BY WITHOUT AGGREGATES
--This is VERY important because later ranking functions use this heavily.

SELECT
    customer_id,
    payment_id,
    amount,
    ROW_NUMBER() OVER (PARTITION BY customer_id)
FROM payment;
/*
Meaning
For EACH customer:

numbering restarts
Customer 1

1
2
3

Customer 2

1
2

THIS IS HUGE
PARTITION BY is not only for SUM/AVG.

It defines:
analytical boundaries*/

select
	customer_id,
	payment_id,
	amount,
	sum(amount) over (partition by customer_id) as total_spent,
	row_number() over (partition by customer_id) as row_number
from payment;

7. MULTIPLE PARTITION COLUMNS
/*
Example
PARTITION BY store_id, customer_id
Meaning

Create partitions by COMBINATION of:

store_id
customer_id

Similar to GROUP BY logic:
(store_id, customer_id)

becomes unique grouping key.

REAL BUSINESS EXAMPLE

Imagine:
customer spending per store

Same customer may belong to different stores.*/

select
	c.customer_id,
	c.first_name || ' ' || c.last_name as full_name,
	p.payment_id,
	p.amount,
	sum(p.amount) over (partition by c.customer_id, c.first_name, c.last_name) as total_spent,
	row_number() over (partition by c.customer_id) as row_number
from payment p
join customer c
	on c.customer_id = p.customer_id;

8. PARTITION BY VS WHERE (IMPORTANT)
/*
WHERE
Filters rows OUT.

PARTITION BY
Keeps rows,
but divides them into calculation groups.

Example
WHERE
WHERE customer_id = 1

Only customer 1 remains.

PARTITION BY
PARTITION BY customer_id

All customers remain.

But calculations happen separately.*/

9. OVER() WITHOUT PARTITION BY
/*
Example
SUM(amount) OVER ()

Meaning
entire table = one partition

So:
Case							Meaning
no PARTITION BY					whole table
PARTITION BY customer_id		one partition per customer*/

select
	customer_id,
	payment_id,
	amount,
	sum(amount) over ()
from payment;

10. INTERNAL SORTING NOTE (PRO INSIGHT)
/*
PARTITION BY often requires:

internal grouping
sorting/hash operations

This is why:
window functions can become expensive on huge datasets.

Especially:
PARTITION BY many_columns

Optimization Tip
Partition only by what is truly needed.

Bad:
PARTITION BY customer_id, city_id, country_id, store_id
unless business logic truly requires it.*/

--Mini Practice
SELECT
    customer_id,
    payment_id,
    amount,
    COUNT(*) OVER (PARTITION BY customer_id) AS payment_count
FROM payment;

SELECT
    staff_id,
    payment_id,
    amount,
    SUM(amount) OVER (
        PARTITION BY staff_id
    ) AS staff_total
FROM payment;



SECTION A1 — Topics 5 & 6
ORDER BY Inside OVER()
Combining PARTITION BY + ORDER BY Together

--1. VERY IMPORTANT DISTINCTION
--There are TWO completely different ORDER BY clauses in SQL.
--Most beginners confuse them.

--A. ORDER BY Outside OVER()

SELECT *
FROM payment
ORDER BY payment_date;

--Purpose:
--sorts FINAL OUTPUT

--This affects:
--display
--result ordering

--B. ORDER BY Inside OVER()

SUM(amount) OVER (
    ORDER BY payment_date
)

--Purpose:
--controls analytical processing order

--This affects:
--calculations
--running totals
--ranking logic
--sequence behavior
--
--NOT final display.

--THIS DIFFERENCE IS CRITICAL
--OUTER ORDER BY

--Think:
--“How should the final table appear?”

--WINDOW ORDER BY

--Think:
--“In what sequence should calculations happen?”

2. WHY ORDER MATTERS IN ANALYTICS
/*
Without ordering:

SUM(amount) OVER (
    PARTITION BY customer_id
)

every row sees ALL rows in partition.

Example

Customer payments:

date	amount
Jan		5
Feb		3
Mar		7

Every row sees:

[5,3,7]

SUM = 15

But what if we want:

“running total over time”

Now sequence matters.*/

3. FIRST ORDERED window

SELECT
    customer_id,
    payment_date,
    amount,
    SUM(amount) OVER (
        ORDER BY payment_date
    ) AS running_total
FROM payment;
/*
WHAT CHANGED?

Now SQL processes rows sequentially.

INTERNAL BEHAVIOR
Row 1

Visible rows:

[5]

SUM = 5

Row 2

Visible rows:

[5,3]

SUM = 8

Row 3

Visible rows:

[5,3,7]

SUM = 15

THIS IS CALLED:
Running Total / Cumulative Sum
KEY MENTAL MODEL

Adding ORDER BY transforms:

From:
“whole partition”
Into:
“progressively growing window”*/

4. VERY IMPORTANT INTERNAL CONCEPT
/*
When ORDER BY exists inside OVER():

SQL must:

Step 1
Sort rows

Step 2
Process rows sequentially

Step 3
Maintain analytical state

This is why:

running totals work
rankings work
LAG/LEAD works*/

5. COMBINING PARTITION + ORDER
--NOW we reach the real professional pattern.

SELECT
    customer_id,
    payment_date,
    amount,
    SUM(amount) OVER (
        PARTITION BY customer_id
        ORDER BY payment_date
    ) AS customer_running_total
FROM payment;
/*
THIS IS EXTREMELY IMPORTANT

Now SQL says:
Step 1
Divide rows by customer

Step 2
Inside each customer:
sort by payment_date

Step 3
Compute running total separately

VISUALIZATION

Customer 1
date	amount	running
Jan		5		5
Feb		3		8
Mar		7		15

Customer 2
date	amount	running
Jan		4		4
Feb		8		12

IMPORTANT

Running total RESTARTS for each customer.
Because:

PARTITION BY customer_id
creates analytical boundaries.

THIS IS THE PROFESSIONAL MODEL
PARTITION BY → WHO belongs together
ORDER BY     → In what sequence calculations happen*/

6. REAL BUSINESS USE CASES
/*
This exact pattern is everywhere professionally.

A. Customer Spending Growth

SUM(amount) OVER (
    PARTITION BY customer_id
    ORDER BY payment_date
)

B. Daily Revenue Trend

SUM(amount) OVER (
    ORDER BY payment_date
)

C. Ranking Within Department

Later:

RANK() OVER (
    PARTITION BY department
    ORDER BY salary DESC
)

D. Monthly Running Revenue

SUM(amount) OVER (
    PARTITION BY DATE_TRUNC('month', payment_date)
    ORDER BY payment_date
)*/


7. MASSIVE PROFESSIONAL INSIGHT
/*
This combination creates:

“Stateful analytics”
Meaning:

each row depends on:

previous rows
order
context

This is a huge jump from normal SQL.*/

8. DIFFERENCE BETWEEN GROUP BY + ORDER BY VS WINDOW ORDER BY
/*
VERY IMPORTANT.

Normal SQL

SELECT customer_id, SUM(amount)
FROM payment
GROUP BY customer_id
ORDER BY customer_id;

ORDER BY here:
ONLY sorts final result.

Window SQL

SUM(amount) OVER (
    ORDER BY payment_date
)

ORDER BY here:
changes:
analytical logic
computation behavior
visible rows
THIS DIFFERENCE IS CRITICAL*/

9. INTERNAL EXECUTION MODEL (PRO LEVEL)
/*
For:

SUM(amount) OVER (
    PARTITION BY customer_id
    ORDER BY payment_date
)

SQL roughly does:

Step 1
Read rows

Step 2
Partition by customer

Step 3
Sort rows inside partition

Step 4
Scan sequentially

Step 5
Maintain running calculation state

Step 6
Attach result to row

THIS IS WHY WINDOW FUNCTIONS CAN BE EXPENSIVE

Especially:

huge partitions
many sorts
multiple ordered windows*/

10. VERY IMPORTANT DEFAULT BEHAVIOR
/*
When ORDER BY exists:

SQL automatically creates a frame like:

RANGE BETWEEN UNBOUNDED PRECEDING
AND CURRENT ROW

You do NOT fully understand this yet.

That is okay.
We will deeply cover frames later.
For now just understand:
ORDER BY creates progressive visibility*/

11. COMMON BEGINNER MISTAKES
/*
Mistake 1
Thinking outer ORDER BY affects running totals.

❌ Wrong

Mistake 2
Forgetting PARTITION BY.

This accidentally creates:
whole-table running totals

instead of:
per-customer totals

Mistake 3
Using non-deterministic ordering.

Example:
ORDER BY amount
when multiple rows have same amount.
This can create unstable results.*/

13. MINI PRACTICE

--Query 1 — Total Per Customer
--Partition By
SELECT
    customer_id,
    payment_id,
    amount,
    SUM(amount) OVER (
        PARTITION BY customer_id
    ) AS total_customer
FROM payment;

--Query 2 — Running Total Entire Table
--Order By
select
	customer_id,
    payment_date,
    amount,
    SUM(amount) OVER (
        ORDER BY payment_date
    ) AS running_total
FROM payment;

--Query 3 — Running Total Per Customer
--Partition and Order By
select
	customer_id,
    payment_date,
    amount,
    SUM(amount) OVER (partition by customer_id
        ORDER BY payment_date
    ) AS running_total
FROM payment;