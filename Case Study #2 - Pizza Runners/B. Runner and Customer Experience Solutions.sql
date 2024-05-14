-- B. Runner and Customer Experience


-- Q1 How many runners signed up for each 1 week period? (i.e. week starts 2021-01-01)
select week(registration_date) as week, count(*) as 'runners_signed' from runners
group by 1;

-- Q2 What was the average time in minutes it took for each runner to arrive at the Pizza Runner HQ to pickup the order?
Select runner_id, avg(minute(timediff(pickup_time, order_time))) as avg_time from customer_orders
join runner_orders using(order_id)
group by 1;

-- Q3  Is there any relationship between the number of pizzas and how long the order takes to prepare?
select pizza_count, avg(prepare_time) as prepare_time from (
select count(order_id) as pizza_count, (minute(timediff(pickup_time, order_time))) as prepare_time from customer_orders c
join runner_orders using(order_id)
where cancellation not like "%cancellation%" or cancellation is null
group by order_id,2) as sub
group by 1;

--  It seems like there might be a relationship between the number of pizzas ordered and the time it takes to prepare the order. As the number of pizzas increases, the preparation time also appears to increase.

-- Q4  What was the average distance travelled for each customer?
select customer_id, round(avg(trim('km' from distance)),1) as distance from customer_orders
join runner_orders using(order_id)
where distance != 'null'
group by 1;

-- Q5  What was the difference between the longest and shortest delivery times for all orders?
select (max(minute(timediff(pickup_time, order_time))) -
min(minute(timediff(pickup_time, order_time)))) as longest_shortest_delivery from customer_orders
join runner_orders using(order_id);

-- Q6 What was the average speed for each runner for each delivery and do you notice any trend for these values?
select runner_id, order_id, round((trim('km' from distance)*60/ REGEXP_SUBSTR(duration,"[0-9]+")),1) as speed from customer_orders
join runner_orders using(order_id)
where round((trim('km' from distance)*60/ REGEXP_SUBSTR(duration,"[0-9]+")),1) is not null
group by 1,2,3;

-- Q7  What is the successful delivery percentage for each runner?
with successful_delivery as (select runner_id, count(c.order_id) as successful_del from customer_orders c
join runner_orders using(order_id)
where cancellation not like "%cancellation%" or cancellation is null
group by 1),
deliver as (
select runner_id, count(c.order_id) as delivery from customer_orders c
join runner_orders using(order_id)
group by 1)

select runner_id, concat(round((successful_del/delivery)*100,1),"%") as delivery_percentage from successful_delivery
join deliver using(runner_id);
