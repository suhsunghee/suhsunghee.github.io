------------------------------------- Exploring Data

--GDPCAP table contains GDP per Capita 2020
SELECT * FROM GDPCAP 

--GDP2020 table contains GDP 2020 

SELECT * FROM GDP2020

--Billion table contains the list of Billionaires as of 2021

SELECT * FROM Billion


--------------------------------------------GDP Per Capita and Total GDP Comparison

SELECT 

GDPCAPRANK = ROW_NUMBER() OVER(ORDER BY CAP DESC),
country,
CAP 

FROM GDPCAP 
WHERE  CAP IS NOT NULL



SELECT 

GDPRANK = ROW_NUMBER() OVER(ORDER BY GDP DESC),
country,
GDP

FROM GDP2020




------------------------------------------------- GDP Total Rank with CTE

WITH GDP_Rank AS 
(
SELECT 
GDPRANK = ROW_NUMBER() OVER(ORDER BY GDP DESC),
country,
GDP 

FROM GDP2020 ),

GDP_CAP_Rank AS 
(
SELECT 

GDPCAPRANK = ROW_NUMBER() OVER(ORDER BY CAP DESC),
country,
CAP

FROM GDPCAP )

SELECT

A.country,
GDPCAPRANK,
CAP, 
GDPRANK,
GDP,
GDP_GDPCAP_RATIO = (GDPRANK*0.1)/(GDPCAPRANK *0.1)

FROM GDP_CAP_Rank A
INNER JOIN GDP_Rank B
ON A.country = B.country 



ORDER BY GDP_GDPCAP_RATIO ASC 






-------------------------------------Data Cleaning on mismatching country Name 

--UPDATE Billion
--SET country = 'Korea, Rep.' WHERE country LIKE '%Korea%'
--UPDATE Billion
--SET country = 'Russian Federation' WHERE country LIKE '%Russia%'
--UPDATE Billion
--SET country = 'Egypt, Arab Rep.' WHERE country LIKE '%Egypt%'
--UPDATE Billion
--SET country = 'Hong Kong SAR, China' WHERE country LIKE '%Hong Kong%'
--UPDATE Billion
--SET country = 'Czech Republic' WHERE country LIKE '%Czech%'
--UPDATE Billion
--SET country = 'Slovak Republic' WHERE country LIKE '%Slovak%'
--UPDATE Billion
--SET country = 'Venezuela, RB' WHERE country LIKE '%Venezuela%'
--UPDATE Billion
--SET country = 'Eswatini' WHERE country LIKE '%Eswatini%'
--UPDATE Billion
--SET country = 'United Kingdom' WHERE country LIKE '%guernsey%'
--UPDATE Billion
--SET country = 'Macao SAR, China' WHERE country LIKE '%Macau%'
--UPDATE Billion
--SET country = 'China' WHERE country LIKE '%Taiwan%'

----------------------------------------------------------- GDP & GDP PER CAPITA RATIO TO COMPARE WEALTH OF A COUNTRY VS WEALTH OF POPULATION





WITH GDP_Rank AS 
(
SELECT 
GDPRANK = ROW_NUMBER() OVER(ORDER BY GDP DESC),
country,
GDP 

FROM GDP2020 ),

GDP_CAP_Rank AS 
(
SELECT 

GDPCAPRANK = ROW_NUMBER() OVER(ORDER BY CAP DESC),
country,
CAP

FROM GDPCAP )

SELECT

A.country,
Rank,
name,
networth,
GDPCAPRANK,
CAP, 
GDPRANK,
GDP,
GDP_GDPCAP_RATIO = (GDPRANK*0.1)/(GDPCAPRANK *0.1)

FROM Billion A
INNER JOIN GDP_Rank B
ON A.country = B.country 
INNER JOIN GDP_CAP_Rank C
ON A.country = C.country 

ORDER BY GDPRANK DESC



---------------------------------------------------------------Merging with Billionaire list Data type Varchar to INT
 -- Currently, networth is set to be $ US in Billions, need to convert this in $ US Million, and to INT
 

 -- First strip the 'B' & '$' Characters and assign it in a temporary column

 ALTER TABLE Billion
 ADD networth_M VARCHAR(40) 

 UPDATE Billion
 SET networth_M = (REPLACE(REPLACE(networth, '$',''),'B',''))


 -- Add another column to cast vharchar as int & convert to numeric 


ALTER TABLE Billion
ADD networth_num DECIMAL(10,4)


UPDATE Billion
SET networth_num = CAST (networth_M AS DECIMAL(10,4))*1000
  


SELECT * FROM Billion




  -------------------------------------------------------------- USE CTE TO merge Billionaire list & GDP 
  WITH GDPTABLE AS  (
  SELECT 
  country,
  GDP,
  GDPRANK = RANK() OVER(ORDER BY GDP DESC )  
  FROM GDP2020

  ) 
  SELECT 
 
  B.country,
  COUNT(DISTINCT(name)) AS Billionaire_counts ,
  SUM(networth_num) AS networth,
  SUM(GDP) AS Country_total_GDP, 
  percent_gdp = (SUM(networth_num) / SUM(GDP))
  FROM BILLION B
  
  INNER JOIN GDPTABLE  
  ON B.country = GDPTABLE.country 
  WHERE  GDPRANK >30
  

  GROUP BY B.Country 
  HAVING SUM(GDP) > 0 
  ORDER BY percent_gdp DESC


