# WORLD LIFE EXPECTANCY PROJECT 

-- New Database creation and activation for the Project 
CREATE DATABASE world_life_expectancy;
USE world_life_expectancy;

-- Import CSV data
SELECT *
FROM world_life_expectancy;

-- Import CSV data as backup 

# DATA CLEANING
-- Identify Duplicates
SELECT country, year, CONCAT(country, year), COUNT(CONCAT(country, year))
FROM world_life_expectancy
GROUP BY country, year, CONCAT(country, year)
HAVING COUNT(CONCAT(country, year)) > 1;
-- A unique tag was created by combining the country and year 
-- Ireland 2022, Senegal 2009, Zimbabwe 2019 were returned with 2 occurrences, duplicates

-- Remove the duplicates form the entire data
-- First, identify the Row IDs of all the duplicate values

SELECT row_id, country, year, CONCAT(country, year),
ROW_NUMBER() OVER(PARTITION BY CONCAT(country, year)) AS row_num
FROM world_life_expectancy;
-- Row_ID field included in our output

SELECT *
FROM (
	SELECT row_id,country, year, CONCAT(country, year),
	ROW_NUMBER() OVER(PARTITION BY CONCAT(country, year)) AS row_num
	FROM world_life_expectancy) AS row_table
WHERE row_num > 1;
-- Duplicates returned with duplicates values and their unique row_id

-- Delete duplicates
DELETE FROM world_life_expectancy
WHERE row_id IN (
	SELECT row_id
	FROM (
	SELECT row_id,country, year, CONCAT(country, year),
	ROW_NUMBER() OVER(PARTITION BY CONCAT(country, year)) AS row_num
	FROM world_life_expectancy) AS row_table
	WHERE row_num > 1);
-- Windows function  used to identify the ID of the duplicate values and
-- SUBQUERY used to filter down the output on the row_id only
-- DELETE FROM deleted the dupllicates from the table;

-- Verify if the duplicates are deleted from the table
SELECT *
FROM (
	SELECT row_id,country, year, CONCAT(country, year),
	ROW_NUMBER() OVER(PARTITION BY CONCAT(country, year)) AS row_num
	FROM world_life_expectancy) AS row_table
WHERE row_num > 1;

SELECT country, year, CONCAT(country, year), COUNT(CONCAT(country, year))
FROM world_life_expectancy
GROUP BY country, year, CONCAT(country, year)
HAVING COUNT(CONCAT(country, year)) > 1;

# Identify missing values within the data 
-- Populate missing values within the status column with existing status
SELECT *
FROM world_life_expectancy
WHERE status = '';

SELECT DISTINCT(status)
FROM world_life_expectancy
WHERE status <> '';
-- Use of DISTINCT to find the unique values of the status column excluding ''
-- We have only two values, 'Developing' and 'Developed'

SELECT DISTINCT(country), status 
FROM world_life_expectancy
WHERE status = 'Developing';
-- Filtering down on unique countries with status 
-- Then we can populate the missing countries statuses using their existing status

-- If 'Afghanistan' has 'Developing' as its existing status, 
-- I want to populate 'Developing' as the missing status of cells with Afghanistan as countries

UPDATE world_life_expectancy table_1
JOIN world_life_expectancy table_2
	ON table_1.country = table_2.country
SET table_1.status = 'Developing'
WHERE table_1.status = ''
AND table_2.status <> ''
AND table_2.status = 'Developing';
-- Countries with existing status 'Developing' populated where there are blanks

-- Verify
SELECT country, status 
FROM world_life_expectancy
WHERE status = '';

UPDATE world_life_expectancy table_1
JOIN world_life_expectancy table_2
	ON table_1.country = table_2.country
SET table_1.status = 'Developed'
WHERE table_1.status = ''
AND table_2.status <> ''
AND table_2.status = 'Developed';
-- Countries with existing status 'Developed' populated where there are blanks

-- Verify if there are no blanks within the status columns
SELECT * 
FROM world_life_expectancy
WHERE status = '';

SELECT * 
FROM world_life_expectancy
WHERE `Life Expectancy` = '';

SELECT * 
FROM world_life_expectancy;

-- Populate the missing values in the `Life Expectancy` using the averages of the years before and after the mising year values
-- Populating using SELF JOIN

SELECT t1.country, t1.year, t1.`Life Expectancy`, t2.country, t2.year, t2.`Life Expectancy`, t3.country, t3.year, t3.`Life Expectancy`
FROM world_life_expectancy t1
JOIN world_life_expectancy t2
	ON t1.country = t2.country
	AND t1.year = t2.year - 1
JOIN world_life_expectancy t3
	ON t1.country = t3.country
	AND t1.year = t3.year + 1;

-- Statistical method to update the missing Life expectancy blanks with avergaes of the neighboring years
SELECT t1.country, t1.year, t1.`Life Expectancy`, 
	t2.country, t2.year, t2.`Life Expectancy`, 
	t3.country, t3.year, t3.`Life Expectancy`,
    ROUND((t2.`Life Expectancy`+ t3.`Life Expectancy`)/2, 1)
FROM world_life_expectancy t1
JOIN world_life_expectancy t2
	ON t1.country = t2.country
	AND t1.year = t2.year - 1
JOIN world_life_expectancy t3
	ON t1.country = t3.country
	AND t1.year = t3.year + 1
WHERE t1.`Life Expectancy` = '';


UPDATE world_life_expectancy t1
JOIN world_life_expectancy t2
	ON t1.country = t2.country
	AND t1.year = t2.year - 1
JOIN world_life_expectancy t3
	ON t1.country = t3.country
	AND t1.year = t3.year + 1
SET t1.`Life Expectancy` = ROUND((t2.`Life Expectancy`+ t3.`Life Expectancy`)/2, 1)
WHERE t1.`Life Expectancy` = '';
-- The `Life Expectancy` missing values have been populated using the averages of the year before and after them through statistical calculations

-- verify
SELECT * 
FROM world_life_expectancy
WHERE `Life Expectancy` = '';

SELECT country
FROM world_life_expectancy
WHERE `Life Expectancy` = 0;

SELECT *
FROM world_life_expectancy
WHERE country = 'Monaco';

# Handling 0 values
-- 0 Life Expecatncy is definitely a data quality issue
-- MySQL treats 0 as a value, functions like like COUNT, AVG treat it is 1
-- For the sake of data validation and accuracy, they are converted to NULLS so they are filtered out in the analysis

UPDATE world_life_expectancy SET `Life Expectancy` = NULL WHERE `Life Expectancy` = 0;

SELECT * 
FROM world_life_expectancy
WHERE `Adult Mortality` = 0;

-- There are lots of 0s in all the columns
-- These are indicators of poor data quality

-- Setting 0s in Adult Mortality to NULL 
-- 0 Adult mortality is impossible
-- The year for these rows is also 2020, covid-19 could disrupt valid data submissions in these countries affected

UPDATE world_life_expectancy SET `Adult Mortality` = NULL WHERE `Adult Mortality` = 0;

SELECT `infant deaths`, count(`infant deaths`)
FROM world_life_expectancy
WHERE `infant deaths` = 0
GROUP BY `infant deaths`;

-- Setting infant deaths at 0 to NULL, it's impossible to have 0 infant deaths
UPDATE world_life_expectancy SET `infant deaths` = NULL WHERE `infant deaths`  = 0;

SELECT * 
FROM world_life_expectancy;	

-- Setting percentage expenditure at 0 to NULL, no country records 0
UPDATE world_life_expectancy SET `percentage expenditure` = NULL WHERE `percentage expenditure`  = 0;

-- Setting measles at 0 to NULL, advanced health care infrastructure can mitigate deaths of infant, it can not prevent it
UPDATE world_life_expectancy SET `Measles` = NULL WHERE `Measles`  = 0;

-- Setting BMI at 0 to NULL, no one weighs 0, physiologically impossible
UPDATE world_life_expectancy SET `BMI` = NULL WHERE `BMI`  = 0;

-- Setting under-five deaths  at 0 to NULL
UPDATE world_life_expectancy SET `under-five deaths` = NULL WHERE `under-five deaths`  = 0;

-- Setting Polio  at 0 to NULL
UPDATE world_life_expectancy SET `Polio` = NULL WHERE `Polio`  = 0;

-- Setting Diphtheria at 0 to NULL
UPDATE world_life_expectancy SET `Diphtheria` = NULL WHERE `Diphtheria`  = 0;

-- Setting HIV/AIDS at 0 to NULL
UPDATE world_life_expectancy SET `HIV/AIDS` = NULL WHERE `HIV/AIDS`  = 0;

-- Setting GDP at 0 to NULL, economically impossible
UPDATE world_life_expectancy SET `GDP` = NULL WHERE `GDP`  = 0;

-- Setting hinness  1-19 years at 0 to NULL
UPDATE world_life_expectancy SET `thinness  1-19 years` = NULL WHERE `thinness  1-19 years`  = 0;

-- Setting thinness 5-9 years at 0 to NULL
UPDATE world_life_expectancy SET `thinness 5-9 years` = NULL WHERE `thinness 5-9 years`  = 0;

-- Setting Schooling at 0 to NULL
UPDATE world_life_expectancy SET `Schooling` = NULL WHERE `Schooling`  = 0;

SELECT * 
FROM world_life_expectancy;










	
