--Data celaning and manipulation for netflix shows ranking dataset

-- First, I take a look at the table
SELECT
	*
FROM
	Population_and_Netflix_Shows_Comparison.dbo.all_weeks_global

-- I noticed there's null values
SELECT
	*
FROM
	Population_and_Netflix_Shows_Comparison.dbo.all_weeks_global
WHERE
	week IS NULL OR
	category IS NULL OR
	weekly_rank IS NULL OR
	show_title IS NULL OR
	season_title IS NULL OR
	weekly_hours_viewed IS NULL OR
	cumulative_weeks_in_top_10 IS NULL

-- Tuned out the "N/A" only exists in nvarchar data columns and they aren't null values
SELECT
	week,
	category,
	show_title,
	season_title
FROM
	Population_and_Netflix_Shows_Comparison.dbo.all_weeks_global
WHERE
	week = 'N/A' OR
	category = 'N/A' OR
	show_title = 'N/A' OR
	season_title = 'N/A'

-- "N/A" only shows up in "season_title" column when there no season title for a show/film
-- Only the season title for shows is enough for my analyse, so I use CASE to combie them and save as a temp table for further use
SELECT
	CASE season_title
		WHEN 'N/A'
		THEN show_title
		ELSE season_title
		END AS show_title,
	weekly_hours_viewed
INTO
	#cleaned_show_title
FROM
	Population_and_Netflix_Shows_Comparison.dbo.all_weeks_global
WHERE
	category = 'TV (English)'
	OR category = 'TV (Non-English)'
ORDER BY
	weekly_hours_viewed DESC

-- Find the totall most weekly hours viewed TV shows using the temp teble
-- Then save it as another temp table
SELECT
	show_title,
	SUM(weekly_hours_viewed) AS most_weekly_hours_viewed
INTO
	#total_most_weekly_hours_viewed
FROM
	dbo.#cleaned_show_title
GROUP BY
	 show_title
ORDER BY
	most_weekly_hours_viewed DESC

-- Find out the top 100 most weekly hours viwed shows
SELECT
	TOP 100 *
INTO
	#top_100_hours_viewed
FROM
	dbo.#total_most_weekly_hours_viewed
ORDER BY
	most_weekly_hours_viewed DESC

-- Now I have the list of the top 100 shows, I can drop the first two temp tables
DROP TABLE dbo.#cleaned_show_title, dbo.#total_most_weekly_hours_viewed

-- The data set from Netflix doesn't provide the shows' country and demographic, so I look up online and manually and add the into the table
-- First I create two new colums
ALTER TABLE
	dbo.#top_100_hours_viewed
ADD 
	Country nvarchar(255),
	Demographic nvarchar(255);

-- Then used Update to put in the info I found
UPDATE
	dbo.#top_100_hours_viewed
SET
	Country = 'North Korea',
	Demographic = 'Non White lead'
WHERE
	show_title = 'Squid Game: Season 1'

--Data cleaning and manipulation for the world population dataset

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
