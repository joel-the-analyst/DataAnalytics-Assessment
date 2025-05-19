-- Q4: Customer Lifetime Value (CLV) Estimation

WITH customer_base AS (
    SELECT
        u.id AS customer_id,
        u.first_name,
        u.last_name,
        u.date_joined
    FROM
        users_customuser u
),

customer_savings AS (
    SELECT
        s.owner_id AS customer_id,
        SUM(s.confirmed_amount) AS total_amount_kobo,
        COUNT(s.id) AS total_transactions
    FROM
        savings_savingsaccount s
    WHERE
        s.confirmed_amount > 0
    GROUP BY
        s.owner_id
),

customer_metrics AS (
    SELECT
        cb.customer_id,
        CONCAT(cb.first_name, ' ', cb.last_name) AS name,
        TIMESTAMPDIFF(MONTH, cb.date_joined, CURDATE()) AS tenure_months,
        cs.total_transactions,

        -- CLV Estimate
        ROUND(
            (
                (cs.total_transactions / NULLIF(TIMESTAMPDIFF(MONTH, cb.date_joined, CURDATE()), 0)) * 12
                * ((cs.total_amount_kobo / 100.0) * 0.001 / NULLIF(cs.total_transactions, 0))
            ), 2
        ) AS estimated_clv
    FROM
        customer_base cb
    LEFT JOIN
        customer_savings cs ON cb.customer_id = cs.customer_id
)

SELECT
    *
FROM
    customer_metrics
ORDER BY
    estimated_clv DESC;
