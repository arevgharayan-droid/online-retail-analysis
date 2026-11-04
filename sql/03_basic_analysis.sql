-- 03_basic_analysis.sql
-- Basic sales analysis on the clean table "sales" (392,688 rows)

-- 1. Overall KPIs (Dec 2010 - Dec 2011)
-- Result: revenue £8,602,289 | orders 18,528 | customers 4,337 | stock codes 3,664
--         AOV £464.29 | revenue per customer £1,983.47 | ~4.3 orders per customer
SELECT
    ROUND(SUM(Quantity * UnitPrice)) AS total_revenue,
    COUNT(DISTINCT InvoiceNo) AS total_orders,
    COUNT(DISTINCT CustomerID) AS total_customers,
    COUNT(DISTINCT StockCode) AS products,
    ROUND(SUM(Quantity * UnitPrice) / COUNT(DISTINCT InvoiceNo), 2) AS avg_order_value,
    ROUND(SUM(Quantity * UnitPrice) / COUNT(DISTINCT CustomerID), 2) AS revenue_per_customer
FROM sales;

-- 2. Monthly report: revenue, orders, customers, average order value, revenue per customer (ARPU)
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

-- 3. Top 10 products by revenue (service codes POST and M excluded)
-- Findings:
--   * #1 REGENCY CAKESTAND 3 TIER (~£142K): fewer units, higher price (~£11.50 per unit).
--   * JUMBO BAG RED RETROSPOT sold the most units among the top 10 (46,078) but is only #3 by revenue.
--   * Top 10 products = ~7.8% of revenue: revenue is spread across many products.
SELECT
    StockCode,
    Description,
    SUM(Quantity) AS units_sold,
    ROUND(SUM(Quantity * UnitPrice)) AS revenue
FROM sales
WHERE StockCode NOT IN ('POST', 'M')
GROUP BY StockCode, Description
ORDER BY revenue DESC
LIMIT 10;

-- 4. Revenue by country (top 10)
-- Findings:
--   * UK: 81.4% of revenue and ~90% of customers.
--   * Netherlands (9 customers, 3.3%) and EIRE (3 customers, 3.1%):
--     a few large, likely wholesale buyers -> customer concentration risk.
SELECT
    Country,
    ROUND(SUM(Quantity * UnitPrice)) AS revenue,
    COUNT(DISTINCT CustomerID) AS customers,
    COUNT(DISTINCT InvoiceNo) AS orders,
    ROUND(100.0 * SUM(Quantity * UnitPrice)
          / (SELECT SUM(Quantity * UnitPrice) FROM sales), 1) AS revenue_share_pct
FROM sales
GROUP BY Country
ORDER BY revenue DESC
LIMIT 10;