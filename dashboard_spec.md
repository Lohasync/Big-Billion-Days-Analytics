# Dashboard Specification: BBD Regional Performance

## Purpose
This dashboard answers one question for the regional managers and leadership: which regions, categories and sales reps carried the Big Billion Days sale, and where should promotional money go next. It is written as a specification for Tableau Public. Every number below comes from `data/orders_clean.csv` (90 orders) and was checked against the Part A queries and the Part B Validation tab.

Revenue rule used everywhere: revenue is the sum of `amount` for orders with status `completed`. Pending and disputed orders are not counted as revenue. All money is in INR.

## Data source
- Main table: `data/orders_clean.csv` (14 columns, 90 rows). `order_month` is kept as text (`2026-09`, `2026-10`, `2026-11`).
- Rep targets: the `reps` table (`monthly_target`) joined on `rep_name`.
- Use the cleaned name columns (`clean_first_name`, `clean_last_name`) for any customer label.

## Calculated fields
| Field | Definition |
|---|---|
| Revenue | `SUM(IF [status] = 'completed' THEN [amount] END)` |
| Completed Orders | `COUNTD(IF [status] = 'completed' THEN [order_id] END)` |
| Avg Order Value | `[Revenue] / [Completed Orders]` |
| Target Attainment | `[Revenue] / SUM([monthly_target])` |
| Contribution Tier | High if item revenue >= 60000, Medium if >= 15000, otherwise Low |

## KPI cards (top row)
| KPI | Value | Source |
|---|---:|---|
| Total revenue | INR 346,200 | q05 |
| Completed orders | 63 of 90 | q05, q06 |
| Average order value | INR 5,495 | q05 |
| Smallest / largest order | INR 1,100 / 15,600 | q05 |
| Pending orders | 19 (INR 64,900 known value) | q06 |
| Disputed orders | 8 (INR 73,200) | q06 |

Note: 3 pending orders have no amount, so the pending value only covers 16 of the 19 orders.

## Charts

### 1. Revenue by region (horizontal bar, sorted high to low)
- Rows: region. Columns: Revenue. Filter: status = completed.
- Values: North 119,300; South 82,500; West 74,900; East 69,500.
- North alone brings in about 34% of revenue.

### 2. Revenue by month (line or column)
- Columns: order_month. Values: Revenue, with a second view split by region (colour).
- Values: 2026-09 = 98,300; 2026-10 = 93,100; 2026-11 = 154,800.
- November is the biggest month at roughly 45% of the total and about 66% above October.

### 3. Revenue by category (bar)
- Values: Electronics 142,300 (41%); Home 126,400 (37%); Apparel 77,500 (22%).
- Add a month breakdown as stacked colour. Home jumps from 12,600 in October to 83,200 in November.

### 4. Product contribution tiers (horizontal bar, coloured by tier)
- Values, highest first: Air Fryer 104,000; Smart Watch 67,500; Wireless Earbuds 60,800 (all High); Running Shoes 43,200; Denim Jacket 17,500; Cotton Kurta 16,800 (Medium); Bluetooth Speaker 14,000; Bedsheet Set 11,400; Table Lamp 11,000 (Low).
- Air Fryer alone is about 30% of all revenue. The top three items make up about 67%.

### 5. Rep performance against target (grouped bar with a target reference line)
- Rows: rep_name. Columns: month. Values: Revenue, with the monthly target as a reference line per rep.
- Three-month revenue against three months of target: Sanjay Roy 193%, Kavya Nair 138%, Neha Kulkarni 125%, Arjun Mehta 99%.
- Colour each bar by tier (Below, On or Above Target) using the q13 rule: below target, at least target but under 1.1 times target, or 1.1 times target and above.

| Rep | Sep | Oct | Nov |
|---|---|---|---|
| Arjun Mehta (target 40,000) | 53,500 Above | 41,300 On | 24,500 Below |
| Kavya Nair (target 20,000) | 19,800 Below | 19,000 Below | 43,700 Above |
| Neha Kulkarni (target 20,000) | 18,600 Below | 20,600 On | 35,700 Above |
| Sanjay Roy (target 12,000) | 6,400 Below | 12,200 On | 50,900 Above |

### 6. Order status by region (stacked bar of order counts)
- Not filtered by status; this view uses all 90 orders.
- Completion rate by region: North 86% (19 of 22), South 68% (17 of 25), West 65% (15 of 23), East 60% (12 of 20).

## Filters and layout
- Filters: month (single or multiple), region, category. Apply them to all sheets except chart 6, which ignores the status filter.
- Layout: KPI cards across the top, then charts 1 and 2, then 3 and 4, then 5 and 6.
- Tooltips: show Revenue, Completed Orders and Avg Order Value on every chart.

## What the numbers say
- North is the strongest region, but its rep, Arjun Mehta, fell from 53,500 in September to 24,500 in November, against a 40,000 monthly target. He finished the sale at 99% of three months of target even though North was the top region.
- Home category growth in November is almost entirely the Air Fryer. Air Fryer made 78,000 of the 83,200 Home revenue that month.
- East has the weakest completion rate (60%). Its 6 pending and 2 disputed orders hold INR 46,500 of known value that has not become revenue yet.
- West has 4 of the 8 disputed orders, worth INR 33,400, which is about 46% of all disputed value.
- The three Low-tier items (Bluetooth Speaker, Bedsheet Set, Table Lamp) each earned under 15,000.

## Recommendations
1. Back the Air Fryer, Smart Watch and Wireless Earbuds first. They are the three High-tier items and make up about two thirds of revenue.
2. Before spending promo money in North, find out why Arjun Mehta's November dropped. The region is strong, so the gap may be about follow-up rather than demand.
3. In East, clear the pending and disputed backlog before running new offers. Converting those orders is cheaper than finding new ones.
4. In West, look into why disputes are so concentrated. The data has no dispute reason, so ask the West team for it.
5. Do not put promo money on the Low-tier items for now. If they are promoted at all, bundle them with a High-tier item.

## Limits of this data
- It is a small synthetic sample: 90 orders over three months, so one large order can move a region or a rep noticeably.
- Three pending orders have no amount, so pending value is understated.
- Four customers (IDs 6, 11, 17 and 24, one in each region) never placed an order. They are not in any revenue figure.
- There is no dispute reason or cost data, so the recommendations are about where to look, not guaranteed returns.

## Reconciliation
| Figure | Dashboard | Part A / Part B |
|---|---:|---|
| Total revenue | 346,200 | q05, Validation tab |
| Completed orders | 63 | q05, Validation tab |
| Region revenue total | 346,200 | q11, Region_Month tab |
| Category revenue total | 346,200 | Category tab |
| Rep revenue total | 346,200 | q13, Rep_Month tab |
