--SELECT *FROM meat_poultry_egg_inspect;
--Making a backup table 

SELECT * INTO meat_poultry_egg_inspect_backup FROM [dbo].[meat_poultry_egg_inspect]

--Missing values for state column
SELECT est_number,
       company,
	   city,
	   zip,
	   st
FROM [dbo].[meat_poultry_egg_inspect]
WHERE st = ''


--making a backup column before updating st blank values

ALTER TABLE [dbo].[meat_poultry_egg_inspect] 
ADD  st_copy VARCHAR(2)

UPDATE [dbo].[meat_poultry_egg_inspect]
SET st_copy = st 


UPDATE [dbo].[meat_poultry_egg_inspect]
SET st ='NE' 
WHERE est_number = 'V18677A'


UPDATE [dbo].[meat_poultry_egg_inspect]
SET st ='AL' 
WHERE est_number LIKE 'M45319%'

UPDATE [dbo].[meat_poultry_egg_inspect]
SET st ='WI' 
WHERE est_number LIKE 'M263A+P263A%'


-- Listing cities by number of companies
SELECT city,
	   st, 
	   count (*) AS city_count
FROM [dbo].[meat_poultry_egg_inspect]

GROUP BY  city, st
ORDER BY  city_count DESC


--Quality testing on zip column to where it is not 5 digits

SELECT company,
       city,
	   zip,
	   st
FROM [dbo].[meat_poultry_egg_inspect]
WHERE LEN(zip) != 5

-- Grouping and ordering rows with digit counts

SELECT LEN(ZIP) AS length_of_zip_code , COUNT(*) FROM [dbo].[meat_poultry_egg_inspect]
GROUP BY LEN(ZIP)
ORDER BY COUNT(*) 

-- Grouping and ordering zip length by state

SELECT st,
       LEN(ZIP) AS length_of_zip_code,
	   COUNT(*) AS number_of_zip_code_per_length
	   FROM [dbo].[meat_poultry_egg_inspect]
GROUP BY LEN(ZIP),st 
ORDER BY st

-- Counting distinct length of zipcode per state
SELECT st,
LEN(ZIP),
COUNT(DISTINCT(LEN(ZIP))) 
FROM [dbo].[meat_poultry_egg_inspect]
GROUP BY st, LEN(ZIP)
ORDER BY st DESC

--Fixing Zipcode values

ALTER TABLE meat_poultry_egg_inspect ADD zip_copy varchar(5);

UPDATE dbo.meat_poultry_egg_inspect
SET zip_copy = zip;

UPDATE dbo.meat_poultry_egg_inspect
SET zip = '00'+ zip
WHERE st IN('PR','VI') AND LEN(zip) = 3;


UPDATE dbo.meat_poultry_egg_inspect
SET zip = '0' + zip
WHERE st IN('CT','MA','ME','NH','NJ','RI','VT') AND LEN(zip) = 4;

--Joining Region information from StateRegion table

SELECT * FROM [dbo].[meat_poultry_egg_inspect]
LEFT JOIN StateRegion
ON meat_poultry_egg_inspect.st = StateRegion.st


