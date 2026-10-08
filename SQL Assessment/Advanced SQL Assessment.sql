

------------------------------------
Q1 — Customer Lifetime Value Tiering
------------------------------------

Build a CTE that calculates each customer total spend and total number of rentals. 
In the outer query, use a window function to rank customers into quartiles based on total spend 
then show customer_id, total_spend, total_rentals, and quartile. 
This is the kind of query that feeds a CRM segmentation dashboard.

---------
Solution:
---------

with customer_spend as (
	select
		customer_id,
		sum(amount) as total_spend
	from payment
	group by customer_id
),

customer_rentals as (
	select 
		customer_id,
		count(*) as total_rentals
	from rental
	group by customer_id
),

customer_metrics as (
    select
        c.customer_id,
        c.first_name,
        c.last_name,
        c.email,
        cs.total_spend,
        cr.total_rentals
    from customer c
    join customer_spend cs
        on c.customer_id = cs.customer_id
    join customer_rentals cr
        on c.customer_id = cr.customer_id
),

customer_segments as (
    select
        *,
        NTILE(4) over (
            order by total_spend desc
        ) as spend_quartile
    from customer_metrics
)

select 
    customer_id,
    first_name || ' ' || last_name AS customer_name,
    email,
    total_spend,
    total_rentals,
    spend_quartile
FROM customer_segments
ORDER BY total_spend DESC;

----------------------------------------------------------------------------------------------------



---------------------------------------------
Q2 — Month-over-Month Revenue Growth by Store
---------------------------------------------

First CTE: aggregate total monthly revenue per store. 
Outer query: use a window function partitioned by store to get the previous months revenue for each store, 
then calculate % growth month-over-month. 
Show store_id, month, revenue, prev_month_revenue, pct_growth.

---------
Solution:
---------


with store_revenue as (
	select
		c.store_id,
		date_trunc('month', p.payment_date) as month,
		sum(p.amount) as revenue
	from payment p
	join customer c 
		on p.customer_id = c.customer_id 
	group by
		c.store_id,
		date_trunc('month', p.payment_date)
),

monthly_revenue as (
	select 
		store_id,
		month,
		revenue,
		lag(revenue) over (
			partition by store_id
			order by month
		) as prev_month_revenue
	from store_revenue
),

store_growth as (
	select 
        store_id,
        month,
        revenue,
        prev_month_revenue,
        case
        	when prev_month_revenue is null or prev_month_revenue = 0 then null
        	else (revenue - prev_month_revenue) / prev_month_revenue
        end as MoM_growth_rate
	from monthly_revenue	
)

select 
	store_id,
	month,
	revenue,
	prev_month_revenue,
	round(MoM_growth_rate, 4) as MoM_growth_rate
from store_growth
order by store_id, month;

----------------------------------------------------------------------------------------------------




----------------------------------------------------------------------
Q3 — Top 2 Films per Category by Revenue, With Category Contribution %
----------------------------------------------------------------------

CTE 1: total revenue per film, joined to its category. 
CTE 2 (built on CTE 1): rank films within each category by revenue .
Also calculate what % each film contributes to its categorys total revenue. 
Final output: 
only the top 2 films per category, showing category name, film title, revenue, rank, 
and pct_of_category_revenue.

---------
Solution:
---------

with film_revenue as (
	select 
		f.film_id,
		f.title as film_title,
		c.name as category_name,
		sum(p.amount) as revenue
	from payment p
	join rental r
		on p.rental_id = r.rental_id	
	join inventory i 
		on r.inventory_id = i.inventory_id 
	join film f
		on i.film_id = f.film_id
	join film_category fc
		on f.film_id = fc.film_id
	join category c
		on fc.category_id = c.category_id
	group by 
		f.film_id,
		f.title,
		c.name
),

category_analysis as (
	select 
		film_id,
		film_title,
		category_name,
		revenue,
		dense_rank() over (
			partition by category_name
			order by revenue desc
		) as revenue_rank,
		
		sum(revenue) over (
			partition by category_name
		) as category_total_revenue
	from film_revenue
),

percentage_growth as (
	select 
		film_id,
		film_title,
		category_name,
		revenue,
		revenue_rank,
		
		round(
		revenue / category_total_revenue, 4) as pct_category_revenue
	from category_analysis
)

select
	film_id,
	film_title,
	category_name,
	revenue,
	revenue_rank,
	pct_category_revenue
from percentage_growth
where revenue_rank <= 2
order by 
	category_name,
	revenue_rank;

----------------------------------------------------------------------------------------------------



------------------------------------------------------------------
Q4 — Staff Performance Running Total + Comparison to Store Average
------------------------------------------------------------------

CTE: total revenue collected per staff member per month. 
Outer query: calculate a running total of each staff members revenue over time (ordered by month) 
AND in the same query show how their monthly revenue compares to the average monthly revenue across all staff in their store 
(a window function partitioned differently than the running total one — so two window functions doing different jobs in one query).

---------
Solution:
---------

with monthly_staff_revenue as (
	select 
		s.staff_id,
		s.store_id,
		date_trunc('month', p.payment_date) as month,
		sum(p.amount) as monthly_revenue
	from payment p
	join staff s
		on p.staff_id = s.staff_id
	group by 
		s.staff_id,
		s.store_id,
		date_trunc('month', payment_date)
),

staff_metrics as (
	select 
		staff_id,
		store_id,
		month,
		monthly_revenue,
		
		sum(monthly_revenue) over (
			partition by staff_id
			order by month
		) as running_revenue,
		
		avg(monthly_revenue) over (
			partition by store_id, month
		) as store_avg_monthly_revenue
		
	from monthly_staff_revenue
)

select 
	staff_id,
	store_id,
	month,
	monthly_revenue,
	running_revenue,
	store_avg_monthly_revenue,
	
	case 
		when store_avg_monthly_revenue = 0
			or
			 store_avg_monthly_revenue is null
			 then null
		else (monthly_revenue - store_avg_monthly_revenue) * 1.0 / store_avg_monthly_revenue
	end as store_avg_pct
from staff_metrics
order by 
	store_id,
	staff_id,
	month;
	
----------------------------------------------------------------------------------------------------
	

	
--------------------------------------------------------
Q5 — Customer Churn Risk Flag Using Gaps Between Rentals
--------------------------------------------------------

CTE: for every customer, get each rental date and the date of their previous rental 
(this requires a value-access window function). 
Outer query: calculate the gap in days between consecutive rentals, 
then flag any customer whose most recent gap exceeds 60 days as "Churn Risk." 
Final output: customer_id, last_rental_date, previous_rental_date, gap_days, churn_flag.	

---------
Solution:
---------

with customer_rental_history as (
    select
        customer_id,
        rental_date,
        lag(rental_date) over (
            partition by customer_id
            order by rental_date
        ) as previous_rental_date
    from rental
),

rental_gap_analysis as (
    select
        customer_id,
        rental_date as last_rental_date,
        previous_rental_date,
        extract(day from rental_date - previous_rental_date)::int as gap_days
    from customer_rental_history
),

latest_customer_activity as (
    select
        customer_id,
        last_rental_date,
        previous_rental_date,
        gap_days,
        row_number() over (
            partition by customer_id
            order by last_rental_date desc
        ) as activity_rank
    from rental_gap_analysis
)

select
    customer_id,
    last_rental_date,
    previous_rental_date,
    gap_days,
    case
        when gap_days is null then 'Insufficient History'
        when gap_days > 60    then 'Churn Risk'
        else                       'Active'
    end as churn_flag
from latest_customer_activity
where activity_rank = 1
order by customer_id;

----------------------------------------------------------------------------------------------------



-----------------------------------------------------
Q6 — Category Revenue Share with Running Cumulative %
-----------------------------------------------------

CTE: total revenue per category. 
Outer query: order categories by revenue descending, 
calculate each categorys % of total revenue, and a running cumulative % 
(this is the classic Pareto/80-20 analysis pattern used in real inventory and merchandising decisions).

---------
Solution:
---------

with category_revenue as (
	select 
		c.category_id,
		c.name as category_name,
		sum(p.amount) as total_revenue
	from payment p
	join rental r
		on p.rental_id = r.rental_id 
	join inventory i
		on r.inventory_id = i.inventory_id 
	join film f
		on i.film_id = f.film_id
	join film_category fc
		on f.film_id = fc.film_id 
	join category c
		on fc.category_id = c.category_id
	group by
		c.category_id,
		c.name
),

category_share as (
	select 
		category_id,
		category_name,
		total_revenue,
		
		round(
		(total_revenue * 100)
		/
		sum(total_revenue) over(),
		2
		) as revenue_share_pct
	from category_revenue
),

pareto_analysis as (
	select 
		category_id,
		category_name,
		total_revenue,
		revenue_share_pct,
		sum(revenue_share_pct) over (
			order by total_revenue desc
			rows between
				unbounded preceding
				and current row
		) as cumulative_share_pct
	from category_share
)

select
    category_id,
    category_name,
    total_revenue,
    revenue_share_pct,
    cumulative_share_pct
from pareto_analysis
order by total_revenue desc;

----------------------------------------------------------------------------------------------------



-----------------------------------------------
Q7 — New vs Returning Customer Revenue by Month
-----------------------------------------------

CTE: find each customers first-ever rental date (their "cohort month"). 
Second CTE: join that back to all their rentals/payments
and use CASE to label each transaction as "New" (if its in their first month) or "Returning." 
Outer query: aggregate monthly revenue split by New vs Returning, 
and use a window function to show each months revenue as a % of total revenue across the whole period.

---------
Solution:
---------

with customer_first_rental as (
	select 
		customer_id,
		date_trunc('month', rental_date) as cohort_month,
		row_number() over (
			partition by customer_id
			order by rental_date
		) as rn
	from rental
),

customer_cohort as (
	select 
		customer_id,
		cohort_month
	from customer_first_rental
	where rn = 1
),

labeled_transaction as (
	select
		p.customer_id,
		c.cohort_month,
		date_trunc('month', p.payment_date) as transaction_month,
		p.amount,
		
		case
			when date_trunc('month', p.payment_date) = c.cohort_month
				then 'New'
		else 'Returning'
		end as customer_type
		
	from payment p
	join customer_cohort c
		on p.customer_id = c.customer_id
),

monthly_revenue as (
	select
		transaction_month,
		customer_type,
		sum(amount) as revenue
	from labeled_transaction
	group by
		transaction_month,
		customer_type
)

select 
	transaction_month,
	customer_type,
	revenue,
	
	round(
		revenue * 100.0
		/
		sum(revenue) over (),
		2
		) as pct_of_total_revenue
from monthly_revenue
order by 
	transaction_month,
	customer_type;
	
----------------------------------------------------------------------------------------------------
	
	
	
-------------------------------------------	
Q8 — Film Performance vs Category Benchmark
-------------------------------------------

CTE: revenue and rental count per film, joined with category. 
Outer query: for each film, use a window function to compute the average revenue of its category, 
then calculate how far above/below that benchmark each film performs 
(both as an absolute difference and a CASE-labeled flag: "Above Average" / "Below Average" / "At Average").

---------
Solution:
---------

with film_metrics as (
	select 
		f.film_id,
		f.title as film_name,
		c.name as category_name,
		sum(p.amount) as film_revenue,
		count(r.rental_id) as total_rentals
	from payment p
	join rental r
		on p.rental_id  = r.rental_id
	join inventory i	
		on i.inventory_id = r.inventory_id 
	join film f 
		on i.film_id = f.film_id 
	join film_category fc
		on f.film_id = fc.film_id
	join category c
		on fc.category_id = c.category_id
	group by
		f.film_id,
		f.title,
		c.name
),

average_revenue as (
	select 
		film_id,
		film_name,
		category_name,
		film_revenue,
		total_rentals,
		
		avg(film_revenue) over (
			partition by category_name
		) as category_avg_revenue
	from film_metrics
),

film_performance as (
	select 
		film_id,
		film_name,
		category_name,
		film_revenue,
		total_rentals,
		category_avg_revenue,
		
		(film_revenue - category_avg_revenue) as revenue_vs_category_avg,
		
		case
			when film_revenue > category_avg_revenue then 'Above Average'
			when film_revenue < category_avg_revenue then 'Below Average'
			else 'At Average'
		end as performance_flag
	from average_revenue	
)

select *
from film_performance
order by
	category_name,
	revenue_vs_category_avg desc;

----------------------------------------------------------------------------------------------------



-------------------------------------------
Q9 — Rolling 3-Month Revenue Trend by Store
-------------------------------------------

CTE: monthly revenue per store. 
Outer query: use a frame-clause window function to calculate a rolling 3-month average revenue for each store, 
and flag months where actual revenue beats the rolling average as "Outperforming."

---------
Solution:
---------

with monthly_revenue as (
	select 
		c.store_id,
		date_trunc('month', payment_date) as month,
		sum(p.amount) as revenue
	from payment p 
	join customer c
		on c.customer_id = p.customer_id 
	group by 
		c.store_id,
		date_trunc('month', payment_date)
),

rolling_analysis as (
	select 
		store_id,
		month,
		revenue,
		
		avg(revenue) over (
			partition by store_id
			order by month
			rows between 
				2 preceding
				and current row
				) as rolling_3_month_avg
		from monthly_revenue
),

flag_months as (
	select 
		store_id,
		month,
		revenue,
		rolling_3_month_avg,
		
		case
			when revenue > rolling_3_month_avg then 'Outperforming'
			else 'Underperforming'
		end as perfromance
	from rolling_analysis
		
)

select *
from flag_months;

----------------------------------------------------------------------------------------------------



------------------------------------------------------------------------
Q10 — Most Valuable Customer per Store with Rank and Spend Concentration
------------------------------------------------------------------------

CTE 1: total spend per customer, joined to their home store. 
CTE 2 (built on CTE 1): rank customers within each store by spend, 
and also calculate what % of their stores total revenue each customer represents. 
Final output: only rank 1 customer per store, showing store_id, customer_id, total_spend, rank, 
and pct_of_store_revenue.

---------
Solution:
---------

with customer_spend as (
	select 
		c.customer_id, 
		c.first_name || ' ' || c.last_name as full_name,
		c.store_id,
		sum(p.amount) as total_spend
	from customer c
	join payment p 
		on p.customer_id = c.customer_id 
	group by 
		c.store_id,
		c.customer_id,
		c.first_name,
		c.last_name
),
customer_metrics as (
	select 
		customer_id,
		full_name,
		store_id,
		total_spend,
		
		dense_rank() over (
			partition by store_id
			order by total_spend desc
		) as customer_rank,
		
		sum(total_spend) over (
			partition by store_id
		) as store_total_revenue
	from customer_spend
)

select 
	customer_id,
	full_name,
	store_id,
	total_spend,
	customer_rank,
		
	round(
		(total_spend * 100)
		/
		store_total_revenue,
		2) as pct_of_store_revenue
from customer_metrics
where customer_rank = 1
order by store_id;

----------------------------------------------------------------------------------------------------