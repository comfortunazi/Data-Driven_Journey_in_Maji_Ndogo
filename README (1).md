# Maji Ndogo: From Analysis to Action 💧
### SQL Data Exploration, Water Accessibility Analysis & Data Quality Investigation

**Tools:** MySQL · SQL  
**Focus:** Exploratory Data Analysis (EDA) · Relational Joins · Aggregation · Data Validation · Data Cleaning

## Project Overview

Access to safe, reliable water is a public-health and infrastructure challenge. In this SQL portfolio project, I explore the fictional **Maji Ndogo** water-services database to investigate how residents access water, how long they wait, whether quality assessments appear consistent, and where pollution records may contain errors.

The project follows a practical analytical workflow: **understand the data → investigate service challenges → examine data quality → correct identified inconsistencies in a separate working table → verify the corrections.**

The SQL script contains **27 guided questions across five sections**. It demonstrates my ability to translate investigative questions into SQL, connect related tables, summarize patterns, and approach data updates carefully.

> **Scope note:** This repository contains the SQL analysis script, not exported query results or the underlying database. The questions and checks below are implemented in SQL; numerical findings should be reported only after running the script against the relevant dataset.

## The Problem

Water-service records can reveal infrastructure and public-health concerns, but useful decisions depend on accurate data. This project investigates four questions:

1. **Accessibility:** Which water-source types are associated with exceptionally long waits?
2. **Service performance:** How do average and maximum queue times compare across source types?
3. **Data consistency:** Are there water-quality ratings or visit records that deserve closer inspection?
4. **Pollution-data reliability:** Are any wells labeled `Clean` despite biological contamination measurements exceeding the project's investigation threshold?

## Database Overview

The analysis uses the `md_water_services` MySQL database and examines eight tables:

| Table | Role in the analysis |
|---|---|
| `data_dictionary` | Explains the dataset's fields |
| `employee` | Explored during initial schema review |
| `global_water_access` | Explored during initial schema review |
| `location` | Explored during initial schema review |
| `water_quality` | Subjective water-quality assessments and visit counts |
| `visits` | Source visits, visit counts, and queue times |
| `water_source` | Water-source types and identifiers |
| `well_pollution` | Well-test descriptions, biological measurements, and results |

**Key joins:** `visits.source_id = water_source.source_id` and `water_quality.record_id = visits.record_id`.

## Analytical Workflow

### 1. Explore and understand the data
- Inspect the available tables with `SHOW TABLES`.
- Preview records with `SELECT` and `LIMIT`.
- Examine column definitions with `DESCRIBE`.
- Identify distinct water-source types using `DISTINCT`.

### 2. Analyze water-source visits and waiting times
- Filter visits with queue times **greater than 500 minutes**.
- Join visit records to their water-source categories.
- Rank individual visits by queue duration.
- Calculate **average** and **maximum** queue times for each water-source type.

**Example: Compare waiting times by water-source type**

```sql
SELECT
    ws.type_of_water_source,
    AVG(v.time_in_queue) AS average_queue_minutes,
    MAX(v.time_in_queue) AS longest_queue_minutes
FROM visits AS v
JOIN water_source AS ws
    ON v.source_id = ws.source_id
GROUP BY ws.type_of_water_source
ORDER BY average_queue_minutes DESC;
```

**Why it matters:** Comparing queue times can help analysts identify water-source categories that warrant further investigation and potentially inform service-improvement priorities.

### 3. Examine water-quality assessments
- Connect water-quality records with visits and source types.
- Investigate `tap_in_home` records with a subjective quality score of **10** and a second recorded visit.
- Compare visit counts across the quality and visit tables to flag records for review.

**Why it matters:** Unusual combinations of ratings and visit histories can be useful quality-assurance signals, although they do **not** establish an error on their own.

### 4. Investigate well-pollution records
- Identify wells recorded as `Clean` where `biological > 0.01`.
- Search for descriptions that begin with `Clean` but also contain contamination-related text.
- Use `WHERE`, `AND`, `OR`, and `LIKE` to isolate potentially inconsistent records.

**Example: Flag contradictory pollution classifications**

```sql
SELECT *
FROM well_pollution
WHERE results = 'Clean'
  AND biological > 0.01;
```

**Why it matters:** Conflicting test values and labels may undermine downstream reporting. The `0.01` cutoff is the criterion used in this exercise; it should not be interpreted as an independently validated regulatory standard.

### 5. Correct and validate pollution data

Rather than updating the original `well_pollution` table, the script first creates a separate working copy:

```sql
CREATE TABLE well_pollution_copy AS
SELECT *
FROM well_pollution;
```

It then standardizes two contradictory descriptions, including `Clean Bacteria: E. coli` and `Clean Bacteria: Giardia Lamblia`, and updates qualifying `Clean` classifications:

```sql
UPDATE well_pollution_copy
SET results = 'Contaminated: Biological'
WHERE biological > 0.01
  AND results = 'Clean';
```

Finally, a validation query counts records that still match the defined error conditions:

```sql
SELECT COUNT(*) AS remaining_problem_records
FROM well_pollution_copy
WHERE description LIKE 'Clean_%'
   OR (results = 'Clean' AND biological > 0.01);
```

A count of **0**, if obtained when executed, indicates that no rows in the working copy match these specific checks. The script also includes an optional `DROP TABLE` statement for removing the working copy after verification.

> **Data-handling note:** `CREATE TABLE ... AS SELECT` copies data but may not preserve indexes, constraints, or other schema properties. The working copy is suitable for this learning exercise; a production workflow would require stronger change controls and testing. The script includes data-changing statements, so review it before executing the entire file.

## SQL Skills Demonstrated

| Skill | Application |
|---|---|
| Database exploration | `SHOW TABLES`, `DESCRIBE`, `SELECT`, `LIMIT` |
| Filtering and pattern matching | `WHERE`, `AND`, `OR`, `LIKE` |
| Relational analysis | `JOIN` across source, visit, and quality tables |
| Aggregation | `AVG`, `MAX`, `COUNT`, `GROUP BY` |
| Sorting and prioritization | `ORDER BY`, `LIMIT` |
| Data-quality checks | Cross-table comparisons and conditional validation |
| Data cleaning | `CREATE TABLE`, `UPDATE`, `SET` |
| Verification and cleanup | Post-update checks and optional `DROP TABLE` |

## Project Deliverable

📄 **[View the complete SQL analysis](Data-Driven_Journey-in-Maji_Ndogo.sql)**

The script is organized into five clearly labeled sections, with question-based comments explaining the purpose of each analysis.

## How to Run the Project

1. Open **MySQL Workbench** or another MySQL-compatible SQL client.
2. Import or create the `md_water_services` database using the corresponding dataset/schema (not included in this repository).
3. Open [`Data-Driven_Journey-in-Maji_Ndogo.sql`](Data-Driven_Journey-in-Maji_Ndogo.sql) or load the file directly from the repository.
4. Confirm the database exists and execute the exploration and analysis queries section by section.
5. Review the results before running the data-modification section. Run the validation queries before optionally dropping `well_pollution_copy`.

## What I Learned

This project strengthened my ability to move beyond retrieving records and toward **asking meaningful questions of data**. I practiced joining related tables, using aggregate measures to investigate operational challenges, distinguishing unusual records from confirmed errors, and validating targeted corrections without directly changing the source table.

It also reinforced an important analytical principle: **data-driven recommendations are only as trustworthy as the data behind them.**

## Potential Next Steps

- Export query results and document confirmed findings with metrics.
- Build a Power BI dashboard showing queue-time patterns and water-source categories.
- Explore geographic differences using the `location` table.
- Introduce additional validation rules and reproducible data-cleaning checks.
- Translate verified findings into prioritized, evidence-based recommendations.

---

**Portfolio project | SQL · Data Analysis · Data Quality**  
*Turning raw water-service records into structured investigations that can support better decisions.*
