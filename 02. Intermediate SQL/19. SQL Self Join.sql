CREATE TABLE employees (
    employee_id INT PRIMARY KEY,
    employee_name VARCHAR(50),
    department VARCHAR(50),
    salary INT,
    manager_id INT
);

CREATE TABLE customers (
    customer_id INT PRIMARY KEY,
    customer_name VARCHAR(50),
    city VARCHAR(50),
    email VARCHAR(100),
    age INT
);

CREATE TABLE orders (
    order_id INT PRIMARY KEY,
    customer_id INT,
    product_name VARCHAR(50),
    amount INT,
    order_date DATE
);

INSERT INTO employees VALUES
(1, 'Ali', 'Management', 150000, NULL),
(2, 'Ahmed', 'Sales', 90000, 1),
(3, 'Sara', 'Sales', 85000, 1),
(4, 'John', 'IT', 95000, 1),
(5, 'David', 'IT', 80000, 4),
(6, 'Emma', 'HR', 75000, 1),
(7, 'Sophia', 'Sales', 72000, 2),
(8, 'Daniel', 'IT', 70000, 4),
(9, 'James', 'HR', 68000, 6),
(10, 'Olivia', 'Sales', 65000, 2),
(11, 'Noah', 'IT', 64000, 4),
(12, 'Liam', 'HR', 62000, 6),
(13, 'Mason', 'Sales', 60000, 3),
(14, 'Lucas', 'IT', 59000, 4),
(15, 'Ethan', 'Sales', 58000, 2),
(16, 'Ava', 'HR', 57000, 6),
(17, 'Mia', 'IT', 56000, 4),
(18, 'Charlotte', 'Sales', 55000, 3),
(19, 'Amelia', 'IT', 54000, 4),
(20, 'Harper', 'HR', 53000, 6);

INSERT INTO customers VALUES
(1, 'Ali', 'Lahore', 'ali@gmail.com', 25),
(2, 'Ahmed', 'Karachi', 'ahmed@gmail.com', 30),
(3, 'Sara', 'Lahore', 'sara@gmail.com', 22),
(4, 'John', 'Islamabad', 'john@gmail.com', 35),
(5, 'Emma', 'Karachi', 'emma@gmail.com', 28),
(6, 'David', 'Lahore', 'david@gmail.com', 40),
(7, 'Sophia', 'Peshawar', 'sophia@gmail.com', 26),
(8, 'Daniel', 'Islamabad', 'daniel@gmail.com', 31),
(9, 'Olivia', 'Karachi', 'olivia@gmail.com', 27),
(10, 'Noah', 'Lahore', 'noah@gmail.com', 29),
(11, 'Mia', 'Peshawar', 'mia@gmail.com', 24),
(12, 'Liam', 'Islamabad', 'liam@gmail.com', 33),
(13, 'Ava', 'Karachi', 'ava@gmail.com', 21),
(14, 'Lucas', 'Lahore', 'lucas@gmail.com', 36),
(15, 'Ethan', 'Peshawar', 'ethan@gmail.com', 32),
(16, 'Amelia', 'Islamabad', 'amelia@gmail.com', 23),
(17, 'James', 'Karachi', 'james@gmail.com', 34),
(18, 'Charlotte', 'Lahore', 'charlotte@gmail.com', 20),
(19, 'Harper', 'Peshawar', 'harper@gmail.com', 27),
(20, 'Benjamin', 'Islamabad', 'ben@gmail.com', 38);

INSERT INTO orders VALUES
(1, 1, 'Laptop', 1200, '2025-01-10'),
(2, 2, 'Mobile', 800, '2025-01-12'),
(3, 3, 'Tablet', 600, '2025-01-13'),
(4, 4, 'Laptop', 1200, '2025-01-15'),
(5, 5, 'Camera', 900, '2025-01-16'),
(6, 6, 'Mobile', 800, '2025-01-17'),
(7, 7, 'Laptop', 1200, '2025-01-18'),
(8, 8, 'Tablet', 600, '2025-01-19'),
(9, 9, 'Camera', 900, '2025-01-20'),
(10, 10, 'Laptop', 1200, '2025-01-21'),
(11, 11, 'Mobile', 800, '2025-01-22'),
(12, 12, 'Camera', 900, '2025-01-23'),
(13, 13, 'Tablet', 600, '2025-01-24'),
(14, 14, 'Laptop', 1200, '2025-01-25'),
(15, 15, 'Camera', 900, '2025-01-26'),
(16, 16, 'Mobile', 800, '2025-01-27'),
(17, 17, 'Tablet', 600, '2025-01-28'),
(18, 18, 'Laptop', 1200, '2025-01-29'),
(19, 19, 'Camera', 900, '2025-01-30'),
(20, 20, 'Mobile', 800, '2025-01-31');

select * from employees;
select * from customers;
select * from orders;

--Phase 1 — Foundations
--Phase 2 — Equality Self Joins
--Phase 3 — Non-Equality Self Joins
--Phase 4 — Pair Logic
--Phase 5 — Hierarchical Thinking
--Phase 6 — Professional Self Join Patterns

Syntax
SELECT ...
FROM table t1
JOIN table t2
ON shared_column = shared_column
AND unique_id < unique_id;


select * 
from customers c1
join customers c2
	on c1.city = c2.city;

select * 
from customers c1
join customers c2
	on c1.age < c2.age;

/*
Deep Hierarchy Understanding
Look at employees.
employee	manager_id
Ahmed	1
This means:
Ahmed points to another employee row.
This is called:
self-referencing foreign key concept
Even though we didn't formally define FK yet.*/

select c1.customer_name,
	   c2.customer_name,
	   c1.city
from customers c1
join customers c2
	on c1.city = c2.city;

--Removing Self Matching
select c1.customer_name,
	   c2.customer_name,
	   c1.city
from customers c1
join customers c2
	on c1.city = c2.city
	and c1.customer_id <> c2.customer_id;

-- STILL A PROBLEM — Mirrored Duplicates
--Output still contains:
--c1		c2
--Ali		Sara
--Sara	Ali

--Professional Solution
--Use:
--<
select c1.customer_name,
	   c2.customer_name,
	   c1.city
from customers c1
join customers c2
	on c1.city = c2.city
	and c1.customer_id < c2.customer_id;

select 
	e1.employee_name,
	e2.employee_name,
	e1.manager_id
from employees e1
join employees e2
	on e1.manager_id = e2.manager_id
	and e1.employee_id < e2.employee_id;

--Customers Ordering Same Product
select * from orders;

select 
	o1.customer_id,
	o2.customer_id,
	o1.product_name
from orders o1
join orders o2 
	on o1.product_name = o2.product_name 
	and o1.customer_id < o2.customer_id;

--Orders Having Same Amount
SELECT
    o1.order_id,
    o2.order_id,
    o1.amount
FROM orders o1
JOIN orders o2
	ON o1.amount = o2.amount
	AND o1.order_id < o2.order_id;

--Employees in Same Department
select * from employees;

select 
	e1.employee_name,
	e2.employee_name,
	e1.department
from employees e1
join employees e2
	on e1.department = e2.department 
	and e1.employee_id < e2.employee_id;

--Older Customers
select * from customers;

select 
	c1.customer_name,
	c2.customer_name,
	c1.age,
	c2.age
from customers c1
join customers c2
	on c1.age > c2.age;

--Employees Earning Higher Salaries
select * from employees e ;

select
	e1.employee_name,
	e2.employee_name,
	e1.salary,
	e2.salary
from employees e1
join employees e2
	on e1.salary > e2.salary;

--Larger Orders Example

SELECT
    o1.order_id,
    o1.amount AS larger_amount,

    o2.order_id,
    o2.amount AS smaller_amount

FROM orders o1
JOIN orders o2
ON o1.amount > o2.amount;

--Customers Older Than 30 Compared With Younger Customers
select 
	c1.customer_name,
	c1.age,
	
	c2.customer_name,
	c2.age

from customers c1
join customers c2
	on c1.age > c2.age
where c1.age > 30;

--Employees Who Earn More Than Their Manager
select * from employees;

select 
	e1.employee_name,
	e1.salary,
	e2.employee_name,
	e2.salary
from employees e1
join employees e2
	on e1.employee_id = e2.manager_id
where e1.salary > e2.salary;

--Salary Rank Concept
select 
	e1.employee_name,
	count(*)  as rank
from employees e1
join employees e2
	on e2.salary > e1.salary
group by e1.employee_name
order by count(*) + 1 desc;

--Find employees in same department.
select * from employees;

select
	c1.employee_name,
	c2.employee_name,
	c1.department
from employees c1
join employees c2 
	on c1.department = c2.department
	and c1.employee_id < c2.employee_id;

--Find employee pairs with salary difference less than 10000.
select
	c1.employee_name,
	c2.employee_name,
	c1.salary,
	c2.salary
from employees c1
join employees c2 
	on c1.employee_id < c2.employee_id
where ABS(c1.salary - c2.salary) < 10000; 
/*ABS() means:
Absolute value
It removes the sign (+ or -) and gives only the distance from zero.
Examples:
SELECT ABS(10);
Output:
10

*Professional rule for ABS()

Use ABS() when the question asks about:
difference
distance
gap
closeness
Examples:
Salary difference less than 10000

*Ask:

Do I care about direction?
If YES:
Do NOT use ABS().
If NO:
Use ABS()

when to use
c1.id < c2.id

Situation 1 — Pair generation
Question:
Find employees in same department
Question:
Find customers in same city
Question:
Find salary differences
We care about:
Ahmed ↔ Sara
only once.
So use:
c1.id < c2.id

Situation 2 — Comparison relationships

Question:

Find employees earning more than others

e1.salary > e2.salary

We do NOT use:

e1.id < e2.id

because:

The comparison itself already removes duplicates.

Example:

If:

90000 > 85000

TRUE

then:

85000 > 90000

FALSE

So mirrored rows cannot happen.



Situation 3 — Relationship-based joins

Question:

Find employees earning more than their manager

e.manager_id = m.employee_id

No need:

e.id < m.id

because:

Manager relationship already uniquely defines pairs.


The Professional Decision Framework

Whenever doing a self join ask:

Question 1

Am I generating general pairs?

Examples:

same city
same manager
same department

YES →

id < id
Question 2

Am I doing comparisons?

Examples:

older than
greater than
larger than

YES →

Usually no:

id < id
Question 3

Am I connecting predefined relationships?

Examples:

employee → manager
parent → child

YES →

No:

id < id
*/

/*
MOST IMPORTANT UNDERSTANDING

manager_id

does NOT store:

manager name

It stores:

employee_id of another row

inside the SAME table.

This is called:

self-referencing relationship*/

/*
4. SQL Mental Model

This query:

FROM employees e
JOIN employees m
ON e.manager_id = m.employee_id

does NOT mean:

employee joins employee

Think professionally:

Employee copy → Manager copy*/
select * from employees;
Select
	e.employee_name as employee,
	m.employee_name as manager
from employees e
join employees m
on e.manager_id = m.employee_id;
/*
employee's manager id equals manager's employee id

we connect:
e.manager_id = m.employee_id

Meaning:

employee's manager id
=
manager's employee id*/

--Include Top-Level Employees
SELECT
	e.employee_name AS employee,
	m.employee_name AS manager
FROM employees e
left join employees m
	on e.manager_id = m.employee_id;

--Find Managers with Their Employees
SELECT
	m.employee_name AS manager,
	e.employee_name AS employee
FROM employees e
JOIN employees m
ON e.manager_id=m.employee_id;

--Find Employees Under Same Manager
SELECT
	e1.employee_name,
	e2.employee_name,
	e1.manager_id
FROM employees e1
JOIN employees e2
	ON e1.manager_id=e2.manager_id
	AND e1.employee_id<e2.employee_id;

--Find Number of Employees Under Each Manager
select
	m.employee_name,
	count(e.employee_id) as total_employees
from employees e
join employees m
	on e.manager_id = m.employee_id 
group by m.employee_name;

--Find Employees Earning More Than Their Manager
select
	e.employee_name as employee,
	m.employee_name as manager,
	e.salary as employee_salary,
	m.salary as manager_salary
from employees e
join employees m
	on e.manager_id = m.employee_id
where e.salary > m.salary;

--Find Top-Level Employees
SELECT *
FROM employees
WHERE manager_id IS NULL;

--Find Employees Without Subordinates
SELECT e.employee_name
FROM employees e
LEFT JOIN employees sub
ON e.employee_id=sub.manager_id
WHERE sub.employee_id IS NULL;

/*
Simple self joins only handle:

one level

Example:

Employee → Manager

For:

Employee → Manager → Director → CEO

we need:

Recursive CTE

which comes later.
 */


--Pattern 1 — Analytical Comparisons
/*This is extremely common.

Question:

Compare one row against another row.

Examples:

salary comparisons
age comparisons
order comparisons
score comparisons*/

--Employees earning more than others
SELECT
    e1.employee_name,
    e2.employee_name,
    e1.salary,
    e2.salary
FROM employees e1
JOIN employees e2
ON e1.salary > e2.salary;

/*
Pattern 2 — Recommendation Logic

This powers:

Netflix recommendations
Amazon suggestions
YouTube recommendations
e-commerce systems

Question:

People who liked X also liked Y

We are not using dvdrental yet because I want the logic first.

Suppose:

customer	product
Ali			Laptop
Ali			Mouse
Ahmed		Laptop
Ahmed		Keyboard
Sara		Mouse

We want:

customers with similar interests


SELECT
    c1.customer_id,
    c2.customer_id,
    c1.product
FROM purchases c1
JOIN purchases c2
ON c1.product=c2.product
AND c1.customer_id<c2.customer_id;
*/

/*
Pattern 3 — Graph Thinking

This is advanced.

Most students struggle because they think tables are:

rows

Professionals think:

connections

Suppose:

person		friend
Ali			Ahmed
Ahmed		Sara
Sara		Sophia

Visual:

Ali — Ahmed — Sara — Sophia

This is called:

graph thinking

Self joins become:

connection finding

Example:

Find people sharing same friend.


select 
	f1.person,
	f2.person,
	f1.friend
from friendships f1
join friendships f2 
	on f1.friend = f2.friend
	and f1.person < f2.person

 */


/*
Pattern 4 — Sequence Relationships

This is extremely important.

Question:

What happened before/after something?

Examples:

previous order
next purchase
previous salary
next event

Suppose:

order_id	customer_id	amount
1	101	50
2	101	80
3	101	100

We want:

current order vs previous order

Query:
 */
select * from orders;	

select
	o1.order_id,
	o2.order_id,
	o1.amount,
	o2.amount
from orders o1
join orders o2
	on o1.customer_id = o2.customer_id
	and o1.order_id = o2.order_id + 1;


/*
Pattern 5 — Advanced Reporting Logic

Professionals often create reports by comparing rows.

Question:

Employees with salary close to each other
 */
select
	e1.employee_name,
	e2.employee_name,
	e1.salary,
	e2.salary
from employees e1
join employees e2
	on e1.employee_id < e2.employee_id
where abs(e1.salary - e2.salary)<10000;  

--Customers with age difference >10
select 
	c1.customer_name,
	c2.customer_name,
	c1.age,
	c2.age
from customers c1
join customers c2
	on c1.customer_id < c2.customer_id 
where abs(c1.age - c2.age) > 10;

/*
 Pattern 6 — Ranking Logic (Before Window Functions)

Before window functions existed:

Professionals ranked using self joins

Count:

How many employees earn more than me

If:

3 employees earn more:

rank=4
*/
select 	
	e1.employee_name,
	count(*) + 1 as rank
from employees e1
join employees e2
	on e2.salary > e1.salary 
group by e1.employee_name;

/*
Pattern 7 — Co-occurrence Logic

Extremely common in recommendations.

Question:

Which products appear together?

Suppose:

order	product
1		Laptop
1		Mouse
1		Keyboard

*/
select * from orders;

select 
	p1.product_name,
	p2.product_name
from orders p1
join orders p2
	on p1.order_id = p2.order_id 
	and p1.product_name  < p2.product_name;


select 
	p1.order_id ,
	p2.order_id ,
	p1.product_name,
	p2.product_name
from orders p1
join orders p2
	on p1.product_name = p2.product_name
	and p1.order_id < p2.order_id ;