--NFL Tables are separated into 3 tables
--1 Stadium data
--2 game data
--4 team data 



--------------------------------------------------------------------------------------------Exploratory Data Analysis 


SELECT * FROM stadiums
SELECT * FROM games
SELECT * FROM teams

SELECT [stadium_name], [stadium_location],[stadium_open],[stadium_close]
INTO stadiums_tp
FROM stadiums


-- Filling in division data with previous division


UPDATE teams
SET [team_division] = [team_division_pre2002] 
WHERE [team_division] IS NULL

SELECT [team_name],[team_division]
INTO teams_tp
FROM teams






--Data type change for numeric columns to apply numeric operators



ALTER TABLE games
ALTER COLUMN [weather_temperature] smallint
ALTER TABLE games
ALTER COLUMN [weather_wind_mph] smallint





-- Create column for the win or loss team

ALTER TABLE games
ADD team_won VARCHAR(100)

UPDATE games
SET [team_won] = [team_home] WHERE [score_home] > [score_away] 
UPDATE games
SET [team_won] = [team_away] WHERE [score_away] > [score_home]
UPDATE games
SET [team_won] = 'TIE' WHERE [score_away]=[score_home]
	

-- Join on stadium name & team for division ( 1. Check the stadium names not in stadium column) 


--1.Check stadium name mismatch between stadiums & games 

SELECT DISTINCT [stadium] FROM games WHERE [stadium] NOT IN (SELECT stadium_name FROM stadiums_tp) 





--2.Wildcard search ( To correct the name ) 


SELECT DISTINCT [stadium_name] FROM stadiums


WHERE [stadium_name] LIKE '%Caesars%' OR
      [stadium_name] LIKE '%FedEx%' OR
	  [stadium_name] LIKE '%Fenway%' OR
	  [stadium_name] LIKE '%Highmark%' OR
	  [stadium_name] LIKE '%Legion%' OR
	  [stadium_name] LIKE '%Lumen%' OR
	  [stadium_name] LIKE '%TIAA%' OR
	  [stadium_name] LIKE '%Tottenham%';


--3. Correct the name on Joining field
UPDATE stadiums_tp
SET [stadium_name] ='FedEx Field' WHERE [stadium_name] = 'FedExField' 




--4.Check teams name 
SELECT DISTINCT [team_won] FROM games WHERE [team_won] NOT IN (SELECT team_name FROM teams_tp) 


SELECT 
[schedule_date],
[schedule_season],
[schedule_week],
[schedule_playoff],
[team_home],
[score_home],
[score_away],
[team_away],
[team_favorite_id],
[spread_favorite],
[over_under_line],
[stadium],
[weather_temperature],
[weather_wind_mph],
[weather_humidity],
[team_won],
[stadium_location],
[stadium_open],
[stadium_close],
[team_division]

INTO NFL

FROM games 

LEFT JOIN teams_tp
ON [team_won] = [team_name]
LEFT JOIN stadiums_tp
ON [stadium_name] = [stadium]

