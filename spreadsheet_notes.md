# Part B: Spreadsheet Cleaning and Pivot Layer

## What I started from
I exported the q09 result from Part A as `data/orders_enriched.csv` (90 orders, 10 columns) and imported it into Google Sheets. The workbook has these tabs:

- `orders`: the 10 original columns (A:J) plus four calculated columns (K:N).
- `products`: the 9 products with category and unit price, sorted by item, header in A1.
- `Validation`: formulas that compare the sheet against my Part A numbers.
- `Region_Month`, `Category`, `Rep_Month`: summary tables built with COUNTIFS and SUMIFS.
- `Guide`: short usage notes.

I imported with automatic conversion switched off so `order_month` stays as text like `2026-09`. All 90 rows still show that form, and the exported CSV keeps it too.

## Cleaning and lookups (row 2, filled down to row 91)
| Column | Formula | Purpose |
|---|---|---|
| K `clean_first_name` | `=PROPER(TRIM(C2))` | removes stray spaces, fixes capitalisation |
| L `clean_last_name` | `=PROPER(TRIM(D2))` | same for last names |
| M `category` | `=VLOOKUP(G2,products!$A$2:$C$10,2,FALSE)` | exact-match category |
| N `unit_price` | `=XLOOKUP(G2,products!$A$2:$A$10,products!$C$2:$C$10,"UNKNOWN_ITEM")` | price, with a fallback text |

Every lookup range is fully anchored with `$`, so the formulas can be copied down without drifting. After cleaning, no name has a leading, trailing or doubled space, and each one is a single capital followed by lower-case letters (for example `  Vikram` / `Singh ` became `Vikram` / `Singh`, and `RAHUL` / `VERMA` became `Rahul` / `Verma`).

No real order uses an item that is missing from `products`, so the fallback never fires on the data. To prove it works, I typed an item that doesn't exist ("Fake Product") into the Validation tab and ran the same XLOOKUP on it. It returns `UNKNOWN_ITEM`. I put this test on the Validation tab rather than beside the data so the orders tab exports as exactly 14 columns.

## Reconciliation with Part A
| Check | Spreadsheet | Part A |
|---|---:|---:|
| All orders | 90 | 90 |
| Completed orders | 63 | 63 (q05) |
| Completed revenue (INR) | 346200 | 346200 (q05) |
| Pending orders | 19 | 19 (q06) |
| Disputed orders | 8 | 8 (q06) |
| Blank amounts | 3 | 3 (q02) |
| Unmatched items | 0 | 0 |
| Names with stray spaces or wrong case | 0 | 0 |

The three summary tabs also reconcile. Each one adds up to 346200, and every region-by-month revenue figure matches q11 and every rep-by-month figure matches q13. The Validation tab shows PASS on all of these.

Revenue follows the project rule: only orders with status `completed` count. Pending and disputed orders are left out, and the 3 missing amounts stay blank (they are all pending orders, so they never touch revenue).

## Summary tabs
- `Region_Month`: completed orders, revenue and average order value for each region and month.
- `Category`: the same figures by product category (Apparel 77500, Electronics 142300, Home 126400).
- `Rep_Month`: completed orders and revenue for each rep and month.

These are formula tables, not native Google Sheets pivot objects. They give the same numbers and update automatically when the data changes.

## Export
I downloaded the `orders` tab as CSV and saved it as `data/orders_clean.csv`. It has 90 data rows and 14 columns:
`order_id, order_month, first_name, last_name, region, rep_name, item, quantity, amount, status, clean_first_name, clean_last_name, category, unit_price`

Part C uses this file.
