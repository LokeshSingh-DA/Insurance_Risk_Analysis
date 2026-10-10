DROP DATABASE IF EXISTS risk_analysis;

CREATE DATABASE risk_analysis;

USE risk_analysis;



CREATE TABLE customer_master (
    customer_id VARCHAR(20) PRIMARY KEY,
    full_name VARCHAR(100) NOT NULL,
    age INT CHECK (age >= 18),
    gender VARCHAR(10) CHECK (gender IN ('Male', 'Female', 'Other')),
    marital_status VARCHAR(20),
    occupation VARCHAR(50),
    region VARCHAR(20) CHECK (region IN ('North', 'South', 'East', 'West', 'Central', 'North-East')),
    smoking_status VARCHAR(5),
    pre_existing_illness VARCHAR(5),
    risk_score FLOAT CHECK (risk_score BETWEEN 0 AND 1),
    date_joined DATE
);


CREATE TABLE agent_info (
    agent_id VARCHAR(20) PRIMARY KEY,
    region VARCHAR(20) CHECK (region IN ('North', 'South', 'East', 'West', 'Central', 'North-East')),
    join_date DATE,
    total_policies_sold INT,
    lapsed_policies INT,
    avg_premium_sold DECIMAL(10,2),
    fraud_association INT
);


CREATE TABLE policy_details (
    policy_id VARCHAR(20) PRIMARY KEY,
    customer_id VARCHAR(20) NOT NULL,
    product_type VARCHAR(50),
    coverage_amount DECIMAL(12,2),
    annual_premium DECIMAL(10,2),
    policy_start_date DATE,
    policy_end_date DATE,
    agent_id VARCHAR(20),
    status VARCHAR(20),
    FOREIGN KEY (customer_id) REFERENCES customer_master(customer_id),
    FOREIGN KEY (agent_id) REFERENCES agent_info(agent_id)
);


CREATE TABLE claim_history (
    claim_id VARCHAR(20) PRIMARY KEY,
    policy_id VARCHAR(20) NOT NULL,
    claim_date DATE,
    claim_amount DECIMAL(12,2) CHECK (claim_amount >= 0),
    claim_status VARCHAR(20) CHECK (claim_status IN ('Approved', 'Rejected', 'Pending')),
    claim_type VARCHAR(20),
    fraud_flag VARCHAR(5) CHECK (fraud_flag IN ('Yes', 'No')),
    days_to_process INT,
    FOREIGN KEY (policy_id) REFERENCES policy_details(policy_id)
);

CREATE TABLE customer_feedback (
    feedback_id VARCHAR(20) PRIMARY KEY,
    customer_id VARCHAR(20),
    date_submitted DATE,
    feedback_text TEXT,
    satisfaction_score INT CHECK (satisfaction_score BETWEEN 1 AND 5),
    contacted_agent VARCHAR(5) CHECK (contacted_agent IN ('Yes', 'No')),
    referred_claim VARCHAR(5) CHECK (referred_claim IN ('Yes', 'No')),
    FOREIGN KEY (Customer_ID) REFERENCES Customer_Master(Customer_ID)
);

/* Problem - Here if you try to directly import customer_feedback csv using table Data import wizard it
			will not import all rows.(only importing 631 rows and removing 369 rows)
    
    Cause - Some of the Feedbacks are anonymous meaning you cannot find those Customer_id in the main
			customer_master table and since you are using the constrain FOREIGN KEY it will only import the mathing rows
			in primary key customer_master.customer_Id
    
    Solution - There are multiple solutions for this but the most professional method is to create an another table customer_feedback_clone
				and not entering foreign key constrain. Then inserting all 1000 rows in that table.
                After that we can directly insert our data by Left joining clone table and main customer_master table. By doing that we can 
                identify those rows which are not in customer_master table then directly replacing there customer_id to null.
                
	Result - It will import all 1000 rows into Customer_feedback table it will show customer_id for 631 rows and nulls in other 369 rows.
*/


CREATE TABLE customer_feedback_staging (
    feedback_id VARCHAR(20),
    customer_id VARCHAR(20),
    date_submitted DATE,
    feedback_text TEXT,
    satisfaction_score INT,
    contacted_agent VARCHAR(5),
    referred_claim VARCHAR(5)
);


INSERT INTO customer_feedback (
    feedback_id,
    customer_id,
    date_submitted,
    feedback_text,
    satisfaction_score,
    contacted_agent,
    referred_claim
)
SELECT
    s.feedback_id,
    CASE
        WHEN c.customer_id IS NOT NULL THEN s.customer_id
        ELSE NULL
    END AS customer_id,
    s.date_submitted,
    s.feedback_text,
    s.satisfaction_score,
    s.contacted_agent,
    s.referred_claim
FROM customer_feedback_staging s
LEFT JOIN customer_master c
    ON s.customer_id = c.customer_id;
    
-- Here We can check all values are imported --
/*  SELECT 
    COUNT(*) AS total_feedback,
    SUM(customer_id IS NOT NULL) AS linked_feedback,
    SUM(customer_id IS NULL) AS anonymous_feedback
FROM
    customer_feedback;
*/

-- Now Droping the clone table because its use is over and it is taking extra space --
# DROP TABLE customer_feedback_staging;
