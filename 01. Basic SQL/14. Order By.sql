select * from payment order by amount;

select * from payment order by amount DESC;
--ORDER BY Multiple Columns
select * from payment order by customer_id asc, amount desc;
--ORDER BY Text Columns
select * from customer order by first_name;
select * from customer order by first_name DESC;
--Order By Expressions
select amount, amount * 10 as Multiplied_Column from payment order by Multiplied_Column DESC;  
--ORDER BY with AND / OR
select * from payment where customer_id = 1 or customer_id = 2 order by amount desc;
--ORDER BY with NULL Values
select * from payment order by amount asc nulls first;
select * from payment order by amount desc nulls last;
--ORDER BY with OFFSET
select * from payment order by amount desc limit 5 offset 5;
--Get top 3 highest payments
select * from payment order by amount desc limit 3;
--Get 5 lowest payments but skip first 5 rows
select * from payment order by amount asc limit 5 offset 5;