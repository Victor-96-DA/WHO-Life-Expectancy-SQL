## World Life Expectancy Analysis (WHO) | MySQL
#### Overview
This project uses MySQL to clean and perform an Exploratory Data Analysis (EDA) on 
the WHO World Life Expectancy dataset sourced from Kaggle, covering 193 countries across 15 years (2007–2022). 
The goal is to uncover the key factors driving high and low life expectancy globally and 
generate data-driven recommendations for improving health outcomes.

#### Tools Used

**MySQL Workbench**

### Dataset
| Detail | Info |
|--------|------|
| Source | Kaggle — WHO World Life Expectancy Dataset |
| Coverage | 193 countries |
| Period | 2007 – 2022 |
| Records | 2,938 (after cleaning) |

#### Project Structure
| File | Description |
|------|-------------|
| `world_life_expectancy_cleaning.sql` | Data cleaning script |
| `world_life_expectancy_EDA.sql` | Exploratory Data Analysis script |

#### Part 1: Data Cleaning
**Step 1 — Removed Duplicates**
Identified and removed 3 duplicate rows (Ireland 2022, Senegal 2009, Zimbabwe 2019) using 
the ROW_NUMBER() window function and a subquery to isolate duplicate row IDs before deletion.

**Step 2 — Populated Missing Status Values**
Used a self JOIN to populate missing country development status (Developing / Developed) 
based on existing status values for the same country in other years.

**Step 3 — Populated Missing Life Expectancy Values**
Used a statistical approach via self JOIN to fill missing life expectancy values with the
average of the year before and after the missing year.

**Step 4 — Converted 0 Values to NULL**
Converted 0 values to NULL across 14 columns where 0 was physiologically, statistically, 
or economically impossible (e.g. BMI, GDP, Adult Mortality, Schooling).
MySQL treats 0 as valid data in aggregations, converting to NULL ensures accurate AVG and COUNT results. 
This decision was validated during EDA where queries with and without NULL filters returned identical results, 
confirming the cleaning was thorough and effective.


#### Part 2: Exploratory Data Analysis
1. **Country Life Expectancy Trends**
The top 10 most improved countries are all developing nations, suggesting that 
foundational healthcare investments yield the greatest life expectancy gains.
11 countries showed stagnant or declining life expectancy over the study period
Conflict-affected nations like Syria, Yemen, Iraq, and Libya recorded the steepest declines,
confirming war as a major driver of life expectancy loss.

2. **GDP vs Life Expectancy**
The analysis shows a strong positive correlation between GDP and life expectancy
Countries with average GDP above 25,000 consistently recorded life expectancy in the 70s and 80s
Countries with average GDP below 1,500 recorded life expectancy in the 40s to 60s (a gap of up to 30 years)
Despite a cumulative GDP of 98,293, Brazil recorded zero life expectancy improvement,
linked to a high adult mortality rate of 2,411 suggesting that GDP alone is insufficient without addressing inequality and mortality drivers.

3. **Developed vs Developing Countries**
Developed countries (32) averaged 79.2 years vs Developing countries (151) at 67.1 years (a 12-year gap)
This mirrors the GDP tier findings, reinforcing the link between economic development and health outcomes.

4. **Schooling vs Life Expectancy**
Countries averaging 15+ years of schooling consistently recorded life expectancy in the 70s and 80s
Countries below 8 years of schooling averaged between 48–65 years (a gap of up to 30 years)
Eastern European nations (Ukraine, Lithuania, Estonia) show relatively high schooling years but
lower-than-expected life expectancy, reflecting Soviet-era healthcare legacy and economic instability.

5. **Global Life Expectancy Trend**
Global average life expectancy rose steadily from 66.8 in 2007 to 71.6 in 2022 (a gain of 4.8 years)
A 2-year rolling average confirms no significant volatility over the period, suggesting consistent and stable global health improvements.

6. **Factors Contributing to Low Life Expectancy**
Among countries with average life expectancy below 55, three factors consistently stand out:

  High adult mortality
  Low GDP
  High measles cases (particularly in high-population countries like Nigeria)

  Adult mortality is the single most consistent factor separating low and high performing countries
  Top performing countries share three characteristics — low adult mortality, high GDP, and high healthcare expenditure, 
  with HIV/AIDS at 0.1 across all top performers


#### Recommendations
1. **Economic Development**
Governments should prioritize economic growth and equitable income distribution. The strong correlation between GDP and 
life expectancy suggests that improving citizens' standard of living directly translates to longer, healthier lives.
2. **Healthcare Infrastructure**
Investment in accessible and advanced healthcare is critical, particularly in Sub-Saharan African nations
where adult mortality and infant deaths are highest.
Reducing adult mortality is identified as the single most consistent factor separating low and high performing countries.
3. **Education Access**
Education should be made universally accessible and affordable. Countries averaging 15+ years of schooling consistently recorded
life expectancy in the 70s and 80s, confirming education as equally important as economic factors in determining health outcomes.
4. **Global Peace and International Relations**
Conflict directly destroys life expectancy gains. Syria, Yemen, Iraq, and Libya all recorded declining life expectancy directly linked to war and instability. International diplomacy and peacekeeping efforts are therefore as critical as health policy in improving global life expectancy outcomes.

### SQL Concepts Demonstrated
#### DDL - Data Definition Language
- **CREATE DATABASE** - created a new database for this project
- **USE DATABASE** - activating the newly created database
- **CREATE TABLE** -imported the WHO dataset as a table

#### DML — Data Manipulation Language
- **UPDATE, DELETE**

#### DQL — Data Query Language
- **SELECT, WHERE, GROUP BY, ORDER BY, HAVING**
- **JOINs** (self JOIN)
- **Subqueries and CTEs** (WITH)
- **Aggregate Functions** (AVG, COUNT, MIN, MAX)
- **Window Functions** (ROW_NUMBER, rolling average)
- **CASE statements and conditional aggregation**
