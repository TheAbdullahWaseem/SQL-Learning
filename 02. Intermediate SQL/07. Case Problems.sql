/*1 Payment Category Label
Write a query to show:
•	payment_id
•	amount
•	a new column payment_type where:
o	amount < 3 → 'Small'
o	amount between 3 and 7 → 'Medium'
o	amount > 7 → 'Large'
*/
select 
	payment_id,
	amount,
	case 
		when amount < 3 then 'Small'
		when amount between 3 and 7 then 'Medium'
		else 'Large'
	end as payment_type
from payment

/*2 Custom Sorting
Display:
•	payment_id
•	amount
Sort results so:
•	Large payments first
•	Medium payments second
•	Small payments last
*/
select 
	payment_id,
	amount,
	case 
		when amount < 3 then 'Small'
		when amount between 3 and 7 then 'Medium'
		else 'Large'
	end as payment_type
from payment
order by 
	case 
		when amount < 3 then 3
		when amount between 3 and 7 then 2
		else 1	
	end ASC;
	
/*3 Customer Spending Category
For each customer:
•	customer_id
•	total_amount
•	spending_level
Where:
•	total < 100 → 'Low'
•	100–200 → 'Medium'
•	200 → 'High'
*/
select 
	customer_id,
	sum(amount) as total_amount,
	case 
		when sum(amount) < 100 then 'Low'
		when sum(amount) between 100 and 200 then 'Medium'
		when sum(amount) > 200 then 'High'
		else 'Other'
	end as spending_level
from payment 
group by customer_id 
order by 
	case 
		when sum(amount) < 100 then 4
		when sum(amount) between 100 and 200 then 3
		when sum(amount) > 200 then 2
		else 1
	end ASC;

/*4 Risk Score per Customer
For each customer calculate:
•	customer_id
•	average_risk_score
Where each payment:
•	amount < 2 → 0
•	2–5 → 1
•	5 → 2
Then average the score per customer.
*/
select 
	customer_id,
	Avg
		(
		case
			when amount < 2 then 0
			when amount between 2 and 5 then 1
			else 2
		end
		) as average_risk_score
from payment
group by customer_id
order by average_risk_score desc;
	
/* 5 Count Large Payments per Customer
For each customer:
•	customer_id
•	number_of_large_payments
Where large payment = amount > 6
*/
select 
	customer_id,
	sum
		(
		case
			when amount > 6 then 1
		end
		) as large_payments
from payment
group by customer_id 
order by large_payments desc;

/*6 Late Return Classification
From rental table:
•	rental_id
•	rental_duration (return_date - rental_date)
•	status:
If:
•	returned in 1 day → 'Fast'
•	2–4 days → 'Normal'
•	5+ days → 'Late'
*/
select
	rental_id,
	(return_date - rental_date) as rental_duration,
	case
		when return_date is null then 'Not Returned'
		when extract(day from (return_date - rental_date)) <=1 then 'Fast'
		when extract(day from (return_date - rental_date)) between 2 and 4 then 'Normal'
		else 'Late'
	end as status
from rental;

/*7 Advanced Customer Label
For each customer:
If total spending > 200:
•	If total payments > 30 → 'VIP'
•	Else → 'Premium'
Else:
•	If total payments > 30 → 'Frequent'
•	Else → 'Regular'
Return:
•	customer_id
•	label
*/
select 
	customer_id,
	case 
		when sum(amount) > 200 then
		case
			when count(*) > 30 then 'VIP'
			else 'Premium'
		end
		when  count(*) > 30 then 'Frequent'
		else 'Regular'
	end as label
from payment 
group by customer_id;

-- OR

select 
	customer_id,
	case
		when sum(amount) > 200 and count(*) > 30 then 'VIP'
		when sum(amount) > 200 then 'Premium'
		when count(*) > 30 then 'Frequent'
		else 'Regular'
	end as label
from payment
group by customer_id;
	
/*Customers with More Large than Small Payments
Large payment = amount > 6
Small payment = amount < 3
Return customers where:
number_of_large_payments > number_of_small_payments
*/
select 
	customer_id,
	
	count(case when amount > 6 then 1 end) as large_payments,
	count(case when amount < 3 then 1 end) as small_payments
	
from payment
group by customer_id

having
	count(case when amount > 6 then 1 end) 
	>
	count(case when amount < 3 then 1 end);
		
/* 9 Safe Return Status
From rental table:
If return_date IS NULL → 'Not Returned'
Else:
If return_date - rental_date <= 3 → 'On Time'
Else → 'Late'
Return:
•	rental_id
•	status
*/
select
	rental_id,
	case 
		when return_date is null then 'Not Returned'
		when extract(epoch from (return_date - rental_date))/86400 <= 3 then 'On Time'
		else 'Late'
 	end as status
 from rental;

/* 10 Large Payment Percentage
For each customer calculate:
•	customer_id
•	total_payments
•	percentage_of_large_payments
Where:
large = amount > 6
Example output:
customer 1 → 40%
customer 2 → 75%
*/
select
	customer_id,
	count(*) as total_payments,
	
	count(case when amount > 6 then 1 end) as large_payments,
	
	(count(case when amount > 6 then 1 end) * 100)
	/
	count(*)			--count(part)/count(total)
	as percentage_of_large_payments
	
from payment
group by customer_id;

/*
Type		Example					Formula

Value percentage	marks, money			sum(part)/sum(total)
Count percentage	events, actions			count(part)/count(total)
*/