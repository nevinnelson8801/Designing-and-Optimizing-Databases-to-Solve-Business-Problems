-- ============================================================
-- Volunteer Engagement Queries
-- Community Aid Hub — Chapter 4
-- ============================================================

-- ------------------------------------------------------------
-- 1. Volunteer activity analysis — last 30 days
--    Ranks volunteers by distributions handled and items distributed
-- ------------------------------------------------------------
SELECT 
    v.volunteer_id,
    CONCAT(v.first_name, ' ', v.last_name) AS volunteer_name,
    COUNT(d.distribution_id)               AS distributions_handled,
    SUM(dd.quantity)                       AS items_distributed
FROM Volunteers v
LEFT JOIN Distributions d
    ON v.volunteer_id = d.distributed_by
LEFT JOIN DistributionDetails dd
    ON d.distribution_id = dd.distribution_id
WHERE d.distribution_date >= DATE_SUB(CURDATE(), INTERVAL 30 DAY)
GROUP BY v.volunteer_id, volunteer_name
ORDER BY distributions_handled DESC;

-- ------------------------------------------------------------
-- 2. Active donors with a donation in the last 6 months
--    Uses EXISTS for better performance than IN with subquery
-- ------------------------------------------------------------
SELECT d.donor_id, d.first_name, d.last_name
FROM Donors d
WHERE EXISTS (
    SELECT 1 
    FROM Donations dn 
    WHERE dn.donor_id = d.donor_id 
      AND dn.donation_date >= DATE_SUB(CURRENT_DATE, INTERVAL 6 MONTH)
);
