B2 — Intermediate CTEs 

44. Multiple CTEs — Chaining Together 
45. CTE Referencing Another CTE 
46. CTE With JOIN 
47. CTE With GROUP BY and Aggregations 
48. CTE With HAVING 
49. CTE With CASE WHEN 
50. CTE With WHERE and Filtering



44. Multiple CTEs — Chaining Together 

--A single CTE can handle one step.
--Multiple CTEs allow you to build a pipeline.

--A multiple CTE query looks like:

WITH cte1 AS (
    ...
),
cte2 AS (
    ...
),
cte3 AS (
    ...
)
SELECT *
FROM cte3;

--Notice:
--WITH
--appears only once.
--Then CTEs are separated by commas.

Mental Model

--Think of a factory.

Raw Material
     ↓
Factory 1
     ↓
Factory 2
     ↓
Factory 3
     ↓
Finished Product

--Each CTE is one factory stage.


Business Question
--Management wants:

--	Show customers whose total payments exceed $200.

--Could we do this with one CTE?

--Yes.

--But lets intentionally split it into stages.

--Step 1 — Calculate Customer Revenue

with customer_revenue as (
	select
		customer_id,
		sum(amount) as total_revenue
	from payment
	group by customer_id
)
select *
from customer_revenue;


--Step 2 — Add Another CTE

with customer_revenue as (
	select
		customer_id,
		sum(amount) as total_revenue
	from payment
	group by customer_id
),
high_revenue as (
	select *
	from  customer_revenue 
	where total_revenue > 200
)
select *
from high_revenue;


--Execution Flow
--SQL executes:

--First
--customer_revenue

--Second
--high_value_customers

--Uses:
--customer_revenue

--Third
--Final query:

--SELECT *
--FROM high_value_customers;


/*
Why Not Write One Query?

Because real analytics pipelines become much larger.

Imagine:

Step 1: Revenue
Step 2: Customer Segmentation
Step 3: Ranking
Step 4: Reporting

Trying to squeeze everything into one SELECT becomes a nightmare.*/


--Professional Example #1

--Business Question
--Find the top 10 customers by revenue.

--Step 1
--Calculate revenue.

WITH customer_revenue AS (
    SELECT
        customer_id,
        SUM(amount) AS total_revenue
    FROM payment
    GROUP BY customer_id
)

--Step 2
--Rank customers.

ranked_customers AS (
    SELECT
        customer_id,
        total_revenue,
        DENSE_RANK() OVER (
            ORDER BY total_revenue DESC
        ) AS revenue_rank
    FROM customer_revenue
)

--final

SELECT *
FROM ranked_customers
WHERE revenue_rank <= 10;

--Full Query
with customer_revenue as (
	select 
		customer_id,
		sum(amount) as total_revenue
	from payment
	group by customer_id
),

ranked_customers as (
	select
		customer_id,
		total_revenue,
		dense_rank() over (
			order by total_revenue desc
		) as revenue_rank
	from customer_revenue
)

select *
from ranked_customers
where revenue_rank <= 10;

--Notice Something Important
--The second CTE is much simpler because:

--	customer_revenue

--already did the heavy work.
--This is a huge professional advantage.



Professional Example #2

--Monthly Revenue Pipeline
--Suppose we want:
--Monthly revenue
--Previous month revenue
--Revenue growth

CTE 1
Monthly revenue

monthly_revenue AS (
    SELECT
        DATE_TRUNC('month', payment_date) AS month,
        SUM(amount) AS revenue
    FROM payment
    GROUP BY 1
)

CTE 2
Previous month revenue

revenue_history AS (
    SELECT
        month,
        revenue,
        LAG(revenue) OVER(
            ORDER BY month
        ) AS previous_revenue
    FROM monthly_revenue
)

Final

SELECT *
FROM revenue_history;

Full Query

with monthly_revenue as	(
	select 
		date_trunc('month', payment_date) as month,
		sum(amount) as revenue
	from payment
	group by date_trunc('month', payment_date)
),

previous_history as (
	select 
		month,
		revenue,
		lag(revenue) over (
			order by month
		) as previous_month
	from monthly_revenue
)

select *
from previous_history;


--The Biggest Mistake Beginners Make
--They try to do everything inside one SELECT.

Example:

SELECT
    customer_id,
    SUM(amount),
    DENSE_RANK() OVER(...),
    CASE WHEN ...,
    LAG(...),
    ...

--Suddenly:
--300-line query
--Very hard to debug.
--Professionals break it apart.
    

Real Data Analyst Pattern
/*
You will see this everywhere:

WITH raw_data AS (...),

cleaned_data AS (...),

aggregated_data AS (...),

ranked_data AS (...),

final_report AS (...)

SELECT *
FROM final_report;

This is extremely common in production SQL.*/




45. CTE Referencing Another CTE
/*
The Core Idea
A CTE can use the result of a previous CTE.

Think of it like this:

CTE 1
 ↓
CTE 2
 ↓
CTE 3
 ↓
Final Query

Each step builds on the previous step.*/

--First Example

WITH customer_revenue AS (
    SELECT
        customer_id,
        SUM(amount) AS total_revenue
    FROM payment
    GROUP BY customer_id
),

high_value_customers AS (
    SELECT *
    FROM customer_revenue
    WHERE total_revenue > 200
)

SELECT *
FROM high_value_customers;


--Dependency Chain
--Visualize it:

payment
   ↓
customer_revenue
   ↓
high_value_customers
   ↓
Final output

--Execution Order
--SQL executes:
--
--Step 1
--customer_revenue

--Step 2
--high_value_customers

--Step 3
--Final query runs.


--Important Rule #1
--A CTE can reference CTEs defined BEFORE it.

✅ Valid:

WITH cte1 AS (...),

cte2 AS (
    SELECT *
    FROM cte1
)

SELECT *
FROM cte2;


--Important Rule #2
--A CTE cannot reference a CTE defined AFTER it.
❌ Invalid:

WITH cte1 AS (
    SELECT *
    FROM cte2
),

cte2 AS (
    SELECT *
    FROM payment
)

SELECT *
FROM cte1;

--Why?
--Because SQL reads CTE definitions from top to bottom.
--At the moment SQL is creating:

--cte1
--it does not know:

--cte2
--exists yet.

--Professional Example #1

--Business Question
--Find customers ranked by revenue.

--Step 1
--Calculate revenue.

WITH customer_revenue AS (
    SELECT
        customer_id,
        SUM(amount) AS total_revenue
    FROM payment
    GROUP BY customer_id
),

--Step 2
--Rank customers.

ranked_customers AS (
    SELECT
        customer_id,
        total_revenue,
        DENSE_RANK() OVER (
            ORDER BY total_revenue DESC
        ) AS revenue_rank
    FROM customer_revenue
)

--Final

SELECT *
FROM ranked_customers;

--Full Query

WITH customer_revenue AS (
    SELECT
        customer_id,
        SUM(amount) AS total_revenue
    FROM payment
    GROUP BY customer_id
),

ranked_customers AS (
    SELECT
        customer_id,
        total_revenue,
        DENSE_RANK() OVER (
            ORDER BY total_revenue DESC
        ) AS revenue_rank
    FROM customer_revenue
)

SELECT *
FROM ranked_customers;
/*
Why This Is Better
Imagine ranking directly from payment.
You would be trying to:

Aggregate revenue
Rank revenue

inside one query.

By separating steps:
Revenue Calculation
      ↓
Ranking

each CTE has one responsibility.*/


Professional Example #2

--Using Three CTEs
--Business Question
--Find the top 5 customers by revenue.

CTE 1
--Revenue

customer_revenue AS (
    SELECT
        customer_id,
        SUM(amount) AS total_revenue
    FROM payment
    GROUP BY customer_id
)

CTE 2
--Ranking

ranked_customers AS (
    SELECT
        customer_id,
        total_revenue,
        DENSE_RANK() OVER (
            ORDER BY total_revenue DESC
        ) AS revenue_rank
    FROM customer_revenue
)

CTE 3
--Top Customers

top_customers AS (
    SELECT *
    FROM ranked_customers
    WHERE revenue_rank <= 5
)

final

SELECT *
FROM top_customers;

/*
Dependency Diagram
payment
   ↓
customer_revenue
   ↓
ranked_customers
   ↓
top_customers
   ↓
final result

This is how real analytical pipelines are written.
Professional Insight
When you see:*/

WITH step1 AS (...),
step2 AS (...),
step3 AS (...)

do not think:

"Three CTEs"

Think:

"Three business transformations"

Each CTE should do one logical thing.


Common Beginner Mistake
/*
Trying to make one CTE do everything.
Example:

WITH huge_cte AS (
    SELECT
        customer_id,
        SUM(amount),
        DENSE_RANK() OVER(...),
        CASE WHEN ...,
        LAG(...),
        ...
)

This defeats much of the purpose of CTEs.

Instead:

CTE 1 = Aggregate
CTE 2 = Rank
CTE 3 = Categorize
CTE 4 = Final Report

Much cleaner.*/

with customer_revenue AS (
    SELECT
        customer_id,
        SUM(amount) AS total_revenue
    FROM payment
    GROUP BY customer_id
),

ranked_customers AS (
    SELECT
        customer_id,
        total_revenue,
        DENSE_RANK() OVER (
            ORDER BY total_revenue DESC
        ) AS revenue_rank
    FROM customer_revenue
),

top_customers AS (
    SELECT *
    FROM ranked_customers
    WHERE revenue_rank <= 5
)


SELECT *
FROM top_customers;




46. CTE With JOIN 

--Before we write a single query, understand this:
--A CTE is just a temporary table.

--That means if this works:

SELECT *
FROM customer c
JOIN payment p
    ON c.customer_id = p.customer_id;

--then this also works:

WITH customer_payments AS (
    SELECT *
    FROM payment
)
SELECT *
FROM customer c
JOIN customer_payments cp
    ON c.customer_id = cp.customer_id;

--Why?

--Because SQL sees:
--customer_payments
--as a temporary table.

/*
The Biggest Mistake Beginners Make

They think:

WITH customer_revenue AS (...)

creates something special.
It doesn't.
Mentally replace it with:

temporary_table

and everything becomes easier.*/


--Mental Model

--Think:
--Real Table
--   +
--CTE

--is no different from:

--Real Table
--    +
--Real Table

--JOIN syntax remains exactly the same.


Example 1 — Customer Information + Revenue

--Business Question
--Management asks:

Show customer name and total revenue generated.

--This is a very realistic business question.

--Step 1
--Calculate revenue.

WITH customer_revenue AS (
    SELECT
        customer_id,
        SUM(amount) AS total_revenue
    FROM payment
    GROUP BY customer_id
)

--Step 2
--Join CTE with customer table.

WITH customer_revenue AS (
    SELECT
        customer_id,
        SUM(amount) AS total_revenue
    FROM payment
    GROUP BY customer_id
)
SELECT
    c.customer_id,
    c.first_name,
    c.last_name,
    cr.total_revenue
FROM customer c
JOIN customer_revenue cr
    ON c.customer_id = cr.customer_id;


Professional Thinking
/*
Notice what happened.
We separated responsibilities.

CTE responsibility
Calculate revenue
Main query responsibility
Get customer details

This separation is extremely valuable.*/


Example 2 — Film Revenue Analysis

--Now lets make it more realistic.

--Business Question
--Which films generated the most revenue?

--Tables involved:

--payment
--rental
--inventory
--film

Step 1
Build revenue dataset.

WITH film_revenue AS (
    SELECT
        i.film_id,
        SUM(p.amount) AS revenue
    FROM payment p
    JOIN rental r
        ON p.rental_id = r.rental_id
    JOIN inventory i
        ON r.inventory_id = i.inventory_id
    GROUP BY i.film_id
)

Step 2
Join with film table.

SELECT
    f.film_id,
    f.title,
    fr.revenue
FROM film f
JOIN film_revenue fr
    ON f.film_id = fr.film_id;


Full query:



WITH film_revenue AS (
    SELECT
        i.film_id,
        SUM(p.amount) AS revenue
    FROM payment p
    JOIN rental r
        ON p.rental_id = r.rental_id
    JOIN inventory i
        ON r.inventory_id = i.inventory_id
    GROUP BY i.film_id
)
SELECT
    f.film_id,
    f.title,
    fr.revenue
FROM film f
JOIN film_revenue fr
    ON f.film_id = fr.film_id;



Important Design Principle
Many beginners do this:

WITH everything AS (
    SELECT
        f.title,
        SUM(p.amount)
    FROM ...
    JOIN ...
    JOIN ...
    JOIN ...
)
/*
Technically valid.
But often harder to maintain.

Professionals usually ask:
	"What is the purpose of this step?"

If purpose is:
	Calculate revenue

Then only calculate revenue.
Join descriptive data later.*/



Example 3 — JOIN Inside CTE

--Until now:
--JOIN after CTE

Now:

--JOIN inside CTE
--Business Question

--Show customer names with total payments.

WITH customer_payments AS (
    SELECT
        c.customer_id,
        c.first_name,
        c.last_name,
        SUM(p.amount) AS total_paid
    FROM customer c
    JOIN payment p
        ON c.customer_id = p.customer_id
    GROUP BY
        c.customer_id,
        c.first_name,
        c.last_name
)
SELECT *
FROM customer_payments;

/*
Notice:

The JOIN happened inside the CTE.
That's perfectly valid.

Which Is Better?
Many students ask:

Should JOIN be:
Inside CTE?
or
Outside CTE?

Answer:
Depends on business logic.*/

Professional Rule

--If JOIN is needed to create the dataset:
--JOIN inside CTE

--Example:
--Need customer names while aggregating.

--If JOIN is only for enrichment:
--JOIN outside CTE

Example:

--Already calculated revenue.
--Now simply attach names.


--Business Question

--Show top revenue customers.
--CTE 1

--Revenue

customer_revenue AS (
    SELECT
        customer_id,
        SUM(amount) AS total_revenue
    FROM payment
    GROUP BY customer_id
)

--CTE 2

--Ranking

ranked_customers AS (
    SELECT
        customer_id,
        total_revenue,
        DENSE_RANK() OVER(
            ORDER BY total_revenue DESC
        ) AS revenue_rank
    FROM customer_revenue
)

Final JOIN

SELECT
    c.first_name,
    c.last_name,
    rc.total_revenue,
    rc.revenue_rank
FROM ranked_customers rc
JOIN customer c
    ON rc.customer_id = c.customer_id;

--Real Industry Pattern
--You will constantly see:

WITH aggregated_data AS (...),

ranked_data AS (...),

filtered_data AS (...)

SELECT ...
FROM filtered_data fd
JOIN dimension_table dt
ON ...

This is one of the most common SQL patterns in analytics.



Professional Takeaway

--When you see:
--WITH something AS (...)

--Never think:
--"This is a CTE."

--Think:
--"This is a temporary table."

--Then JOIN logic becomes effortless because you're simply joining tables:

Table + Table
Table + CTE
CTE + CTE
CTE + Table

--All follow exactly the same JOIN principles you already know.

where to use join in CTE:


Scenario 1
JOIN Inside the CTE

Suppose management asks:

Show revenue generated by each customer.


--Option A
--JOIN inside CTE

WITH customer_revenue AS (
    SELECT
        c.customer_id,
        c.first_name,
        c.last_name,
        SUM(p.amount) AS total_revenue
    FROM customer c
    JOIN payment p
        ON c.customer_id = p.customer_id
    GROUP BY
        c.customer_id,
        c.first_name,
        c.last_name
)
SELECT *
FROM customer_revenue;

--Why JOIN inside?
--Because:

--Need customer names
--Need payment amounts
--Need them together while aggregating

The JOIN is essential to create the dataset.
So JOIN belongs inside.

Scenario 2
JOIN Outside the CTE

--Same business question.
--But now lets separate responsibilities.

--CTE
--Only calculate revenue.


with customer_revenue as (
	select 
		customer_id,
		sum(amount) as total_revenue
	from payment
	group by customer_id
)
select
	c.first_name,
	c.last_name,
	cr.total_revenue
from customer_revenue cr
join customer c
	on cr.customer_id = c.customer_id;

--Why JOIN outside?
--Because:
--
--CTE purpose:
--Calculate revenue
--
--Final query purpose:
--Add customer details
--
--Each step has one responsibility.
--This is usually the cleaner design

--Professional Principle #1
--Aggregate First, Enrich Later
--
--This is one of the most common analytics patterns.

--The heavy aggregation happens first.
--Then descriptive information is attached later.



Scenario 3
/*
When JOIN Must Be Inside

Suppose:
Calculate revenue by city.

Now revenue depends on city.
Tables:

payment
customer
address
city

You cannot aggregate by city without joining city first.*/

WITH city_revenue AS (
    SELECT
        ci.city,
        SUM(p.amount) AS revenue
    FROM payment p
    JOIN customer c
        ON p.customer_id = c.customer_id
    JOIN address a
        ON c.address_id = a.address_id
    JOIN city ci
        ON a.city_id = ci.city_id
    GROUP BY ci.city
)
SELECT *
FROM city_revenue;

--Why JOIN inside?
--
--Because:
--City is needed for aggregation itself.
--Without city, aggregation is impossible.

Professional Principle #2
/*
If a column is needed for GROUP BY, JOIN first.

Example:
GROUP BY city

means city must already exist.
Therefore:

JOIN city table
↓
GROUP BY city*/


Scenario 4

--Ranking Example
--Suppose:
--
--Rank customers by revenue.

--Best design:

WITH customer_revenue AS (
    SELECT
        customer_id,
        SUM(amount) AS revenue
    FROM payment
    GROUP BY customer_id
),

ranked_customers AS (
    SELECT
        customer_id,
        revenue,
        DENSE_RANK() OVER(
            ORDER BY revenue DESC
        ) AS revenue_rank
    FROM customer_revenue
)

select 
    c.first_name,
    c.last_name,
    rc.revenue,
    rc.revenue_rank
FROM ranked_customers rc
JOIN customer c
    ON rc.customer_id = c.customer_id;


/*
Why not join customer earlier?
Because:

Ranking only needs:
customer_id
revenue

Names are irrelevant for ranking.
So attach them later.*/


Professional Principle #3

Don not Carry Unnecessary Columns Through the Pipeline

Bad:

WITH customer_revenue AS (
    SELECT
        c.customer_id,
        c.first_name,
        c.last_name,
        c.email,
        c.create_date,
        SUM(p.amount)

if only revenue is needed.

Good:

WITH customer_revenue AS (
    SELECT
        customer_id,
        SUM(amount)

Keep only what is needed.


Scenario 5

CTE Joining Another CTE
Very common.

Example:
Revenue CTE

WITH customer_revenue AS (
    SELECT
        customer_id,
        SUM(amount) AS revenue
    FROM payment
    GROUP BY customer_id
),

--Rental CTE

customer_rentals AS (
    SELECT
        customer_id,
        COUNT(*) AS rentals
    FROM rental
    GROUP BY customer_id
)

--Join the two CTEs

SELECT
    cr.customer_id,
    cr.revenue,
    crt.rentals
FROM customer_revenue cr
JOIN customer_rentals crt
    ON cr.customer_id = crt.customer_id;

--This is extremely common in business reporting.
/*
My Recommended Approach (Data Analyst Style)

When solving a problem:
Step 1

Ask:
What is the metric?

Example:

Revenue
Rental Count
Profit
Orders

Build that first.

Step 2
Ask:

Do I need ranking/filtering?
Apply it.

Step 3
Ask:

Do I need names, cities, categories?
Join them at the end.
This often produces the cleanest analytics SQL.*/

--Need column for filtering before aggregation?
--JOIN BEFORE aggregation
--
--Example:
--WHERE city = 'London'
--Need city first.


--Need column only in final report?
--JOIN AFTER ranking/filtering
--Usually cleaner.




47. CTE With GROUP BY and Aggregations


/*
First Understand Why We Combine Them
Suppose management asks:

Show customers whose total payments exceed $200.
The natural process is:

Raw Payment Data
        ↓
Aggregate Revenue Per Customer
        ↓
Filter Customers
        ↓
Final Result

The aggregation is a separate logical step.
That is exactly what CTEs are designed for.*/


The Most Common Pattern
WITH aggregated_data AS (
    SELECT
        grouping_column,
        AGGREGATE_FUNCTION(...)
    FROM table
    GROUP BY grouping_column
)
SELECT *
FROM aggregated_data;


Example 1 — Total Revenue Per Customer

--Lets start simple.
--Business Question
--How much has each customer paid?

Without CTE

SELECT
    customer_id,
    SUM(amount) AS total_revenue
FROM payment
GROUP BY customer_id;

--Works perfectly.

--With CTE

WITH customer_revenue AS (
    SELECT
        customer_id,
        SUM(amount) AS total_revenue
    FROM payment
    GROUP BY customer_id
)
SELECT *
FROM customer_revenue;

--What Did We Gain?

--At first glance:
--Nothing.
--The output is identical.
--But now we have a reusable dataset:

| customer_id | total_revenue |
| ----------- | ------------- |
| 1           | 118.68        |
| 2           | 128.73        |
| 3           | 221.55        |

This dataset can be used in later steps.

--Professional Mindset
--Think:
--
--CTE = Build Dataset
--GROUP BY = Create Metrics

Example 2 — Aggregate First, Filter Later
Business Question

--Find customers who spent more than $200.

with customer_revenue as (
	select 
		customer_id,
		sum(amount) as revenue
	from payment
	group by customer_id
)
select *
from customer_revenue
where revenue > 200;

--Why This Is Powerful
--The aggregation step is isolated.
--
--customer_revenue
--has one responsibility:
--Calculate revenue
--
--The final query has another:
--Filter revenue

Example 3 — Multiple Aggregations

--Real business reporting rarely uses only one metric.
--Business Question
--
--Show for every customer:
--
--Total payments
--Number of payments
--Average payment
--Highest payment
--Lowest payment

WITH customer_stats AS (
    SELECT
        customer_id,
        SUM(amount) AS total_revenue,
        COUNT(*) AS payment_count,
        AVG(amount) AS avg_payment,
        MAX(amount) AS max_payment,
        MIN(amount) AS min_payment
    FROM payment
    GROUP BY customer_id
)
SELECT *
FROM customer_stats;


Example 4 — Aggregation Then Ranking

--This is where CTEs shine.
--Business Question
--
--Rank customers by revenue.
--Step 1
--
--Aggregate.

WITH customer_revenue AS (
    SELECT
        customer_id,
        SUM(amount) AS revenue
    FROM payment
    GROUP BY customer_id
),

--Step 2
--Rank.

ranked_customers AS (
    SELECT
        customer_id,
        revenue,
        DENSE_RANK() OVER(
            ORDER BY revenue DESC
        ) AS revenue_rank
    FROM customer_revenue
)

--Final

SELECT *
FROM ranked_customers;


Example 5 — Aggregation With JOIN
--Business Question
--
--Show total revenue by customer name.

with customer_revenue as (
	select
		customer_id,
		sum(amount) as revenue
	from payment
	group by customer_id
)
select 
	c.first_name || ' ' || c.last_name as fullname,
	cr.revenue
from customer c
join customer_revenue cr
	on c.customer_id = cr.customer_id;

Professional Principle

--Notice:

--Aggregation first
--Join later

--This is extremely common.

Example 6 — Monthly Revenue

--Now a real analytics example.
--Business Question

--Show revenue per month.

with monthly_revenue as (
	select
		date_trunc('month', payment_date) as month,
		sum(amount)
	from payment
	group by date_trunc('month', payment_date )	
)
select *
from monthly_revenue
order by month;

Example 7 — Film Rental Analysis

--Business Question
--How many times was each film rented?
--
--Step 1

--Aggregate.

WITH film_rentals AS (
    SELECT
        i.film_id,
        COUNT(*) AS rental_count
    FROM rental r
    JOIN inventory i
        ON r.inventory_id = i.inventory_id
    GROUP BY i.film_id
)

--Step 2
--Join film title.

SELECT
    f.title,
    fr.rental_count
FROM film_rentals fr
JOIN film f
    ON fr.film_id = f.film_id;
/*
Execution Flow

Always think:
Raw Rows
   ↓
GROUP BY
   ↓
Aggregated Dataset
   ↓
Further Analysis

The CTE stores the aggregated dataset.*/


Master-Level Rule
/*
When solving a business problem:

Step 1

Ask:
What metric am I creating?

Examples:

Revenue
Rental Count
Order Count
Average Order Value
Profit

Step 2

Create that metric using:
GROUP BY
inside a CTE.

Step 3

Use the resulting dataset for:

Filtering
Ranking
Joining
Window Functions
Reporting
*/



48. CTE With HAVING 

--Example Without CTE
--Business Question

--Show customers whose total payments exceed $200.

SELECT
    customer_id,
    SUM(amount) AS total_revenue
FROM payment
GROUP BY customer_id
HAVING SUM(amount) > 200;

--Perfectly valid.

--What Does HAVING See?
--After:

--GROUP BY customer_id
--SQL has something like:

--Now Add a CTE
--Same logic.

WITH high_value_customers AS (
    SELECT
        customer_id,
        SUM(amount) AS total_revenue
    FROM payment
    GROUP BY customer_id
    HAVING SUM(amount) > 200
)
SELECT *
FROM high_value_customers;


Example 2 — Films With Many Rentals

--Business Question
--Show films rented more than 30 times.

WITH popular_films AS (
    SELECT
        i.film_id,
        COUNT(*) AS rental_count
    FROM rental r
    JOIN inventory i
        ON r.inventory_id = i.inventory_id
    GROUP BY i.film_id
    HAVING COUNT(*) > 30
)
SELECT *
FROM popular_films;


Example 4 — Multiple Aggregates In HAVING

--Very common in reporting.
--Business Question
--
--Find customers who:
--
--Made at least 30 payments
--Generated over $100 revenue

WITH qualified_customers AS (
    SELECT
        customer_id,
        COUNT(*) AS payment_count,
        SUM(amount) AS revenue
    FROM payment
    GROUP BY customer_id
    HAVING COUNT(*) >= 30
       AND SUM(amount) > 100
)
SELECT *
FROM qualified_customers;


--Question:
--Show payments greater than $5 and customers whose total revenue exceeds $100.

with customer_revenue as (
	select 
		customer_id,
		sum(amount) as revenue
	from payment
	where amount > 5
	group by customer_id
	having sum(amount) > 100
)
select *
from customer_revenue;

Business Question

Show customer names for customers generating more than $200.

WITH high_value_customers AS (
    SELECT
        customer_id,
        SUM(amount) AS revenue
    FROM payment
    GROUP BY customer_id
    HAVING SUM(amount) > 200
)
SELECT
    c.first_name,
    c.last_name,
    hvc.revenue
FROM high_value_customers hvc
JOIN customer c
    ON hvc.customer_id = c.customer_id;



49. CTE With CASE WHEN 

If I had to rank CTE combinations by how often they are used in business reports, it would be something like:

1. CTE + GROUP BY
2. CTE + JOIN
3. CTE + CASE WHEN
4. CTE + Window Functions
5. CTE + having
/*
Why Combine CASE WHEN with CTE?
Because the most common workflow is:

Aggregate Data
      ↓
Create Metrics
      ↓
Classify Metrics
      ↓
Report Results

A CTE lets us separate those steps cleanly.*/

Example 1 — Customer Revenue Segmentation
/*
Business Question

Classify customers:
Revenue >= 200 → High Value

Revenue >= 100 → Medium Value

Otherwise → Low Value*/

with customer_revenue as (
	select
		customer_id,
		sum(amount) as revenue
	from payment
	group by customer_id
),

customer_segment as(
select 
	c.first_name,
	revenue,
	case
		when revenue >= 200 then 'High'
		when revenue >= 100 then 'Medium'
		else 'Low'
	end as segment
from customer c
join customer_revenue cr
	on c.customer_id = cr.customer_id
)
select *
from customer_segment;

--Why Use a CTE Here?
--Without the CTE, SQL becomes harder to read:

SELECT
    customer_id,
    SUM(amount),
    CASE ...

--The revenue calculation and business classification are mixed together.

--With a CTE:

--CTE:
--Calculate Revenue

--Final Query:
--Classify Revenue

--Much cleaner.
    
--Professional Principle
--
--A very common pattern is:
--CTE 1 → Calculate Metrics
--CTE 2 → Classify Metrics
--
--Final → Report
    
Example 3 — Staff Performance Classification
/*
Business Question
Classify staff members.

Revenue > 3000 → Excellent

Revenue > 2000 → Good

Otherwise → Needs Improvement*/

WITH staff_revenue AS (
    SELECT
        staff_id,
        SUM(amount) AS revenue
    FROM payment
    GROUP BY staff_id
)
SELECT
    staff_id,
    revenue,
    CASE
        WHEN revenue > 3000 THEN 'Excellent'
        WHEN revenue > 2000 THEN 'Good'
        ELSE 'Needs Improvement'
    END AS performance
FROM staff_revenue;


Example 4 — Film Popularity Classification

--Business Question
--Classify films by rental count.
--
--Step 1
--
--Calculate rentals.

WITH film_rentals AS (
    SELECT
        i.film_id,
        COUNT(*) AS rental_count
    FROM rental r
    JOIN inventory i
        ON r.inventory_id = i.inventory_id
    GROUP BY i.film_id
)

--Step 2
--Classify.

SELECT
    film_id,
    rental_count,
    CASE
        WHEN rental_count >= 40 THEN 'Blockbuster'
        WHEN rental_count >= 20 THEN 'Popular'
        ELSE 'Regular'
    END AS popularity
FROM film_rentals;


Example 5 — CASE Inside the CTE

--Until now we used CASE outside.
--But CASE can also be inside.

WITH customer_segments AS (
    SELECT
        customer_id,
        SUM(amount) AS revenue,
        CASE
            WHEN SUM(amount) >= 200 THEN 'High Value'
            ELSE 'Regular'
        END AS segment
    FROM payment
    GROUP BY customer_id
)
SELECT *
FROM customer_segments;
/*
Is This Valid?
Yes.

Is It Recommended?
Usually not.

Why?
Because you are mixing:

Aggregation
+
Classification

inside the same step.*/


Professional Pattern #2

Revenue → Segment → Rank

WITH customer_revenue AS (...),

customer_segments AS (...),

ranked_customers AS (...)

--Extremely common in dashboards.


Professional Pattern #3

Revenue → Segment → Join Customer

WITH customer_revenue AS (...),

customer_segments AS (...)

SELECT
    c.first_name,
    c.last_name,
    cs.segment
FROM customer_segments cs
JOIN customer c
    ON cs.customer_id = c.customer_id;

--This is exactly the type of query analysts build.





50. CTE With WHERE and Filtering
/*
A CTE does NOT change SQL logic.
It only changes structure.

So filtering rules remain EXACTLY the same:

WHERE  → row-level filtering (before GROUP BY)
HAVING → group-level filtering (after GROUP BY)
WHERE (outside CTE) → filtering final dataset*/

Example 1 — WHERE Inside CTE (MOST COMMON)

--Business Question
--Show customers who made payments greater than $5, 
--then calculate their total revenue.
--
--Step 1: Filter raw rows first (IMPORTANT)

WITH filtered_payments AS (
    SELECT *
    FROM payment
    WHERE amount > 5
)

--Step 2: Aggregate filtered data

, customer_revenue AS (
    SELECT
        customer_id,
        SUM(amount) AS revenue
    FROM filtered_payments
    GROUP BY customer_id
)

--Final

SELECT *
FROM customer_revenue;
/*
Why This Is Powerful
Because we reduced data EARLY.
Instead of aggregating everything:

100,000 rows

We first reduce:
maybe 40,000 rows

Then aggregate.
This is called:
early filtering (best practice)*/


Example 2 — WHERE After Aggregation (Inside CTE)

--Business Question
--Find customers whose total revenue exceeds 200.

WITH customer_revenue AS (
    SELECT
        customer_id,
        SUM(amount) AS revenue
    FROM payment
    GROUP BY customer_id
    HAVING SUM(amount) > 50
)
SELECT *
FROM customer_revenue
WHERE revenue > 200;

--Key Insight

--You can filter at multiple stages:

--Raw data filter → WHERE
--Group filter → HAVING
--Final filter → WHERE (outside CTE)

Example 3 

Real Analytics Pattern 

Business Question

--Show high-value customers (only those who made payments > 5)
--and spent more than 100 total.

WITH filtered_payments AS (
    SELECT *
    FROM payment
    WHERE amount > 5
),

customer_revenue AS (
    SELECT
        customer_id,
        SUM(amount) AS revenue
    FROM filtered_payments
    GROUP BY customer_id
)

SELECT *
FROM customer_revenue
WHERE revenue > 100;

Example 4 — WHERE + JOIN in CTE

--Business Question
--Find revenue per customer, but only for customers from store_id = 1

with filtered_customers as (
	select *
	from customer
	where store_id = 1
),

customer_revenue as (
	select  
		fc.customer_id,
		sum(amount) as revenue
	from filtered_customers fc
	join payment p
		on fc.customer_id = p.customer_id
	group by fc.customer_id
	)
select *
from customer_revenue;


--Why filter BEFORE JOIN?
--Because:
--Less rows → faster JOIN → cleaner logic


Example 5 — Filtering AFTER CTE (MOST COMMON IN JOBS)

--Business Question
--Get all customers and show only top spenders.

WITH customer_revenue AS (
    SELECT
        customer_id,
        SUM(amount) AS revenue
    FROM payment
    GROUP BY customer_id
)

SELECT *
FROM customer_revenue
WHERE revenue > 150;