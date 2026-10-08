B4 — Professional Patterns 

58. CTE for Data Cleaning Pipeline 
59. CTE for Step by Step Feature Engineering 
60. CTE + Window Functions + JOIN Combined 
61. Final Complex Query — All Topics Together




58. CTE for Data Cleaning Pipeline 

1. Concept

What is a Data Cleaning Pipeline?

--	A data cleaning pipeline is a sequence of steps that gradually transforms
--	raw data into clean, usable data.

--Instead of doing everything in one giant query, we break the process into stages.

Each stage:

--Fixes one problem
--Produces cleaner output
--Passes the result to the next stage

--CTEs are perfect for this.

--Why does it exist?
--Because real business data is messy.
--Examples:

| Problem            | Example                    |
| ------------------ | -------------------------- |
| NULL values        | Missing customer name      |
| Leading spaces     | `' Abdullah'`              |
| Trailing spaces    | `'Abdullah '`              |
| Mixed case         | `'ABDULLAH'`, `'abdullah'` |
| Invalid values     | Negative sales amount      |
| Duplicate rows     | Same customer twice        |
| Missing categories | NULL product category      |

--Before analysis, these issues must be fixed.
--Otherwise reports become unreliable.

Analysts spend huge amounts of time cleaning data before analysis.

--This is often called:
--Garbage In → Garbage Out


When to Use It

Use a CTE cleaning pipeline when:

✅ Multiple cleaning steps exist
✅ Each step depends on the previous step
✅ You want readability
✅ You want debugging capability
✅ You want professional code

--Raw data enters.
/*
CTE 1:
Fix spaces.
↓
CTE 2:
Fix capitalization.
↓
CTE 3:
Handle NULLs.
↓
CTE 4:
Remove duplicates.
↓
Final clean dataset.*/


3. Syntax Structure

--General pattern:
WITH step1 AS (
    ...
),
step2 AS (
    ...
),
step3 AS (
    ...
)
SELECT *
FROM step3;

--Each CTE becomes the input of the next CTE.


Example 1 — Simple Cleaning Pipeline

--Imagine names contain inconsistent capitalization.
--Raw:
--abdullah
--ABDULLAH
--AbDuLlAh

Step 1

WITH cleaned_names AS (
    SELECT
        first_name,
        INITCAP(first_name) AS cleaned_name
    FROM customer
)
SELECT *
FROM cleaned_names;

--What INITCAP Does
--INITCAP('ABDULLAH')
--Output:
--Abdullah

Query Execution Flow
/*
Step 1
Read customer table.

Step 2
Apply:
INITCAP(first_name)

Step 3
Store result in CTE.

Step 4
Return CTE result.*/


Example 2 — Multi-Step Cleaning Pipeline

Suppose we want:

--Remove spaces
--Standardize capitalization
--Replace NULL values


with trimmed_names as (
	select 
		customer_id,
		trim(first_name) as first_name
	from customer
),

formatted_names as (
	select
		customer_id,
		initcap(first_name) as first_name
	from trimmed_names	
),

final_names as (
	select 
		customer_id,
		coalesce(first_name, 'unknown') as first_name
	from formatted_names
)

select *
from final_names;


Example 3 — dvdrental Business Example

--Lets clean customer email information.

--Suppose management wants:
--
--standardized email
--no spaces
--lowercase only

WITH trimmed_email AS (
    SELECT
        customer_id,
        TRIM(email) AS email
    FROM customer
),

lower_email AS (
    SELECT
        customer_id,
        LOWER(email) AS email
    FROM trimmed_email
)

SELECT *
FROM lower_email;

Example 4 — Revenue Cleaning Pipeline

--Imagine sales data contains negative values.

Business rule:
--Revenue cannot be negative.

WITH raw_sales AS (
    SELECT *
    FROM payment
),

validated_sales AS (
    SELECT
        payment_id,
        payment_date,
        CASE
            WHEN amount < 0 THEN 0
            ELSE amount
        END AS cleaned_amount
    FROM raw_sales
),

monthly_sales AS (
    SELECT
        DATE_TRUNC('month', payment_date) AS month,
        SUM(cleaned_amount) AS revenue
    FROM validated_sales
    GROUP BY DATE_TRUNC('month', payment_date)
)

SELECT *
FROM monthly_sales
ORDER BY month;






59. CTE for Step by Step Feature Engineering 

--What Is a Feature?
--A feature is simply:

--	A useful piece of information derived from raw data.

--Raw data:

| customer_id | payment_date | amount |
| ----------- | ------------ | ------ |
| 1           | 2025-01-01   | 4.99   |
| 1           | 2025-01-15   | 7.99   |

--Feature:

| customer_id | total_spent |
| ----------- | ----------- |
| 1           | 12.98       |

--We created a new piece of information.
--That new piece of information is called a feature.

What Is Feature Engineering?

--	Feature Engineering is:
--	The process of creating useful business variables from raw data.

--Simple Real-Life Example
--Suppose a bank has:

--Customer Name
--Date of Birth
--Account Balance

--Raw data:

| Customer | DOB        |
| -------- | ---------- |
| Abdullah | 2000-05-01 |

--Not very useful for analysis.
--Create:
--AGE

--Now:

| Customer | Age |
| -------- | --- |
| Abdullah | 26  |

--Age is a feature.

--Another Example
--Raw:

| Customer | Orders |
| -------- | ------ |
| Abdullah | 45     |

--Feature:
--Customer Segment

Rules:

--Orders > 40 → Loyal
--Orders > 20 → Active
--Otherwise → Casual

--New feature:

| Customer | Segment |
| -------- | ------- |
| Abdullah | Loyal   |

--Feature Engineering

--Why Businesses Care
--Businesses rarely analyze raw columns directly.
--They analyze engineered features.
--Examples:

| Raw Data      | Feature             |
| ------------- | ------------------- |
| Orders        | Total Orders        |
| Payments      | Lifetime Revenue    |
| Dates         | Customer Age        |
| Transactions  | Average Transaction |
| Purchases     | Customer Segment    |
| Sales History | Revenue Growth      |

--Most dashboards are built on engineered features.

Where You Will Use It

--Data Analyst

--Very frequently.

--Examples:

--Customer Segments
--Revenue Buckets
--Purchase Frequency
--Retention Metrics

--Power BI
--Extremely common.
--You often create:

SQL Features
↓
Power BI Measures
↓
Dashboard


Machine Learning

--Feature Engineering is one of the biggest parts of ML.
--Often:

Raw Data
↓
Feature Engineering
↓
Model Training

--Many ML projects spend more time on feature engineering than model building.

Why CTEs Are Perfect For This

--Imagine creating:

--Customer spending
--Average order value
--Customer segment
--Customer ranking

--Could be one giant query.

--But professionals do:

WITH spending AS (...),
avg_order AS (...),
segments AS (...),
ranking AS (...)

--Each CTE creates a new feature.
--This becomes a feature engineering pipeline.

Professional Definition

--A Feature Engineering Pipeline is:

--	A sequence of transformations that progressively creates business-ready
--	analytical variables from raw data.

--And CTEs are one of the cleanest ways to build that pipeline.

How Analysts Actually Work

Very often:

Raw Data
↓
Cleaning
↓
Feature Creation
↓
Aggregation
↓
Dashboard

--Notice something?

--Topic 58 was:
--Cleaning Pipeline

--Topic 59 is:
--Feature Engineering Pipeline

These are often done together.

First dvdrental Example

--Lets build a simple feature engineering pipeline.

Business Question:

--For each customer, create:

--Total Revenue
--Total Transactions
--Average Transaction Amount

These are all features.

with customer_revenue as (
	select
		customer_id,
		sum(amount) as total_revenue
	from payment
	group by customer_id
),
total_transactions as (
	select 
		customer_id,
		count(*) as transaction_count
	from payment
	group by customer_id
),
avg_payment as (
	select 
		customer_id,
		avg(amount) as avg_payment
	from payment
	group by customer_id 
)
select 
	cr.customer_id,
	cr.total_revenue,
	tt.transaction_count,
	ap.avg_payment
from customer_revenue cr
join total_transactions tt
	on cr.customer_id = tt.customer_id 
join avg_payment ap
	on tt.customer_id = ap.customer_id
	
	
Professional Revision Notes
/*
Feature
	A feature is a useful variable created from raw data.

Examples:

Total Revenue
Average Order Value
Customer Age
Customer Segment
Purchase Frequency

Feature Engineering
	The process of creating business-ready variables from raw data.

Why Use CTEs

CTEs allow feature creation in stages.

WITH feature1 AS (...),
feature2 AS (...),
feature3 AS (...)

Each CTE represents a business feature.*/





60. CTE + Window Functions + JOIN Combined
/*
Concept

This topic is about building SQL queries where:

CTEs = step-by-step pipeline
JOINs = bring business context
Window functions = analytics layer on top

So instead of:

one big messy query

you build:

Raw Data
 → CTE 1 (base)
 → JOIN (business enrichment)
 → CTE 2 (aggregation)
 → Window functions (ranking/trends)
 → Final output*/


Step-by-Step Professional Build

STEP 1 — Base Data (CTE)
--We start from payment


WITH base_payments AS (
    SELECT
        customer_id,
        amount,
        payment_date
    FROM payment
),

--What we did:
--We created a clean base dataset.

--STEP 2 — JOIN Customer Table
--Now we add business meaning:

customer_info AS (
    SELECT
        c.customer_id,
        c.first_name,
        c.last_name,
        bp.amount,
        bp.payment_date
    FROM base_payments bp
    JOIN customer c
        ON bp.customer_id = c.customer_id
),

--Why this matters:
--Now we can analyze customers by name, not ID.

--STEP 3 — Feature Engineering (Aggregation CTE)
--Now we build features:

customer_metrics AS (
    SELECT
        customer_id,
        first_name,
        last_name,
        SUM(amount) AS total_revenue,
        COUNT(*) AS total_transactions
    FROM customer_info
    GROUP BY customer_id, first_name, last_name
),

--Features created:
--total_revenue
--total_transactions

--STEP 4 — Window Function (Ranking Layer)
--Now we add ranking:

ranked_customers as (
	select 
		*,
		rank() over (
			order by total_revenue desc
		) as revenue_rank
	from customer_metrics
)

SELECT *
FROM ranked_customers
ORDER BY revenue_rank;


--What You Just Learned (IMPORTANT)
--This is a real industry pattern:
--
--Pattern Name:
--ETL + Feature Engineering + Analytics Layer


Everything Together

WITH base_payments AS (
    SELECT
        customer_id,
        amount,
        payment_date
    FROM payment
),

customer_info AS (
    SELECT
        c.customer_id,
        c.first_name,
        c.last_name,
        bp.amount,
        bp.payment_date
    FROM base_payments bp
    JOIN customer c
        ON bp.customer_id = c.customer_id
),

customer_metrics AS (
    SELECT
        customer_id,
        first_name,
        last_name,
        SUM(amount) AS total_revenue,
        COUNT(*) AS total_transactions
    FROM customer_info
    GROUP BY customer_id, first_name, last_name
),

ranked_customers AS (
    SELECT
        *,
        RANK() OVER (ORDER BY total_revenue DESC) AS revenue_rank
    FROM customer_metrics
)

SELECT *
FROM ranked_customers
ORDER BY revenue_rank;

Layer Breakdown

| Layer               | Tool               |
| ------------------- | ------------------ |
| Extraction          | CTE base           |
| Transformation      | JOIN + aggregation |
| Feature engineering | SUM, COUNT         |
| Analytics           | Window functions   |
| Reporting           | Final SELECT       |





61. Final Complex Query — All Topics Together

1. What This Topic Really is

--A final complex query is:

--	A multi-layer SQL pipeline that transforms raw database tables into
--	a business-ready analytics report.

--It includes:

| Layer        | Purpose             |
| ------------ | ------------------- |
| CTE 1        | Base extraction     |
| CTE 2        | Business JOINs      |
| CTE 3        | Feature engineering |
| CTE 4        | Aggregation         |
| CTE 5        | Window analytics    |
| Final SELECT | Reporting output    |


2. Mental Model (VERY IMPORTANT)
/*
Think like a data team building a dashboard:

Step 1 — Raw Data
Payments + Customers + Staff

Step 2 — Cleaning + Structuring
Fix data format, join tables

Step 3 — Feature Engineering
Revenue, transactions, averages

Step 4 — Business Logic
Customer segments

Step 5 — Analytics Layer
Ranking, top performers

Step 6 — Final Report
Dashboard-ready table*/

Step-by-Step Professional Build

STEP 1 — Base Payments

WITH base_payments AS (
    SELECT
        customer_id,
        amount,
        payment_date
    FROM payment
)

--STEP 2 — JOIN Customer Info (Business Context)

customer_data AS (
    SELECT
        c.customer_id,
        c.first_name,
        c.last_name,
        bp.amount,
        bp.payment_date
    FROM base_payments bp
    JOIN customer c
        ON bp.customer_id = c.customer_id
)

--STEP 3 — Feature Engineering (Core Metrics)
--Now we build business features.

customer_features AS (
    SELECT
        customer_id,
        first_name,
        last_name,

        SUM(amount) AS total_revenue,
        COUNT(*) AS total_transactions,
        AVG(amount) AS avg_payment
    FROM customer_data
    GROUP BY customer_id, first_name, last_name
)

--STEP 4 — Business Segmentation (CASE WHEN Feature)
--Now we create customer categories:

customer_segments AS (
    SELECT
        *,
        CASE
            WHEN total_revenue > 150 THEN 'VIP'
            WHEN total_revenue > 80 THEN 'LOYAL'
            ELSE 'REGULAR'
        END AS customer_segment
    FROM customer_features
)

--STEP 5 — Analytics Layer (Window Functions)
--Now ranking customers:

ranked_customers AS (
    SELECT
        *,
        RANK() OVER (ORDER BY total_revenue DESC) AS revenue_rank
    FROM customer_segments
)




Final Query

WITH base_payments AS (
    SELECT
        customer_id,
        amount,
        payment_date
    FROM payment
),

customer_data AS (
    SELECT
        c.customer_id,
        c.first_name,
        c.last_name,
        bp.amount,
        bp.payment_date
    FROM base_payments bp
    JOIN customer c
        ON bp.customer_id = c.customer_id
),

customer_features AS (
    SELECT
        customer_id,
        first_name,
        last_name,

        SUM(amount) AS total_revenue,
        COUNT(*) AS total_transactions,
        AVG(amount) AS avg_payment
    FROM customer_data
    GROUP BY customer_id, first_name, last_name
),

customer_segments AS (
    SELECT
        *,
        CASE
            WHEN total_revenue > 150 THEN 'VIP'
            WHEN total_revenue > 80 THEN 'LOYAL'
            ELSE 'REGULAR'
        END AS customer_segment
    FROM customer_features
),

ranked_customers AS (
    SELECT
        *,
        RANK() OVER (ORDER BY total_revenue DESC) AS revenue_rank
    FROM customer_segments
)

SELECT
    customer_id,
    first_name,
    last_name,
    total_revenue,
    total_transactions,
    avg_payment,
    customer_segment,
    revenue_rank
FROM ranked_customers
ORDER BY revenue_rank;