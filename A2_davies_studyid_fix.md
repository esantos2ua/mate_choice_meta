# Davies study-identifier fix — what to run and what will change

Applied 2026-08-05. Companion to `A1_yang_correction_impact.md`.

## The bug

`hedges_davies` keyed on `identifierStudyId = Author`, a bare surname string with no year. Davies' spreadsheet carries a proper **`Study_no`** column that was never used. Five author strings each cover 2–3 separate publications:

| Author string | `Study_no` | Years | Effect sizes |
|---|---|---|---|
| Brooks | 11, 12 | 1996, 1999 | 8 |
| Dugatkin and Godin | 20, 22, 27 | 1992, 1993, 1998 | 8 |
| Nobel et al | 62, 63 | 2018 | 6 |
| Ophir and Galef | 65, 66 | 2003, 2004 | 3 |
| White and Galef | 77, 78, 79 | 1999, 2000 | 4 |

**29 of 158 Davies effect sizes (18%) affected; 7 studies lost.** Jones and the new extraction are clean.

`Author_Year` would not have been enough — "Nobel et al 2018" and "White and Galef 2000" each span two `Study_no`.

## The fix

```r
identifierStudyId = paste0(Author, " [", Study_no, "]")   # was: Author
```

`Study_no` alone is correct but renders as bare integers in the leave-one-study-out figures, which label by study. The composite keeps those plots readable ("Brooks [11]", "Brooks [12]") while guaranteeing uniqueness.

Applied in **four** files — `overall_effect.qmd:192/203`, `publication_bias.qmd:267/275`, `sensitivity_analysis.qmd:170`, `moderator_analysis.qmd:191`.

In the first two the ID is built in the existing `mutate()` as `.study_id` and then referenced in `select()`, because `select()` cannot evaluate expressions. The other two use `transmute()`, which can.

## What to run

```bash
git add -A && git commit -m "Fix Davies study ID: Author -> Author [Study_no]"
quarto render 2>&1 | tee render.log
```

All four files change, so **everything re-executes** — expect a full-length render, not the quick one.

## What will change

### Should change

| Quantity | Now | Expect |
|---|---|---|
| Davies study contribution | 51 | **58** |
| Combined Hedges' *g* study count | 80 | **87** |
| Total distinct studies (all sources) | 120 | **127** |
| Every Hedges' *g* estimate | — | small shifts: mean, CI, σ², *I*², τ², PI, Egger slope, time-lag β, both bias corrections, taxon model, LOO, contentious-ES sensitivity |
| Hedges' *g* containment df | year at df 224 | should drop to roughly study-level (~80s) |

The df change is the diagnostic that started this. If publication year still sits at df ≈ 224 on the Hedges' *g* scale after the fix, the ID is still not unique per publication and something else is wrong.

### Must NOT change

| Quantity | Value |
|---|---|
| Log OR study count | 69 |
| Every log OR estimate | 1.81 (1.34–2.45), bias-corrected 0.10, bias-robust 0.55, Egger 2.11, β<sub>year</sub> −0.028 |
| New-extraction-only estimates | *g* 0.21, OR 1.46 |
| Effect-size counts | 227 *g*, 172 lnOR, 69 new |
| Species count | 33 |

Davies contributes no odds ratios, so **the entire log OR side is a control**. If any OR number moves, the edit has touched something it should not have — investigate before going further.

## Manuscript updates after the render

Everything in `A1_yang_correction_impact.md` §2a again, plus:

- **"80 studies" → "87 studies"** in the abstract (E1), the Discussion opener (E20), and E1b/E16 in the edit sheet.
- **"120 studies"** if it appears anywhere.
- The two stale values already flagged in the last audit — Hedges' *g* Egger slope (4.36 → recheck) and time-lag β<sub>year</sub> (−0.002 → recheck) — will move again; take them fresh rather than using the values from the previous audit.
- The **seven figures** in `overleaf_upload/` all regenerate; re-copy and re-upload.
- The leave-one-study-out figures now label Davies studies as `Author [Study_no]`. Check the labels still fit the panel.

⚠️ **Uncommitted risk:** the manuscript currently in Overleaf carries the *previous* render's numbers. Do not transcribe anything until this render finishes, or you will transcribe twice.

## Caveat

Not executed here — no R in this environment. All five R chunks re-checked for balanced delimiters and no `paste0()` left inside a `select()`. `Study_no` and `Author` both survive to the point of use in all four files (each reads the raw sheet with no intervening `select`).
