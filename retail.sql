---Cleaning Data

---Total Records = 541909
---135080 Records have no customerid
---406829 Records have customerid



with online_retail as
(
	SELECT invoiceno
		  ,stockcode
		  ,description
		  ,quantity
		  ,invoicedate
		  ,unitprice
		  ,customerid
		  ,country
	  FROM retail_info
	  Where CustomerID != 0
)
, quantity_price as 
(

	select *
	from online_retail
	where quantity > 0 and unitprice > 0
)
, dup_check as
(
	---duplicate check
	select * , ROW_NUMBER() over (partition by invoiceno, stockcode, quantity order by invoicedate)dups
	from quantity_price

)
---397667 clean data
--5215 duplicate records
select *
into retail_main
from dup_check
where dups = 1

ALTER TABLE retail_main ALTER COLUMN invoicedate TYPE DATE using to_date(invoicedate, 'DD-MM-YYYY');


----Clean Data
----BEGIN COHORT ANALYSIS
select * from retail_main


select
	Customerid,
	min(invoicedate) first_purchase_date,
	to_char(min(invoicedate),'YYYY-MM-01') Cohort_Date
into cohort4
from retail_main
group by Customerid

select *
from cohort4

---Create Cohort Index
select
	rrr.*,
 	year_diff * 12 + month_diff + 1 as cohort_index
into cohort_retention5
from
	(
		select
			rr.*,
 			invoice_year::INTEGER - cohort_year::INTEGER as year_diff,
 			invoice_month::INTEGER - cohort_month::INTEGER as month_diff
		from
			(
				select
					r.*,
					c.Cohort_Date,
				    to_char(r.invoicedate::DATE, 'YYYY')invoice_year,
					to_char(r.invoicedate::DATE, 'MM')invoice_month,
					to_char(c.cohort_date::DATE, 'YYYY')cohort_year,
					to_char(c.cohort_date::DATE, 'MM')cohort_month
				from retail_main r
				left join cohort4 c
					on r.Customerid = c.Customerid
			)rr
	)rrr
--where CustomerID = 14733
select * from cohort_retention5
ORDER BY 15 DESC

-- There are 13 distinct cohort index 
select *
into cohort_pivot
from 
(
		select distinct 
		customerid, 
		cohort_date,
		cohort_index
		from cohort_retention5 

)as tbl,

select cohort_date,
					 count(CASE WHEN cohort_index = 1 THEN customerid END) as "1",
					 count(CASE WHEN cohort_index = 2 THEN customerid END) as "2",
					 count(CASE WHEN cohort_index = 3 THEN customerid END) as "3",
					 count(CASE WHEN cohort_index = 4 THEN customerid END) as "4",
					 count(CASE WHEN cohort_index = 5 THEN customerid END) as "5",
					 count(CASE WHEN cohort_index = 6 THEN customerid END) as "6",
					 count(CASE WHEN cohort_index = 7 THEN customerid END) as "7",
					 count(CASE WHEN cohort_index = 8 THEN customerid END) as "8",
					 count(CASE WHEN cohort_index = 9 THEN customerid END) as "9",
					 count(CASE WHEN cohort_index = 10 THEN customerid END) as "10",
					 count(CASE WHEN cohort_index = 11 THEN customerid END) as "11",
					 count(CASE WHEN cohort_index = 12 THEN customerid END) as "12",
					 count(CASE WHEN cohort_index = 13 THEN customerid END) as "13"

			 into pivot_table1
			 from cohort_pivot
		 group by cohort_date
		 order by cohort_date


select *
from pivot_table1
order by cohort_date

select cohort_date ,
	(1.0 * ("1")/("1") * 100) as "1", 
    (1.0 * ("2")/("1") * 100) as "2", 
	(1.0 * ("3")/("1") * 100) as "3",
	(1.0 * ("4")/("1") * 100) as "4",
	(1.0 * ("5")/("1") * 100) as "5",
	(1.0 * ("6")/("1") * 100) as "6",
	(1.0 * ("7")/("1") * 100) as "7",
	(1.0 * ("8")/("1") * 100) as "8",
	(1.0 * ("9")/("1") * 100) as "9",
	(1.0 * ("10")/("1") * 100) as "10",
	(1.0 * ("11")/("1") * 100) as "11",
	(1.0 * ("12")/("1") * 100) as "12",
	(1.0 * ("13")/("1") * 100) as "13"
from pivot_table1
order by cohort_date





