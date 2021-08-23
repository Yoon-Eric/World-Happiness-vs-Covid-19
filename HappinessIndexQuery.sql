--SELECT * 
--FROM HappinessQuery..Happiness
--Everything imported correctly, works

--Query out attribute 'life ladder' as happiness index
--for each country and for 2019 (before covid) and 2020 (during covid)

-- 2019 (before covid)
SELECT [Country name], [Life Ladder]
FROM HappinessQuery..Happiness
WHERE [year] like '2019'
order by 2

-- 2020 (during covid)
SELECT [Country name], [Life Ladder]
FROM HappinessQuery..Happiness
WHERE [year] like '2020'
order by 2

--Create two tables, each for 2019 and 2020 for later use
--CREATE TABLE COVID2019 AS (
--	SELECT [Country name] AS Name, [Life Ladder] AS Index
--	FROM HappinessQuery..Happiness
--	WHERE [year] like '2019'
--)
--CREATE TABLE COVID2020 AS (
--	SELECT [Country name] AS Name, [Life Ladder] AS Index
--	FROM HappinessQuery..Happiness
--	WHERE [year] like '2020'
--)

--2020 data has significantly less data, so use left join 2019 on 2020
--then find the change in happiness index 
SELECT C2020.['Name']
FROM HappinessQuery..COVID2020 C2020
LEFT JOIN HappinessQuery..COVID2019 C2019 ON COVID2020.Name = COVID2019.Name