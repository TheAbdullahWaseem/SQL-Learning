select * from payment;
select min(amount) from payment where payment_date >= '2007-02-16' and payment_date < '2007-02-17';

select customer_id, min(amount) as smallest_payment, max(amount) as max_payment from payment group by customer_id;
select customer_id, min(payment_date) as first_payment,
					max(payment_date) as last_payment
from payment group by customer_id;

select min(first_name), max(first_name) from customer;
select max(amount) from payment;
select * from payment where amount = (select max(amount) from payment);

select max(amount) from payment;
select amount from payment order by amount desc limit 1;
--Find the earliest payment date in the entire table.
select min(payment_date) as earliest_payment_date from payment;
--For each customer, find the difference between their largest and smallest payment.
select customer_id, (max(amount) - min(amount)) as difference from payment group by customer_id;
--Find customers whose first payment happened before 2008.
select customer_id, min(payment_date) from payment group by customer_id having min(payment_date) < '2008-01-01'; 
select payment_date from payment;

--Find the highest payment ever made.
select max(amount) from payment;
--2️⃣ Date Logic: Find the most recent payment date in the table.
select max(payment_date) from payment;
--🔹 3️⃣ For each customer, show: earliest payment date latest payment date
select customer_id, min(payment_date) as earlist_payment_date,
					max(payment_date) as lastest_payment_date
from payment group by customer_id
--🔹 4️⃣ Find customers whose largest payment was greater than 10.
select customer_id, max(amount) from payment group by customer_id having max(amount) > 10;
--🔹 5️⃣ Find customers whose smallest payment was greater than 5.
select customer_id, min(amount) from payment group by customer_id having min(amount) > 5;
--For each customer, calculate the difference between their max and min payment,
-- and return only customers where that difference is greater than 8.
select customer_id, (max(amount) - min(amount)) as Difference_greater_than_8 from payment
group by customer_id having (max(amount) - min(amount)) > 8;
--For each customer, return: total payments (COUNT), smallest payment, largest payment
--But only include customers who made more than 20 payments.
select customer_id, count(*) as total_payment, min(amount) as smallest_payment, max(amount) as largest_payment
from payment group by customer_id having count(amount) > 20;
--For each customer, find the maximum payment after 2007-01-01.
select customer_id, max(amount) from payment where payment_date > '2007-01-01' group by customer_id;
--Find the earliest payment date for payments between 5 and 10 dollars.
select min(payment_date) as earliest_payment_date from payment where amount between 5 and 10;
--Find customers whose maximum payment is exactly equal to their minimum payment.
select customer_id, min(amount), max(amount) from payment group by customer_id having min(amount) = max(amount);
--Find customers whose earliest payment happened in 2007.
select customer_id, min(payment_date) as earlist_payment from payment group by customer_id 
having min(payment_date) >= '2007-01-01' and min(payment_date) < '2008-01-01'