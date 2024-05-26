-- 2. Data Exploration


-- Q1 What day of the week is used for each week_date value?
SELECT DISTINCT DAYNAME(date) AS day_used
FROM clean_weekly_sales;


-- Q2 What range of week numbers are missing from the dataset?
with recursive cte as (
select 1 as rnge
union all

select rnge+1 from cte
where rnge<52
)
select group_concat(rnge separator ',') as missing_range from cte
where rnge not in (select distinct week_number from clean_weekly_sales);



-- Q3 How many total transactions were there for each year in the dataset?
select calender_year,  sum(transactions) as total_transactions from clean_weekly_sales
group by 1;


-- Q4 What is the total sales for each region for each month?
select Region, month_number ,  sum(sales) as total_transactions from clean_weekly_sales
group by 1,2;


-- Q5 What is the total count of transactions for each platform
select Platform,  count(transactions) as total_transactions_count from clean_weekly_sales
group by 1;


-- Q6 What is the percentage of sales for Retail vs Shopify for each month?
with total as (
select month_number, sum(sales) as t from clean_weekly_sales
group by 1)

select Platform, month_number, (sum(sales)/t)*100 as sales_percentage
from clean_weekly_sales
join total using(month_number)
group by 1,2
order by 2;


-- Q7 What is the percentage of sales by demographic for each year in the dataset?
with total as (
select Calender_year, sum(sales) as t from clean_weekly_sales
group by 1)

select demographic, calender_year, (sum(sales)/t)*100 as sales_percentage
from clean_weekly_sales
join total using(calender_year)
group by 1,2
order by 2;


-- Q8 Which age_band and demographic values contribute the most to Retail sales?
select age_band, demographic, sum(sales) as total from clean_weekly_sales
where platform='Retail'
group by 1,2
order by 3 desc;


-- Q9 Can we use the avg_transaction column to find the average transaction size for each year for Retail vs Shopify? If not - how would you calculate it instead?
select platform, calender_year, (sum(sales)/sum(transactions))*100 as average_transaction from clean_weekly_sales
group by 1,2
