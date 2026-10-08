CREATE TABLE customers_dirty (
    customer_id INT,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    email VARCHAR(100),
    city VARCHAR(50),
    signup_date VARCHAR(50),
    total_spent VARCHAR(20)
);

INSERT INTO customers_dirty VALUES
(1, 'Ali', 'Khan', 'ali@gmail.com', 'lahore', '2023/01/15', '100'),
(2, 'Sara', 'Ahmed', NULL, 'Lahore ', '15-02-2023', '200'),
(3, 'John', 'Doe', 'john@gmail.com', 'KARACHI', 'March 5, 2023', '300'),
(4, 'Fatima', 'Ali', 'fatima@gmail.com', 'karachi', NULL, NULL),
(5, 'Usman', 'Raza', 'usman@gmail.com', 'Islamabad', '2023-04-10', 'abc'),
(6, 'Ali', 'Khan', 'ali@gmail.com', 'lahore', '2023/01/15', '100'); 


select * from  customers_dirty;

select column_name, data_type
from information_schema.columns
where table_name = 'customers_dirty';

--Step 1: Handiling Null Values
select * from customers_dirty
where email is null;
--Remove Null Values
select first_name, coalesce(email, 'Not Provided') as email
from customers_dirty;

--Step 2: Remove duplicates
select first_name, last_name, count(*)
from customers_dirty
group by first_name, last_name
having count(*) > 1;
--Remove duplicates
select distinct * from customers_dirty;

--Step 3: Clean Text Data
select upper(city) from customers_dirty;
select replace(city, 'karachi', 'Karachi') from customers_dirty; 

--step 4: Fix Data Types
select * from  customers_dirty;
select total_spent::integer from customers_dirty
where total_spent != 'abc';

select 
case 
	when total_spent ~ '^[0-9]+$' then cast(total_spent as int)
	else null
end as clean_spent
from customers_dirty;


--Step 5: Fix Date Formats

select signup_date from customers_dirty;
select signup_date::Date from customers_dirty;

--Step 6: Handle Invalid Values
--1. Replace the Invalid Values
--Sometimes we remove bad data with a default value
select
first_name,
case 
	when total_spent ~ '^[0-9]+$'
	then cast(total_spent as int)
	else 0
end as clean_total_spent
from customers_dirty;

--2. Remove the invalid Rows
 SELECT *
FROM customers_dirty
WHERE total_spent ~ '^[0-9]+$';

--3. find the invalid Data
select 
	first_name,
	total_spent,
	case
		when total_spent ~ '^[0-9]+$'
		then 'valid'
		else 'Invalid'
	end as data_status
from customers_dirty;


--Step 7: Create New Features
select first_name,
case
	when total_spent ~ '^[0-9]+$' and 
	cast(total_spent as int) > 200 then 'VIP'
	else 'Regular'
end as customer_type
from customers_dirty;

--step 8: Final Clean Dataset
select
customer_id,
trim(upper(first_name)) as first_name,
trim(upper(last_name)) as last_name,
coalesce(email, 'Not Provided') as email,
trim(upper(city)) as city,
case 
	when total_spent ~ '^[0-9]+$' then cast(total_spent as int)
	else null 
end as total_spent
from customers_dirty;



--Data Wrangling Parctice Set
/*Question 1 — Identify Data Quality Problems

Write a query that returns:

total number of rows
number of rows with NULL emails
number of rows with invalid total_spent values
number of rows with NULL signup_date*/
select 
	count(*) as total_rows,
	count(case
		when email is null then 1
	end
	) as null_emails,
	count(
	case
		when total_spent !~ '^[0-9]+$' or total_spent is null
		then 1
	end
	) as invalid_total_spent_values,
	count(
	case
		when signup_date is null then 1
		else null
	end
	) as null_signup_date
	
	from customers_dirty;
	
	
	
select * from customers_dirty cd ;

/*Question 2 — Detect Logical Duplicates
Find customers that appear more than once based on:
first_name
last_name
email
Return:
first_name
last_name
email
duplicate_count
Only show rows where duplicates exist.*/

select first_name, last_name, email, 
count(*) as total
from customers_dirty cd 
group by first_name, last_name, email
having count(*) > 1;

/*Question 3 — Standardize the City Column
Clean the city column so that:
lahore ,Lahore, Lahore
All become: Lahore
Also fix: karachi, KARACHI
so they become: Karachi
Return: customer_id, clean_city
You must combine multiple functions.*/
select customer_id, initcap(lower(trim(city))) as clean_city
from customers_dirty;

/*Question 4 — Clean and Convert total_spent
Create a column called:
clean_total_spent
Rules:
•	if the value contains only digits → convert to integer 
•	if the value is invalid → return NULL */

select total_spent,
		case
			when total_spent ~ '^[0-9]+$' then total_spent::integer
			else null
		end as clean_total_spent
		from customers_dirty cd;
				
/*Question 5 — Flag Data Quality Issues
Create a query that labels each row as:
Clean
Needs Review
A row needs review if:
•	email is NULL 
•	signup_date is NULL 
•	total_spent is invalid 
Return:
customer_id
data_quality_status*/

select customer_id,
 case
 	when email is null 
 	or signup_date is null 
 	or total_spent is null
 	or total_spent !~ '^[0-9]+$'
 	then 'Needs Review'
 	else 'Clean'
 end as data_quality_status
from customers_dirty; 

/*Question 7 — Fix Multiple Date Formats
Convert signup_date into a proper DATE column called:
clean_signup_date
Possible formats include:
2023/01/15
15-02-2023
March 5, 2023
2023-04-10
Use conditional logic to convert them properly.*/

select * from customers_dirty;
SELECT 
    signup_date,
    CASE
        -- Format: 2023/01/15
        WHEN signup_date ~ '^\d{4}/\d{2}/\d{2}$'
        THEN TO_DATE(signup_date, 'YYYY/MM/DD')

        -- Format: 15-02-2023
        WHEN signup_date ~ '^\d{2}-\d{2}-\d{4}$'
        THEN TO_DATE(signup_date, 'DD-MM-YYYY')

        -- Format: March 5, 2023
        WHEN signup_date ~ '^[A-Za-z]+ \d{1,2}, \d{4}$'
        THEN TO_DATE(signup_date, 'Month DD, YYYY')

        -- Format: 2023-04-10
        WHEN signup_date ~ '^\d{4}-\d{2}-\d{2}$'
        THEN TO_DATE(signup_date, 'YYYY-MM-DD')

        ELSE NULL
    END AS clean_signup_date
FROM customers_dirty;

SELECT DISTINCT signup_date
FROM customers_dirty;

--OR 

select signup_date,
case
	when signup_date like '____/__/__' then to_date(signup_date, 'YYYY/MM/DD')
	when  signup_date like '__-__-____' then to_date(signup_date, 'DD-MM-YYYY')
	when  signup_date like '% %, ____' then to_date(signup_date, 'Month DD, YYYY')
	when  signup_date like '____-__-__' then to_date(signup_date, 'YYYY/MM/DD')
	else null
end as clean_signup_date
from customers_dirty;