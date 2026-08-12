#Create backup
CREATE TABLE layoffs_backup
like layoffs_22
;
INSERT into layoffs_backup
SELECT * from layoffs_22
;
#Check duplicated rows
With duplicated_data AS(
	SELECT * ,
    ROW_NUMBER() OVER(PARTITION BY company,location,industry,total_laid_off,percentage_laid_off,`date`,stage,country,funds_raised_millions
    )as row_num
    from layoffs_22
)
SELECT * FROM duplicated_data
where row_num >1;

#Adding row_num Column To Table To Delete Duplicted Rows
CREATE TABLE `layoffs_New` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  `row_num` int 
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

INSERT INTO layoffs_new

	SELECT * ,
    ROW_NUMBER() OVER(PARTITION BY company,location,industry,total_laid_off,percentage_laid_off,`date`,stage,country,funds_raised_millions
    )as row_num
    from layoffs_22;

#Remove Duplicated Rows
DELETE FROM layoffs_new
WHERE row_num >1;

# Trim Rows
UPDATE layoffs_new
SET
    company = TRIM(company),
    location = TRIM(location),
    industry = TRIM(industry),
    percentage_laid_off = TRIM(percentage_laid_off),
    `date` = TRIM(`date`),
    stage = TRIM(stage),
    country = TRIM(country);
    
#Clean industry Column

SELECT DISTINCT industry FROM layoffs_new
ORDER BY 1;

SELECT industry FROM layoffs_new
WHERE industry like 'Crypto%'
order by 1;

UPDATE layoffs_new
set industry ='Crypto'
WHERE industry like 'Crypto%';

#Clean country Column
SELECT DISTINCT country from layoffs_new
ORDER BY 1;

UPDATE layoffs_new
set country = 'Australia'
WHERE country like 'Austr%';

UPDATE layoffs_new
set country = 'United States'
WHERE country like 'United States%';

#Clean date type
UPDATE layoffs_new
set `date` = str_to_date(`date`,'%m/%d/%Y');

ALTER TABLE layoffs_new
MODIFY COLUMN `date` DATE ;

#Nulls And Blank
SELECT t1.industry,t2.industry FROM layoffs_new t1
join layoffs_new t2
on t1.company = t2.company
WHERE (t1.industry is NULL OR t1.industry ='') And
t2.industry is not null;
UPDATE layoffs_new t1
JOIN layoffs_new t2
on t1.company = t2.company
set t1.industry = t2.industry
WHERE t1.industry is NULL AND t2.industry is NOT NULL;
SELECT * FROM layoffs_new;

ALTER TABLE layoffs_new
DROP COLUMN row_num;


#EDA 
Use world_life;

#total laid of over years
SELECT year(`date`) as year_,
SUM(total_laid_off) as total_laid_off
from layoffs_new
GROUP BY year_
ORDER BY 1;

#total laid off by industry
SELECT industry,
SUM(total_laid_off) as total_laid_off
from layoffs_new
WHERE industry is not null
GROUP BY industry
ORDER BY total_laid_off desc;

#Max Total Laid Off
SELECT *
FROM layoffs_new # is 12000 in google in 2023
WHERE total_laid_off =(SELECT Max(layoffs_new.total_laid_off) From layoffs_new);

#total laid off over country
SELECT country,
SUM(total_laid_off) as total_laid_off
from layoffs_new
WHERE country is not null And total_laid_off is not null
GROUP BY country
ORDER BY total_laid_off desc; # United States has Max laid off