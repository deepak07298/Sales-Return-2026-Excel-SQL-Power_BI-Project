USE sales_return;

DESCRIBE sales_data;

-- 1. Total Transaction
SELECT
    COUNT(*) AS total_transaction
FROM sales_data;

-- 2. Overall Business KPIs
SELECT
    COUNT(*) AS total_transaction,
    SUM(weight_qtl) AS total_weight,
    SUM(bags) AS total_bags,
    SUM(amount) AS total_amount,
    AVG(rate) AS average_rate
FROM sales_data;

-- 3. Year Wise Performance
SELECT
    YEAR(date) AS year,
    COUNT(*) AS transaction,
    SUM(weight_qtl) AS total_weight,
    SUM(amount) AS total_amount
FROM sales_data
GROUP BY YEAR(date)
ORDER BY year;

-- 4. Month Wise Performance
SELECT
    YEAR(date) AS year,
    MONTH(date) AS month,
    COUNT(*) AS transaction,
    SUM(amount) AS total_amount
FROM sales_data
GROUP BY YEAR(date), MONTH(date)
ORDER BY year, month;

-- 5. Material Wise Performance - Paddy
SELECT
    matrial,
    COUNT(*) AS transactions,
    SUM(weight_qtl) AS total_weight,
    SUM(bags) AS total_bags,
    SUM(amount) AS total_amount
FROM sales_data
WHERE matrial = 'paddy'
GROUP BY matrial
ORDER BY total_amount DESC;

-- 6. Daily Sales / Transaction Analysis
SELECT
    date,
    COUNT(*) AS total_transactions,
    SUM(weight_qtl) AS total_weight,
    SUM(amount) AS total_amount
FROM sales_data
WHERE date = '2026-07-17'
GROUP BY date
ORDER BY date;

-- 7. Party Wise Performance
SELECT
    party_address,
    COUNT(*) AS total_transaction,
    SUM(weight_qtl) AS total_weight,
    SUM(bags) AS total_bags,
    SUM(amount) AS total_amount
FROM sales_data
GROUP BY party_address
ORDER BY total_amount DESC;

-- 8. Top 10 Parties by Amount
SELECT
    party_address,
    SUM(amount) AS total_amount
FROM sales_data
GROUP BY party_address
ORDER BY total_amount DESC
LIMIT 10;

-- 9. Vehicle Wise Performance
SELECT
    vehicle_no,
    COUNT(*) AS trip,
    SUM(weight_qtl) AS total_weight,
    SUM(bags) AS total_bags,
    SUM(amount) AS total_amount
FROM sales_data
GROUP BY vehicle_no
ORDER BY total_amount DESC;

-- 10. Driver Wise Performance
SELECT
    driver_name,
    COUNT(*) AS trip,
    SUM(weight_qtl) AS total_weight,
    SUM(amount) AS total_amount
FROM sales_data
GROUP BY driver_name
ORDER BY total_weight DESC;

-- 11. Average Rate by Material
SELECT
    matrial,
    AVG(rate) AS average_rate,
    MIN(rate) AS minimum_rate,
    MAX(rate) AS maximum_rate
FROM sales_data
GROUP BY matrial
ORDER BY average_rate DESC;

-- 12. Highest Value Transactions
SELECT
    sr_no,
    date,
    vehicle_no,
    matrial,
    weight_qtl,
    rate,
    amount
FROM sales_data
ORDER BY amount DESC
LIMIT 10;

-- 13. Soyabean Party Wise Analysis
SELECT
    party_address,
    COUNT(*) AS transaction,
    SUM(weight_qtl) AS total_weight,
    SUM(bags) AS total_bags,
    SUM(amount) AS total_amount
FROM sales_data
WHERE matrial = 'soyabean'
GROUP BY party_address
ORDER BY total_amount DESC;

-- 14. Transaction Category by Amount
SELECT
    sr_no,
    date,
    matrial,
    amount,
    CASE
        WHEN amount >= 2000000 THEN 'High Value'
        WHEN amount >= 1000000 THEN 'Medium Value'
        ELSE 'Low Value'
    END AS transaction_category
FROM sales_data;

-- 15. Transaction Category Summary
SELECT
    CASE
        WHEN amount >= 2000000 THEN 'High Value'
        WHEN amount >= 1000000 THEN 'Medium Value'
        ELSE 'Low Value'
    END AS transaction_category,
    COUNT(*) AS transaction,
    SUM(weight_qtl) AS total_weight,
    SUM(amount) AS total_amount
FROM sales_data
GROUP BY transaction_category
ORDER BY total_amount DESC;

-- 16. Rank Parties by Total Amount
WITH party_summary AS (
    SELECT
        party_address,
        SUM(amount) AS total_amount
    FROM sales_data
    GROUP BY party_address
)
SELECT
    party_address,
    total_amount,
    DENSE_RANK() OVER (
        ORDER BY total_amount DESC
    ) AS party_rank
FROM party_summary
ORDER BY party_rank;

-- 17. Top 5 Parties
WITH party_summary AS (
    SELECT
        party_address,
        SUM(amount) AS total_amount
    FROM sales_data
    GROUP BY party_address
),
ranked_parties AS (
    SELECT
        party_address,
        total_amount,
        DENSE_RANK() OVER (
            ORDER BY total_amount DESC
        ) AS party_rank
    FROM party_summary
)
SELECT
    party_address,
    total_amount,
    party_rank
FROM ranked_parties
WHERE party_rank <= 5
ORDER BY party_rank;

-- 18. Material Contribution %
SELECT
    matrial,
    SUM(amount) AS total_amount,
    ROUND(
        SUM(amount) * 100.0 /
        SUM(SUM(amount)) OVER (),
        2
    ) AS contribution_percentage
FROM sales_data
GROUP BY matrial
ORDER BY contribution_percentage DESC;

-- 19. Material Wise Rank
SELECT
    matrial,
    SUM(amount) AS total_amount,
    RANK() OVER (
        ORDER BY SUM(amount) DESC
    ) AS material_rank
FROM sales_data
GROUP BY matrial
ORDER BY material_rank;

-- 20. Daily Running Total
WITH daily_sales AS (
    SELECT
        date,
        SUM(amount) AS daily_amount
    FROM sales_data
    GROUP BY date
)
SELECT
    date,
    daily_amount,
    SUM(daily_amount) OVER (
        ORDER BY date
    ) AS running_total
FROM daily_sales
ORDER BY date;

-- Final Material Business Summary
SELECT
    matrial,
    COUNT(*) AS transaction,
    SUM(weight_qtl) AS total_weight,
    SUM(bags) AS total_bags,
    ROUND(AVG(rate), 2) AS average_rate,
    SUM(amount) AS total_amount,
    ROUND(
        SUM(amount) * 100.0 /
        SUM(SUM(amount)) OVER (),
        2
    ) AS contribution_percentage,
    DENSE_RANK() OVER (
        ORDER BY SUM(amount) DESC
    ) AS material_rank
FROM sales_data
GROUP BY matrial
ORDER BY material_rank;
