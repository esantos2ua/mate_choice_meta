# Final check — `main (9).tex` + Biology Open submission requirements

Audited 2026-08-06 against the 09:13 render and [BiO manuscript preparation](https://journals.biologists.com/bio/pages/manuscript-prep) (last updated 22 July 2026).

**Verdict:** the transcription is ~85% correct. Seven number groups were missed, all in the Results and Supplementary Results. Separately, five BiO requirements are unmet, one of which (the abstract) is substantial work.

---

# PART A — Numbers still stale in `main (9).tex`

Everything in the abstract, Discussion, heterogeneity paragraph and bias-correction paragraph is **correct** ✔. The misses cluster in two places: the taxon paragraph (line 226), the exploratory moderator paragraph (line 231), and the sensitivity paragraph (line 470).

## A1 · Line 226 — taxonomic group means and omnibus test

Hedges' *g* values shifted with the Davies fix; **all log OR values are correct as written** ✔.

| Item | Currently | Should be |
|---|---|---|
| Arthropods, *g* | 0.24 (0.01 to 0.46) | **0.25 (0.03 to 0.47)** |
| Fish, *g* | 0.49 (0.28 to 0.69) | **0.50 (0.30 to 0.70)** |
| Other vertebrates, *g* | 0.71 (0.36 to 1.07) | **0.70 (0.35 to 1.05)** |
| Omnibus, *g* | *F*<sub>2,27</sub> = 3.06, *p* = 0.063 | ***F*<sub>2,27</sub> = 3.00, *p* = 0.066** |
| Residual τ², fish / arthropods (*g*) | 0.54 / 0.13 | **0.53 / 0.12** |
| All log OR values | 0.33, 0.82, 0.61; *F*<sub>2,25</sub> = 1.17, *p* = 0.327; τ² 1.04 / 0.15 | ✔ correct |

## A2 · Line 231 — mechanism and virginity contrasts

| Item | Currently | Should be |
|---|---|---|
| Mechanism, combined *g* | 0.44 *vs.* 0.44; *F*<sub>1,225</sub> = 0.003, *p* = 0.96 | **0.43 *vs.* 0.46; *F*<sub>1,225</sub> = 0.05, *p* = 0.82** |
| Virginity, combined OR | OR = 1.75 *vs.* 1.91; *p* = 0.72 | add the statistic: ***F*<sub>1,170</sub> = 0.13, *p* = 0.72** |
| New-extraction values (0.26/0.16, 0.48/0.30, 0.09/0.36, *F*<sub>1,27</sub> = 1.61) | | ✔ all correct |

## A3 · Line 470 — contentious-effect-size sensitivity

This paragraph appears to predate the final render entirely — even its "Main" row disagrees with the Results.

| Version | Currently | Should be |
|---|---|---|
| Hedges' *g*, leave-out | 0.41 (0.22 to 0.60), *k* = 213 | **0.42 (0.22 to 0.61)**, *k* = 213 |
| Hedges' *g*, corrected | 0.42 (0.23 to 0.60), *k* = 225 | **0.42 (0.23 to 0.61)**, *k* = 225 |
| OR, main | 1.81 (1.36 to 2.42) | **1.81 (1.34 to 2.45)** |
| OR, leave-out | 1.77 (1.32 to 2.38) | **1.77 (1.30 to 2.41)** |
| OR, corrected | 1.79 (1.36 to 2.34) | **1.79 (1.35 to 2.36)** |

⚠️ Consider adding the study counts, now that they are meaningful: 87 / 80 / 87 studies for Hedges' *g*, 69 / 60 / 67 for log OR.

## A4 · Two placeholders

- `⟨⟨Zenodo DOI⟩⟩` at line 206.
- `\orcidlink{your-orcid-here}` ×3 (Erick, Marija, Sergio), plus six authors with no surname in the `\author{}` block.

---

# PART B — Biology Open compliance

BiO offers **format-free first submission**, so much of this can wait until revision. The table separates what must be right *now* from what can wait.

## B1 · Required at submission

| Requirement | Status | Action |
|---|---|---|
| **Abstract ≤ 200 words** | 🔴 **416 words** | Must be cut by more than half — see below |
| **Keywords 3–6** | 🔴 7 | Drop one; "mate choice" and "nonindependent mate choice" overlap with the title and each other |
| **Running title ≤ 32 characters** | 🔴 absent | e.g. `Mate choice copying: an update` (30) |
| **Summary statement, 15–30 words** | 🔴 absent | For e-alerts; must not repeat the title |
| **≤ 8000 words** (excl. references and Methods) | ✅ ~3045 | Comfortable |
| **≤ 8 display items** | ⚠️ **exactly 8** (7 figures + Table 1) | At the cap. The E16 composition table cannot be added to the main text — put it in the supplement |
| **Single PDF at first submission** | — | LaTeX source only at revision |

**On the abstract.** BiO's limit is 200 words and yours is 416. This is the one genuinely substantial job left. The bias-correction material is where the space went; the two-correction contrast can be compressed to a single clause, and the sentences on leave-one-out robustness and on prediction/heterogeneity can be cut entirely — neither is a headline finding. Note also that BiO abstracts take **no references and no subheadings**, which yours already satisfies.

## B2 · Required, and not format-dependent

| Requirement | Status | Action |
|---|---|---|
| **AI use declared in a dedicated Materials and Methods section** | 🔴 missing | You used `Google Gemini 3.1 Pro` to extract data from figures. BiO's [AI policy](https://journals.biologists.com/journals/pages/ai-policies) requires this in its own subsection, not only in passing under Data collection. The `metaDigitise` validation is a strength — state it there |
| **Full names including middle initials for all authors** | 🔴 six authors have first names only | Same circulation as E27 |
| **Data and resource availability** (exact section name) | 🟡 yours is "Data Availability Statement" | Rename; add the Zenodo DOI and repository name as required |
| **Competing interests wording** | 🟡 "The authors declare that no competing interests exist" | BiO asks for the exact phrase **"No competing interests declared"** |
| **Funding: official agency names from the Crossref registry** | 🟡 uses NSERC, NAWA, CERC abbreviations | Spell out in full, e.g. "Natural Sciences and Engineering Research Council of Canada" |

## B3 · Can wait until revision (format-free at first submission)

| Requirement | Status |
|---|---|
| Figure panel labels **uppercase A, B, C** | 🟡 24 instances of lowercase `\textbf{a}` etc. |
| **Harvard (name, date)** in-text citations | 🟡 currently numeric — a biblatex style change, not a manual edit |
| Figure citation format `Fig. 1A,B`, `Figs 1, 2`, `Table 1` | 🟡 currently `Figure~\ref*{...}` |
| Equations cited as `Eqn 1` | 🟡 currently `\autoref` |
| 1.5 line spacing, continuous line numbers, page numbers | 🟡 add `setspace` + `lineno` |
| Figure legends: first sentence bold | ✅ already done |
| Supplementary numbering `Fig. S1`, `Table S1` | ✅ already done |

## B4 · Two things worth knowing

- **Reproducibility of results must be addressed** — BiO's [submission checklist](https://journals.biologists.com/DocumentLibrary/BIO/Checklist.pdf) is required at revision and asks specifically about this. Your Results already carry it implicitly via the sensitivity analyses; a sentence making it explicit would help.
- **Supplementary information must be a single PDF**, ≤50 MB, and every item must be cited at least once in the main text. Your nine supplementary figures and four supplementary tables need collating, and the website is a *separate* archive — BiO does not accept "text files that provide additional materials and methods, results or discussions", which reinforces the E14 decision to treat the website as reproducibility-only.

---

# Suggested order

1. **Fix A1–A3** — 15 minutes, purely numeric, all values above.
2. **Cut the abstract to 200 words** — the real work.
3. **Add running title, summary statement, AI declaration**; trim keywords to six.
4. **Rename Data Availability**, fix competing-interests wording, spell out funders.
5. **Chase author names/ORCIDs and mint the Zenodo DOI.**
6. Leave B3 for revision — BiO explicitly does not want you reformatting for first submission.
