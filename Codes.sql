use amazon_sells;
SELECT * FROM amazon; 
# Add a new column named timeofday to give insight of sales in the Morning, Afternoon and Evening. 
# This will help answer the question on which part of the day most sales are made

ALTER TABLE amazon
ADD time_of_day varchar(10);


UPDATE amazon
set time_of_day = 'Moring'
where time<12;

UPDATE amazon
set time_of_day = 'Afternoon'
where time>=12 and time<17;

UPDATE amazon
set time_of_day = 'Evening'
where time>=17 and time<=21;


#  Add a new column named dayname that contains the extracted days of the week
# on which the given transaction took place (Mon, Tue, Wed, Thur, Fri).
# This will help answer the question on which week of the day each branch is busiest.

ALTER TABLE amazon
ADD day_name varchar(10);

UPDATE amazon
set day_name = dayname(date);

#Add a new column named monthname that contains the extracted months of the year
# on which the given transaction took place (Jan, Feb, Mar).
# Help determine which month of the year has the most sales and profit.

ALTER TABLE amazon
ADD month_name varchar(10);

update amazon
set month_name = monthname(date);


# 1) What is the count of distinct cities in the dataset?

select city,count(city) from amazon
group by 1;


# 2) For each branch, what is the corresponding city?
select distinct branch,city from amazon;


# 3) What is the count of distinct product lines in the dataset?
SELECT Product_line,count(product_line) from amazon
group by Product_line;

# 4) Which payment method occurs most frequently?
select payment,count(payment) as payment_method from amazon
group by Payment
order by 2 desc
limit 1;

# 5) Which product line has the highest sales?
select product_line,count(product_line) as total_sales from amazon
group by 1
order by 2 desc
limit 1;

# 6) How much revenue is generated each month?
select month_name,sum(unit_price*quantity) as revenue from amazon
group by 1;

# 7) In which month did the cost of goods sold reach its peak?
select month_name,sum(cogs) from amazon
group by 1
order by 2 desc
limit 1;

# 8) Which product line generated the highest revenue?
select product_line,sum(unit_price*quantity) as revenue from amazon
group by 1
order by 2 desc
limit 1;

# 9) In which city was the highest revenue recorded?
select city,sum(unit_price*quantity) as revenue from amazon
group by 1
order by 2 desc
limit 1;

# 10) Which product line incurred the highest Value Added Tax?
select product_line,sum(tax_5_percent) as total_tax from amazon
group by 1
order by 2 desc
limit 1;




# 11) For each product line, add a column indicating "Good" if its sales are above average, otherwise "Bad".
ALTER TABLE amazon
ADD product_status varchar(4);

UPDATE amazon
SET product_status = 'Good'
where product_line in
(select distinct product_line from (select * from amazon) as something
group by 1
having sum(cogs) > (select sum(cogs)/count(distinct product_line) from (select * from amazon) as something));


UPDATE amazon
SET product_status = 'Bad'
where product_line not in
(select distinct product_line from (select * from amazon) as something
group by 1
having sum(cogs) > (select sum(cogs)/count(distinct product_line) from (select * from amazon) as something));

select * from amazon;

select distinct Product_line, product_status from amazon;




# 12) Identify the branch that exceeded the average number of products sold.
select 
	branch,
    sum(Quantity) as total_product_sold,
    (select sum(Quantity)/count(distinct Branch) from amazon) as average_product_sold 
from amazon
group by 1
having 
	sum(Quantity) > (select sum(Quantity)/count(distinct Branch) from amazon);




# 13) Which product line is most frequently associated with each gender?
select gender,Product_line,count(gender) as count, row_number() over(partition by gender order by count(gender) desc) as row_num from amazon
group by 1,2
order by 4
limit 2;




# 14) Calculate the average rating for each product line.
select product_line,avg(rating) as average_rating from amazon
group by Product_line;




# 15) Count the sales occurrences for each time of day on every weekday.
select day_name,time_of_day,count(cogs) as count_of_sales from amazon
where day_name != 'Saturday' and day_name != 'Sunday'
group by day_name,time_of_day
order by 1,2 desc;




# 16) Identify the customer type contributing the highest revenue.
select customer_type,sum(cogs) as revenue from amazon
group by Customer_type
order by 2 desc
limit 1;



# 17) Determine the city with the highest VAT percentage.
select city,sum(tax_5_percent) as VAT from amazon
group by city
order by 2 desc
limit 1;



# 18) Identify the customer type with the highest VAT payments.
select customer_type,sum(tax_5_percent) as VAT from amazon
group by Customer_type
order by 2 desc
limit 1;




# 19) What is the count of distinct customer types in the dataset?
select Customer_type,count(Customer_type) as count from amazon
group by Customer_type;



# 20) What is the count of distinct payment methods in the dataset?
select payment,count(payment) as count from amazon
group by payment;



# 21) Which customer type occurs most frequently?
select Customer_type,count(Customer_type) as count from amazon
group by Customer_type
limit 1;



# 22) Identify the customer type with the highest purchase frequency.
select customer_type,sum(quantity) as total_purchase from amazon
group by Customer_type
limit 1;




# 23) Determine the predominant gender among customers.
select gender,sum(quantity),sum(cogs) from amazon
group by gender
order by 3 desc
limit 1;




# 24) Examine the distribution of genders within each branch.
select branch,gender,count(gender) as count from amazon
group by 1,2
order by 1;





# 25) Identify the time of day when customers provide the most ratings.
select time_of_day,avg(rating) as average_rating from amazon
group by 1
limit 1;




# 26) Determine the time of day with the highest customer ratings for each branch.
WITH rating_per_branch_cte AS (
	select row_number() over(partition by branch order by avg(rating) desc) as cte_index,branch,time_of_day,avg(rating) as average_rating from amazon
	group by 2,3
	order by 2,4 desc
)

select branch,time_of_day,average_rating from rating_per_branch_cte
where cte_index = 1;




# 27) Identify the day of the week with the highest average ratings.
select day_name,avg(rating) as average_rating from amazon
group  by 1
order by 2 desc
limit 1;





# 28) Determine the day of the week with the highest average ratings for each branch.
WITH rating_each_day_cte AS (
	select row_number() over(partition by branch order by avg(rating) desc) as cte_index,branch,day_name,avg(rating) as average_rating from amazon
	group by 2,3
	order by 2,4 desc
)

select branch,day_name,average_rating from rating_each_day_cte
where cte_index = 1;