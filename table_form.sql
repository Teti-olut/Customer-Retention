SELECT 
    TO_CHAR(a.cohort_month, 'YYYY-MM') AS cohort_month,
    COUNT(DISTINCT a.user_id) AS cohort_size,
    -- Period 0
    COUNT(DISTINCT CASE WHEN (DATE_PART('year', AGE(b.transaction_month, a.cohort_month)) * 12) + DATE_PART('month', AGE(b.transaction_month, a.cohort_month)) = 0 THEN a.user_id END) AS p0,
    -- Period 1
    COUNT(DISTINCT CASE WHEN (DATE_PART('year', AGE(b.transaction_month, a.cohort_month)) * 12) + DATE_PART('month', AGE(b.transaction_month, a.cohort_month)) = 1 THEN a.user_id END) AS p1,
    -- Period 2
    COUNT(DISTINCT CASE WHEN (DATE_PART('year', AGE(b.transaction_month, a.cohort_month)) * 12) + DATE_PART('month', AGE(b.transaction_month, a.cohort_month)) = 2 THEN a.user_id END) AS p2,
    -- Period 3
    COUNT(DISTINCT CASE WHEN (DATE_PART('year', AGE(b.transaction_month, a.cohort_month)) * 12) + DATE_PART('month', AGE(b.transaction_month, a.cohort_month)) = 3 THEN a.user_id END) AS p3,
    -- Period 4
    COUNT(DISTINCT CASE WHEN (DATE_PART('year', AGE(b.transaction_month, a.cohort_month)) * 12) + DATE_PART('month', AGE(b.transaction_month, a.cohort_month)) = 4 THEN a.user_id END) AS p4,
    -- Period 5
    COUNT(DISTINCT CASE WHEN (DATE_PART('year', AGE(b.transaction_month, a.cohort_month)) * 12) + DATE_PART('month', AGE(b.transaction_month, a.cohort_month)) = 5 THEN a.user_id END) AS p5,
    -- Period 6
    COUNT(DISTINCT CASE WHEN (DATE_PART('year', AGE(b.transaction_month, a.cohort_month)) * 12) + DATE_PART('month', AGE(b.transaction_month, a.cohort_month)) = 6 THEN a.user_id END) AS p6,
    -- Period 7
    COUNT(DISTINCT CASE WHEN (DATE_PART('year', AGE(b.transaction_month, a.cohort_month)) * 12) + DATE_PART('month', AGE(b.transaction_month, a.cohort_month)) = 7 THEN a.user_id END) AS p7,
    -- Period 8
    COUNT(DISTINCT CASE WHEN (DATE_PART('year', AGE(b.transaction_month, a.cohort_month)) * 12) + DATE_PART('month', AGE(b.transaction_month, a.cohort_month)) = 8 THEN a.user_id END) AS p8,
    -- Period 9
    COUNT(DISTINCT CASE WHEN (DATE_PART('year', AGE(b.transaction_month, a.cohort_month)) * 12) + DATE_PART('month', AGE(b.transaction_month, a.cohort_month)) = 9 THEN a.user_id END) AS p9
FROM (
    -- Step 1: Cohort Definition (Each user's first successful transaction month)
    SELECT user_id, DATE_TRUNC('month', MIN(transaction_date)) AS cohort_month
    FROM wallet_transactions
    WHERE status = 'success'
    GROUP BY user_id
) a
JOIN (
    -- Step 2: Time Series of Activity (All unique active transaction months per user)
    SELECT DISTINCT user_id, DATE_TRUNC('month', transaction_date) AS transaction_month
    FROM wallet_transactions
    WHERE status = 'success'
) b ON a.user_id = b.user_id
GROUP BY a.cohort_month
ORDER BY a.cohort_month;