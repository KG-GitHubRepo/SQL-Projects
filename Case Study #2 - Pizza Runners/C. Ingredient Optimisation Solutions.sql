-- C. Ingredient Optimisation

use pizza_runner;

-- Q1 What are the standard ingredients for each pizza?
with CTE as (
WITH RECURSIVE topping_split AS (
    SELECT 
        pizza_id,
        TRIM(SUBSTRING_INDEX(toppings, ',', 1)) AS topping,
        SUBSTRING(toppings, LENGTH(SUBSTRING_INDEX(toppings, ',', 1)) + 2) AS rest,
        1 AS current_part
    FROM pizza_recipes
    
    UNION ALL
    
    SELECT 
        pizza_id,
        TRIM(SUBSTRING_INDEX(rest, ',', 1)) AS topping,
        SUBSTRING(rest, LENGTH(SUBSTRING_INDEX(rest, ',', 1)) + 2) AS rest,
        current_part + 1
    FROM topping_split
    WHERE LENGTH(rest) > 0
)
SELECT pizza_id, topping
FROM topping_split
ORDER BY pizza_id, current_part ) 

select pizza_id, group_concat(topping_name separator ',') as ingredients from cte
join pizza_toppings on topping=topping_id
group by 1;

-- Q2 What was the most commonly added extra?
with recursive extra_added AS (
select pizza_id, trim(substring_index(extras, ',',1)) as extra, 
substring(extras, length(substring_index(extras, ',',1))+2) as rest,
1 as current_part from customer_orders

union all

select pizza_id, trim(substring_index(rest, ',',1)) as extra, 
substring(rest, length(substring_index(rest, ',',1))+2) as rest,
current_part+1 from extra_added
where length(rest)>0
)

select extra, count(extra) as no_of_times, topping_name from extra_added
join pizza_toppings on extra=topping_id
where extra REGEXP '^-?[0-9]+$'
group by 1,3
order by 2 desc limit 1;

-- Q3  What was the most common exclusion?
with recursive excluded AS (
select pizza_id, trim(substring_index(exclusions, ',',1)) as exclusion, 
substring(exclusions, length(substring_index(exclusions, ',',1))+2) as rest,
1 as current_part from customer_orders

union all

select pizza_id, trim(substring_index(rest, ',',1)) as exclusion, 
substring(rest, length(substring_index(rest, ',',1))+2) as rest,
current_part+1 from excluded
where length(rest)>0
)

select exclusion, count(exclusion) as no_of_times, topping_name from excluded
join pizza_toppings on exclusion=topping_id
where exclusion REGEXP '^-?[0-9]+$'
group by 1,3
order by 2 desc limit 1;

-- Q4  Generate an order item for each record in the customers_orders table in the format of one of the following:
-- Meat Lovers
-- Meat Lovers - Exclude Beef
-- Meat Lovers - Extra Bacon
-- Meat Lovers - Exclude Cheese, Bacon - Extra Mushroom, Peppers
WITH Exclusion_extra as (	
SELECT 
    co.order_id,
    co.pizza_id,
    case when exclusions = '' or exclusions = 'null' or exclusions is null  then concat_ws(",",pt1.topping_name,pt2.topping_name)
    else concat('Exclude ', concat_ws(",",pt1.topping_name,pt2.topping_name)) end as exclusion_name,
    case when extras = '' or extras = 'null' or extras is null  then concat_ws(",",pt3.topping_name,pt4.topping_name)
    else concat('Extra ', concat_ws(",",pt3.topping_name,pt4.topping_name)) end as extra_name
FROM 
    customer_orders co
LEFT JOIN 
    pizza_toppings pt1 ON TRIM(SUBSTRING_INDEX(co.exclusions, ',', 1)) = pt1.topping_id
LEFT JOIN 
    pizza_toppings pt2 ON CASE 
                             WHEN LENGTH(co.exclusions) - LENGTH(REPLACE(co.exclusions, ',', '')) > 0 THEN 
                                 TRIM(SUBSTRING(co.exclusions, LENGTH(SUBSTRING_INDEX(co.exclusions, ',', 1)) + 2))
                             ELSE NULL
                         END = pt2.topping_id
LEFT JOIN 
    pizza_toppings pt3 ON TRIM(SUBSTRING_INDEX(co.extras, ',', 1)) = pt3.topping_id
LEFT JOIN 
    pizza_toppings pt4 ON CASE 
                             WHEN LENGTH(co.extras) - LENGTH(REPLACE(co.extras, ',', '')) > 0 THEN 
                                 TRIM(SUBSTRING(co.extras, LENGTH(SUBSTRING_INDEX(co.extras, ',', 1)) + 2))
                             ELSE NULL
                         END = pt4.topping_id
ORDER BY 
    co.order_id, co.pizza_id)
    
select distinct order_id, pizza_id, 
case when exclusion_name = '' and extra_name = '' then pizza_name
when exclusion_name <> '' and extra_name = '' then concat_ws(' - ', pizza_name, exclusion_name)
when exclusion_name = '' and extra_name <> '' then concat_ws(' - ', pizza_name, extra_name)
else concat_ws(' - ', pizza_name, exclusion_name, extra_name) end as topping_name
from exclusion_extra
join pizza_names using(pizza_id);


-- Q5  Generate an alphabetically ordered comma separated ingredient list for each pizza order from the customer_orders table and add a 2x in front of any relevant ingredients
-- For example: "Meat Lovers: 2xBacon, Beef, ... , Salami"
with cte as (
SELECT 
    ROW_NUMBER() OVER (ORDER BY order_id, pizza_id, toppings, extras) AS unique_id,
    order_id, pizza_id,
    case 
    when extras = '' or extras is null or extras = 'null' then toppings
    else
    concat_ws(' ,',toppings,extras) end as toppings
FROM 
    customer_orders
join 
	pizza_recipes using(pizza_id)),

split as (
with RECURSIVE topping_split AS (
    SELECT unique_id, order_id,
        pizza_id,
        TRIM(SUBSTRING_INDEX(toppings, ',', 1)) AS topping,
        SUBSTRING(toppings, LENGTH(SUBSTRING_INDEX(toppings, ',', 1)) + 2) AS rest,
        1 AS current_part
    FROM cte
    
    UNION ALL
    
    SELECT unique_id,order_id,
        pizza_id,
        TRIM(SUBSTRING_INDEX(rest, ',', 1)) AS topping,
        SUBSTRING(rest, LENGTH(SUBSTRING_INDEX(rest, ',', 1)) + 2) AS rest,
        current_part + 1
    FROM topping_split
    WHERE LENGTH(rest) > 0
)
SELECT *
FROM topping_split),

ingred as (
select unique_id, CASE 
        WHEN COUNT(*) > 1 THEN CONCAT(COUNT(*), 'x', topping_name)
        ELSE topping_name
    END AS ingredient from split
join pizza_toppings on topping_id=topping
group by 1, topping_name
order by 1)

select order_id , group_concat(ingredient separator ',') as ingredients from ingred
join cte using(unique_id)
group by unique_id, 1;


-- Q6 What is the total quantity of each ingredient used in all delivered pizzas sorted by most frequent first?
 with cte as (
SELECT 
    ROW_NUMBER() OVER (ORDER BY order_id, pizza_id, toppings, extras) AS unique_id,
    order_id, pizza_id,
    case 
    when extras = '' or extras is null or extras = 'null' then toppings
    else
    concat_ws(',',toppings,extras) end as toppings
FROM 
    customer_orders
join 
	pizza_recipes using(pizza_id)
join 
	runner_orders using(order_id)
	where cancellation not like "%cancellation%" or cancellation is null),

split as (
with RECURSIVE topping_split AS (
    SELECT unique_id, order_id,
        pizza_id,
        TRIM(SUBSTRING_INDEX(toppings, ',', 1)) AS topping,
        SUBSTRING(toppings, LENGTH(SUBSTRING_INDEX(toppings, ',', 1)) + 2) AS rest,
        1 AS current_part
    FROM cte
    
    UNION ALL
    
    SELECT unique_id,order_id,
        pizza_id,
        TRIM(SUBSTRING_INDEX(rest, ',', 1)) AS topping,
        SUBSTRING(rest, LENGTH(SUBSTRING_INDEX(rest, ',', 1)) + 2) AS rest,
        current_part + 1
    FROM topping_split
    WHERE LENGTH(rest) > 0
)
SELECT *
FROM topping_split),

exclusion as (
select topping_name, count(*) as times from (
select exclusion, topping_name from (
SELECT 
	TRIM(SUBSTRING_INDEX(exclusions, ',', 1)) as exclusion,
    CASE 
		WHEN LENGTH(exclusions) - LENGTH(REPLACE(exclusions, ',', '')) > 0 THEN 
		TRIM(SUBSTRING(exclusions, LENGTH(SUBSTRING_INDEX(exclusions, ',', 1)) + 2))
		ELSE '' END as remaining
FROM 
    customer_orders) as ex
join 
	pizza_toppings on exclusion=topping_id
union all
select remaining, topping_name from (
SELECT 
	TRIM(SUBSTRING_INDEX(exclusions, ',', 1)) as exclusion,
    CASE 
		WHEN LENGTH(exclusions) - LENGTH(REPLACE(exclusions, ',', '')) > 0 THEN 
		TRIM(SUBSTRING(exclusions, LENGTH(SUBSTRING_INDEX(exclusions, ',', 1)) + 2))
		ELSE '' END as remaining
FROM 
    customer_orders) as ex
join
	pizza_toppings on remaining=topping_id) as exclu
group by 1
)

select ingredient, 
case when ingredient in (select topping_name from exclusion) then num - times
else num end as no_of_times_used from (
select topping_name AS ingredient , count(*) num from split
left join pizza_toppings on topping_id=topping
group by 1) as new
left join exclusion on ingredient=topping_name
order by 2 desc;

