-- C. Challenge Payment Question

-- Q The Foodie-Fi team wants you to create a new payments table for the year 2020 that includes amounts paid by each customer in the subscriptions table with the following requirements:

-- monthly payments always occur on the same day of month as the original start_date of any monthly paid plan
-- upgrades from basic to monthly or pro plans are reduced by the current paid amount in that month and start immediately
-- upgrades from pro monthly to pro annual are paid at the end of the current billing period and also starts at the end of the month period
-- once a customer churns they will no longer make payments


-- create table payment_2020 (
-- customer_id integer, 
-- plan_id integer, 
-- plan_name varchar(20), 
-- start_date date,
-- amount decimal(5,2),
-- payment_order integer);

Drop table if exists payments_2020;

CREATE TABLE payments_2020 AS
with recursive cte as (
 SELECT s.customer_id, s.plan_id, plan_name, start_date,
LAST_DAY(CONCAT(YEAR(start_date), '-12-01')) AS end_date, price
FROM subscriptions s
JOIN plans USING (plan_id)
WHERE year(start_date) <= 2020
 AND plan_name not IN ('trial','churn')
 union all
SELECT customer_id, plan_id, plan_name, date_add(start_date, interval 1 month),
LAST_DAY(CONCAT(YEAR(start_date), '-12-01')) AS end_date, price
FROM cte
WHERE start_date < end_date and plan_id <> 3
),

cte1 as (
select customer_id,
lag(customer_id) over(partition by customer_id order by start_date) as prev_id,
plan_id,
lag(plan_id) over(partition by customer_id order by start_date) as prev_plan,
plan_name, start_date,
lag(start_date) over(partition by customer_id order by start_date) as prev_date,
price,
lag(price) over(partition by customer_id order by start_date) as prev_price
from cte),

cte2 as (
select customer_id, plan_id,plan_name, start_date,
case when customer_id = prev_id and plan_id <> prev_plan and month(start_date) = month(prev_date) then price-prev_price
else price end as upd_price
from cte1),


final as (
SELECT customer_id, plan_id, plan_name, start_date, upd_price,
LAST_DAY(CONCAT(YEAR(start_date), '-12-01')) AS end_date
FROM cte2
WHERE customer_id NOT IN (
    SELECT DISTINCT customer_id
    FROM cte2
    WHERE plan_id = 2) OR start_date <= (
    SELECT MIN(start_date)
    FROM cte2 AS sub
    WHERE sub.customer_id = cte2.customer_id AND plan_id = 2)
    
union all

SELECT customer_id, plan_id, plan_name, date_add(start_date, interval 1 month),upd_price,
end_date
FROM final
WHERE start_date < end_date and plan_id = 2
)

select customer_id, plan_id, p.plan_name, start_date, 
case
when plan_id=2 and rn<>1 or upd_price<0 then p.price else upd_price end as amount,
rank() over(partition by customer_id order by start_date) as payment_order from
(
select *,row_number() over(partition by customer_id,plan_id order by start_date) as rn from final) as sub
join plans p using(plan_id)
where year(start_date)=2020
order by 1,4;

select * from payments_2020;