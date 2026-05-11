-- ============================================================
-- Query Optimization Examples
-- Community Aid Hub — Chapter 5: Optimization Techniques
-- ============================================================

-- ------------------------------------------------------------
-- 1. Beneficiary distribution count
--    BEFORE: LEFT JOIN with GROUP BY (full scan risk on large tables)
-- ------------------------------------------------------------
-- Original query
SELECT b.beneficiary_id, b.family_name, 
       COUNT(d.distribution_id) AS distribution_count
FROM Beneficiaries b
LEFT JOIN Distributions d ON b.beneficiary_id = d.beneficiary_id
GROUP BY b.beneficiary_id, b.family_name;

-- AFTER: Correlated subquery — more readable and index-friendly
SELECT b.beneficiary_id, b.family_name,
       (SELECT COUNT(*) 
        FROM Distributions d 
        WHERE d.beneficiary_id = b.beneficiary_id) AS distribution_count
FROM Beneficiaries b;

-- ------------------------------------------------------------
-- 2. Monthly distribution analytics — last 12 months
--    Uses a CTE for clarity and single-pass aggregation
-- ------------------------------------------------------------
WITH MonthlyStats AS (
    SELECT 
        DATE_FORMAT(distribution_date, '%Y-%m') AS month,
        COUNT(DISTINCT beneficiary_id)          AS beneficiary_count,
        COUNT(distribution_id)                  AS distribution_count
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

-- ------------------------------------------------------------
-- 3. EXISTS vs IN for donor filtering
--    EXISTS short-circuits on the first match — faster when the
--    inner result set is large
-- ------------------------------------------------------------
-- Using EXISTS (preferred for performance)
SELECT d.donor_id, d.first_name, d.last_name
FROM Donors d
WHERE EXISTS (
    SELECT 1 
    FROM Donations dn 
    WHERE dn.donor_id = d.donor_id 
      AND dn.donation_date >= DATE_SUB(CURRENT_DATE, INTERVAL 6 MONTH)
);

-- Equivalent using IN (slower on large Donations tables)
SELECT donor_id, first_name, last_name
FROM Donors
WHERE donor_id IN (
    SELECT donor_id 
    FROM Donations
    WHERE donation_date >= DATE_SUB(CURRENT_DATE, INTERVAL 6 MONTH)
);
