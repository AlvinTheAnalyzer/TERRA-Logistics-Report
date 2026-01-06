/* Purpose: Analyze the data

Alvin Hartridge, Jr.
Created on: August 29,2025

*/


-- Top 5 Highest Selling Products with TotalAmount Sold
SELECT TOP 5
  p.ProductName,
  SUM(o.totalamount) AS total_sales
FROM
  products AS p
JOIN
  orderdetails AS od ON p.productid = od.productid
JOIN
  orders AS o ON od.orderid = o.orderid
GROUP BY
  p.productname
ORDER BY
  total_sales DESC;


  -- Top 10 Highest paying Customers
  SELECT TOP 10
	c.FirstName,
	c.LastName,
	o.TotalAmount AS Total_Sales
  FROM 
	Customers as c
JOIN
	Orders AS o ON c.CustomerID = o.CustomerID
ORDER BY 
	Total_Sales DESC;


-- Orders by Month
/*    
==================================
Using second one, this one returns output as 2024-09
==================================

SELECT
    FORMAT(o.orderdate, 'yyyy-MM') AS order_month_and_year,
    COUNT(o.orderid) AS number_of_orders
FROM
    orders AS o
GROUP BY
    FORMAT(o.orderdate, 'yyyy-MM')
ORDER BY
    order_month_and_year;
*/

SELECT
    DATENAME(MONTH, o.orderdate) + ' ' + CAST(YEAR(o.orderdate) AS VARCHAR) AS order_month_and_year,
    COUNT(o.orderid) AS number_of_orders
FROM
    orders AS o
GROUP BY
    DATENAME(MONTH, o.orderdate),
    YEAR(o.orderdate),
    MONTH(o.orderdate)
ORDER BY
    YEAR(o.orderdate),
    MONTH(o.orderdate);

