use supply_chain;
show tables;

-- PART A: Explore the data
-- 1.Read the data from all tables.
select * from customer;
select * from product;
select * from supplier;
select * from orders;
select * from orderitem;

-- 2.Find the country wise count of customers.
select country,count(id) No_of_customers from customer group by country order by No_of_customers desc;
-- We see that USA is having maximum number of customers (i.e. 13) while Ireland, Norway and Poland is having only one customer.

-- 3.Display the products which are not discontinued.
select * from product where isdiscontinued=0;
-- We note that out of 78 products,70 products are available and 8 are discontinued.

-- 4.Display the list of companies along with the product name that they are supplying.
select s.companyname,group_concat(p.productname) products 
from supplier s join product p on s.id=p.supplierid
group by s.companyname;

-- 5. Display the price of the costliest item that is ordered by the customer along with the customer details.
select c.id,concat(firstname," ",lastname) customername,max(oi.unitprice) Price_Of_Costliest_Item_Ordered 
from customer c join orders o on c.id=o.customerid
join orderitem oi on o.id=oi.orderid
group by c.id order by price_of_costliest_item_ordered desc;

select id,customername,productname,unitprice from
(select c.id,concat(c.firstname," ",c.lastname) customername,p.productname,oi.unitprice,rank() over(partition by c.id order by oi.unitprice desc) product_price_ranking
from customer c join orders o on c.id=o.customerid
join orderitem oi on o.id=oi.orderid
join product p on oi.productid=p.id) T
where product_price_ranking=1 group by id,productname,unitprice
order by unitprice desc;

-- 6.Display supplier id who owns the highest number of products.
select s.id,s.companyname,s.contactname,count(p.id) No_of_products 
from supplier s join product p on s.id=p.supplierid
group by s.id order by No_of_products desc;
-- Two suppliers Ian devling, Martin Bein with supplier id 7,12 respectively own the highest number of products(i.e. 5) and three 
-- suppliers with supplier id 10,13,27 own the least number of products(i.e. 1)

-- 7. Display month wise and year wise count of the orders placed.
select monthname(orderdate),year(orderdate),count(id) No_of_orders_placed from orders 
group by monthname(orderdate),year(orderdate) order by No_of_orders_placed desc;
-- We observe that with each passing year, the number of orders placed has increased. The highest orders placed is found to be in April and March 2014
-- Both in 2013 and 2012, highest number of orders were placed in the month of December.

-- 8. Which country has maximum suppliers.
select country,count(id) No_of_suppliers from supplier group by country order by No_of_suppliers desc;
-- USA has maximum number of suppliers(i.e. 4) while 7 countries have only one supplier.

-- 9. Which customers did not place any order.
select * from customer where id not in (select customerid from orders);
-- Out of 91 customers, 2 customers one from Spain and one from France did not place any order.

-- PART B: Know the Business
-- 1. Arrange the product id, product name based on high demand by the customer.
select p.id,p.productname,sum(oi.quantity) Total_Quantity_Sold 
from product p join orderitem oi on p.id=oi.productid
group by p.id order by Total_Quantity_Sold desc;
-- The product 'Camembert Pierrot' has been ordered highest number of times by customers with a total order of 1577 while the product
-- 'Mishi Kobe Niku' has been ordered least number of times with total order of 95. 

-- 2. Calculate year-wise total revenue.
select year(orderdate),sum(totalamount) Total_Revenue from orders group by year(orderdate); 

-- 3.Display the customer details whose order amount is maximum including his past orders.
select * from customer where id=(select id from
(select c.id,sum(o.totalamount) Total_Order_Amount
from customer c join orders o on c.id=o.customerid
group by c.id order by Total_Order_Amount desc limit 1) T);
-- Horst Kloss from Germany has placed maximum order including all past orders.

-- 4. Display total amount ordered by each customer from high to low.
select c.id,concat(c.firstname," ",c.lastname) customername,sum(o.TotalAmount) TotalOrders
from customer c join orders o on c.id=o.customerid
group by c.id order by TotalOrders desc;
-- Francisco Chang has placed least total orders.

-- The sales and marketing department of this company wants to find out how frequently customers have business with them.
-- This can be done in two ways.
-- 5. Approach 1. List the current and previous order amount for each customer.
select c.id,concat(c.firstname," ",c.lastname) customer_name,o.totalamount,lag(o.totalamount) over(partition by o.customerid order by date(orderdate)) previous_total
from customer c join orders o on c.id=o.customerid;

-- 6. Approach 2. Display the customerid, order ids and the order dates along with the previous order date and the next order date for every customer 
-- in the table
select c.id customer_id,concat(firstname," ",lastname) customername,o.id order_id,date(o.orderdate) orderdate,
lead(date(o.orderdate)) over(partition by o.customerid order by date(o.orderdate)) next_orderdate
from customer c join orders o on c.id=o.customerid;

-- 7.Find out the top 3 suppliers in terms of revenue generated by their products.
select * from supplier where id in (select id from
(select s.id,sum(oi.unitprice*oi.quantity) Total_Revenue
from supplier s join product p on s.id=p.supplierid
join orderitem oi on p.id=oi.productid
group by s.id order by Total_Revenue desc limit 3) T);
-- Guylène Nodier from France,'Martin Bein' from Germany,'Eliane Noz' from France are top three suppliers in terms of revenue generated by their products.




