﻿--------------------------------------------------------------------
/*
(Window Function) دوره آموزشی کوئری‌نویسی پیشرفته 
Site:        http://www.NikAmooz.com
Email:       Info@NikAmooz.com
Instagram:   https://instagram.com/nikamooz/
Telegram:	 https://telegram.me/nikamooz
Created By:  Mehdi Shishebory 
*/
--------------------------------------------------------------------

USE WF;
GO

/*
تمرین کلاسی
کوئری‌ای بنویسید که مجموع مبلغ سفارشات هر مشتری به‌همراه
.مجموع مبلغ تمامی سفارشات ثبت شده را در خروجی نمایش دهد

VIEW: Sales.OrderValues

orderid  custid   val    Cust_Total	  Grand_Total   
-------  ------  ------  ----------	 ------------   
10643      1     814.50    4273.00	  1265793.22   
10692      1     878.00    4273.00	  1265793.22   
10702      1     330.00    4273.00	  1265793.22   
10835      1     845.80    4273.00	  1265793.22   
10952      1     471.20    4273.00	  1265793.22   
11011      1     933.50    4273.00	  1265793.22   
...	      	        	  			 		  	    
10906      91    427.50    3531.95	  1265793.22   
10870      91    160.00    3531.95	  1265793.22   
10998      91    686.00    3531.95	  1265793.22   
11044      91    591.60    3531.95	  1265793.22   
10611      91    808.00    3531.95	  1265793.22   
10792      91    399.85    3531.95	  1265793.22   
10374      91    459.00    3531.95	  1265793.22   

(830 rows affected)
*/

-- !!!قابل نوشتن نیست GROUP BY کوئری موردنظر با استفاده از
SELECT
	orderid, custid, val,
	SUM(val) AS Cust_Total
FROM Sales.OrderValues AS O1
GROUP BY orderid, custid, val;
GO

-- Table Expression نوشتن کوئری موردنظر با استفاده از
WITH C1
AS
(
	SELECT
		SUM(val) AS Grand_Total
	FROM Sales.OrderValues -- مجموع مبلغ تمامی سفارشات
),
C2
AS
(
	SELECT
		custid,
		SUM(val) AS Cust_Total
	FROM Sales.OrderValues
	GROUP BY custid -- مجموع مبلغ سفارشات هر مشتری
)
SELECT
	orderid, custid, val,
	(SELECT C2.Cust_Total FROM C2
		WHERE C2.custid = O.custid) AS Cust_Total,
	(SELECT Grand_Total FROM C1) AS Grand_Total
FROM Sales.OrderValues AS O
ORDER BY O.custid;
GO

-- Subquery نوشتن کوئری موردنظر با استفاده از
SELECT
	O.orderid, O.custid, O.val,
	(SELECT SUM(val) FROM Sales.OrderValues AS O1
		WHERE O1.custid = O.custid) AS Cust_Total,
	(SELECT SUM(val) FROM Sales.OrderValues) AS Grand_Total
FROM Sales.OrderValues AS O
ORDER BY O.custid;
GO

-- WF نوشتن کوئری موردنظر با استفاده از
SELECT
	orderid, custid, val,
	SUM(val) OVER(PARTITION BY custid) AS Cust_Total,-- مجموع مبلغ سفارشات هر مشتری
	SUM(val) OVER() AS Grand_Total-- مجموع مبلغ تمامی سفارشات
FROM Sales.OrderValues;
GO
--------------------------------------------------------------------

-- PARTITION BY فاقد OVER
SELECT
	orderid, custid, empid, val,
	SUM(val) OVER() AS Grand_Total -- .هستند Window تمامی رکوردها در یک
FROM Sales.OrderValues;
GO

-- PARTITION BY به‌همراه عبارت OVER
SELECT
	orderid, custid, empid, val,
	SUM(val) OVER(PARTITION BY custid) AS Cust_Total -- .هستند Window های یکسان در یک custid تمامی
FROM Sales.OrderValues AS O1;
GO

-- بر روی بیش از یک ستون PARTITION BY به‌همراه عبارت OVER
SELECT
	orderid, custid, empid, val,
	SUM(val) OVER(PARTITION BY custid, empid) AS Cust_Emp_Total -- .هستند Window های یکسان در یک empid و custid تمامی
FROM Sales.OrderValues AS O1;
GO
--------------------------------------------------------------------

/*
تمرین کلاسی

:به‌ازای هر مشتری موارد زیر را در خروجی نمایش دهید WF با استفاده از

مجموع مبلغ مقادیر سفارشات هر مشتری
مجموع مبلغ سفارشات تمامی مشتریان
درصد مبلغ هر سفارش مشتری به مجموع مبلغ سفارشات خودش
درصد مبلغ هر سفارش مشتری به مجموع مبلغ سفارشات تمامی مشتریان
 

orderid   custid     val     Cust_Total	  Grand_Total   Prcnt_Cust   Prcnt_All
-------  --------  --------  ----------	 ------------  -----------  ----------
 10643      1       814.50    4273.00	  1265793.22      19.06	       0.06   
 10692      1       878.00    4273.00	  1265793.22      20.55	       0.07   
 10702      1       330.00    4273.00	  1265793.22      7.72	       0.03   
 10835      1       845.80    4273.00	  1265793.22      19.79	       0.07   
 10952      1       471.20    4273.00	  1265793.22      11.03	       0.04   
 11011      1       933.50    4273.00	  1265793.22      21.85	       0.07   
 ...	       	   		     			 		  	   	 		   	   	
 10906      91      427.50    3531.95	  1265793.22      12.10	       0.03   
 10870      91      160.00    3531.95	  1265793.22      4.53	       0.01   
 10998      91      686.00    3531.95	  1265793.22      19.42	       0.05   
 11044      91      591.60    3531.95	  1265793.22      16.75	       0.05   
 10611      91      808.00    3531.95	  1265793.22      22.88	       0.06   
 10792      91      399.85    3531.95	  1265793.22      11.32	       0.03   
 10374      91      459.00    3531.95	  1265793.22      13.00	       0.04   

(830 rows affected)
*/

SELECT
	orderid, custid, val,
	SUM(val) OVER(PARTITION BY custid) AS Cust_Total,
	SUM(val) OVER() AS Grand_Total,
	CAST(100 * val / SUM(val) OVER(PARTITION BY custid) AS NUMERIC(5, 2)) AS Prcnt_Cust,
	CAST(100 * val / SUM(val) OVER() AS NUMERIC(5, 2)) AS Prcnt_All
FROM Sales.OrderValues AS O1;
GO