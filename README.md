# Risk analytics and claim intelligence
### About Project 
AegisLife Insurance Pvt. Ltd. is a mid-sized Indian life and general insurance company that has recorded a consistent 35% year-on-year growth in policy issuance over the last three years.
This rapid expansion has brought new operational complexities, especially in how customer, policy, and claims data are monitored and interpreted.
The company is facing some challenges related to its operations. The Goal of this project is to recommend some data-driven suggestions to improve operational quality.

## Challanges
- High claim ratio that threaten profitability across certain regions and product line.
- Potential anomalies in claims data, possibly indication inefficient or fraudulent processing.

## Project Workflow

### 1 Excel

- Examined the data properly in excel.
- Finding anomalies and applying data validation where it is necessary.
- Then converted whole data into a Table.
- Opened power query editor to assigning correct data types to the columns and replacing errors with correct values.  
    1. In customer_master table : There were 10 typo error in region columns and 17 typo errors in gender column replaced them with correct value. 	ex- wset-> west, souht-> south.  
    2. In claim_history table : 6 typo errors in status column so changed those to correct values and claim_date was in text format so I used text to column to change it into date fromat (dd/mm/yyyy).  
    3. In customer_feedback table : date_submitted was also in text format similary used text to column to convert it into date format. There are 369 anonymous feedback which cannot be traced so I didn’t changed them.  
    4. In agent_info table : Converted join_date column into date.  
    5. In policy_details table : There were 4 typo error in product_type column so replaced them with correct value and changed data type of policy_start_date and policy_end date columns.  
- Created a data_quality_log table where summarized data issues, anomalities, inconsistency there total count and error percentage.
- After that saved these files as both .xlsx and .csv ( for SQL)



### 2 Imported Data to MySQL

- Created Database risk_analysis.
- Then created DDL scripts for 5 tables customer_master, agent_info, policy_details, claim_history and customer_feedback.
- Used all important constrains to maintain data integrity.
  <img width="1164" height="389" alt="image" src="https://github.com/user-attachments/assets/f27c38e1-2a6d-4ad4-96e4-d36ba9c6f5e7" />
- Similarly created DDL scrips for other tables as well. After that saved it as a text file.
- Then reopened MYSQL and executed there.
- Then Imported all csv files using MySQL Workbench Table Data Import Wizard.
- MySQL cannot red dd/mm/yyyy as data format so before importing those tables go to csv tables in change it to yyyy/mm/dd. Only then it can recognize it as date.
- The Sequence of table import is important because all tables are related with primary and foreign keys it is important to import those table which has primary keys first then only you can import other tables otherwise it will throw an error.
   Sequence :   
      1. customer_master  
      2. agent_info  
      3. policy_details  
      4. claim_history  
      5. customer_feedback  
- Problem - Here if you try to directly import customer_feedback csv using table Data import wizard it will not import all rows.(only importing 631 rows and removing 369 rows)
- Cause - Some of the Feedbacks are anonymous meaning you cannot find those Customer_id in the main customer_master table and since you are using the constrain FOREIGN KEY it will only import the mathing rows in primary key customer_master.customer_Id.
- Solution - There are multiple solutions for this but the most professional method is to create another table customer_feedback_clone and not entering foreign key constrain. Then inserting all 1000 rows in that table. After that we can directly insert our data by Left joining clone table and main customer_master table. By doing that we can identify those rows which are not in customer_master table then directly replacing customer_id to null.

- Now all the tables are imported. Quickly checked if all data has been imported correctly.
- Check if all the relations are correct.
- Created an ER-Diagram for this relational database.
<img width="1184" height="688" alt="image" src="https://github.com/user-attachments/assets/4fe4c1b2-d17c-4ca6-b73a-acd1e97da9ff" />



### 3 Connected MySQL with Python

- Imported libraries and made connection
<img width="1097" height="442" alt="image" src="https://github.com/user-attachments/assets/55c2b62e-8ea8-48fe-8747-e6d15cd58101" />
- Now preparing data for analysis in python
    - Checking Null values
    - Data types
    - Duplicate values
- Created some helper columns.
- Created some charts for EDA.
- Then run sum Hypothesis test to find the causes of High claim rate and fraud ratio.
- Main tests were:
      - Chi-square test of independence 
      - Kruskal-Wallis test
      - Mann-Whitney U test
- After numerous other test statistically there are not sufficient proofs to determine if customer region, marital status, occupation, smoking status or illness is the reason for high claim ration or fraudulent cases.<img width="2653" height="62" alt="image" src="https://github.com/user-attachments/assets/510552f9-6349-4b6b-9353-08a45dda2b1e" />
After test saved all main 5 dataframes as csv files.

### 4 Power BI
- Imported data using csv files.
- In power query editor created 3 folders in lift side pane.
    - Original Files
    - Dimensions
    - Facts
- Created facts and dimensions from from original files by taking them as reference.
- After creating both dimensions and facts I unticked enable load for all original files. Reason in data model we don't have any use of them now so hiding them is better for clean data model.
- After that created a Date table.
- After that created data model. The structure is **Star Schema** where each dimension is connecting facts together and no facts are directly connecting to each other.
  <img width="265" height="576" alt="image" src="https://github.com/user-attachments/assets/7718d9b5-dfdd-42b7-8990-abd0e6ee8fd5" />
- After that created a measures table where I created all important measure. By creating a new measure table I can find all measure in a single place rather than finding it everywhere.  
  #### This is the data model after everything.
  <img width="1585" height="708" alt="image" src="https://github.com/user-attachments/assets/5cbad21a-f56a-4c29-b2eb-ef9a8567cb88" />

- After that created 3 dashboard to present insights by visualizations.

## Business Insights

Key Findings :

**Payout Related Insights:**  
- Approved payout is ₹127.39M against ₹75.47M annual premium, producing a 168.80% payout-to-premium indicator. Which shows that that The portfolio needs urgent pricing, underwriting, and claims-cost review.  
- South has the highest regional ratio at 207.17%, followed by Central at 192.09% and East at 183.40%. Thus we have to prioritise South, Central, and East for deeper underwriting, claims, and product-mix review.  
- Health has the highest product ratio at 188.64%, followed by Whole Life at 177.57%. Because of that Health and Whole Life should be the first products reviewed for pricing adequacy, eligibility rules, exclusions, and claim severity so that we can target majority of our customers first.  

  
**Claims Related Insights:**  
- Claims and approved payout has a sudden spike in 2023 and which peaked in 2024: 540 claims and about ₹54M payout. The annual premium from year 2023 and 2024 was 24 and 15 Million rupees only. The 2023–24 period needs root-cause analysis like product mix, policy vintage, claim type, underwriting changes, or potential data-period effects.
- 454 claims are pending (32.29%), while 448 are rejected (31.86%) and average processing dates take 31 days this backlog and pending claims may worsen customer experience and this can be the reason for customer lapse rate. 



**Fraud Claims Insights:**
- Fraud-flagged claim rate is 49% This is unusually high in the insurance industry, normal fraud rates typically hover between 5% to 10%. Which points to systemic, severe operational failures. The company is likely failing to verify basic applicant information, allowing high-risk or fake identities to buy policies. A rate this high often indicates collusion, where corrupt employees or agents are actively working with fraudsters to bypass security checks.
- Death claims have the highest number of fraud flags (157), then Accident claims (140). Prioritise fraud-control review for Death and Accident claims.

**Customer Retention Insights:**
- South also has the highest lapse rate at 15.59%, followed by North at 15.30% and lowest lapse rate is 14.21% in North-East. The average lapse rate is around 14.90% which is high for insurance industry. South is a dual-risk region: highest payout indicator and highest customer attrition. Retention action should be region-specific after checking fraud claims and annual premium.
- Customer satisfaction is only 46.40%, average satisfaction is 3.22/5, and 339 customers are dissatisfied. Customer experience is a material issue, likely linked to claims handling, rejection communication, or delays.
- High fraud rate and high claim volume is major factor for the delay because of these reasons all background check are necessary and cases have to pass through multiple safety checks and stages. 
- Top 10 agents have premium books between ₹12.5M and ₹14.8M. Identify the practices of high-performing agents, but assess them alongside lapse rate, claims experience, and customer satisfaction—not premium volume alone.

## Recommendation
- **Launch a South-region risk review:** Review underwriting quality, agent practices, claim types, and policy mix in South; repeat for Central and East.
- **Review Health and Whole Life pricing:** Analyse coverage limits, premium adequacy, exclusions, pre-existing illness rules, and high-severity approved claims.
- **Reduce the pending-claim backlog:** Create claim-processing SLAs, ageing buckets, escalation for delayed claims, and a weekly pending-claims review.
- **Validate the fraud flag process:** Measure confirmed-fraud rate, false-positive rate, investigation turnaround time, and recovery amount. Avoid treating all flagged claims as confirmed fraud.
- **Improve communication with customer and customer satisfaction:** Analyse dissatisfied and claim-related feedback themes; improve status updates, rejection explanations, and claim-document guidance.
- **Create a regional agent scorecard:** Monitor each agent the practices of high-performing agents, but assess them alongside premium book, lapse rate, claim frequency, approved payout ratio, fraud flags, and customer satisfaction—not premium volume alone. Then create a agent scoreboard to rank them based on all the metioned criterias.


## Conclusion
- AegisLife’s immediate priorities are to investigate high payout exposure in South, Central, Health, and Whole Life portfolios. 
- Investigate all the suspicious activities and practices by agents to check if they have any involvement in high fraud cases.
- Do not declare all fraud flag cases as actual fraud cases. Do a double check and review benchmarks to verify if there are any issue with benchmarks of our company
- Reduce the pending-claims backlog
- Validate unusually high fraud flags and improve customer experience through clearer, faster claims handling.

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
Author:
Lokesh Singh
Linked In : https://www.linkedin.com/in/lokesh-singh-da/




