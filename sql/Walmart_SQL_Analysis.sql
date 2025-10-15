============================================================================
-- 1. REVENUE ANALYSIS - Monthly Performance & Growth Trends
-- ============================================================================
ALTER TABLE walmart__cleaned RENAME TO walmart_cleaned;

-- 1.1 Monthly Revenue Trends with Growth Rates
WITH monthly_revenue AS (
    SELECT 
        month,
        month_name,
        year,
        SUM(total_sales) as monthly_revenue,
        SUM(profit_margin) as monthly_profit,
        COUNT(*) as transaction_count,
        AVG(total_sales) as avg_transaction_value,
        COUNT(DISTINCT customer_id) as unique_customers
    FROM walmart_cleaned
    GROUP BY month, month_name, year
    ORDER BY month
),
revenue_growth AS (
    SELECT *,
        LAG(monthly_revenue) OVER (ORDER BY month) as prev_month_revenue,
        ROUND(
            CASE 
                WHEN LAG(monthly_revenue) OVER (ORDER BY month) IS NOT NULL 
                AND LAG(monthly_revenue) OVER (ORDER BY month) != 0
                THEN (monthly_revenue - LAG(monthly_revenue) OVER (ORDER BY month)) 
                     / LAG(monthly_revenue) OVER (ORDER BY month) * 100
                ELSE NULL
            END, 2
        ) as revenue_growth_pct,
        ROUND(monthly_profit / monthly_revenue * 100, 2) as profit_margin_pct
    FROM monthly_revenue
)
SELECT 
    month_name,
    ROUND(monthly_revenue::NUMERIC, 2) as monthly_revenue,
    ROUND(monthly_profit::NUMERIC, 2) as monthly_profit,
    transaction_count,
    ROUND(avg_transaction_value::NUMERIC, 2) as avg_transaction_value,
    unique_customers,
    revenue_growth_pct,
    profit_margin_pct
FROM revenue_growth
ORDER BY month;

-- 1.2 Top Performing Stores by Revenue
SELECT 
    store_location,
    city,
    state,
    ROUND(SUM(total_sales)::NUMERIC, 2) as total_revenue,
    ROUND(SUM(profit_margin)::NUMERIC, 2) as total_profit,
    COUNT(*) as total_transactions,
    COUNT(DISTINCT customer_id) as unique_customers,
    ROUND(AVG(total_sales)::NUMERIC, 2) as avg_transaction_value,
    ROUND((SUM(profit_margin) / SUM(total_sales) * 100)::NUMERIC, 2) as profit_margin_pct,
    RANK() OVER (ORDER BY SUM(total_sales) DESC) as revenue_rank
FROM walmart_cleaned
GROUP BY store_location, city, state
ORDER BY total_revenue DESC;

-- 1.3 Daily Performance Analysis (Day of Week Patterns)
SELECT 
    day_of_week,
    ROUND(SUM(total_sales)::NUMERIC, 2) as total_revenue,
    ROUND(SUM(profit_margin)::NUMERIC, 2) as total_profit,
    COUNT(*) as transaction_count,
    ROUND(AVG(total_sales)::NUMERIC, 2) as avg_transaction_value,
    COUNT(DISTINCT customer_id) as unique_customers,
    ROUND((SUM(total_sales) / SUM(SUM(total_sales)) OVER () * 100)::NUMERIC, 2) as revenue_share_pct
FROM walmart_cleaned
GROUP BY day_of_week
ORDER BY 
    CASE day_of_week 
        WHEN 'Monday' THEN 1
        WHEN 'Tuesday' THEN 2
        WHEN 'Wednesday' THEN 3
        WHEN 'Thursday' THEN 4
        WHEN 'Friday' THEN 5
        WHEN 'Saturday' THEN 6
        WHEN 'Sunday' THEN 7
    END;

-- ============================================================================
-- 2. CUSTOMER SEGMENTATION ANALYSIS
-- ============================================================================
-- 2.1 Customer Lifetime Value by Loyalty Tier
WITH customer_metrics AS (
    SELECT 
        customer_id,
        customer_loyalty_level,
        customer_income,
        customer_age,
        customer_gender,
        SUM(total_sales) AS lifetime_value,
        COUNT(*) AS total_transactions,
        AVG(total_sales) AS avg_transaction_value,
        -- If profit_margin is a percentage (e.g., 12.5 means 12.5%):
        SUM(total_sales * (profit_margin / 100.0)) AS total_profit_generated,
        -- If profit_margin is already a currency amount, use: SUM(profit_margin) AS total_profit_generated,
        MAX(transaction_date::date) AS last_purchase_date
    FROM walmart_cleaned
    GROUP BY customer_id, customer_loyalty_level, customer_income, customer_age, customer_gender
)
SELECT 
    customer_loyalty_level,
    COUNT(*) AS customer_count,
    ROUND(AVG(lifetime_value)::NUMERIC, 2) AS avg_customer_lifetime_value,
    ROUND(AVG(avg_transaction_value)::NUMERIC, 2) AS avg_transaction_value,
    ROUND(AVG(total_transactions)::NUMERIC, 1) AS avg_transaction_frequency,
    ROUND(AVG(customer_income)::NUMERIC, 0) AS avg_customer_income,
    ROUND(AVG(customer_age)::NUMERIC, 1) AS avg_customer_age,
    ROUND(SUM(lifetime_value)::NUMERIC, 2) AS total_segment_revenue,
    ROUND((SUM(lifetime_value) / SUM(SUM(lifetime_value)) OVER () * 100)::NUMERIC, 2) AS revenue_share_pct
FROM customer_metrics
GROUP BY customer_loyalty_level
ORDER BY avg_customer_lifetime_value DESC NULLS LAST;


-- 2.2 Payment Method Analysis with Customer Behavior
SELECT 
    payment_method,
    COUNT(*) as transaction_count,
    COUNT(DISTINCT customer_id) as unique_customers,
    ROUND(AVG(total_sales)::NUMERIC, 2) as avg_transaction_value,
    ROUND(SUM(total_sales)::NUMERIC, 2) as total_revenue,
    ROUND(AVG(customer_age)::NUMERIC, 1) as avg_customer_age,
    ROUND(AVG(customer_income)::NUMERIC, 0) as avg_customer_income,
    ROUND((SUM(total_sales) / SUM(SUM(total_sales)) OVER () * 100)::NUMERIC, 2) as revenue_share_pct,
    RANK() OVER (ORDER BY AVG(total_sales) DESC) as avg_value_rank
FROM walmart_cleaned
GROUP BY payment_method
ORDER BY avg_transaction_value DESC;

-- 2.3 Customer Demographics Analysis
WITH demographic_analysis AS (
    SELECT 
        customer_gender,
        CASE 
            WHEN customer_income < 30000 THEN 'Low (<$30K)'
            WHEN customer_income < 50000 THEN 'Lower-Mid ($30K-$50K)'
            WHEN customer_income < 70000 THEN 'Mid ($50K-$70K)'
            WHEN customer_income < 90000 THEN 'Upper-Mid ($70K-$90K)'
            ELSE 'High ($90K+)'
        END as income_bracket,
        CASE 
            WHEN customer_age < 25 THEN '18-24'
            WHEN customer_age < 35 THEN '25-34'
            WHEN customer_age < 45 THEN '35-44'
            WHEN customer_age < 55 THEN '45-54'
            ELSE '55+'
        END as age_group,
        COUNT(*) as transaction_count,
        COUNT(DISTINCT customer_id) as unique_customers,
        ROUND(AVG(total_sales)::NUMERIC, 2) as avg_transaction_value,
        ROUND(SUM(total_sales)::NUMERIC, 2) as total_revenue
    FROM walmart_cleaned
    GROUP BY customer_gender, 
        CASE 
            WHEN customer_income < 30000 THEN 'Low (<$30K)'
            WHEN customer_income < 50000 THEN 'Lower-Mid ($30K-$50K)'
            WHEN customer_income < 70000 THEN 'Mid ($50K-$70K)'
            WHEN customer_income < 90000 THEN 'Upper-Mid ($70K-$90K)'
            ELSE 'High ($90K+)'
        END,
        CASE 
            WHEN customer_age < 25 THEN '18-24'
            WHEN customer_age < 35 THEN '25-34'
            WHEN customer_age < 45 THEN '35-44'
            WHEN customer_age < 55 THEN '45-54'
            ELSE '55+'
        END
)
SELECT *,
    ROUND((total_revenue / SUM(total_revenue) OVER () * 100)::NUMERIC, 2) as revenue_share_pct
FROM demographic_analysis
ORDER BY avg_transaction_value DESC;

-- ============================================================================
-- 3. PRODUCT PERFORMANCE ANALYSIS
-- ============================================================================

-- 3.1 Top Products with Profitability Analysis
WITH product_performance AS (
    SELECT 
        product_name,
        category,
        SUM(total_sales) as total_revenue,
        SUM(profit_margin) as total_profit,
        SUM(quantity_sold) as total_units_sold,
        COUNT(*) as total_transactions,
        COUNT(DISTINCT customer_id) as unique_customers,
        AVG(unit_price) as avg_unit_price,
        ROUND((SUM(profit_margin) / SUM(total_sales) * 100)::NUMERIC, 2) as profit_margin_pct
    FROM walmart_cleaned
    GROUP BY product_name, category
)
SELECT *,
    ROUND((total_revenue / total_units_sold)::NUMERIC, 2) as revenue_per_unit,
    ROUND((total_profit / total_units_sold)::NUMERIC, 2) as profit_per_unit,
    RANK() OVER (ORDER BY total_revenue DESC) as revenue_rank,
    RANK() OVER (ORDER BY profit_margin_pct DESC) as profitability_rank,
    RANK() OVER (ORDER BY total_units_sold DESC) as volume_rank
FROM product_performance
ORDER BY total_revenue DESC;

-- 3.2 Category Performance Comparison
SELECT 
    category,
    ROUND(SUM(total_sales)::NUMERIC, 2) as category_revenue,
    ROUND(SUM(profit_margin)::NUMERIC, 2) as category_profit,
    SUM(quantity_sold) as category_units_sold,
    COUNT(*) as category_transactions,
    COUNT(DISTINCT customer_id) as unique_customers,
    COUNT(DISTINCT product_name) as unique_products,
    ROUND(AVG(total_sales)::NUMERIC, 2) as avg_transaction_value,
    ROUND(AVG(unit_price)::NUMERIC, 2) as avg_unit_price,
    ROUND((SUM(profit_margin) / SUM(total_sales) * 100)::NUMERIC, 2) as profit_margin_pct,
    ROUND((SUM(total_sales) / SUM(SUM(total_sales)) OVER () * 100)::NUMERIC, 2) as revenue_share_pct
FROM walmart_cleaned
GROUP BY category
ORDER BY category_revenue DESC;

-- 3.3 Product Price Analysis and Distribution
WITH price_analysis AS (
    SELECT 
        product_name,
        category,
        MIN(unit_price) as min_price,
        MAX(unit_price) as max_price,
        AVG(unit_price) as avg_price,
        STDDEV(unit_price) as price_std_dev,
        SUM(total_sales) as total_revenue,
        SUM(quantity_sold) as total_units_sold
    FROM walmart_cleaned
    GROUP BY product_name, category
)
SELECT *,
    CASE 
        WHEN avg_price < 500 THEN 'Budget (<$500)'
        WHEN avg_price < 1000 THEN 'Mid-Range ($500-$1000)'
        WHEN avg_price < 1500 THEN 'Premium ($1000-$1500)'
        ELSE 'Luxury ($1500+)'
    END as price_tier,
    ROUND((total_revenue / total_units_sold)::NUMERIC, 2) as revenue_per_unit
FROM price_analysis
ORDER BY total_revenue DESC;

-- ============================================================================
-- 4. PROMOTIONAL EFFECTIVENESS ANALYSIS
-- ============================================================================

-- 4.1 Promotion Impact Analysis
SELECT 
    promotion_applied,
    COALESCE(promotion_type, 'No Promotion') as promotion_type,
    COUNT(*) as transaction_count,
    ROUND(AVG(total_sales)::NUMERIC, 2) as avg_transaction_value,
    ROUND(SUM(total_sales)::NUMERIC, 2) as total_revenue,
    ROUND(AVG(profit_margin)::NUMERIC, 2) as avg_profit_per_transaction,
    ROUND(AVG(quantity_sold)::NUMERIC, 2) as avg_quantity_per_transaction,
    COUNT(DISTINCT customer_id) as unique_customers,
    COUNT(DISTINCT product_name) as unique_products
FROM walmart_cleaned
GROUP BY promotion_applied, promotion_type
ORDER BY avg_transaction_value DESC;

-- 4.2 Promotion Effectiveness by Customer Segment
SELECT 
    promotion_type,
    customer_loyalty_level,
    COUNT(*) as transaction_count,
    ROUND(AVG(total_sales)::NUMERIC, 2) as avg_transaction_value,
    ROUND(SUM(total_sales)::NUMERIC, 2) as total_revenue,
    ROUND(AVG(customer_income)::NUMERIC, 0) as avg_customer_income,
    COUNT(DISTINCT customer_id) as unique_customers
FROM walmart_cleaned
WHERE promotion_applied = 'true'
GROUP BY promotion_type, customer_loyalty_level
ORDER BY promotion_type, avg_transaction_value DESC;

-- 4.3 Seasonal and Weather Impact on Sales
SELECT 
    quarter,
    weather_conditions,
    holiday_indicator,
    COUNT(*) as transaction_count,
    ROUND(AVG(total_sales)::NUMERIC, 2) as avg_transaction_value,
    ROUND(SUM(total_sales)::NUMERIC, 2) as total_revenue,
    COUNT(DISTINCT customer_id) as unique_customers,
    ROUND(AVG(quantity_sold)::NUMERIC, 2) as avg_quantity_per_transaction
FROM walmart_cleaned
GROUP BY quarter, weather_conditions, holiday_indicator
ORDER BY quarter, avg_transaction_value DESC;

-- ============================================================================
-- 5. INVENTORY AND OPERATIONAL ANALYSIS
-- ============================================================================

-- 5.1 Inventory Performance and Stockout Analysis
SELECT 
    product_name,
    category,
    ROUND(AVG(inventory_level)::NUMERIC, 2) as avg_inventory_level,
    ROUND(AVG(reorder_point)::NUMERIC, 2) as avg_reorder_point,
    SUM(CASE WHEN stockout_indicator='true' THEN 1 ELSE 0 END) as total_stockouts,
    COUNT(*) as total_transactions,
    ROUND((SUM(CASE WHEN stockout_indicator='true' THEN 1 ELSE 0 END) / COUNT(*)::NUMERIC * 100), 2) as stockout_rate_pct,
    ROUND(SUM(total_sales)::NUMERIC, 2) as total_revenue,
    SUM(quantity_sold) as total_units_sold,
    ROUND((SUM(quantity_sold) / AVG(inventory_level))::NUMERIC, 2) as inventory_turnover_ratio
FROM walmart_cleaned
GROUP BY product_name, category
HAVING COUNT(*) >= 50  -- Filter for products with significant transaction volume
ORDER BY stockout_rate_pct DESC;

-- 5.2 Demand Forecasting Accuracy Analysis
WITH forecast_analysis AS (
    SELECT 
        product_name,
        category,
        month_name,
        AVG(forecasted_demand) as avg_forecasted_demand,
        AVG(actual_demand) as avg_actual_demand,
        AVG(forecast_accuracy) as avg_forecast_accuracy,
        COUNT(*) as transaction_count,
        SUM(total_sales) as total_revenue
    FROM walmart_cleaned
    GROUP BY product_name, category, month_name
)
SELECT 
    product_name,
    category,
    ROUND(AVG(avg_forecasted_demand)::NUMERIC, 2) as avg_forecasted_demand,
    ROUND(AVG(avg_actual_demand)::NUMERIC, 2) as avg_actual_demand,
    ROUND((AVG(avg_actual_demand) - AVG(avg_forecasted_demand))::NUMERIC, 2) as demand_variance,
    ROUND(((AVG(avg_actual_demand) - AVG(avg_forecasted_demand)) / AVG(avg_forecasted_demand) * 100)::NUMERIC, 2) as demand_variance_pct,
    ROUND(AVG(avg_forecast_accuracy)::NUMERIC, 2) as avg_forecast_accuracy,
    ROUND(SUM(total_revenue)::NUMERIC, 2) as total_revenue,
    CASE 
        WHEN AVG(avg_actual_demand) > AVG(avg_forecasted_demand) THEN 'Underforecasted'
        WHEN AVG(avg_actual_demand) < AVG(avg_forecasted_demand) THEN 'Overforecasted'
        ELSE 'Accurate'
    END as forecast_bias
FROM forecast_analysis
GROUP BY product_name, category
ORDER BY ABS(demand_variance_pct) DESC;

-- 5.3 Supplier Performance Analysis
SELECT 
    supplier_id,
    ROUND(AVG(supplier_lead_time)::NUMERIC, 2) as avg_lead_time,
    COUNT(DISTINCT product_name) as products_supplied,
    COUNT(*) as total_transactions,
    ROUND(SUM(total_sales)::NUMERIC, 2) as total_revenue,
    SUM(quantity_sold) as total_units_sold,
    ROUND(AVG(inventory_level)::NUMERIC, 2) as avg_inventory_level,
    SUM(CASE WHEN stockout_indicator ='true' THEN 1 ELSE 0 END) as total_stockouts,
    ROUND((SUM(CASE WHEN stockout_indicator='true' THEN 1 ELSE 0 END) / COUNT(*)::NUMERIC * 100), 2) as stockout_rate_pct
FROM walmart_cleaned
GROUP BY supplier_id
ORDER BY total_revenue DESC;

-- ============================================================================
-- 6. COMPREHENSIVE BUSINESS INSIGHTS SUMMARY
-- ============================================================================

-- 6.1 Executive KPI Dashboard Query
WITH business_metrics AS (
    SELECT 
        COUNT(*) as total_transactions,
        COUNT(DISTINCT customer_id) as unique_customers,
        COUNT(DISTINCT product_name) as unique_products,
        COUNT(DISTINCT store_location) as unique_stores,
        ROUND(SUM(total_sales)::NUMERIC, 2) as total_revenue,
        ROUND(SUM(profit_margin)::NUMERIC, 2) as total_profit,
        ROUND(AVG(total_sales)::NUMERIC, 2) as avg_transaction_value,
        ROUND((SUM(profit_margin) / SUM(total_sales) * 100)::NUMERIC, 2) as overall_profit_margin_pct,
        SUM(quantity_sold) as total_units_sold
    FROM walmart_cleaned
),
top_month AS (
    SELECT month_name
    FROM walmart_cleaned
    GROUP BY month_name
    ORDER BY SUM(total_sales) DESC
    LIMIT 1
),
top_store AS (
    SELECT store_location
    FROM walmart_cleaned
    GROUP BY store_location
    ORDER BY SUM(total_sales) DESC
    LIMIT 1
),
top_product AS (
    SELECT product_name
    FROM walmart_cleaned
    GROUP BY product_name
    ORDER BY SUM(total_sales) DESC
    LIMIT 1
),
top_segment AS (
    SELECT customer_loyalty_level
    FROM walmart_cleaned
    GROUP BY customer_loyalty_level
    ORDER BY AVG(total_sales) DESC
    LIMIT 1
)
SELECT 
    -- Business Overview
    (SELECT total_revenue FROM business_metrics) as total_revenue,
    (SELECT total_profit FROM business_metrics) as total_profit,
    (SELECT avg_transaction_value FROM business_metrics) as avg_transaction_value,
    (SELECT overall_profit_margin_pct FROM business_metrics) as profit_margin_pct,
    (SELECT total_transactions FROM business_metrics) as total_transactions,
    (SELECT unique_customers FROM business_metrics) as unique_customers,
    
    -- Key Insights
    (SELECT store_location FROM top_store) as best_performing_store,
    (SELECT product_name FROM top_product) as best_performing_product,
    (SELECT customer_loyalty_level FROM top_segment) as best_customer_segment,
    (SELECT month_name FROM top_month) as peak_revenue_month;

-- 6.2 Strategic Recommendations Query
WITH geographic_insight AS (
    SELECT 
        'Geographic Expansion' as recommendation_type,
        'Expand in West Coast markets' as recommendation,
        'Los Angeles leads with $' || ROUND((SUM(total_sales)/1000000)::NUMERIC, 2) || 'M revenue' as supporting_data
    FROM walmart_cleaned
    WHERE store_location LIKE '%Los Angeles%'
),
payment_insight AS (
    SELECT 
        'Digital Payment Strategy' as recommendation_type,
        'Incentivize digital wallet adoption' as recommendation,
        'Digital wallet users spend $' || ROUND(avg_digital::NUMERIC, 0) || ' vs $' || 
        ROUND(avg_credit::NUMERIC, 0) || ' for credit card users' as supporting_data
    FROM (
        SELECT 
            AVG(CASE WHEN payment_method = 'Digital Wallet' THEN total_sales END) as avg_digital,
            AVG(CASE WHEN payment_method = 'Credit Card' THEN total_sales END) as avg_credit
        FROM walmart_cleaned
    ) t
),
loyalty_insight AS (
    SELECT 
        'Loyalty Program Optimization' as recommendation_type,
        'Enhance Bronze/Silver tier benefits' as recommendation,
        'Platinum customers spend $' || ROUND(avg_platinum::NUMERIC, 0) || ' vs $' ||
        ROUND(avg_bronze::NUMERIC, 0) || ' for Bronze customers' as supporting_data
    FROM (
        SELECT 
            AVG(CASE WHEN customer_loyalty_level = 'Platinum' THEN total_sales END) as avg_platinum,
            AVG(CASE WHEN customer_loyalty_level = 'Bronze' THEN total_sales END) as avg_bronze
        FROM walmart_cleaned
    ) t
)
SELECT * FROM geographic_insight
UNION ALL
SELECT * FROM payment_insight
UNION ALL
SELECT * FROM loyalty_insight;

-- ============================================================================
-- ADDITIONAL POSTGRESQL-SPECIFIC OPTIMIZATIONS
-- ============================================================================

-- Create indexes for better query performance
CREATE INDEX IF NOT EXISTS idx_walmart_customer_id ON walmart_cleaned(customer_id);
CREATE INDEX IF NOT EXISTS idx_walmart_product_name ON walmart_cleaned(product_name);
CREATE INDEX IF NOT EXISTS idx_walmart_category ON walmart_cleaned(category);
CREATE INDEX IF NOT EXISTS idx_walmart_store_location ON walmart_cleaned(store_location);
CREATE INDEX IF NOT EXISTS idx_walmart_month ON walmart_cleaned(month);
CREATE INDEX IF NOT EXISTS idx_walmart_loyalty ON walmart_cleaned(customer_loyalty_level);
CREATE INDEX IF NOT EXISTS idx_walmart_payment ON walmart_cleaned(payment_method);

-- Update table statistics for query optimizer
ANALYZE walmart_cleaned;