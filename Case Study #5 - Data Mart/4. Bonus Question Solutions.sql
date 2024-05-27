-- 4. Bonus Question


-- Which areas of the business have the highest negative impact in sales metrics performance in 2020 for the 12 week before and after period?

-- region
-- platform
-- age_band
-- demographic
-- customer_type
-- Do you have any further recommendations for Danny’s team at Data Mart or any interesting insights based off this analysis?


-- region
(with befor as 
(
SELECT region, SUM(sales) as sales
FROM clean_weekly_sales
WHERE date >= '2020-06-15' - INTERVAL 12 WEEK
  AND date < '2020-06-15'
group by 1),

aftr as (
SELECT region, SUM(sales) as sales
FROM clean_weekly_sales
WHERE date < '2020-06-15' + INTERVAL 12 WEEK
  AND date >= '2020-06-15'
group by 1)

select region as areas,'region' , b.sales as beforesales, a.sales as aftersales, abs(b.sales-a.sales) as diff,
abs(b.sales-a.sales)*100/ sum(b.sales) as sales_perc from befor as b
join aftr as a using(region)
group by 1)

union

(with befor as 
(
SELECT platform, SUM(sales) as sales
FROM clean_weekly_sales
WHERE date >= '2020-06-15' - INTERVAL 12 WEEK
  AND date < '2020-06-15'
group by 1),

aftr as (
SELECT platform, SUM(sales) as sales
FROM clean_weekly_sales
WHERE date < '2020-06-15' + INTERVAL 12 WEEK
  AND date >= '2020-06-15'
group by 1)

select platform as areas, 'platform' , b.sales as beforesales, a.sales as aftersales, abs(b.sales-a.sales) as diff,
abs(b.sales-a.sales)*100/ sum(b.sales) as sales_perc from befor as b
join aftr as a using(platform)
group by 1)

union

(with befor as 
(
SELECT age_band, SUM(sales) as sales
FROM clean_weekly_sales
WHERE date >= '2020-06-15' - INTERVAL 12 WEEK
  AND date < '2020-06-15'
group by 1),

aftr as (
SELECT age_band, SUM(sales) as sales
FROM clean_weekly_sales
WHERE date < '2020-06-15' + INTERVAL 12 WEEK
  AND date >= '2020-06-15'
group by 1)

select age_band as areas, 'age_band' , b.sales as beforesales, a.sales as aftersales, abs(b.sales-a.sales) as diff,
abs(b.sales-a.sales)*100/ sum(b.sales) as sales_perc from befor as b
join aftr as a using(age_band)
group by 1)

union

(with befor as 
(
SELECT demographic, SUM(sales) as sales
FROM clean_weekly_sales
WHERE date >= '2020-06-15' - INTERVAL 12 WEEK
  AND date < '2020-06-15'
group by 1),

aftr as (
SELECT demographic, SUM(sales) as sales
FROM clean_weekly_sales
WHERE date < '2020-06-15' + INTERVAL 12 WEEK
  AND date >= '2020-06-15'
group by 1)

select demographic as areas, 'demographic' , b.sales as beforesales, a.sales as aftersales, abs(b.sales-a.sales) as diff,
abs(b.sales-a.sales)*100/ sum(b.sales) as sales_perc from befor as b
join aftr as a using(demographic)
group by 1)

union

(with befor as 
(
SELECT customer_type, SUM(sales) as sales
FROM clean_weekly_sales
WHERE date >= '2020-06-15' - INTERVAL 12 WEEK
  AND date < '2020-06-15'
group by 1),

aftr as (
SELECT customer_type, SUM(sales) as sales
FROM clean_weekly_sales
WHERE date < '2020-06-15' + INTERVAL 12 WEEK
  AND date >= '2020-06-15'
group by 1)

select customer_type as areas, 'customer_type' , b.sales as beforesales, a.sales as aftersales, abs(b.sales-a.sales) as diff,
abs(b.sales-a.sales)*100/ sum(b.sales) as sales_perc from befor as b
join aftr as a using(customer_type)
group by 1);



-- The most significant negative impacts were observed in the Retail platform, 
-- the OCEANIA and ASIA regions, and among Existing and Guest customer types. 
-- These areas represent the biggest declines in sales performance metrics and may need targeted interventions to improve.