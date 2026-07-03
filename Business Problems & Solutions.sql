-- Walmart Business Problems
select * from walmart;
-- 1)What are the different payment methods, and how many transactions and items were sold with each method?

select payment_method , 
	   count(invoice_id) as total_transactions,
	   sum(quantity) as total_items_sold
from walmart
group by payment_method;

-- 2)  Which category received the highest average rating in each branch?
select branch,
	   category, 
       avg_rating
from (
select branch,
	   category, 
       avg(rating) as avg_rating, 
       dense_rank() over(partition by branch order by avg(rating) desc) as ranking
from walmart
group by 1,2) as a 
where ranking =1;

-- 3) What is the busiest day of the week for each branch based on transaction volume?
select branch,
		day_name,
        total_transactions
from (
select  branch,
		dayname(date) as day_name,
        count(*) as total_transactions,
        dense_rank() over(partition by branch order by count(invoice_id)desc) as ranking
from walmart
group by 1,2) as a 
where ranking=1;

-- 4) How many items were sold through each payment method?
select payment_method,
	   sum(quantity) as total_items_sold
from walmart
group by 1;

-- 5) What are the average, minimum, and maximum ratings for each category in each city?
select City,
		Category,
        avg(rating) as avg_rating,
        max(rating) as maximum_rating,
        min(rating) as minimum_rating
from walmart
group by 1,2 
order by 1;

-- 6) What is the total profit for each category, ranked from highest to lowest?
select category,
	   sum(total*profit_margin) as total_profit,
       dense_rank() over( order by sum(total) desc) as ranking
from walmart
group by 1;


-- 7) What is the most frequently used payment method in each branch?
select branch,
	   payment_method
from (
select branch,
	   payment_method,
       count(*) as total_used,
       dense_rank() over(partition by branch order by count(*) desc) as ranking
from walmart
group by 1,2) as a 
where ranking=1;

-- 8) How many transactions occur in each shift (Morning, Afternoon, Evening) across branches?
select  branch,
		case 
        when hour(cast(time as time)) < 12 then 'Morning'
        when hour(cast(time as time)) between 12 and 17 then 'Afternonn'
        else 'Evening'
        end as shift_time,
        count(*) as total_transactions
from walmart
group by 1,2
order by 1,3 desc;

-- 9) Which 5 branches experienced the largest decrease in revenue compared to the previous year? from current_year
with cte as (select branch, 
		year(date) as year,
		sum(total) as total
from walmart
where year(date) in (2025,2026)
group by 1,2),
cte2 as (select branch , 
		year,
        total,
        lag(total) over(partition by branch order by year),
	  total- lag(total) over(partition by branch order by year) as revenue_difference 
from cte)
select branch,
        revenue_difference
from cte2
where revenue_difference is not null
order by revenue_difference 
limit 5;

-- 10) identify branch  with higest decrease in ratio in revenue compared to last year-2022 and current year-2023
-- ratio-->last_year_revenue-current_year_revenue/last_year_revenue*100
with r_2022 as ( select branch,
				   year(date),
				   sum(total) as revenue
			from walmart
			where year(date) =2022
			group by 1,2),
r_2023 as (	select branch,
			   year(date),
			   sum(total) as revenue
		from walmart
		where year(date) =2023
		group by 1,2)
select ls.branch as branch_name ,
		ls.revenue as last_year_rev,
        cr.revenue as current_year_rev,
		round((ls.revenue-cr.revenue)/ls.revenue*100,2) as revenue_ratio
from r_2022 as ls
join  r_2023 as cr on ls.branch=cr.branch
where ls.revenue>cr.revenue
order by 4 desc
limit 5;










