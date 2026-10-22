# Part D — AI-Assisted Analysis with Human-in-the-Loop Verification

## Disclosure and evidence scope

This work was **assisted by ChatGPT** (OpenAI) using the supplied synthetic Flipkart BBD seed dataset, SQL questions, and capstone instructions. AI assistance included SQL construction, CSV production, spreadsheet formulas and notes, dashboard specification, and this Part D analysis. The Part D prompts below are **written prompt artifacts for the assignment**; they are not represented as historical prompts sent verbatim to an assistant. The verification described as performed below was run against the supplied seed in SQLite using Python's `sqlite3` engine. Whoever submits the work should also inspect and verify it independently in their chosen SQL and spreadsheet tools, and adapt all explanations in their own words. No artificial transcript of an assistant response is claimed here.

**Revenue definition throughout:** sum of `orders.amount` only when `orders.status = 'completed'`. The date strings are text in `YYYY-MM` format and all money values are INR.

## Task 1 — Structured five-part prompt for Part A, q13

**Role:** Act as an experienced SQL business analyst who validates sales metrics and writes clear, portable queries.

**Task:** Produce Part A's q13 query to calculate each sales representative's completed revenue by month and compare it against that representative's monthly target. Return the rep name, order month, monthly target, revenue, and a performance tier.

**Context:** The SQL dialect is **SQLite**. The real schema is `reps(rep_id, rep_name, region, monthly_target)`, `customers(customer_id, first_name, last_name, city, region, age, rep_id)`, and `orders(order_id, customer_id, item, quantity, amount, status, order_month)`. Join `reps.rep_id = customers.rep_id` and `customers.customer_id = orders.customer_id`. `order_month` is text such as `2026-09`; `monthly_target` and `amount` are INR.

**Constraints:** Count **completed orders only** (`o.status = 'completed'`). Tier thresholds: `Below Target` when monthly completed revenue is **less than** target; `On Target` when revenue is **at least target but less than 1.1 times target**; `Above Target` when revenue is **at least 1.1 times target**. Use `SUM(o.amount)` in the `CASE` conditions rather than referencing a derived alias in `WHERE` or `GROUP BY`. Group by `r.rep_name`, `o.order_month`, and `r.monthly_target`; sort by rep name and month. Do **not** use `WITH` clauses, stored procedures, or invented tables or columns.

**Format:** Return **raw SQL only**, with inline SQL comments explaining joins, grouping, and performance tiers. No Markdown fence, explanation, or fabricated results.

## Task 2 — Inspect the flawed Scenario D1 answer

The supplied assistant answer (reproduced for inspection) is:

```sql
SELECT region_name, SUM(total_sales) AS sales
FROM sales
WHERE SUM(total_sales) > 80000
GROUP BY region_name
ORDER BY sales DESC;
```

> "North is the strongest region, and its revenue grew 38% month over month."

| Defect in the original answer | Required classification | Explanation and correction |
|---|---|---|
| Table `sales` does not exist | **fake method/function** | Real order transactions are in `orders`, joined to `customers` to obtain the **customer** region. Use `FROM orders o JOIN customers c ON o.customer_id = c.customer_id`. |
| Columns `region_name` and `total_sales` do not exist | **fake method/function** | Use `c.region` as the region column and `o.amount` for the amount to sum. |
| `SUM(total_sales) > 80000` appears in `WHERE` | **logic error** | `WHERE` filters raw rows. Use `WHERE o.status = 'completed'`, then `GROUP BY c.region HAVING SUM(o.amount) > 80000` to filter grouped totals. |
| Claimed 38% month-over-month revenue growth for North without evidence | **phantom statistic** | Calculate the change from **q11**: North's Sep revenue ₹53,500 and Oct revenue ₹41,300; the actual change is **−22.8%**, not +38%. |

The `ORDER BY sales DESC` alias would be valid after defining the aggregate correctly; it is **not** a fifth defect.

## Task 3 — Corrected D1 SQL, execution result, and North growth check

Save and execute the exact SQL stored in [`sql/d1_corrected.sql`](../sql/d1_corrected.sql):

```sql
SELECT c.region AS region,
       SUM(o.amount) AS revenue
FROM orders o
JOIN customers c
  ON o.customer_id = c.customer_id
WHERE o.status = 'completed'
GROUP BY c.region
HAVING SUM(o.amount) > 80000
ORDER BY SUM(o.amount) DESC, c.region ASC;
```

**Verified SQLite result — exactly 2 rows:**

| region | revenue (INR) |
|---|---:|
| North | 119300 |
| South | 82500 |

For the growth check, SQL q11 (`results/query_results.md`) shows North's completed revenue as **₹53,500 for `2026-09`** and **₹41,300 for `2026-10`**.

**Actual month-over-month percentage change** = `(October − September) / September × 100` = `(41,300 − 53,500) / 53,500 × 100` = **−22.8%** (rounded to one decimal place).

The original assistant's statement of **38% growth is contradicted by the data**: North's completed revenue fell, rather than increased, from September to October. North still has the highest **total** completed revenue across all three months; that ranking alone says nothing about its month-to-month growth.

## Task 4 — Human-in-the-loop protocol for Scenario D1

**Specification:** Restate the business question precisely: rank customer regions by `SUM(orders.amount)` from **completed orders only**, and include only regions above INR 80,000. Use the actual `orders` and `customers` tables. Independently check North's September-to-October change rather than assuming the assistant's claim is true.

**Execution:** Inspect the original proposed query and the seed schema; the original query cannot execute against the provided schema because the `sales` table does not exist. Write `sql/d1_corrected.sql` using a valid join, completed-status filter, grouped `HAVING` threshold, and descending revenue order; execute it in SQLite and query q11 for month-specific figures.

**Inspection:** Compare the generated text with the schema and SQL aggregation rules. Record four defects: nonexistent table, nonexistent columns, aggregate misuse in `WHERE`, and a 38% claim without a supporting calculation. Inspect the returned region names and values and make sure pending/disputed order amounts were excluded.

**Verification:** Running the corrected SQL over the supplied seed produces exactly **North ₹119,300** and **South ₹82,500**. Independent SQL q11 values for North are **₹53,500** in September and **₹41,300** in October, so the verified change is **−22.8%**. Both the two-row result and the monthly calculation are reproducible from the supplied seed and `results/query_results.md`.

**Decision:** **Reject the original assistant answer** because it has fake schema references, invalid aggregate filtering, and an unsupported growth claim contradicted by q11. **Accept the corrected SQL and its two-row result**, because it executes against the actual SQLite seed, preserves the completed-only revenue definition, and matches the recorded regional totals. **Reject the original 38% statistic** and replace it with **−22.8%** supported by q11.

## Task 5 — Structured five-part prompt for Scenario D2, diagnosis and repaired formula

**Role:** Act as a Google Sheets formula debugger and explain exact-match lookup errors without inventing data.

**Task:** Find the reason the supplied exact-match `VLOOKUP` returns "not found", and repair the formula without changing the original product table.

**Context:** The `products` tab occupies `A1:C10`, with a header in row 1, product/item names in column A and unit prices in column C. The formula is being written on the **`orders`** tab, where `G2` contains the literal text **`" Smart Watch"`** (one **leading** space). The corresponding product key on the products tab is **`"Smart Watch"`** without that extra space. The original formula is `=VLOOKUP(G2, $A$2:$C$10, 3, FALSE)`.

**Constraints:** Use an exact match (`FALSE`), preserve the correct absolute lookup range, reference the correct `products` tab explicitly, and remove unintended leading/trailing spaces from the lookup key without replacing missing values with guesses. Explain the root cause.

**Format:** Return the corrected Google Sheets formula, a brief explanation of why the original fails, and one simple test to confirm the repaired lookup returns the expected unit price **₹4,500**.

**Root cause (our own explanation):** `G2` begins with an invisible **leading space**, so the exact-match lookup looks for `" Smart Watch"` rather than `"Smart Watch"` and fails. In addition, the original unqualified `$A$2:$C$10` references the **orders tab** when entered there, not the `products` tab. Both must be fixed.

**Repaired formula:**

```excel
=VLOOKUP(TRIM(G2),products!$A$2:$C$10,3,FALSE)
```

`TRIM(G2)` removes the leading space. The `products!` sheet qualification chooses the correct table, `$` anchors the range, `3` returns `unit_price`, and `FALSE` requires an exact match. Expected result for the specified Smart Watch case: **4500**. This is a controlled scenario; the original seed data's actual item values should not be silently altered to manufacture a lookup error.

## Task 6 — Skeptical-analyst review of Part C's first recommendation

The **first recommendation in `docs/dashboard_spec.md`** is: **"North leads total completed revenue: ₹119,300 (19 completed orders). Protect strong product availability there, but avoid assuming higher ad ROI solely from revenue."**

### Prompt for a skeptical analyst

**Role:** You are a skeptical business analyst auditing a proposed marketing and inventory recommendation. **Task:** Critically challenge the recommendation to protect or prioritise stock availability in North because it leads completed revenue. Identify at least three **unstated assumptions**; ask for evidence that inventory availability or promotional spending **causes** improved results, not merely that high revenue is **correlated** with the North region. **Context:** This is synthetic BBD sales data with 90 orders, 63 completed orders and ₹346,200 completed revenue across Sep–Nov 2026. North recorded ₹119,300 across 19 completed orders, but there are no observations of marketing spend, inventory availability, traffic, margins, or competitor effects. **Constraints:** Do not invent causal uplift, conversion rates, stockouts, or ROI. For every assumption, suggest a data check or controlled experiment and indicate which conclusions the current dataset cannot support. **Format:** A concise audit table with assumption, data evidence/check, possible alternative explanation, and decision implication.

### Assumptions and verification checks

| Unstated assumption behind the recommendation | Specific check or figure from the data | What would confirm or weaken it |
|---|---|---|
| North's sales lead represents **sustained, growing demand** rather than a temporary peak | North's q11 revenue: Sep **₹53,500**, Oct **₹41,300**, Nov **₹24,500**; North total **₹119,300** | The three-month total confirms the ranking, but the repeated monthly declines weaken a claim of strengthening demand. Obtain more months before forecasting stock requirements. |
| North's demand is **broad across buyers** rather than driven by just a few customers | North has **19** completed orders from **5 distinct ordering customers**; Sep alone has **8 orders from 2 customers** | The customer concentration weakens an assumption that sales are representative of a large active market. Compare unique-customer share and repeat behavior before allocating regional budget. |
| Protecting inventory of high-selling products will address a **real stock constraint** | North's Smart Watch completed revenue is **₹45,000 across 5 orders**, versus North total **₹119,300**; original order data have **no inventory or stockout columns** | Product concentration points to SKUs worth inspecting, but cannot prove stock shortages. Confirm with stockout history, fill rate and lost-sales tracking before increasing inventory. |
| North's highest revenue implies **better promotional return on investment** | Revenue North **₹119,300** vs South **₹82,500**, West **₹74,900**, East **₹69,500**; **no ad spend, profit margin, or acquisition cost** fields exist | Revenue ranks regions but cannot establish ROI. Compare incremental gross profit per advertising rupee in a controlled campaign to determine where promotional money should go. |

### Decision on the Part C recommendation

**Keep it as a cautious hypothesis, not a causal conclusion.** North's completed revenue lead is real. Before reallocating marketing or replenishment budgets, independently check stockouts, margins, campaign spend, and demand concentration, and consider a small controlled regional pilot.

## Independent verification record and sign-off

| Check | Source or action | Observed result |
|---|---|---|
| Seed | Executed `sql/00_schema_and_seed.sql` in SQLite | reps=4, products=9, customers=24, orders=90 |
| Part A | Executed q01 through q13 from seed, checked output counts | 19, 3, 5, 8, 1, 3, 4, 4, 90, 4, 12, 9, 12 |
| KPI | q05 | 63 completed orders; ₹346,200 |
| D1 corrected SQL | Executed `sql/d1_corrected.sql` in SQLite | North ₹119,300; South ₹82,500 |
| North growth | q11 result; arithmetic shown above | −22.8% |
| D2 repair | Reasoning from scenario's exact key and layout | Expected Smart Watch unit price ₹4,500; verify in Google Sheets |
| Part C reference | `docs/dashboard_spec.md`, first recommendation | North revenue ₹119,300; no evidence of inventory causality or promotional ROI |

**AI use disclosure:** ChatGPT substantially assisted in constructing these project artifacts and this log. Statements of executed checks refer to reproducible computational checks; the student's own sign-off has not been asserted or fabricated. Before submitting, the student should rerun the SQL, test the D2 formula in Google Sheets, and review the analysis to meet the originality and human-verification requirement.

**Student verification checklist (complete personally):**
- [ ] I executed D1 corrected SQL in my own SQL compiler and saw exactly North 119300 and South 82500.
- [ ] I independently calculated North's −22.8% September-to-October revenue change from q11.
- [ ] I inspected the D2 formula in Google Sheets and confirmed the leading-space test.
- [ ] I checked that the Part C recommendation is based on observed data and not an unsupported causal claim.
- [ ] I reviewed and, as appropriate, rewrote the AI-assisted text in my own words and declared the assistance accurately.
