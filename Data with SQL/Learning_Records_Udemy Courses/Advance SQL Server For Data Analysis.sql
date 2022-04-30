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

