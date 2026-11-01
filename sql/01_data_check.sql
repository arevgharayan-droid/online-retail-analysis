 -- Total rows in raw data. Result: 541,909
SELECT COUNT(*) AS total_rows FROM raw_transactions;
-- Date range. Result: 2010-12-01 08:26 to 2011-12-09 12:50
SELECT MIN(InvoiceDate) AS first_date,
       MAX(InvoiceDate) AS last_date 
       FROM raw_transactions;