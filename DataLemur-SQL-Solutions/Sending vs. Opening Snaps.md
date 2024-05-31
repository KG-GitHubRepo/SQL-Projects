# Sending vs. Opening Snaps [Snapchat SQL Interview Question]

~~~~sql

with cte as (
SELECT age_bucket,
sum(case when activity_type='open' then time_spent end) as open,
sum(case when activity_type='send' then time_spent end) as send FROM activities
join age_breakdown using(user_id)
group by 1
)

select age_bucket,round(send*100.0/(open+send),2) as send_perc,
round(open*100.0/(open+send),2) as open_perc from cte

~~~~
