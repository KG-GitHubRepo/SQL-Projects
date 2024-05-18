-- B. Data Analysis Questions


-- Q1 How many customers has Foodie-Fi ever had?
Select count(distinct customer_id) total_customers from subscriptions;


-- Q2 What is the monthly distribution of trial plan start_date values for our dataset - use the start of the month as the group by value
select month(start_date) as month,date_format(start_date, '%M') as month_name, count(customer_id) as total
from subscriptions
where plan_id=0
group by 1,2
order by 1;


-- Q3 What plan start_date values occur after the year 2020 for our dataset? Show the breakdown by count of events for each plan_name
select s.Plan_id, plan_name, count(customer_id) as total from subscriptions s
join plans using(plan_id)
where year(start_date)>2020
group by 1,2
order by 1;


-- Q4 What is the customer count and percentage of customers who have churned rounded to 1 decimal place?
select count(customer_id) as churned_count, 
round((count(customer_id)/(select count( distinct customer_id) from subscriptions))*100,1) as churned_percentage
from subscriptions
where plan_id=4;


-- Q5 How many customers have churned straight after their initial free trial - what percentage is this rounded to the nearest whole number?
with cte as (
select *, row_number() over(partition by customer_id order by start_date) as rn from subscriptions
order by customer_id)

select count(customer_id) as churned,
round((count(customer_id)/(select count( distinct customer_id) from subscriptions))*100,0) as churned_percentage
from cte
where plan_id =4 and rn=2;



-- Q6 What is the number and percentage of customer plans after their initial free trial?
with cte as (
select *, row_number() over(partition by customer_id order by start_date) as rn from subscriptions
order by customer_id)

select count(customer_id) as purchased_plan,
round((count(customer_id)/(select count( distinct customer_id) from subscriptions))*100,0) as purchased_percentage
from cte
where plan_id <> 4 and rn=2
order by 1;



-- Q7 What is the customer count and percentage breakdown of all 5 plan_name values at 2020-12-31?
with cte as (
select *, row_number() over(partition by customer_id order by start_date desc) as rn from subscriptions
where start_date <= '2020-12-31'
order by customer_id)

select plan_id,plan_name, count(customer_id) as count,
round((count(customer_id)/(select count( distinct customer_id) from subscriptions))*100,0) as percentage
from cte
join plans using(plan_id)
where rn=1
group by 1,2
order by 1;


-- Q8 How many customers have upgraded to an annual plan in 2020?
with cte as (
select *, row_number() over(partition by customer_id order by start_date desc) as rn from subscriptions
where year(start_date) = 2020
order by customer_id)

select count(customer_id) as count from cte
where plan_id=3 and rn=1;


-- Q9 How many days on average does it take for a customer to an annual plan from the day they join Foodie-Fi?
with cte as (
select *, lag(start_date) over(partition by customer_id order by start_date ) as join_date from subscriptions
where  plan_id in (0,3)
order by customer_id)

select round(avg(days),0) as avg_days from 
(select *, ifnull(datediff(start_date,join_date),'') as days from cte) as sub
where days <> '';



-- Q10 Can you further breakdown this average value into 30 day periods (i.e. 0-30 days, 31-60 days etc)
with cte as (
select *,
ifnull(datediff(start_date, (lag(start_date) over(partition by customer_id order by start_date ))),'') AS days from subscriptions
where  plan_id in (0,3)
order by customer_id)

select periods, round(avg(days)) as no_of_avg_days, count(customer_id) as count from
(
select days, customer_id,
case when days between 0 and 30 then '0-30 days'
when days between 31 and 60 then '31-60 days'
when days between 61 and 90 then '61-90 days'
when days between 91 and 120 then '91-120 days'
else '120+ days' end as periods
from cte
where days <> '') as sub
group by 1;



-- Q11 How many customers downgraded from a pro monthly to a basic monthly plan in 2020?
with cte as (
select *, lag(start_date) over(partition by customer_id order by plan_id) as join_date from subscriptions
where year(start_date)=2020 and plan_id in (1,2))

select count(*) as downgraded from cte
where start_date<join_date
