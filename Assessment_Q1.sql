/** 
Question 1:
Write a query to find customers with at least one funded savings plan AND 
one funded investment plan, sorted by total deposits. 
**/

-- Create a CTE named plan_counts
WITH plan_counts AS (
    SELECT 
        owner_id,
        COUNT(CASE WHEN is_regular_savings = 1 THEN 1 END) AS savings_count,
        COUNT(CASE WHEN is_a_fund = 1 THEN 1 END) AS investment_count
    FROM plans_plan
    GROUP BY owner_id
),

-- Create a CTE named total_deposits
total_deposits AS (
    SELECT 
        owner_id,
        SUM(confirmed_amount) AS total_amount
    FROM savings_savingsaccount
    WHERE confirmed_amount > 0
    GROUP BY owner_id
)

-- Combined Queries
SELECT 
    u.id AS owner_id,
    CONCAT(u.first_name, ' ', u.last_name) AS name,
    COALESCE(p.savings_count, 0) AS savings_count,
    COALESCE(p.investment_count, 0) AS investment_count,
    ROUND(COALESCE(sa.total_amount, 0) / 100.0, 2) AS total_deposits
FROM users_customuser u
JOIN plan_counts p ON u.id = p.owner_id
LEFT JOIN total_deposits sa ON u.id = sa.owner_id
WHERE p.savings_count > 0 AND p.investment_count > 0
ORDER BY total_deposits DESC;
