# Part B — Spreadsheet Cleaning and Pivot Layer

## Source and reproducibility
- Source file: `data/orders_enriched.csv`, generated from SQL q09 (90 records and 10 original columns).
- Product lookup source: `SELECT item, category, unit_price FROM products ORDER BY item` (9 products).
- Sheet names: `orders` (90 transactions), `products` (9 products), `Validation`, `Region_Month`, `Category`, `Rep_Month`, and `Guide`.
- `order_month` MUST remain literal text in `YYYY-MM` format, e.g. `2026-09` (not `Sep-26`).
- Working Google Sheets-compatible file is supplied **separately** as `Flipkart_BBD_PartB_Google_Sheets.xlsx` and is **not submitted** (the brief prohibits binary files).

## Required formulas in `orders`
The first 10 columns (A:J) come directly from q09. Rows 2 through 91 cover all orders.

| Column | Field | Formula in row 2; fill down to 91 |
|---|---|---|
| K | `clean_first_name` | `=PROPER(TRIM(C2))` |
| L | `clean_last_name` | `=PROPER(TRIM(D2))` |
| M | `category` | `=VLOOKUP(G2,products!$A$2:$C$10,2,FALSE)` |
| N | `unit_price` | `=XLOOKUP(G2,products!$A$2:$A$10,products!$C$2:$C$10,"UNKNOWN_ITEM")` |

The products sheet has columns `item`, `category`, `unit_price` beginning at A1. All lookup ranges are absolute and the VLOOKUP uses exact match (`FALSE`).

Fallback demonstration in a spare cell (e.g. P2):
`=XLOOKUP("Fake Product",products!$A$2:$A$10,products!$C$2:$C$10,"UNKNOWN_ITEM")`
Expected output: `UNKNOWN_ITEM`. All 90 genuine rows have known items.

The export `data/orders_clean.csv` retains A:J (including original messy names) and adds K:N with the clean *values* from these formulas; a CSV does not store formulas.

## Pivot-table build guide (for a native Google Sheets pivot)
The following are **reproducible pivot specifications**. The separately supplied workbook contains formula-driven summary tables, *not native Google Sheets pivot objects*. To meet any native-pivot requirement in the unseen remainder of Part B, create these in Google Sheets using **Insert > Pivot table** and filter `status = completed`:

1. **Region × Month**: Rows = `region`; Columns = `order_month`; Values = SUM of `amount`; Filter = `status: completed`.
2. **Category**: Rows = `category`; Values = SUM of `amount`, COUNTA of `order_id`; Filter = `status: completed`.
3. **Rep × Month**: Rows = `rep_name`; Columns = `order_month`; Values = SUM of `amount`; Filter = `status: completed`.

## Reconciliation with SQL q05/q06/q11/q13

| Check | Value |
|---|---:|
| Total orders | 90 |
| Completed orders | 63 |
| Pending orders | 19 |
| Disputed orders | 8 |
| Completed revenue (INR) | 346200 |
| Completed mean order (INR, 2 d.p.) | 5495.24 |
| Missing amount cells | 3 |
| Unknown real product codes | 0 |
| Text month format retained | 90 / 90 |

### Completed revenue by region
| region | completed_orders | revenue_inr |
| --- | --- | --- |
| North | 19 | 119300 |
| South | 17 | 82500 |
| West | 15 | 74900 |
| East | 12 | 69500 |

### Completed revenue by category
| category | completed_orders | revenue_inr |
| --- | --- | --- |
| Electronics | 24 | 142300 |
| Home | 21 | 126400 |
| Apparel | 18 | 77500 |

### Completed revenue by month
| order_month | completed_orders | revenue_inr |
| --- | --- | --- |
| 2026-09 | 19 | 98300 |
| 2026-10 | 20 | 93100 |
| 2026-11 | 24 | 154800 |


Only `status = 'completed'` contributes revenue. Pending and disputed amounts are **not** revenue. The three absent amounts remain empty; do not replace them with zero.

## Verification plan in Google Sheets
1. Open the supplied workbook in Google Sheets; confirm K:N formulas run without errors.
2. Check `orders!B2:B91` remains `YYYY-MM` **plain text**.
3. Confirm the `UNKNOWN_ITEM` test output in a spare cell.
4. Compare the Validation tab with SQL q05 and q06.
5. Build any native pivots the *full* rubric specifies; compare pivot grand totals with ₹346,200.
6. For submission, export plain-text `data/orders_clean.csv` and include **this** Markdown file, not `.xlsx`.

## Source limitation
The Part B statement supplied here ends midway through the XLOOKUP instruction; the exact remaining Part B rubric is unavailable. The sheets, summaries, and pivot guidance cover the visible requirements and useful analysis but may need additions after the complete brief is obtained.
