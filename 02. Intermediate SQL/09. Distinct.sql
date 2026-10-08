select customer_id from payment;
select distinct customer_id from payment;
select distinct customer_id, amount from payment;

select count(distinct customer_id) 
from payment;
select sum(distinct amount) from payment;
select distinct customer_id, payment_date from payment;

select distinct amount from payment order by amount desc;
select count(amount) as total_amount, count(distinct amount) as unique_total from payment;

select count(distinct customer_id), count(distinct amount) from payment;

--List all unique customers who made payments.
select distinct customer_id from payment;
--Show all unique combinations of customer and amount.
select distinct customer_id, amount from payment;
--How many unique payment amounts exist in the table?
select count(distinct amount) as unique_payments from payment;
--For each customer, count the number of unique "large" payments (amount > 6).
select customer_id,
count(distinct case when amount > 6 then payment_id else 0 end) as unique_large_payments
from payment
group by customer_id;
--Find customers who made payments with unique amounts greater than 8.
select customer_id from (select distinct customer_id, amount from payment where amount > 8) as sub  order by customer_id;