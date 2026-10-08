SECTION A3 — Ranking Functions
Topic 12 — ROW_NUMBER()

--Unique Sequential Numbers
--This is one of the MOST important analytical functions in professional SQL.
--Not because it is difficult syntactically.
--
--But because:
--it solves extremely important real-world analytical problems.

PART 1 — The Core Mental Model

--Before syntax…
--you must deeply understand:
--what problem ROW_NUMBER() solves.

--Suppose a company asks:
--“For every customer, show their rentals from oldest to newest.”

Not grouped.
Not aggregated.

The business still wants:

every rental row preserved
BUT with sequential ordering INSIDE each customer history

Example:

customer_id		rental_date		sequence
1				Jan 2			1
1				Jan 5			2
1				Jan 9			3
2				Jan 1			1
2				Jan 3			2

--This is NOT a GROUP BY problem.
--This is:
--ordered analytical numbering


--The True Purpose of ROW_NUMBER()
--ROW_NUMBER() creates:
--a unique sequential position inside a window

--Extremely Important Understanding

--ROW_NUMBER() is NOT:

--aggregation
--grouping
--collapsing rows

--Instead:
--it adds analytical metadata to rows.

--This is the core philosophy of window functions.


PART 2 — Syntax

ROW_NUMBER() OVER (
    PARTITION BY ...
    ORDER BY ...
)
/*
Internal Conceptual Execution

The database conceptually does this:

Step 1 — Build partitions

Example:
PARTITION BY customer_id
Database mentally separates rows into groups.

Step 2 — Sort rows inside each partition

Example:
ORDER BY rental_date
Now each customers rows are sorted.

Step 3 — Assign sequential numbers

Database walks row-by-row:

1
2
3
4
...
CRITICAL UNDERSTANDING

The numbering is based entirely on:
the ORDER BY inside OVER()
This is EVERYTHING.

Without ordering:
row numbering is meaningless.*/

SELECT
    customer_id,
    rental_id,
    rental_date,

    ROW_NUMBER() OVER (
        PARTITION BY customer_id
        ORDER BY rental_date
    ) AS rental_sequence

FROM rental;

--This query answers:
--“What was the exact sequence of customer rentals over time?”

--VERY IMPORTANT — Stateful Analytical Thinking

--This is where SQL becomes analytical engineering.
--The database is conceptually maintaining:

Current customer partition
+
Current ordered position
+
Current row count

This is stateful computation.
Not static filtering.

PART 4 — Why ORDER BY is Mandatory
/*
This is VERY important professionally.
Consider:

ROW_NUMBER() OVER (
    PARTITION BY customer_id
)

This is invalid in PostgreSQL.
Why?
Because:

sequential numbering requires deterministic order

Without order:
there is no meaning to:

first
second
third

This is a deep analytical principle.*/

PART 5 — Unique Numbering Behavior
/*
Now we reach the MOST important characteristic.

ROW_NUMBER() NEVER creates ties
Even if values are identical.

Example:

amount
10
10
10

Still becomes:

amount	row_number
10		1
10		2
10		3

This is VERY important.

Because later:

RANK()
DENSE_RANK()

behave differently.*/

PART 6 — Professional Example: Sales Leaderboard

--Imagine:
--“Rank customers by total spending.”

select
	customer_id,
	sum(amount) as total_spent,
	
	row_number() over (
		order by sum(amount) desc
	) as spending_rank
from payment
group by customer_id;

/*
STOP HERE — IMPORTANT CONCEPT
Notice something avdanced:

ORDER BY SUM(amount)
inside window function.

This means:

aggregation happens first
grouped rows are produced
THEN window function operates on grouped output

This is layered analytical execution.*/

PART 7 — Internal Execution Flow
/*
Professional mental execution:

FROM
→ WHERE
→ GROUP BY
→ aggregates
→ window functions
→ SELECT
→ ORDER BY

Meaning:
window functions operate AFTER aggregation.

This is why:

ROW_NUMBER() OVER (
    ORDER BY SUM(amount)
)

works.
*/
PART 8 — One of the MOST Important Real-World Uses
/*
Deduplication
Professional analysts use ROW_NUMBER() constantly for this.
Suppose a table accidentally has duplicates.

You want:
keep latest record only.
*/
SELECT
    customer_id,
    rental_id,
    rental_date,

    ROW_NUMBER() OVER (
        PARTITION BY customer_id
        ORDER BY rental_date DESC
    ) AS rn

FROM rental;

--Now:
--rn = 1

--means:
--latest rental per customer.

SELECT *
FROM (
    SELECT
        customer_id,
        rental_id,
        rental_date,

        ROW_NUMBER() OVER (
            PARTITION BY customer_id
            ORDER BY rental_date DESC
        ) AS rn

    FROM rental
) t
WHERE rn = 1;
/*
This Pattern Is MASSIVELY Important
This is one of the most famous SQL patterns in industry.

It solves:

latest transaction
latest login
latest status
latest order
latest customer activity
latest shipment
deduplication pipelines

You MUST master this.*/

PART 9 — Why Subquery Needed?

--This is advanced understanding.
--You cannot directly do:

WHERE ROW_NUMBER() ...

because:

--WHERE executes BEFORE window functions
--This is one of the most important execution-order rules.

--So:

--Compute window first
--→ then filter outside

--That is why:

--subqueries
--CTEs
--are commonly combined with window functions.

PART 10 — Professional Analytical Patterns
/*
ROW_NUMBER() is commonly used for:

1. First Purchase Detection
ROW_NUMBER() OVER (
    PARTITION BY customer_id
    ORDER BY payment_date
)

Finds:

first purchase
second purchase
nth purchase
2. Event Sequencing
login 1
login 2
login 3

Used in:

app analytics
behavioral analytics
user journey tracking
3. Top-N Extraction

Later:

WHERE rn <= 3

Used for:

top 3 products
top 5 customers
best movies per category

This becomes:

Top N Per Group

One of the most famous SQL interview problems.*/

PART 11 — Performance Intuition
/*
Very important professionally.

ROW_NUMBER() usually requires:

sorting
partition processing

Sorting is expensive.

Especially:

PARTITION BY + ORDER BY

on huge datasets.

So indexes become important.

Helpful Index Pattern

If frequently running:

PARTITION BY customer_id
ORDER BY rental_date

Helpful index:

(customer_id, rental_date)

Why?

Because database can:

organize rows faster
reduce sorting work

This is optimization intuition.*/

PART 12 — Difference From GROUP BY
/*
This is foundational.

GROUP BY

Collapses rows.

ROW_NUMBER()

Preserves rows
+
adds analytical metadata.

Example:

GROUP BY customer_id

returns:
1 row per customer.

But:

ROW_NUMBER()

returns:
ALL rows.

This distinction is fundamental.*/

PART 13 — Professional Practice Queries

Films By Length Inside Category

select 
	c.name,
	f.title,
	f.length,
	
	row_number() over (
		partition by c.name
		order by f.length desc
	) as length_rank
from film f
join film_category fc
	on f.film_id = fc.film_id
join category c
	on fc.category_id = c.category_id;
	
PART 14 — One Extremely Important Professional Insight
/*
ROW_NUMBER() is not really about numbering.

It is about:

creating deterministic ordered identity inside analytical context.

That is the real mental model.

The numbering is just the visible result.*/

PART 15 — The MOST Important Thing To Remember

/*ROW_NUMBER() guarantees uniqueness.

Even with ties:

every row gets different sequence number.

This is EXACTLY why later:

RANK()
DENSE_RANK()

exist.

Because businesses sometimes WANT ties.

And sometimes they DONT.

That distinction is one of the most important analytical decisions in SQL.*/

Topic 13 — RANK()

--Ranking With Gaps for ties
--
--the question becomes:
--“Should tied values share the same rank?”
--ROW_NUMBER() said:
--NO
--
--RANK() says:
--YES

PART 1 — The Core Mental Model
/*
RANK() creates:

competitive ranking

Meaning:

If two rows tie,
they receive the same rank.

But:

the next rank is skipped.

This is the defining behavior.

Example

Suppose sales are:

customer	sales
A			100
B			90
C			90
D			70

Using RANK():

customer	sales	rank
A			100		1
B			90		2
C			90		2
D			70		4

Notice carefully:

There is NO rank 3.

Why?

Because:
two rows occupied rank 2.

This is called:

ranking with gaps
Real-World Analogy

Think about sports competitions.

If two runners tie for second place:

1st
2nd
2nd
4th

There is no 3rd place.

That is EXACTLY how RANK() behaves.

Core Philosophy

RANK() prioritizes:

fairness of ties

over:

uniqueness of numbering

This is the opposite philosophy from ROW_NUMBER().*/

PART 2 — Syntax

RANK() OVER (
    PARTITION BY ...
    ORDER BY ...
)
/*
Structurally:
looks identical to ROW_NUMBER().

But internally:
the ranking logic changes completely.*/

PART 3 — Internal Analytical Logic
/*
This is the important part.

The database conceptually tracks:

current ordered value
previous ordered value
current rank
tie groups
Internal Conceptual Process

Imagine ordered values:

100
90
90
70

The engine walks row-by-row:

First Row
100

First row always becomes:

rank = 1
Second Row
90

Value changed from 100 → 90

So:

rank = 2
Third Row
90

Same as previous value.

So:

rank remains 2
Fourth Row
70

Now database asks:

“How many rows came before this?”

Answer:

3 rows

So:

rank = 4

This creates the gap.

VERY IMPORTANT UNDERSTANDING

RANK() does NOT increment row-by-row.

Instead:
it increments based on:

position in ordered dataset

This is the key difference.*/

PART 4 — First Professional Query

select 	
	customer_id,
	sum(amount) as total_spend,
	
	rank() over (
		order by sum(amount) desc
	) as spending_rank
from payment
group by customer_id;


--In below query it ranks on sum(amount) and then customer_id,
--run both queries and see the difference at rank 25
select 	
	customer_id,
	sum(amount) as total_spend,
	
	rank() over (
		order by sum(amount) desc, customer_id
	) as spending_rank
from payment
group by customer_id;

--This answers:
--“What is each customer’s spending rank?”
--
--But importantly:
--
--customers with equal spending:
--share rank
--are treated equally analytically

PART 5 — The Most Important Difference From ROW_NUMBER()
/*
Look carefully.

ROW_NUMBER()
100 → 1
90  → 2
90  → 3
70  → 4

Unique numbering always.

RANK()
100 → 1
90  → 2
90  → 2
70  → 4

Ties share ranks.*/

PART 6 — Why ORDER BY Is EVERYTHING
/*
Like all ranking functions:
ranking is completely dependent on ordered context.

Example:

RANK() OVER (
    ORDER BY SUM(amount) DESC
)

Meaning:

highest spender = rank 1
second highest = rank 2

Reverse ordering:

ORDER BY SUM(amount) ASC

Now:

smallest spender = rank 1

Same function.
Completely different business meaning.*/

PART 7 — Partitioned Ranking
/*
Now we move into professional analytical ranking.

Business Question

“Rank films by length INSIDE each category.”

This is very realistic business analytics.*/

SELECT
    c.name AS category,
    f.title,
    f.length,

    RANK() OVER (
        PARTITION BY c.name
        ORDER BY f.length DESC
    ) AS length_rank

FROM film f
JOIN film_category fc
    ON f.film_id = fc.film_id
JOIN category c
    ON fc.category_id = c.category_id;

/*
What Happens Internally

Database conceptually:

Step 1

Creates separate category partitions.

Action
Comedy
Drama
Horror
...
Step 2
Sorts films inside each category by length.

Step 3
Assigns ranks with tie-awareness.*/

PART 8 — Professional Use Cases
/*
RANK() is extremely common in analytics.

1. Leaderboards
Top sales reps
Top gamers
Top athletes
Top stores

Businesses often WANT ties.

2. Scholarship Systems

Students with same marks:
should receive same rank.

3. Sales Competitions

Equal performance should receive equal placement.

4. KPI Reporting

Executives often expect:
fair ranking logic.*/

PART 9 — Very Important Filtering Pattern
/*
Suppose business asks:

“Show top 3 customers by spending.”

You may think:

WHERE rank <= 3

But with RANK():
this can return MORE than 3 rows.

Why?

Because ties expand result size.

Example
customer	sales	rank
A	100	1
B	90	2
C	90	2
D	85	4

Now:

WHERE rank <= 3

returns:

customer
A
B
C

Three rows returned.

But there is no rank 3.

This is VERY important analytically.*/

PART 10 — Professional Top-N Pattern

SELECT *
FROM (
    SELECT
        customer_id,
        SUM(amount) AS total_spent,

        RANK() OVER (
            ORDER BY SUM(amount) DESC
        ) AS spending_rank

    FROM payment
    GROUP BY customer_id
) t
WHERE spending_rank <= 5;

PART 11 — Internal Difference From ROW_NUMBER()
/*
This is the deep engine-level intuition.

ROW_NUMBER()

Tracks:

current sequential position

Simple counter.

RANK()

Tracks:

current ordered value
+
tie groups
+
position offsets

Much more analytical state management.*/

PART 12 — Important Determinism Insight
/*
Suppose ties exist:

customer	sales
B			90
C			90

Their rank is stable:

2
2

But:
their internal output order may still vary unless additional sorting exists.

Very important professionally.

Stable Deterministic Ranking Pattern
RANK() OVER (
    ORDER BY SUM(amount) DESC,
             customer_id
)

Now:

ranking still based primarily on spending
ties become consistently ordered

This matters in:

dashboards
exports
pagination
reporting reproducibility*/

select 	
	customer_id,
	sum(amount) as total_spend,
	
	rank() over (
		order by sum(amount) desc
	) as spending_rank
from payment
group by customer_id;


--In below query it ranks on sum(amount) and then customer_id,
--run both queries and see the difference at rank 25
select 	
	customer_id,
	sum(amount) as total_spend,
	
	rank() over (
		order by sum(amount) desc, customer_id
	) as spending_rank
from payment
group by customer_id;

PART 13 — Ranking vs Aggregation
/*
Again:
ranking functions:

preserve rows
add analytical metadata

They do NOT collapse rows.

This distinction remains foundational.*/

PART 14 — Performance Intuition
/*
Like ROW_NUMBER():
RANK() requires sorting.

And tie detection adds additional processing logic.

Expensive operations:

large partitions
heavy sorting
high-cardinality analytics

Indexes helping:

(partition_column, ordering_column)

remain extremely useful.*/

PART 15 — Professional Analytical Insight
/*
The real purpose of RANK() is:

modeling competitive position fairly.

That is the mental model.

Not numbering.

Not sequencing.

But:

competitive analytical ranking.*/

PART 16 — Practice Queries

--Query 1 — Customer Payment Rank Per Customer

SELECT
    customer_id,
    payment_id,
    amount,

    RANK() OVER (
        PARTITION BY customer_id
        ORDER BY amount desc
    ) AS payment_rank

FROM payment;

--Query 2 — Monthly Revenue Rank

SELECT
    DATE_TRUNC('month', payment_date) AS month,
    SUM(amount) AS revenue,
    
    rank() over (
    	order by sum(amount) desc
    ) as revenue_rank
 from payment
 group by month;
    
    
Topic 14 — DENSE_RANK()
Ranking Without Gaps
    
--DENSE_RANK() is conceptually a modification of RANK().
--The BIG idea is simple:

--Core Mental Model

--DENSE_RANK():
--allows ties
--BUT does NOT skip ranks
--That is the entire philosophy.
/*
Example

Suppose:

customer	sales
A			100
B			90
C			90
D			70

RANK()

customer	rank
A			1
B			2
C			2
D			4

Gap exists.

DENSE_RANK()

customer	dense_rank
A			1
B			2
C			2
D			3

No gap.

Mental Model

RANK()
Ranks based on:
physical row position

DENSE_RANK()
Ranks based on:
distinct ordered values

This is the key difference.

Internal Conceptual Logic
Suppose ordered values:

100
90
90
70

Database conceptually tracks:

Distinct value groups
Value Groups
100 → group 1
90  → group 2
70  → group 3

So ranks become:

1
2
2
3
Syntax
DENSE_RANK() OVER (
    PARTITION BY ...
    ORDER BY ...
)

Same structure as other ranking functions.

Only ranking behavior changes.
That is the defining behavior.*/

SELECT
    customer_id,
    SUM(amount) AS total_spent,

    DENSE_RANK() OVER (
        ORDER BY SUM(amount) desc
    ) AS spending_rank

FROM payment
GROUP BY customer_id;

/*
Why Businesses Prefer DENSE_RANK Sometimes

Suppose executive sees:

1
2
2
4

They ask:

“Where is rank 3?”

This happens constantly in real business reporting.

DENSE_RANK() solves this.

Most Important Comparison

Function		Ties Allowed		Gaps

ROW_NUMBER		No					No
RANK			Yes					Yes
DENSE_RANK		Yes					No

This table is foundational.

Visual Comparison

Suppose:

100
90
90
70

ROW_NUMBER
1
2
3
4

RANK

1
2
2
4

DENSE_RANK

1
2
2
3

This is the entire ranking ecosystem.
**/

--Professional Query — Film Ranking Per Category

SELECT
    c.name AS category,
    f.title,
    f.length,

    DENSE_RANK() OVER (
        PARTITION BY c.name
        ORDER BY f.length DESC
    ) AS length_rank

FROM film f
JOIN film_category fc
    ON f.film_id = fc.film_id
JOIN category c
    ON fc.category_id = c.category_id;

--Top-N Behavior
/*
This is VERY important.

With:

WHERE dense_rank <= 3

you may still get more than 3 rows.

Because ties still exist.

Example:

1
2
2
3

returns 4 rows.

Important professionally.*/

Performance

--Performance characteristics are nearly identical to:
--
--RANK()
--ROW_NUMBER()
--
--because all require:
--
--sorting
--partition processing
--ordered analytical computation

One Important Professional Insight
/*
ROW_NUMBER()

answers:
“What exact row position is this?”

RANK()

answers:
“What competitive position is this?”

DENSE_RANK()

answers:

“What distinct value level is this?”
That is the best mental distinction.*/

Topic 15 — Difference Between
ROW_NUMBER() vs RANK() vs DENSE_RANK()

The Entire Difference in One table
| Function       | Ties Allowed? | Gaps After Ties? | Main Purpose          |
| -------------- | ------------- | ---------------- | --------------------- |
| `ROW_NUMBER()` | ❌ No          | ❌ No             | Unique row sequencing |
| `RANK()`       | ✅ Yes         | ✅ Yes            | Competitive ranking   |
| `DENSE_RANK()` | ✅ Yes         | ❌ No             | Compact ranking       |

/*
ROW_NUMBER()

Asks:

“What exact row position is this?”
Every row must be unique.
Even ties are forced apart.

RANK()

Asks:

“What competitive position is this?”
Ties share position.
Next rank skips.

DENSE_RANK()

Asks:

“What distinct level/group is this?”
Ties share position.
No gaps.*/

When To Use ROW_NUMBER()
/*
Use when:

uniqueness matters more than fairness.

Examples:

latest record per customer
deduplication
pagination
first event detection
sequential event tracking*/

When To Use RANK()
/*
Use when:

competitive fairness matters.

Examples:

sports ranking
sales competitions
scholarship positions
leaderboard systems

Because ties should share rank.*/

When To Use DENSE_RANK()
/*
Use when:

business wants clean ranking levels.

Examples:

dashboard reporting
customer tiers
KPI segmentation
executive analytics

Because gaps often confuse business users.*/

Technical Internal Difference
/*
Conceptually:

ROW_NUMBER()

Maintains:
simple counter

RANK()

Maintains:
counter
+
tie offsets

DENSE_RANK()

Maintains:
distinct value groups

This is the internal analytical distinction.*/

One Extremely Important Professional Rule
/*
If business says:

“Exactly 10 rows”

Use:

ROW_NUMBER()

because it guarantees uniqueness.

If business says:

“Top 10 ranks fairly”

Use:

RANK() or DENSE_RANK()

because ties matter.

This distinction is critical professionally.*/

Best Comparison Query

SELECT
    customer_id,
    SUM(amount) AS total_spent,

    ROW_NUMBER() OVER (
        ORDER BY SUM(amount) DESC
    ) AS row_num,

    RANK() OVER (
        ORDER BY SUM(amount) DESC
    ) AS rank_num,

    DENSE_RANK() OVER (
        ORDER BY SUM(amount) DESC
    ) AS dense_rank_num

FROM payment
GROUP BY customer_id;

Partitioned Comparison Query

SELECT
    c.name AS category,
    f.title,
    f.rental_rate,

    ROW_NUMBER() OVER (
        PARTITION BY c.name
        ORDER BY f.rental_rate DESC
    ) AS row_num,

    RANK() OVER (
        PARTITION BY c.name
        ORDER BY f.rental_rate DESC
    ) AS rank_num,

    DENSE_RANK() OVER (
        PARTITION BY c.name
        ORDER BY f.rental_rate DESC
    ) AS dense_rank_num

FROM film f
JOIN film_category fc
    ON f.film_id = fc.film_id
JOIN category c
    ON fc.category_id = c.category_id;

Final Professional Summary
/*
Function			Think Like

ROW_NUMBER()		Exact row identity
RANK()				Competitive placement
DENSE_RANK()		Distinct ranking level*/ 


Topic 16 — NTILE(n)
Dividing Rows Into Buckets
/*
This topic is much deeper than it first appears.

Because NTILE() is not just about numbering.

It is about:
segmentation.
And segmentation is one of the MOST important concepts in analytics.

Used everywhere in:

customer analytics
business intelligence
marketing
risk analysis
sales analytics
performance reporting
finance
recommendation systems*/

PART 1 — The Core Mental Model
/*
NTILE(n) divides ordered rows into:
approximately equal-sized groups (buckets)
This is the entire idea.

Example

Suppose you have:
20 customers
And you run:

NTILE(4)

The database divides customers into:
4 groups
Each group gets approximately:
5 customers

Visual Example

Suppose customer spending ordered descending:

customer	spending
A			1000
B			950
C			900
D			850
E			800
F			750
G			700
H			650

NTILE(4)

Produces:

customer	tile
A			1
B			1
C			2
D			2
E			3
F			3
G			4
H			4

Meaning:

Tile 1 → top quarter
Tile 2 → upper-middle
Tile 3 → lower-middle
Tile 4 → bottom quarter

This is segmentation analytics.*/

PART 2 — The Real Purpose of NTILE
/*
NTILE() answers questions like:

“Which percentile group does this row belong to?”

or

“Which performance bucket?”

or

“Which customer tier?”

This is VERY business-oriented SQL.*/

PART 3 — Syntax

NTILE(n) OVER (
    PARTITION BY ...
    ORDER BY ...
)
/*
Where:

n = number of buckets
Examples
NTILE(4)

Quartiles.

NTILE(10)

Deciles.

NTILE(100)

Percentile-style segmentation.

Very common in enterprise analytics.*/

PART 4 — Internal Analytical Logic
/*
This is the important part.
The database conceptually performs:

Step 1 — Sort rows

Based on:
ORDER BY

Step 2 — Count rows

Suppose:
20 rows

Step 3 — Divide rows into buckets

Example:
20 / 4 = 5 rows per bucket

Step 4 — Assign tile numbers

1
1
1
1
1

2
2
2
2
2

3
3
3
3
3

4
4
4
4
4
VERY IMPORTANT UNDERSTANDING

NTILE() distributes:

rows
NOT values.

This distinction is critical.

Example of Important Consequence
Suppose:

customer	spending
A			100
B			100
C			100
D			50

Using:

NTILE(2)

Possible result:

customer	tile
A			1
B			1
C			2
D			2

Notice:
equal values got separated.

Why?

Because:
NTILE() balances row counts.

NOT tie groups.

This is VERY important professionally.*/

PART 5 — Difference From Ranking Functions
/*
This is foundational.

RANK() / DENSE_RANK()

Concerned with:

relative position

NTILE()

Concerned with:
segmentation buckets

Completely different analytical purpose.*/

PART 6 — First Professional Query
Customer Spending Quartiles

select
	customer_id,
	sum(amount),
	
	ntile(5) over (
		order by sum(amount) desc
	) as spending_quartiles
from payment
group by customer_id;

/*
Business Meaning

This creates:

Quartile	Meaning

1			highest spenders
2			upper-middle
3			lower-middle
4			lowest spenders

This is classic customer segmentation.

VERY IMPORTANT ANALYTICAL INSIGHT

Businesses rarely analyze:

every individual customer

Instead they analyze:

groups

Examples:

top 10%
high-value customers
medium-value customers
low-value customers

This is exactly what NTILE() enables.*/

PART 7 — Why ORDER BY Direction Matters MASSIVELY
/*
Descending Order
ORDER BY SUM(amount) DESC

Tile 1 becomes:

best customers
Ascending Order
ORDER BY SUM(amount) ASC

Tile 1 becomes:

worst customers

Same function.
Completely different business meaning.

This is VERY important.*/

PART 8 — Uneven Distribution Behavior
/*
Suppose:

10 rows
NTILE(4)

10 cannot divide evenly into 4.

So what happens?

PostgreSQL Behavior

Earlier buckets receive extra rows.

Example
10 / 4

Becomes:

Tile	Rows
1	3
2	3
3	2
4	2

This is important professionally.*/

PART 9 — Partitioned NTILE
/*
Now we move into real analytical segmentation.

Business Question
“Segment films into 5 length groups INSIDE each category.” 
*/
select
	c.name,
	f.title,
	f.length,
	
	ntile(5) over (
		partition by c.name order by f.length desc
	) as length_bucket
	
from film f
join film_category fc
	on f.film_id = fc.film_id
join category c
	on fc.category_id = c.category_id;
/*
Business Interpretation

Inside EACH category:

Bucket 1 → longest films
Bucket 5 → shortest films

This is comparative segmentation.*/

PART 10 — Enterprise Analytics Use Cases
/*
This is where NTILE() becomes extremely valuable.

1. Customer Segmentation
Top 10% customers
Middle-value customers
Low-value customers

Used everywhere.

2. Credit Risk Analysis

Banks segment:

high-risk
medium-risk
low-risk

using scoring buckets.

3. Sales Team Tiering

Top performers
Average performers
Low performers
4. Marketing Analytics

Segment users by:

activity
engagement
purchase behavior

5. Salary Analysis

Divide employees into:

compensation bands
salary quartiles

Very common in HR analytics.
*/
PART 11 — NTILE vs Percentiles

Important professional distinction.
/*
NTILE(4)

Creates:
quartiles

NTILE(10)

Creates:
deciles

NTILE(100)

Creates:
percentile-style buckets

Though:
true percentiles and PERCENT_RANK() are slightly different.*/

PART 12 — Important Technical Limitation
/*
Unlike:

RANK()
DENSE_RANK()

NTILE() does NOT preserve ties.

This is VERY important.

Equal values may split across buckets.

This surprises many analysts.*/

PART 13 — Performance Intuition
/*
NTILE() requires:

full ordering
row counting
bucket distribution

Meaning:
sorting cost remains important.

Large datasets:

expensive partitions
expensive sorts
memory usage

Indexes helping:

(partition_column, ordering_column)

still matter heavily.*/

PART 14 — Professional Query Patterns
--Monthly Revenue Segmentation

select
	date_trunc('month', payment_date) as month,
	sum(amount) as revenue,
	
	ntile(4) over (
		order by sum(amount) desc
	) as revenue_group
	
from payment
group by month;

PART 15 — One Extremely Important Professional Insight
/*
NTILE() is less about ranking.

And more about:

analytical categorization.

This is the true mental model.

It transforms:

continuous ordered data

into:

business-friendly groups

That is extremely important in BI systems.*/

Topic 17 — PERCENT_RANK()
Percentage-Based Ranking
/*
This topic is important professionally because it moves ranking into:

relative statistical positioning.

Unlike:

ROW_NUMBER()
RANK()
DENSE_RANK()
NTILE()

which mostly answer:

"What bucket or rank is this row?"

PERCENT_RANK() answers:

“What percentage of rows are below this row?”

This is a much more statistical/analytical way of thinking.*/

PART 1 — The Core Mental Model
/*
Suppose a customer spends more than:

80% of customers

That is percentile-style positioning.

Not:

exact rank
bucket
sequence

but:

relative standing in population.

This is the true purpose of PERCENT_RANK().*/

PART 2 — The Formula (VERY IMPORTANT)
/*
Unlike previous ranking functions,
PERCENT_RANK() has an actual mathematical formula.

Conceptually:

	   RANK−1
|-----------------|
	TOTAL_ROWS−1
	​
This formula is foundational.

Meaning of Formula
Component		Meaning
RANK - 1		how many ranking positions are below current row
TOTAL_ROWS - 1	total comparison space

Result becomes:

percentage-style relative position.*/

PART 3 — Very Important Range
/*
PERCENT_RANK() always returns values between:

0 and 1

Meaning:

Value		Meaning

0			lowest rank
1			highest rank
0.5			middle position
0.9			higher than most rows*/

PART 4 — Important Example
/*
Suppose ordered spending:

customer	spending
A			100
B			90
C			80
D			70
E			60

Ranks:

customer	rank
A			1
B			2
C			3
D			4
E			5

Now formula:

	RANK−1
|----------|
	5−1

Results:

customer	percent_rank
A			0
B			0.25
C			0.50
D			0.75
E			1

VERY IMPORTANT OBSERVATION

Highest row becomes:

0

Lowest row becomes:

1

IF ordering is ascending.

But if ordering is descending:
behavior reverses.

This is VERY important.*/

PART 5 — ORDER BY Direction Changes Meaning

/*
Descending Order
ORDER BY SUM(amount) DESC

Produces:

Meaning
0 = best
1 = worst
Ascending Order
ORDER BY SUM(amount) ASC

Produces:

Meaning
0 = worst
1 = best

This confuses many analysts initially.

Always interpret carefully.*/

PART 6 — First Professional Query
Customer Spending Percentile position

select
	customer_id,
	sum(amount) as total_spent,
	
	percent_rank() over (
		order by sum(amount) desc
	) as spending_percentile,
	
	dense_rank() over (
		order by sum(amount) desc
	) as dense_rank,
	
	row_number() over (
		order by sum(amount) desc
	) as row_number

from payment
group by customer_id;
/*
Business Meaning

This answers:

“Where does each customer stand relative to all customers?”

This is MUCH more analytical than simple ranking.

Example Interpretation
percent_rank	meaning
0.01			elite customer
0.20			high-value
0.50			average
0.90			low-value
*/
PART 7 — Difference From NTILE

This is VERY important professionally.
/*
NTILE(4)

Creates:
discrete buckets

Example:

1
2
3
4

PERCENT_RANK()

Creates:
continuous relative positioning

Example:

0.13
0.47
0.82

This is much more granular.
*/
PART 8 — Difference From RANK
/*
RANK()
Answers:

"What exact competitive position?"

PERCENT_RANK()

Answers:
"How relatively high/low is this row?"

Very different analytical purpose.*/

PART 9 — Important Tie Behavior
/*
This is VERY important.

PERCENT_RANK() is based on:

RANK()

NOT:

ROW_NUMBER
DENSE_RANK

Meaning:
ties receive same percent rank.

Example
value
100
90
90
70

Ranks:==-087	

value	rank
100		1
90		2
90		2
70		4

Now formula:

	RANK−1
|----------|
	 4-1	​


Results:

value	percent_rank
100		0
90		0.333
90		0.333
70		1

This is important.
*/

--now check that the rows having same rank also having same percent_row

select
	customer_id,
	date(payment_date),
	amount,
	
	rank() over (
		partition by customer_id order by date(payment_date)
	) as rank,
	
	percent_rank() over(
		partition by customer_id order by date(payment_date)
	) as percent_rank
	
from payment;

PART 10 — Very Important Edge Case
/*
Suppose partition contains:

only 1 row

Then:

TOTAL_ROWS - 1 = 0

Division problem.

PostgreSQL handles this by returning:

0

Important technical detail.*/
	
PART 11 — Partitioned Percentile Ranking
/*
Now real analytical usage.

Business Question
“Within each category, what percentile position is each film by rental rate?”
*/
SELECT
    c.name AS category,
    f.title,
    f.rental_rate,

    PERCENT_RANK() OVER (
        PARTITION BY c.name
        ORDER BY f.rental_rate DESC
    ) AS rental_percentile

FROM film f
JOIN film_category fc
    ON f.film_id = fc.film_id
JOIN category c
    ON fc.category_id = c.category_id;
/*
Business Meaning

Inside EACH category:

0 → best films
1 → weakest films

relative to category peers.*/

PART 12 — Enterprise Analytics Use Cases
/*
This is where PERCENT_RANK() becomes extremely valuable.

1. Credit Scoring

Banks ask:

“Customer risk compared to population?”

2. Salary Benchmarking
Top 5%
Top 10%
Median employees

3. Exam Analytics

Student percentile performance.

4. Customer Value Analytics

Find:

top 1% customers

Very common in marketing.

5. Fraud Detection

Find outliers relative to population.*/

PART 13 — Professional Filtering Patterns
Top 10% Customers

select *
from (
	select 
		customer_id,
		sum(amount) as total_spent,
		
		percent_rank() over (
            order by sum(amount) desc 
        ) as pct_rank

    FROM payment
    GROUP BY customer_id
)
where pct_rank <= 0.10;

PART 14 — Important Analytical Insight
/*
PERCENT_RANK() is:

relative
NOT absolute.

Meaning:
value depends entirely on:

population size
ordering
comparison group

This is crucial professionally.
*/
PART 15 — Performance Intuition
/*
Like all ranking functions:
requires:

sorting
partition processing
rank computation

Performance similar to:

RANK()
DENSE_RANK()

because internally it uses ranking behavior.*/

PART 16 — Important Comparison table

| Function         | Purpose                      |
| ---------------- | ---------------------------- |
| `ROW_NUMBER()`   | unique row sequence          |
| `RANK()`         | competitive rank             |
| `DENSE_RANK()`   | compact rank                 |
| `NTILE()`        | bucket segmentation          |
| `PERCENT_RANK()` | relative percentile position |

PART 17 — Professional Practice Queries

Monthly Revenue Percentile

SELECT
    DATE_TRUNC('month', payment_date) AS month,
    SUM(amount) AS revenue,

    PERCENT_RANK() OVER (
        ORDER BY SUM(amount) DESC
    ) AS revenue_percentile

FROM payment
GROUP BY month;

PART 18 — One Extremely Important Professional Insight
/*
PERCENT_RANK() is one of the first window functions that truly introduces:

statistical analytics thinking inside SQL.
This is important because modern SQL analytics is heavily statistical.

Especially in:

data science
BI systems
finance
ML feature engineering
recommendation systems*/

Topic 18 — Top N Per Group
Classic SQL Interview Problem

PART 1 — The Core Business Problem
/*
Business asks:

“Find the top N rows INSIDE each group.”

This is the key phrase:

inside each group

Examples:

top 3 customers per country
top 5 products per category
highest-paid employee per department
latest order per customer
top-rated movie per genre

This is NOT global ranking.

It is:

partitioned ranking + filtering.*/

PART 2 — Why Beginners Fail This Problem
/*
Many beginners try:

ORDER BY amount DESC
LIMIT 3

This gives:

top 3 overall rows

NOT:
top 3 per group.

This is the fundamental difference.
Example

Suppose:*/

| category | film | rental_rate |
| -------- | ---- | ----------- |
| Action   | A    | 5           |
| Action   | B    | 4           |
| Comedy   | C    | 5           |
| Comedy   | D    | 4           |

/*
Wrong Query

ORDER BY rental_rate DESC
LIMIT 2

Returns:

top 2 overall

NOT:

top 2 per category

This distinction is foundational.*/

PART 3 — The Real Solution Pattern
/*
Top-N-per-group always follows:

Step 1 — Partition
PARTITION BY group_column

Step 2 — Rank Inside Each Partition

Usually using:
ROW_NUMBER()
RANK()
DENSE_RANK()

Step 3 — Filter Ranked Rows
WHERE rank <= N

That is the entire professional pattern.*/

PART 4 — Most Common Professional Pattern
Top 3 Films Per Category

SELECT *
FROM (
    SELECT
        c.name AS category,
        f.title,
        f.rental_rate,

        ROW_NUMBER() OVER (
            PARTITION BY c.name
            ORDER BY f.rental_rate DESC
        ) AS rn

    FROM film f
    JOIN film_category fc
        ON f.film_id = fc.film_id
    JOIN category c
        ON fc.category_id = c.category_id
) t
WHERE rn <= 3;
/*
Business Meaning

Inside EACH category:

1st highest rental rate
2nd highest
3rd highest

This is extremely common professionally.*/

PART 5 — Why Subquery Is Required
/*
You already learned this earlier,
but now it becomes critically important.

This does NOT work:

WHERE ROW_NUMBER() OVER (...) <= 3

Because:

WHERE executes BEFORE window functions

Execution order matters.

So:

compute ranking first
filter outside

using:

subquery
CTE

This is one of the biggest interview concepts.*/

PART 6 — Choosing Correct Ranking Function
This is VERY important professionally.
/*
Using ROW_NUMBER()

ROW_NUMBER()
Guarantees:
exactly N rows per group
because ties are broken uniquely.

Using RANK()

RANK()
Allows:
ties
gaps

Result may contain:
more than N rows

Using DENSE_RANK()
Similar:
ties allowed.
Can also exceed N rows.

This Is Extremely Important
Business requirement determines function choice.*/

PART 7 — Example Comparison
/*
Suppose category films:

film	rate
A		5
B		4
C		4
D		3

ROW_NUMBER()

film	rn
A		1
B		2
C		3
D		4

WHERE rn <= 2

Returns:
A
B

Exactly 2 rows.

RANK()

film	rank
A		1
B		2
C		2
D		4

WHERE rank <= 2

Returns:
A
B
C

Three rows returned.
This is fairness-based ranking.*/

PART 8 — Most Important Professional Use Cases

/*
1. Latest Record Per Entity

Massively common.

ROW_NUMBER() OVER (
    PARTITION BY customer_id
    ORDER BY payment_date DESC
)

Then:

WHERE rn = 1

Finds:

latest payment
latest login
latest order
latest transaction

This pattern is everywhere in industry.

2. Best Products Per Category
Top 5 products

inside each category.

3. Highest Revenue Customers Per Country

Real BI analytics.

4. Top Movies Per Genre

Classic recommendation-system query.

5. First Event Detection
first purchase
first login
first rental*/

PART 9 — Professional Query Variations

--Top 5 Customers Per Store

SELECT *
FROM (
    SELECT
        c.customer_id,
        c.store_id,
        SUM(p.amount) AS total_spent,

        ROW_NUMBER() OVER (
            PARTITION BY store_id
            ORDER BY SUM(amount) DESC
        ) AS rn

    FROM payment p
    JOIN customer c
        ON p.customer_id = c.customer_id

    GROUP BY c.customer_id, c.store_id
) t
WHERE rn <= 5;

--Longest Film Per Category

SELECT *
FROM (
    SELECT
        c.name AS category,
        f.title,
        f.length,

        ROW_NUMBER() OVER (
            PARTITION BY c.name
            ORDER BY f.length DESC
        ) AS rn

    FROM film f
    JOIN film_category fc
        ON f.film_id = fc.film_id
    JOIN category c
        ON fc.category_id = c.category_id
) t
WHERE rn = 1;
/*
Business Interpretation

This gives:

single longest film in each category

Very classic analytics query.*/

PART 10 — CTE Version (Professional Style)

This is often cleaner professionally.

WITH ranked_films AS (
    SELECT
        c.name AS category,
        f.title,
        f.length,

        ROW_NUMBER() OVER (
            PARTITION BY c.name
            ORDER BY f.length DESC
        ) AS rn

    FROM film f
    JOIN film_category fc
        ON f.film_id = fc.film_id
    JOIN category c
        ON fc.category_id = c.category_id
)

SELECT *
FROM ranked_films
WHERE rn <= 3;

PART 11 — Performance Insights
/*
This pattern can become expensive because database must:

partition rows
sort inside partitions
assign rankings
possibly materialize intermediate results

Large datasets:
sorting dominates cost.

Indexes help heavily.

Helpful Index Pattern

If frequently running:

PARTITION BY customer_id
ORDER BY payment_date DESC

Helpful index:

(customer_id, payment_date)

Very important optimization intuition.*/

PART 12 — One Very Important Professional Insight
/*
Top-N-per-group is fundamentally:

localized ranking.

Not global ranking.

That mental distinction matters enormously.*/

PART 13 — Common Interview Variations

Very common interview questions:
/*
1. Latest Order Per Customer
Classic.

2. Highest Salary Per Department
Classic.

3. Top 3 Products Per Category
Classic.

4. First Login Per User
Classic.

5. Most Recent Status Per Device
Extremely common in real systems.*/

PART 14 — Professional-Level Practice Queries
--Latest Payment Per Customer

SELECT *
FROM (
    SELECT
        customer_id,
        payment_id,
        payment_date,
        amount,

        ROW_NUMBER() OVER (
            PARTITION BY customer_id
            ORDER BY payment_date DESC
        ) AS rn

    FROM payment
) t
WHERE rn = 1;

--Top Revenue Months Per Year

SELECT *
FROM (
    SELECT
        EXTRACT(YEAR FROM payment_date) AS year,
        DATE_TRUNC('month', payment_date) AS month,
        SUM(amount) AS revenue,

        ROW_NUMBER() OVER (
            PARTITION BY EXTRACT(YEAR FROM payment_date)
            ORDER BY SUM(amount) DESC
        ) AS rn

    FROM payment
    GROUP BY year, month
) t
WHERE rn <= 3;

PART 15 — One Extremely Important Professional Insight
/*
Top-N-per-group is not really one topic.

It is:

the combination of everything you learned about window functions.

That is why it is so important professionally.

It combines:

partitioning
ordering
ranking
execution order
filtering
analytical thinking

This is real analytical SQL engineering.*/