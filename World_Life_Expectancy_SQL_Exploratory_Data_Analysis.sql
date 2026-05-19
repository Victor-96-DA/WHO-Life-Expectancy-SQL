SELECT * 
FROM world_life_expectancy;

-- Querying the lowest and highest Life Expectancy across each country
SELECT country, MIN(`Life Expectancy`), MAX(`Life Expectancy`)
FROM world_life_expectancy
GROUP BY country
HAVING MIN(`Life Expectancy`) IS NOT NULL 
AND MAX(`Life Expectancy`) IS NOT NULL ;

-- Order of countries by their life expectancy improvement across the years, lowest to the highest
SELECT country, 
MIN(`Life Expectancy`),
MAX(`Life Expectancy`),
ROUND((MAX(`Life Expectancy`) - MIN(`Life Expectancy`)), 1) AS Life_Expectancy_Increase_Over_Years
FROM world_life_expectancy
GROUP BY country
HAVING MIN(`Life Expectancy`) IS NOT NULL 
AND MAX(`Life Expectancy`) IS NOT NULL 
ORDER BY Life_Expectancy_Increase_Over_Years;

-- Order of countries by their life expectancy improvement across the years, highest to lowest
SELECT country, 
MIN(`Life Expectancy`),
MAX(`Life Expectancy`),
ROUND((MAX(`Life Expectancy`) - MIN(`Life Expectancy`)), 1) AS Life_Expectancy_Increase_Over_Years
FROM world_life_expectancy
GROUP BY country
HAVING MIN(`Life Expectancy`) IS NOT NULL 
AND MAX(`Life Expectancy`) IS NOT NULL 
ORDER BY Life_Expectancy_Increase_Over_Years DESC;

-- Top 10 countries that improved the least 
SELECT country, 
MIN(`Life Expectancy`),
MAX(`Life Expectancy`),
ROUND((MAX(`Life Expectancy`) - MIN(`Life Expectancy`)), 1) AS Life_Expectancy_Increase_Over_Years
FROM world_life_expectancy
GROUP BY country
HAVING MIN(`Life Expectancy`) IS NOT NULL 
AND MAX(`Life Expectancy`) IS NOT NULL 
ORDER BY Life_Expectancy_Increase_Over_Years
LIMIT 10;

-- Top 10 countries that improved the most
SELECT country, 
MIN(`Life Expectancy`),
MAX(`Life Expectancy`),
ROUND((MAX(`Life Expectancy`) - MIN(`Life Expectancy`)), 1) AS Life_Expectancy_Increase_Over_Years
FROM world_life_expectancy
GROUP BY country
HAVING MIN(`Life Expectancy`) IS NOT NULL 
AND MAX(`Life Expectancy`) IS NOT NULL 
ORDER BY Life_Expectancy_Increase_Over_Years DESC
LIMIT 10;

-- Digging into the statuses of the top 10 countries that improved the most
SELECT country, 
status,
MIN(`Life Expectancy`),
MAX(`Life Expectancy`),
ROUND((MAX(`Life Expectancy`) - MIN(`Life Expectancy`)), 1) AS Life_Expectancy_Increase_Over_Years
FROM world_life_expectancy
GROUP BY country, status
HAVING MIN(`Life Expectancy`) IS NOT NULL 
AND MAX(`Life Expectancy`) IS NOT NULL 
ORDER BY Life_Expectancy_Increase_Over_Years DESC
LIMIT 10;
# Insights: the top 10 countries that improved their life expectancy the most are 'Developing countries'
# This could suggest improvement in healthcare infrastructure, improvement in economic situations
# These essentially yield gains in life expectancy outcomes

-- Digging into the statuses of the bottom 10 countries that improved the least
SELECT country, 
status,
MIN(`Life Expectancy`),
MAX(`Life Expectancy`),
ROUND((MAX(`Life Expectancy`) - MIN(`Life Expectancy`)), 1) AS Life_Expectancy_Increase_Over_Years
FROM world_life_expectancy
GROUP BY country, status
HAVING MIN(`Life Expectancy`) IS NOT NULL 
AND MAX(`Life Expectancy`) IS NOT NULL 
ORDER BY Life_Expectancy_Increase_Over_Years 
LIMIT 10;
# Insights: The 10 countries that improved the least are developing countries but they already had a relatively fair and good bsae life expectancy (having the minimum as 65 and 78.2 as the maximum) and this suggests less room for growth.

# Countries that recorded stagnant or declined life expectancy
SELECT country,
MAX(CASE WHEN row_num_asc = 1 THEN `Life Expectancy` END) AS first_year_value,
MAX(CASE WHEN row_num_desc = 1 THEN `Life Expectancy` END) AS last_year_value,
ROUND((MAX(CASE WHEN row_num_desc = 1 THEN `Life Expectancy` END) - MAX(CASE WHEN row_num_asc = 1 THEN `Life Expectancy` END)), 1) AS year_diff
FROM (
	SELECT country, year, row_num_asc, row_num_desc, `Life Expectancy`
	FROM (
	SELECT country, year , `Life Expectancy`,
	ROW_NUMBER() OVER(PARTITION BY country ORDER BY year) AS row_num_asc,
	ROW_NUMBER() OVER(PARTITION BY country ORDER BY year DESC) AS row_num_desc
	FROM world_life_expectancy) year_diff
	WHERE row_num_asc = 1 OR row_num_desc = 1) row_table
GROUP BY country
HAVING year_diff <= 0
ORDER BY year_diff DESC;

-- digging into reasons why Brazil recorded a stagnant progress over the study period
SELECT country, SUM(`Adult Mortality`)
FROM world_life_expectancy 
WHERE country = 'Brazil'
GROUP BY country;

SELECT country, SUM(`GDP`)
FROM world_life_expectancy 
WHERE country = 'Brazil'
GROUP BY country
ORDER BY SUM(`GDP`) DESC;


# Insghts
-- 11 countries showed stagnant and declined life expectancy
-- 2 showed stagnant process( Brazil and Somalia at 0); The stagnancy for Somalia could be attached to the conflict, instablity and weak healthcare infrastructure.
-- Why did Brazil record a stagnant life expectancy? An OUTLIER? Brazil,  although has a large economy with a GDP of about 98293, it recorded 2411 Ault Mortality rates over the years 
-- Countries with decline progress seem to be war and conflicts zone, Syria, Lybia, Yemen, Iraq
-- Estonia , Romania (post-soviettransition econmies), Grenada , Paraguay, smaller nations
-- Conclusion: 11 countries showed stagnant or declining life expectancy over the study period. Conflict-affected nations (Syria, Libya, Yemen, Iraq) show the strongest declines, suggesting war is a more significant driver of life expectancy loss than economic or health factors alone.

-- Is there a correlation between GDP and Life Expectancy?
SELECT country, 
ROUND(AVG(`Life Expectancy`), 1) avg_life_exp,
ROUND(AVG(`GDP`), 1) avg_gdp
FROM world_life_expectancy
WHERE `Life Expectancy` IS NOT NULL
AND GDP IS NOT NULL
GROUP BY country
ORDER BY avg_gdp DESC;

SELECT country, 
ROUND(AVG(`Life Expectancy`), 1) avg_life_exp,
ROUND(AVG(`GDP`), 1) avg_gdp
FROM world_life_expectancy
WHERE `Life Expectancy` IS NOT NULL
AND GDP IS NOT NULL
GROUP BY country
ORDER BY avg_gdp;

# Insights
-- High GDP (57K - 10k) - Life Expectancy 70s and 80s
-- Low GDP (137 - 1000) - Life Expectacncy 40s, 50s, 60s
-- Cnnclusion:  strong positive correlation exists between GDP and life expectancy. Countries with average GDP between 10,000 and 58,000 consistently recorded life expectancy in the 70s and 80s, while countries with average GDP between 137 and 365 recorded life expectancy in the 40s to 60s; a difference of roughly 20-30 years of life.

SELECT 
CASE WHEN avg_gdp >= 7951 THEN 'High GDP' 
		WHEN avg_gdp BETWEEN  1500 AND 7950 THEN 'Mid GDP' 
        WHEN avg_gdp < 1500 THEN 'Low GDP' 
        
	END AS gdp_tier,
    ROUND(AVG(avg_life_exp), 1) avg_life,
    COUNT(DISTINCT w1.country) AS country_count
FROM world_life_expectancy w1
JOIN ( 
	SELECT country, 
	ROUND(AVG(`Life Expectancy`), 1) avg_life_exp,
	ROUND(AVG(`GDP`), 1) avg_gdp
	FROM world_life_expectancy
	WHERE `Life Expectancy` IS NOT NULL
	AND GDP IS NOT NULL
	GROUP BY country) w2
ON w1.country = w2.country
GROUP BY gdp_tier;

-- Further classified the country into 3 tiers according to their GDP, I created a threshold using CASE statements
-- Joining avg_gdp subquery back to raw table to avoid averaging an average
-- ensuring statistically sound aggregation of life expectancy by GDP tier

-- Developing vs Developed Life Expectancy Analysis
SELECT status, 
ROUND(AVG(`Life Expectancy`), 1) avg_life_exp,
COUNT(DISTINCT country) count_of_countries
FROM world_life_expectancy
WHERE `Life EXpectancy` IS NOT NULL
AND status IS NOT NULL
GROUP BY status;

# Insights 
-- A 12-year gap between Developed and Developing countries
-- 32 developed countries with an AVG life exp of 79 years vs 151 developing countries with an AVG of 67 years
-- 151 as against 32 stands as an outlier but it is a solid proof that the developed countries, athough few, are a group of healthy nation with great GDPs and other advanced infrastructure that helps healthy lifestyle, 151 on the other hand ranges from middle income countries to relatively poor countries and this puls down their average significantly. 
-- Conclusion:  The comparison between Developed and Developing countries should be interpreted cautiously , the significant imbalance in group sizes (32 vs 151) and the high variance within the Developing category may influence the average gap of 12 years.

-- Detecting correlation between Schooling and Life Expectancy

SELECT * 
FROM world_life_expectancy;

SELECT country,
ROUND(AVG(Schooling), 1) avg_schooling,
ROUND(AVG(`Life Expectancy`), 1) avg_life_exp
FROM world_life_expectancy
WHERE Schooling IS NOT NULL
AND `Life Expectancy` IS NOT NULL
GROUP BY country
ORDER BY avg_schooling DESC;

# Insights
-- A strong positive correlation exists between schooling years and life expectancy
-- High schooling → 70s and 80s  and Low schooling → 40s, 50s, 60s 
-- Countries averaging 14+ years of schooling consistently record life expectancy in the 70s and 80s, while countries below 8 years average between 48-65; confirming education as a significant factor in population health outcomes.
-- Although countries like Ukraine have have schooling years of 14.6 and yet the avg_life_exp 69.9; a proof that  war seems to have a strong negative impact on life expectancy even where there are advanced healthcare infrastructure and high GDP, they are all destroyed by war. 
-- Ukraine tells the same story as Lithuania and Estonia.

SELECT year ,
ROUND(AVG(`Life Expectancy`), 1) avg_life_exp
FROM world_life_expectancy
WHERE `Life Expectancy` IS NOT NULL
GROUP BY year
ORDER BY year;

WITH cte_name AS (
	SELECT year ,
	ROUND(AVG(`Life Expectancy`), 1) avg_life_exp
	FROM world_life_expectancy
	WHERE `Life Expectancy` IS NOT NULL
	GROUP BY year
	ORDER BY year)
SELECT year, 
avg_life_exp,
ROUND(AVG(avg_life_exp) OVER(ORDER BY year ROWS BETWEEN 1 PRECEDING AND CURRENT ROW), 1) AS rolling_avg
FROM cte_name;

-- Uncovering the top contributing factors to low life expectancy
SELECT country , ROUND(AVG(`Life Expectancy`), 1) AS avg_life_exp,
ROUND(AVG(`Adult Mortality`), 1) avg_adult_mortality,
ROUND(AVG( `infant deaths`), 1) avg_inf_death,
ROUND(AVG( `percentage expenditure`), 1) avg_perc_exp,
ROUND(AVG( `measles`), 1) avg_measles,
ROUND(AVG( `BMI`), 1) avg_bmi,
ROUND(AVG( `under-five deaths`), 1) avg_under5_deaths,
ROUND(AVG( `polio`), 1) avg_polio,
ROUND(AVG( `Diphtheria`), 1) avg_diphteria,
ROUND(AVG( `HIV/AIDS`), 1) avg_hiv_aids,
ROUND(AVG( `gdp`), 1) avg_gdp,
ROUND(AVG( `thinness  1-19 years`), 1) avg_thin_1,
ROUND(AVG( `thinness 5-9 years`), 1) avg_thin_5,
ROUND(AVG( `schooling`), 1) avg_schooling
FROM world_life_expectancy
WHERE `Life Expectancy` IS NOT NULL
GROUP BY country
HAVING avg_life_exp < 55
AND avg_perc_exp IS NOT NULL
AND avg_bmi IS NOT NULL
ORDER BY avg_life_exp;
# Insights
-- Among the conutries with the least life expectancy below 55, three factors stand as consistent contributors to low life expectancy
-- High adult mortality , low GDP and extreme measles cases in some countries like NIgeria with a record of 51653
-- Conclusion: Adult mortality is consistent across all low performing countries, suggesting that preventable adult deaths are the strongest driver of low life expectancy in developing nations.

-- Uncovering the top contributing factors to great life expectancy
SELECT country , ROUND(AVG(`Life Expectancy`), 1) AS avg_life_exp,
ROUND(AVG(`Adult Mortality`), 1) avg_adult_mortality,
ROUND(AVG( `infant deaths`), 1) avg_inf_death,
ROUND(AVG( `percentage expenditure`), 1) avg_perc_exp,
ROUND(AVG( `measles`), 1) avg_measles,
ROUND(AVG( `BMI`), 1) avg_bmi,
ROUND(AVG( `under-five deaths`), 1) avg_under5_deaths,
ROUND(AVG( `polio`), 1) avg_polio,
ROUND(AVG( `Diphtheria`), 1) avg_diphteria,
ROUND(AVG( `HIV/AIDS`), 1) avg_hiv_aids,
ROUND(AVG( `gdp`), 1) avg_gdp,
ROUND(AVG( `thinness  1-19 years`), 1) avg_thin_1,
ROUND(AVG( `thinness 5-9 years`), 1) avg_thin_5,
ROUND(AVG( `schooling`), 1) avg_schooling
FROM world_life_expectancy
WHERE `Life Expectancy` IS NOT NULL
GROUP BY country
HAVING avg_life_exp > 80
AND avg_perc_exp IS NOT NULL
AND avg_bmi IS NOT NULL
AND avg_inf_death IS NOT NULL
ORDER BY avg_life_exp;
# Insights
-- In contrast to the least performing countries, countries with high life expectancy consistently share three characteristics 
-- low adult mortality, high GDP and high healthcare expenditure. 
-- HIV/AIDS is 0.1 across every single high performing country but significantly higher in low performers like Lesotho (23), Swaziland (32.9) and Zimbabwe (23.3)
-- Conclusion: Low life expectancy countries show the opposite pattern, suggesting that economic investment in healthcare directly translates to longer, healthier lives.

#RECOMMENDATIONS
-- Economic Development: Governments should prioritize economic growth and equitable income distribution. The strong correlation between GDP and life expectancy suggests that improving citizens' standard of living directly translates to longer, healthier lives.

-- Healthcare Infrastructure: Investment in accessible and advanced healthcare infrastructure is critical, particularly in Sub-Saharan African nations where adult mortality and infant deaths are highest. Reducing adult mortality is identified as the single most consistent factor separating low and high performing countries.

-- Education Access: Education should be made universally accessible and affordable. Countries averaging 15+ years of schooling consistently recorded life expectancy in the 70s and 80s, suggesting education is as important as economic factors in determining health outcomes

-- Global Peace and International Relations: Conflict is a direct destroyer of life expectancy gains; Syria, Yemen, Iraq and Libya all recorded declining life expectancy directly linked to war and instability. International diplomacy and peacekeeping efforts are therefore as critical as health policy in improving global life expectancy.
