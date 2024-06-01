# Odd and Even Measurements [Google SQL Interview Question]

~~~~sql
WITH CTE AS (
SELECT 
  DATE_TRUNC('day', measurement_time)  AS measurement_day
  , measurement_value
  , ROW_NUMBER() OVER( 
    PARTITION BY DATE_TRUNC('day', measurement_time)
    ORDER BY measurement_time)  rn
FROM measurements
)

SELECT
    measurement_day
    , SUM(CASE WHEN rn % 2 != 0 THEN measurement_value ELSE 0 END) odd_sum
    , SUM(CASE WHEN rn % 2 = 0 THEN measurement_value ELSE 0 END) even_sum 
FROM CTE
GROUP BY 1
~~~~
