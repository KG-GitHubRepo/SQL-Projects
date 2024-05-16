-- D. Pricing and Ratings

use pizza_runner;

-- Q1 If a Meat Lovers pizza costs $12 and Vegetarian costs $10 and there were no charges for changes - how much money has Pizza Runner made so far if there are no delivery fees?
select sum(costs) as pizza_costs from (select c.pizza_id, pizza_name,
case when pizza_name = 'meatlovers' then 12 else 10 end as costs from customer_orders c 
join pizza_names using(pizza_id)
join runner_orders using(order_id)
where cancellation not like "%cancellation%" or cancellation is null) as pizza;


-- Q2 What if there was an additional $1 charge for any pizza extras?
-- Add cheese is $1 extra
with cte as (
select c.pizza_id, pizza_name,
case when pizza_name = 'meatlovers' then 12 else 10 end as costs ,
case when extras <> '' and extras is not null and extras <> 'null' 
then LENGTH(extras) - LENGTH(REPLACE(extras, ',', ''))+1
else 0 end AS count
from customer_orders c 
join pizza_names using(pizza_id)
join runner_orders using(order_id)
where cancellation not like "%cancellation%" or cancellation is null)

select sum(costs+count) as total from cte;


-- Q3  The Pizza Runner team now wants to add an additional ratings system that allows customers to rate their runner, how would you design an additional table for this new dataset.
-- Generate a schema for this new table and insert your own data for ratings for each successful customer order between 1 to 5.
DROP TABLE IF EXISTS ratings;
CREATE TABLE ratings 
 (order_id INTEGER,
    rating float);
INSERT INTO ratings
 (order_id ,rating)
VALUES 
(1,3),
(2,4.5),
(3,5),
(4,2),
(5,2.5),
(6,3.5),
(7,4),
(8,3.5),
(9,3),
(10,5); 

SELECT * 
from ratings;



-- Q4  Using your newly generated table - can you join all of the information together to form a table which has the following information for successful deliveries?
-- customer_id
-- order_id
-- runner_id
-- rating
-- order_time
-- pickup_time
-- Time between order and pickup
-- Delivery duration
-- Average speed
-- Total number of pizzas
select c.order_id, customer_id,runner_id,rating,order_time,pickup_time,
minute(timediff(pickup_time,order_time)) as timedifference,
duration, round(avg((trim('km' from distance)/ REGEXP_SUBSTR(duration,"[0-9]+")*60)),1) as speed, 
count(*) over() as total_pizzas from customer_orders c
join runner_orders using(order_id)
join ratings using(order_id)
group by 1,2,3,4,5,6,7,8;





-- Q5  If a Meat Lovers pizza was $12 and Vegetarian $10 fixed prices with no cost for extras and each runner is paid $0.30 per kilometre traveled.
-- How much money does Pizza Runner have left over after these deliveries?
with cte as (
select order_id,
case when pizza_id=1 then 12 else 10 end as cost,trim('km'from distance) ,
 trim('km'from distance)*0.30 as delivery_cost from customer_orders c
join runner_orders using(order_id)
where distance <> 'null')

select sum(cost) as revenue, round(sum(delivery_cost),2) as delivery_cost,
round(sum(cost-delivery_cost),2) as profit from cte;