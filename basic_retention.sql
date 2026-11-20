WITH user_cohorts AS (
    -- Step 1: Define each user's cohort month (first successful transaction month)
    SELECT 
        user_id, 
        DATE_TRUNC('month', MIN(transaction_date)) AS cohort_month
    FROM wallet_transactions
    WHERE status = 'success'
    GROUP BY user_id
),

user_activity_months AS (
    -- Step 2: Time series of activity (unique active months per user)
    SELECT DISTINCT 
        user_id, 
        DATE_TRUNC('month', transaction_date) AS transaction_month
    FROM wallet_transactions
    WHERE status = 'success'
),

period_counts AS (
    -- Step 3 & 4: Calculate elapsed months (period) and count unique active users
    SELECT 
        (DATE_PART('year', AGE(b.transaction_month, a.cohort_month)) * 12) + 
        DATE_PART('month', AGE(b.transaction_month, a.cohort_month)) AS period,
        COUNT(DISTINCT a.user_id) AS cohort_retained
    FROM user_cohorts a
    JOIN user_activity_months b 
        ON a.user_id = b.user_id
    GROUP BY 1
)

-- Step 5: Compute baseline cohort size (Period 0) and retention rate
SELECT 
    period,
    FIRST_VALUE(cohort_retained) OVER (ORDER BY period) AS cohort_size,
    cohort_retained,
    ROUND(
        (cohort_retained * 1.0) / FIRST_VALUE(cohort_retained) OVER (ORDER BY period), 
        4
    ) AS pct_retained
FROM period_counts
ORDER BY period;