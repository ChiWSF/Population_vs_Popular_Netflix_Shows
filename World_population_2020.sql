-- First, look at the world population data set
SELECT
	*
FROM
	Population_and_Netflix_Shows_Comparison.dbo.world_population

-- I only need the worl population of 2020 and the country names

SELECT
	[Country Name],
	[2020]
INTO
	#population_2020
FROM
	Population_and_Netflix_Shows_Comparison.dbo.world_population

-- Check if there's any null values in the table
SELECT
	*
FROM
	dbo.#population_2020
WHERE
	[Country Name] IS NULL OR
	[2020] IS NULL

-- The null vales don't know affect the countries I'm using for my analyse.
-- Calculate the LGBTQ+ population
SELECT
	(SELECT
	CAST(ROUND([2020] * 0.09, 0) AS float)
	FROM dbo.#population_2020
	WHERE [Country Name] = 'World') AS LGBTQ_Plus
FROM
	dbo.#population_2020

-- Then insert the result into the table
INSERT INTO
	dbo.#population_2020 ([Country Name], [2020])
VALUES
	('LGBTQ+', '698545813')

-- Save the temp table as a new table
SELECT *
INTO world_population_2020
FROM dbo.#population_2020

-- Rename column 2020 to population
EXEC sp_rename 'world_population_2020.2020', 'Population', 'COLUMN'
