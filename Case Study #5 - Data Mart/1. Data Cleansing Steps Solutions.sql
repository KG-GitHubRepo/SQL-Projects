-- 1. Data Cleansing Steps


Drop table if exists clean_weekly_sales;

CREATE TABLE clean_weekly_sales AS
with data as (
select *, str_to_date(week_date, '%d/%m/%Y') as date from weekly_sales)

select date, week(date) as week_number ,month(date) as month_number,
year(date) as calender_year, region, platform, segment,
case when REGEXP_SUBSTR(segment,"[0-9]+")=1 then "Young Adults"
when REGEXP_SUBSTR(segment,"[0-9]+")=2 then "Middle Aged"
when REGEXP_SUBSTR(segment,"[0-9]+")=3 or REGEXP_SUBSTR(segment,"[0-9]+")=4 then "Retirees"
else "Unknown" end as age_band,
case when REGEXP_SUBSTR(segment,"[a-zA-Z]+")='C' then "Couples"
when REGEXP_SUBSTR(segment,"[a-zA-Z]+")='F' then "Families"
else "Unknown" end as demographic,  transactions, sales,
round(sales/transactions,2) as avg_transaction
from data;


select * from clean_weekly_sales;
