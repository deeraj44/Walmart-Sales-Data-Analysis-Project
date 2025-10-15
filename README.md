
# 🛒 Walmart Sales Data Analysis Project

## 📘 Project Overview

This project analyzes a **Walmart sales dataset** to extract business insights and demonstrate **end-to-end data analysis skills**. The workflow involved **data cleaning with Python**, **SQL analysis using PostgreSQL**, and **interactive visualizations in Tableau**.

The dataset (5,000 transactions from 2024) contains sales facts (e.g., revenue, profit), product details (category, price, inventory levels), store locations, and customer attributes (age, gender, income, loyalty tier, payment method).

After cleaning the raw data in Python, key business questions were addressed with SQL queries, and the results were presented on three Tableau dashboards. The analysis covers:

- Overall sales performance  
- Top markets  
- Customer demographics & behavior  
- Product performance  
- Inventory insights  

---

## 🧰 Tools Used

| Tool | Purpose |
|------|----------|
| **Python (pandas)** | Data wrangling and cleaning — handled missing values, corrected data types, and computed new fields like total sales and profit. |
| **PostgreSQL** | Executed SQL queries for aggregations and business analysis (grouping by city, customer segment, product category, etc.). |
| **Tableau** | Built interactive dashboards visualizing trends and comparisons (monthly sales, geographical performance, customer segments, product breakdowns). |

---

## 📊 Key Analysis and Findings
<img width="1440" height="844" alt="image" src="https://github.com/user-attachments/assets/8d3e6e7d-5010-456a-a1aa-9bcfe0945be6" />

### 🏬 Sales & Store Performance

- **Total Sales:** ≈ **$15.3M**  
- **Total Profit:** ≈ **$3.8M** (≈25% margin)  
- **Transactions:** 5,000  
- **Average Order Value (AOV):** ≈ **$3,050**

#### **Monthly Sales Trend**
Sales steadily grew from **January ($1.73M)** to a peak in **August ($2.02M)** before a dip in **September ($0.91M)**, suggesting a seasonal slowdown or incomplete Q4 data. Profit followed a similar trend.

#### **Top Cities by Revenue**
| Rank | City | Revenue |
|------|------|----------|
| 1 | Los Angeles | $3.28M |
| 2 | Chicago | $3.16M |
| 3 | New York | $2.96M |
| 4 | Miami | $2.96M |
| 5 | Dallas | $2.90M |

> Revenue was well distributed across multiple cities — Walmart’s sales aren’t dominated by a single market.  
> **Insight:** Resource allocation and inventory planning should focus equally on these top-performing regions.

---

### 👥 Customer Insights

#### **Loyalty Program Impact**
- Tiers: Bronze, Silver, Gold, Platinum; each contributed roughly **25%** of total sales.  
- **Average spend** per customer: ~$3.2K–$3.3K across all tiers.  
- **Insight:** Loyalty tier didn’t greatly influence spending. The program’s benefit may lie in retention rather than immediate purchase value.

#### **Customer Demographics**
<img width="1441" height="828" alt="image" src="https://github.com/user-attachments/assets/3db8e37e-950a-4aeb-a0ca-4e5d41825cf8" />

- **Age:** 18–70 (avg. ~44 years)  
- **Gender:** Female & non-binary customers spent slightly more (~$3.4K) than male customers (~$3.2K).  
- **Insight:** Walmart appeals broadly across ages and genders; inclusivity is key to its success.

#### **Income and Spending**
- **Income range:** $20K–$120K (avg. ~$70K).  
- **Finding:** Spending didn’t strongly correlate with income. Both low- and high-income groups spent similarly.  
- **Insight:** Walmart’s customer appeal spans all income segments.

#### **Payment Methods**
| Method | % of Transactions |
|---------|-------------------|
| Credit Card | ~26% |
| Cash | ~25% |
| Digital Wallet | ~24% |
| Debit Card | ~25% |

> **Insight:** Payment preferences are evenly distributed — Walmart should continue supporting diverse payment options and leverage its own digital payment ecosystem.

---

### 📦 Product & Inventory Insights
<img width="1441" height="826" alt="image" src="https://github.com/user-attachments/assets/8b161bba-abc0-48da-8a0e-c7de5191bfc0" />

#### **Revenue by Category**
- **Electronics:** ~$7.94M (52%)  
- **Appliances:** ~$7.32M (48%)  
> Balanced contribution across both product lines. Walmart should continue investing in both equally.

#### **Top Performing Products**
| Rank | Product | Revenue | Units Sold |
|------|----------|----------|-------------|
| 1 | TV | ~$2.05M | ~1,950 |
| 2 | Tablet | ~$2.00M | ~1,880 |
| 3 | Fridge | ~$1.95M | ~1,967 |
| 4 | Smartphone | ~$1.94M | ~1,850 |
| 5 | Washing Machine | ~$1.92M | ~1,820 |

> **Insight:** Revenue is evenly spread across several top products, diversification reduces risk.

#### **Profit vs. Units Sold**
Profit scaled linearly with units sold, confirming consistent margins (~25%) across all products.  
> **Insight:** Increasing volume for popular items directly boosts profit; pricing is stable and well-balanced.

#### **Price Distribution**
- Range: **$50–$2,000**
- Most transactions in **$500–$1,500** range.
> **Insight:** Revenue mainly driven by mid-to-premium products, important for merchandising and inventory focus.

#### **Inventory & Stockouts**
- **Stockout Rate:** ~50% of transactions flagged as stockouts.  
> **Insight:** Indicates frequent sellouts; Walmart could refine reorder strategies and safety stock levels for high-demand products.

---

## 📈 Tableau Dashboards

The Tableau dashboards included:

1. **Sales & Store Performance Dashboard**  
   - KPIs (Total Sales, Profit, AOV)  
   - Monthly trend lines  
   - Top city bar chart  

2. **Customer Insights Dashboard**  
   - Spending by loyalty tier and gender  
   - Age distribution histogram  
   - Payment method pie chart  

3. **Product & Inventory Dashboard**  
   - Category-wise revenue split  
   - Top products by revenue  
   - Profit vs. units sold scatter plot  
   - Inventory and stockout tracker  

---

## 🎯 Lessons Learned

### **1. Understanding Customer Behavior**
- Walmart’s sales are broad-based; age, income, or loyalty tier didn’t drastically affect spending.
- The loyalty program appears more beneficial for retention than basket size.
- Balanced gender and income engagement highlight Walmart’s wide market reach.

### **2. Product Performance Insights**
- The top 5–10 products drive the majority of revenue.
- Margins are stable — profit grows linearly with sales volume.
- Frequent stockouts highlight the need for better demand forecasting and inventory planning.

### **3. Business Intelligence Process**
- End-to-end pipeline: **Python → SQL → Tableau**.
- Learned efficient data cleaning, SQL aggregation, and storytelling with dashboards.
- Reinforced the importance of clear narratives — every chart must answer a business question.

---

## 💡 Conclusion

This project provided a holistic understanding of Walmart’s 2024 sales data and hands-on experience with data cleaning, database querying, and visualization.  

The insights can help Walmart’s management in:
- Improving **inventory planning**
- Enhancing **city-level sales strategy**
- Strengthening **customer loyalty programs**

It also strengthened the analyst’s practical knowledge of **Python, SQL, and Tableau integration** — key tools for real-world business intelligence.

---

### 📂 Repository Structure (suggested for GitHub)

```
walmart_sales_analysis/
│
├── data/
│   └── walmart_cleaned.csv
│
├── notebooks/
│   └── data_cleaning.ipynb
│
├── sql/
│   └── walmart_analysis_queries.sql
│
├── tableau/
│   └── walmart_dashboard.twbx
└── README.md
```
