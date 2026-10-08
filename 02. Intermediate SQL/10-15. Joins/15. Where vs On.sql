-- Example 1
SELECT c.customer_id, p.amount
FROM customer c
INNER JOIN payment p
  ON c.customer_id = p.customer_id
WHERE p.amount > 10;

-- Example 2
SELECT c.customer_id, p.amount
FROM customer c
LEFT JOIN payment p
  ON c.customer_id = p.customer_id
WHERE p.amount > 10;

SELECT c.customer_id, p.amount
FROM customer c
LEFT JOIN payment p
  ON c.customer_id = p.customer_id
 AND p.amount > 10;

SELECT c.customer_id, c.first_name, p.amount
FROM customer c
LEFT JOIN payment p
ON c.customer_id = p.customer_id
WHERE p.amount IS NULL;

SELECT c.customer_id, c.first_name, p.amount
FROM customer c
LEFT JOIN payment p
ON c.customer_id = p.customer_id AND p.amount IS NULL;

select c.customer_id, c.first_name, p.amount
from customer c
left join payment p
	on c.customer_id = p.customer_id 
	and (p.amount > 5 or p.amount is null);

--Return: All customers, Only payments where amount > 7, But still show customers who never made a payment
select c.customer_id, p.amount
from customer c 
left join payment p
	on c.customer_id = p.customer_id 
	and p.amount > 7;

--Return: All customers, Payments between 5 and 10, Preserve customers with no payments
select c.customer_id, p.amount
from customer c
left join payment p
	on c.customer_id = p.customer_id
	and p.amount between 5 and 10;

--Return customers: Whose first name starts with 'A', AND whose payment amount is greater than 5, OR whose payment amount is NULL
select c.customer_id, c.first_name, p.amount
from customer c 
left join payment p 
	on c.customer_id  = p.customer_id 
	where (p.amount > 5 and c.first_name like 'A%') or p.amount is null;

--Return customers who: Have no payments at all
select c.customer_id, p.amount
from customer c
left join payment p
	on c.customer_id = p.customer_id 
	where p.customer_id is null;

--Return: customer_id , total amount spent , But only include customers: Whose total spending is greater than 100 
--And whose first name starts with 'M'
select c.customer_id, c.first_name , sum(p.amount) as total_amount
from customer c
left join payment p
	on c.customer_id = p.customer_id
	where c.first_name like 'M%'
	group by c.customer_id , c.first_name
	having coalesce(sum(p.amount), 0) > 100;

--Return: DISTINCT customer first names, Who made payments greater than 8
select distinct c.first_name
from customer c
left join payment p
	on c.customer_id = p.customer_id
	where p.amount > 8
	order by c.first_name ASC;

--Return: customer_id , amount , A new column: 'High' if amount > 8 , 'Medium' if amount BETWEEN 5 AND 8 , 'Low' otherwise
--Only include: Customers whose first name starts with 'J' , And amount is NOT NULL 
select c.customer_id, c.first_name , p.amount,
case 
	when p.amount > 8 then 'High'
	when p.amount between 5 and 8 then 'Medium'
	else 'Low'
end as Payment_Category
	from customer c
	left join payment p
		on c.customer_id = p.customer_id
		where c.first_name like 'J%' and p.amount is not null;

--Using FULL OUTER JOIN between customer and payment: Return rows where: Either customer has no payment
--OR payment does not match a customer
select c.customer_id, p.amount
from customer c 
full outer join payment p
	on c.customer_id = p.customer_id
	where c.customer_id is null or p.customer_id is null;

--Write TWO queries: 
--A) Filter amount > 6 inside the JOIN. 
--B) Filter amount > 6 using WHERE. 
--Then observe:  
--Do they return the same result? 
--Why or why not?
select c.customer_id, p.amount
from customer c 
left join payment p
	on c.customer_id = p.customer_id
	and amount > 6;

select c.customer_id, p.amount
from customer c 
left join payment p
	on c.customer_id = p.customer_id
	where amount > 6;
/*
Return customers who: 
Have payments greater than 10 , But exclude payments between 1 and 10 
Still show customers with no payments 
*/
select c.customer_id, p.amount 
from customer c
left join payment p 
	on c.customer_id = p.customer_id 
	and p.amount > 10;