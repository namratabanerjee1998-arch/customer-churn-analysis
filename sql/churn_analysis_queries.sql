-- Q1: Overall Churn Rate Summary
SELECT
    COUNT(*) AS Total_Customers,
    SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END) AS Churned,
    ROUND(SUM(CASE WHEN Churn='Yes' THEN 1.0 ELSE 0 END) / COUNT(*) * 100,2) AS Churn_Rate_Pct,
    ROUND(AVG(CASE WHEN Churn='Yes' THEN MonthlyCharges END),2) AS Avg_Churned_Monthly_Bill
FROM customers;

-- Q2: Churn Rate by Contract Type (KEY INSIGHT)
SELECT
    Contract,
    COUNT(*) AS Total,
    SUM(CASE WHEN Churn='Yes' THEN 1 ELSE 0 END) AS Churned,
    ROUND(SUM(CASE WHEN Churn='Yes' THEN 1.0 ELSE 0 END) / COUNT(*) * 100, 2) AS Churn_Rate_Pct
FROM customers
GROUP BY Contract
ORDER BY Churn_Rate_Pct DESC;

-- Q3: Cohort Analysis — Churn by Tenure Bucket
SELECT
    CASE
        WHEN tenure BETWEEN 0 AND 12  THEN '0-12 months (New)'
        WHEN tenure BETWEEN 13 AND 24 THEN '13-24 months'
        WHEN tenure BETWEEN 25 AND 48 THEN '25-48 months'
        ELSE '49+ months (Loyal)'
    END AS Tenure_Cohort,
    COUNT(*) AS Customers,
    ROUND(SUM(CASE WHEN Churn='Yes' THEN 1.0 ELSE 0 END) / COUNT(*) * 100,2) AS Churn_Pct,
    ROUND(AVG(MonthlyCharges),2) AS Avg_Monthly_Charge
FROM customers
GROUP BY Tenure_Cohort
ORDER BY Churn_Pct DESC;

-- Q4: Churn by Internet Service Type
SELECT InternetService,
    COUNT(*) AS Customers,
    ROUND(SUM(CASE WHEN Churn='Yes' THEN 1.0 ELSE 0 END) / COUNT(*) * 100,2) AS Churn_Rate,
    ROUND(AVG(MonthlyCharges),2) AS Avg_Bill
FROM customers
GROUP BY InternetService;

-- Q5: High-Risk Segment — Month-to-Month + Fiber + Electronic Check
SELECT
    COUNT(*) AS Segment_Size,
    ROUND(SUM(CASE WHEN Churn='Yes' THEN 1.0 ELSE 0 END) / COUNT(*) * 100,2) AS Churn_Rate,
    ROUND(SUM(CASE WHEN Churn='Yes' THEN MonthlyCharges ELSE 0 END),2) AS Revenue_At_Risk
FROM customers
WHERE Contract = 'Month-to-month'
  AND InternetService = 'Fiber optic'
  AND PaymentMethod = 'Electronic check';

-- Q6: Churn Rate by Senior Citizen Status
SELECT SeniorCitizen,
    COUNT(*) AS Customers,
    ROUND(SUM(CASE WHEN Churn='Yes' THEN 1.0 ELSE 0 END) / COUNT(*) * 100,2) AS Churn_Rate
FROM customers
GROUP BY SeniorCitizen;

-- Q7: Monthly Revenue Lost to Churn
SELECT
    ROUND(SUM(CASE WHEN Churn='Yes' THEN MonthlyCharges ELSE 0 END),2) AS Monthly_Revenue_Lost,
    ROUND(SUM(CASE WHEN Churn='Yes' THEN TotalCharges ELSE 0 END),2) AS Lifetime_Revenue_Lost
FROM customers;

-- Q8: Impact of Tech Support on Churn
SELECT TechSupport,
    ROUND(SUM(CASE WHEN Churn='Yes' THEN 1.0 ELSE 0 END) / COUNT(*) * 100,2) AS Churn_Rate
FROM customers
WHERE TechSupport != 'No internet service'
GROUP BY TechSupport;

-- Q9: Top Churn Risk Customers (for retention team)
SELECT tenure, Contract, MonthlyCharges, InternetService,
    CASE
        WHEN Contract='Month-to-month' AND tenure < 12
             AND MonthlyCharges > 70 THEN 'HIGH RISK'
        WHEN Contract='Month-to-month' AND tenure < 24 THEN 'MEDIUM RISK'
        ELSE 'LOW RISK'
    END AS Risk_Level
FROM customers
WHERE Churn = 'No'  -- Only current customers
ORDER BY MonthlyCharges DESC
LIMIT 50;

-- Q10: Churn Rate by Number of Services (bundle effect)
SELECT
    (CASE WHEN PhoneService='Yes' THEN 1 ELSE 0 END +
     CASE WHEN InternetService != 'No' THEN 1 ELSE 0 END +
     CASE WHEN OnlineSecurity='Yes' THEN 1 ELSE 0 END +
     CASE WHEN TechSupport='Yes' THEN 1 ELSE 0 END) AS Services_Count,
    COUNT(*) AS Customers,
    ROUND(SUM(CASE WHEN Churn='Yes' THEN 1.0 ELSE 0 END) / COUNT(*) * 100,2) AS Churn_Rate
FROM customers
GROUP BY Services_Count
ORDER BY Services_Count;
