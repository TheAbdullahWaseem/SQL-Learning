/*
============================================================
DATE & TIME FORMATTING — POSTGRESQL
============================================================

Author: Abdullah Waseem
Track: Data Analysis | Data Science | Machine Learning
Database: PostgreSQL — dvdrental

Purpose:
This script covers PostgreSQL date and time operations required
for Data Analysis, Data Science, and Machine Learning.

Topics include:
- DATE, TIME, TIMESTAMP, and TIMESTAMPTZ
- Extracting date/time components
- DATE_TRUNC() and analytical time bucketing
- Date/time formatting and parsing
- Date/time arithmetic and intervals
- Time-zone fundamentals
- Recency, cohorts, trends, and period comparisons
- Calendar and time-based ML features
- Preparing datetime data for pandas and ML workflows
- generate_series() for continuous time-series analysis

Important Rule:
Preserve full timestamp precision while row-level uniqueness,
ordering, ranking, or event-level analysis is still required.
Only truncate or convert timestamps when the reduced precision
is actually needed for the next analytical step.

Goal:
Build professional datetime handling skills for SQL analytics,
Data Science, and Machine Learning workflows.

============================================================
*/

=============================
SECTION A — Foundations
A1 — Recap and Current Moment
=============================

-------------------------------------
1. DATE, TIME, TIMESTAMP, TIMESTAMPTZ
-------------------------------------
These four types are the foundation for everything that follows.
--------
1.1 DATE
--------
DATE stores only a calendar date:

select date '2026-09-29';

It stores:

Year
Month
Day

It does not store:

Hour
Minute
Second
Time zone
-------------------
Check the data type
-------------------

select 
	date '2026-09-29' as my_date,
	pg_typeof(date '2026-09-29') as data_type;

--------
1.2 TIME
--------
TIME stores a time of day, without a date.

select time '15:30:45';

SELECT
    TIME '15:30:45' AS my_time,
    pg_typeof(TIME '15:30:45') AS data_type;


select time '15:30:45';

-------------
1.3 TIMESTAMP
-------------
TIMESTAMP stores:

DATE + TIME

select timestamp '2026-09-29 15:30:45';

select 
	timestamp '2026-09-29 15:30:45' as value,
	pg_typeof (timestamp '2026-09-29 15:30:45') as data_type;

---------------------
Important distinction
---------------------
Consider:

2026-09-29 15:30:45

A plain TIMESTAMP tells you:

The date and clock time are 15:30:45 on September 29.

It does not tell PostgreSQL which timezone that represents.

It could be:

UTC
Pakistan
Dubai
London
New York

The value itself does not establish that.

---------------
1.4 TIMESTAMPTZ
---------------
TIMESTAMPTZ means:

timestamp with time zone

It represents an absolute point in time.

select timestamptz '2026-09-29 15:30:45+05';

--------------------------
This is important because:
--------------------------
2026-09-29 15:30:45+05

and:

2026-09-29 10:30:45+00

represent the same instant.

Think of it this way:

Pakistan time
15:30
   │
   │ same instant
   ▼
UTC
10:30


1.5 The four types together

Keep this table in your notes:

1.5 The four types together

Keep this table in your notes:

Type			Stores						Time-zone aware?
DATE			Date only					No
TIME			Time only					No
TIMESTAMP		Date + time					No
TIMESTAMPTZ		Absolute point in time		yes


DATE
└── 2026-09-29

TIME
└── 15:30:45

TIMESTAMP
└── 2026-09-29 15:30:45

TIMESTAMPTZ
└── 2026-09-29 15:30:45+05

---------------------
1.7 dvdrental Example
---------------------

select 
	pg_typeof(rental_date)
from rental
limit 1;

==========================
2. TIMESTAMPTZ in Practice
==========================
This is probably the most important concept in Section A.
---------------------------------
2.1 What PostgreSQL actually does
---------------------------------
Suppose you provide:

The important concept is

          SAME INSTANT
               │
       ┌───────┴───────┐
       ▼               ▼
 UTC +00            UTC +05
10:30:00            15:30:00

The displayed clock time changes depending on the timezone.

The instant does not.

---------------------------------------
2.2 Check your current session timezone
---------------------------------------

select current_setting('timezone');

------------------------------------------------
2.3 See the same instant in different time zones
------------------------------------------------
Run:

select
	timestamptz '2026-09-29 15:30:00+05' 
	as original_time,
	
	timestamptz '2026-09-29 15:30:00+05'
	at time zone 'UTC'
	as utc_time;
	
-------------------------------------
2.4 Session timezone controls display
-------------------------------------
You can temporarily change your session timezone:

set time zone 'UTC';

SELECT TIMESTAMPTZ '2026-09-29 15:30:00+05';

You will see the instant displayed in UTC.

Now:

set time zone 'Asia/Karachi';

select timestamptz '2026-09-29 15:30:00+05';

--------------------------
2.5 A critical distinction
--------------------------
Do not think:

"TIMESTAMPTZ stores the timezone."

A better mental model is:

TIMESTAMPTZ represents an instant and PostgreSQL displays that instant 
according to the session timezone.

select current_setting('timezone');

========================
3. Current Date and Time
========================
PostgreSQL gives you several ways to obtain the current moment.
----------------
3.1 CURRENT_DATE
----------------

select current_date;
select current_time;

SELECT
    CURRENT_DATE,
    pg_typeof(CURRENT_DATE);

----------------
3.2 CURRENT_TIME
----------------

SELECT CURRENT_TIME;

Returns the current time with timezone information.

---------------------
3.3 CURRENT_TIMESTAMP
---------------------
SELECT CURRENT_TIMESTAMP;

Returns the current date and time with timezone information.

---------
3.4 NOW()
---------

select now();

NOW() is PostgreSQL very commonly used function for getting the current timestamp.

Check:

SELECT
    NOW(),
    pg_typeof(NOW());

You should see:

timestamp with time zone

-------------------------
3.5 Compare them together
-------------------------

Run:

select 
	current_date as current_date,
	current_time as current_time,
	current_timestamp as current_timestamp,
	now() as now;

CURRENT_DATE
→ date only

CURRENT_TIME
→ time only

CURRENT_TIMESTAMP
→ date + time + timezone

NOW()
→ date + time + timezone

------------------------------
3.6 CURRENT_TIMESTAMP vs NOW()
------------------------------
For your practical SQL work:

CURRENT_TIMESTAMP

and:

NOW()

are effectively equivalent for getting the current timestamp.

You will encounter both.

select
	rental_id,
	rental_date,
	now() - rental_date as time_since_rental
from rental
limit 10;


==============================================================================
3.7 Important PostgreSQL behavior: current timestamp is transaction-start time
==============================================================================


There is one detail you should know as a professional PostgreSQL user.

CURRENT_TIMESTAMP and NOW() represent the current timestamp at the start of 
the current transaction, not a continuously changing clock value.

For ordinary analytical queries, this usually makes no practical difference.

You can see the concept using:

BEGIN;

SELECT NOW();

-- Wait some time and execute again
SELECT NOW();

COMMIT;

======================================
3.8 clock_timestamp() — Know It Exists
======================================
PostgreSQL also provides:

SELECT clock_timestamp();

Unlike NOW(), this returns the actual current clock time and can change during a transaction.

Compare:

select 
	now(),
	clock_timestamp();
==========================
4. LOCALTIMESTAMP vs NOW()
==========================
This distinction is small but important.

Run:

SELECT
    LOCALTIMESTAMP,
    NOW();

They may look very similar:

2026-09-29 15:30:45.123
2026-09-29 15:30:45.123+05

But their types and semantics differ.
------------------
4.1 LOCALTIMESTAMP
------------------
SELECT LOCALTIMESTAMP;

Returns:

timestamp without time zone

---------
4.2 NOW()
---------
SELECT NOW();

Returns:

timestamp with time zone

----------------------
4.3 The key difference
----------------------
LOCALTIMESTAMP
       ↓
timestamp without time zone


NOW()
       ↓
timestamp with time zone

So do not treat them as simply two different names for the same thing.

-------------------------
4.4 Why does this matter?
-------------------------
Suppose you are building a system that combines timestamps from:

Pakistan
USA
UK
Germany

A timezone-aware timestamp can represent a real instant consistently.

A timezone-less timestamp:

2026-09-29 15:30:00

does not tell you which timezone it belongs to.

Therefore, when your data represents a real-world event, 
timezone awareness can matter greatly.


===========================================
SECTION B — Extracting Parts of a Date/Time
===========================================
This section is about extracting useful components from an existing date/time value.

=============================
5. EXTRACT(field FROM source)
=============================
----------------
5.1 Basic syntax
----------------
EXTRACT(field FROM source)

select 
	extract(year from rental_date) as year
from rental
limit 10;

The important idea is that EXTRACT() reads a component from the original datetime value; 
it does not modify the original value.

-------------
Extract month
-------------
SELECT
    rental_date,
    EXTRACT(MONTH FROM rental_date) AS month
FROM rental
LIMIT 10;

If you want:

May

rather than:

5

that is a formatting task and belongs to TO_CHAR(), which we will cover later.


------------
Extract hour
------------

SELECT
    rental_date,
    EXTRACT(HOUR FROM rental_date) AS hour
FROM rental
LIMIT 10;

--------------
Extract minute
--------------

SELECT
    rental_date,
    EXTRACT(MINUTE FROM rental_date) AS minute
FROM rental
LIMIT 10;


--------------
Extract second
--------------

SELECT
    rental_date,
    EXTRACT(SECOND FROM rental_date) AS second
FROM rental
LIMIT 10;

-----------------
Day of Week — DOW
-----------------

select 
	rental_date,
	extract(DOW from rental_date) as day_of_week
from rental
limit 10;

| Value | Day       |
| ----: | --------- |
|   `0` | Sunday    |
|   `1` | Monday    |
|   `2` | Tuesday   |
|   `3` | Wednesday |
|   `4` | Thursday  |
|   `5` | Friday    |
|   `6` | Saturday  |

select 
	rental_id,
	rental_date,
	extract(dow from rental_date) as day_of_week
from rental
where extract(dow from rental_date) in (0, 6)
limit 10;

------------------------
ISO Day of Week — ISODOW
------------------------

Unlike DOW, ISO numbering is:

| Value | Day       |
| ----: | --------- |
|   `1` | Monday    |
|   `2` | Tuesday   |
|   `3` | Wednesday |
|   `4` | Thursday  |
|   `5` | Friday    |
|   `6` | Saturday  |
|   `7` | Sunday    |

If you want the conventional ISO/Monday-first system, use:

EXTRACT(ISODOW FROM rental_date)

-----------------
Day of Year — DOY
-----------------

SELECT
    rental_date,
    EXTRACT(DOY FROM rental_date) AS day_of_year
FROM rental
LIMIT 10;

-------
Quarter
-------

SELECT
    rental_date,
    EXTRACT(QUARTER FROM rental_date) AS quarter
FROM rental
LIMIT 10;

1 → Q1
2 → Q2
3 → Q3
4 → Q4

----
Week
----

SELECT
    rental_date,
    EXTRACT(WEEK FROM rental_date) AS week
FROM rental
LIMIT 10;

This uses PostgreSQL ISO week numbering.

You do not need to memorize the complicated edge cases around ISO weeks yet, 
but know that week numbers and calendar years have special behavior around New Year.

For serious weekly reporting, DATE_TRUNC('week', ...) is often more useful
because it gives you an actual weekly bucket.

------------------------------------
Extract Multiple Components Together
------------------------------------

SELECT
    rental_id,
    rental_date,

    EXTRACT(YEAR FROM rental_date) AS year,
    EXTRACT(MONTH FROM rental_date) AS month,
    EXTRACT(DAY FROM rental_date) AS day,

    EXTRACT(HOUR FROM rental_date) AS hour,
    EXTRACT(MINUTE FROM rental_date) AS minute,
    EXTRACT(SECOND FROM rental_date) AS second,

    EXTRACT(DOW FROM rental_date) AS day_of_week,
    EXTRACT(DOY FROM rental_date) AS day_of_year

FROM rental
LIMIT 10;

----------------------------------
EXTRACT() Is Useful in Aggregation
----------------------------------

SELECT
    EXTRACT(HOUR FROM rental_date) AS hour,
    COUNT(*) AS rental_count
FROM rental
GROUP BY EXTRACT(HOUR FROM rental_date)
ORDER BY hour;

----------------------
Rentals by day of week
----------------------

SELECT
    EXTRACT(ISODOW FROM rental_date) AS day_of_week,
    COUNT(*) AS rental_count
FROM rental
GROUP BY EXTRACT(ISODOW FROM rental_date)
ORDER BY day_of_week;


EXTRACT() is excellent for analysis, because it gives you components that can
be grouped, filtered, compared, and used as features.

------------------
EXTRACT() in where
------------------

SELECT
    rental_id,
    rental_date
FROM rental
WHERE EXTRACT(MONTH FROM rental_date) = 5;

------------------------------
rentals occurring on weekends:
------------------------------
SELECT
    rental_id,
    rental_date
FROM rental
WHERE EXTRACT(isodow FROM rental_date) in (6,7);

-----------------
EXTRACT() in case
-----------------
	
select 
	rental_id,
	rental_date,
	case 
		when extract (isodow from rental_date) in (6,7)
		then 1
		else 0
	end as is_weekend
from rental;
	
end

==============
6. DATE_PART()
==============

DATE_PART() provides essentially the same functionality as EXTRACT().

Syntax:

DATE_PART('field', source)

select 
	date_part('year', rental_date) as year,
	date_part('month', rental_date) as month,
	date_part('day', rental_date) as day
from rental
limit 10;

You can also use:

SELECT
    DATE_PART('hour', rental_date) AS hour,
    DATE_PART('minute', rental_date) AS minute,
    DATE_PART('second', rental_date) AS second
FROM rental
LIMIT 10;

And:

SELECT
    DATE_PART('dow', rental_date) AS day_of_week,
    DATE_PART('doy', rental_date) AS day_of_year
FROM rental
LIMIT 10;

----------------------
6.1 Compare the Syntax
----------------------
EXTRACT():

EXTRACT(YEAR FROM rental_date)

DATE_PART():

DATE_PART('year', rental_date)

The conceptual operation is the same:

------------------------------
6.2 DATE_PART() with dvdrental
------------------------------
For example:

SELECT
    rental_id,
    rental_date,
    DATE_PART('year', rental_date) AS year,
    DATE_PART('month', rental_date) AS month,
    DATE_PART('dow', rental_date) AS day_of_week
FROM rental
LIMIT 10;

This is perfectly valid PostgreSQL.

You will encounter it in existing SQL code, Stack Overflow answers, 
projects, and PostgreSQL documentation.

Both extract a datetime component.

For your SQL work:

Prefer EXTRACT() when writing new SQL.

Why?

Because EXTRACT() is the SQL-standard form and its syntax clearly expresses:

EXTRACT this field
FROM this source

DATE_PART() is PostgreSQL function-style alternative.

Important Fields — Keep This Reference

You do not need to memorize dozens of obscure fields. 
For your DA/DS/ML work, know these well:

| Field     | Meaning               | Example |
| --------- | --------------------- | ------: |
| `YEAR`    | Year                  |  `2005` |
| `MONTH`   | Month number          |     `5` |
| `DAY`     | Day of month          |    `24` |
| `HOUR`    | Hour                  |    `22` |
| `MINUTE`  | Minute                |    `53` |
| `SECOND`  | Seconds               |    `30` |
| `DOW`     | Sunday=0 → Saturday=6 |     `2` |
| `ISODOW`  | Monday=1 → Sunday=7   |     `2` |
| `DOY`     | Day of year           |   `144` |
| `WEEK`    | ISO week              |  varies |
| `QUARTER` | Quarter               |     `2` |


====================================
SECTION C — Truncating and Bucketing
====================================

8. DATE_TRUNC('unit', timestamp) — Bucketing Time

DATE_TRUNC() changes a timestamp to the start of a specified time period.

Common units:

hour
day
week
month
quarter
year

Example:

SELECT DATE_TRUNC(
    'month',
    TIMESTAMP '2026-09-29 15:42:37'
);

The timestamp has been moved to the beginning of September.

SELECT
    DATE_TRUNC('hour', TIMESTAMP '2026-09-29 15:42:37')    AS hour_bucket,
    DATE_TRUNC('day', TIMESTAMP '2026-09-29 15:42:37')     AS day_bucket,
    DATE_TRUNC('week', TIMESTAMP '2026-09-29 15:42:37')    AS week_bucket,
    DATE_TRUNC('month', TIMESTAMP '2026-09-29 15:42:37')   AS month_bucket,
    DATE_TRUNC('quarter', TIMESTAMP '2026-09-29 15:42:37') AS quarter_bucket,
    DATE_TRUNC('year', TIMESTAMP '2026-09-29 15:42:37')    AS year_bucket;

------------------------------------
Important distinction from EXTRACT()
------------------------------------
You already learned:

EXTRACT(MONTH FROM rental_date)

returns:

5

whereas:

DATE_TRUNC('month', rental_date)

returns something like:

2005-05-01 00:00:00

EXTRACT()    → extracts a component
DATE_TRUNC() → creates a time bucket


Using dvdrental

See the difference between the original timestamp and its buckets:

SELECT
    rental_id,
    rental_date,
    DATE_TRUNC('day', rental_date) AS rental_day,
    DATE_TRUNC('month', rental_date) AS rental_month
FROM rental
ORDER BY rental_date
LIMIT 10;

Monthly rental count

This is one of the most common analytical uses:

SELECT
    DATE_TRUNC('month', rental_date) AS rental_month,
    COUNT(*) AS rental_count
FROM rental
GROUP BY DATE_TRUNC('month', rental_date)
ORDER BY rental_month;

=====================================
9. Why DATE_TRUNC() Precision Matters
=====================================

This is the formal version of the earlier row-collapse problem.

Suppose a customer has:

customer_id    rental_date
--------------------------------
1              2005-05-24 10:15
1              2005-05-24 15:30
1              2005-05-24 21:45

These are three separate events.

If we truncate:

DATE_TRUNC('day', rental_date)

we get:

2005-05-24 00:00
2005-05-24 00:00
2005-05-24 00:00

The rows still exist, but their time-level distinction has disappeared.


The important point

DATE_TRUNC() itself does not remove rows.

The problem occurs when the reduced timestamp is then used in something 
that requires uniqueness or event-level precision.

with events as (
	select  
		customer_id,
		date_trunc('day', rental_date) as rental_day
	from rental 
)

select distinct 
	customer_id,
	rental_day
from events;


If a customer rented multiple times on the same day, 
those events can now become one row.

The same issue can happen with:

GROUP BY
DISTINCT
JOIN conditions
PARTITION BY
ORDER BY

when the analysis incorrectly assumes the 
truncated value still identifies the original event.

The correct CTE pattern

If you need event-level calculations such as ROW_NUMBER(), LAG(), gaps, or ordering:

Preserve the original timestamp first.

with events as (
	select 
		customer_id,
		rental_id,
		rental_date,
		
		row_number() over (
			partition by customer_id
			order by rental_date, rental_id
		) as rental_number
	from rental
)

select *
from events
order by customer_id, rental_number;

-- Only after that event-level work should you create a bucket:

with events as (
	select 
		customer_id,
		rental_id,
		rental_date,
		
		row_number() over (
			partition by customer_id
			order by rental_date, rental_id
		) as rental_number
	from rental
)

SELECT
    DATE_TRUNC('month', rental_date) AS rental_month,
    COUNT(*) AS rental_count
FROM events
GROUP BY DATE_TRUNC('month', rental_date)
ORDER BY rental_month;

Do not reduce timestamp precision before you are finished with 
calculations that need the original event timing.

===================================
10. DATE_TRUNC() vs Casting to DATE
===================================
These two can look similar, but they serve different purposes.


Casting to DATE

rental_date::date

Result:

2005-05-24

You are saying:

I need this value to be a date, without a time component.

DATE_TRUNC('day', ...)
DATE_TRUNC('day', rental_date)

Result:

2005-05-24 00:00:00

You are saying:

I need the timestamp representing the beginning of this day.
-----------------
Direct comparison
-----------------

select 

	rental_date,
	rental_date::date as date_only,
	date_trunc('day', rental_date) as day_bucket,
	date_trunc('month', rental_date) as month_bucket
	
from rental
limit 5;

When to use which?

| Requirement                     | Use                                  |
| ------------------------------- | ------------------------------------ |
| Need only the calendar date     | `rental_date::date`                  |
| Need day-level timestamp bucket | `DATE_TRUNC('day', rental_date)`     |
| Need week bucket                | `DATE_TRUNC('week', rental_date)`    |
| Need month bucket               | `DATE_TRUNC('month', rental_date)`   |
| Need quarter bucket             | `DATE_TRUNC('quarter', rental_date)` |
| Need year bucket                | `DATE_TRUNC('year', rental_date)`    |


==================================
SECTION D — Formatting for Display
==================================

This section is about an important distinction:

DATE/TIMESTAMP → TO_CHAR() → TEXT for display

TEXT → TO_DATE()/TO_TIMESTAMP() → DATE/TIMESTAMP for actual date/time operations

-----------------------------------------------------
11. TO_CHAR(date, format) — Custom Display Formatting
-----------------------------------------------------

TO_CHAR() converts a date/timestamp into text according to a format pattern.

Syntax
TO_CHAR(date_or_timestamp, 'format')

select  to_char(timestamp '2026-09-12 14:35:42', 'Mon DD HH ss mi');

SELECT TO_CHAR(
    TIMESTAMP '2026-09-30 14:35:42',
    'DD-MM-YYYY'
);

select 
	rental_date,
	to_char(rental_date, 'DD-MM-YYYY') as formatted_date,
	to_char(rental_date, 'Mon YYYY') as month_year
from rental
limit 10;


Important

TO_CHAR() returns text, not a date.

SELECT pg_typeof(
    TO_CHAR(rental_date, 'DD-MM-YYYY')
)
FROM rental
LIMIT 1;
--------------------------
12. Common Format Patterns
--------------------------
These are the patterns you should know for analytics.

| Pattern     | Meaning              | Example     |
| ----------- | -------------------- | ----------- |
| `YYYY`      | 4-digit year         | `2026`      |
| `YY`        | 2-digit year         | `26`        |
| `MM`        | 2-digit month        | `09`        |
| `Mon`       | Short month name     | `Sep`       |
| `Month`     | Full month name      | `September` |
| `DD`        | 2-digit day          | `30`        |
| `Day`       | Full weekday name    | `Wednesday` |
| `DY`        | Short weekday name   | `Wed`       |
| `HH24`      | Hour, 24-hour format | `14`        |
| `HH12`      | Hour, 12-hour format | `02`        |
| `MI`        | Minutes              | `35`        |
| `SS`        | Seconds              | `42`        |
| `AM` / `PM` | AM/PM                | `PM`        |


SELECT
    TO_CHAR(rental_date, 'YYYY-MM-DD') AS standard_date,
    TO_CHAR(rental_date, 'DD-MM-YYYY') AS day_month_year,
    TO_CHAR(rental_date, 'Mon YYYY') AS month_year,
    TO_CHAR(rental_date, 'Day') AS weekday,
    TO_CHAR(rental_date, 'HH24:MI:SS') AS time_24h
FROM rental
LIMIT 5;

select 
	to_char(
	timestamp '2026-09-30 14:35:42',
	'Day, DD Mon YYYY HH24:MI:SS'
	);

-------------------------
TO_CHAR() vs DATE_TRUNC()
-------------------------
This distinction is important from the previous section:

DATE_TRUNC('month', rental_date)

produces a timestamp:

2005-05-01 00:00:00

while:

TO_CHAR(rental_date, 'Mon YYYY')

produces text:

May 2005

So:

DATE_TRUNC → analytical bucket
TO_CHAR    → display format

For example, for analysis:

select 
	date_trunc('month', rental_date) as month,
	count(*) as rentals
from rental
group by date_trunc('month', rental_date)
order by month;

---------------------------------------------
13. TO_DATE() / TO_TIMESTAMP() — Parsing Text
---------------------------------------------
Now we go in the opposite direction.

Sometimes dates arrive as text:

'30-09-2026'
'2026/09/30'
'30-Sep-2026'

PostgreSQL cannot treat arbitrary text as a proper date 
until we tell it how that text is structured.

TO_DATE()

Use TO_DATE() when the input represents a date without meaningful time.

Syntax
TO_DATE(text, format)

select pg_typeof(to_date('30-09-2026', 'DD-MM-YYYY'))

Another example:

SELECT TO_DATE(
    '24/05/2005',
    'DD/MM/YYYY'
);

--------------
TO_TIMESTAMP()
--------------
Use TO_TIMESTAMP() when the text contains date + time.

select to_timestamp('30-09-2026 14:35:42',
					'DD-MM-YYYY HH24:MI:SS');

------------------------------
Why the format pattern matters
------------------------------
Suppose the text is:

'05-06-2026'

Does that mean:

5 June 2026

or:

6 May 2026

The format tells PostgreSQL how to interpret it.

select to_date('05-06-2026', 'DD-MM-YYYY')

means:

05 = day
06 = month
2026 = year

Therefore:

2026-06-05

Whereas:

TO_DATE('05-06-2026', 'MM-DD-YYYY')

------------------
A Complete Example
------------------

Imagine a CSV contains:

customer_id | rental_date_text
------------+-------------------
1           | 24-05-2005 22:53:30
2           | 25-05-2005 01:15:20

The column is text, so first parse it:

Below query is just an example, it would not work because rental_date is already
a timestamp

select 
	customer_id,
	to_timestamp(
		rental_date, 'DD-MM-YYYY HH24:MI:SS'
	) as rental_timestamp
from rental;



================================
SECTION E — Date/Time Arithmetic
================================

This section is important for analytics because it lets you answer questions such as:

When will this date be one month later?
How many days are between two events?
How long has it been since a customers previous rental?
Is an event within a particular date range?

We already know the basic date/timestamp types, so lets
go directly into the operations.

-------------------------------
14. Adding/Subtracting INTERVAL
-------------------------------
INTERVAL represents a duration of time.

Basic syntax
timestamp + INTERVAL 'duration'
timestamp - INTERVAL 'duration'


Add Days

select 
	timestamp '2026-09-30 14:30:00' + interval '5 days';

SELECT
    TIMESTAMP '2026-09-30 14:30:00'
    - INTERVAL '5 days';

SELECT
    TIMESTAMP '2026-09-30 14:30:00'
    + INTERVAL '5 months';

You can use

'1 day'
'7 days'
'1 week'
'2 months'
'1 year'
'3 hours'
'30 minutes'
'45 seconds'

and comnbinations

select 
	timestamp '2026-09-30 14:30:00'
	+ interval '1 month 5 days 2 hours';

With dvdrental

For example, find the date one month after each rental:

select 
	rental_id,
	rental_date,
	rental_date + interval '1 month' as one_month_later
from rental 
limit 10;

You can also calculate a deadline:

SELECT
    rental_id,
    rental_date,
    rental_date + INTERVAL '7 days' AS seven_day_deadline
FROM rental
LIMIT 10;

---------------------
Important distinction
---------------------
INTERVAL is a duration, while DATE_TRUNC() creates a time bucket.

DATE_TRUNC() → reduce precision
INTERVAL     → move forward/backward in time

------------------------------------
15. Subtracting Two Dates/Timestamps
------------------------------------
There is an important PostgreSQL difference here.

date - date
--------------------------------------------------
Two DATE values produce an integer number of days.
--------------------------------------------------
select date '2026-09-30' - date '2026-09-25';

The result type is:

integer
---------------------
timestamp - timestamp
---------------------
Two timestamps produce an interval.

SELECT
    TIMESTAMP '2026-09-30 15:30:00'
    - TIMESTAMP '2026-09-25 10:15:00';

The key rule

DATE - DATE
      ↓
integer
      ↓
number of days


TIMESTAMP - TIMESTAMP
      ↓
interval
      ↓
duration

Using dvdrental

You can calculate the gap between a customers rentals with LAG():

with rental_history as (
	select 
		customer_id,
		rental_date,
		lag(rental_date) over (
			partition by customer_id
			order by rental_date
	) as previous_rental
	from rental
)

select 
	customer_id,
	rental_date,
	previous_rental,
	rental_date - previous_rental as rental_gap
from rental_history
where previous_rental is not null
order by customer_id, rental_date;

-----------------------------------
16. AGE() — Human-Readable Duration
-----------------------------------
AGE() calculates the difference between two dates/timestamps while preserving
years, months, and days.

Syntax
AGE(later_timestamp, earlier_timestamp)

SELECT AGE(
    TIMESTAMP '2026-09-30',
    TIMESTAMP '2024-05-15'
);

SELECT 
    TIMESTAMP '2026-09-30'
    - TIMESTAMP '2024-05-15';


select 
	customer_id,
	Age(
		current_date,
		min(rental_date)::date
	) as customer_history
from rental
group by customer_id 
order by customer_id;

Important

do not automatically use AGE() whenever you need a gap.

For analytical calculations such as:

"How many days since the previous rental?"

you usually want a day count, not:

0 years 1 mon 5 days

That is where the next pattern becomes useful.

------------------------------
17. EXTRACT(day FROM interval)
------------------------------
This is the pattern you have already encountered in gap analysis.

Suppose:

SELECT
    TIMESTAMP '2026-09-30 15:30:00'
    - TIMESTAMP '2026-09-25 10:15:00';

produces an interval:

5 days 05:15:00

You can extract the day component

select 	
	extract(
		day from (
			TIMESTAMP '2026-09-30 15:30:00'
    		- TIMESTAMP '2026-09-25 10:15:00'
		)
);

	
WITH rental_history AS (
    SELECT
        customer_id,
        rental_date,
        LAG(rental_date) OVER (
            PARTITION BY customer_id
            ORDER BY rental_date
        ) AS previous_rental
    FROM rental
)
SELECT
    customer_id,
    rental_date,
    previous_rental,

    EXTRACT(
        DAY FROM (rental_date - previous_rental)
    ) AS gap_days

FROM rental_history
WHERE previous_rental IS NOT NULL
ORDER BY customer_id, rental_date;

One important nuance

EXTRACT(DAY FROM interval) extracts the day component of the interval.

For example:

1 month 5 days

has:

select extract(year from interval '2 year 1 month 6 days');

------------------------------
18. Comparing Dates/Timestamps
------------------------------
Dates and timestamps can be compared using the normal comparison operators:

<
>
<=
>=
=
<>
Example

select *
from rental 
where rental_date > TIMESTAMP '2005-06-01 00:00:00';
--------------
Before a date:
--------------
SELECT *
FROM rental
WHERE rental_date < TIMESTAMP '2005-06-01';
------------------
On or after a date
------------------
SELECT *
FROM rental
WHERE rental_date >= TIMESTAMP '2005-06-01';
-------
BETWEEN
-------
You can specify a range:

select *
from rental 
where rental_date between
	timestamp '2005-06-01 00:00:00' 
	and timestamp '2005-06-30 23:59:59';

BETWEEN is inclusive:

lower value ≤ value ≤ upper value

So both boundaries are included.

-------------------------
Important timestamp issue
-------------------------
This is safer for a month boundary:

WHERE rental_date >= TIMESTAMP '2005-06-01'
  AND rental_date <  TIMESTAMP '2005-07-01'

rather than:

WHERE rental_date BETWEEN
    TIMESTAMP '2005-06-01'
    AND TIMESTAMP '2005-06-30 23:59:59'
    
Because timestamps can have fractional seconds. An event such as:

2005-06-30 23:59:59.500

would be after:

2005-06-30 23:59:59

and could therefore be missed.

The half-open range:

>= start
< next_period

is a very useful professional pattern for timestamp filtering.


Section E — Mental Model
INTERVAL
    ↓
Move a date/time forward or backward

date - date
    ↓
Integer number of days

timestamp - timestamp
    ↓
Interval duration

AGE()
    ↓
Calendar-oriented years/months/days

EXTRACT(DAY FROM interval)
    ↓
Extract day component from a duration

< > BETWEEN
    ↓
Filter/compare dates and timestamps

The most useful patterns to remember

-- Add/subtract time
rental_date + INTERVAL '7 days'

-- Date difference
date_2 - date_1

-- Timestamp difference
timestamp_2 - timestamp_1

-- Human-readable calendar difference
AGE(date_2, date_1)

-- Day component of a gap
EXTRACT(DAY FROM (timestamp_2 - timestamp_1))

-- Safe timestamp range
WHERE rental_date >= start_date
  AND rental_date < next_date

  
======================
SECTION F — Time Zones
======================
We already covered the basic distinction between TIMESTAMP and TIMESTAMPTZ in Section A, so I would not repeat that explanation.

Here we only need the practical behavior and AT TIME ZONE.

------------------------
19. TIMESTAMPTZ Behavior
------------------------
TIMESTAMPTZ means timestamp with time zone.

The important thing to remember is:

PostgreSQL uses TIMESTAMPTZ to represent an absolute point in time, 
while the displayed clocktime depends on the sessions time zone.

For example:

SELECT TIMESTAMPTZ '2026-09-30 18:00:00+05';

This represents:

2026-09-30 13:00:00 UTC

If your PostgreSQL session is set to Pakistan time:

SHOW timezone;

you may see:

Asia/Karachi

select current_setting('timezone');

The important idea

These are the same instant:

Pakistan:  18:00 +05
UTC:       13:00 +00

The clock representation changes; the actual moment does not.

------------------------------
Why TIMESTAMPTZ is often safer
------------------------------
Suppose an application records:

Customer transaction happened at 18:00

Without timezone information, we do not know whether that means:

18:00 Pakistan
18:00 UAE
18:00 UK
18:00 US

But an absolute timestamp such as:

2026-09-30 18:00:00+05

identifies the exact instant.

This matters when data comes from:

users in different countries
cloud systems
APIs
distributed applications
international businesses

For analytics, this means you can safely convert the same event into the 
timezone required for a particular report.

================
20. AT TIME ZONE
================
AT TIME ZONE is PostgreSQLs syntax for working with a specific timezone.

The behavior depends on whether the value is:

TIMESTAMP

or:

TIMESTAMPTZ

You mainly need to recognize and use the common TIMESTAMPTZ case.
-----------------------------------------
Converting an instant to another timezone
-----------------------------------------
Suppose:

SELECT TIMESTAMPTZ '2026-09-30 13:00:00+00';

This is the instant:

13:00 UTC

select 
	timestamptz '2026-09-30 13:00:00+00'
	at time zone 'Asia/Karachi';

----------------------
Using a named timezone
----------------------
Use proper IANA timezone names:

'Asia/Karachi'
'Europe/London'
'America/New_York'
'Asia/Dubai'
'UTC'


select 
	timestamptz '2026-09-30 2:00:00+00'
	at time zone 'Asia/Dubai';

--------------------------
A useful dvdrental example
--------------------------
The rental_date column in dvdrental is:

timestamp without time zone

So you should not blindly use:

rental_date AT TIME ZONE 'Asia/Karachi'

and assume you are simply "converting" the existing value.

Because rental_date has no timezone information, PostgreSQL has to interpret 
that timestamp according to timezone rules before producing the timezone-aware value.

For your current learning, the important distinction is:

For your current learning, the important distinction is:

TIMESTAMPTZ
    ↓
AT TIME ZONE 'Asia/Karachi'
    ↓
show that instant as Pakistan local time

Whereas a plain:

TIMESTAMP

does not identify an absolute instant by itself.

final Mental Model

TIMESTAMP
    ↓
"What date and clock time is written here?"

TIMESTAMPTZ
    ↓
"What exact moment did this event happen?"

AT TIME ZONE
    ↓
"Show that moment according to this timezone."
    
===============================================    
SECTION G — Applied Date Patterns for Analytics
===============================================

These four patterns are important for Data Analyst / Data Science
work and directly connect to your existing SQL skills.

----------------------------------------------------
21. Bucketing Transactions by Week / Month / Quarter
----------------------------------------------------
Concept

A transaction table contains individual events:

2025-01-03  → transaction
2025-01-05  → transaction
2025-01-17  → transaction
2025-02-02  → transaction
...

For trend analysis, we usually do not want every individual timestamp.

We want to group events into periods:

Month       Revenue
----------  -------
Jan 2025    50,000
Feb 2025    62,000
Mar 2025    71,000


This is date bucketing.

The main tool is:

DATE_TRUNC()

-------------
Monthly trend
-------------

Using dvdrental:

select 
	date_trunc('month', payment_date) as payment_month,
	sum(amount) as total_revenue
from payment
group by date_trunc('month', payment_date)
order by payment_month;

---------------------
Important distinction
---------------------
DATE_TRUNC() creates the bucket.

GROUP BY combines rows into that bucket.

This connects directly to the row-collapse issue we discussed earlier.

Weekly Trend:

SELECT
    DATE_TRUNC('week', payment_date) AS payment_week,
    SUM(amount) AS total_revenue
FROM payment
GROUP BY DATE_TRUNC('week', payment_date)
ORDER BY payment_week;

PostgreSQLs week truncation follows ISO-style week boundaries, 
with the week beginning on Monday.


Professional pattern

For reporting, you may want a readable label:

select 
	date_trunc('month', payment_date) as month_start,
	to_char(date_trunc('month', payment_date), 'Mon YYYY') as month_label,
	sum(amount) as total_revenue
from payment
group by date_trunc('month', payment_date)
order by month_start;
-------------------------------------------------------------------
Notice that we order using the actual date, not the formatted text.

This is safer than:

ORDER BY month_label
--------------------

Practical rule

Use:

DATE_TRUNC()

when you want to answer:

"What happened per week/month/quarter?"

Use:

EXTRACT()

when you want to answer:

"What component of the date is this?"

For example:

EXTRACT(MONTH FROM payment_date)

gives:

1
2
3
...

while:

DATE_TRUNC('month', payment_date)

gives an actual analytical month bucket.

-----------------------------------------------
22. Calculating Recency — Days Since Last Event
-----------------------------------------------
This is extremely important for customer analytics.

Business question

When was each customers most recent activity, and how many days has 
it been since then?

This is the foundation of recency analysis and 
can contribute to identifying potentially inactive or at-risk customers.

----------------------------
Step 1 — Find the last event
----------------------------
For dvdrental:

select 
	customer_id,
	max(rental_date) as last_rental
from rental
group by customer_id 
order by customer_id;

MAX() gives the most recent rental for each customer.

--------------------------
Step 2 — Calculate the gap
--------------------------
Conceptually:

Current date - Last rental date

select 
	customer_id,
	max(rental_date) as last_rental,
	current_date - max(rental_date)::date as days_since_last_rental
from rental
group by customer_id
order by days_since_last_rental;

Adding a business classification

You can build a simple analytical feature:

SELECT
    customer_id,
    MAX(rental_date) AS last_rental,
    CURRENT_DATE - MAX(rental_date)::date AS days_since_last_rental,
    CASE
        WHEN CURRENT_DATE - MAX(rental_date)::date > 60
            THEN 'At Risk'
        WHEN CURRENT_DATE - MAX(rental_date)::date > 30
            THEN 'Inactive'
        ELSE 'Recently Active'
    END AS activity_status
FROM rental
GROUP BY customer_id
ORDER BY days_since_last_rental DESC;
		
The 60/30-day thresholds are business rules, not universal SQL rules. 
In a real project, the threshold should be based on the business context or 
historical customer behavior.
	
------------------------------
23. Cohort-Style Date grouping
------------------------------
What is a cohort?

A cohort is a group of entities that share a common starting period.

For customers, one common definition is:

Customers grouped by the month in which they first became active.

Example:
----------------------------
Step 1 — Find first activity
----------------------------
select 
	customer_id,
	min(rental_date)::date as first_activity
from rental 
group by customer_id
order by first_activity;

----------------------------------------------------
Step 2 — Convert first activity into a cohort period
----------------------------------------------------

select 
	customer_id,
	date_trunc('month', min(rental_date)) as cohort_month
from rental 
group by customer_id 
order by cohort_month, customer_id;

------------------------------
Count customers in each cohort
------------------------------

SELECT
    DATE_TRUNC('month', MIN(rental_date)) AS cohort_month,
    COUNT(*) AS customers
FROM rental
GROUP BY DATE_TRUNC('month', MIN(rental_date))
ORDER BY cohort_month;

--------------------------------
Important analytical distinction
--------------------------------
A cohort is not simply a monthly transaction group.

These are different:
----------------------------
Monthly transaction grouping
----------------------------
DATE_TRUNC('month', rental_date)

asks:

How many transactions happened during this month?
------------------------
Customer cohort grouping
------------------------
DATE_TRUNC('month', MIN(rental_date))

asks:

When did this customer first become active?

That distinction becomes very important for retention analysis later.

-------------------------------------------------------
24. Month-over-Month and Period-over-Period Comparisons
-------------------------------------------------------
This combines skills you already know:

DATE_TRUNC
    ↓
GROUP BY
    ↓
Aggregate metric
    ↓
LAG()
    ↓
Compare current vs previous period

------------------------
Step 1 — Monthly revenue
------------------------
First create the monthly dataset:

SELECT
    DATE_TRUNC('month', payment_date) AS month,
    SUM(amount) AS revenue
FROM payment
GROUP BY DATE_TRUNC('month', payment_date)
ORDER BY month;

-----------------------------------------
Step 2 — Get the previous months revenue
-----------------------------------------
Now use LAG():

with monthly_revenue as (
	select 
		date_trunc('month', payment_date) as month, 
		sum(amount) as revenue
	from payment
	group by date_trunc('month', payment_date)
)

select 
	month, 
	revenue,
	lag(revenue) over (
		order by month
	) as previous_month_revenue
from monthly_revenue
order by month;

-----------------------------
Step 3 — Calculate MoM change
-----------------------------
----------------
Absolute change:

----------------
revenue - previous_month_revenue

------------------
Percentage change:
------------------

(current - previous)
-------------------- × 100
      previous
      
with monthly_revenue as (
   	select 
   		date_trunc('month', payment_date) as month,
   		sum(amount) as revenue
   	from payment
   	group by date_trunc('month', payment_date)
), 

comparison AS (
    SELECT
        month,
        revenue,
        LAG(revenue) OVER (
            ORDER BY month
        ) AS previous_month_revenue
    FROM monthly_revenue
)

select 
	month,
	revenue, 
	previous_month_revenue,
	revenue - previous_month_revenue as revenue_change,
	round (
		100.0 * (revenue - previous_month_revenue)
		/ nullif(previous_month_revenue, 0),
		2
	) as mom_growth_pct
from comparison
order by month


Why NULLIF()?

This:

NULLIF(previous_month_revenue, 0)

prevents division by zero.

If the previous value is 0, the denominator becomes NULL instead of causing
a division-by-zero error.

----------------------------------------
Period-over-Period — The General Pattern
----------------------------------------
MoM is just one example.

The same structure works for:

Week-over-Week       → weekly buckets
Month-over-Month     → monthly buckets
Quarter-over-Quarter → quarterly buckets
Year-over-Year       → yearly buckets

Only the bucket changes.



The Complete Mental Model for Section G

You should now recognize these four patterns immediately:

1. TREND ANALYSIS

   Individual events
        ↓
   DATE_TRUNC()
        ↓
   GROUP BY
        ↓
   Revenue / Sales / Count
   
2. RECENCY

   Customer events
        ↓
   MAX(date)
        ↓
   Current date - last date
        ↓
   Days since activity
   
3. COHORT

   Customer events
        ↓
   MIN(date)
        ↓
   DATE_TRUNC()
        ↓
   First-activity cohort
   
4. PERIOD COMPARISON

   Individual events
        ↓
   DATE_TRUNC()
        ↓
   GROUP BY + aggregate
        ↓
   LAG()
        ↓
   Previous period
        ↓
   Change / Growth %
   
------------------------------
The most important distinction
------------------------------

Remember this:

| Analytical question      | Main pattern                     |
| ------------------------ | -------------------------------- |
| Revenue per month        | `DATE_TRUNC` + `GROUP BY`        |
| Revenue per week         | `DATE_TRUNC` + `GROUP BY`        |
| Last customer activity   | `MAX(date)`                      |
| Gap between activities   | `LAG(date)`                      |
| First customer activity  | `MIN(date)`                      |
| Customer cohort          | `MIN(date)` + `DATE_TRUNC`       |
| Previous months revenue  | `LAG()`                          |
| MoM growth               | Aggregate + `LAG()` + arithmetic |
| QoQ growth               | Quarterly bucket + `LAG()`       |
| YoY growth               | Yearly bucket + `LAG()`          |


One final professional rule

do not truncate timestamps before event-level logic that depends on exact
ordering or uniqueness.

Do:

Full timestamp
      ↓
LAG / ROW_NUMBER / gap calculations
      ↓
DATE_TRUNC
      ↓
Aggregation

when you need event-level analysis.
------------------------------------------------
For pure trend aggregation, you can directly do:

Timestamp
   ↓
DATE_TRUNC
   ↓
GROUP BY

That is the main lesson from the earlier row-collapse problem.


=====================================================================
SECTION H — Applied Date/Time for ML, Data Science, and Data Analysis
=====================================================================
This section is important for your DA → DS → ML path, because dates 
and timestamps are rarely useful to an ML model in their raw form.

The general pipeline is:

Raw timestamp
      ↓
Clean / validate
      ↓
Extract meaningful features
      ↓
Create numerical / categorical features
      ↓
pandas / ML model

The four patterns below are worth knowing and practicing.

----------------------------------------
25. Why Time-Based Features Matter in ML
----------------------------------------
A raw timestamp such as:

2026-09-29 18:42:31

does not directly tell a model what behavior it represents.

We usually transform it into meaningful features.

Common examples:

Recency
Frequency
Time since previous event
Day of week
Month
Hour
Weekend flag
Season

Three especially important concepts are:

----------
A. Recency
----------

How recently did this event/customer activity occur?

For a customer:

Last purchase = 2026-09-20
Today         = 2026-10-01

Then:

Recency = 11 days

SQL pattern:

CURRENT_DATE - MAX(rental_date)::date

This can become an ML feature:

customer_id    recency_days
-----------    ------------
101            5
102            42
103            120

A model can potentially learn that customers with 
different recency patterns have different future behavior.

------------
B. Frequency
------------
Frequency asks:

How often does this entity perform an activity?

For example:

SELECT
    customer_id,
    COUNT(*) AS rental_frequency
FROM rental
GROUP BY customer_id;

-----------------------
This becomes a feature:

frequency = number of rentals
-----------------------------

----------------------------
C. Time Since Previous Event
----------------------------
This is different from recency.

Recency:

Now - customers last activity

Previous-event gap:

Current event - previous event

Using the LAG() pattern you already know:

WITH history AS (
    SELECT
        customer_id,
        rental_date,
        LAG(rental_date) OVER (
            PARTITION BY customer_id
            ORDER BY rental_date
        ) AS previous_rental
    FROM rental
)
SELECT
    customer_id,
    rental_date,
    rental_date - previous_rental AS time_since_previous
FROM history
WHERE previous_rental IS NOT NULL;

This can produce features such as:

average_gap_days
median_gap_days
last_gap_days

These can be useful in customer behavior modeling.

---------------------------------------------
26. Extracting Calendar Features for Modeling
---------------------------------------------

A timestamp contains many pieces of information.

For example:

2026-09-29 18:42:31

can become:

year       = 2026
month      = 9
day        = 29
hour       = 18
day_of_week = 2
is_weekend = 0

This is called feature engineering.

-----------
Day of Week
-----------
Using PostgreSQL:

SELECT
    rental_date,
    EXTRACT(ISODOW FROM rental_date) AS day_of_week
FROM rental;

--------
Day Name
--------
For reporting:

select 
	rental_date,
	to_char(rental_date, 'day') as day_name
from rental;

But for ML, a numeric/categorical representation
is usually more useful than a formatted text label.

----
Hour
----
Useful when customer behavior depends on time of day:

SELECT
    rental_date,
    EXTRACT(HOUR FROM rental_date) AS hour
FROM rental;

For example:

00 → midnight
06 → morning
12 → noon
18 → evening
23 → late night

------------------
Is-Weekend Feature
------------------
This is a very common feature.

Using ISODOW:

SELECT
    rental_id,
    rental_date,
    EXTRACT(ISODOW FROM rental_date) AS day_of_week,
    EXTRACT(MONTH FROM rental_date) AS month,
    EXTRACT(HOUR FROM rental_date) AS hour,
    CASE
        WHEN EXTRACT(ISODOW FROM rental_date) IN (6, 7)
            THEN 1
        ELSE 0
    END AS is_weekend
FROM rental;

Now one timestamp has become several usable features.

-------------------------
Why these features matter
-------------------------
Imagine you are predicting sales.

A raw timestamp:

2026-10-01 18:30:00

is not necessarily the best representation.

Instead:

month       = 10
hour        = 18
day_of_week = 4
is_weekend  = 0

can allow a model to learn recurring patterns.
	
-------------------------------------------------------
Important ML Warning: Month Is Not Always Truly Numeric
-------------------------------------------------------

Suppose:

January = 1
February = 2
...
December = 12

A model may interpret:

December > January

and potentially treat the difference between 1 and 2 as meaningful in a way 
that is not appropriate for the problem.

For some models, categorical encoding is better.

Even more importantly, cyclical features can be useful for variables such 
as hour/month/day-of-week:

23 → 0

are actually close in time, despite being numerically far apart.

This is a more advanced feature-engineering topic that you will handle
later in the ML section. For now, understand the principle:

Calendar values often need thoughtful encoding rather than blindly 
treating them as ordinary numbers.

-------------------------------------------------------------
27. Preparing Clean Timestamp Columns Before Export to pandas
-------------------------------------------------------------

This is particularly important in your SQL → pandas workflow.

You may query PostgreSQL from Python and expect:
--------------
datetime64[ns]
--------------
but sometimes receive:

object

for a date column.

----------------------
What does object mean?
----------------------

Suppose pandas shows:

rental_date    object

That often means pandas is treating the values as strings rather than actual datetime values.

For example:

"2005-05-24 22:53:30"
"2005-05-25 11:30:37"

are text representations.

You want:

datetime64[ns]

so pandas can perform proper datetime operations.
------------------------------------------------
Best practice: keep SQL timestamps as timestamps
------------------------------------------------

If PostgreSQL already contains:

rental_date timestamp

do not unnecessarily convert it to text in SQL:
----------------------------------
TO_CHAR(rental_date, 'YYYY-MM-DD')
----------------------------------
if the data is going to pandas for analysis.

TO_CHAR() deliberately converts it into text.

Instead:

SELECT
    customer_id,
    rental_date
FROM rental;

preserves the timestamp type.

This is an important rule:

Format dates only when you need presentation. 
Preserve the real date/time type when the data is going to analysis or ML.

--------------------------------
Why TO_CHAR() can cause problems
--------------------------------
This:

SELECT TO_CHAR(rental_date, 'YYYY-MM-DD')
FROM rental;

returns:
text

So Python may receive:
object

rather than a datetime dtype.

Compare:

SELECT rental_date
FROM rental;

with:

SELECT TO_CHAR(rental_date, 'YYYY-MM-DD')
FROM rental;

The first preserves the timestamp.

The second creates a string.
-------------------------
If pandas receives object
-------------------------
You can convert it:

df['rental_date'] = pd.to_datetime(df['rental_date'])

Then:

df['rental_date'].dtype

should become a datetime dtype such as:

datetime64[ns]

-----------------
You can then use:
-----------------

df['rental_date'].dt.year
df['rental_date'].dt.month
df['rental_date'].dt.day
df['rental_date'].dt.dayofweek
df['rental_date'].dt.hour

for Example:

df['year'] = df['rental_date'].dt.year
df['month']  df['rental_date'].dt.month
df['day_of_week'] = df['rental_date'].dt.dayofweek
df['hour'] = df['rental_date'].dt.hour

----------------------------
SQL vs pandas responsibility
----------------------------
A useful way to think about the workflow is:

PostgreSQL
    ↓
Keep timestamp correctly typed
    ↓
Export/query
    ↓
pandas
    ↓
Verify datetime dtype
    ↓
Feature engineering

For example:
---
sql
---

SELECT
    customer_id,
    rental_date
FROM rental;

------
pandas
------

df['rental_date'] = pd.to_datetime(df['rental_date'])

df['month'] = df['rental_date'].dt.month
df['day_of_week'] = df['rental_date'].dt.dayofweek
df['hour'] = df['rental_date'].dt.hour

You do not have to do all feature engineering in SQL.

The important thing is to avoid destroying the datetime information 
before pandas receives it.

================================================
28. generate_series() for Continuous Date Ranges
================================================

This is a particularly useful PostgreSQL feature for time-series analysis.

The problem

Suppose your sales data contains:

January → 5000
February → 6200
March → no transactions
April → 7100

If you simply aggregate the transaction table, March may completely disappear:

January  5000
February 6200
April    7100

But for time-series analysis, we often need:

January  5000
February 6200
March    0
April    7100

We need a continuous date range.

Thats where generate_series() is useful.
-----------------------
Basic generate_series()
-----------------------
For dates:

select 
	generate_series(
		date '2026-01-01',
		date '2026-06-01',
		interval '1 month'
	) as month;

Conceptually:

2026-01-01
2026-02-01
2026-03-01
2026-04-01
2026-05-01
2026-06-01


Example with dvdrental

First generate the months:

with months as (
	select 
		generate_series (
			date_trunc('month', min(payment_date)),
			date_trunc('month', max(payment_date)),
			interval '1 month'
		) as month
	from payment
)
select *
from months 
order by month;

This creates a continuous list of months covering the payment data.
--------------------
Join it with revenue
--------------------

WITH months AS (
    SELECT
        generate_series(
            DATE_TRUNC('month', MIN(payment_date)),
            DATE_TRUNC('month', MAX(payment_date)),
            INTERVAL '1 month'
        ) AS month
    FROM payment
),

monthly_revenue as (
	select 
		date_trunc('month', payment_date) as month,
		sum(amount) as revenue
	from payment
	GROUP BY DATE_TRUNC('month', payment_date)
)

select 
	m.month,
	coalesce(r.revenue, 0) as revenue
from months m
left join monthly_revenue r
	on m.month = r.month
order by m.month;

What is happening?

First:

months

contains every month.

Then:

monthly_revenue

contains only months where transactions exist.

Then:

LEFT JOIN

ensures every month from the calendar remains.

If there is no matching revenue:

r.revenue

is:

NULL

Then:

COALESCE(r.revenue, 0)

turns it into:

0

So you get a continuous time series.
----------------------------------------
generate_series() Can Also Generate Days
----------------------------------------
For example:

SELECT
    generate_series(
        DATE '2026-01-01',
        DATE '2026-01-07',
        INTERVAL '1 day'
    )::date AS day;

Result:

2026-01-01
2026-01-02
2026-01-03
2026-01-04
2026-01-05
2026-01-06
2026-01-07

You can therefore build:

daily calendar
weekly calendar
monthly calendar

and join your data to it.
-----------------------------------
The Complete Section H Mental Model
-----------------------------------

You should now see why date/time
knowledge matters beyond simply knowing SQL syntax.

                  RAW TIMESTAMP
                       │
          ┌────────────┴────────────┐
          ↓                         ↓
    Behavioral features       Calendar features
          │                         │
    ┌─────┼─────┐             ┌────┼────┬────┐
    ↓     ↓     ↓             ↓    ↓    ↓    ↓
 Recency Frequency Gap       Day  Month Hour Weekend
          │                         │
          └────────────┬────────────┘
                       ↓
                Feature Dataset
                       ↓
                    pandas
                       ↓
               ML / Analysis
               
               
And for time-series data:

Transactions
     ↓
DATE_TRUNC()
     ↓
Aggregate by period
     ↓
generate_series()
     ↓
Create continuous calendar
     ↓
LEFT JOIN
     ↓
Fill/handle missing periods
     ↓
Time-series dataset


What you should remember from Section H

| Topic                          | Core idea                                                                              |
| ------------------------------ | -------------------------------------------------------------------------------------- |
| **25. Time-based ML features** | Turn timestamps into behavioral features such as recency, frequency, and activity gaps |
| **26. Calendar features**      | Extract day, month, hour, weekday, weekend, etc.                                       |
| **27. SQL → pandas**           | Preserve actual timestamp types; do not use `TO_CHAR()` before analytical export        |
| **28. `generate_series()`**    | Create continuous dates/periods so missing time buckets can be identified and handled  |


The most important professional rule

do not treat dates as strings unless you are formatting them for presentation.
--------------------
For analysis and ML:
--------------------

timestamp
    ↓
preserve as datetime
    ↓
extract / engineer features
    ↓
model
-----------------
For presentation:
-----------------

timestamp
    ↓
TO_CHAR()
    ↓
text label

---------------------------------
And for time-series completeness:
---------------------------------

generate_series()
    ↓
calendar
    ↓
LEFT JOIN actual data

==========
Conclusion
==========

This notebook covered PostgreSQL Date & Time from foundations to 
practical analytics and ML-oriented feature engineering.

Key skills covered:

* Working with `DATE`, `TIME`, `TIMESTAMP`, and `TIMESTAMPTZ`
* Extracting and formatting date/time components
* Using `DATE_TRUNC()` for analytical time buckets
* Performing date/time arithmetic and interval calculations
* Handling time zones at a practical level
* Applying dates to trend analysis, recency, cohorts, and period comparisons
* Engineering time-based features for Data Science and Machine Learning
* Preparing timestamp data for pandas
* Using `generate_series()` to create continuous time ranges

The main principle is simple:

**Preserve datetime information during analysis, transform it into meaningful
features when needed, and format it as text only for presentation.**
