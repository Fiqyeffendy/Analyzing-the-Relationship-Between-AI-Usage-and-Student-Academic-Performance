-- =========================================================
-- Project: Student AI Usage & Academic Performance Dashboard
-- Tools: PostgreSQL / DBeaver & Power BI
-- =========================================================

-- =========================================================
-- 1. Data Understanding
-- =========================================================

-- Check all the data
SELECT * FROM dampak_ai;

-- Check the column structure and data types
SELECT column_name, data_type
FROM information_schema.columns
WHERE table_name = 'dampak_ai'
ORDER BY ordinal_position;

-- check total data
SELECT COUNT(*) AS total_students
FROM dampak_ai;

-- Check the unique value of major_category
SELECT DISTINCT major_category FROM dampak_ai
ORDER BY major_category;

-- Check the unique value of year_of_study
SELECT DISTINCT year_of_study FROM dampak_ai
ORDER BY year_of_study;

-- Check the unique value of primary_use_case
SELECT DISTINCT primary_use_case FROM dampak_ai
ORDER BY primary_use_case;

-- Check the unique value of burnout_risk_level
SELECT DISTINCT burnout_risk_level FROM dampak_ai
ORDER BY burnout_risk_level;

-- =========================================================
-- 2. Converting the data type
-- =========================================================
ALTER TABLE dampak_ai
ALTER COLUMN student_id TYPE INTEGER
USING student_id::INTEGER;

ALTER TABLE dampak_ai
ALTER COLUMN pre_semester_gpa TYPE NUMERIC(4,3)
USING pre_semester_gpa::NUMERIC;

ALTER TABLE dampak_ai
ALTER COLUMN post_semester_gpa TYPE NUMERIC(4,3)
USING post_semester_gpa::NUMERIC;

ALTER TABLE dampak_ai
ALTER COLUMN weekly_genai_hours TYPE NUMERIC(5,2)
USING weekly_genai_hours::NUMERIC;

ALTER TABLE dampak_ai
ALTER COLUMN traditional_study_hours TYPE NUMERIC(5,2)
USING traditional_study_hours::NUMERIC;

ALTER TABLE dampak_ai
ALTER COLUMN perceived_ai_dependency TYPE INTEGER
USING perceived_ai_dependency::INTEGER;

ALTER TABLE dampak_ai
ALTER COLUMN anxiety_level_during_exams TYPE INTEGER
USING anxiety_level_during_exams::INTEGER;

ALTER TABLE dampak_ai
ALTER COLUMN skill_retention_score TYPE NUMERIC(5,2)
USING skill_retention_score::NUMERIC;

-- =========================================================
-- 3. Data Quality Check
-- =========================================================

-- Check for missing values in key columns
SELECT 
    COUNT(*) - COUNT(student_id) AS missing_student_id,
    COUNT(*) - COUNT(major_category) AS missing_major_category,
    COUNT(*) - COUNT(year_of_study) AS missing_year_of_study,
    COUNT(*) - COUNT(pre_semester_gpa) AS missing_pre_semester_gpa,
    COUNT(*) - COUNT(post_semester_gpa) AS missing_post_semester_gpa,
    COUNT(*) - COUNT(weekly_genai_hours) AS missing_weekly_genai_hours,
    COUNT(*) - COUNT(perceived_ai_dependency) AS missing_ai_dependency,
    COUNT(*) - COUNT(skill_retention_score) AS missing_skill_retention,
    COUNT(*) - COUNT(anxiety_level_during_exams) AS missing_anxiety,
    COUNT(*) - COUNT(burnout_risk_level) AS missing_burnout
FROM dampak_ai;

-- Check for duplicates based on student_id
SELECT student_id, COUNT(*) AS total_duplicate
FROM dampak_ai GROUP BY student_id
HAVING COUNT(*) > 1;

-- Check the GPA range
SELECT 
    MIN(pre_semester_gpa) AS min_pre_gpa,
    MAX(pre_semester_gpa) AS max_pre_gpa,
    MIN(post_semester_gpa) AS min_post_gpa,
    MAX(post_semester_gpa) AS max_post_gpa
FROM dampak_ai;

-- Check for an unusual GPA
SELECT *
FROM dampak_ai
WHERE pre_semester_gpa < 0
   OR pre_semester_gpa > 4
   OR post_semester_gpa < 0
   OR post_semester_gpa > 4;

-- Check the range of AI applications
SELECT 
    MIN(weekly_genai_hours) AS min_ai_hours,
    MAX(weekly_genai_hours) AS max_ai_hours,
    ROUND(AVG(weekly_genai_hours), 2) AS avg_ai_hours
FROM dampak_ai;

-- Check for unusual AI usage
SELECT *
FROM dampak_ai
WHERE weekly_genai_hours < 0;


-- =========================================================
-- 4. KPI Summary Dashboard
-- =========================================================
SELECT 
    COUNT(DISTINCT student_id) AS total_students,
    ROUND(AVG(weekly_genai_hours), 2) AS avg_weekly_ai_hours,
    ROUND(AVG(post_semester_gpa) - AVG(pre_semester_gpa), 3) AS avg_gpa_change,
    ROUND(AVG(perceived_ai_dependency), 2) AS avg_ai_dependency
FROM dampak_ai;

-- =========================================================
-- 5. Analysis Questions
-- =========================================================

-- Q1. Which field of study has the highest average use of AI?
SELECT major_category, 
ROUND(AVG(weekly_genai_hours), 2) AS avg_weekly_genai_hours
FROM dampak_ai GROUP BY major_category
ORDER BY avg_weekly_genai_hours DESC;

-- Q2. What is the average GPA increase by major category?
SELECT major_category,
    ROUND(AVG(weekly_genai_hours), 2) AS avg_weekly_genai_hours,
    ROUND(AVG(pre_semester_gpa), 3) AS avg_pre_semester_gpa,
    ROUND(AVG(post_semester_gpa), 3) AS avg_post_semester_gpa,
    ROUND(AVG(post_semester_gpa) - AVG(pre_semester_gpa), 3) AS avg_gpa_change
FROM dampak_ai GROUP BY major_category
ORDER BY avg_gpa_change DESC;


-- Q3. Is greater use of AI associated with AI dependency?
SELECT 
    CASE 
        WHEN weekly_genai_hours < 5 THEN 'Low Usage'
        WHEN weekly_genai_hours BETWEEN 5 AND 15 THEN 'Medium Usage'
        ELSE 'High Usage'
    END AS ai_usage_level,
    COUNT(*) AS total_students,
    ROUND(AVG(weekly_genai_hours), 2) AS avg_weekly_genai_hours,
    ROUND(AVG(perceived_ai_dependency), 2) AS avg_ai_dependency
FROM dampak_ai
GROUP BY 
    CASE 
        WHEN weekly_genai_hours < 5 THEN 'Low Usage'
        WHEN weekly_genai_hours BETWEEN 5 AND 15 THEN 'Medium Usage'
        ELSE 'High Usage'
    END
ORDER BY avg_weekly_genai_hours;


-- Q4. How is the use of AI related to the skill retention score?
SELECT 
    CASE 
        WHEN weekly_genai_hours < 5 THEN 'Low Usage'
        WHEN weekly_genai_hours BETWEEN 5 AND 15 THEN 'Medium Usage'
        ELSE 'High Usage'
    END AS kategori_penggunaan_ai,
    CASE 
        WHEN weekly_genai_hours < 5 THEN 1
        WHEN weekly_genai_hours BETWEEN 5 AND 15 THEN 2
        ELSE 3
    END AS usage_sort,
    COUNT(student_id) AS total_students,
    ROUND(AVG(weekly_genai_hours), 2) AS avg_weekly_genai_hours,
    ROUND(AVG(skill_retention_score), 2) AS avg_skill_retention_score
FROM dampak_ai
GROUP BY 
    CASE 
        WHEN weekly_genai_hours < 5 THEN 'Low Usage'
        WHEN weekly_genai_hours BETWEEN 5 AND 15 THEN 'Medium Usage'
        ELSE 'High Usage'
    END,
    CASE 
        WHEN weekly_genai_hours < 5 THEN 1
        WHEN weekly_genai_hours BETWEEN 5 AND 15 THEN 2
        ELSE 3
    END
ORDER BY usage_sort;
