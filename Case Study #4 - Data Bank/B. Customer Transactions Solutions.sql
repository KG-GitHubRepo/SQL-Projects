--  B. Customer Transactions


-- Q1 What is the unique count and total amount for each transaction type?
select txn_type , count(*) as unique_count, sum(txn_amount) as total_amount
from customer_transactions
group by 1;


-- Q2 What is the average total historical deposit counts and amounts for all customers?
select round(avg(dep_count)) as dep_count, round(avg(dep_amount)) as dep_amount from 
(
select count(case when txn_type='deposit' then 1 end) as dep_count,
sum(case when txn_type='deposit' then txn_amount end) as dep_amount
from customer_transactions 
group by customer_id) as sub;


-- Q3 For each month - how many Data Bank customers make more than 1 deposit and either 1 purchase or 1 withdrawal in a single month?
with cte as 
(select customer_id, month(txn_date) as month, txn_type
from customer_transactions
where txn_type='deposit'),

cte2 as 
(select customer_id, month(txn_date) as month, txn_type
from customer_transactions
where txn_type <>'deposit'),

final as (
select c1.customer_id, c1.month,c1.txn_type, c2.month as m , c2.txn_type as txn from cte c1
join cte2 c2 
where c1.customer_id=c2.customer_id and c1.month=c2.month)

select month,count( distinct customer_id) as unique_count from final
group by 1
order by 1,2;



-- Q4 What is the closing balance for each customer at the end of the month?
with cte as (
select  customer_id,month(txn_date) as month,
sum(case when txn_type='deposit' then txn_amount end) - 
ifnull(sum(case when txn_type='withdrawal' or txn_type='purchase' then txn_amount end),0)  as net_amount
from customer_transactions
group by 1,2)

select *, sum(net_amount) over(partition by customer_id order by month rows between unbounded preceding and current row) as closing_balance
from cte
where net_amount is not null
order by 1,2;


-- Q5 What is the percentage of customers who increase their closing balance by more than 5%?
WITH cte AS (
  SELECT
    customer_id,
    MONTH(txn_date) AS month,
    SUM(CASE WHEN txn_type = 'deposit' THEN txn_amount ELSE 0 END) -
    IFNULL(SUM(CASE WHEN txn_type = 'withdrawal' OR txn_type = 'purchase' THEN txn_amount ELSE 0 END), 0) AS net_amount
  FROM
    customer_transactions
  GROUP BY
    customer_id, MONTH(txn_date)
),

closing_balances AS (
  SELECT
    customer_id,
    month,
    net_amount,
    SUM(net_amount) OVER (
      PARTITION BY customer_id
      ORDER BY month
      ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS closing_balance
  FROM
    cte
  WHERE
    net_amount IS NOT NULL
),

percentage_changes AS (
  SELECT
    customer_id,
    month,
    closing_balance,
    LAG(closing_balance) OVER (PARTITION BY customer_id ORDER BY month) AS first_deposit,
    ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY month DESC) AS row_num
  FROM
    closing_balances
)
select count(customer_id)/(select count(distinct customer_id) from percentage_changes) *100 as percent from (
select *,
case when closing_balance <0 then 0 else (closing_balance-first_deposit)/closing_balance*100 end as percentage
from percentage_changes
where row_num=1
) as sub
where percentage>=5