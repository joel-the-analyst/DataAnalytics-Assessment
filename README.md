# DataAnalytics-Assessment


### **Question 1:  Customers with Funded Savings & Investment Plans**

**Objective:**  
Find customers who have **at least one funded savings plan** and **one funded investment plan**, sorted by their **total deposits**.

**Approach:**
To address this problem effectively, I broke the query into logical steps using Common Table Expressions (CTEs) for clarity and reusability.

**Step 1:** Identify Customers with Funded Plans
CTE: plan_counts

This CTE filters the plans_plan table to count, per customer (`owner_id`), how many plans fall into each category:

`is_regular_savings` = 1: considered a savings plan.

`is_a_fund` = 1: considered an investment plan.

**Step 2:** Calculate Total Deposits
CTE: total_deposits

From the `savings_savingsaccount` table, I filtered rows where `confirmed_amount` > 0, indicating funded transactions.

I then aggregated the total amount per `owner_id`.

**Step 3:** Join and Filter Customers
In the final query:

I joined the `users_customuser` table with `plan_counts` and `total_deposits` on `owner_id`.

I used `COALESCE` to handle customers with no deposits.

I filtered to include only those customers at least one savings plan and at least one investment plan

---

### **Question 2:  Customer Transaction Frequency Analysis**

**Objective:**  
Categorize customers into **High**, **Medium**, and **Low** frequency groups based on their average monthly transactions.

**Approach:**

**Step 1:** Filter Inflow Transactions Only

I used `confirmed_amount` > 0 to focus on active inflow transactions, ensuring I ignore non-deposit entries.

**Step 2:** Calculate Transaction Span
I measured the transaction duration per customer:
  a. This captures the number of active months from the customer’s first to last transaction.
  b. I added +1 to include both the start and end months.

**Step 3:** Compute Average Monthly Transactions for each user:

This provides a normalized view of transaction frequency, independent of how long a customer has been active

**Step 4:** Customers were segmented based on their average monthly transaction count:

**Step 5:** I grouped customers by their frequency tier and calculated the number of customers in each category and average transactions per month (rounded to one decimal place)


---
### **Question 3:  Inactive Accounts in the Last 365 Days**

**Objective:**  
Find all **active savings or investment plans** that have had **no transactions in the last 365 days**.

**Approach:**

**Step 1:** Savings Accounts (CTE: savings_last_txn)
  - I focus on plans flagged as `is_regular_savings` = 1.
  - I filter to only those records where `confirmed_amount` > 0, indicating that a transaction (inflow) took place.
  - For each savings plan (`s.id`), I retrieve the most recent transaction date using MAX(`s.created_on`).
  - I calculate inactivity days using DATEDIFF(CURDATE(), MAX(`s.created_on`)).
  - I keep only those plans that have had no inflow in the past 365 days using a `HAVING` clause.

**Step 2:** Investment Plans (CTE: investment_last_txn)
  - These are identified using `is_a_fund` = 1.
  - Since transactions are logged via the `created_on` field in the plans_plan table, we apply similar logic to get the last transaction date.
  - Plans with no recent transaction in the last 365 days are filtered using the same `HAVING DATEDIFF(...)` > 365.

**Step 3:** Combined Results
  - The two result sets (savings_last_txn and investment_last_txn) are combined using UNION ALL to present a consolidated list.
  - I sorted the result by `inactivity_days` DESC to prioritize the most dormant accounts at the top.



---

### **Question 4:  Customer Lifetime Value (CLV) Estimation**

**Objective:**  
Estimate the **Customer Lifetime Value (CLV)** based on tenure and transaction behavior.

**Approach:**
I used Common Table Expressions (CTEs) to structure the query clearly and logically

**Step 1:** customer_base
I first extract the essential customer profile information from the users_customuser table:
  - id (customer ID),
  - first_name, last_name,
  - date_joined (used to compute customer tenure).

**Step 2:** customer_savings
I calculated two metrics from the savings_savingsaccount table:
  - total_amount_kobo: Total confirmed deposits by each customer.
  - total_transactions: Count of savings transactions.
Only records where confirmed_amount > 0 (indicating actual deposits) are considered.

**Step 3:** customer_metrics
This CTE performs the core CLV calculation:
  - tenure_months: Customer's time with the platform (from date_joined to now).
  - avg_txn_per_month: Calculated as total_transactions / tenure_months.
  - avg_value_per_txn: Calculated as (total_amount_kobo / 100) * 0.001 / total_transactions.
  - estimated_clv: Projected as avg_txn_per_month * 12 * avg_value_per_txn
Null-safe division (NULLIF(..., 0)) is used to avoid division errors when tenure or transactions are zero.

---

### **Challenges**

  - Identifying how to distinguish between a regular savings plan and an investment plan required examining the `is_regular_savings` and `is_a_fund flags` in the plans_plan table.
  - Accurately calculating active_months was challenging, especially in edge cases where MIN(`created_on`) equals MAX(`created_on`), which could result in 0-month durations and divide-by-zero errors. I resolved this by add (+1) to the equation to balance the count.
