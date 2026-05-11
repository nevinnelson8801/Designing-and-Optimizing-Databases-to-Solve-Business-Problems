-- ============================================================
-- Transaction Management & Concurrency Control
-- Community Aid Hub — Chapter 4
-- ============================================================

-- ------------------------------------------------------------
-- 1. Distribution processing transaction
--    Atomically: deducts inventory, creates distribution record,
--    adds line items, and rolls back if stock goes negative
-- ------------------------------------------------------------
START TRANSACTION;

-- Deduct quantity from inventory
UPDATE InventoryItems 
SET quantity = quantity - @quantity
WHERE item_id = @item_id;

-- Create the distribution header record
INSERT INTO Distributions (distribution_id, beneficiary_id, distribution_date, status)
VALUES (@dist_id, @benef_id, CURDATE(), 'Processing');

-- Add line-item detail
INSERT INTO DistributionDetails (distribution_detail_id, distribution_id, item_id, quantity)
VALUES (@detail_id, @dist_id, @item_id, @quantity);

-- Only commit if inventory quantity remains non-negative
IF (SELECT quantity FROM InventoryItems WHERE item_id = @item_id) >= 0 THEN
    COMMIT;
ELSE
    ROLLBACK;
END IF;


-- ------------------------------------------------------------
-- 2. Optimistic Locking
--    Uses a version column to detect conflicting concurrent updates
-- ------------------------------------------------------------

-- Add version control column to InventoryItems
ALTER TABLE InventoryItems ADD COLUMN version INT DEFAULT 0;

-- Update with version check — fails silently if another process
-- already modified this row (version mismatch)
UPDATE InventoryItems 
SET quantity = quantity - @amount,
    version  = version + 1
WHERE item_id = @item_id 
  AND version = @original_version;


-- ------------------------------------------------------------
-- 3. Row-Level Locking (Pessimistic)
--    Locks the row for the duration of the transaction
-- ------------------------------------------------------------
SELECT quantity 
FROM InventoryItems 
WHERE item_id = @item_id 
FOR UPDATE;
