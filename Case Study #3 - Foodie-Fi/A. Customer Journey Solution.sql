-- A. Customer Journey

-- Q Based off the 8 sample customers provided in the sample from the subscriptions table, write a brief description about each customer’s onboarding journey.
with cte as (select customer_id, s.plan_id, start_date, plan_name, price, 
ifnull(lag(start_date) over(partition by customer_id order by start_date),'') as previous_sub from subscriptions s
join plans using(plan_id)
where customer_id <9)

select * , ifnull(datediff(start_date, previous_sub),'') as diff from cte;