--Write an SQL query to find the top 5 customers with the highest total order amounts.
create table dbo.Customer_Table
(
customer_id  int NOT NULL Primary key,
CustomerName char(24) NOT NULL,
Region char(18) NOT NULL,
Order_amount int NOT NULL
)
--------------------------
insert into dbo.Customer_Table(customer_id,CustomerName,Region,Order_amount)
values
(1,'Samarth','Pune',8000),
(2,'Rohan','Solapur',4000),
(3,'Kiran','Mumbai',3000),
(4,'Rupa','Delhi',1500),
(5,'Sayli','Gujrat',900),
(6,'Rohit','Jaipur',500),
(7,'Raj','Kolkatta',300),
(8,'Vaiju','Mumbai',10000),
(9,'Shital','Pune',6000),
(10,'Karn','Satara',2500)
---------------------------
select * from Customer_Table
---------------------------
SELECT Top 5 CustomerName,Order_amount FROM Customer_Table
ORDER BY order_amount DESC

