-- A. Pizza Metrics


-- Q1 How many pizzas were ordered?
Select count(order_id) as Pizzas_order from customer_orders;

-- Q2 How many unique customer orders were made?
Select count(DISTINCT order_id) as Pizzas_order from customer_orders;

-- Q3  How many successful orders were delivered by each runner?
SELECT runner_id, count(*) successful_orders FROM runner_orders 
where cancellation not like "%cancellation%" or cancellation is null
group by 1;

-- Q4  How many of each type of pizza was delivered?
select c.pizza_id, count(pizza_id) as delivered_count, pizza_name from customer_orders c
join pizza_names using(pizza_id)
join runner_orders using(order_id)
where cancellation not like "%cancellation%" or cancellation is null
group by 1,3;

-- Q5  How many Vegetarian and Meatlovers were ordered by each customer?
select customer_id, count(pizza_id) as delivered_count, pizza_name from customer_orders c
join pizza_names using(pizza_id)
group by 1,3
order by 1;

-- Q6 What was the maximum number of pizzas delivered in a single order?
select count(order_id) as max_delivered_count from customer_orders c
join runner_orders using(order_id)
where cancellation not like "%cancellation%" or cancellation is null
group by c.order_id
order by 1 desc limit 1;

-- Q7  For each customer, how many delivered pizzas had at least 1 change and how many had no changes?
select customer_id, 
sum(case when exclusions = '' or exclusions = 'null' and extras = '' or extras = 'null' or extras is null then 1 else 0 end) as no_changes,
sum(case when exclusions <> '' and exclusions <> 'null' or extras <> '' and extras <> 'null' and extras is not null then 1 else 0 end) as atleast_1_changes
from customer_orders c
join runner_orders using(order_id)
where cancellation not like "%cancellation%" or cancellation is null
group by customer_id; 

-- Q8  How many pizzas were delivered that had both exclusions and extras?
select 
sum(case when exclusions <> '' and exclusions <> 'null' and extras <> '' and extras <> 'null' and extras is not null then 1 else 0 end) as both_changes
from customer_orders c
join runner_orders using(order_id)
where cancellation not like "%cancellation%" or cancellation is null;

-- Q9  What was the total volume of pizzas ordered for each hour of the day?
SELECT 
hour(order_time) AS hours,
COUNT(order_id) AS "pizza ordered"
FROM customer_orders
GROUP BY hours
ORDER BY hours;

-- Q10  What was the volume of orders for each day of the week?
SELECT 
dayname(order_time) as day,
COUNT(order_id) AS "pizza ordered"
FROM customer_orders
GROUP BY 1
ORDER BY 2 desc;