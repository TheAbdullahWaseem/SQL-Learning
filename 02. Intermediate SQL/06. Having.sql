select avg(amount) from payment having avg(amount) > 3;
select customer_id, count(*), avg(amount) from payment group by customer_id having count(*) > 10;

select customer_id, count(*), avg(amount) from payment where payment_date > '2007-01-01'
group by customer_id having count(*) > 10;

Select customer_id, count(*), avg(amount) from payment group by customer_id having avg(amount) between 6 and 9 and count(*) > 15;

select customer_id, avg(amount) from payment group by customer_id having avg(amount) > (select avg(amount) from payment);
--Find customers who made more than 15 payments.
select customer_id, count(*) from payment group by customer_id having count(*) > 15;
--Find customers whose average payment is greater than the overall average payment.
select customer_id, avg(amount)  from payment group by customer_id having avg(amount) > (select avg(amount) from payment);
--Find customers whose maximum payment is greater than 10 but minimum payment is less than 5.
select customer_id, max(amount), min(amount) from payment group by customer_id having max(amount) > 10 and min(amount) < 5;
--Find customers whose average payment is between 6 and 9 dollars and who made more than 10 payments.
select customer_id, count(*), avg(amount) from payment group by customer_id having avg(amount) between 6 and 9 and count(*) > 10;
--Find customers whose average payment after 2007-01-01 is greater than 8.
select customer_id, avg(amount) from payment where payment_date > '2007-01-01' group by customer_id having avg(amount) > 8;