-- Question 3: Find active savings or investment accounts with no transactions in the last 365 days

-- Savings accounts with no transactions in the last 365 days
WITH savings_last_txn AS (
    SELECT 
        s.id AS plan_id,
        s.owner_id,
        'Savings' AS type,
        MAX(s.created_on) AS last_transaction_date,
        DATEDIFF(CURDATE(), MAX(s.created_on)) AS inactivity_days
    FROM 
        savings_savingsaccount s
    JOIN 
        plans_plan p ON s.plan_id = p.id
    WHERE 
        p.is_regular_savings = 1
        AND s.confirmed_amount > 0
    GROUP BY 
        s.id, s.owner_id
    HAVING 
        DATEDIFF(CURDATE(), MAX(s.created_on)) > 365
),

-- Investment plans with no transactions in the last 365 days
investment_last_txn AS (
    SELECT 
        p.id AS plan_id,
        p.owner_id,
        'Investment' AS type,
        MAX(p.created_on) AS last_transaction_date,
        DATEDIFF(CURDATE(), MAX(p.created_on)) AS inactivity_days
    FROM 
        plans_plan p
    WHERE 
        p.is_a_fund = 1
    GROUP BY 
        p.id, p.owner_id
    HAVING 
        DATEDIFF(CURDATE(), MAX(p.created_on)) > 365
)

-- Joined results
SELECT * FROM savings_last_txn
UNION ALL
SELECT * FROM investment_last_txn
ORDER BY inactivity_days DESC;
