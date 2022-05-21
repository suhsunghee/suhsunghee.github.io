-- GDP Data contains country regions as country names
-- Filtering only valid country name using subquery 


SELECT
*
INTO GDP 

FROM GDPHIST
WHERE GDPHIST.[Country Name] IN
(
SELECT ValidCountry FROM Countrylist
)


-- Sorting countries  by 2020 GDP
-- 1.US 2.China 3.Japan 4. Germany 5.United Kingdom 6.India 7.France 8. Italy 9. Canada 10.Korea, Rep.

SELECT [Country Name] FROM GDP
ORDER BY [2020] DESC 


-- GDP Growth rate rank compared 2020 with 1960
-- 1.Botswana (494%) 2. Singapore (481%) 3. Korea, Rep (412%) 4. Hong Kong (261%) 5. China (245%)

SELECT
GDPGrowthRate = ([2020] - [1960])/[1960],
GrowthRank = ROW_NUMBER() OVER (ORDER BY ([2020] - [1960])/[1960] DESC),
[Country Name] FROM GDP 
ORDER BY GDPGROWTHRATE DESC




-- GDP Decrease rate
-- 1. Macao , China : -53%, 2.Libya :-51% 3.Lebanon: -38%  118. United States : -2% 

SELECT 
GDPDecreaseRate  = ([2020] - [2019])/[2019],
[Country Name]
FROM GDP
WHERE [2020] - [2019] < 0 
ORDER BY GDPDecreaseRate ASC


-- Using Subquery to compare GDP between the countries with neighbor rank 
-- Japan (3rd 2020 GDP ) & China (2nd 2020 GDP ) has the biggest percentage gap for countries with neighboring rank
-- China and Japan had a GDP Gap that of 65% of Chinese total GDP 

SELECT 
[Country Name],
[2020],
GDP2020Rank,
NextRankGDP = LEAD([2020],1) OVER(ORDER BY [GDP2020Rank]),
GDPGap = ([2020] - ( LEAD([2020],1) OVER(ORDER BY [GDP2020Rank])))/[2020]
FROM
(

SELECT
[Country Name],
[2020],
GDP2020Rank = ROW_NUMBER() OVER(ORDER BY [2020] DESC)
FROM GDP

) X
ORDER BY GDPGap DESC


--Comparing 1960, 1980, 2000, 2020 GDP Rank per country to see the trend is consistent

SELECT 
GDP2020Rank,
GDP2000Rank,
GDP1980Rank,
GDP1960Rank,
[Country Name],
AverageRank = (GDP2020Rank+GDP2000Rank+GDP1980Rank+GDP1960Rank) /4

FROM 
(

SELECT
GDP2020Rank = ROW_NUMBER() OVER (ORDER BY ([2020]) DESC),
GDP2000Rank = ROW_NUMBER() OVER (ORDER BY ([2000]) DESC),
GDP1980Rank = ROW_NUMBER() OVER (ORDER BY ([1980]) DESC),
GDP1960Rank = ROW_NUMBER() OVER (ORDER BY ([1960]) DESC),
[Country Name] FROM GDP 
) X

ORDER BY AverageRank 

