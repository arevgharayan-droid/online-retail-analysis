-- 03_basic_analysis.sql
-- Basic sales analysis on the clean table "sales" (392,692 rows)

-- Monthly report: revenue, orders, customers, average order value, revenue per customer (ARPU)
-- Findings:
--   * Revenue is seasonal: it grows from September and peaks in November (~£1.16M),
--     about 2.6x February (~£446K), the weakest full month.
--   * November vs October: revenue +12%, orders +38%, customers +22%, AOV -19%.
--     The growth came from more orders and customers, not bigger orders.
--   * December 2011 is incomplete (data ends on 2011-12-09).
SELECT
    strftime('%Y-%m', InvoiceDate) AS month,
    ROUND(SUM(Quantity * UnitPrice)) AS revenue,
    COUNT(DISTINCT InvoiceNo) AS orders,
    COUNT(DISTINCT CustomerID) AS customers,
    ROUND(SUM(Quantity * UnitPrice) / COUNT(DISTINCT InvoiceNo), 2) AS avg_order_value,
    ROUND(SUM(Quantity * UnitPrice) / COUNT(DISTINCT CustomerID), 2) AS revenue_per_customer
FROM sales
GROUP BY month
ORDER BY month;