# Manuscript Review Checklist

**Manuscript:** *Mate-choice copying in non-human animals: an update of two meta-analyses*
**Source reviewed:** `main.tex` (587 lines) + tables, in the Overleaf folder
**Date:** 2026-07-09

Verified as **correct** (not issues): `metafor v.5.0-1` and `R v.4.6.0` are both real, current releases (April 2026). Core counts are internally consistent — the included-studies table has exactly 29 studies, and the 69 effect sizes / 29 studies / 33 combined species / 15 new-extraction species figures reconcile across abstract, methods, results, and supplement.

---

## Clear errors

- [ ] **1. Egger's-regression logic stated backwards (~line 203).** Text says a significant intercept means the estimate is *downwardly* biased. Your positive small-study effects and downward corrections (Hedges' g 0.44 → −0.21) mean the naïve estimate is *upwardly* (inflated) biased. Change "downwardly" → "upwardly," or reword to just "biased/inflated."
- [ ] **2. Duplicated search term (Supp., line 390).** Scopus (Davies) query: `(copying OR nonindependent OR nonindependent OR learning)` — "nonindependent" appears twice.
- [ ] **3. Grammar (line 53).** "compared with to no social information" — delete "with" or "to."

## Inconsistencies

- [ ] **4. Q1/Q2 collision (lines 57 vs 63–64).** Intro defines Q1/Q2 as *research questions*; "Additions and deviations" reuses Q1/Q2 to mean *search strategies* ("strategy described under Q2," "narrower Q1 search"). Rename the search strategies (e.g., S1/S2).
- [ ] **5. Author list vs. Author Contributions.** 15 co-authors listed with first-name-only and placeholder ORCIDs (`your-orcid-here`); Author Contributions names only 3 (Santos, Lagisz, Nakagawa). Reconcile; fill in real names/ORCIDs.
- [ ] **6. Placeholder text in Acknowledgements (line 350).** "Shoutout to all my friends." — replace.
- [ ] **7. Moderator category labels don't match.** Methods (line 105): "mating, visual association, acoustic, odour." Results/Discussion (line 238): "visual, chemical, or acoustic." "Odour"→"chemical" and "mating" dropped. Harmonize.
- [ ] **8. Self-note inside figure caption (Phylogeny, line 287).** "…the number of studies column total adds to 30, when in fact the actual number of studies included is 29." Fix the figure so the column sums to 29, or reword for readers.

## Interpretation / wording that may mislead

- [ ] **9. "Marginally below zero" understates the corrected estimate.** Bias-corrected Hedges' g intercept is −0.21 (95% CI −0.41 to −0.01), a CI that *excludes* zero — significantly negative. Called "marginally below zero" in abstract, Results (line 243), and Discussion. State more directly: the conservative correction flips the sign to a significantly negative mean.
- [ ] **10. Abstract "confidence intervals overlapping zero" (line 40).** Loose for the OR result: new-data OR = 1.46 (CI 0.968–2.201) overlaps **1**, not zero. Tighten wording so it isn't literally wrong for the OR scale.
- [ ] **11. Incomplete sentence (line 195).** "We present estimates in the figures in our results." — finish or delete.
- [ ] **12. Unexplained overlap with the originals (Results, line 219).** 13/29 new studies (45%) published ≤2019 (inside original search window) and 6 are theses. Add one sentence on *why* the originals missed nearly half (non-English, grey literature).

## Minor / polish

- [ ] **13. Missing period** at end of line 61 (after PRISMA-EcoEvo reference).
- [ ] **14. Inconsistent decimal precision.** OR `1.46 (0.968 to 2.201)` (3 dp) vs `1.81 (1.35 to 2.42)` (2 dp); g `0.206`/`0.445` (3 dp) vs taxon g `0.24`/`0.49`/`0.71` (2 dp). Standardize (2 dp conventional).
- [ ] **15. Rounding.** "46 effect sizes (66% of total)" — 46/69 = 66.7% ≈ 67%.
- [ ] **16. Tense (line 226).** "Our new data has a mean…" → "had," for consistency.
- [ ] **17. Unreferenced equation labels.** `eq:d-means` (line 120) and `eq:or-to-var-d` (line 170) are labelled but never cited.
- [ ] **18. Bib entries to check.** `cinarPhylogeneticMultilevelMetaanalysis` and `michonneauRotlPackageInteract` appear to lack a year — verify completeness.

## Methodological flag (not an error)

- [ ] **19. Figure data extraction via "Google Gemini 3.1 Pro" (line 107).** Validated against `metaDigitise` on only 20 records; described qualitatively ("indistinguishable"). Reviewers will scrutinize an LLM as the *primary* extraction tool. Enlarge the validation set and report a concrete agreement statistic (correlation / mean absolute difference).
