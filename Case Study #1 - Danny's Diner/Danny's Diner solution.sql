-- Q1 What is the total amount each customer spent at the restaurant? 
-- Code:
select customer_id, sum(price) as Total_price from sales
join menu using(product_id)
group by 1;

-- Q2 How many days has each customer visited the restaurant?
select customer_id, count(distinct order_date) as visited from sales
group by 1 ;

-- Q3 What was the first item from the menu purchased by each customer?
with cte as (SELECT customer_id, product_name, 
row_number() over(partition by customer_id order by order_date) as rn from sales
join menu using(product_id))

select customer_id, product_name from cte
where rn=1;

-- Q4 What is the most purchased item on the menu and how many times was it purchased by all customers?
 SELECT sales.product_id, count(sales.product_id) as no_of_times, product_name from sales
join menu using(product_id)
group by 1,3
order by 2 desc limit 1;

-- Q5 Which item was the most popular for each customer?
select customer_id, product_name, no_of_times from
(
select customer_id, product_name,  count(sales.product_id) as no_of_times,
rank() over(partition by customer_id order by count(sales.product_id) desc) as rn  from sales
join menu using(product_id)
group by 1,2) as sq
where rn=1;

-- Q6 Which item was purchased first by the customer after they became a member?
with cte as (Select customer_id, order_date, product_name,
case when order_date>=join_date then 'Y' else 'N' end as member from sales
join menu using(product_id)
join members using(customer_id) )

select customer_id, product_name from (select customer_id, product_name,
rank() over(partition by customer_id order by order_date) as rn from cte
where member='Y') as t
where rn=1;

-- Q7 Which item was purchased just before the customer became a member?
with cte as (Select customer_id, order_date, product_name,
rank() over(partition by customer_id order by order_date desc) as rn
from sales
join menu using(product_id)
join members using(customer_id)
where order_date<join_date )

select customer_id, product_name from cte
where rn=1;

-- Q8 What is the total items and amount spent for each member before they became a member?
Select customer_id, count(product_id) as total_items, sum(price) as amount
from sales
join menu using(product_id)
join members using(customer_id)
where order_date<join_date
group by 1;

-- Q9 If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have? 
Select customer_id, 
sum(case when product_name='sushi' then price*10*2 else price*10 end) as points
from sales
join menu using(product_id)
group by 1;

-- Q10 In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?
Select customer_id, 
sum(case when product_name='sushi' or order_date between join_date and DATE_ADD(join_date, INTERVAL 7 day) then price*10*2 
else price*10 end) as total_points
from sales
join menu using(product_id)
join members using(customer_id)
WHERE order_date BETWEEN '2021-01-01' AND '2021-01-31'
group by 1
order by 2 desc;