# AI Assistance Log

I used an AI assistant (Claude) for parts of this project. This log lists what it produced, how each item was checked against the data, and what was changed. Nothing was used without a check.

## Where AI was used
| # | Artifact | What the AI did | How it was checked | Result |
|---|---|---|---|---|
| 1 | `sql/q01.sql` to `sql/q13.sql` | Drafted all 13 queries from the task wording | Ran every file on the loaded seed and compared row counts with the brief: q01=19, q02=3, q03=5, q04=8, q05=1, q06=3, q07=4, q08=4, q09=90, q10=4, q11=12, q12=9, q13=12 | All 13 matched |
| 2 | `results/query_results.md` | Ran the queries and formatted the output as Markdown tables | Compared against the seed check (4, 9, 24, 90) and the q05 row (total_orders 63, total_revenue 346200) | Matched |
| 3 | `data/orders_enriched.csv` | Exported the q09 result | Counted 1 header line plus 90 data lines, 10 columns each, and 3 empty amount cells (orders 1001, 1010, 1064) | Matched |
| 4 | Part B formulas (`orders` K:N) | Wrote the PROPER(TRIM()), VLOOKUP and XLOOKUP formulas | Checked that no cleaned name has stray spaces or wrong case, that every item finds a category and price, and that all lookup ranges use absolute references | All passed |
| 5 | Part B workbook and Validation tab | Built the summary tabs and the reconciliation checks | Compared the totals with Part A: 90 orders, 63 completed, 346200 revenue, 19 pending, 8 disputed, 3 blank amounts | All passed |
| 6 | `data/orders_clean.csv` | Produced the cleaned export | Rebuilt it independently from `orders_enriched.csv` and the products table; both files matched row for row | Matched |
| 7 | `docs/spreadsheet_notes.md` | Drafted and then rewrote the notes | Read it against the workbook to make sure every number and formula in it is real | Corrected, see below |
| 8 | `docs/dashboard_spec.md` | Computed the KPIs and chart values and drafted the text | Re-ran the figures with separate queries on the seed and checked the totals against q05, q11 and q13 | Matched |
| 9 | `README.md` | Drafted the layout and run instructions | Checked file names and paths against the repository | Matched |

## Claims I verified before relying on them
| Claim | Check | Outcome |
|---|---|---|
| Revenue means completed orders only | Used `status = 'completed'` in every revenue query and sheet formula | Consistent: 346200 |
| q11 should use an inner join and COUNT(DISTINCT) | A customer can order several times in a month; every order has a customer | Correct, row count 12 |
| Tier columns can be computed without an alias in WHERE | Wrote the CASE expression out in full in q12 and q13 | Both run and give 9 and 12 rows |
| Region and rep monthly revenue in the spreadsheet matches SQL | Compared all 12 rows against q11 and all 12 against q13 | All 24 comparisons agree |
| North is the top region | Compared completed revenue by region | North 119,300, ahead of South 82,500 |
| Air Fryer drives the November jump in Home | Added up completed Home orders for November | Air Fryer is 78,000 of 83,200 |

## Problems found and fixed
- The first version of the workbook put the XLOOKUP fallback test in columns P:Q of the `orders` tab. Exporting that tab as CSV would have added extra columns to `orders_clean.csv`. The test now sits on the Validation tab, and `orders` has exactly 14 columns.
- The first notes file mentioned a "rubric caveat" and a "supplied excerpt", which does not belong in a submission. It was removed.
- The summary tabs are formula tables built with COUNTIFS and SUMIFS, not native pivot tables. The notes now say so plainly.

## What I did not use AI for
The business question, the choice of revenue definition, and the decision to submit were mine. I am responsible for the correctness of everything in this repository.
