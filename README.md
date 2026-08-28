# Executive Fraud Risk & Loss Mitigation Dashboard

![Dashboard Preview](assets/dashboard_preview.png)

## 📌 Business Overview
This end-to-end data project analyzes **$1.13M in financial transaction fraud** across online (`_net`) and physical (`_pos`) channels. The interactive Power BI dashboard identifies high-risk exposure windows, key transaction categories, and operational mitigation strategies to minimize annual fraud loss.

---

## 🛠️ Tech Stack & Workflow
* **SQL:** Data extraction, aggregation, and initial data transformation.
* **Python:** Automated cleaning pipeline and feature engineering.
* **Power BI:** Data modeling, DAX measures, dark-mode UX design, and interactive filtering.

---

## 🔄 End-to-End Pipeline Architecture

![Data Pipeline Workflow](assets/pipeline_workflow.png)

---

## 📊 Core Business Insights

### 1. Risk Exposure
* **Channel Split:** Online transactions account for **63.4% ($718.35K)** of total fraud losses, compared to **36.6% ($414.98K)** in-person.
* **Primary Drivers:** `Shopping (Net)` generates **~$0.50M** in loss, followed by `Misc (Net)` at **$0.21M**.
* **Temporal Patterns:** Peak fraud volume occurs during the late-night window (**10 PM – 3 AM**), showing a sharp velocity drop-off after 4 AM.

### 2. Loss Mitigation Strategy
* **Rule 1 (MFA/3DS Step-Up):** Mandate dynamic multi-factor authentication on online transactions exceeding **$500** during late-night hours (**10 PM – 4 AM**).
* **Rule 2 (Velocity Capping):** Implement dynamic transaction limits on `Shopping (Net)` to cap automated card-testing scripts.
* **Financial Impact:** Targeted intervention on the top 20% overnight spikes projects an estimated **~$180K in annual loss prevention**.

---

## 📐 Key DAX Measures (`_Risk KPIs` Table)

```dax
// Total Fraud Loss
Total Fraud Loss = SUM(cleaned_financial_risk_data[amount])

// Online Fraud Loss
Online Fraud Loss = 
CALCULATE(
    [Total Fraud Loss], 
    cleaned_financial_risk_data[Channel] = "Online"
)

// In-Person Fraud Loss
In-Person Fraud Loss = 
CALCULATE(
    [Total Fraud Loss], 
    cleaned_financial_risk_data[Channel] = "In-Person"
)

// Fraud Loss Rate %
Fraud Loss Rate % = 
DIVIDE([Total Fraud Loss], SUM(cleaned_financial_risk_data[total_amount]), 0)
```