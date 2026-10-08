SECTION A2 — Aggregate Window Functions
Topic 7 — SUM() OVER() — Running and Total Sums
/*
ROADMAP

PART 1 — Total Sums
SUM OVER()
partition totals
analytical totals

PART 2 — Running Totals
ordered windows
cumulative sums
progressive analytics

PART 3 — Professional Patterns
percentages
customer lifetime value
cumulative revenue
grouped running totals

PART 4 — Internal Execution
how SQL computes running sums
performance thinking
professional optimization insights*/

PART 1 — TOTAL SUMS
1. Basic SUM() OVER()

SELECT
    payment_id,
    amount,
    SUM(amount) OVER () AS total_revenue
FROM payment;

--What happens?

--You already know:
--no PARTITION BY
--whole table = one window

--So every row gets:
--total payment revenue of entire table

SELECT
    payment_id,
    customer_id,
    amount,
    SUM(amount) OVER () AS company_revenue
FROM payment
LIMIT 20;


2. SUM() OVER(PARTITION BY ...)
--Now we move to analytical grouping.

SELECT
    customer_id,
    payment_id,
    amount,
    SUM(amount) OVER (
        PARTITION BY customer_id
    ) AS customer_total_spending
FROM payment;


PART 2 — RUNNING TOTALS

--Now we move into the real power.
--This is where ORDER BY changes everything.

--3. Running Total Across Entire Table

SELECT
    payment_date,
    amount,
    SUM(amount) OVER (
        ORDER BY payment_date
    ) AS running_revenue
FROM payment;

--INTERNAL EXECUTION MODEL

--For row N:
--SQL maintains:
--previous_sum + current_amount

--This creates:
--cumulative state

--THIS IS called

--Running Total
--Cumulative Sum
--Progressive Sum

--All same concept.

4. Running Total Per Customer

--NOW we combine:
--
--partitioning
--ordering
--
--This is extremely professional.

SELECT
    customer_id,
    payment_date,
    amount,
    SUM(amount) OVER (
        PARTITION BY customer_id
        ORDER BY payment_date
    ) AS customer_running_total
FROM payment;

--What SQL does internally

--Step 1
--Split by customer

--Step 2
--Sort payments chronologically

--Step 3
--Build running total separately

--RESULT
--Each customer gets independent cumulative tracking.

PART 3 — PROFESSIONAL ANALYTICAL PATTERNS
5. Percentage Contribution to Total Revenue

SELECT
    payment_id,
    amount,
    ROUND(
        amount * 100.0 /
        SUM(amount) OVER (),
        2
    ) AS revenue_percentage
FROM payment;

SELECT
    payment_id,
    amount,
    ROUND(
        amount * 100.0 /
        SUM(amount) OVER (),
        2
    ) AS revenue_percentage,
    sum(amount) over()
FROM payment;

6. Customer Contribution Analysis

select 	
	customer_id,
	payment_id,
	amount,
	sum(amount) over (
		partition by customer_id
	) as customer_total,
	
	Round(
		amount * 100/ sum(amount) OVER(
			partition by customer_id), 2
	) as payment_of_customer_spending
from payment;

7. Daily Revenue Running Total

Professional reporting pattern.

select 
	date(payment_date) as payment_day,
	sum(amount) as daily_revenue,
	
	sum(sum(amount)) over 
	(
	order by date(payment_date)
	) as cumulative_daily_revenue
from payment
group by date(payment_date);
/*
VERY IMPORTANT QUERY

This is professional-level thinking.
Notice carefully:

SUM(SUM(amount)) OVER(...)
WHY DOUBLE SUM?

Because:

INNER SUM
SUM(amount)

creates:

daily revenue
OUTER SUM OVER
SUM(...) OVER(...)

creates:

cumulative daily revenue
THIS IS CALLED
Layered Aggregation

Extremely important professionally.*/

PART 4 — INTERNAL EXECUTION & PROFESSIONAL THINKING

8. INTERNAL EXECUTION OF RUNNING TOTAL

--For:

SUM(amount) OVER (
    ORDER BY payment_date
)
/*
SQL roughly does:

Step 1
Sort rows

Step 2
Initialize accumulator
running_sum = 0

Step 3
For each row:
running_sum += current_amount

Step 4
Attach value to row

THIS IS WHY ORDERING MATTERS

Without ORDER:
no sequence
no accumulation logic*/

9. PERFORMANCE INSIGHT (VERY IMPORTANT)
/*
Running totals often require:

sorting
memory
sequential processing

So:
ORDER BY payment_date
can become expensive on huge datasets.

Professional optimization tip
Indexes help greatly:
INDEX(payment_date)

or:

INDEX(customer_id, payment_date)
for partitioned running totals.
*/
11. PROFESSIONAL ANALYTICAL THINKING

--When you see:

PARTITION BY customer_id
ORDER BY payment_date

--you should immediately think:

--“Time-based customer analytics.”

--This instinct is what professional analysts develop.


SECTION A2 — Topic 8
COUNT() OVER() — Running and Total Counts

PART 1 — BASIC TOTAL COUNTS
1. COUNT() OVER()

--Start simple.

SELECT
    payment_id,
    amount,
    COUNT(*) OVER () AS total_payments
FROM payment;

--What happens?
--Every row sees:
--total number of rows in payment table

SELECT
    payment_id,
    customer_id,
    amount,
    COUNT(*) OVER () AS total_transactions
FROM payment
LIMIT 20;

--2. COUNT() OVER(PARTITION BY ...)
--Now analytical grouping.

SELECT
    customer_id,
    payment_id,
    amount,

    COUNT(*) OVER (
        PARTITION BY customer_id
    ) AS customer_payment_count

FROM payment;

PART 2 — RUNNING COUNTS

--Now we combine:

--COUNT
--ORDER BY

--This becomes sequential event tracking.

--3. Running Count Across Entire Table

SELECT
    payment_date,
    amount,

    COUNT(*) OVER (
        ORDER BY payment_date
    ) AS running_transaction_count

FROM payment;

--What SQL does
--For each row:
--count all previous rows + current row

4. Running Count Per Customer

select
	customer_id,
	payment_id,
	payment_date,
	amount,
	count(*) over (
		partition by customer_id
		order by payment_date
		) as customer_payment_sequence
from payment;

--VERY IMPORTANT INSIGHT

--This query behaves similarly to:
--ROW_NUMBER()
--which we’ll study later.
--But COUNT builds the mental model first.

PART 3 — PROFESSIONAL ANALYTICS PATTERNS
Now we move into business analytics.

5. Customer Frequency Analysis

SELECT
    customer_id,
    payment_id,
    amount,

    COUNT(*) OVER (
        PARTITION BY customer_id
    ) AS frequency,

    SUM(amount) OVER (
        PARTITION BY customer_id
    ) AS total_spending

FROM payment;

6. Daily Transaction Progression

select 
	date(payment_date) as payment_day,
	count(*) as daily_transaction,
	
	sum(count(*)) over (
		order by date(payment_date)	
	) as cumulative_transactions
		
from payment
group by date(payment_date);

PART 4 — IMPORTANT COUNT NUANCES

--This section is VERY important professionally.
--Because COUNT has hidden behavior many beginners do not know.

7. COUNT(*) vs COUNT(column)

--COUNT(*)

--Counts:
--ALL rows
--including:
--NULL rows

--COUNT(column)

--Counts:
--only NON-NULL values

SELECT
    rental_id,
    return_date,

    COUNT(*) OVER () AS total_rows,

    COUNT(return_date) OVER () AS returned_rentals

FROM rental;

--If some rentals are not returned yet:
--COUNT(return_date)
--<
--COUNT(*)
--because NULLs are skipped.

8. COUNT DISTINCT Limitation (IMPORTANT)

--Many databases do NOT allow:
--
--COUNT(DISTINCT customer_id) OVER(...)
--
--or support is limited/expensive.
--PostgreSQL versions matter here.
--
--Professionally:
--DISTINCT window counts can become costly
--We’ll discuss workarounds later.
11. PROFESSIONAL ANALYTICAL THINKING

When you see:

COUNT(*) OVER (
    PARTITION BY customer_id
    ORDER BY payment_date
)

--you should immediately think:

--“Customer event progression over time.”


SECTION A2 — Topic 9
AVG() OVER() — Running and Total Averages
--
PART 1 — BASIC TOTAL AVERAGES
1. AVG() OVER()

Start simple.

SELECT
    payment_id,
    amount,

    AVG(amount) OVER () AS average_payment

FROM payment;

SELECT
    payment_id,
    customer_id,
    amount,

    ROUND(
        AVG(amount) OVER (),
        2
    ) AS avg_payment

FROM payment
LIMIT 20;
---
2. AVG() OVER(PARTITION BY ...)
Now group-level benchmarking.

SELECT
    customer_id,
    payment_id,
    amount,
	round(
		avg(amount) over (
			partition by customer_id), 2	
	) as customer_avg_payment
from payment;

PART 2 — RUNNING AVERAGES
Now we move into trend smoothing.

3. Running Average Across Entire table

SELECT
    payment_date,
    amount,
	
    round(
    	avg(amount) over (
    		order by payment_date
    	), 2
    	) as running_avg
from payment;

--Now SQL computes:
--average of all previous rows + current row

--INTERNAL LOGIC

--Row 1
--AVG(5)

--Row 2
--AVG(5,3)

--Row 3
--AVG(5,3,7)

--THIS IS CALLED
--cumulative smoothing

--4. Running Average Per Customer

select 		
	customer_id,
	payment_date,
	amount,
	round(
		avg(amount) over (partition by customer_id order by payment_date),
		2
	) as customer_running_avg
from payment;

PART 3 — PROFESSIONAL ANALYTICS PATTERNS

5. Compare Payment Against Company Average

SELECT
    payment_id,
    customer_id,
    amount,

    ROUND(
        AVG(amount) OVER (),
        2
    ) AS company_avg,

    ROUND(
        amount -
        AVG(amount) OVER (),
        2
    ) AS difference_from_avg

FROM payment;

--This answers:
--“How far above or below average is this payment?”

6. Customer-Level Benchmarking

SELECT
    customer_id,
    payment_id,
    amount,

    ROUND(
        AVG(amount) OVER (
            PARTITION BY customer_id
        ),
        2
    ) AS customer_avg,

    ROUND(
        amount -
        AVG(amount) OVER (
            PARTITION BY customer_id
        ),
        2
    ) AS deviation_from_customer_avg

FROM payment;

--This answers:
--“Is this payment unusually high or low for this customer?”

7. Daily Revenue Average Trend

select 
	date(payment_date) as payment_day,
	sum(amount) as daily_revenue,
	
	round(
		avg(sum(amount)) over (
			order by date(payment_date)
		), 2
	) as running_avg_daily_revenue
	
from payment
group by date(payment_date);

PART 4 — IMPORTANT AVG NUANCES

8. AVG() Ignores NULLs
/*
Same behavior as:

SUM
COUNT(column)

Example
AVG(return_date - rental_date)

NULL values are skipped automatically.

AVG does NOT treat NULL as 0.
It completely ignores NULL rows.

Otherwise averages become misleading.
*/
9. INTEGER DIVISION & PRECISION
/*
Example Problem
SELECT AVG(5);

may behave differently from:

SELECT AVG(5.0);
depending on type system.

PROFESSIONAL PRACTICE
Always use:

ROUND()
explicit casting when needed

especially in analytics dashboards.

Example
ROUND(
    AVG(amount) OVER (),
    2
)*/

10. INTERNAL EXECUTION MODEL

/*
For:

AVG(amount) OVER (
    ORDER BY payment_date
)

SQL roughly maintains:

running_sum
and
running_count

Then computes:

running_sum / running_count
for every row.

THIS IS IMPORTANT
AVG internally behaves like:
SUM + COUNT combined*/

11. VERY IMPORTANT BEGINNER MISTAKE
/*
Mistake

Thinking averages always represent:

“normal”

❌ WRONG

Averages can be distorted by:

outliers
skewed distributions
unusual payments

Professionally:
analysts interpret averages carefully*/


SECTION A2 — Topic 10 & 11
MIN() OVER() + MAX() OVER()

PART 1 — BASIC MIN/MAX WINDOWS
1. MIN() OVER()

--Start simple.

select 
	payment_id,
	amount,
	min(amount) over() as minimum_payment
from payment;

--Minimum repeats for every row because:
--every row sees same global window

SELECT
    payment_id,
    customer_id,
    amount,

    MIN(amount) OVER () AS global_min_payment

FROM payment
LIMIT 20;

2. MAX() OVER()
Now maximum analytics.

SELECT
    payment_id,
    amount,

    MAX(amount) OVER () AS maximum_payment

FROM payment;


SELECT
    payment_id,
    customer_id,
    amount,

    MIN(amount) OVER () AS min_payment,
    MAX(amount) OVER () AS max_payment

FROM payment;

3. MIN/MAX Per Customer
Now partition-based extrema analytics.

SELECT
    customer_id,
    payment_id,
    amount,

    MIN(amount) OVER (
        PARTITION BY customer_id
    ) AS customer_min_payment,

    MAX(amount) OVER (
        PARTITION BY customer_id
    ) AS customer_max_payment

FROM payment;

PART 2 — RUNNING MIN/MAX

Now we combine:
ORDER BY
extrema tracking

4. Running Minimum

SELECT
    payment_date,
    amount,

    MIN(amount) OVER (
        ORDER BY payment_date
    ) AS running_minimum

FROM payment;

5. Running Maximum

SELECT
    payment_date,
    amount,

    MAX(amount) OVER (
        ORDER BY payment_date
    ) AS running_maximum

FROM payment;

6. Running Min/Max Per Customer

Now advanced behavioral analytics.

SELECT
    customer_id,
    payment_date,
    amount,

    MIN(amount) OVER (
        PARTITION BY customer_id
        ORDER BY payment_date
    ) AS customer_historical_min,

    MAX(amount) OVER (
        PARTITION BY customer_id
        ORDER BY payment_date
    ) AS customer_historical_max

FROM payment;

PART 3 — PROFESSIONAL ANALYTICS PATTERNS

7. Compare Payment Against Historical Maximum

select
	payment_id,
	customer_id,
	amount,
	
	max(amount) over (
		partition by customer_id
	) as customer_max,
	
	round(
		max(amount) over (
			partition by customer_id	
		) - amount,
		2
	) as distance_from_max
from payment;
	)
	
8. Detect Record-Breaking Payments

SELECT
    payment_date,
    amount,

    MAX(amount) OVER (
        ORDER BY payment_date
    ) AS running_max

FROM payment;

Whenever:
amount = running_max
a new historical record occurred.

9. Daily Revenue Peak Tracking
Layered aggregation again.

select
	date(payment_date) as payment_day,
	sum(amount) as daily_revenue,
	
	max(sum(amount)) over (
		order by date(payment_date)
	) as historical_best_day
from payment
group by date(payment_date);

PART 4 — INTERNAL EXECUTION & IMPORTANT NUANCES

10. Internal Execution of Running MAX

/*
10. Internal Execution of Running MAX

For:

MAX(amount) OVER (
    ORDER BY payment_date
)

SQL roughly maintains:

current_max

Then for each row:
current_max = MAX(current_max, current_row)

SAME FOR MIN
current_min =
MIN(current_min, current_row)
THIS IS STATEFUL ANALYTICS

Very important mental model.*/

11. IMPORTANT PROFESSIONAL INSIGHT
/*
Running MIN/MAX are often:

computationally cheaper
than running AVG/SUM

because:
only one boundary value maintained
not:
full arithmetic accumulation*/

13. PROFESSIONAL ANALYTICAL THINKING
/*
When you see:

MAX(amount) OVER (
    PARTITION BY customer_id
    ORDER BY payment_date
)

you should immediately think:

“Customer historical peak behavior over time.”
That instinct is what analysts develop professionally.*/