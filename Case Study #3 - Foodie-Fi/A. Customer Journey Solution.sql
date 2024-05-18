-- A. Customer Journey


-- Q Based off the 8 sample customers provided in the sample from the subscriptions table, write a brief description about each customer’s onboarding journey.
with cte as (select customer_id, s.plan_id, start_date, plan_name, price, 
ifnull(lag(start_date) over(partition by customer_id order by start_date),'') as previous_sub from subscriptions s
join plans using(plan_id)
where customer_id <9)

select * , ifnull(datediff(start_date, previous_sub),'') as diff from cte;

'''
Description

The table provides subscription data for different customers, including their plan details and subscription dates. Here are insights for each customer:

Customer 1
Initial Plan: Started with a trial plan on 2020-08-01.
Next Plan: Upgraded to a basic monthly plan on 2020-08-08, just 7 days after the trial started.
Insight: This customer transitioned from a free trial to a paid subscription.

Customer 2
Initial Plan: Started with a trial plan on 2020-09-20.
Next Plan: Upgraded to a pro annual plan on 2020-09-27, 7 days after the trial began.
Insight: This customer upgraded to a high-value plan (pro annual) after the trial period.
  
Customer 3
Initial Plan: Started with a trial plan on 2020-01-13.
Next Plan: Upgraded to a basic monthly plan on 2020-01-20, 7 days after starting the trial.
Insight: Similar to Customer 1, this customer moved from a trial to a basic monthly plan.
  
Customer 4
Initial Plan: Started with a trial plan on 2020-01-17.
Next Plan: Upgraded to a basic monthly plan on 2020-01-24, 7 days after the trial.
Churn: Ended the subscription on 2020-04-21, 88 days after starting the basic monthly plan.
Insight: This customer used the basic monthly plan for nearly 3 months before churning.
  
Customer 5
Initial Plan: Started with a trial plan on 2020-08-03.
Next Plan: Upgraded to a basic monthly plan on 2020-08-10, 7 days after the trial.
Insight: Another customer who moved to a basic monthly plan after the trial period.
  
Customer 6
Initial Plan: Started with a trial plan on 2020-12-23.
Next Plan: Upgraded to a basic monthly plan on 2020-12-30, 7 days after the trial.
Churn: Ended the subscription on 2021-02-26, 58 days after starting the basic monthly plan.
Insight: This customer stayed on the basic monthly plan for nearly 2 months before churning.
  
Customer 7
Initial Plan: Started with a trial plan on 2020-02-05.
Next Plan: Upgraded to a basic monthly plan on 2020-02-12, 7 days after the trial.
Further Upgrade: Moved to a pro monthly plan on 2020-05-22, 100 days after starting the basic monthly plan.
Insight: This customer gradually moved from a trial to a basic monthly plan, and then upgraded to a pro monthly plan after about 3 months.
  
Customer 8
Initial Plan: Started with a trial plan on 2020-06-11.
Next Plan: Upgraded to a basic monthly plan on 2020-06-18, 7 days after the trial.
Further Upgrade: Moved to a pro monthly plan on 2020-08-03, 46 days after starting the basic monthly plan.
Insight: This customer transitioned from a trial to a basic monthly plan and then to a pro monthly plan within a couple of months.
  
General Insights
Most customers transitioned from a trial plan to a basic monthly plan within 7 days.
Some customers eventually upgraded to higher-tier plans (pro monthly/annual).
Churn occurred for a few customers after 2-3 months of subscribing to the basic monthly plan.
  
These patterns suggest a common trend of initially offering a trial period, followed by a transition to basic plans, with few customers further upgrading or eventually churning after a few months.
'''
