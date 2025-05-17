WITH transaction_stats AS (
    SELECT 
        s.owner_id,
        COUNT(*) AS total_transactions,
        TIMESTAMPDIFF(MONTH, MIN(s.created_on), MAX(s.created_on)) + 1 AS active_months
    FROM 
        savings_savingsaccount s
    WHERE 
        s.confirmed_amount > 0
    GROUP BY 
        s.owner_id
),
categorized_users AS (
    SELECT 
        t.owner_id,
        (t.total_transactions * 1.0 / t.active_months) AS avg_txn_per_month,
        CASE 
            WHEN (t.total_transactions * 1.0 / t.active_months) >= 10 THEN 'High Frequency'
            WHEN (t.total_transactions * 1.0 / t.active_months) BETWEEN 3 AND 9 THEN 'Medium Frequency'
            ELSE 'Low Frequency'
        END AS frequency_category
    FROM 
        transaction_stats t
)
SELECT 
    frequency_category,
    COUNT(owner_id) AS customer_count,
    ROUND(AVG(avg_txn_per_month), 1) AS avg_transactions_per_month
FROM 
    categorized_users
GROUP BY 
    frequency_category
ORDER BY 
    FIELD(frequency_category, 'High Frequency', 'Medium Frequency', 'Low Frequency');
