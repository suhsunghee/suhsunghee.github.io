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
WHERE GDPRANK < 10 
ORDER BY GDP_GDPCAP_RATIO ASC 




Top 10 GDP Countries and per capita rank comaprison 


----------------------------------------------------------------------------
country	GDPCAPRANK	CAP	GDPRANK	GDP	GDP_GDPCAP_RATIO
China	80	10434.7751874839	2	14722730.6978901	0.02500000000000000
India	182	1927.70782309335	6	2622983.73200645	0.03296703296703296
Japan	28	40193.2524448357	3	5064872.87560459	0.10714285714285714
United States	8	63206.5210767941	1	20936600	0.12500000000000000
United Kingdom	27	41059.1688090547	5	2707743.77717391	0.18518518518518518
Germany	20	46252.6893044892	4	3806060.14012452	0.20000000000000000
Italy	36	31769.9658684833	8	1886445.26834071	0.22222222222222222
France	30	39037.1226309074	7	2603004.39590195	0.23333333333333333
Canada	25	43258.2638715602	9	1643407.97706893	0.36000000000000000




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
  

  GROUP BY B.Country 
  HAVING SUM(GDP) > 0  AND perccent_gdp > 1 
  ORDER BY percent_gdp DESC



--Billionaires with more networth than country GDP 
--------------------------------------------------------------------
percent_gdp
country	Billionaire_counts	networth	Country_total_GDP	percent_gdp
Belize	1	3600.0000	1763.6961189519	2.04116795479447
St. Kitts&Nevis	1	1500.0000	927.451851851852	1.6173346325256
Eswatini	1	5300.0000	3962.49309299308	1.33754176363665
