-- A. Customer Nodes Exploration

-- Q1 How many unique nodes are there on the Data Bank system?
select count(distinct node_id) as unique_nodes from customer_nodes;


-- Q2 What is the number of nodes per region?
select region_id, region_name, count(node_id) as no_of_nodes from customer_nodes
join regions using(region_id)
group by 1,2
order by 3 desc;


-- Q3 How many customers are allocated to each region?
select region_id, region_name, count(distinct customer_id) as no_of_customers from customer_nodes
join regions using(region_id)
group by 1,2
order by 3 desc;


-- Q4 How many days on average are customers reallocated to a different node?
select avg(datediff(end_date,start_date)) as reallocation
from customer_nodes
where end_date <> '9999-12-31';


-- Q5 What is the median, 80th and 95th percentile for this same reallocation days metric for each region?
WITH reallocation_days AS (
  SELECT 
    region_id,
    DATEDIFF(end_date, start_date) AS days
  FROM customer_nodes
  where end_date <> '9999-12-31'
)
, ranked_days AS (
  SELECT
    region_id,
    days,
    ROW_NUMBER() OVER (PARTITION BY region_id ORDER BY days) AS row_num,
    COUNT(*) OVER (PARTITION BY region_id) AS total_count
  FROM reallocation_days
)
, percentiles AS (
  SELECT
    region_id,
    MAX(CASE WHEN row_num <= total_count * 0.50 THEN days END) AS median,
    MAX(CASE WHEN row_num <= total_count * 0.80 THEN days END) AS p80,
    MAX(CASE WHEN row_num <= total_count * 0.95 THEN days END) AS p95
  FROM ranked_days
  GROUP BY region_id
)
SELECT 
  r.region_id,
  r.region_name,
  p.median,
  p.p80,
  p.p95
FROM percentiles p
JOIN regions r ON p.region_id = r.region_id
ORDER BY r.region_name;
