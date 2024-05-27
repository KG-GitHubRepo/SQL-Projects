-- 3. Before & After Analysis

-- This technique is usually used when we inspect an important event and want to inspect the impact before and after a certain point in time. 
-- Taking the week_date value of 2020-06-15 as the baseline week where the Data Mart sustainable packaging changes came into effect. We would include all week_date values for 2020-06-15 
-- as the start of the period after the change and the previous week_date values would be before Using this analysis approach - answer the following questions:

-- Q1 What is the total sales for the 4 weeks before and after 2020-06-15? What is the growth or reduction rate in actual values and percentage of sales?
with befor as 
(
SELECT SUM(sales) as sales
FROM clean_weekly_sales
WHERE date >= '2020-06-15' - INTERVAL 4 WEEK
  AND date < '2020-06-15'),

aftr as (
SELECT SUM(sales) as sales
FROM clean_weekly_sales
WHERE date < '2020-06-15' + INTERVAL 4 WEEK
  AND date >= '2020-06-15')

select b.sales as before4week, a.sales as after4week, abs(b.sales-a.sales) as diff,
abs(b.sales-a.sales)*100/ sum(b.sales) as sales_perc from befor as b, aftr as a
group by 1,2;



-- Q2 What about the entire 12 weeks before and after?
with befor as 
(
SELECT SUM(sales) as sales
FROM clean_weekly_sales
WHERE date >= '2020-06-15' - INTERVAL 12 WEEK
  AND date < '2020-06-15'),

aftr as (
SELECT SUM(sales) as sales
FROM clean_weekly_sales
WHERE date < '2020-06-15' + INTERVAL 12 WEEK
  AND date >= '2020-06-15')

select b.sales as beforesales, a.sales as aftersales, abs(b.sales-a.sales) as diff,
abs(b.sales-a.sales)*100/ sum(b.sales) as sales_perc from befor as b, aftr as a
group by 1,2;



-- Q3 How do the sale metrics for these 2 periods before and after compare with the previous years in 2018 and 2019?
with befor as 
(
SELECT calender_year,SUM(sales) as sales
FROM clean_weekly_sales
WHERE week_number >= week('2020-06-15') - 4
  AND week_number < week('2020-06-15')
group by 1),

aftr as (
SELECT calender_year,SUM(sales) as sales
FROM clean_weekly_sales
WHERE week_number < week('2020-06-15') + 4
  AND week_number >= week('2020-06-15')
group by 1)

select calender_year, b.sales as beforesales, a.sales as aftersales, abs(b.sales-a.sales) as diff,
abs(b.sales-a.sales)*100/ sum(b.sales) as sales_perc from befor as b
join aftr as a using(calender_year)
group by 1;