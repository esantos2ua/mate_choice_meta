# A1 — Yang bias-robust correction: what changed, and what must be updated

Applied 2026-08-05. Companion to `unresolved_comments_EDITS_2026-07-31.md` (Part 0).

## What was wrong

Yang et al.'s step one is a **multivariate fixed-effect model weighted by the sampling variance–covariance matrix** (FE + VCV, ρ = 0.5). The inverse-VCV weighting *is* the bias-robust mechanism. The repo used a univariate `rma(vi = vi, method = "FE")`, which weights each effect size by 1/*vᵢ* independently — discarding the within-study correlation and letting studies with many effect sizes accumulate weight in proportion to their effect-size count.

```r
# before
fe <- metafor::rma(yi = yi, vi = vi, method = "FE", test = "t")
metafor::robust(fe, cluster = study, clubSandwich = TRUE)

# after
VCV <- metafor::vcalc(vi = vi, cluster = identifierStudyId,
                      obs = identifierEffectSizeID, rho = 0.5, data = dat)
fe  <- metafor::rma.mv(yi = yi, V = VCV, method = "REML",
                       test = "t", dfs = "contain", sparse = TRUE, data = dat)
metafor::robust(fe, cluster = dat$identifierStudyId, adjust = TRUE, clubSandwich = TRUE)
```

This changes the **point estimate**, not only its interval.

---

## Code changes made (3 model fits + 4 prose/label edits)

| File | Location | Change |
|---|---|---|
| `scripts/1_effect_size_calculation_pipeline/overall_effect.qmd` | `fit_bias_robust()`, chunk `fit_bias_robust_splits` | Rewritten as FE + VCV; gained `obs_var` and `rho` arguments |
| " | bullet above that chunk | Method description updated |
| `scripts/1_effect_size_calculation_pipeline/publication_bias.qmd` | chunk `hedges_biasrobust_models` | `fe_hedges` rewritten as FE + VCV (`VCV_hedges_fe` added) |
| " | chunk `or_biasrobust_models` | `fe_or` rewritten as FE + VCV (`VCV_or_fe` added) |
| " | "New method" bullet (§Bias-Corrected Means) | Method description updated; CR2/no-random-effects rationale added |
| " | comparison table label ×2 | "FE + CR2" → "FE + VCV, CR2" |
| " | summary paragraph | "fixed-effect + CR2" → "FE + VCV, then CR2" |

`fit_bias_robust()` is called for six splits (new / original / combined × two scales), so **all six bias-robust estimates change**, not just the combined ones.

## A2 + E6 + A3 changes made (applied 2026-08-05 on your instruction)

### A2 — phylogenetic term added to the bias-corrected models

| File | Change |
|---|---|
| `overall_effect.qmd` | `fit_corrected_mv()` gains `phylo_cor` / `phylo_var` arguments and the same phylogeny block as `fit_overall_mv()` (subset correlation matrix, level cleaning, graceful fallback with a warning). Returns `used_phylo`. |
| " | All **6 call sites** updated: `phylo_cor_new` for the new-extraction splits, `phylo_cor_hedges` / `phylo_cor_or` for original and combined. |
| `publication_bias.qmd` | Had **no phylogeny scaffolding at all**. Ported from `overall_effect.qmd`: `recode_new`, `recode_davies`, `jones_binomial`, `read_phylo()`, the two correlation matrices, and `species_phylo` on all four dataset builders (`hedges_new`, `hedges_davies`, `or_new`, `or_jones` — the last via the Family + epithet join, with the unmapped-epithet warning). |
| " | New helper `phylo_terms(dat, phylo_cor)` returns `$random`, `$R` and a level-cleaned `$data`; **all 8 `rma.mv` models** rewired to use it: `ma_hedges`, `egger_hedges`, `egger_hedges_v`, `decline_hedges`, `ma_or`, `egger_or`, `egger_or_v`, `decline_or`. |

### E6 — phylogenetic term added to the taxonomic-moderator model

`fit_taxon_hetero_mv()` gains `phylo_cor` / `phylo_var`, and the fallback cascade now has **four** candidates instead of two:

1. Heteroscedastic (HCS, ρ = 0) **+ phylogeny** ← new primary
2. Homoscedastic **+ phylogeny** ← new
3. Heteroscedastic (HCS, ρ = 0) — the previous primary, now a fallback
4. Homoscedastic

Both call sites pass the matching matrix. This design answers E6 empirically: if HCS + phylogeny converges, the placeholder disappears; if it does not, the cascade log records the failure and *that* becomes the justification the Methods needs. Either way you get a defensible sentence instead of a guess.

### A3 — `dfs = "contain"` harmonised

Added to `fit_overall_mv()`, `fit_corrected_mv()`, and all 8 `publication_bias.qmd` models. Already present in `fit_taxon_hetero_mv()` and `moderator_analysis.qmd`. The Yang FE models also carry it.

### ⚠️ Not changed — `moderator_analysis.qmd`

The three exploratory biological-moderator models still lack the phylogenetic term. Adding it means a third port of the scaffolding *plus* threading `species_phylo` through bespoke subsets (`comb_hedges_mech`, `comb_or_virgin`) that bind new and original data with moderator-specific filtering. I stopped rather than blind-edit that on top of everything above. These models are exploratory, all non-significant, and reported only in the supplement — but say the word and I'll finish the job.

### ⚠️ The Yang FE models correctly have *no* random effects

`fit_bias_robust()` and `fe_hedges` / `fe_or` were deliberately **not** given a phylogenetic term. A fixed-effect step one is what makes the CR2 correction valid; adding random effects would reintroduce exactly the crossed-random-effects problem Kyle raised. This is by design, not an oversight.

---

## Step 1 — Re-render

Quarto's freeze hashes the source, so editing the `.qmd` invalidates it automatically; no need to clear `_freeze/` by hand.

```bash
cd /path/to/mate_choice_meta
quarto render
```

Then confirm in the console output that step one now prints **`Variance Components: none`** and that the CR2 block reports **`Number of clusters`** and Satterthwaite df. If either is missing, the fit did not take.

---

## Step 2 — Numbers to re-read and update

### 2a. Numbers in `main.tex` — now a much wider set

With A2 and E6 applied, **every multilevel estimate in the paper is refitted**, not just the bias-robust ones. Treat every number below as provisional until re-rendered.

| Quantity | Currently in the manuscript | Why it moves |
|---|---|---|
| Bias-robust mean + CI, Hedges' *g* | 0.34 (0.24 to 0.44) | A1 |
| Bias-robust mean + CI, log OR | 0.57 (0.42 to 0.73), OR = 1.77 | A1 |
| Bias-corrected mean + CI, Hedges' *g* | −0.21 (−0.41 to −0.01) | A2 — phylogeny added |
| Bias-corrected mean + CI, log OR | 0.10 (−0.22 to 0.42), OR = 1.11 | A2 |
| Egger slopes β<sub>√vi</sub> | 2.11 (1.23 to 2.99); 4.36 (3.22 to 5.49) | A2 + A3 |
| Time-lag β<sub>year</sub> | −0.028; −0.002 | A2 + A3 |
| Taxon group means, both scales | *g* 0.24 / 0.49 / 0.71; lnOR 0.33 / 0.82 / 0.61 | E6 |
| Taxon omnibus tests | *F*<sub>2,28</sub> = 3.06; *F*<sub>2,26</sub> = 1.17 | E6 — df will change |
| Group-specific τ² | 0.13 / 0.54 / 0.48 and 0.15 / 1.04 / 0.30 | E6 |
| Total and partial *I*², Table `tab:partial-i2` | *I*² > 74%, phylo < 7% | A3 (df only) — verify |

The **uncorrected** pooled means (*g* = 0.44; OR = 1.81) should be **unchanged** — `fit_overall_mv` already had phylogeny, and only `dfs` changed, which affects inference, not the point estimate. If those move, something is wrong: check first.

⚠️ Expect the CI to **widen**. The old diagonal weighting understated dependence in the point estimate while CR2 corrected only the SE; with the VCV in the weights, the two steps are now consistent. If the interval narrows instead, check the fit before believing it.

### 2b. Figures to regenerate and re-copy into `figures/`

Two manuscript figures carry the green Bias-Robust diamond:

| Manuscript figure | Generated by | Source chunk |
|---|---|---|
| `figures/correction_comparison_hedges-1.png` (`fig:hedgesorchard`) | `overall_effect.qmd` | `correction_comparison_hedges` |
| `figures/correction_comparison_or-1.png` (`fig:ororchard`) | `overall_effect.qmd` | `correction_comparison_or` |

Each has **three panels** (New / Original / Combined), and all three green diamonds move — the per-split estimates change too.

With A2 and E6 applied, **four more manuscript figures** are now affected:

| Manuscript figure | Generated by | Why |
|---|---|---|
| `figures/taxon_moderator_orchard.pdf` | `overall_effect.qmd` | E6 — phylogeny in the taxon model |
| `figures/dashboard_eggers_timelag_hedges.pdf` | `publication_bias.qmd` | A2 — phylogeny in Egger/decline models |
| `figures/dashboard_eggers_timelag_or.pdf` | `publication_bias.qmd` | A2 |
| `figures/funnel_hedges.pdf`, `figures/funnel_or.pdf` | `publication_bias.qmd` | A2 — residuals come from `ma_*` |

Still unaffected: `prisma_flowdiagram`, `phylogeny_*`, `loo_*`, `sensitivity_contentious_*` (`sensitivity_analysis.qmd` already had phylogeny and was not touched).

Also regenerated on the website but not used in the manuscript: the `pub_bias_plot` panels in `publication_bias.qmd` (`hedges_pub_bias_plot`, `or_pub_bias_plot`) and the three-estimate comparison table.

### 2c. Manuscript prose that states the bias-robust result

Search for these and re-check each against the new numbers. Wording may survive; the direction of the claim must be verified, not assumed.

| Location | Current claim | Action |
|---|---|---|
| Abstract | "a bias-robust estimator retained a positive but reduced mean" | Verify still true |
| Results, §Small-study effects | "whereas the bias-robust estimator retained a positive but reduced effect" | Verify |
| Discussion, §Knowledge gaps (¶1) | "the bias-robust estimator retained a positive but reduced signal" | Verify |
| Conclusion | "bears clear fingerprints of small-study and selective-reporting bias that, under the more conservative correction, draw the estimate close to zero" | Verify — refers to the Nakagawa correction, so likely safe |
| Fig. captions (both orchards) | "bias-robust (Yang; green diamond)" | No change needed |

**If the bias-robust estimate loses significance**, the framing in the abstract and Discussion shifts materially — the paper would then have *two* corrections pointing at a null rather than one positive and one null. That is the scenario to watch for; it would strengthen E1's already-hedged abstract wording but require rewriting the "retained a positive but reduced" phrasing throughout.

### 2d. Methods text

**E11** in the edit sheet is already written for the corrected implementation and needs one addition — the method name. Update the E11 replacement text so it reads *"a bias-robust weighting scheme (a multivariate fixed-effect GLS estimator weighted by the sampling variance–covariance matrix, which is less susceptible to selective reporting)"* rather than the current "(a fixed- or common-effects GLS estimator...)", which describes the old, incorrect implementation.

### 2e. Downstream artefacts

- `outputs/1_effect_size_calculation_pipeline/` — the two `correction_comparison_*` PDF/PNG pairs.
- `docs/` — rebuilt by `quarto render`.
- Zenodo archive (**E14**, comment #47) — mint the DOI *after* this fix, not before.

---

## Verification checklist

- [ ] `quarto render` completes without errors
- [ ] No `Phylogenetic random effect skipped` warnings anywhere in the log
- [ ] No `Unmapped Jones epithets` warning from `publication_bias.qmd`
- [ ] Yang step-one fits report `Variance Components: none`
- [ ] CR2 output reports `Number of clusters` = 80 (Hedges' *g*) and 69 (log OR) for the combined models
- [ ] Bias-corrected models now show a **fourth** variance component (`species_phylo`)
- [ ] Taxon model: note which cascade candidate was chosen → this is the E6 answer
- [ ] Uncorrected means still 0.44 and 1.81 (if not, investigate before proceeding)
- [ ] All numbers in table 2a re-read and updated in `main.tex`
- [ ] Six figures re-copied into `figures/` (2 correction_comparison, taxon_moderator_orchard, 2 dashboard, 2 funnel)
- [ ] Four prose claims in 2c re-verified against the new direction
- [ ] E11 and E6 Methods text updated per 2d
- [ ] Decide whether to finish `moderator_analysis.qmd`

---

## Caveats — read before rendering

**No R in this environment, so none of this has been executed.** I verified that every R chunk in both edited files is brace/paren/bracket balanced (49 chunks in `overall_effect.qmd`, 23 in `publication_bias.qmd`, zero imbalances), but that is a syntax check, not a run.

Four things to watch on first render:

1. **HCS + phylogeny may not converge** in the taxon model. That is an expected outcome, not a failure — the cascade falls back automatically and the log records it. Read the "Chosen structure" line in the fit diagnostic and write the E6 justification from whatever it reports.
2. **`dfs = "contain"` on the Yang FE models** (no random effects). The Yang tutorial passes it on exactly this shape, so it should be fine; if `rma.mv` objects, drop it — CR2's Satterthwaite df supersede it.
3. **`adjust = TRUE` in `robust()`.** Added to match the tutorial. Likely the default and immaterial under `clubSandwich = TRUE`, but unconfirmed against the metafor docs.
4. **Watch for the phylogeny fallback warnings.** Both new code paths warn rather than fail when a species is missing from the correlation matrix — deliberate, so a name mismatch cannot break the render. But it also means a silent fallback would leave you with the *old* structure while you believe you have the new one. Grep the render log for `Phylogenetic random effect skipped` and `Unmapped Jones epithets`; both should be absent.

`publication_bias.qmd` is the highest-risk file, since the species-name reconciliation was ported into it rather than written against a working fit. If a fallback warning appears there, compare its `species_phylo` values against `data/2_phylogeny/combined_species_counts.csv`.
