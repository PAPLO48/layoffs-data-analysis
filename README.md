\# Layoffs Data Cleaning \& Exploratory Data Analysis



\## 📌 Project Overview



This project focuses on cleaning, transforming, and analyzing a layoffs dataset using \*\*MySQL\*\*.



The project was divided into two main stages:



1\. \*\*Data Cleaning \& Preparation\*\*

2\. \*\*Exploratory Data Analysis (EDA)\*\*



The goal was to transform raw layoffs data into a cleaner and more reliable dataset, then extract meaningful insights about layoffs across different years, industries, and countries.



\---



\## 🎯 Project Objectives



\* Identify and remove duplicate records.

\* Clean inconsistent text values.

\* Standardize industry and country names.

\* Convert date values into a proper `DATE` format.

\* Handle missing and blank values.

\* Prepare a reliable dataset for analysis.

\* Analyze layoffs across different years, industries, and countries.

\* Identify companies with the highest number of layoffs.



\---



\## 📊 Dataset



The dataset contains information about layoffs from companies around the world.



\### Columns



| Column                  | Description                      |

| ----------------------- | -------------------------------- |

| `company`               | Company name                     |

| `location`              | Company location                 |

| `industry`              | Industry of the company          |

| `total\_laid\_off`        | Number of employees laid off     |

| `percentage\_laid\_off`   | Percentage of workforce laid off |

| `date`                  | Date of the layoff               |

| `stage`                 | Company funding/stage            |

| `country`               | Company country                  |

| `funds\_raised\_millions` | Funds raised in millions         |



The cleaned dataset contains \*\*1,995 records\*\* and \*\*9 columns\*\*.



\---



\# 🧹 Data Cleaning



\## 1. Creating a Backup



A backup table was created before modifying the original dataset.



```sql

CREATE TABLE layoffs\_backup

LIKE layoffs\_22;



INSERT INTO layoffs\_backup

SELECT \*

FROM layoffs\_22;

```



This ensures that the original data remains available if any issue occurs during the cleaning process.



\---



\## 2. Detecting Duplicate Records



A `ROW\_NUMBER()` window function was used to identify duplicate records based on the relevant columns.



```sql

ROW\_NUMBER() OVER(

&#x20;   PARTITION BY company,

&#x20;                location,

&#x20;                industry,

&#x20;                total\_laid\_off,

&#x20;                percentage\_laid\_off,

&#x20;                `date`,

&#x20;                stage,

&#x20;                country,

&#x20;                funds\_raised\_millions

) AS row\_num

```



Records with `row\_num > 1` were considered duplicates.



\---



\## 3. Removing Duplicates



A new cleaned table was created containing the duplicate-ranking column.



After inserting the data, duplicate records were removed:



```sql

DELETE FROM layoffs\_new

WHERE row\_num > 1;

```



This ensured that each unique record appeared only once.



\---



\## 4. Trimming Text Values



Unnecessary spaces were removed from text columns using `TRIM()`.



```sql

UPDATE layoffs\_new

SET

&#x20;   company = TRIM(company),

&#x20;   location = TRIM(location),

&#x20;   industry = TRIM(industry),

&#x20;   percentage\_laid\_off = TRIM(percentage\_laid\_off),

&#x20;   `date` = TRIM(`date`),

&#x20;   stage = TRIM(stage),

&#x20;   country = TRIM(country);

```



This helps prevent inconsistencies caused by leading or trailing spaces.



\---



\## 5. Standardizing Industry Values



Different variations of cryptocurrency-related industries were identified and standardized.



For example:



```text

Crypto

Crypto Currency

Crypto / Blockchain

CryptoCurrency

```



were standardized to:



```text

Crypto

```



using:



```sql

UPDATE layoffs\_new

SET industry = 'Crypto'

WHERE industry LIKE 'Crypto%';

```



\---



\## 6. Standardizing Country Values



Inconsistent country names were also standardized.



For example, values beginning with `Austr` were standardized to:



```text

Australia

```



and variations beginning with `United States` were standardized to:



```text

United States

```



\---



\## 7. Converting the Date Column



The original date values were stored as text.



They were first converted using:



```sql

STR\_TO\_DATE(`date`, '%m/%d/%Y')

```



Then the column was changed to the proper `DATE` data type:



```sql

ALTER TABLE layoffs\_new

MODIFY COLUMN `date` DATE;

```



The final dataset covers layoffs recorded between \*\*2020 and 2023\*\*.



\---



\## 8. Handling Missing Industry Values



A self-join was used to identify companies where one record had a missing industry while another record for the same company contained the industry.



```sql

UPDATE layoffs\_new t1

JOIN layoffs\_new t2

ON t1.company = t2.company

SET t1.industry = t2.industry

WHERE t1.industry IS NULL

AND t2.industry IS NOT NULL;

```



This allowed missing industry information to be recovered from other records belonging to the same company.



\---



\## 9. Removing the Temporary Column



After duplicate removal, the temporary `row\_num` column was no longer required:



```sql

ALTER TABLE layoffs\_new

DROP COLUMN row\_num;

```



The result was a clean dataset ready for analysis.



\---



\# 📈 Exploratory Data Analysis



After completing the cleaning process, several SQL queries were used to explore the dataset.



\## Layoffs Over the Years



The total number of layoffs was calculated for each year.



\### Key Finding



| Year | Total Layoffs |

| ---- | ------------: |

| 2020 |        80,998 |

| 2021 |        15,823 |

| 2022 |       160,661 |

| 2023 |       125,677 |



\*\*2022 recorded the highest total number of layoffs\*\*, followed by 2023.



This shows a significant increase in layoffs after the relatively low level observed in 2021.



\---



\## Layoffs by Industry



The total number of layoffs was grouped by industry.



The industries with the highest recorded layoffs included:



| Industry       | Total Layoffs |

| -------------- | ------------: |

| Consumer       |        45,182 |

| Retail         |        43,613 |

| Other          |        36,289 |

| Transportation |        33,748 |

| Finance        |        28,344 |

| Healthcare     |        25,953 |

| Food           |        22,855 |



The \*\*Consumer industry\*\* recorded the highest number of layoffs in the cleaned dataset.



\---



\## Layoffs by Country



The analysis also examined layoffs by country.



The United States had a significant lead:



| Country       | Total Layoffs |

| ------------- | ------------: |

| United States |       256,559 |

| India         |        35,993 |

| Netherlands   |        17,220 |

| Sweden        |        11,264 |

| Brazil        |        10,391 |



The \*\*United States accounted for the largest number of recorded layoffs\*\* in the dataset.



\---



\## Maximum Single-Company Layoff



A subquery using `MAX()` was used to identify the company with the highest single layoff event.



```sql

SELECT \*

FROM layoffs\_new

WHERE total\_laid\_off = (

&#x20;   SELECT MAX(total\_laid\_off)

&#x20;   FROM layoffs\_new

);

```



\### Result



\*\*Google\*\* recorded the largest single layoff event in the dataset:



\* \*\*Company:\*\* Google

\* \*\*Total Laid Off:\*\* 12,000

\* \*\*Date:\*\* January 20, 2023

\* \*\*Country:\*\* United States



\---



\# 🛠️ SQL Techniques Used



The project demonstrates several important SQL concepts:



\* `CREATE TABLE`

\* `INSERT INTO`

\* `UPDATE`

\* `DELETE`

\* `ALTER TABLE`

\* `DROP COLUMN`

\* `TRIM()`

\* `LIKE`

\* `STR\_TO\_DATE()`

\* `GROUP BY`

\* `ORDER BY`

\* `WHERE`

\* `IS NULL`

\* `IS NOT NULL`

\* `JOIN`

\* `CTE`

\* `ROW\_NUMBER()`

\* Window Functions

\* Aggregate Functions

\* `SUM()`

\* `MAX()`

\* Subqueries



\---



\# 💡 Key Insights



The analysis revealed several important patterns:



1\. \*\*2022 was the year with the highest total number of layoffs\*\* in the dataset, with approximately \*\*160.7K layoffs\*\*.



2\. Layoffs increased dramatically after 2021, when the dataset recorded approximately \*\*15.8K layoffs\*\*.



3\. The \*\*Consumer industry\*\* recorded the highest number of layoffs among the categorized industries.



4\. The \*\*United States\*\* had by far the highest number of recorded layoffs, with approximately \*\*256.6K\*\*.



5\. \*\*Google recorded the largest individual layoff event\*\* in the dataset, with \*\*12,000 employees laid off\*\* in January 2023.



\---



\# 📂 Project Structure



```text

Layoffs-Data-Analysis/

│

├── layoffs.csv

├── layoffs\_analysis.sql

└── README.md

```



\---



\# 💻 Tools \& Technologies



\* \*\*MySQL\*\*

\* \*\*MySQL Workbench\*\*

\* \*\*SQL\*\*

\* \*\*Window Functions\*\*

\* \*\*CTEs\*\*

\* \*\*Data Cleaning\*\*

\* \*\*Exploratory Data Analysis\*\*



\---



\# 🚀 Project Workflow



```text

Raw Dataset

&#x20;    ↓

Backup Creation

&#x20;    ↓

Duplicate Detection

&#x20;    ↓

Duplicate Removal

&#x20;    ↓

Text Cleaning

&#x20;    ↓

Standardization

&#x20;    ↓

Missing Value Handling

&#x20;    ↓

Date Conversion

&#x20;    ↓

Clean Dataset

&#x20;    ↓

Exploratory Data Analysis

&#x20;    ↓

Insights

```



\---



\# 📌 Conclusion



This project demonstrates a complete SQL-based data analysis workflow, starting from a raw dataset and ending with a structured and cleaned dataset ready for analysis.



The project focuses not only on writing SQL queries, but also on understanding the data, identifying quality issues, applying appropriate cleaning techniques, and extracting meaningful insights from the final dataset.



The workflow provides a foundation for more advanced analysis using tools such as \*\*Python, Power BI, Tableau, and Machine Learning\*\*.



\---



\## 👤 Author



\*\*Mostafa Mahmoud\*\*



Data Analyst | Computer Science Student



\---



