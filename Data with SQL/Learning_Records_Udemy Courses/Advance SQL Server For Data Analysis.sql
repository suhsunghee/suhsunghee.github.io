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


-- Combining WINDOW fuction and subqueries
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

-- Correlated subqueries
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

