select email, address_id, count(*) as total from customer group by email, address_id;
select email, address_id, count(*) as total from customer group by 1, 2;

select customer_id, sum(amount) from payment group by customer_id;
select customer_id, count(*) from rental group by customer_id;
--Revenue per Customer
select customer_id, sum(amount) as total_spent from payment group by customer_id;
--group by multiple columns
select customer_id, staff_id, count(*) as total from payment group by 1, 2 order by total;

SELECT payment_date, SUM(amount)
FROM payment
GROUP BY payment_date;
--same as
SELECT DATE(payment_date), SUM(amount)
FROM payment
GROUP BY DATE(payment_date);
--1️⃣ Count how many payments exist for each customer.
select customer_id, count(*) from payment group by customer_id;
--2️⃣ Find the total amount paid per customer.
select customer_id, sum(amount) as "Total Amount" from payment group by customer_id order by sum(amount) desc;  
--3️⃣ Find the average payment amount per day.
select Date(payment_date), avg(amount) as "Average Amount" from payment group by Date(payment_date);
--4️⃣ Show the maximum payment amount for each customer.
select customer_id, max(amount) from payment group by customer_id;
--5️⃣ How many rentals happened on each rental_date?
select date(rental_date), count(*) from rental group by date(rental_date);
--6️⃣ Find customers who made more than 30 payments.
select customer_id, count(amount) from payment group by customer_id having count(amount) > 30;
--7Find customers whose average payment amount is greater than 6.
select customer_id, avg(amount) as "average payment amount" from payment group by customer_id having avg(amount) > 6;
--8For each day, show: total revenue, number of payments
select date(payment_date), sum(amount) as Total_revenue, count(amount) as Number_of_payments
from payment group by date(payment_date) order by sum(amount) desc;
--9Find customers who made payments on more than 3 different days.
select customer_id, count(distinct payment_date) as Days from payment group by customer_id having count(distinct payment_date) > 3;