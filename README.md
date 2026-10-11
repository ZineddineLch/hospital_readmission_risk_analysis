# hospital_readmission_risk_analysis


Problem presentation:
Business Problem: Hospitals face financial penalties when patients are readmitted within 30 days of leaving the hospital. This project looks at 10 years of fata from 130 U.S .
hospitals to find wich patients , diagnoses, and care patterns are linked to a higher rosk of readmission. The goal is to help care teams identify hight-risk patients, focus follow-up resources and prevent avoidabl readmission


Data & tools :
- Dataset: Diabetes 130-US Hospitals for Years 1999-2008 (CC BY 4.0). -100,100 patient encounters across 130 hospitals 1999-2008
- DataBase: MySql Workbench
- Techniques Used: CTEs, Window Function (rank,ntile), case-based risk tiering correlated subqueries and multi tabel joins



Approach/Methodology
- Cleaning: Replaced placeholder missing values with NULLs, removed a column with about 97% missing data, kept only one encounter per patient to avoid duplicate bias, and removed patients who were discharged to hospice or were discharged to hospice
- Exploratory analysis: Established baseline readmission rates by age, admission type, and diagnosis category.
- Advanced analysis: Built a reusable high-risk patient group with a pipeline, applied window function to rank patients by risk, grouped by medication use and number of diagnoses, and found diagnosis categories with above average readmission rates.
- Findings: Summarized the results into four key findings that connect back to the main business problem.
