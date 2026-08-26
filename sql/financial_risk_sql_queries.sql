-- create transaction table

CREATE TABLE transactions (
    csv_index INT,
    trans_date_trans_time TIMESTAMP,
    cc_num VARCHAR(50),
    merchant VARCHAR(255),
    category VARCHAR(100),
    amt NUMERIC(10, 2),
    first VARCHAR(100),
    last VARCHAR(100),
    gender CHAR(1),
    street VARCHAR(255),
    city VARCHAR(100),
    state VARCHAR(10),
    zip INT,
    lat NUMERIC(9, 6),
    long NUMERIC(9, 6),
    city_pop INT,
    job VARCHAR(255),
    dob DATE,
    trans_num VARCHAR(255),
    unix_time BIGINT,
    merch_lat NUMERIC(9, 6),
    merch_long NUMERIC(9, 6),
    is_fraud INT
);

-- High-Risk Categories & Merchants: 
-- Which spending categories (e.g., travel, grocery_pos, shopping_net) see the highest volume and total dollar amount of fraud?

SELECT 
    category,
    COUNT(*) AS total_transactions,
    SUM(is_fraud) AS total_fraud_cases,
    ROUND((SUM(is_fraud)::DECIMAL / COUNT(*)) * 100, 2) AS fraud_rate_pct,
    ROUND(SUM(CASE WHEN is_fraud = 1 THEN amt ELSE 0 END), 2) AS total_fraud_loss_usd,
    ROUND(AVG(CASE WHEN is_fraud = 1 THEN amt ELSE 0 END), 2) AS avg_fraud_transaction_usd
FROM transactions
GROUP BY category
ORDER BY total_fraud_loss_usd DESC;

-- Demographic & Geographical Patterns: 
-- Are certain age groups, job titles, or state locations more vulnerable to fraudulent transactions?

WITH age_data AS (
    SELECT 
        amt,
        is_fraud,
        EXTRACT(YEAR FROM CURRENT_DATE)::INT - EXTRACT(YEAR FROM dob)::INT AS age
    FROM transactions
)
SELECT 
    CASE 
        WHEN age < 30 THEN '<30' 
        WHEN age BETWEEN 30 AND 49 THEN '30-49' 
        WHEN age BETWEEN 50 AND 64 THEN '50-64' 
        ELSE '65+' 
    END AS age_group, 
    COUNT(*) AS total_transaction_count, 
    SUM(CASE WHEN is_fraud = 1 THEN 1 ELSE 0 END) AS total_fraud_count, 
    SUM(CASE WHEN is_fraud = 1 THEN amt ELSE 0 END) AS total_fraud_dollar_loss, 
    ROUND((SUM(CASE WHEN is_fraud = 1 THEN 1 ELSE 0 END)::DECIMAL / COUNT(*)) * 100, 2) AS fraud_rate_percentage
FROM age_data
GROUP BY age_group
ORDER BY total_fraud_dollar_loss DESC;

-- Temporal Patterns: 
-- Do fraudulent charges spike at specific hours of the day or days of the week compared to legitimate transactions?

-- Hour of the Day Analysis

SELECT 
    EXTRACT(HOUR FROM trans_date_trans_time) AS hour_of_day, 
    COUNT(*) AS total_transaction_count, 
    SUM(is_fraud) AS total_fraud_count, 
    ROUND(SUM(CASE WHEN is_fraud = 1 THEN amt ELSE 0 END), 2) AS total_fraud_dollar_loss,  
    ROUND((SUM(is_fraud)::DECIMAL / COUNT(*)) * 100, 2) AS fraud_rate_percentage
FROM transactions
GROUP BY hour_of_day
ORDER BY total_fraud_count DESC;

-- Day of the Week Analysis

SELECT 
    TO_CHAR(trans_date_trans_time, 'Day') AS day_of_week,
    EXTRACT(ISODOW FROM trans_date_trans_time) AS day_num, -- Used to sort Monday-Sunday
    COUNT(*) AS total_transaction_count, 
    SUM(is_fraud) AS total_fraud_count, 
    ROUND(SUM(CASE WHEN is_fraud = 1 THEN amt ELSE 0 END), 2) AS total_fraud_dollar_loss,  
    ROUND((SUM(is_fraud)::DECIMAL / COUNT(*)) * 100, 2) AS fraud_rate_percentage
FROM transactions
GROUP BY day_of_week, day_num
ORDER BY day_num ASC;

-- Transaction Size Thresholds: 
-- Is there a clear average dollar amount difference between normal purchases and fraudulent ones?

SELECT 
    CASE WHEN is_fraud = 1 THEN 'Yes' ELSE 'No' END AS is_fraud_flag, 
    COUNT(*) AS total_transaction_count, 
    ROUND(AVG(amt), 2) AS average_transaction_amount, 
    MIN(amt) AS minimum_transaction_amount, 
    MAX(amt) AS maximum_transaction_amount, 
    PERCENTILE_CONT(0.5) WITHIN GROUP(ORDER BY amt) AS median_amount
FROM transactions
GROUP BY is_fraud;