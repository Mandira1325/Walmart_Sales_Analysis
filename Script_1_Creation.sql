create database walmart_db;
use walmart_db;
show tables;

-- Data Explorations-->
select * 
from walmart;

select count(*) 
from walmart;

select  payment_method,	
		count(*)
from walmart
group by 1;

select count(distinct Branch)
from walmart;

select max(quantity),min(quantity)
from walmart;

