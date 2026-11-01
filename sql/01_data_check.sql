-- 01_data_check.sql
-- First look at the raw data (table: raw_transactions)
-- Missing values (checked in load_data.py): CustomerID 135,080; Description 1,454

-- Total rows in raw data. Result: 541,909
SELECT COUNT(*) AS total_rows FROM raw_transactions;

-- Date range. Result: 2010-12-01 08:26 to 2011-12-09 12:50
SELECT MIN(InvoiceDate) AS first_date,
       MAX(InvoiceDate) AS last_date
FROM raw_transactions;

-- Cancelled invoices (InvoiceNo starts with 'C'). Result: 9,288 rows
SELECT COUNT(*) AS cancelled_rows
FROM raw_transactions
WHERE InvoiceNo LIKE 'C%';

-- Rows with Quantity <= 0. Result: 10,624 rows
SELECT COUNT(*) AS non_positive_qty_rows
FROM raw_transactions
WHERE Quantity <= 0;

-- Hypothesis: all cancelled rows have Quantity <= 0,
-- so 10,624 - 9,288 = 1,336 non-cancelled rows should remain.
-- Result: 1,336 -> confirmed
SELECT COUNT(*) AS non_cancel_negative_qty_rows
FROM raw_transactions
WHERE Quantity <= 0
  AND InvoiceNo NOT LIKE 'C%';

-- Examples: Description is NULL, UnitPrice = 0, CustomerID is NULL
SELECT *
FROM raw_transactions
WHERE Quantity <= 0
  AND InvoiceNo NOT LIKE 'C%'
LIMIT 10;

-- Check on all rows: how many have no CustomerID?
-- Result: 1,336 of 1,336 -> likely stock adjustments, not customer sales
SELECT COUNT(*) AS non_cancel_negative_qty_no_customer
FROM raw_transactions
WHERE Quantity <= 0
  AND InvoiceNo NOT LIKE 'C%'
  AND CustomerID IS NULL;