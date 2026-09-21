-- ============================================
-- QA Release & Defect Analytics — SQL Queries
-- ============================================

-- 1. Total defects by module
SELECT 
    module,
    COUNT(*) AS total_defects
FROM defects
GROUP BY module
ORDER BY total_defects DESC;


-- 2. Defects by module, as % of all defects
SELECT 
    module,
    COUNT(*) AS total_defects,
    CAST(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM defects) AS DECIMAL(5,1)) AS pct_of_all_defects
FROM defects
GROUP BY module
ORDER BY total_defects DESC;


-- 3. Defects by module and where they were found (QA / UAT / Production)
SELECT 
    module,
    found_in,
    COUNT(*) AS defect_count
FROM defects
GROUP BY module, found_in
ORDER BY module, found_in;


-- 4. Production leakage rate by module (key finding query)
-- What % of each module's defects reached Production instead of being
-- caught earlier in QA or UAT.
SELECT 
    module,
    COUNT(*) AS total_defects,
    SUM(CASE WHEN found_in = 'Production' THEN 1 ELSE 0 END) AS production_defects,
    CAST(SUM(CASE WHEN found_in = 'Production' THEN 1 ELSE 0 END) * 100.0 
         / COUNT(*) AS DECIMAL(5,1)) AS production_leakage_pct
FROM defects
GROUP BY module
ORDER BY production_leakage_pct DESC;


-- 5. Average resolution time by severity
-- Confirms Critical defects are resolved fastest, Low severity slowest.
SELECT 
    severity,
    COUNT(*) AS total_defects,
    AVG(DATEDIFF(day, date_reported, date_resolved)) AS avg_days_to_resolve
FROM defects
WHERE status = 'Resolved'
GROUP BY severity
ORDER BY 
    CASE severity 
        WHEN 'Critical' THEN 1 
        WHEN 'High' THEN 2 
        WHEN 'Medium' THEN 3 
        WHEN 'Low' THEN 4 
    END;


-- 6. Sanity check counts (used to validate the data load)
SELECT COUNT(*) AS total_defects FROM defects;
SELECT COUNT(*) AS total_releases FROM releases;
SELECT COUNT(*) AS total_test_cases FROM test_cases;
