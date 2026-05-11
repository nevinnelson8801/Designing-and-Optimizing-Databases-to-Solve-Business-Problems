-- ============================================================
-- Beneficiary Service Analysis Queries
-- Community Aid Hub — Chapter 4
-- ============================================================

-- ------------------------------------------------------------
-- 1. Service delivery efficiency — response time categories
--    Classifies beneficiaries by how quickly they received service
--    (Same Day / 2 Days / Over 2 Days) over the last 30 days
-- ------------------------------------------------------------
WITH ServiceMetrics AS (
    SELECT 
        b.beneficiary_id,
        COUNT(d.distribution_id)                          AS service_count,
        AVG(DATEDIFF(d.distribution_date, d.created_at)) AS avg_response_time
    FROM Beneficiaries b
    LEFT JOIN Distributions d ON b.beneficiary_id = d.beneficiary_id
    WHERE d.created_at >= DATE_SUB(CURDATE(), INTERVAL 30 DAY)
    GROUP BY b.beneficiary_id
)
SELECT 
    CASE 
        WHEN avg_response_time <= 1 THEN 'Same Day'
        WHEN avg_response_time <= 2 THEN '2 Days'
        ELSE 'Over 2 Days'
    END AS response_category,
    COUNT(*) AS beneficiary_count
FROM ServiceMetrics
GROUP BY response_category;

-- ------------------------------------------------------------
-- 2. Monthly service summary — last 12 months
--    Shows beneficiary reach and distributions per month,
--    plus average distributions per beneficiary
-- ------------------------------------------------------------
WITH MonthlyStats AS (
    SELECT 
        DATE_FORMAT(distribution_date, '%Y-%m')  AS month,
        COUNT(DISTINCT beneficiary_id)           AS beneficiary_count,
        COUNT(distribution_id)                   AS distribution_count
    FROM Distributions
    WHERE distribution_date >= DATE_SUB(CURRENT_DATE, INTERVAL 12 MONTH)
    GROUP BY DATE_FORMAT(distribution_date, '%Y-%m')
)
SELECT 
    month,
    beneficiary_count,
    distribution_count,
    distribution_count / beneficiary_count AS avg_distributions_per_beneficiary
FROM MonthlyStats
ORDER BY month;
