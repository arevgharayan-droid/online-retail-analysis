-- Cleans raw_transactions and creates the final table "sales".
-- raw_transactions is never modified.
-- Raw data: 541,909 rows
-- Step 1: remove cancelled invoices (InvoiceNo starts with 'C')
-- Removed: 9,288 | Remaining: 532,621
DROP TABLE IF EXISTS clean_transactions;
CREATE TABLE clean_transactions AS
SELECT * FROM raw_transactions
WHERE InvoiceNo NOT LIKE 'C%';
-- Step 2: remove rows with Quantity <= 0 (all of them had no CustomerID)
-- Removed: 1,336 | Remaining: 531,285
DELETE FROM clean_transactions WHERE Quantity <= 0;
-- Step 3: remove rows with UnitPrice <= 0
-- Removed: 1,181 | Remaining: 530,104
DELETE FROM clean_transactions WHERE UnitPrice <= 0;
-- Step 4: remove rows without CustomerID
-- Removed: 132,220 | Remaining: 397,884
DELETE FROM clean_transactions WHERE CustomerID IS NULL;
-- Step 5: remove exact duplicate rows and create the final table
-- Removed: 5,192 | Remaining: 392,692
DROP TABLE IF EXISTS sales;
CREATE TABLE sales AS
SELECT DISTINCT * FROM clean_transactions;
-- Remove the intermediate table
DROP TABLE clean_transactions;
-- Check: expected 392,692
SELECT COUNT(*) AS final_rows FROM sales;