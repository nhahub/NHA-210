SELECT Student_ID, COUNT(*) AS Count
FROM student_performance
GROUP BY Student_ID
HAVING COUNT(*) > 1;

-- Convert (weekly_Study_Hours) to numeric
ALTER TABLE student_performance
MODIFY Weekly_Study_Hours DECIMAL(5,2);

-- Standardize categorical fields (fix inconsistent Yes/No, Gender)
UPDATE student_performance
SET Gender = CASE 
    WHEN LOWER(Gender) IN ('male', 'm') THEN 'Male'
    WHEN LOWER(Gender) IN ('female', 'f') THEN 'Female'
    ELSE 'Unknown'
END
WHERE Gender IS NOT NULL;


UPDATE student_performance
SET Assignment_Submission = CASE WHEN LOWER(Assignment_Submission) = 'yes' THEN 'Yes' ELSE 'No' END,
    Assessment_Improvement = CASE WHEN LOWER(Assessment_Improvement) = 'yes' THEN 'Yes' ELSE 'No' END,
    Has_Disciplinary_Record = CASE WHEN LOWER(Has_Disciplinary_Record) = 'yes' THEN 'Yes' ELSE 'No' END,
    Dropout = CASE WHEN LOWER(Dropout) = 'yes' THEN 'Yes' ELSE 'No' END,
    Graduation = CASE WHEN LOWER(Graduation) = 'yes' THEN 'Yes' ELSE 'No' END,
    Overall_Pass = CASE WHEN LOWER(Overall_Pass) = 'yes' THEN 'Yes' ELSE 'No' END;

-- Handle impossible or missing values
-- Replace negative or unrealistic ages
UPDATE student_performance
SET Age = NULL
WHERE Age < 5 OR Age > 30;

-- Replace null or empty strings with NULL
UPDATE student_performance
SET Weekly_Study_Hours = NULL
WHERE Weekly_Study_Hours = '' OR Weekly_Study_Hours IS NULL;

-- The Whole Table
use student_performance_db;
SELECT 
    *
FROM
    student_performance;
    
                                        -- KPI Category (KPi name , KPI name)

-- Academic Achievement (Average Grade , Pass Rate)
SELECT 
    AVG((Math + Science + English + History + Geography) / 5) AS Avg_Grade,
    ROUND(COUNT(CASE
                WHEN Overall_Pass = 'Yes' THEN 1
            END) * 100.0 / COUNT(*),
            2) AS Pass_Rate
FROM
    student_performance;

-- Engagement (Attendance Rate , Assignment Submission Rate )
SELECT 
    AVG(Attendance_Percentage) AS Avg_Attendance,
    ROUND(COUNT(CASE
                WHEN Assignment_Submission = 'Yes' THEN 1
            END) * 100.0 / COUNT(*),
            2) AS Submission_Rate
FROM
    student_performance;

-- Learning Progress (Assessment Improvement Rate)

SELECT 
    ROUND(COUNT(CASE
                WHEN Assessment_Improvement = 'Yes' THEN 1
            END) * 100 / COUNT(*),
            2) AS Assessment_Improvement_Rate
FROM
    student_performance;

-- Behavioral Indicators (Disciplinary Records , Interaction Frequency (Avg))
SELECT 
    ROUND(AVG(Disciplinary_Records) * 100, 2) AS Disciplinary_Records_rate,
    AVG(Interaction_Frequency) AS Avg_Interaction_Frequency
FROM
    student_performance;
    
-- Retention & Completion (Dropout Rate , Graduation Rate)
SELECT 
    ROUND(COUNT(CASE
                WHEN dropout = 'yes' THEN 1
            END) * 100 / COUNT(*),
            2) AS Dropout_Rate,
    ROUND(COUNT(CASE
                WHEN graduation = 'yes' THEN 1
            END) * 100 / COUNT(*),
            2) AS Graduation_Rate
FROM
    student_performance;
    
										-- Summary Dashboard view (for visualizasion)
                                        
	CREATE OR REPLACE VIEW student_kpi_dashboard AS
SELECT
    ROUND(AVG((Math + Science + English + History + Geography) / 5), 2) AS Avg_Grade,
    ROUND(SUM(CASE WHEN Overall_Pass = 'Yes' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS Pass_Rate,
    ROUND(AVG(Attendance_Percentage), 2) AS Avg_Attendance,
    ROUND(SUM(CASE WHEN Assignment_Submission = 'Yes' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS Submission_Rate,
    ROUND(SUM(CASE WHEN Assessment_Improvement = 'Yes' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS Assessment_Improvement_Rate,
    ROUND(AVG(Disciplinary_Records) * 100, 2) AS Disciplinary_Records_Rate,
    ROUND(AVG(Interaction_Frequency), 2) AS Avg_Interaction_Frequency,
    ROUND(SUM(CASE WHEN Dropout = 'Yes' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS Dropout_Rate,
    ROUND(SUM(CASE WHEN Graduation = 'Yes' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS Graduation_Rate
FROM student_performance;

select * from student_kpi_dashboard;