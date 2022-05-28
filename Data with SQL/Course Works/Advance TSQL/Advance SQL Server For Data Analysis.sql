--1.1 Window Functions

-- This table return YTD values per row ( Business ID ) and refers to highest YTD Sales to give percentage 
-- compare to the highst YTD 

SELECT [BusinessEntityID]
        ,[TerritoryID]
		,[SalesQuota]
		,[Bonus]
		,[CommissionPct]
		,[SalesYTD]
		,[SalesLastYear]
		,[Total YTD Sales] = SUM([SalesYTD]) OVER()
		,[Total % of YTD Sales] = [SalesYTD]/SUM([SalesYTD]) OVER()
		,[Total YTD Sales] = MAX([SalesYTD]) OVER()
		,[% of Best Performer] = [SalesYTD]/MAX([SalesYTD]) OVER()
      FROM [Sales].[SalesPerson]

	 SELECT
	 [ProductID],
	 [OrderQty],
	 [LineTotal] = SUM([LineTotal]) OVER(PARTITION BY [ProductID],[OrderQty])
	 FROM [Sales].[SalesOrderDetail]
	 ORDER BY [ProductID], [OrderQty] DESC


-- Applying different ranking methods
-- Using RANK function we can avoid the same values ranked differently (ties ranked the same)

--Defining Rank Per Sales OrderID, 
SELECT
[SalesOrderID],
[SalesOrderDetailID],
[LineTotal],
RankongWithRowNumber = ROW_NUMBER() OVER(PARTITION BY SalesOrderID ORDER BY [LineTotal] DESC),
RankingWithRank = RANK() OVER(PARTITION BY SalesOrderID ORDER BY [LineTotal] DESC),
RankingWithDense_Rank = DENSE_RANK() OVER(PARTITION BY SalesOrderID ORDER BY [LineTotal] DESC)
FROM Sales.SalesOrderDetail

ORDER BY SalesOrderID


-- Defining RANK Per Product Category 
SELECT 
  ProductName = A.Name,
  A.ListPrice,
  ProductSubcategory = B.Name,
  ProductCategory = C.Name,
  [Price Rank] = ROW_NUMBER() OVER(ORDER BY A.ListPrice DESC),
  [Category Price Rank] = ROW_NUMBER() OVER(PARTITION BY C.Name ORDER BY A.ListPrice DESC),
  [Category Price Rank With Rank] = RANK() OVER(PARTITION BY C.Name ORDER BY A.ListPrice DESC),
  [Category Price Rank With Dense Rank] = DENSE_RANK() OVER(PARTITION BY C.Name ORDER BY A.ListPrice DESC),
  [Top 5 Price In Category] = 
	CASE 
		WHEN DENSE_RANK() OVER(PARTITION BY C.Name ORDER BY A.ListPrice DESC) <= 5 THEN 'Yes'
		ELSE 'No'
	END


  FROM AdventureWorks2019.Production.Product A
  JOIN AdventureWorks2019.Production.ProductSubcategory B
  ON A.ProductSubcategoryID = B.ProductSubcategoryID
  JOIN AdventureWorks2019.Production.ProductCategory C
  ON B.ProductCategoryID = C.ProductCategoryID







-- Using the ROW_NUMBER result as a subquery to select all sales order lines that has rank 1


SELECT 
*
FROM 

(SELECT
[SalesOrderID],
[SalesOrderDetailID],
[LineTotal],
RankongWithRowNumber = ROW_NUMBER() OVER(PARTITION BY SalesOrderID ORDER BY [LineTotal] DESC)
FROM Sales.SalesOrderDetail
) AS A 

WHERE RankongWithRowNumber =1 

--LEAD and LAG

--LEAD & LAG function applied to sales order ID brings back the next/previous sales order total as
--next total due to make it easier to compare order values relative to sequence of sales order 

SELECT 
[SalesOrderID],
[OrderDate],
[CustomerID],
[TotalDue],
[NextTotalDue] = LEAD([TotalDue],1) OVER(ORDER BY [SalesOrderID]),
[PreviousTotalDue] = LAG([TotalDue],1) OVER(ORDER BY [SalesOrderID])
FROM Sales.SalesOrderHeader
ORDER BY [SalesOrderID]




---1.2 LAG & LEAD FUNCTION TO COMPARE WITH WINDOWFUNCTION
-- LAG function to show previous total due from the same vendors for each orderdate
-- LEAD function to show next vendor names processed by each employee 



SELECT 
	   PurchaseOrderID
      ,OrderDate
      ,TotalDue
	  ,VendorName = B.Name
	  ,PrevOrderFromVendorAmt = LAG(A.TotalDue) OVER(PARTITION BY A.VendorID ORDER BY A.OrderDate)
	  ,NextOrderByEmployeeVendor = LEAD(B.Name) OVER(PARTITION BY A.EmployeeID ORDER BY A.OrderDate)

  FROM AdventureWorks2019.Purchasing.PurchaseOrderHeader A
  JOIN AdventureWorks2019.Purchasing.Vendor B
    ON A.VendorID = B.BusinessEntityID

  WHERE YEAR(A.OrderDate) >= 2013
	AND A.TotalDue > 500

  ORDER BY 
  A.EmployeeID,
  A.OrderDate





-- Combining partition by with LEAD & LAG function to group the result by customers

SELECT 
[SalesOrderID],
[OrderDate],
[CustomerID],
[TotalDue],
[NextTotalDue] = LEAD([TotalDue],1) OVER(PARTITION BY [CustomerID] ORDER BY [SalesOrderID]),
[PreviousTotalDue] = LAG([TotalDue],1) OVER(PARTITION BY [CustomerID] ORDER BY [SalesOrderID])
FROM Sales.SalesOrderHeader
ORDER BY [CustomerID], [SalesOrderID]




-- Using DENSE_RANK() with subquery to bring back only resuts that are top 3 total due per vendor 


SELECT
	PurchaseOrderID,
	VendorID,
	OrderDate,
	TaxAmt,
	Freight,
	TotalDue

FROM (
	SELECT 
		PurchaseOrderID,
		VendorID,
		OrderDate,
		TaxAmt,
		Freight,
		TotalDue,
		PurchaseOrderRank = DENSE_RANK() OVER(PARTITION BY VendorID ORDER BY TotalDue DESC)

	FROM AdventureWorks2019.Purchasing.PurchaseOrderHeader
) X

WHERE PurchaseOrderRank <= 3


-- 1.3 Combining WINDOW fuction and subqueries


-- Return MaxRatio column to show percentage of employee vacation time compared to the max vacation hours
-- Using subquery to refine the data to filter out any employees whoes vacation hours are less than 80% of
-- the maximum amount of vacation hours.

SELECT 

[BusinessEntityID],
[JobTitle],
[VacationHours],
[MaxVacationHours] = MAX([VacationHours]) OVER(PARTITION BY [BusinessEntityID] ORDER BY [VacationHours]),
[Maxratio] = (MAX([VacationHours]) OVER(PARTITION BY [BusinessEntityID] ORDER BY [VacationHours]))*1.0/
(SELECT MAX([VacationHours]) FROM AdventureWorks2019.HumanResources.Employee)
FROM 
AdventureWorks2019.HumanResources.Employee

WHERE 
0.8 < (SELECT MAX([VacationHours]) OVER(PARTITION BY [BusinessEntityID] ORDER BY [VacationHours]))*1.0/
(SELECT MAX([VacationHours]) FROM AdventureWorks2019.HumanResources.Employee)

-- 1.4 Correlated subqueries



-- Using Correlated Subqueries to return count of purchase record that has not been rejected
-- Using Correlated Subqueries to return the max unit price for a given purchase order ID 


SELECT 
PurchaseOrderID,
VendorID,
OrderDate,
TotalDue,
MostExpensiveItem = 

(SELECT 
MAX(B.UnitPrice) 
FROM Purchasing.PurchaseOrderDetail B 
WHERE
A.PurchaseOrderID = B.PurchaseOrderID 
) ,

NonRejectedItems = 
(
SELECT 
COUNT(*)
FROM 
Purchasing.PurchaseOrderDetail B
WHERE
A.PurchaseOrderID = B.PurchaseOrderID 
AND 
B.RejectedQty = 0
)

FROM Purchasing.PurchaseOrderHeader A


-- 1.5 Using Exist to reference another table without a join  

SELECT 

A.[SalesorderID]
,A.[OrderDate]
,A.[TotalDue]

FROM [Sales].[SalesOrderHeader] A

WHERE EXISTS (
SELECT
1
FROM [Sales].[SalesOrderDetail] B
WHERE B.LineTotal > 10000
AND A.[SalesOrderID]=B.[SalesOrderID]

)

ORDER BY 1 


 
--Getting a list value for One to Many relationship 
--Using FOR XML PATH With Stuff 

SELECT

SalesorderID,
OrderDate,
TaxAmt,
Freight,
TotalDue,
LineTotals = 
STUFF( 

    ( 
	SELECT 
	','+ CAST(CAST(LineTotal AS MONEY) AS VARCHAR) 
	FROM Sales.SalesOrderDetail B
	WHERE A.SalesorderID = B.SalesOrderID 

	FOR XML PATH('')
	),
	1,1,'')

	FROM Sales.SalesOrderHeader A 



-- 2.1 Pivoting by Product Category Names

SELECT
*

FROM 
(   SELECT ProductCategoryName = D.Name,
	A.LineTotal,
	A.OrderQty
FROM Sales.SalesOrderDetail A
	JOIN Production.Product B
	ON A.ProductID = B.ProductID
	JOIN Production.ProductSubCategory C
	ON B.ProductSubCategoryID = C.ProductSubCategoryID
	JOIN Production.ProductCategory D
	ON C.ProductCategoryID = D.ProductCategoryID

) A

PIVOT

( 
SUM(LineTotal)
FOR ProductCategoryName IN([Bikes],[Clothing],[Accessories],[Components]) 
)B 


-- Using subqueries to return Sun of Top 10 orders per month and compare each monthly top 10 sum 
-- with previous month of top 10 sum
-- Problem is approached both using subqueries and CTEs 

-- 2.2  Subquery 


SELECT
A.OrderMonth,
A.Top10Total,
PreviousTop10Total = B.Top10Total

FROM 

(SELECT 

OrderMonth,
Top10Total = SUM(TotalDue)

FROM (

SELECT
OrderDate,
TotalDue,
OrderMonth = DATEFROMPARTS(YEAR(OrderDate),MONTH(OrderDate),1),
OrderRank = ROW_NUMBER() OVER(PARTITION BY DATEFROMPARTS(YEAR(OrderDate),MONTH(OrderDate),1) ORDER BY TotalDue DESC)
FROM Sales.SalesOrderHeader
) X

WHERE OrderRank <= 10

GROUP BY OrderMonth
)
A

LEFT JOIN

(SELECT 

OrderMonth,
Top10Total = SUM(TotalDue)

FROM (

SELECT
OrderDate,
TotalDue,
OrderMonth = DATEFROMPARTS(YEAR(OrderDate),MONTH(OrderDate),1),
OrderRank = ROW_NUMBER() OVER(PARTITION BY DATEFROMPARTS(YEAR(OrderDate),MONTH(OrderDate),1) ORDER BY TotalDue DESC)
FROM Sales.SalesOrderHeader
) X

WHERE OrderRank <= 10

GROUP BY OrderMonth
) B ON A.OrderMonth = DATEADD(MONTH,1,B.OrderMonth)

ORDER BY A.OrderMonth


--2.3  CTE


WITH Sales AS

(
SELECT
OrderDate,
TotalDue,
OrderMonth = DATEFROMPARTS(YEAR(OrderDate),MONTH(OrderDate),1),
OrderRank = ROW_NUMBER() OVER(PARTITION BY DATEFROMPARTS(YEAR(OrderDate),MONTH(OrderDate),1) ORDER BY TotalDue DESC)
FROM Sales.SalesOrderHeader
),

Top10 AS 
(
SELECT 
OrderMonth,
Top10Total = SUM(TotalDue)
FROM Sales
WHERE OrderRank <= 10
GROUP BY OrderMonth
)

SELECT
A.OrderMonth,
A.Top10Total,
PreviousTop10Total = B.Top10Total
FROM Top10 A
LEFT JOIN Top10 B
ON A.OrderMonth=DATEADD(MONTH,1,B.OrderMonth)
ORDER BY A.OrderMonth


--- 2.4 Recursion CTE

--Making a recursion CTE to add on day on a date field

WITH DateSeries AS
(
SELECT CAST('01-01-2022' AS DATE) AS MyDate

UNION ALL

SELECT
DATEADD(DAY,1,MyDate)
FROM DateSeries
WHERE MyDate < CAST('12-31-2022' AS DATE)

)

SELECT 
MyDate
FROM DateSeries
OPTION(MAXRECURSION 365)


--3.1 Creating Temp Tables
--1. Directly SELECT fields and make table with INTO statement
--2. CREATE TABLE then assign the fields then use INSERT INTO (With or without field list) , followed by SELECT 


SELECT
OrderDate,
TotalDue,
OrderMonth = DATEFROMPARTS(YEAR(OrderDate),MONTH(OrderDate),1),
OrderRank = ROW_NUMBER() OVER(PARTITION BY DATEFROMPARTS(YEAR(OrderDate),MONTH(OrderDate),1) ORDER BY TotalDue DESC)

INTO #Sales 
FROM Sales.SalesOrderHeader




CREATE TABLE #Top10Sales
(
OrderMonth DATE,
Top10Total MONEY
)

INSERT INTO #Top10Sales

SELECT 
OrderMonth,
Top10Total = SUM(TotalDue)
FROM #Sales
WHERE OrderRank <= 10
GROUP BY OrderMonth



SELECT
A.OrderMonth,
A.Top10Total,
PreviousTop10Total = B.Top10Total
FROM #Top10Sales A
LEFT JOIN #Top10Sales B
ON A.OrderMonth=DATEADD(MONTH,1,B.OrderMonth)
ORDER BY A.OrderMonth


DROP TABLE #Sales
DROP TABLE #Top10Sales


--3.2 Truncating table to use the same structure of a temporary tables for different data sources 
--Top 10 sales + purchases script

CREATE TABLE #Orders
(
       OrderDate DATE
	  ,OrderMonth DATE
      ,TotalDue MONEY
	  ,OrderRank INT
)



INSERT INTO #Orders
(
       OrderDate
	  ,OrderMonth
      ,TotalDue
	  ,OrderRank
)
SELECT 
       OrderDate
	  ,OrderMonth = DATEFROMPARTS(YEAR(OrderDate),MONTH(OrderDate),1)
      ,TotalDue
	  ,OrderRank = ROW_NUMBER() OVER(PARTITION BY DATEFROMPARTS(YEAR(OrderDate),MONTH(OrderDate),1) ORDER BY TotalDue DESC)

FROM AdventureWorks2019.Sales.SalesOrderHeader



CREATE TABLE #Top10Orders
(
OrderMonth DATE,
OrderType VARCHAR(32),
Top10Total MONEY
)


INSERT INTO #Top10Orders
(
OrderMonth,
OrderType,
Top10Total
)
SELECT
OrderMonth,
OrderType = 'Sales',
Top10Total = SUM(TotalDue)

FROM #Orders
WHERE OrderRank <= 10
GROUP BY OrderMonth


/*Fun part begins here*/

TRUNCATE TABLE #Orders

INSERT INTO #Orders
(
       OrderDate
	  ,OrderMonth
      ,TotalDue
	  ,OrderRank
)
SELECT 
       OrderDate
	  ,OrderMonth = DATEFROMPARTS(YEAR(OrderDate),MONTH(OrderDate),1)
      ,TotalDue
	  ,OrderRank = ROW_NUMBER() OVER(PARTITION BY DATEFROMPARTS(YEAR(OrderDate),MONTH(OrderDate),1) ORDER BY TotalDue DESC)

FROM AdventureWorks2019.Purchasing.PurchaseOrderHeader


INSERT INTO #Top10Orders
(
OrderMonth,
OrderType,
Top10Total
)
SELECT
OrderMonth,
OrderType = 'Purchase',
Top10Total = SUM(TotalDue)

FROM #Orders
WHERE OrderRank <= 10
GROUP BY OrderMonth


SELECT
A.OrderMonth,
A.OrderType,
A.Top10Total,
PrevTop10Total = B.Top10Total

FROM #Top10Orders A
	LEFT JOIN #Top10Orders B
		ON A.OrderMonth = DATEADD(MONTH,1,B.OrderMonth)
			AND A.OrderType = B.OrderType

ORDER BY 3 DESC

DROP TABLE #Orders
DROP TABLE #Top10Orders





--4.1  Optimization
--1.Filter as early as possible
--2.Avoid sevral JOINS in as single SELECT 
--3.use UPDATE statements to populate fields in a temp table, one source table at a time
--4.apply indexes to fields that will used in JOINS 


--Using UPDATE to replace WHERE EXISTS subquery 

--Select all orders with at least one item over 10K, using EXISTS

SELECT
       A.SalesOrderID
      ,A.OrderDate
      ,A.TotalDue

FROM AdventureWorks2019.Sales.SalesOrderHeader A

WHERE EXISTS (
	SELECT
	1
	FROM AdventureWorks2019.Sales.SalesOrderDetail B
	WHERE A.SalesOrderID = B.SalesOrderID
		AND B.LineTotal > 10000
)

ORDER BY 1



--5.) Select all orders with at least one item over 10K, including a line item value, using UPDATE

--Create a table with Sales data, including a field for line total:
CREATE TABLE #Sales
(
SalesOrderID INT,
OrderDate DATE,
TotalDue MONEY,
LineTotal MONEY
)


--Insert sales data to temp table
INSERT INTO #Sales
(
SalesOrderID,
OrderDate,
TotalDue
)

SELECT
SalesOrderID,
OrderDate,
TotalDue

FROM AdventureWorks2019.Sales.SalesOrderHeader


--Update temp table with > 10K line totals

UPDATE A
SET LineTotal = B.LineTotal

FROM #Sales A
	JOIN AdventureWorks2019.Sales.SalesOrderDetail B
		ON A.SalesOrderID = B.SalesOrderID
WHERE B.LineTotal > 10000


--Recreate EXISTS:

SELECT * FROM #Sales WHERE LineTotal IS NOT NULL


--Recreate NOT EXISTS:

SELECT * FROM #Sales WHERE LineTotal IS NULL



SELECT * FROM Sales.SalesOrderDetail


----- Creating a calendar table for lookup 

--Create Table

CREATE TABLE Adventureworks2019.dbo.Calendar
(
DateValue DATE,
DayOfWeekNumber INT,
DayOfWeekName VARCHAR(32),
DayOfMonthNumber INT,
MonthNumber INT,
YearNumber INT,
WeekendFlag TINYINT,
HolidayFlag TINYINT
)


--Insert values manually

INSERT INTO Adventureworks2019.dbo.Calendar
(
DateValue,
DayOfWeekNumber,
DayOfWeekName,
DayOfMonthNumber,
MonthNumber,
YearNumber,
WeekendFlag,
HolidayFlag
)

VALUES
(CAST('01-01-2011' AS DATE),7,'Saturday',1,1,2011,1,1),
(CAST('01-02-2011' AS DATE),1,'Sunday',2,1,2011,1,0)


SELECT * FROM Adventureworks2019.dbo.Calendar


--Truncate manually inserted values


TRUNCATE TABLE Adventureworks2019.dbo.Calendar




--Insert dates to table with recursive CTE

WITH Dates AS
(
SELECT
 CAST('01-01-2011' AS DATE) AS MyDate

UNION ALL

SELECT
DATEADD(DAY, 1, MyDate)
FROM Dates
WHERE MyDate < CAST('12-31-2030' AS DATE)
)

INSERT INTO AdventureWorks2019.dbo.Calendar
(
DateValue
)
SELECT
MyDate

FROM Dates
OPTION (MAXRECURSION 10000)

SELECT * FROM AdventureWorks2019.dbo.Calendar









UPDATE AdventureWorks2019.dbo.Calendar
SET
DayOfWeekNumber = DATEPART(WEEKDAY,DateValue),
DayOfWeekName = FORMAT(DateValue,'dddd'),
DayOfMonthNumber = DAY(DateValue),
MonthNumber = MONTH(DateValue),
YearNumber = YEAR(DateValue)


SELECT * FROM AdventureWorks2019.dbo.Calendar



UPDATE AdventureWorks2019.dbo.Calendar
SET
WeekendFlag = 
	CASE
		WHEN DayOfWeekNumber IN(1,7) THEN 1
		ELSE 0
	END


SELECT * FROM AdventureWorks2019.dbo.Calendar



UPDATE AdventureWorks2019.dbo.Calendar
SET
HolidayFlag =
	CASE
		WHEN DayOfMonthNumber = 1 AND MonthNumber = 1 THEN 1
		ELSE 0
	END


SELECT * FROM AdventureWorks2019.dbo.Calendar


--Use Calendar table in a query


SELECT
A.*

FROM AdventureWorks2019.Sales.SalesOrderHeader A
	JOIN AdventureWorks2019.dbo.Calendar B
		ON A.OrderDate = B.DateValue

WHERE B.WeekendFlag = 1






--- 5. Programming with SQL
--- 5.1 Variable 

--Embedded scalar subquery example

SELECT 
	   ProductID
      ,[Name]
      ,StandardCost
      ,ListPrice
	  ,AvgListPrice = (SELECT AVG(ListPrice) FROM AdventureWorks2019.Production.Product)
	  ,AvgListPriceDiff = ListPrice - (SELECT AVG(ListPrice) FROM AdventureWorks2019.Production.Product)

FROM AdventureWorks2019.Production.Product

WHERE ListPrice > (SELECT AVG(ListPrice) FROM AdventureWorks2019.Production.Product)

ORDER BY ListPrice ASC



--Rewritten with variables:

DECLARE @AvgPrice MONEY = (SELECT AVG(ListPrice) FROM AdventureWorks2019.Production.Product)

SELECT 
	   ProductID
      ,[Name]
      ,StandardCost
      ,ListPrice
	  ,AvgListPrice = @AvgPrice
	  ,AvgListPriceDiff = ListPrice - @AvgPrice

FROM AdventureWorks2019.Production.Product

WHERE ListPrice > @AvgPrice

ORDER BY ListPrice ASC


--Variables for complex date math:

DECLARE @Today DATE = CAST(GETDATE() AS DATE)

SELECT @Today

DECLARE @BOM DATE = DATEFROMPARTS(YEAR(@Today),MONTH(@Today),1)

SELECT @BOM 

DECLARE @PrevEOM DATE = DATEADD(DAY,-1,@BOM)

SELECT @PrevEOM

DECLARE @PrevBOM DATE = DATEADD(MONTH,-1,@BOM)

SELECT @PrevBOM



SELECT
*
FROM AdventureWorks2019.dbo.Calendar
WHERE DateValue BETWEEN @PrevBOM AND @PrevEOM


---5.2 User defined functions
--Code to create user defined function:

CREATE FUNCTION dbo.ufnCurrentDate()

RETURNS DATE

AS

BEGIN

	RETURN CAST(GETDATE() AS DATE)

END


--Query that calls user defined function

SELECT
	   SalesOrderID
      ,OrderDate
      ,DueDate
      ,ShipDate
	  ,Today = dbo.ufnCurrentDate()

FROM AdventureWorks2019.Sales.SalesOrderHeader A

WHERE YEAR(A.OrderDate) = 2011


----5.3 User defined functions with parameters 

--Correlated Subquery Example:

SELECT
	   SalesOrderID
      ,OrderDate
      ,DueDate
      ,ShipDate
	  ,ElapsedBusinessDays = (
		SELECT
		COUNT(*)
		FROM AdventureWorks2019.dbo.Calendar B
		WHERE B.DateValue BETWEEN A.OrderDate AND A.ShipDate
			AND B.WeekendFlag = 0
			AND B.HolidayFlag = 0
	  ) - 1

FROM AdventureWorks2019.Sales.SalesOrderHeader A

WHERE YEAR(A.OrderDate) = 2011



--Rewriting as a fucntion, with variables:

CREATE FUNCTION dbo.ufnElapsedBusinessDays(@StartDate DATE, @EndDate DATE)

RETURNS INT

AS  

BEGIN

	RETURN 
		(
			SELECT
				COUNT(*)
			FROM AdventureWorks2019.dbo.Calendar

			WHERE DateValue BETWEEN @StartDate AND @EndDate
				AND WeekendFlag = 0
				AND HolidayFlag = 0
		)	- 1

END




--Using the function in a query

SELECT
	   SalesOrderID
      ,OrderDate
      ,DueDate
      ,ShipDate
	  ,ElapsedBusinessDays = dbo.ufnElapsedBusinessDays(OrderDate,ShipDate)

FROM AdventureWorks2019.Sales.SalesOrderHeader

WHERE YEAR(OrderDate) = 2011

----5.4 Stored Procedures

--Starter query:

	SELECT
		*
	FROM (
		SELECT 
			ProductName = B.[Name],
			LineTotalSum = SUM(A.LineTotal),
			LineTotalSumRank = DENSE_RANK() OVER(ORDER BY SUM(A.LineTotal) DESC)

		FROM AdventureWorks2019.Sales.SalesOrderDetail A
			JOIN AdventureWorks2019.Production.Product B
				ON A.ProductID = B.ProductID

		GROUP BY
			B.[Name]
		) X

	WHERE LineTotalSumRank <= 10



--Basic (non-dynamic) stored procedure

CREATE PROCEDURE dbo.OrdersReport

AS

BEGIN
	SELECT
		*
	FROM (
		SELECT 
			ProductName = B.[Name],
			LineTotalSum = SUM(A.LineTotal),
			LineTotalSumRank = DENSE_RANK() OVER(ORDER BY SUM(A.LineTotal) DESC)

		FROM AdventureWorks2019.Sales.SalesOrderDetail A
			JOIN AdventureWorks2019.Production.Product B
				ON A.ProductID = B.ProductID

		GROUP BY
			B.[Name]
		) X

	WHERE LineTotalSumRank <= 10
END



--Execute stored procedure

EXEC dbo.OrdersReport





--Modify stored procedure to accept parameter

ALTER PROCEDURE dbo.OrdersReport(@TopN INT)

AS

BEGIN
	SELECT
		*
	FROM (
		SELECT 
			ProductName = B.[Name],
			LineTotalSum = SUM(A.LineTotal),
			LineTotalSumRank = DENSE_RANK() OVER(ORDER BY SUM(A.LineTotal) DESC)

		FROM AdventureWorks2019.Sales.SalesOrderDetail A
			JOIN AdventureWorks2019.Production.Product B
				ON A.ProductID = B.ProductID

		GROUP BY
			B.[Name]
		) X

	WHERE LineTotalSumRank <= @TopN
END



--Execute stored procedure

EXEC dbo.OrdersReport 20


-- 5.5 USING IF Statements to leverage flexibility of stored procedures
--Multiple IF statement example

ALTER PROCEDURE dbo.OrdersReport(@TopN INT, @OrderType INT)

AS

BEGIN

	IF @OrderType = 1
		BEGIN
			SELECT
				*
			FROM (
				SELECT 
					ProductName = B.[Name],
					LineTotalSum = SUM(A.LineTotal),
					LineTotalSumRank = DENSE_RANK() OVER(ORDER BY SUM(A.LineTotal) DESC)

				FROM AdventureWorks2019.Sales.SalesOrderDetail A
					JOIN AdventureWorks2019.Production.Product B
						ON A.ProductID = B.ProductID

				GROUP BY
					B.[Name]
				) X

			WHERE LineTotalSumRank <= @TopN
		END
	IF @OrderType = 2
		BEGIN
				SELECT
					*
				FROM(
					SELECT 
						ProductName = B.[Name],
						LineTotalSum = SUM(A.LineTotal),
						LineTotalSumRank = DENSE_RANK() OVER(ORDER BY SUM(A.LineTotal) DESC)

					FROM AdventureWorks2019.Purchasing.PurchaseOrderDetail A
						JOIN AdventureWorks2019.Production.Product B
							ON A.ProductID = B.ProductID

					GROUP BY
						B.[Name]
					) X

				WHERE LineTotalSumRank <= @TopN
			END

	IF @OrderType = 3
		BEGIN				
			SELECT
				ProductID,
				LineTotal

			INTO #AllOrders

			FROM AdventureWorks2019.Sales.SalesOrderDetail

			INSERT INTO #AllOrders

			SELECT
				ProductID,
				LineTotal

			FROM AdventureWorks2019.Purchasing.PurchaseOrderDetail
					

			SELECT
				*
			FROM (
				SELECT 
					ProductName = B.[Name],
					LineTotalSum = SUM(A.LineTotal),
					LineTotalSumRank = DENSE_RANK() OVER(ORDER BY SUM(A.LineTotal) DESC)

				FROM #AllOrders A
					JOIN AdventureWorks2019.Production.Product B
						ON A.ProductID = B.ProductID

				GROUP BY
					B.[Name]
				) X

			WHERE LineTotalSumRank <= @TopN

			DROP TABLE #AllOrders
		END
END



--Call modified stored procedure


EXEC dbo.OrdersReport 20,1

EXEC dbo.OrdersReport 15,2

EXEC dbo.OrdersReport 25,3


----5.6 Dynamic SQL 

CREATE PROC dbo.DynamicTopN(@TopN INT, @AggFunc VARCHAR(50))

AS

BEGIN
	DECLARE @DynamicSQL VARCHAR(MAX)

	SET @DynamicSQL = 
	'	SELECT
			*
		FROM (
			SELECT 
				ProductName = B.[Name],
				LineTotalSum = ' 

	SET @DynamicSQL = @DynamicSQL + @AggFunc

	SET @DynamicSQL = @DynamicSQL +
	'(A.LineTotal),
				LineTotalSumRank = DENSE_RANK() OVER(ORDER BY '

	SET @DynamicSQL = @DynamicSQL + @AggFunc

	SET @DynamicSQL = @DynamicSQL +
	'(A.LineTotal) DESC)

			FROM AdventureWorks2019.Sales.SalesOrderDetail A
				JOIN AdventureWorks2019.Production.Product B
					ON A.ProductID = B.ProductID

			GROUP BY
				B.[Name]
			) X

		WHERE LineTotalSumRank <= '

	SET @DynamicSQL = @DynamicSQL + CAST(@TopN AS VARCHAR)

	EXEC(@DynamicSQL)

END

