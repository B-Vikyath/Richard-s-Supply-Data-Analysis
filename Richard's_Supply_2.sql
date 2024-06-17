use supply_chain;

select * from customer;
select * from product;
select * from supplier;
select * from orders;
select * from orderitem;

-- PART C: Business Analysis
-- 1. Fetch the records to display the customer details who ordered more than 10 products in the single order.
select c.id,concat(c.firstname," ",c.lastname) customer_name,oi.orderid,count(oi.productid) No_of_products
from customer c join orders o on c.id=o.customerid
join orderitem oi on o.id=oi.orderid
group by c.id,oi.orderid having No_of_products>10;

select * from customer where id in (select id from 
(select c.id,concat(c.firstname," ",c.lastname) customer_name,oi.orderid,count (oi.productid) No_of_products
from customer c join orders o on c.id=o.customerid
join orderitem oi on o.id=oi.orderid
group by c.id,oi.orderid having No_of_products>10) T);

-- Paula Wilson from USA is the only customer who has ordered more than 10 products in a single order. She has ordered 25 products in a single order.

-- 2. Display the companies which supply products whose cost is above 100.
select s.id,s.companyname,s.contactname,p.productname,p.unitprice 
from supplier s join product p on s.id=p.supplierid
where p.unitprice>100;
-- There are two products 'Thüringer Rostbratwurst','Côte de Blaye' whose unitprice is above 100 and they are supplied by the suppliers
-- 'Martin Bein','Guylène Nodier' respectively.

-- 3.  Company sells the product at different discounted rates. Refer actual product price in product table and selling price in the order item table.
-- Write a query to find out the total amount saved in each order then display the orders from highest to lowest amount saved.
select id,Actual_Amount,Amount_Paid,Actual_Amount-Amount_Paid Savings from
(select o.id,sum(p.unitprice*oi.quantity) Actual_Amount,o.totalamount Amount_Paid
from orders o join orderitem oi on o.id=oi.orderid
join product p on oi.productid=p.id
group by oi.orderid) T where (Actual_Amount-Amount_Paid)!=0 order by Savings desc;
-- Out of 830 orders,discount has been given in 250 orders.The highest discount is given in the order with order id 125 where actual amount is 15353
-- and savings is 3072

-- 4. Mr. Kavin wants to become a supplier. He got the database of "Richard's Supply" for reference. Help him to pick:
-- a. List a few products that he should choose based on demand.
-- b. Who will be the competitors for him for the products suggested in above questions.
select p.id,p.productname,sum(oi.quantity) Total_Quantity_Sold,s.companyname,s.contactname
from supplier s join product p on s.id=p.supplierid
join orderitem oi on p.id=oi.productid
group by oi.productid order by Total_Quantity_Sold desc limit 10;
-- From this table,we will get to know the top 10 products in terms of quantity sold and their respectively supplier and company name.

-- 5. Create a combined list to display customers and suppliers details considering the following criteria
-- ● Both customer and supplier belong to the same country
-- ● Customer who does not have supplier in their country
-- ● Supplier who does not have customer in their country
select country,group_concat(distinct concat(firstname," ",lastname)) CustomerName,group_concat(distinct contactname) SupplierName
from customer join supplier using(country) group by country;
-- There are 12 countries having both customers and suppliers

select c.country,group_concat(distinct concat(c.firstname," ",c.lastname)) CustomerName,group_concat(distinct s.contactname) SupplierName
from customer c left join supplier s on c.country=s.country
group by c.country;
-- The countries-Argentina,Austria,Belgium,Ireland,Mexico,Poland,Portugal,Switzerland,Venezuela have no suppliers but these countries have customers.

select s.country,group_concat(distinct concat(c.firstname," ",c.lastname)) CustomerName,group_concat(distinct s.contactname) SupplierName
from customer c right join supplier s on c.country=s.country
group by s.country;
-- The countries-Australia,Japan,Netherlands,Singapore have suppliers but no customers

-- Every supplier supplies specific products to the customers. Create a view of suppliers and total sales made by their products and write a query 
-- on this view to find out top 2 suppliers (using windows function RANK() in each country by total sales done by the products.
create view supplier_totalsales as
(select s.id,s.companyname,s.contactname,s.country,sum(oi.unitprice*oi.quantity) Total_Sales
from supplier s join product p on s.id=p.supplierid
join orderitem oi on p.id=oi.productid
group by s.id);

select * from supplier_totalsales;

select * from
(select *,rank() over(partition by country order by Total_sales desc) country_wise_ranking from supplier_totalsales) T
where country_wise_ranking<=2;
