create database Capstone_amazon_E_Com_PGA49;
use Capstone_amazon_E_Com_PGA49;
SET SQL_SAFE_UPDATES = 0;
SET FOREIGN_KEY_CHECKS = 0;

create table customer(
 C_ID varchar(300) primary key,
 C_Name char(200),
 Gender char(200),
 Age int,
 City char(200),
 State char(200),
 Address varchar(300), 
Mobile_No bigint
);

create table product(
 P_ID varchar(300) primary key,
 P_Name char(250),
 Category varchar(260),
 Specs char(200),
 Price float
);

create table orders(
 Or_ID varchar(250) primary key ,
 C_ID varchar(300),
 P_ID varchar(300) ,
 Order_Date date ,
 Qty int, 
 Coupon char(100) ,
 DP_ID varchar(300)
);

create table transactions(
Tr_ID varchar(300) primary key,
Or_ID varchar(300),
 Transaction_Mode char(200),
 Tran_Status char(200)
);

create table rating(
R_ID varchar(300) primary key ,
Or_ID varchar(300),
Prod_Rating float,
Delivery_Service_Rating float
);

create table Subscription_Plan(
Plan_ID varchar(300) primary key,
Plan_Name varchar(250),
Features varchar(350)
);

create table Subscription_Details(
SD_ID varchar(300) primary key ,
C_ID varchar(300),
Plan_ID varchar(300),
From_Date date,
To_Date date
);

create table Delivery(
DP_ID varchar(300) primary key,
DP_Name char(200), 
DP_Ratings float
);

create table return_refund(
RT_ID varchar(300) primary key ,
Or_ID varchar(300), 
Reason char(250),
Return_Refund char(200), 
R_Date date
);

show tables; 

create table customer(
 C_ID varchar(300) primary key,
 C_Name char(200),
 Gender char(200),
 Age int,
 City char(200),
 State char(200),
 Address varchar(300), 
Mobile_No bigint
);

create table product(
 P_ID varchar(300) primary key,
 P_Name char(250),
 Category varchar(260),
 Specs char(200),
 Price float
);

create table orders(
 Or_ID varchar(250) primary key ,
 C_ID varchar(300),
 P_ID varchar(300) ,
 Order_Date date ,
 Qty int, 
 Coupon char(100) ,
 DP_ID varchar(300)
);

create table transactions(
Tr_ID varchar(300) primary key,
Or_ID varchar(300),
 Transaction_Mode char(200),
 Tran_Status char(200)
);

create table rating(
R_ID varchar(300) primary key ,
Or_ID varchar(300),
Prod_Rating float,
Delivery_Service_Rating float
);

create table Subscription_Plan(
Plan_ID varchar(300) primary key,
Plan_Name varchar(250),
Features varchar(350)
);

create table Subscription_Details(
SD_ID varchar(300) primary key ,
C_ID varchar(300),
Plan_ID varchar(300),
From_Date date,
To_Date date
);

create table Delivery(
DP_ID varchar(300) primary key,
DP_Name char(200), 
DP_Ratings float
);

create table return_refund(
RT_ID varchar(300) primary key ,
Or_ID varchar(300), 
Reason char(250),
Return_Refund char(200), 
R_Date date
);

show tables;

/* describe the tables */
describe customer;
describe product;
describe orders;
describe transactions;
describe rating;
describe subscription_plan;
describe subscription_details;
describe delivery;
describe return_refund;

/* display the data in the tables */
select * from customer;
select * from product;
select * from  orders;
select * from  transactions;
select * from  rating;
select * from  subscription_plan;
select * from  subscription_details;
select * from  delivery;
select * from  return_refund;


/* add foreign key in table */
alter table orders add foreign key (C_ID) references customer(C_ID);
alter table orders add foreign key (DP_ID) references delivery(DP_ID);
alter table orders add constraint Prod_od foreign  key (P_ID) references product(P_ID);
alter table transactions add constraint trns_od foreign key (Or_ID) references orders(Or_ID);
alter table rating add constraint rt_od foreign key(Or_ID) references orders(Or_ID);
alter table subscription_details add constraint sd_cs foreign key(C_ID) references customer(C_ID);
alter table subscription_details add constraint sd_pl foreign key(Plan_ID) references subscription_plan(Plan_ID);
alter table return_refund add constraint rr_or foreign key(Or_ID) references orders(Or_ID);


/*Select tables  based on parameters set*/

# 1. Customer Analysis
#	  Find the total number of customers grouped by gender and age group.
select Gender,Age,count(*) as Total_Customers from customer group by Gender,Age order by Gender desc;

#	  List the top 10 cities along with with the highest number of customers who placed orders.
select c.City,c.State,count(o.C_ID) as Total_Customers from customer as c join orders as o on c.C_ID=o.C_ID
group by c.City,c.State order by Total_Customers desc limit 10;

#	  Identify customers who have subscriptions but have not placed any orders in the past 6 months
select c.C_Name,sp.Plan_Name,sd.From_Date,sd.To_Date from customer as c join subscription_details as sd on
c.C_ID=sd.C_ID join subscription_plan as sp on sp.Plan_ID=sd.Plan_ID where c.C_ID not in 
( select o.C_ID from orders as o where c.C_ID=o.C_ID and datediff(now(),o.Order_Date)>180 );  

#	  Calculate the average spending of customers based on their age group and find its top 20.
select c.age,round( avg(o.Qty*p.Price),2) as average_spending from customer as c join orders as o on c.C_ID=o.C_ID 
join product as p on p.P_ID=o.P_ID group by c.age order by  average_spending desc limit 20;

#	  Find the percentage of customers in each city who use coupons in their orders.
select  count(c.C_ID)/(select count(C_ID) from customer )*100 as '%_Customers'
from customer as c where C_ID in (select C_ID from orders as o where c.C_ID=o.C_ID and o.Coupon not in ('No Coupons'));


# 2. Product/Service Analysis
#     Find the top 10 most sold products for each category. 
select * from 
(select p.Category,p.P_Name,
row_number() over ( partition by p.Category order by o.Qty desc ) as Ranks
from product as p join orders as o on o.P_ID=p.P_ID ) as tq where tq.Ranks<=10 order by tq.Category asc ;

#     Calculate the total revenue generated by each product, along with its category.
select p.P_Name,p.Category, round(sum(p.Price*o.Qty),2) as Total_Revenue from product as p join orders as o
on o.P_ID=p.P_ID group by p.Category,p.P_Name order by round(sum(p.Price*o.Qty),2) desc;

#     Identify top 20  products with the lowest return/refund rate and their respective categories.
select p.P_Name,count(rr.RT_ID) as Total_Returns, 
round(count(RT_ID)/sum(o.Qty)*100,2) as Return_Refund_Rate from product as p join orders as o on o.P_ID=p.P_ID
left join return_refund as rr on rr.Or_ID=o.Or_ID group by p.P_Name order by Return_Refund_Rate desc limit 20;


#     List the products that received an average rating below 3 and their total sales. 
select p.P_Name, round(avg(r.Prod_Rating),1) as Average_Rating, round(sum(p.Price*o.Qty),2) as Total_Sales from
product as p join orders as o on o.P_ID=p.P_ID join rating as r on r.Or_ID=o.Or_ID
group by p.P_Name order by Average_Rating desc; 

#     Calculate the average price of products in each category.
select Category,P_Name, round(avg(Price),2) as Average_Price from product group by Category,P_Name 
order by Category asc, P_Name asc; 


#3. Order Analysis
#     Calculate the total revenue generated for each city and find top 50.
select c.City, round(sum(o.Qty*p.Price),2) as Revenue from customer as c join orders as o on
c.C_ID=o.C_ID join product as p on p.P_ID=o.P_ID group by c.City order by Revenue desc limit 50;

#     Identify the top 20 customers who placed the most orders and their total spending. \
select c.C_Name , count(Or_ID) as Total_Orders, round(sum(p.Price*o.Qty),2) Total_Spending from customer as c join orders as o on
c.C_ID=o.C_ID join product as p on p.P_ID=o.P_ID group by c.C_Name order by Total_Orders desc limit 20;

#     Calculate the average order value (AOV) for orders with and without coupons. 
select 
( select round(sum(p.Price*o.Qty)/count(Or_ID),2)   from orders as o join product as p on 
p.P_ID=o.p_ID where not o.Coupon ='No Coupon' ) as 'Avg_Order_Value (No_Coupon)',
(select round(sum(p.Price*o.Qty)/count(Or_ID),2)  from orders as o join product as p on 
p.P_ID=o.p_ID where  o.Coupon='No Coupon')  as 'Avg_Order_Value (Coupon)' ;

#     Find the total quantity sold for each product in the last year  monthwise. 
select monthname(Order_Date) as Month , sum(Qty) as Total_Quantity from orders 
where year(Order_Date)=2023 group by monthname(Order_Date) order by Total_Quantity desc;

#     Identify orders of product where delivery was handled by the partner with the lowest ratings (less than 4).
select p.P_Name,round(avg(d.DP_Ratings),1) as Avg_Rating from product as p join orders as o on
p.P_ID=o.P_ID join delivery as d on o.DP_ID=d.DP_ID group by p.P_Name having Avg_Rating<4 order by Avg_Rating desc; 

#     Calculate MOM%_Sales
with Monthly_Sales as  
(select date_format(o.Order_Date,'%Y-%M') as Months , round(sum(o.Qty*p.Price),2) as total_sales from orders as o join product as p
on p.P_ID=o.P_ID group by Months order by Months Desc)  ,
Monthly_Growth as (select Months, total_sales, LAG(total_sales) OVER (ORDER BY Months) AS prev_month_sales FROM monthly_sales)
select Months , total_sales, round((total_sales- prev_month_sales)/prev_month_sales*100,2) as 'MOM %'
from Monthly_Growth order by month(Months) asc  ;

#     Calculate YOY%_Sales 
with Yearly_Sales as  
(select year(Order_Date) as Years , round(sum(o.Qty*p.Price),2) as total_sales from orders as o join product as p
on p.P_ID=o.P_ID group by Years order by Years Desc)  ,
Yearly_Growth as (select Years, total_sales, LAG(total_sales) OVER (ORDER BY Years) AS prev_year_sales FROM Yearly_Sales)
select Years , total_sales, round((total_sales- prev_year_sales)/prev_year_sales*100,2) as 'YOY %'
from Yearly_Growth order by Years desc  ;


# 4. Transaction Analysis
#      Find the percentage of successful transactions for each transaction mode. 
select  Transaction_Mode, round(count(Tran_Status)/(select count(Tr_ID) from transactions)*100,2) as Percent_Successful from transactions where Tran_Status='Successful'
group by Transaction_Mode order by Percent_Successful desc;

#.     List customers along with products with failed transactions    
select c.C_Name,p.P_Name from customer as c join orders as o on o.C_ID=c.C_ID join product as p
on p.P_ID=o.P_ID join transactions as t on t.Or_ID=o.Or_ID where Tran_Status='Failed' 
group by c.C_Name,p.P_Name order by c.C_Name asc;

#      Calculate the total revenue generated from successful transactions by each product category.
select p.Category,p.P_Name,round(sum(p.Price*o.Qty),2) as Total_Revenue from product as p join orders as o on p.P_ID=o.P_ID
join transactions as t on t.Or_Id=o.Or_ID where Tran_Status='Successful' group by p.Category,p.P_Name order by p.Category desc;
 
#      Identify the most frequently used transaction mode. 
select t.Transaction_Mode,count(t.Tr_ID) as Total_Use from transactions as t join orders as o on o.Or_ID=t.Or_ID
 group by t.Transaction_Mode order by Total_Use desc; 

#      Find the total revenue from transactions grouped by the month.
select monthname(Order_Date) as Months,t.Transaction_Mode,round(sum(p.Price*o.Qty),2) as Total_Revenue 
from transactions as t join orders as o on o.Or_ID=t.Or_ID join product as p on p.P_ID=o.P_ID where Tran_Status='Successful'
group by Months, t.Transaction_Mode order by Months asc  ;

#      Calculate Month-over-Month (MOM%) growth in transaction success rates.
with Monthly_Sales as  
(select date_format(o.Order_Date,'%Y-%M') as Months,t.Transaction_Mode as Transaction_Mode , 
round(sum(o.Qty*p.Price),2) as total_sales from 
orders as o join product as p on p.P_ID=o.P_ID join transactions as t on t.Or_ID=o.Or_ID
group by Months,Transaction_Mode order by Months Desc)  ,
Monthly_Growth as (select Months, Transaction_Mode, total_sales, LAG(total_sales) OVER (ORDER BY Months) AS prev_month_sales 
FROM monthly_sales)
select Months,Transaction_Mode , total_sales, round((total_sales- prev_month_sales)/prev_month_sales*100,2) as 'MOM %'
from Monthly_Growth order by month(Months) asc  ;


#5. Rating Analysis
#     Identify the products with the highest and lowest average ratings.
select * from
(select p.P_Name, round(avg(r.Prod_Rating),1) as Average_Rating from product as p join orders as o on p.P_ID=o.P_ID join 
rating as r on r.Or_ID=o.Or_ID group by p.P_Name order by Average_Rating desc limit 1 ) as high_rate
union select * from 
(select p.P_Name, round(avg(r.Prod_Rating),1) as Average_Rating from product as p join orders as o on p.P_ID=o.P_ID join 
rating as r on r.Or_ID=o.Or_ID group by p.P_Name order by Average_Rating asc limit 1 ) as low_rate; 
 
#     Calculate the average delivery rating for each delivery partner and find top 20. 
select d.DP_Name,round(avg(r.Delivery_Service_Rating),1) as Avg_Rating from rating as r join orders as o 
on o.Or_ID=r.Or_ID join delivery as d on d.DP_ID=o.DP_ID group by d.DP_Name order by Avg_Rating desc limit 20; 

#     Find customers who rated both products and delivery partners below 3.
select c.C_Name,round(avg(r.Prod_Rating),1) as Product_Rating,round(avg(r.Delivery_Service_Rating),1) as Service_Rating
from customer as c join orders as o on c.C_ID=o.C_ID join rating as r on r.Or_ID=o.Or_ID
group by c.C_Name having Service_Rating<=3 and Product_Rating<3 order by Product_Rating desc ,Service_Rating desc;

#     Identify the top 20 products with the most ratings and their average sales. 
select p.P_Name,round(avg(r.Prod_Rating),1) as Product_Rating,round(avg(p.Price*o.Qty),2) as Avg_Sales 
from product as p join orders as o on p.P_ID=o.P_ID join rating as r on r.Or_ID=o.Or_ID 
group by p.P_Name order by Product_Rating desc limit 20;

#     Calculate the combined average product and delivery rating for each product ordered.
select p.P_Name,round(avg(r.Prod_Rating),1) as Product_Rating,round(avg(r.Delivery_Service_Rating),1) as Service_Rating
from product as p join orders as o on p.P_ID=o.P_ID join rating as r on r.Or_ID=o.Or_ID
group by p.P_Name order by Product_Rating desc;


#6. Subscription Analysis
#     Find the most popular subscription plan based on the number of active customers. 
select sp.Plan_Name,sp.Features,count(c.C_ID) as Total_Customers from customer as c join subscription_details as sd 
on c.C_ID=sd.C_ID join subscription_plan as sp on sp.Plan_ID=sd.Plan_ID where sd.To_Date >= DATE_SUB(CURDATE(), INTERVAL 30 DAY)
group by sp.Plan_Name,sp.Features order by count(c.C_ID) desc;

#     Identify customers with expired subscriptions who placed orders in the last month. 
select c.C_Name,datediff(sd.To_Date,sd.From_Date) as Duration from customer as c join subscription_details as sd 
on c.C_ID=sd.C_ID join subscription_plan as sp on sp.Plan_ID=sd.Plan_ID join orders as o on o.C_ID=c.C_ID
where year(sd.To_Date)<2025 and (year(o.Order_Date)=2024 and month(o.Order_Date)=12 )
group by c.C_Name ,Duration order by Duration desc ;

#     Calculate the total revenue generated from subscription plans (if revenue is defined per plan) along with customer count. 
select sp.Plan_Name,sp.Features,sp.Plan_Price ,count(c.C_ID) as Total_Customers , sp.Plan_Price*count(c.C_ID) as Total_Revenue
from customer as c join subscription_details as sd on c.C_ID=sd.C_ID join subscription_plan as sp on sp.Plan_ID=sd.Plan_ID
group by sp.Plan_Name,sp.Features,sp.Plan_Price ;

#     List top 20 customers with multiple subscriptions and their monthly duration .
select c.C_Name,sp.Plan_Name,round(datediff(sd.To_Date,sd.From_Date)/30) as Monthly_Durations from customer as c join subscription_details
as sd on c.C_ID=sd.C_ID join subscription_plan as sp on sp.Plan_ID=sd.Plan_ID  group by  c.C_Name,sp.Plan_Name,Monthly_Durations
having count(sd.SD_ID)>1 order by Monthly_Durations desc limit 20;

#     List top 50 customers with multiple subscriptions and their lowest total spending.
select c.C_Name,sp.Plan_Name,Plan_Price*round(datediff(sd.To_Date,sd.From_Date)/30) as Monthly_Spending 
from customer as c join subscription_details as sd on c.C_ID=sd.C_ID 
join subscription_plan as sp on sp.Plan_ID=sd.Plan_ID  
group by  c.C_Name,sp.Plan_Name,Monthly_Spending
having count(sd.SD_ID)>1 order by Monthly_Spending asc limit 50;


#7. Returns/Refund Analysis
#     Find the return/refund rate for each product category.
select p.Category,round(count(rr.RT_ID)/count(o.Or_ID)*100,2) as 'Return/Refund Rate'  from product as p join orders as o on
p.P_ID=o.P_ID left join return_refund as rr on rr.Or_ID=o.Or_ID group by p.Category; 

#     Identify the most common reasons for returns/refunds. 
select r.Reason,r.Return_Refund,count(o.Or_ID) as  Reason_Count from return_refund as r join orders as o on o.Or_ID=r.Or_ID 
group by r.Reason,r.Return_Refund order by r.Return_Refund desc, Reason_Count desc;

#     Calculate the total revenue loss due to returns/refunds.
select p.P_Name,round(sum(p.Price*o.Qty),2) as Revenue_Loss from Orders as o join product as p on p.P_ID=o.P_ID
join return_refund as rr on rr.Or_ID=o.Or_ID group by p.P_Name order by Revenue_Loss desc;

#     List the top 20 customers with the highest number of refunds/returns. 
select c.C_Name,count(rr.Or_ID) as Total_Refund from customer as c join orders as o on c.C_ID=o.C_ID
join return_refund as rr on rr.Or_ID=o.Or_ID group by c.C_Name order by Total_Refund desc limit 20;

#     List the top 20 products with the highest number of refunds/retunns. 
select p.P_Name,count(rr.Or_ID) as Total_Refund from product as p join orders as o on p.P_ID=o.P_ID
join return_refund as rr on rr.Or_ID=o.Or_ID group by p.P_Name order by Total_Refund desc limit 20;

#     Identify the delivery partners associated with the most refunds/returns.
select d.DP_Name,count(o.Or_ID) as Refund_Count from delivery as d join orders as o 
on d.DP_ID=o.DP_ID join return_refund as rr on rr.Or_ID=o.Or_ID group by d.DP_Name order by Refund_Count desc;


#8. Advanced Cross-Table Insights
#     Identify the delivery partners with the highest-rated service deliveries service for orders involving coupons. 
select d.DP_Name,round(avg(r.Delivery_Service_Rating),1) as Service_Rating from delivery as d join orders as o
on o.DP_ID=d.DP_ID join rating as r on r.Or_ID=o.Or_ID where not o.Coupon='No Coupon' group by d.DP_Name
order by Service_Rating desc;

#     Calculate the total spent  by customers with active subscriptions. 
select c.C_Name,round(sum(p.Price*o.Qty),2) as Total_Spent from customer as c join orders as o on c.C_ID=o.C_ID
join product as p on p.P_ID=o.P_ID join subscription_details as sd on sd.C_ID=c.C_ID where year(sd.To_Date)>2024
group by c.C_Name order by Total_Spent desc;

#     Find top 50 customers who placed orders in multiple product. 
select c.C_Name,count(distinct(p.P_Name)) as Total_Product from product as p join orders as o on o.P_ID=p.P_ID
join customer as c on c.C_ID=o.C_ID group by c.C_Name order by Total_Product desc limit 50;

#     Calculate the total revenue loss for refunded orders for products with low ratings (<3).
select p.P_Name,round(sum(p.Price*o.Qty),2) as Revenue_Loss , round(avg(r.Prod_Rating),1) as Ratings
from product as p join orders as o on p.P_ID=o.P_ID join rating as r on r.Or_ID=o.Or_ID join return_refund
as rr on rr.Or_ID=o.Or_ID group by p.P_Name having Ratings<3 order by Revenue_Loss desc;

#     Identify top 30 customers with the highest total spending across all orders, subscriptions, and refunds.
select Total_Spending.C_Name, 
round(Total_Spending.total_order,2) as Total_Spending,
Total_Subscription.total_subscription as Total_Subscription ,
round(ifnull(Total_Return.total_refund ,0),2) as Total_Refund,
(round(Total_Spending.total_order,2) + Total_Subscription.total_subscription - round(ifnull(Total_Return.total_refund ,0),2) ) as Total_Amount
from
(select c.C_Name,sum(p.Price*o.Qty) as total_order  from customer as c join orders as o 
on o.C_ID=c.C_ID join product as p on p.P_ID=o.P_ID group by c.C_Name) as Total_Spending 
join 
(select c.C_Name,sum(sp.Plan_Price*round(datediff(sd.To_Date,sd.From_Date)/30)) as total_subscription 
from subscription_plan as sp join subscription_details as sd on sp.Plan_ID=sd.Plan_ID 
join customer as c on c.C_ID=sd.C_ID group by c.C_Name) as Total_Subscription on 
Total_Spending.C_Name=Total_Subscription.C_Name 
left join 
(select c.C_Name,sum(p.Price*o.Qty) as total_refund from customer as c join orders as o on o.C_ID=c.C_ID 
join product as p on p.P_ID=o.P_ID join return_refund as rr on
rr.Or_ID=o.Or_ID group by c.C_Name ) as Total_Return on Total_Spending.C_Name=Total_Return.C_Name 
order by Total_Amount desc limit 30;
#sum(p.Price*o.Qty) as Refunds from  customer as c join orders as o on o.C_ID=c.C_ID  


/*Select tables  based on KPI set in Power BI*/
# 1. Sales Dashboard
select round(sum(p.Price*o.Qty),2) as Overall_Sales,count(distinct o.C_ID) as Overall_Customers, count(o.Or_ID) as Total_Orders
from product as p right join orders as o on o.P_ID=p.P_ID ;
select c.state,round(sum(p.Price*o.Qty),2) as Overall_Sales from product as p  join orders 
as o on o.P_ID=p.P_ID join customer as c on c.C_ID=o.C_ID group by c.state order by Overall_Sales desc; 
select c.city,round(sum(p.Price*o.Qty),2) as Overall_Sales from product as p  join orders 
as o on o.P_ID=p.P_ID join customer as c on c.C_ID=o.C_ID group by c.city order by Overall_Sales desc;
select year(Order_Date) as Year,monthname(Order_Date) as Month, round(sum(p.Price*o.Qty),2) as Overall_Sales 
from product as p  join orders as o on o.P_ID=p.P_ID group by year(Order_Date),monthname(Order_Date) order by Year asc ,Overall_Sales desc;
select p.P_Name,round(sum(p.Price*o.Qty),2) as Overall_Sales from product as p  join orders 
as o on o.P_ID=p.P_ID join customer as c on c.C_ID=o.C_ID group by p.P_Name order by Overall_Sales desc;
select p.Category,round(sum(p.Price*o.Qty),2) as Overall_Sales from product as p  join orders 
as o on o.P_ID=p.P_ID join customer as c on c.C_ID=o.C_ID group by p.Category order by Overall_Sales desc;

# 2. Customer Dashboard
select round(avg(c.Age)) as Average_Age, count(distinct o.C_ID) as Overall_Customers, 
count(o.Or_ID)-count(distinct o.C_ID) as Repeated_Customer , round(avg(p.Price*o.Qty),2) as Avg_Spending
from customer as c right join orders as o on o.C_ID=c.C_ID left join product as p on p.P_ID=o.P_ID;
select c.state,count(distinct o.Or_ID) as Total_Customer from orders 
as o join customer as c on c.C_ID=o.C_ID group by c.state order by Total_Customer desc; 
select c.city,count(distinct o.Or_ID) as Total_Customer from  orders as o join customer
 as c on c.C_ID=o.C_ID group by c.city order by Total_Customer desc; 
select c.gender,count(distinct o.Or_ID) as Total_Customer from  orders as o join customer
 as c on c.C_ID=o.C_ID group by c.gender order by Total_Customer desc; 
select t.Transaction_Mode,count(distinct o.Or_ID) as Total_Customer from orders as o join transactions
 as t on t.Or_ID=o.Or_ID group by t.Transaction_Mode order by Total_Customer desc; 
select year(Order_Date) as Year,monthname(Order_Date) as Month,  count(distinct o.Or_ID) as Total_Customer
from product as p  join orders as o on o.P_ID=p.P_ID group by year(Order_Date),monthname(Order_Date) 
order by Year asc ,Total_Customer desc;

# 3. Product & Sales Dashboard
select count(o.P_ID) as Total_Product, count(p.P_ID) as Total_Ordered , count(distinct o.P_ID) as Unique_Product_Ordered,
sum(o.Qty) as Total_Quantity_Sold , round(sum(p.Price*o.Qty)/count(o.Or_ID),3) as Average_Order_Value from 
product as p right join orders as o on p.P_ID=o.P_ID ; 
select count(distinct rr.Or_ID)/count(o.Or_ID)*100 as Percent_Return 
from orders as o left join return_refund as rr on rr.Or_ID=o.Or_ID; 
select round(avg(r.Prod_Rating),2) as Prod_rating, round(avg(r.Delivery_Service_Rating),2) as Delivery_Service_Rating
from rating as r; 
with Monthly_Sales as (select date_format(o.Order_Date,'%Y-%M') as Months,t.Transaction_Mode as Transaction_Mode ,
 round(sum(o.Qty*p.Price),2) as total_sales from orders as o join product as p on p.P_ID=o.P_ID join transactions as t 
 on t.Or_ID=o.Or_ID group by Months,Transaction_Mode order by Months Desc) , Monthly_Growth as 
 (select Months, Transaction_Mode, total_sales, LAG(total_sales) OVER (ORDER BY Months) AS prev_month_sales FROM monthly_sales) 
 select Months,Transaction_Mode , total_sales, round((total_sales- prev_month_sales)/prev_month_sales*100,2) 
 as 'MOM %' from Monthly_Growth order by month(Months) asc ;
with Quarterly_Sales as ( select CONCAT(YEAR(o.Order_Date), '-Q', QUARTER(o.Order_Date)) AS Quarters,t.Transaction_Mode,
ROUND(SUM(o.Qty * p.Price), 2) AS total_sales FROM  orders AS o JOIN  product AS p ON p.P_ID = o.P_ID JOIN 
transactions AS t ON t.Or_ID = o.Or_ID GROUP BY Quarters, t.Transaction_Mode ORDER BY Quarters DESC), 
Quarterly_Growth AS ( SELECT Quarters, Transaction_Mode, total_sales, 
LAG(total_sales) OVER (ORDER BY Quarters) AS prev_quarter_sales FROM Quarterly_Sales )
SELECT Quarters,Transaction_Mode, total_sales, ROUND((total_sales - prev_quarter_sales) / prev_quarter_sales * 100, 2) AS 'QoQ %'
FROM  Quarterly_Growth ORDER BY Quarters ASC;
select p.P_Name,count(o.Or_ID) as Total_Customer from product as p join 
orders as o on o.P_ID=p.P_ID group by p.P_Name order by Total_Customer desc limit 10;
select p.Category,count(o.Or_ID) as Total_Customer from product as p join 
orders as o on o.P_ID=p.P_ID group by p.Category order by Total_Customer desc;
select p.P_Name,round(avg(r.Prod_Rating),1) as Product_Rating from product as p join 
orders as o on o.P_ID=p.P_ID join rating as r on r.Or_ID=o.Or_ID
group by p.P_Name order by Product_Rating desc limit 10;

# 4. Subscription Dashboard
select sum(sp.Plan_Price*round(datediff(sd.To_Date,sd.From_Date)/30)) as Total_Subscription_Amount,
round(avg(datediff(sd.To_Date,sd.From_Date)/30),2) as Avg_Monthly_Subscription, count(distinct sd.C_ID) as Total_Customer,
round(count(distinct sd.C_ID)/count(all c.C_ID),2)* 100 as Percent_Subscription_Count
from customer as c  join subscription_details as sd on c.C_ID=sd.C_ID 
join subscription_plan as sp on sp.Plan_ID=sd.Plan_ID  ;
select count(distinct sd.C_ID) as Active_Cust_Subs 
from  subscription_details as sd join customer as c 
on c.C_ID=sd.C_ID where sd.To_Date >= date_sub(curdate(), INTERVAL 30 DAY);
select round(count(case when sd.To_Date >= current_date() then 1 end)/count(all sd.C_ID)*100,2) as Customer_Retention_Rate
from   subscription_details as sd ;
select sp.Plan_Name ,count(distinct c.C_ID) as Active_Cust_Subs 
from  subscription_details as sd join customer as c 
on c.C_ID=sd.C_ID join  subscription_plan as sp on sp.Plan_ID=sd.Plan_ID
where sd.To_Date >= date_sub(curdate(), INTERVAL 30 DAY) group by sp.Plan_Name;
select concat('Qtr', quarter(sd.From_Date)) as Quarters ,count(distinct c.C_ID) as Active_Cust_Subs 
from  subscription_details as sd join customer as c 
on c.C_ID=sd.C_ID join  subscription_plan as sp on sp.Plan_ID=sd.Plan_ID
where sd.To_Date >= date_sub(curdate(), INTERVAL 30 DAY) group by Quarters;
select year(sd.From_Date) as Year, monthname(sd.From_Date) as Month,
 sum(sp.Plan_Price*round(datediff(sd.To_Date,sd.From_Date)/30)) as Total_Subscription_Amount
from subscription_details as sd 
join subscription_plan as sp on sp.Plan_ID=sd.Plan_ID group by Year, Month order by year asc,
Total_Subscription_Amount desc ;
select c.C_Name,avg(sp.Plan_Price*round(datediff(sd.To_Date,sd.From_Date)/30)) as Avg_Subscription_Amount
from customer as c  join subscription_details as sd on c.C_ID=sd.C_ID 
 join subscription_plan as sp on sp.Plan_ID=sd.Plan_ID group by  c.C_Name order by 
Avg_Subscription_Amount desc limit 8;
select c.Gender,round( avg(sp.Plan_Price*round(datediff(sd.To_Date,sd.From_Date)/30)),2) as Avg_Subscription_Amount
from customer as c  join subscription_details as sd on c.C_ID=sd.C_ID 
 join subscription_plan as sp on sp.Plan_ID=sd.Plan_ID group by  c.Gender order by 
Avg_Subscription_Amount desc;
select c.State,count(sd.SD_ID) as Total_Subscription
from customer as c  join subscription_details as sd on c.C_ID=sd.C_ID 
group by  c.State order by Total_Subscription desc;

# 5. Transaction Dashboard
select count(t.Tr_ID),count(case when t.Tran_Status='Successful' then 1 end ) as Successful_Transaction,
count(case when t.Tran_Status='Successful' then 1 end )/count(t.Tr_ID)*100 as Percent_Success
from transactions as t ;
select round(sum(p.Price*o.Qty),2) as Total_Successful_Transaction_Amount
from transactions as t join orders as o on o.Or_ID=t.Or_ID join product as p 
on p.P_ID=o.P_ID  where t.Tran_Status='Successful' ;
select p.P_Name, sum(o.Qty)/count(all t.Tr_ID) as Avg_Product_per_Transaction from product as p right join orders as o on 
o.P_ID=p.P_ID left join transactions as t on t.Or_ID=o.Or_ID group by p.P_Name order by  Avg_Product_per_Transaction desc
limit 10;
select year(Order_Date) as Year,monthname(Order_Date) as Month ,round(avg(p.Price*o.Qty),2) as Average_Successful_Transaction_Amount
from transactions as t join orders as o on o.Or_ID=t.Or_ID join product as p 
on p.P_ID=o.P_ID  where t.Tran_Status='Successful' group by Year,Month order by Year asc ,
Average_Successful_Transaction_Amount desc;
select Transaction_Mode, count(Tr_ID) Total_Transactions from Transactions group by Transaction_Mode order by  Total_Transactions desc ;
select Tran_Status, count(Tr_ID) Total_Transactions from Transactions group by Tran_Status;
select c.City,count(case when t.Tran_Status='Successful' then 1 end ) as Successful_Transaction
from transactions as t join orders as o on o.Or_ID=t.Or_ID join customer as c on c.C_ID=o.C_ID  
group by c.City order by Successful_Transaction desc;

# 6. Return/REfund Dashboard
select count(RT_ID) as Total_Return_Refund, count(case when return_refund='Return' then 1 end ) as Total_Return,
count(case when return_refund='Return' then 1 end )/count(RT_ID)*100 as Return_Rate from return_Refund;
select round(sum(p.Price*o.Qty),2 ) as Loss_due_to_Return_Refund ,
round(sum(p.Price*o.Qty)/(select sum( p.Price*o.Qty) from product as p  join orders as o on o.P_ID=p.P_ID)*100,2) as 
Percent_Loss_due_to_Return_Refund from product as p left join orders as o on o.P_ID=p.P_ID right join
return_refund as rr on rr.Or_ID=o.OR_ID;
select return_refund,count(RT_ID) as total_return_Refund from return_Refund group by return_refund;
select c.gender,count(rr.RT_ID) as total_return_Refund from return_Refund as rr join orders as o on
o.Or_ID=rr.Or_ID join customer as c on c.C_ID=o.C_ID group by c.gender;
select return_refund,reason,count(RT_ID) as total_return_Refund from return_Refund 
group by return_refund,reason order by return_refund desc;
select year(rr.R_Date) as Year,monthname(rr.R_Date) as Month,round(sum(p.Price*o.Qty),2 ) as Loss_due_to_Return_Refund 
 from product as p  join orders as o on o.P_ID=p.P_ID  join return_refund as rr on rr.Or_ID=o.OR_ID 
group by Year,Month  order by Year asc, Loss_due_to_Return_Refund desc;
select rr.return_refund,round(sum(p.Price*o.Qty),2 ) as Loss_due_to_Return_Refund 
 from product as p  join orders as o on o.P_ID=p.P_ID  join return_refund as rr on rr.Or_ID=o.OR_ID 
group by rr.return_refund order by Loss_due_to_Return_Refund desc;
select p.P_Name,count(rr.RT_ID) as Product_Return 
 from product as p  join orders as o on o.P_ID=p.P_ID  join return_refund as rr on rr.Or_ID=o.OR_ID 
group by p.P_Name order by Product_Return desc limit 10; 
select p.Category,count(rr.RT_ID) as Product_Return 
 from product as p  join orders as o on o.P_ID=p.P_ID  join return_refund as rr on rr.Or_ID=o.OR_ID 
group by p.Category order by Product_Return desc limit 10; 


