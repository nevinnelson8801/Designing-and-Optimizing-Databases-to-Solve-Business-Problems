-- ============================================================
-- Inventory Management Queries
-- Community Aid Hub — Chapter 4
-- ============================================================

-- ------------------------------------------------------------
-- 1. Real-time inventory status with alert levels
--    Flags categories that are Critical (<100 units) or Low (<300)
-- ------------------------------------------------------------
SELECT 
    i.category,
    SUM(i.quantity) AS current_stock,
    CASE 
        WHEN SUM(i.quantity) < 100 THEN 'Critical'
        WHEN SUM(i.quantity) < 300 THEN 'Low'
        ELSE 'Adequate'
    END AS stock_status
FROM InventoryItems i
GROUP BY i.category
HAVING stock_status IN ('Critical', 'Low');

-- ------------------------------------------------------------
-- 2. Track items expiring within the next 30 days
--    Sorted by urgency (soonest expiry first)
-- ------------------------------------------------------------
SELECT 
    item_id,
    name,
    quantity,
    expiry_date,
    DATEDIFF(expiry_date, CURDATE()) AS days_until_expiry
FROM InventoryItems
WHERE expiry_date BETWEEN CURDATE() AND DATE_ADD(CURDATE(), INTERVAL 30 DAY)
ORDER BY days_until_expiry;
