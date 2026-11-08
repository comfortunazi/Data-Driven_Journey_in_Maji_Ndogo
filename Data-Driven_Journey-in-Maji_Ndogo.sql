-- MAJI NDOGO: FROM ANALYSIS TO ACTION
-- Beginner-friendly SQL answers based on the project PDF and md_water_services.sql.
-- Select the md_water_services database before running these queries.
-- NOTE: The project slides include exploratory prompts; some numbered questions below
-- are practical follow-up questions to help organize the tasks, not verbatim slide text.

USE md_water_services;

-- =====================================================
-- SECTION 1: GET TO KNOW OUR DATA
-- =====================================================

-- Question 1: How many tables are in the database, and what are their names?
SHOW TABLES;
-- In the supplied schema, the tables are:
-- data_dictionary, employee, global_water_access, location,
-- water_quality, visits, water_source, well_pollution.

-- Question 2: How can we retrieve the first five records from each table?
SELECT * FROM data_dictionary LIMIT 5;
SELECT * FROM employee LIMIT 5;
SELECT * FROM global_water_access LIMIT 5;
SELECT * FROM location LIMIT 5;
SELECT * FROM water_quality LIMIT 5;
SELECT * FROM visits LIMIT 5;
SELECT * FROM water_source LIMIT 5;
SELECT * FROM well_pollution LIMIT 5;

-- Question 3: What columns and data types are contained in each table?
-- DESCRIBE shows column names, data types, keys, and whether NULL is allowed.
DESCRIBE data_dictionary;
DESCRIBE employee;
DESCRIBE global_water_access;
DESCRIBE location;
DESCRIBE water_quality;
DESCRIBE visits;
DESCRIBE water_source;
DESCRIBE well_pollution;

-- Question 4: What information does each table contain?
-- Use the first-five-row queries above and the data dictionary to inspect meaning.
SELECT * FROM data_dictionary;
-- The data_dictionary explains the meaning of columns in the project tables.

-- Question 5: Which table contains information about different water-source types?
-- The water_source table.
SELECT * FROM water_source LIMIT 5;

-- Question 6: What are all the unique types of water sources?
SELECT DISTINCT type_of_water_source
FROM water_source;

-- =====================================================
-- SECTION 2: UNPACK THE VISITS TO WATER SOURCES
-- =====================================================

-- Question 7: Which table records visits made to water sources?
-- The visits table.
SELECT * FROM visits LIMIT 5;

-- Question 8: Which visits have a queue time greater than 500 minutes?
SELECT *
FROM visits
WHERE time_in_queue > 500;

-- Question 9: What types of water sources have queue times greater than 500 minutes?
SELECT DISTINCT ws.type_of_water_source
FROM visits AS v
JOIN water_source AS ws
    ON v.source_id = ws.source_id
WHERE v.time_in_queue > 500;

-- Question 10: Which water sources are associated with the longest queue times?
SELECT
    v.source_id,
    ws.type_of_water_source,
    v.time_in_queue,
    v.visit_count
FROM visits AS v
JOIN water_source AS ws
    ON v.source_id = ws.source_id
WHERE v.time_in_queue > 0
ORDER BY v.time_in_queue DESC
LIMIT 20;

-- Question 11: How can queue times be summarized by water-source type?
SELECT
    ws.type_of_water_source,
    AVG(v.time_in_queue) AS average_queue_minutes,
    MAX(v.time_in_queue) AS longest_queue_minutes
FROM visits AS v
JOIN water_source AS ws
    ON v.source_id = ws.source_id
GROUP BY ws.type_of_water_source
ORDER BY average_queue_minutes DESC;

-- =====================================================
-- SECTION 3: ASSESS THE QUALITY OF WATER SOURCES
-- =====================================================

-- Question 12: Which table contains subjective water-quality scores?
-- The water_quality table.
SELECT * FROM water_quality LIMIT 5;

-- Question 13: Find records where a home tap received a quality score of 10
-- despite being visited a second time.
-- Connect water_quality to visits through record_id, then visits to water_source
-- through source_id. The quality table's visit_count is used for this condition.
SELECT
    wq.record_id,
    wq.subjective_quality_score,
    wq.visit_count,
    v.source_id,
    ws.type_of_water_source
FROM water_quality AS wq
JOIN visits AS v
    ON wq.record_id = v.record_id
JOIN water_source AS ws
    ON v.source_id = ws.source_id
WHERE wq.subjective_quality_score = 10
  AND wq.visit_count = 2
  AND ws.type_of_water_source = 'tap_in_home';

-- Question 14: Why might these records be unexpected?
-- A score of 10 is the highest subjective score, so a second visit may seem unusual.
-- This is an interpretation prompt, not something SQL can prove by itself.

-- Question 15: How can you inspect records that might indicate survey-data issues?
-- Review the records returned by Question 13 and compare both visit-count columns.
SELECT
    wq.record_id,
    wq.subjective_quality_score,
    wq.visit_count AS quality_visit_count,
    v.visit_count AS visit_log_count,
    v.source_id,
    ws.type_of_water_source
FROM water_quality AS wq
JOIN visits AS v
    ON wq.record_id = v.record_id
JOIN water_source AS ws
    ON v.source_id = ws.source_id
WHERE wq.subjective_quality_score = 10
  AND (wq.visit_count = 2 OR v.visit_count = 2)
  AND ws.type_of_water_source = 'tap_in_home';

-- =====================================================
-- SECTION 4: INVESTIGATE POLLUTION ISSUES
-- =====================================================

-- Question 16: Which table contains pollution-test information for wells?
-- The well_pollution table.
SELECT * FROM well_pollution LIMIT 5;

-- Question 17: Display the first five well-pollution records.
SELECT * FROM well_pollution LIMIT 5;

-- Question 18: Which records say 'Clean' despite biological contamination > 0.01?
SELECT *
FROM well_pollution
WHERE results = 'Clean'
  AND biological > 0.01;

-- Question 19: Which descriptions begin with 'Clean_' followed by more text?
-- In LIKE patterns, '_' matches one character and '%' matches zero or more characters.
SELECT *
FROM well_pollution
WHERE description LIKE 'Clean_%';

-- Question 20: Find descriptions that start with 'Clean' but include additional text.
SELECT *
FROM well_pollution
WHERE description LIKE 'Clean %'
   OR description LIKE 'Clean_%';

-- =====================================================
-- SECTION 5: CORRECT THE POLLUTION DATA
-- =====================================================

-- Question 21: Make a copy of well_pollution before changing data.
-- Run this only if the copy table does not already exist.
CREATE TABLE well_pollution_copy AS
SELECT *
FROM well_pollution;

-- Question 22: Change 'Clean Bacteria: E. coli' to 'Bacteria: E. coli'.
UPDATE well_pollution_copy
SET description = 'Bacteria: E. coli'
WHERE description = 'Clean Bacteria: E. coli';

-- Question 23: Change 'Clean Bacteria: Giardia Lamblia' to
-- 'Bacteria: Giardia Lamblia'.
UPDATE well_pollution_copy
SET description = 'Bacteria: Giardia Lamblia'
WHERE description = 'Clean Bacteria: Giardia Lamblia';

-- Question 24: Mark records biologically contaminated when biological > 0.01
-- and the current result is 'Clean'.
UPDATE well_pollution_copy
SET results = 'Contaminated: Biological'
WHERE biological > 0.01
  AND results = 'Clean';

-- Question 25: Verify the description and result corrections.
SELECT *
FROM well_pollution_copy
WHERE description LIKE 'Clean_%'
   OR (results = 'Clean' AND biological > 0.01);

-- Question 26: Count remaining records that match the error conditions.
-- A result of 0 means no rows still match these conditions.
SELECT COUNT(*) AS remaining_problem_records
FROM well_pollution_copy
WHERE description LIKE 'Clean_%'
   OR (results = 'Clean' AND biological > 0.01);

-- Question 27: Remove the temporary copy after verifying the corrections.
-- Only run this when you no longer need the copy.
DROP TABLE well_pollution_copy;
