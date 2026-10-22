# Part C — BBD Regional Performance Dashboard Specification

## Status and deliverable
**Written dashboard specification** using the verified cleaned order data. The capstone statement explicitly grades `docs/dashboard_spec.md`, not a Tableau workbook or screenshot. An optional interactive browser demonstration is provided separately from the GitHub submission.

**Limit on rubric certainty:** the uploaded brief ends halfway through Part B, so Part C's detailed tasks and acceptance criteria were not supplied. This is a complete practical dashboard specification, but should be compared with the rest of the original rubric before final submission.

## Business objective
Answer which regions, product categories, and sales representatives drove completed sales across September–November 2026, and identify where targeted promotional support is justified. All money amounts are INR.

## Source and grain
- Dataset: `data/orders_clean.csv`, created from SQL q09 -> spreadsheet cleansing.
- Grain: one record per order (`order_id`), 90 source rows.
- 14 columns: `order_id`, `order_month`, `first_name`, `last_name`, `region`, `rep_name`, `item`, `quantity`, `amount`, `status`, `clean_first_name`, `clean_last_name`, `category`, `unit_price`.
- A region is the **customer's** region; the assigned rep is from `customers.rep_id -> reps.rep_id`.
- `order_month` is plain text `YYYY-MM`; sort in its natural ascending order.
- Completed revenue is `SUM(amount)` **only** where `status = completed`; pending and disputed never contribute revenue.
- Original NULL amounts stay blank. The clean CSV maintains the original messy names alongside corrected names.

## Suggested layout (desktop; responsive when possible)
1. Top: dashboard title, annotation stating Sep–Nov 2026; filters for region, month, category, and rep.
2. KPI strip: completed revenue, completed orders, average completed order value, pending count, disputed count.
3. Main: revenue by region (ranked horizontal bar); completed revenue by month (line or column chart).
4. Detail: category performance (bar); product revenue/contribution tier (bar or table); rep-month revenue versus target (grouped bars / detail table).
5. Bottom: written observations, cautious actions, and metric provenance.

## Calculated fields / metric definitions
| Metric | Definition | Source check |
|---|---|---|
| Completed revenue | `SUM(IF [status]='completed' THEN [amount] ELSE 0 END)` | q05: ₹346,200 |
| Completed orders | `COUNT(IF [status]='completed' THEN [order_id] END)` | q05: 63 |
| Average completed order value | completed revenue / completed orders | q05: ₹5,495.24 |
| Pending order count | count of rows whose status is pending | q01/q06: 19 |
| Disputed order count | count of rows whose status is disputed | q06: 8 |
| Category revenue | sum completed amount, grouped by `category` | products lookup + q09 |
| Regional monthly completed revenue | sum completed amount by `region`, `order_month` | q11 |
| Rep monthly completed revenue | sum completed amount by `rep_name`, `order_month` | q13 |
| Monthly rep target | original `monthly_target` from `reps`; avoid summing per-order targets | q13; use a separate target dimension or q13 result |

**Warning:** `monthly_target` is **not** a column in the 14-column cleaned orders export. For a target-vs-actual panel, bring the rep targets from SQL q13 or the 4-row `reps` table, or join a small target lookup; do not invent or multiply monthly targets per order.

## Expected KPI cards (unfiltered)
| KPI | Value |
|---|---:|
| Completed revenue | ₹346,200 |
| Completed orders | 63 |
| Avg completed order | ₹5,495 (display 2 decimals: ₹5,495.24) |
| Pending | 19 |
| Disputed | 8 |

## Region chart (unfiltered)
| region | completed_orders | completed_revenue_inr |
| --- | --- | --- |
| North | 19 | 119300 |
| South | 17 | 82500 |
| West | 15 | 74900 |
| East | 12 | 69500 |


## Monthly chart (unfiltered)
| month | completed_orders | completed_revenue_inr |
| --- | --- | --- |
| 2026-09 | 19 | 98300 |
| 2026-10 | 20 | 93100 |
| 2026-11 | 24 | 154800 |


## Category chart (unfiltered)
| category | completed_orders | completed_revenue_inr |
| --- | --- | --- |
| Electronics | 24 | 142300 |
| Home | 21 | 126400 |
| Apparel | 18 | 77500 |


## Top products / contribution tiers
| item | revenue_inr | tier |
| --- | --- | --- |
| Air Fryer | 104000 | High |
| Smart Watch | 67500 | High |
| Wireless Earbuds | 60800 | High |
| Running Shoes | 43200 | Medium |
| Denim Jacket | 17500 | Medium |
| Cotton Kurta | 16800 | Medium |
| Bluetooth Speaker | 14000 | Low |
| Bedsheet Set | 11400 | Low |
| Table Lamp | 11000 | Low |


## Rep performance panel (unfiltered)
Use the q13 result below. The labels use the **assignment's** tier rule: Below Target if revenue < target; On Target if target <= revenue < 1.1×target; Above Target if revenue >= 1.1×target.

| rep | month | monthly_target_inr | completed_revenue_inr | performance_tier |
| --- | --- | --- | --- | --- |
| Arjun Mehta | 2026-09 | 40000 | 53500 | Above Target |
| Arjun Mehta | 2026-10 | 40000 | 41300 | On Target |
| Arjun Mehta | 2026-11 | 40000 | 24500 | Below Target |
| Kavya Nair | 2026-09 | 20000 | 19800 | Below Target |
| Kavya Nair | 2026-10 | 20000 | 19000 | Below Target |
| Kavya Nair | 2026-11 | 20000 | 43700 | Above Target |
| Neha Kulkarni | 2026-09 | 20000 | 18600 | Below Target |
| Neha Kulkarni | 2026-10 | 20000 | 20600 | On Target |
| Neha Kulkarni | 2026-11 | 20000 | 35700 | Above Target |
| Sanjay Roy | 2026-09 | 12000 | 6400 | Below Target |
| Sanjay Roy | 2026-10 | 12000 | 12200 | On Target |
| Sanjay Roy | 2026-11 | 12000 | 50900 | Above Target |


## Target comparison integrity and precision rules
- Display average completed order value to **two decimal places** (unfiltered ₹5,495.24). Other displayed revenue amounts may use whole rupees.
- **Critical filter safeguard:** when users select a single category, the representative revenue displayed is only for that category. The original monthly target applies to all categories combined. Therefore, **do not calculate or display `Below Target`, `On Target`, or `Above Target` for category-filtered revenue**; show `Not comparable — category subset` or hide the tier. Full-rep target classification is valid again when the category filter is cleared.
- A salesperson belongs to a single region in this seed, so region/rep filters can still support full monthly target comparisons when **all categories** are selected.
- All verification values below are for the **unfiltered** dashboard. With filters, checks must be recomputed on the same eligible order subset rather than compared to the unfiltered grand total.
- If the user applies filters that produce no completed orders, the revenue KPI should display ₹0, the order count 0, and average order value `N/A` (not a divide-by-zero).

## Filters and interactions
- Region filter controls overall counts, revenue, region, month, category, and product charts.
- Month filter controls all related figures; months as strings from `2026-09` to `2026-11`.
- Category filter should apply to sales results, but the rep target comparison must clearly state that original **whole-region/month** rep targets are not category-level targets.
- Rep filter uses `rep_name`, and region/rep filters are compatible with the supplied reps mapping.
- Default state: all regions, months, categories, and reps; `completed` for revenue-based charts.
- No cross-chart selection may accidentally bring pending or disputed amounts into revenue.

## Manager-facing analysis and suggested next actions
1. **North leads total completed revenue:** ₹119,300 (19 completed orders). Protect strong product availability there, but avoid assuming higher ad ROI solely from revenue.
2. **Electronics leads categories:** ₹142,300. Investigate whether electronics-focused campaigns outperform other categories before reallocating budget.
3. **November was the largest month:** ₹154,800, versus September ₹98,300 and October ₹93,100. Consider testing November timing or promotion mix rather than attributing the increase to a cause not in this dataset.
4. **East had the lowest aggregate regional revenue (₹69,500)**, but Sanjay's November revenue was ₹50,900 against a ₹12,000 monthly target. Review month-level results before treating East as uniformly underperforming.
5. **Pending orders (19) and disputed orders (8)** should be investigated operationally; neither contributes to recognised revenue. Three pending amounts are missing and should not be overwritten during cleaning.

These are *decision hypotheses*, not proven causal conclusions: the dataset lacks costs, ad spend, profit margin, and traffic, so the dashboard cannot establish advertising ROI.

## Tableau Public build procedure (optional)
1. Open Tableau Public, create a new workbook, connect to `orders_clean.csv`.
2. Confirm `order_month` is a text dimension and `amount`/`quantity`/`unit_price` are numeric measures.
3. Create a boolean filter `[status] = 'completed'` for revenue and comparison charts.
4. Create the calculated fields above; build region and category bars, monthly trend, product tier table.
5. Add a separate table/lookup for rep targets and create rep-month actual-versus-target chart without duplicating targets on individual order records.
6. Arrange worksheets in a dashboard; add relevant filters and explanatory captions.
7. Independently verify default-state sums and counts with q05, q06, q11, q12 and q13 before publishing.
8. Keep any Tableau workbook or screenshot **out of the GitHub submission**, since the brief accepts only text and grades this specification.

## Audit trail
- `sql/q05.sql` and `results/query_results.md` validate KPIs.
- `sql/q06.sql` validates status counts and *recorded* status amounts.
- `sql/q09.sql` produces 90 joined order records; `data/orders_enriched.csv` stores the original order-level layer.
- `docs/spreadsheet_notes.md` explains name and product enrichment into `data/orders_clean.csv`.
- `sql/q11.sql` validates region-month figures; `sql/q12.sql` validates product tiers; `sql/q13.sql` validates rep-month targets.
- `docs/ai_log.md` documents AI-supported drafting and independent checks.
