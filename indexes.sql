-- ============================================================
-- Advanced Index Definitions
-- Community Aid Hub — Chapter 5: Optimization Techniques
-- ============================================================

-- ------------------------------------------------------------
-- Composite index for donation tracking
-- Supports queries filtering by donor, date range, and status
-- ------------------------------------------------------------
CREATE INDEX idx_donation_tracking
    ON Donations(donor_id, donation_date, status);

-- ------------------------------------------------------------
-- Composite index for inventory management
-- Supports queries filtering by category, expiry, and quantity
-- ------------------------------------------------------------
CREATE INDEX idx_inventory_status
    ON InventoryItems(category, expiry_date, quantity);

-- ------------------------------------------------------------
-- Composite index for beneficiary service history
-- Supports queries joining on beneficiary_id and date range
-- ------------------------------------------------------------
CREATE INDEX idx_beneficiary_service
    ON Distributions(beneficiary_id, distribution_date);

-- ------------------------------------------------------------
-- Partial index for active volunteers only
-- Reduces index size by excluding inactive/suspended records
-- ------------------------------------------------------------
CREATE INDEX idx_active_volunteers
    ON Volunteers(status, skills)
    WHERE status = 'Active';

-- ------------------------------------------------------------
-- Covering index for frequently accessed donor contact info
-- Avoids table lookups when only contact fields are needed
-- ------------------------------------------------------------
CREATE INDEX idx_donor_contact
    ON Donors(donor_id, email, phone, status)
    INCLUDE (first_name, last_name);

-- ------------------------------------------------------------
-- Full-text search index for inventory search
-- Enables natural-language search on item name and description
-- ------------------------------------------------------------
CREATE FULLTEXT INDEX idx_inventory_search
    ON InventoryItems(name, description);

-- ------------------------------------------------------------
-- Query plan examples — use EXPLAIN to verify index usage
-- ------------------------------------------------------------

-- Should use idx_donation_tracking
EXPLAIN SELECT * 
FROM Donations 
WHERE donor_id = 'D001' 
  AND donation_date BETWEEN '2024-01-01' AND '2024-12-31';

-- Should use idx_inventory_status
EXPLAIN SELECT * 
FROM InventoryItems 
WHERE category = 'Food' 
  AND expiry_date < CURRENT_DATE;
