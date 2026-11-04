-- 04_customer_analysis.sql
-- Customer analysis: new vs returning customers, repeat rate, cohort retention
-- Table: sales (392,688 rows). Uses CTEs and window functions.

-- 1. New customers by month (first purchase month, similar to FTD in iGaming)
-- Findings:
--   * December 2010 shows 885 "new" customers = all customers active that month.
--     The data starts on 2010-12-01, so every customer looks new (data limitation).
--   * New customers fall from 416 (Jan) to 169 (Aug), then grow in autumn (358 in Oct).
WITH first_purchase AS (
    SELECT CustomerID,
           MIN(InvoiceDate) AS first_date
    FROM sales
    GROUP BY CustomerID
)
SELECT
    strftime('%Y-%m', first_date) AS first_month,
    COUNT(*) AS new_customers
FROM first_purchase
GROUP BY first_month
ORDER BY first_month;

-- 2. New vs returning customers by month
-- Findings:
--   * Share of returning customers grows from 44% (Jan 2011) to 80-82% (Jul-Aug 2011).
--   * Early months are understated because the data starts in December 2010.
WITH first_purchase AS (
    SELECT CustomerID,
           strftime('%Y-%m', MIN(InvoiceDate)) AS first_month
    FROM sales
    GROUP BY CustomerID
),
monthly_customers AS (
    SELECT DISTINCT CustomerID,
           strftime('%Y-%m', InvoiceDate) AS month
    FROM sales
)
SELECT
    m.month,
    COUNT(*) AS active_customers,
    SUM(CASE WHEN m.month = f.first_month THEN 1 ELSE 0 END) AS new_customers,
    SUM(CASE WHEN m.month > f.first_month THEN 1 ELSE 0 END) AS returning_customers,
    ROUND(100.0 * SUM(CASE WHEN m.month > f.first_month THEN 1 ELSE 0 END)
          / COUNT(*), 1) AS returning_pct
FROM monthly_customers m
JOIN first_purchase f ON m.CustomerID = f.CustomerID
GROUP BY m.month
ORDER BY m.month;

-- 3. Repeat purchase rate (customers with 2+ orders)
-- Result: 2,843 of 4,337 customers = 65.6%
WITH customer_orders AS (
    SELECT CustomerID,
           COUNT(DISTINCT InvoiceNo) AS orders
    FROM sales
    GROUP BY CustomerID
)
SELECT
    COUNT(*) AS customers,
    SUM(CASE WHEN orders >= 2 THEN 1 ELSE 0 END) AS repeat_customers,
    ROUND(100.0 * SUM(CASE WHEN orders >= 2 THEN 1 ELSE 0 END) / COUNT(*), 1) AS repeat_rate_pct
FROM customer_orders;

-- 4. Cohort retention (cohort = first purchase month)
-- Findings:
--   * December 2010 cohort: 36.6% returned in month 1 (324 of 885),
--   --  About 32-40% were active again in months 1-10, and 50.3% in month 11 (November 2011).
--   * This cohort includes older loyal customers (data starts in Dec 2010),
--     so its retention is likely higher than for truly new cohorts.
WITH customer_months AS (
    SELECT DISTINCT
        CustomerID,
        strftime('%Y-%m', InvoiceDate) AS month,
        strftime('%Y-%m', MIN(InvoiceDate) OVER (PARTITION BY CustomerID)) AS cohort_month
    FROM sales
),
cohort_activity AS (
    SELECT
        cohort_month,
        (CAST(substr(month, 1, 4) AS INTEGER) - CAST(substr(cohort_month, 1, 4) AS INTEGER)) * 12
          + (CAST(substr(month, 6, 2) AS INTEGER) - CAST(substr(cohort_month, 6, 2) AS INTEGER)) AS month_number,
        COUNT(*) AS customers
    FROM customer_months
    GROUP BY cohort_month, month_number
)
SELECT
    cohort_month,
    month_number,
    customers,
    FIRST_VALUE(customers) OVER (PARTITION BY cohort_month ORDER BY month_number) AS cohort_size,
    ROUND(100.0 * customers
          / FIRST_VALUE(customers) OVER (PARTITION BY cohort_month ORDER BY month_number), 1) AS retention_pct
FROM cohort_activity
ORDER BY cohort_month, month_number;