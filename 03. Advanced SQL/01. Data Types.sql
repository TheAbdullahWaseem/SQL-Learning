/*
SQL Data Types & Type Conversion — Overview

In this section, we will learn how PostgreSQL stores, interprets, and converts different types of data.

We will cover:

1. Data Types — What they are and why they matter
2. Numeric Types — INTEGER, BIGINT, NUMERIC, REAL, DOUBLE PRECISION
3. Character Types — CHAR, VARCHAR, TEXT
4. Date & Time Types — DATE, TIME, TIMESTAMP, TIMESTAMPTZ, INTERVAL
5. Boolean Type — TRUE, FALSE, and NULL
6. NULL — How missing values behave
7. Type Conversion — Implicit conversion, CAST(), and ::
8. Practical Casting — Text, numbers, dates, timestamps, and booleans
9. Casting Errors & Dirty Data — Handling real-world data safely
10. Type Inspection — pg_typeof() and inspecting table columns
11. Data Types in Data Analysis & ML — SQL types, pandas dtypes, and feature engineering
12. Additional Types — UUID, JSONB, and ARRAY

Throughout this section, we will use PostgreSQL, DBeaver, and the dvdrental database to
develop professional SQL skills for Data Analysis, Data Science, and Machine Learning.
*/

-----------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------

=======================
SECTION A — FOUNDATIONS
=======================

============================================
1. What Is a Data Type — Concept and Purpose
============================================

A data type tells PostgreSQL what kind of data a value or column
is supposed to contain.

For example:

customer_id  → INTEGER
first_name   → TEXT
amount       → NUMERIC
rental_date  → TIMESTAMP
active       → BOOLEAN

-- 25 and '25' may look similar to us, but PostgreSQL sees them differently:

SELECT 25, '25';

Here:

25 is a numeric value.
'25' is a text/string value.

--We can verify this with pg_typeof():
--------------------
SELECT
    pg_typeof(25),
    pg_typeof('25');
--------------------
You should get types equivalent to:

integer
unknown

The second result is unknown because a bare string literal has not yet been given
enough context for PostgreSQL to determine its final type. 
Once PostgreSQL uses it in a typed context, it can resolve it appropriately.

for Example:
---------------------------
select 
	pg_typeof(25::integer);
---------------------------

Why does the type matter?
Because the type determines what PostgreSQL can do with the data.

For example:

SELECT 10 + 20;

works because both values are numeric.

But:
--------------------
SELECT '10' + '20';
--------------------

does not work as ordinary numeric addition because those values are text.

You would explicitly convert them:
---------------------------------------
SELECT '10'::integer + '20'::integer;
---------------------------------------

The key idea

do not think:
"A data type is just a label."

Think:
A data type tells PostgreSQL how a value should be interpreted, 
stored, and operated on.

====================================================
2. How PostgreSQL Enforces Types at the Column Level
====================================================

This is where data types become particularly important.
When you create a table, you specify a type for each column.

For example:

----------------------------
create table employee_demo (
	employee_id integer,
	employee_name text,
	salary numeric(10, 2),
	is_active Boolean
);
----------------------------

PostgreSQL will enforce those definitions when data is inserted.
For example, this is valid:
---------------------------------------
insert into employee_demo
values (1, 'Abdullah', 75000.50, True);
---------------------------------------
-------------------------------------------
INSERT INTO employee_demo
VALUES ('ABC', 'Abdullah', 75000.50, TRUE);
-------------------------------------------

it will arise error as employee_id → INTEGER

But PostgreSQL can sometimes convert values automatically

For example:
-----------------------------------------
INSERT INTO employee_demo
VALUES ('1', 'Abdullah', 75000.50, TRUE);
-----------------------------------------
PostgreSQL may be able to interpret '1' as an integer because the 
value is compatible with the columns type.

This introduces an important concept we will study in depth later:

Implicit type conversion

You should not assume that every value that looks convertible will
be automatically converted. PostgreSQLs type system has specific rules
for when implicit conversion is allowed.
----------------------------------
select * from employee_demo

select
	column_name,
	data_type
from information_schema.columns
where table_name = 'employee_demo';	
-----------------------------------
This shows the data types PostgreSQL has assigned to the columns.

you want:

	age + 10

but you are starting with text rather than a numeric value.

You may need to clean and convert it:

SELECT age::INTEGER + 10
FROM some_table;

But here is an even more important example

Suppose you have:

customer_id
-----------
00125
00126
00127

You might think:

"These are numbers, so I should convert them to INTEGER."

Wrong.
They may be identifiers, not quantities.
If you convert:

00125 → 125

you have lost information.

So:
A value looking numeric does not automatically mean it should have a numeric data type.

This is an extremely important Data Analyst / Data Scientist habit.
-------------------------------
select
	column_name,
	data_type
from information_schema.columns
where table_name = 'customer';
--------------------------------

-- =====================================================================
-- SECTION B — NUMERIC TYPES
-- =====================================================================
--
-- Topics:
--
-- 4. SMALLINT, INTEGER, BIGINT
-- 5. SERIAL, BIGSERIAL, and IDENTITY
-- 6. NUMERIC / DECIMAL — Exact Numbers
-- 7. REAL / DOUBLE PRECISION — Approximate Numbers
-- 8. Choosing the Right Numeric Type for Analytics and ML
--
-- =====================================================================

4. INTEGER FAMILY — SMALLINT, INTEGER, BIGINT

PostgreSQL provides three main integer types:

| Type       | Storage |                     Approximate range | Typical use              |
| ---------- | ------: | ------------------------------------: | ------------------------ |
| `SMALLINT` | 2 bytes |                     -32,768 to 32,767 | Small counts             |
| `INTEGER`  | 4 bytes |           -2.1 billion to 2.1 billion | General-purpose integers |
| `BIGINT`   | 8 bytes | -9.22 quintillion to 9.22 quintillion | Very large values        |

For normal Data Analysis work:
Use INTEGER by default unless you have a reason to use SMALLINT or BIGINT.
--------
SMALLINT
--------
Use when you know the values will remain relatively small.
-----------------------
SELECT 25000::SMALLINT;
-----------------------

this will fail, i have not create table:

INSERT INTO small_example
VALUES (40000);

because 40000 is outside the SMALLINT range.
-------
INTEGER
-------
This is the normal integer type you will use most often.

SELECT 100::INTEGER;
------
BIGINT
------
Use BIGINT when the possible value can exceed the INTEGER range.
--------------------------
SELECT 5000000000::BIGINT;
--------------------------
Try:
----------------------------------
SELECT
    pg_typeof(5000000000::BIGINT);
----------------------------------
Important distinction
do not choose BIGINT simply because:
"Bigger must be better."
It uses more storage than INTEGER.
------------------
Integer Arithmetic
------------------
PostgreSQL performs integer arithmetic according to the types involved.

For example:

SELECT
    10 + 5 AS addition,
    10 - 5 AS subtraction,
    10 * 5 AS multiplication;

But pay attention to integer division:

SELECT 10 / 3;

Result:

3

because both operands are integers.

If you want a decimal result:

select 10::numeric / 3;
-----------------------------
5. AUTO-INCREMENTING INTEGERS
-----------------------------
When a table needs an automatically generated ID, PostgreSQL provides several approaches.

The older/common approach:

SERIAL
BIGSERIAL

The modern PostgreSQL approach:

identity
======
SERIAL
======
SERIAL automatically generates integer values.

CREATE TABLE serial_demo (
    id SERIAL,
    name TEXT
);

Insert rows without specifying id:

INSERT INTO serial_demo (name)
VALUES
    ('Ali'),
    ('Ahmed'),
    ('Abdullah');
=========
BIGSERIAL
=========
Use it when the generated identifier may eventually require the much larger BIGINT range.

=====================================
IDENTITY — Modern PostgreSQL Approach
=====================================
For new tables, you should know the modern approach:

CREATE TABLE identity_demo (
    id INTEGER GENERATED ALWAYS AS IDENTITY,
    name TEXT
);
==============================
GENERATED ALWAYS vs BY DEFAULT
==============================
Two forms are important.
----------------
GENERATED always
----------------
CREATE TABLE identity_always (
    id INTEGER GENERATED ALWAYS AS IDENTITY,
    name TEXT
);

PostgreSQL controls the generated value.

Normally you do not manually provide the ID.
----------
BY default
----------
CREATE TABLE identity_default (
    id INTEGER GENERATED BY DEFAULT AS IDENTITY,
    name TEXT
);

PostgreSQL generates the ID when you do not provide one, but explicitly 
supplied values can be allowed.
------------------------------------
6. NUMERIC / DECIMAL — EXACT NUMBERS
------------------------------------
This is one of the most important numeric types for Data Analysis.

NUMERIC and DECIMAL are equivalent in PostgreSQL.
----------------------
SELECT 99.99::NUMERIC;
----------------------
You can also specify:

NUMERIC(precision, scale)
Precision

The total number of digits.

Scale

The number of digits after the decimal point.

For example:
---------------------------
CREATE TABLE numeric_demo (
    product_id INTEGER,
    price NUMERIC(10, 2)
);
---------------------------
----------------------------
7. REAL AND DOUBLE PRECISION
----------------------------
These are floating-point types.

They are designed for approximate numerical calculations.

REAL
DOUBLE PRECISION

DOUBLE PRECISION provides substantially more precision than REAL.

The important difference
NUMERIC
Exact
REAL / DOUBLE PRECISION
Approximate

This matters because computers represent many decimal fractions 
using binary floating-point representations.

SELECT
    0.1::DOUBLE PRECISION
    +
    0.2::DOUBLE PRECISION;

You may see:
0.30000000000000004

rather than exactly:
0.3

That tiny difference is normal floating-point behavior.

for exact values use numeric

REAL vs DOUBLE PRECISION

Both are approximate.
The major difference is precision.

SELECT
    pg_typeof(1.5::REAL),
    pg_typeof(1.5::DOUBLE PRECISION);

REAL
  ↓
less precision
less storage

DOUBLE PRECISION
  ↓
more precision
more storage

For most analytical floating-point work, if you need floating-point, 
DOUBLE PRECISION is generally the more useful choice.
-------------------------------------------------
8. NUMERIC vs FLOATING-POINT FOR ANALYTICS AND ML
-------------------------------------------------
This is where you need professional judgment.
There is no rule that says NUMERIC is always better.
The correct choice depends on the data and the calculation.

Use NUMERIC when exactness matters

Examples:
Revenue
Price
Salary
Tax
Financial transactions
Accounting values
Exact decimal measurements

Use floating-point when approximation is acceptable

Examples can include:
Scientific measurements
Statistical calculations
Continuous numerical measurements
Large-scale numerical computation
ML-related numerical features

-- =====================================================================
-- NUMERIC vs FLOATING-POINT
-- =====================================================================

SELECT
    0.1::NUMERIC + 0.2::NUMERIC
        AS exact_result,

    0.1::DOUBLE PRECISION + 0.2::DOUBLE PRECISION
        AS approximate_result;
    
The important lesson is not simply:

"NUMERIC good, DOUBLE bad."

It is:

NUMERIC gives exact decimal arithmetic; floating-point gives approximate 
arithmetic optimized for numerical computation.

-- =====================================================================
-- INSPECT NUMERIC COLUMNS IN DVDRental
-- =====================================================================

SELECT
    table_name,
    column_name,
    data_type,
    numeric_precision,
    numeric_scale
FROM information_schema.columns
WHERE table_schema = 'public'
  AND data_type IN (
      'smallint',
      'integer',
      'bigint',
      'numeric',
      'real',
      'double precision'
  )
ORDER BY
    table_name,
    ordinal_position;

This is an important professional skill:

Instead of guessing what type a database column has, inspect the database metadata.

Let us Inspect payment
-- =====================================================================
-- PAYMENT TABLE — NUMERIC DATA
-- =====================================================================


SELECT
    payment_id,
    customer_id,
    amount
FROM payment
LIMIT 10;

Now:

SELECT
    pg_typeof(payment_id) AS payment_id_type,
    pg_typeof(customer_id) AS customer_id_type,
    pg_typeof(amount) AS amount_type
FROM payment
LIMIT 1;

You should see the actual PostgreSQL types.
-------------------------------
One Important Warning About IDs
-------------------------------
Do not automatically choose numeric types because an ID contains digits.

For example:

customer_id = 1001

can appropriately be:

INTEGER

But something like:
=====================
postal_code = '02115'
=====================
should generally be treated as an identifier/code rather than a mathematical number.

Why?

Because:
=======
'02115'
=======
contains meaningful formatting that would be lost if converted to:

2115

We will revisit this much more deeply in the ML/DS section.

-- =====================================================================
-- HOW TO CHOOSE A NUMERIC TYPE
-- =====================================================================
/*
SMALLINT
    ↓
Small integer range
    ↓
Use only when the range is known to be small

INTEGER
    ↓
Normal whole numbers
    ↓
Default choice for many integer columns

BIGINT
    ↓
Very large whole numbers
    ↓
Large IDs / very large counts

NUMERIC / DECIMAL
    ↓
Exact decimal arithmetic
    ↓
Money / financial values / exact decimal quantities

REAL
    ↓
Approximate floating-point
    ↓
Use when lower precision is acceptable

DOUBLE PRECISION
    ↓
Approximate floating-point with higher precision
    ↓
Scientific / analytical numerical calculations*/

-- =====================================================================
-- SECTION B — CORE RULES
-- =====================================================================

1. INTEGER is the normal general-purpose integer type.

2. SMALLINT is for values with a known small range.

3. BIGINT is for values that may exceed INTEGERs range.

4. SERIAL and BIGSERIAL are older PostgreSQL auto-generated
   integer approaches.

5. IDENTITY is the modern approach for generated identity columns.

6. NUMERIC / DECIMAL provides exact decimal arithmetic.

7. NUMERIC(precision, scale):
       precision = total number of digits
       scale     = digits after the decimal point

8. REAL and DOUBLE PRECISION use approximate floating-point arithmetic.

9. Do not use floating-point when exact decimal arithmetic is required,
   such as financial calculations.

10. DOUBLE PRECISION is generally preferable to REAL when floating-point
    precision matters.

11. Do not choose a data type based only on how a value looks.
    Choose it based on what the data represents.

12. The correct type depends on the purpose of the data and the
    operations you will perform on it.
    
    
====================================
SECTION C — CHARACTER / STRING TYPES
====================================
Topics:
9. CHAR(n) vs VARCHAR(n) vs TEXT
10. CHAR(n) trailing-space behavior — a common gotcha
11. Why TEXT is generally preferred in PostgreSQL analytics

================================
9. CHAR(n) vs VARCHAR(n) vs TEXT
================================

PostgreSQL has three main character/string types:

CHAR(n)
VARCHAR(n)
TEXT

The key difference is how they handle length.

| Type         |                        Length limit | Padding | Typical use                           |
| ------------ | ----------------------------------: | ------- | ------------------------------------- |
| `CHAR(n)`    | Exactly `n` characters conceptually | Yes     | Rare/specific fixed-width data        |
| `VARCHAR(n)` |              Maximum `n` characters | No      | Data with a meaningful maximum length |
| `TEXT`       |                   No declared limit | No      | General-purpose strings               |

The important point is:

In PostgreSQL analytics, TEXT is usually the simplest and most practical choice.

Let us understand why.

-------
CHAR(n)
-------

CHAR(n) is a fixed-length character type.

Example:
------------------------
CREATE TABLE char_test (
    code CHAR(5)
);
------------------------
Now:
---------------------
insert into char_test
values ('ABC');
---------------------
select * from char_test;

The value is treated as a 5-character fixed-width value.

Conceptually:

ABC__

where _ represents spaces.

You can inspect it with:
-------------------------
SELECT code, length(code)
FROM char_test;
-------------------------

You may be surprised to see:

ABC | 3

That is because PostgreSQLs CHAR(n) has special trailing-space behavior. We will examine that in Topic 10.

Important
do not think:

	CHAR(5) means PostgreSQL will always return a string visibly containing 5 characters.

Its behavior around trailing spaces is more subtle.

----------
VARCHAR(n)
----------

VARCHAR(n) means:
Store a string with a maximum length of n characters.

Example:
----------------------------
CREATE TABLE customer_test (
    first_name VARCHAR(50)
);
----------------------------
-------------------------
INSERT INTO customer_test
VALUES ('Abdullah');
-------------------------
But a value exceeding 50 characters will be rejected.
----------------------------------------------------------------
INSERT INTO customer_test
VALUES ('A very long string that exceeds the defined limit...');
----------------------------------------------------------------

VARCHAR(50) means:

0 to 50 characters

It does not mean every value must contain exactly 50 characters.
----
TEXT
----

TEXT is PostgreSQLs general-purpose string type.

Example:
----------------------------
CREATE TABLE customer_test (
    first_name TEXT
);
----------------------------
You can store strings without declaring a maximum length:
-----------------------------------------
INSERT INTO customer_test
VALUES ('Abdullah');
or
INSERT INTO customer_test
VALUES ('A much longer piece of text...');
------------------------------------------
=============================
THE MOST IMPORTANT DIFFERENCE
=============================

CREATE TABLE strings (
    a CHAR(10),
    b VARCHAR(10),
    c TEXT
);

INSERT INTO strings
VALUES ('SQL', 'SQL', 'SQL');

The conceptual difference is:

CHAR(10)
--------
Fixed-width character type.


VARCHAR(10)
-----------
Variable-length, maximum 10 characters.


TEXT
----
Variable-length, no declared character limit.

For normal analytical data, the practical choice is usually:

TEXT

unless you have a specific reason to impose a maximum length.

select 
	table_name,
	column_name,
	data_type,
	character_maximum_length
from information_schema.columns 
where table_schema = 'public'
	and data_type in ('character', 'charcter varying', 'text')
order by table_name, ordinal_position;
===========================
Why not use CHAR for names?
===========================

Imagine:
first_name CHAR(50)

and:
first_name TEXT

A name such as:
John

does not naturally have a fixed width of 50 characters.
So CHAR(50) communicates the wrong idea.

A name is naturally:
	variable length

first_name TEXT
	is generally more appropriate
-------------------	
Why use VARCHAR(n)?
-------------------

Suppose your business rule says:

A username cannot exceed 30 characters.
You could use:

username VARCHAR(30)

This makes the maximum length part of the database schema.
-----------------------------------
10. CHAR(n) TRAILING-SPACE BEHAVIOR
-----------------------------------

CHAR(n) is unusual because PostgreSQL pads values with spaces to the declared 
length when necessary, but trailing spaces are generally ignored when values are compared.

Let us demonstrate.

DROP TABLE IF EXISTS char_demo;

CREATE TABLE char_demo (
    code CHAR(5)
);


INSERT INTO char_demo
VALUES ('ABC');

SELECT
    code,
    length(code),
    octet_length(code)
FROM char_demo;

The important distinction is:
length(code)

counts characters while ignoring trailing spaces for CHAR.

Whereas:
octet_length(code)

can reveal the underlying padded storage representation.

For example, conceptually:

ABC__
The two spaces are there as padding.
-----------------------
CHAR(n) and comparisons
-----------------------

This is an important gotcha.


SELECT *
FROM char_demo
WHERE code = 'ABC';

works.

And:

SELECT *
FROM char_demo
WHERE code = 'ABC  ';

can also compare equal because trailing spaces are not treated as significant in the usual 
CHAR comparison behavior.
This is one reason CHAR(n) can behave differently from what beginners expect.

---------------------------------------
CHAR(n) vs VARCHAR(n) — trailing spaces
---------------------------------------

CREATE TABLE string_demo (
    fixed_code CHAR(5),
    variable_code VARCHAR(5)
);

INSERT INTO string_demo
VALUES ('ABC', 'ABC');

The fixed-width column conceptually has:

ABC__

while the variable-length column contains:

ABC

select length(fixed_code), OCTET_LENGTH(fixed_code),
	   length(variable_code), OCTET_LENGTH(fixed_code)
from string_demo;

So:

CHAR(5)
    → fixed-width behavior
VARCHAR(5)
    → variable-width behavior
    
-----------------------------------------------------------
11. WHY TEXT IS GENERALLY PREFERRED IN POSTGRESQL ANALYTICS
-----------------------------------------------------------

This is the practical conclusion of the whole section.

For many PostgreSQL analytical tables, you will commonly see:

TEXT

used for ordinary strings.

Why?
-----------------------------------
1. No unnecessary length constraint
-----------------------------------
Instead of:

first_name VARCHAR(50)

you can use:

first_name TEXT

if there is no meaningful business requirement that the 
database enforce a 50-character maximum.
-------------------------
2. No fixed-width padding
-------------------------
Unlike:

CHAR(50)

TEXT does not introduce fixed-width character behavior.
-----------------
3. Simpler schema
-----------------
Compare:

CREATE TABLE customers (
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    email VARCHAR(100),
    address VARCHAR(200)
);

with:

CREATE TABLE customers (
    first_name TEXT,
    last_name TEXT,
    email TEXT,
    address TEXT
);

If those numeric limits are not genuine business rules, 
the second schema is simpler.
------------------------------------------------------------------------
4. PostgreSQL does not generally give VARCHAR(n) a performance advantage
------------------------------------------------------------------------
A common misconception is:

VARCHAR(50) must be faster or more memory-efficient than TEXT.

For ordinary PostgreSQL strings, do not choose VARCHAR(n) just because you think it will improve performance.

Choose the type based on the semantics and constraints of the data.

========================
DATA CLEANING connection
========================

Suppose your database contains:

'John'
' john'
'JOHN '
'John   '

Changing the column from TEXT to VARCHAR(50) does not clean these values.

The type controls the nature/constraints of the data.

Cleaning is a separate operation.

For example:

SELECT
    trim(first_name) AS cleaned_name
FROM customer;

Or:

SELECT
    lower(trim(first_name)) AS cleaned_name
FROM customer;

So remember:

Data type ≠ data cleaning

A TEXT column can contain messy text.

A VARCHAR(50) column can also contain messy text.
===========================
IMPORTANT TRAPS TO REMEMBER
===========================

-- 1. CHAR(n) is not simply "VARCHAR with a limit".

CHAR(n)
→ fixed-width semantics + special trailing-space behavior


VARCHAR(n)
→ variable-width + maximum length


TEXT
→ variable-width + no declared maximum length

-- 2. Don't use CHAR for ordinary strings just because the length is known.

Knowing that a name is usually under 50 characters does not mean it is fixed-width.

-- 3. Don't use VARCHAR(n) automatically.

Use it when the maximum length represents a meaningful rule.

-- 4. TEXT does not mean "unstructured" or "badly typed".

It is a legitimate PostgreSQL string data type.

-- 5. TEXT does not mean unlimited in an absolute physical sense.

PostgreSQL still has limits on individual field/value size.

-- 6. String type does not determine whether the contents are clean.

For example:

' John '
'JOHN'
'john'

can all exist in a TEXT column.
==========================
SECTION C — MASTER SUMMARY
==========================

The professional-level understanding you should retain is:

CHAR(n)
→ Fixed-width character type.
→ Pads shorter values with spaces.
→ Has special trailing-space behavior.
→ Rarely needed in normal PostgreSQL analytics.


VARCHAR(n)
→ Variable-length string.
→ Enforces a maximum of n characters.
→ Useful when the maximum length is a genuine business rule.


TEXT
→ Variable-length string.
→ No declared character limit.
→ Generally the simplest/default choice for ordinary strings
  in PostgreSQL analytics.
  
  -- =====================================================================
-- SECTION D — DATE/TIME TYPES — OVERVIEW ONLY
-- =====================================================================
--
-- Topics:
-- 12. DATE, TIME, TIMESTAMP, TIMESTAMPTZ
-- 13. INTERVAL
--
-- =====================================================================
  
DATE
→ What calendar date?

TIME
→ What time of day?

TIMESTAMP
→ What date + time?

TIMESTAMPTZ
→ What date + time, interpreted with a time zone?
----
DATE
----
Stores a calendar date.

DATE
Example:

SELECT DATE '2026-08-18';

Conceptually:
2026-08-18

It does not store:

16:30:00

Use it when the time of day is not relevant.

Examples:
Use it when the time of day is not relevant.
----
TIME
----
Stores a time of day, without a calendar date.

TIME
Example:

SELECT TIME '14:30:00';

Conceptually:

14:30:00

It does not tell you which day.
---------
TIMESTAMP
---------
Stores:

date + time
Example:

SELECT TIMESTAMP '2026-08-18 14:30:00';

Conceptually:
2026-08-18 14:30:00

It does not contain time-zone information.
This distinction is important.

For example:
2026-08-18 14:30:00

means a particular date and clock time, but PostgreSQL is not
storing a time-zone offset with it.
-----------
TIMESTAMPTZ
-----------
Despite its name, PostgreSQLs TIMESTAMPTZ does not simply store a timestamp plus a time-zone label.

It represents an instant in time, with PostgreSQL using time-zone information when interpreting input/output.

Example:

SELECT TIMESTAMPTZ '2026-08-18 14:30:00+05';

The +05 tells PostgreSQL the inputs time-zone offset.

Two representations of the same instant can therefore be displayed differently depending on the session time zone.

For example, conceptually:

Pakistan:
2026-08-18 14:30:00+05

UTC:
2026-08-18 09:30:00+00

These represent the same instant
------------------------------------
TIMESTAMP vs TIMESTAMPTZ — IMPORTANT
------------------------------------

Suppose an international company records:

2026-08-18 14:00

If this represents an event that happened at a real-world moment, such as:

payment completed
customer logged in
server event occurred
order created

then time-zone handling can matter.

For example:

New York:  2026-08-18 05:00
Pakistan:  2026-08-18 14:00
UTC:       2026-08-18 09:00

These can all represent the same instant.

This is why TIMESTAMPTZ is often important for real-world event data.
============
13. interval
============

INTERVAL represents a duration or amount of elapsed time.

Examples:

INTERVAL '3 days'
INTERVAL '2 hours'
INTERVAL '15 minutes'
INTERVAL '1 month'
INTERVAL '2 years'

Example:

SELECT INTERVAL '3 days';

select interval '6 Days'

SELECT TIMESTAMP '2026-08-18 10:00:00'
       + INTERVAL '3 days';

SELECT TIMESTAMP '2026-08-18 10:00:00'
       + INTERVAL '2 hours';
=====================================
SECTION D — WHAT YOU NEED TO REMEMBER
=====================================
DATE
→ Calendar date


TIME
→ Time of day


TIMESTAMP
→ Date + time without time-zone semantics


TIMESTAMPTZ
→ An instant in time with time-zone-aware interpretation/display


INTERVAL
→ Duration / amount of elapsed time

For Data Analysis, the most important distinction is:

TIMESTAMP ≠ TIMESTAMPTZ

and:

TIMESTAMP/TIMESTAMPTZ
→ when something happened


INTERVAL
→ how long / how far apart


-- =====================================================================
-- SECTION E — BOOLEAN
-- =====================================================================
--
-- Topic:
-- 14. BOOLEAN — TRUE / FALSE / NULL and Three-Valued Logic
--
-- =====================================================================


14. BOOLEAN — TRUE / FALSE / null

BOOLEAN stores logical values.

PostgreSQL supports:

TRUE
FALSE
null

CREATE TABLE users (
    user_id INTEGER,
    is_active BOOLEAN
);

INSERT INTO users
VALUES
    (1, TRUE),
    (2, FALSE),
    (3, NULL);
==================
THREE-VALUED LOGIC
==================

Normal beginners often think logical conditions only have:

TRUE
FALSE

SQL has:

TRUE
FALSE
UNKNOWN

where NULL usually causes the result to become UNKNOWN.
-----------------
Boolean filtering
-----------------
You can write:

SELECT *
FROM users
WHERE is_active = TRUE;

or simply:

SELECT *
FROM users
WHERE is_active;
=========================
BOOLEAN — IMPORTANT RULES
=========================
TRUE  ≠ FALSE
TRUE  ≠ NULL
FALSE ≠ NULL

And:

NULL means unknown/missing,
not automatically FALSE.

Use:

IS NULL
IS NOT NULL

instead of:

= NULL
<> null

select cast(25 as integer);


-- =====================================================================
-- SECTION F — NULL AND TYPE BEHAVIOR
-- =====================================================================
--
-- Topics:
-- 15. NULL Is Not a Value — How It Behaves Across Every Data Type
-- 16. How NULL Behaves During Type Conversion
--
-- =====================================================================


NULL means:

The value is unknown, missing, or not applicable.
select 10 + null;
SELECT 10 * NULL;
SELECT 10 - NULL;
SELECT 10 / NULL;

all produce NULL.

The general idea:

known value + unknown value
→ unknown result
-----------------
NULL WITH STRINGS
-----------------
SELECT 'Hello' || NULL;

Result:
NULL

Because PostgreSQL cannot determine the complete concatenated value when one part is unknown.
This is important when cleaning/combining real-world data.

For example:

SELECT first_name || ' ' || last_name
FROM customer;

If either name is NULL, the whole expression can become NULL.
------------------------------
NULL WITH DIFFERENT DATA TYPES
------------------------------

The important thing is that NULL itself does not represent a particular data value.

A column can contain:

INTEGER → NULL
NUMERIC → NULL
TEXT → NULL
DATE → NULL
TIMESTAMP → NULL
BOOLEAN → null
----------------------------
NULL AND AGGREGATE FUNCTIONS
----------------------------

This is particularly important for Data Analysis.
Consider:

amount
------
100
200
NULL
300

Then:

SELECT SUM(amount);

returns:

600

The NULL is not treated as zero; aggregate functions such as SUM() generally ignore NULL values.

Similarly:
SELECT AVG(amount);

calculates the average of the known values:
(100 + 200 + 300) / 3

not:

(100 + 200 + 0 + 300) / 4
This distinction becomes very important when preparing data for pandas/ML.
-----------------------------
COUNT() — IMPORTANT EXCEPTION
-----------------------------

Compare:

COUNT(*)

with:

COUNT(column_name)
COUNT(*) counts rows.
COUNT(column_name) counts non-NULL values in that column.

Example:
id | amount
---+-------
1  | 100
2  | 200
3  | null

SELECT
    COUNT(*) AS total_rows,
    COUNT(amount) AS known_amounts
FROM payment;

Conceptually:

total_rows    → 3
known_amounts → 2

This is extremely useful in data-quality analysis.
===============================
16. NULL DURING TYPE CONVERSION
===============================

Now connect NULL with casting.

Suppose:
SELECT CAST(NULL AS INTEGER);

Result:
NULL

Likewise:

SELECT CAST(NULL AS TEXT);

returns:
null

And:

SELECT CAST(NULL AS DATE);

returns:
NULL

The important idea is:

Casting NULL does not turn it into a normal value. 
It remains NULL, but PostgreSQL can give it a specific type.
---------------------------
Why would NULL need a type?
---------------------------

Consider:

SELECT NULL;

PostgreSQL has very little information about what type you intend.

But:

SELECT CAST(NULL AS INTEGER);

explicitly says:

This NULL should be treated as an INTEGER-typed NULL.

This matters when PostgreSQL needs to resolve the 
type of an expression, column, union, function argument, etc.
--------------------------------
NULL DOES NOT CAUSE A CAST ERROR
--------------------------------

Compare:

SELECT CAST('123' AS INTEGER);

Result:

123

But:

SELECT CAST('abc' AS INTEGER);

causes an error.

However:

SELECT CAST(NULL AS INTEGER);

is perfectly valid.

So:

'123' → INTEGER
'abc' → INTEGER
NULL  → INTEGER

behave differently:

'123' → succeeds
'abc' → conversion error
NULL  → remains NULL

This distinction becomes very important when we later 
discuss safe casting of dirty real-world data.


-- =====================================================================
-- SECTION G — TYPE CONVERSION
-- =====================================================================
--
-- G1 — Conversion Basics
--
-- 17. Implicit (Automatic) Type Conversion
-- 18. Explicit Conversion — CAST(value AS type)
-- 19. PostgreSQL :: Shorthand Cast Syntax
--
-- =====================================================================

Type conversion means:

Changing or interpreting a value as another data type.

For example:

TEXT → INTEGER
INTEGER → NUMERIC
TEXT → DATE
DATE → TEXT

There are two broad ways PostgreSQL can perform conversion:

Implicit conversion
Explicit conversion
========================================
17. IMPLICIT / AUTOMATIC TYPE CONVERSION
========================================

Implicit conversion means:

PostgreSQL performs a type conversion without you explicitly requesting it.

For example:

SELECT 10 + 2.5;

You wrote:

INTEGER + NUMERIC

PostgreSQL needs compatible types to perform the operation, 
so it resolves the expression using PostgreSQLs type rules.

Result:

12.5

You did not write:

CAST(10 AS NUMERIC)

PostgreSQL handled the type compatibility for you.

Implicit conversion is convenient, but do not assume PostgreSQL will
automatically convert every incompatible type.

For example, do not expect:

SELECT '100' + 20;

to behave like Python or some loosely typed language.

String-to-number conversion should generally be made explicit when required.
-----------------------------------------------------------
Implicit conversion is NOT "PostgreSQL converts everything"
-----------------------------------------------------------

This is a common misconception.

PostgreSQL has defined type-conversion rules.

If there is no valid/appropriate implicit conversion, you will get an error.

For example, if you need:

TEXT → INTEGER

you should explicitly tell PostgreSQL:

CAST(value AS INTEGER)

or:

value::INTEGER

This makes your intention clear
================================
18. EXPLICIT CONVERSION — CAST()
================================

Explicit conversion means:
You tell PostgreSQL exactly what type you want.

The standard syntax is:
CAST(value AS type)

Example:

SELECT CAST('123' AS INTEGER);

Result:

123

SELECT pg_typeof(
    CAST('100' AS INTEGER)
);
--------------
INTEGER → TEXT
--------------
SELECT CAST(100 AS TEXT);

Now 100 is text rather than a numeric value.

This matters because:

SELECT CAST(100 AS TEXT) || ' dollars';

produces:

100 dollars
=============================
19. :: — POSTGRESQL SHORTHAND
=============================

PostgreSQL provides a very commonly used shorthand:

value::type

Instead of:

CAST(value AS type)

you can write:

value::INTEGER

select 123::Integer;

select cast(123 as integer);

select 
	'123'::integer,
	'123.45'::numeric,
	'2026-08-18'::date,
	100::text;

CAST()

More standard SQL:

CAST(value AS type)

Useful when writing SQL intended to be portable across database systems.