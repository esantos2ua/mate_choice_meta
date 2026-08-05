# Copy-paste edit sheet — 47 unresolved comments

Companion to `unresolved_comments_plan_2026-07-31.md` (which explains *why*). This file is **ordered by line number in `main (7).tex`** so you can work top-to-bottom in Overleaf without jumping around.

Each edit gives a **FIND** block (exact current text — search for it) and a **REPLACE** block (paste over it). Line numbers are from `main (7).tex` and will drift as you edit, so search on the FIND text rather than trusting the number.

## Status tags

| Tag | Meaning | Comments closed |
|---|---|---|
| `PASTE` | Apply verbatim. Nothing to decide, nothing to look up. | 26 |
| `FILL` | Apply verbatim except for `⟨⟨placeholder⟩⟩` tokens — one number each. | 4 |
| `WRITE` | Draft supplied, but needs your judgement or new prose. | 13 |
| `RUN` | Needs a new analysis before the text can be written. | 3 |
| — | No action (#43, a compliment). | 1 |

Placeholders are written as `⟨⟨like this⟩⟩` so you can grep for `⟨⟨` to find everything still outstanding.

---

# PART 0 — Code audit of the two bias corrections

Triggered by the E11 finding. Verdict up front: **the Nakagawa bias-corrected estimate is implemented correctly. The Yang bias-robust estimate is not** — step one uses the wrong weighting scheme, which changes the point estimate, not just its interval. Everything below is checked against the authors' own tutorial ([Yang et al., BiasRobustMA tutorial](https://yefeng0920.github.io/BiasRobustMA_tutorial/)), which accompanies the paper you cite.

## A1 · ✅ FIXED IN CODE 2026-08-05 — Yang bias-robust: step one omitted the VCV

> **The code fix is applied.** Three model fits in `overall_effect.qmd` and `publication_bias.qmd` now use FE + VCV. See **`A1_yang_correction_impact.md`** for the full re-render and update checklist. The description below records what was wrong and why.

**What the method specifies.** Yang et al.'s step one is a *multivariate* fixed-effect model whose weights come from the inverse variance–covariance matrix — "FE + VCV" in their words. The point of the method is the weighting scheme: *"the inverse VCV weighting scheme assigned smaller weights to studies with low precision and large effects, thereby penalizing studies that appear to be 'selectively reported'."*

```r
# tutorial, step one
VCV      <- vcalc(vi = var.eff.size, cluster = study, obs = obs, rho = 0.5, data = dat)
mod_MLFE <- rma.mv(yi = eff.size, V = VCV, method = "REML",
                   test = "t", dfs = "contain", data = dat)
# tutorial, step two
mod_MLFE_RVE <- robust(mod_MLFE, cluster = study, adjust = TRUE, clubSandwich = TRUE)
```

**What the repo does** — identically in `overall_effect.qmd:1274` (`fit_bias_robust`) and `publication_bias.qmd:845` and `:905`:

```r
fe <- metafor::rma(yi = yi, vi = vi, method = "FE", test = "t")   # univariate, diagonal weights
metafor::robust(fe, cluster = identifierStudyId, clubSandwich = TRUE)
```

**Why it matters.** `rma()` with `vi` weights every effect size by 1/*v_i* independently. That discards the ρ = 0.5 within-study correlation the rest of the paper assumes, and lets a study contributing many effect sizes carry proportionally more weight. Here that is not hypothetical: *Drosophila* and *Poecilia* studies supply roughly two-thirds of all effect sizes. The bias-robust means reported at audit time — *g* = 0.34 (0.24 to 0.44) and log OR = 0.57 (0.42 to 0.73) — were therefore not the estimator the manuscript said it used. After the fix they are **0.31 (0.22 to 0.41)** and **0.55 (0.39 to 0.71)**, both still clearly positive.

⚠️ I cannot predict the direction of the shift without refitting, and would not guess: VCV weighting downweights multi-effect-size studies, and the taxon model shows arthropods have both the smallest means and the most effect sizes, so the estimate could move either way.

**The fix** (two lines, in all three places):
```r
VCV <- metafor::vcalc(vi = vi, cluster = identifierStudyId,
                      obs = identifierEffectSizeID, rho = 0.5, data = dat)
fe  <- metafor::rma.mv(yi = yi, V = VCV, method = "REML",
                       test = "t", dfs = "contain", data = dat, sparse = TRUE)
metafor::robust(fe, cluster = dat$identifierStudyId, adjust = TRUE, clubSandwich = TRUE)
```
`rma.mv()` with no `random` argument *is* the fixed-effect model — the output reports "Variance Components: none". Both scripts already build exactly this VCV for the Egger models, so the ingredients are on hand.

**Knock-on if you refit:** the bias-robust numbers in Supplementary Results, the green diamonds in the two orchard figures, the abstract's "bias-robust estimator retained a positive but reduced mean", and the parallel Discussion sentences. This is the one item in the whole set that could change a headline number, so it is worth settling before the Discussion prose (E21–E23).

⚠️ Also pass `adjust = TRUE` as the tutorial does. Verify whether `metafor::robust()` already defaults to it when `clubSandwich = TRUE` — I believe the CR2 small-sample correction is inherent, making this immaterial, but I have not confirmed it.

## A2 · ✅ FIXED IN CODE 2026-08-05 — Nakagawa bias-corrected: was correct, but lacked phylogeny

`fit_corrected_mv` (`overall_effect.qmd:604`) and `egger_*_v` (`publication_bias.qmd:431`, `:675`) are faithful to Nakagawa et al. (2022):

| Check | Status |
|---|---|
| Moderator is the sampling variance `vi` (step 2), not SE | ✔ correct |
| Test model separately uses `~ 1 + se` (step 1) | ✔ correct — matches the two-step in your Methods |
| Adjusted mean = intercept at `vi = 0`, via `mod_results(at = list(vi = 0), mod = "1")` | ✔ correct |
| VCV with ρ = 0.5 in the meta-regression | ✔ correct (stricter than the tutorial, which uses diagonal `V` for its Egger example) |
| Random effects: study, effect-size, species | ✔ |
| **Phylogenetic random effect** | ✅ **added 2026-08-05** (was absent while the uncorrected models had it) |

**The gap, now closed.** `fit_overall_mv` included the phylogenetic correlation matrix; `fit_corrected_mv` did not, so the headline contrast conflated the `vi` moderator with the removal of a random effect. On your instruction the term was added to `fit_corrected_mv` (all 6 call sites) and to all 8 models in `publication_bias.qmd`, which had no phylogeny scaffolding at all and needed it ported.

**It mattered more than expected.** The bias-corrected Hedges' *g* moved from −0.213, 95% CI (−0.412, −0.014), *p* = 0.036 to **−0.225, 95% CI (−0.487, 0.038), *p* = 0.091** — the standard error rose from 0.101 to 0.128 and the interval now spans zero. Four passages in the manuscript claiming it "fell below zero" are no longer supported. See `A1_yang_correction_impact.md` §2c for the exact rewording. The log OR bias-corrected mean was unchanged at 0.10.

## A3 · ✅ FIXED IN CODE 2026-08-05 — degrees-of-freedom convention was mixed

| Model | Call | `dfs` |
|---|---|---|
| Intercept-only (`fit_overall_mv`) | `rma.mv` | default (residual) |
| Bias-corrected (`fit_corrected_mv`) | `rma.mv` | default (residual) |
| Egger / decline (`publication_bias.qmd`) | `rma.mv` | default (residual) |
| Taxon moderator (`fit_taxon_hetero_mv`) | `rma.mv` | **`"contain"`** |
| Biological moderators (`moderator_analysis.qmd:385`) | `rma.mv` | **`"contain"`** |

Both the Nakagawa and Yang tutorials use `dfs = "contain"` throughout, and on your instruction it was added to every remaining call: `fit_overall_mv`, `fit_corrected_mv`, all 8 `publication_bias.qmd` models, and the Yang FE models. Point estimates are unaffected — `dfs` changes inference only — but **every confidence interval and *p*-value in the paper shifts slightly**, and the taxon omnibus df moved from (2,28) and (2,26) to (2,27) and (2,25).

⚠️ At audit time only the moderator models used `dfs = "contain"`, so the E6 draft was amended to describe both conventions. Now that they are harmonised, E6's Methods text can revert to the simpler single-convention wording — see the note in E6.

---

# PART 1 — Front matter and abstract

## E1 · `PASTE` · line 40 — whole abstract paragraph
**Closes #1 #2 #3 #4 #5 #6** (Aleksandra, Anna ×2, Kyle, Erick, Santiago, Christine)

Replace the entire `\noindent` paragraph. **Study counts resolved — see E1b: 80 and 69.**

**FIND** (the sentence that starts the block, through the end of the paragraph):
```
Using a comprehensive, multilingual, and grey-literature-inclusive search across seven languages, we added 69 new effect sizes from 29 studies and combined them with the original datasets, harmonizing the two source metrics (odds ratio and Hedges' standardized mean difference) onto common scales.
```
…through…
```
Our results call for broader taxonomic sampling, pre-registered tests of the moderators driving mate choice copying heterogeneity, and a publication culture that reports null and small-sample results.
```

**REPLACE:**
```latex
Using a comprehensive, multilingual, and grey-literature-inclusive search across seven languages, we added 69 new effect sizes from 29 studies (15 species) to the original datasets, harmonizing the two source metrics (odds ratio and Hedges' standardized mean difference) onto common scales. The combined evidence comprises 227 Hedges' \textit{g} effect sizes from 80 studies and 172 log odds ratio effect sizes from 69 studies, spanning 33 species. We re-analyzed it with phylogenetically-informed multilevel meta-analytic models and a battery of publication bias assessments and sensitivity analyses. The overall effect of social information remained positive and statistically significant on both scales, but was appreciably smaller than the original estimates (Hedges' \textit{g} = 0.45, 95\% CI: 0.23 to 0.66, \textit{vs.} 0.58 originally; OR = 1.81, 95\% CI: 1.34 to 2.45, \textit{vs.} 2.71). Considered on its own, the new evidence was roughly half that magnitude. Heterogeneity was high and accumulated mainly within studies and among species rather than between studies or across the phylogeny, which showed little signal. We detected strong small-study effects on both scales---smaller, less precise studies reported systematically larger effects, the expected signature of selective reporting---and a partial decline in effect size over time for the binary outcomes. How much this matters depends on the correction applied: a bias-robust estimator retained a positive but reduced mean, whereas a more conservative regression-based correction drew the adjusted mean to approximately zero on both scales. The unadjusted pooled estimates were nonetheless insensitive to the removal of any single study or species, and to alternative treatment of the effect sizes that disagreed between the two source datasets. The qualitative conclusion that animals copy the mate choices of others therefore remains supported by the unadjusted evidence, but the magnitude---and, under conservative bias correction, even the presence---of a positive average effect is less certain than the original syntheses implied. The effect is also highly heterogeneous, a pattern itself consistent with theory predicting that copying is a conditional, strategic use of social information. Our results call for broader taxonomic sampling, pre-registered tests of the moderators driving this heterogeneity, and a publication culture that reports null and small-sample results.\\
```

## E1b · ✔ RESOLVED — the two study counts are 80 and 69

**Anna's proposed numbers are correct.**

**Script:** `scripts/1_effect_size_calculation_pipeline/overall_effect.qmd`, chunk `source_summary_table` (~line 360), built on the `db_hedges` and `db_or` objects assembled at ~lines 170–272.

**You do not need to re-run it** — the values are in the frozen render at `_freeze/scripts/1_effect_size_calculation_pipeline/overall_effect/execute-results/html.json`, in the "Studies & Effect Sizes by Source" table:

| Data Source | Studies (k) | Hedges' *g* ES | Log OR ES | Total ES | Species |
|---|---|---|---|---|---|
| New Extraction (Santos) | 29 | 69 | 69 | 138 | 15 |
| Original (Davies 2020) | 51 | 158 | 0 | 158 | 23 |
| Original (Jones & DuVal 2019) | 40 | 0 | 103 | 103 | 17 |
| **TOTAL** | **120** | **227** | **172** | **399** | 36 |

The table reports studies per *source*, not per *dataset*, so add the two rows that feed each metric:

- **N_g** = 29 (new) + 51 (Davies) = **80**
- **N_or** = 29 (new) + 40 (Jones & DuVal) = **69**

Simple addition is valid here: 29 + 51 + 40 = 120, exactly the TOTAL row, so no study is tagged to more than one source and there is nothing to de-duplicate. To confirm directly:

```r
n_distinct(db_hedges$identifierStudyId)  # 80
n_distinct(db_or$identifierStudyId)      # 69
```

⚠️ **Do not take the Species column from this table.** It counts 36 distinct `taxonomySpecies` strings, whereas the manuscript reports 33 species and `data/2_phylogeny/combined_species_counts.csv` has 33 rows. The gap is name reconciliation — subspecies collapsed to species, epithet-only names resolved to binomials, synonyms relabelled (all described in the Phylogeny subsection). 33 is the defensible number; 36 is a raw string count.

---

# PART 2 — Methods

## E2 · `PASTE` · line 61 — adopt MeRIT
**Closes #7** (Anna) · half of **#44**

**FIND:**
```
guidelines (\hyperref[tab:prisma-ecoevo]{Supplementary Table~\ref*{tab:prisma-ecoevo}}).
```

**REPLACE:**
```latex
guidelines (\hyperref[tab:prisma-ecoevo]{Supplementary Table~\ref*{tab:prisma-ecoevo}}). We report author contributions to each methodological step using MeRIT (Method Reporting with Initials for Transparency;~\cite{nakagawaMeritReportingInitials2023}), giving author initials in-line throughout the Methods. Where initials would be ambiguous we disambiguate by surname: AMizuno (Ayumi Mizuno) and AMilenovic (Aleksandra Milenovic); CSchneider (Cassidy Schneider) and CSosiak (Christine Sosiak).
```

Add to `10_MainTextReferences.bib`:
```bibtex
@article{nakagawaMeritReportingInitials2023,
  title   = {Method Reporting with Initials for Transparency ({{MeRIT}}) promotes more granularity and accountability in research reporting},
  author  = {Nakagawa, Shinichi and Ivimey-Cook, Edward R. and Grainger, Matthew J. and O'Dea, Rose E. and Burke, Samantha and Drobniak, Szymon M. and Gould, Elliot and Macartney, Erin L. and Martinig, April Robin and Morrison, Kyle and Paquet, Matthieu and Pick, Joel L. and Pottier, Patrice and Ricolfi, Lorenzo and Wilkinson, David P. and Willcox, Adam and Yang, Yefeng and Lagisz, Malgorzata},
  journal = {Nature Communications},
  volume  = {14},
  number  = {1},
  pages   = {1788},
  year    = {2023},
  doi     = {10.1038/s41467-023-37039-1}
}
```
⚠️ Verify the author list against the DOI before submitting — it is a large consortium paper and this list is from memory.

## E3 · `WRITE` · lines 67–77 — merge PECOS and Eligibility criteria
**Closes #8 #9 #10** (Santiago, Ayumi ×2)

Delete the `\subsection{Eligibility criteria}` heading and its paragraph entirely, and replace the PECOS block with the version below. The substantive changes are marked ▸ — everything else is your existing wording.

**FIND:** the block from `We used the PECOS (Population, Exposure, Comparator, Outcomes, and Study design) framework` through the end of the eligibility paragraph (`...significance statistics for the mate-choice-copying trials.`), including the `\subsection{Eligibility criteria}` heading between them.

**REPLACE:**
```latex
\subsection{Eligibility criteria}
We used the PECOS (Population, Exposure, Comparator, Outcomes, and Study design) framework~\cite{richardsonWellbuiltClinicalQuestion1995, fooPracticalGuideQuestion2021} to define a single set of eligibility criteria, applied to both the literature search and the two screening stages, following our pre-registered protocol~\cite{santosMatechoiceCopyingNonhuman2026} and the criteria of Jones and DuVal~\cite{jonesMechanismsSocialInfluence2019} and Davies et al.~\cite{daviesMetaanalysisFactorsInfluencing2020}.

\textbf{Population}: Non-human, sexually mature female or male individuals, from wild or captive populations of multicellular animals. Studies that experimentally manipulated sexual maturity or prior mating experience were eligible provided the focal individuals were mature at testing.

\textbf{Exposure}: Tests of the audience effect during mate choice trials; that is, the observation of a social cue (\textit{e.g.}, a female near or copulating with a male). The social cue could be the presence of a model or demonstrator individual of the same sex as the focal individual, a chemical, visual, or auditory cue, or an observed copulation.

\textbf{Comparator}: A group (sample) of females or males making a choice of mate without social cues or with neutral/conflicting cues. For instance, a no-information control: individuals tested under identical conditions but with no model present, or the model hidden behind an opaque partition---so any preference reflects chance/baseline rather than social information. Pre-demonstration preference comparators, and comparisons with an explicit chance expectation were also considered.

\textbf{Outcome}: The mating preference of the focal/observer individual. Studies had to report, for each focal individual, either a discrete mate choice or a continuous measure of preference. Examples include preference-zone time, defined as the number of seconds the observer spent within a specific distance of a target individual after the demonstration; a social learning index, calculated to quantify the bias toward the phenotype chosen by the observer; and copulation choice, defined as the phenotype the focal/observer individual chose to mate with when physical access was allowed.

\textbf{Study design}: Empirical experimental studies that expose focal/observer individuals to opposite-sex mates (with and without an audience effect), in which one focal or observer individual chooses between two individuals of the opposite sex, one of which---the target---was associated with stimuli from a model or demonstrator.

\noindent \textbf{Additional restrictions.} Beyond the PECOS criteria, studies were eligible only if (i) they were reported in English, Japanese, Polish, Portuguese, Russian, Simplified or Traditional Chinese, or Spanish; and (ii) they reported sufficient statistical information to calculate an effect size---group means with standard deviations or standard errors and sample sizes, raw choice counts, or a convertible test statistic. Effects reported only as $F$-statistics, $\chi^{2}$ values, or generalised linear mixed-model outputs were not convertible and were excluded (\hyperref[tab:excluded]{Supplementary Table~\ref*{tab:excluded}}).
```

▸ The one real change is in **Outcome**: the old criterion said studies "had to report individual, discrete choices", which contradicts both PECOS and your data (✔ 22 of 70 retained rows are mean-difference data on continuous outcomes). Ayumi flagged this twice.

▸ Tagged `WRITE` rather than `PASTE` only because you should re-read it against the pre-registration to confirm nothing was silently widened.

## E4 · `FILL` · line 143 — equal-allocation assumption
**Closes #11 #12** (Erick, Ayumi ×3)

All three numbers below are ✔ verified against the extraction spreadsheet.

**FIND:**
```
When no separate control group existed, we used the null expectation that individuals chose each option with equal probability, setting $C = D = n/2$, as the two original meta-analysis did.
```

**REPLACE:**
```latex
When no separate control group existed, we used the null expectation that individuals chose each option with equal probability, setting $C = D = n/2$, as both original meta-analyses did. This applied to 22 of the 38 binary effect sizes in our new extraction (11 of 17 studies). Where $n$ was odd, the resulting half-integer cell counts were retained rather than rounded, because $\ln(\mathit{OR})$ and its delta-method variance are defined for non-integer counts; this affected nine effect sizes. No $2\times2$ table contained a zero cell, so no continuity correction was applied. Because the equal-allocation assumption treats a within-subject or chance-expectation comparison as though it were an independent control group, and therefore likely understates sampling variance, we flagged these effect sizes and refitted the binary model with them excluded as a sensitivity analysis (⟨⟨result: see E4b⟩⟩; \nameref{supplresults}).
```

## E4b · `RUN` — sensitivity refit without imputed controls

The refit Erick is implicitly asking for. Filter to the 22 flagged rows and drop them:

```r
dat_or$imputed_control <- with(dat_or,
  effectSizeSampleSizeC == effectSizeSampleSizeD &
  (effectSizeSampleSizeC + effectSizeSampleSizeD) ==
  (effectSizeSampleSizeA + effectSizeSampleSizeB))
```
Note the `C + D == A + B` condition matters: plain `C == D` catches 26 rows, but four of those (Araújo 2024) are genuine pre-demonstration counts that happen to be equal. Refit the combined lnOR model on `!imputed_control`, then report the shifted mean in E4 and add a sentence to Supplementary Results.

## E5 · `PASTE` ✔ · line 169 — the `(n=X species?)` TODO
**Closes #13** (Iwo)

**The answer is zero — no species were grafted.** Every species was placed directly by Open Tree, so the sentence should state that rather than report a count.

**FIND:**
```
Any species that the Open Tree could not place was grafted next to a congener (n=X species?).
```

**REPLACE:**
```latex
After this reconciliation, every species in both datasets was matched to a tip in the Open Tree synthetic tree, so no species required grafting next to a congener.
```

### How this was established

Inferred from the saved trees in `outputs/2_phylogeny/`, since the count is only ever printed to the console and never written to a file:

| | `tree_combined.tre` | `tree_new_extraction.tre` |
|---|---|---|
| Tips | 33 | 15 |
| Tips matching the dataset species list exactly | 33 / 33 | 15 / 15 |
| Internal nodes (expected for a bifurcating tree) | 32 (32) | 14 (14) |
| Internal nodes **without** an Open Tree label | **0** | **0** |

Every internal node carries a genuine Open Tree identifier, and every congeneric cherry is subtended by an `mrcaott⟨A⟩ott⟨B⟩` node — a label that encodes the ott IDs of two taxa Open Tree actually contains:

- *Drosophila melanogaster* + *D. simulans* → `mrcaott505714ott505718`
- *Poecilia latipinna* + *P. mexicana* → `mrcaott6454ott23615`
- *Limia nigrofasciata* + *L. perugiae* → `mrcaott149143ott672039`
- *Etheostoma olmstedi* + *E. flabellare* → `mrcaott26366ott84336`

Had `prepR4pcm::reconcile_augment()` grafted a species with no Open Tree tip, the insertion would have created an internal node Open Tree never produced — necessarily unlabelled or synthetic. There are none. This is also consistent with your never having seen the count: `build_phylogeny.R:221` guards the message with `if (!is.null(aug$augmented) && nrow(aug$augmented) > 0)`, so zero grafts prints nothing at all, which is very likely why the placeholder was written as a question.

⚠️ This is inference from the saved topology, not a re-run. Confirm cheaply next time you execute `build_phylogeny.R`: `nrow(aug$augmented)` should be 0 (or `aug$augmented` NULL).

### Don't confuse grafting with name reconciliation
Three operations *did* occur and are already described in the manuscript — subspecies collapsed to species (*Taeniopygia guttata castanotis* → *T. guttata*), epithet-only names resolved to binomials, and synonyms relabelled (*Austruca mjoebergi* → *Uca mjoebergi*). These are why 36 raw `taxonomySpecies` strings reduce to 33 species (see **E1b**). None of them is a graft.

## E6 · `WRITE` · insert after line 179 — new model-specification subsection
**Closes #14 #15 #16 #32 #34** (Ayumi, Kyle ×3, Erick ×2)

Insert immediately after the paragraph ending `...from the package \lstinline{orchaRd} \cite{nakagawaOrchaRd20Package2023}.` and before `\subsection{Small-study effects...}`.

**INSERT:**
```latex
\subsubsection{Model specification and inference}
All models were fitted by restricted maximum likelihood (REML), and inference on fixed effects used $t$-distributed test statistics with containment degrees of freedom (\lstinline{test = "t"}, \lstinline{dfs = "contain"} in \lstinline{rma.mv}), which is preferable to $z$-based inference given the moderate number of clusters available. For every model we report the variance component of each random effect ($\sigma^2$) alongside total and partial $I^2$, and a 95\% prediction interval for the overall mean. We report both because $I^2$ describes the \textit{proportion} of observed variance not attributable to sampling error rather than its absolute magnitude, and is sensitive to the precision of the contributing studies~\cite{borensteinBasicsHeterogeneity2017, inthoutPlearPredictionInterval2016}; the prediction interval expresses the expected range of true effects in a new study on the original scale.

\subsubsection{Meta-regression models}
We fitted taxonomic group (arthropods, fish, and other vertebrates) as an intercept-coded categorical moderator on each combined dataset, following the heterogeneous-variance workflow of \lstinline{orchaRd 2.0}~\cite{nakagawaOrchaRd20Package2023}. Because residual variance differed markedly among taxonomic groups, we allowed the effect-size--level variance to differ by group, specified as a heteroscedastic compound-symmetric structure (\lstinline{struct = "HCS"}) on \lstinline{~ tax_group | identifierEffectSizeID} with the between-group correlation fixed at zero (\lstinline{rho = 0}), so that one residual variance is estimated per group with no cross-group covariance. A single pooled between-study variance (\lstinline{~ 1 | identifierStudyId}) and a homoscedastic species variance (\lstinline{~ 1 | taxonomySpecies}) were retained. As in the intercept-only models, a phylogenetic correlation matrix was included as an additional random effect. As in the main analyses, the sampling variance--covariance matrix was constructed with \lstinline{metafor::vcalc} assuming a within-study correlation of $\rho = 0.5$, and models were fitted by REML with \lstinline{test = "t"} and \lstinline{dfs = "contain"}. Both models converged at the first attempt using the \lstinline{nlminb} optimiser without warnings. We report the omnibus $F$-test of the moderator together with group-specific marginalised means and pairwise contrasts obtained with \lstinline{orchaRd::mod_results} (via \lstinline{emmeans}), so that inference does not depend on an arbitrary reference level.

Four further moderators extracted during data collection---the copying mechanism (generalized \textit{vs.} individual), the modality of the social cue (visual, chemical, or acoustic), the mating status of the observer, and the relative age of the demonstrator---were not part of our pre-registered analyses, and several of their levels are sparsely sampled. We therefore fitted them as single-moderator multilevel models on the new extraction (both scales) and, where the coding could be harmonized with an original dataset, on the combined data, and treat all four as exploratory throughout. The relative age of the demonstrator showed no variation in our extraction (all ``same-age'') and could not be analyzed.
```

Bib entries needed for the two new citations:
```bibtex
@article{borensteinBasicsHeterogeneity2017,
  title   = {Basics of meta-analysis: {{I}}$^2$ is not an absolute measure of heterogeneity},
  author  = {Borenstein, Michael and Higgins, Julian P. T. and Hedges, Larry V. and Rothstein, Hannah R.},
  journal = {Research Synthesis Methods}, volume = {8}, number = {1}, pages = {5--18},
  year    = {2017}, doi = {10.1002/jrsm.1230}
}
@article{inthoutPlearPredictionInterval2016,
  title   = {Plea for routinely presenting prediction intervals in meta-analysis},
  author  = {IntHout, Joanna and Ioannidis, John P. A. and Rovers, Maroeska M. and Goeman, Jelle J.},
  journal = {BMJ Open}, volume = {6}, number = {7}, pages = {e010247},
  year    = {2016}, doi = {10.1136/bmjopen-2015-010247}
}
```
Both DOIs are the ones Kyle pasted into his comment. ⚠️ Kyle's first DOI (`10.1002/jrsm.1678`) is *not* the Borenstein 2017 paper — verify which he meant before citing.

### ✔ Heteroscedastic structure — verified

From `overall_effect.qmd`, function `fit_taxon_hetero_mv` (~line 1637), confirmed against the executed output in `_freeze/.../overall_effect/execute-results/html.json`. Both scales used the **first** cascade candidate — no fallback was triggered.

| | Value |
|---|---|
| `struct` | `"HCS"` (heteroscedastic compound symmetry) |
| Heteroscedastic term | `~ tax_group \| identifierEffectSizeID`, `rho = 0` (fixed) |
| Other random terms | `~ 1 \| identifierStudyId`, `~ 1 \| taxonomySpecies` (both homoscedastic) |
| **Phylogenetic term** | **present** (`~ 1 \| species_phylo` with `R =`) — added 2026-08-05, converged first attempt |
| Estimation | `method = "REML"`, `test = "t"`, `dfs = "contain"`, `sparse = TRUE` |
| VCV | `metafor::vcalc(..., rho = 0.5)` |
| Optimiser | `nlminb`, clean fit, 0 warnings |
| Fallback candidates | none attempted — the phylogenetic HCS structure fitted first time on both scales |

Group-specific residual variances, ready to quote:

| Group | *g*: τ² (*k*) | lnOR: τ² (*k*) |
|---|---|---|
| Arthropods | 0.1273 (65) | 0.1531 (79) |
| Fish | 0.5433 (132) | 1.0423 (81) |
| Other Vertebrates | 0.4835 (30) | 0.3033 (12) |
| Between-study σ² | 0.0223 (80 studies) | **0.0000** (69 studies) |
| Species σ² | 0.0177 (31 species) | 0.1894 (29 species) |

Three things follow.

**(a) ✅ RESOLVED — the phylogenetic term is now in the model.** At audit time the taxon models omitted it while the intercept-only models had it. It was added on 2026-08-05 as the primary candidate in the fallback cascade, and **it converged at the first attempt on both scales** (`Chosen structure: Heteroscedastic + phylogeny (HCS, rho = 0)`), so no fallback was needed and no justification for dropping it is required. Its variance component is essentially zero (σ² = 0.0000, 30 and 28 species levels), consistent with the negligible phylogenetic signal reported throughout. Point estimates for all three groups were unchanged; only the df moved.

**(b) Between-study variance is exactly zero in the lnOR model.** Report it rather than let a reviewer find it. It is also consistent with what you already say in Results (study ID accounts for < 8% of heterogeneity).

**(c) Independent confirmation of E1b.** `nlvls` on `identifierStudyId` is **80** for Hedges' *g* and **69** for log odds ratio — exactly the study counts derived in E1b by a different route.

**Paired deletion (this is what makes E6 close #34):** once this is inserted, delete the first two sentences of the Results subsection *Exploratory uni-moderator analyses* — see **E19**.

## E7 · `PASTE` · line 183 — precision definition + funnel asymmetry
**Closes #17** (Ayumi) and **#46** (Christine)

Ayumi is right that the figures plot 1/SE while the Methods say inverse of sampling variance. Christine wants the asymmetry definition moved out of the caption into the main text. Both fixed here.

**FIND:**
```
First, we visually assessed the funnel plot asymmetry by examining the residuals from a meta-analytic model that included all the random factors used in our study. These residuals were plotted against the precision of the effect sizes (the inverse of sampling variance).
```

**REPLACE:**
```latex
First, we visually assessed funnel plot asymmetry---a systematic association between the magnitude of an effect size and its precision, such that low-precision studies scatter asymmetrically about the mean rather than symmetrically, which is the expected footprint of selective reporting---by examining the residuals from a meta-analytic model that included all the random factors used in our study. These residuals were plotted against the precision of the effect sizes, defined as the inverse of the standard error ($1/SE$), matching the funnel plots in \nameref{suppinfo}.
```

## E8 · `PASTE` · line 185 — two-step wording
**Closes #20** (Cassidy, Christine)

**FIND:**
```
we implement a two-step approach: 1) Fit a multilevel analogue of Egger's regression model using the standard error ($SE = \sqrt v_i$) as the precision proxy; and 2) if the slope of the standard error model was statistically significant, it indicated that the estimate is biased. In this case, we re-fit the model using the sampling variance ($V = v_i$) as the moderator to obtain a less biased estimate of the adjusted overall meta-analytic mean.
```

**REPLACE:**
```latex
we implemented a two-step approach: (1) Fit a multilevel analogue of Egger's regression using the standard error as the precision proxy, where $v_i$ is the sampling variance of the $i$th effect size and $SE_i = \sqrt{v_i}$; and (2) If the slope of that model was statistically significant---indicating a biased estimate---re-fit the model with the sampling variance ($v_i$) as the moderator, whose intercept provides the bias-adjusted overall meta-analytic mean.
```

This also defuses **#19** (Kyle reading $\sqrt{v_i}$ as the SE of a mean) by defining the symbol on first use, and satisfies **#22** (Cassidy) by capitalising after the colon-introduced numerals. Check the other colons in this section for the same treatment.

## E9 · `PASTE` · line 187 — move the small-study clause out of the time-lag paragraph
**Closes #21** (Erick, confirmed by Kyle)

**FIND:**
```
Third, we examined the possibility of time-lag bias by including publication year as a moderator in our multilevel meta-analytic model. Uni-moderator models were run for each of the inverses of the effective sample size and the publication year, and a multi-moderator model was fitted with the full model, including both the sampling variance and the publication year as moderators.
```

**REPLACE:**
```latex
Third, we examined the possibility of time-lag bias by fitting publication year as a single moderator in our multilevel meta-analytic model. We then fitted a multi-moderator model containing both the precision moderator and publication year, to test whether either pattern persisted after conditioning on the other.
```

The deleted clause described uni-moderator models on *effective sample size* — a small-study analysis sitting inside the time-lag paragraph, which is exactly Erick's point. It also described an analysis the Methods do not otherwise specify (see **E10**).

## E10 · `PASTE` · line 185 — justify keeping the SE-based moderator
**Addresses #18** (Erick) · **DECIDED: keep SE-based as currently stated — no re-run**

Erick's technical point stands: the sampling variance of Hedges' *g* and ln(OR) is partly a function of the effect-size estimate, so a regression on $\sqrt{v_i}$ can detect asymmetry that is in part artefactual, and Nakagawa et al. (2022) offer the effective sample size as the alternative. Keeping SE is defensible, but the manuscript should say *why* rather than leave the choice unexplained — otherwise a reviewer raises the same point Erick did.

**The inconsistency is already fixed by E9**, which deletes the stray "inverses of the effective sample size" clause. That clause was the only place the manuscript described an effective-*N* analysis; with it gone, the Methods, the figures, and the Supplementary Results ($\beta_{\sqrt{v_i}}$) all describe the same SE-based analysis. Nothing needs re-running.

Add this justification to the end of the Egger's paragraph (after the E8 replacement):

**INSERT:**
```latex
We used the standard error rather than the effective sample size as the precision moderator, for comparability with the two source meta-analyses and with the wider literature. We note that for standardised mean differences and log odds ratios the sampling variance is partly a function of the effect-size estimate itself, so a regression on $\sqrt{v_i}$ can register asymmetry that is in part an artefact of that dependence~\cite{nakagawaMethodsTestingPublication2022}. Because this artefact inflates rather than deflates apparent small-study effects, the resulting adjusted mean should be read as a conservative bound on the true average effect rather than as a point estimate---which is how we treat it throughout, as the more pessimistic of our two correction frameworks.
```

This is a genuinely strong position rather than a concession: the known artefact pushes the SE-based correction in the *pessimistic* direction, so the framing you already use ("the more conservative bias correction") is exactly right, and the bias-robust Yang estimator provides the counterweight. Worth saying so explicitly in the reply to Erick's thread as well.

**Knock-on effect:** E10 no longer gates anything. The earlier warning to sequence it first is void — the numeric edits (E1b, E18, Supplementary Results) are now stable and can be done in any order.

## E11 · `PASTE` · line 189 — CR2 with crossed random effects
**Closes #23** (Kyle)

⚠️ **Extended after the A1 code fix.** The FIND block now also covers the phrase describing the estimator itself, which previously described the old (incorrect) univariate implementation.

**FIND:**
```
a bias-robust weighting scheme (a fixed- or common-effects GLS estimator that is less susceptible to selective reporting) is combined with cluster-robust (CR2) variance estimation to address the non-independence of effect sizes within studies. We overlay both corrected means on an orchard plot using \lstinline{orchaRd::pub_bias_plot()}.
```

**REPLACE:** *(no new analysis — caveat only)*
```latex
a bias-robust weighting scheme is combined with cluster-robust (CR2) variance estimation. The weighting scheme is a multivariate fixed-effect GLS estimator in which the weights derive from the sampling variance--covariance matrix (assuming $\rho = 0.5$, as elsewhere); inverse-covariance weighting downweights imprecise studies reporting large effects and prevents a study contributing many correlated effect sizes from accruing weight in proportion to their number, making the resulting mean less susceptible to selective reporting than a random-effects mean. Cluster-robust variance estimation, implemented with \lstinline{clubSandwich} and clustered by study, then restores valid inference under the non-independence of effect sizes within studies. Because this first-stage model contains no random effects, the CR2 small-sample correction is applicable, which it would not be for a multilevel model with crossed random terms~\cite{yangCautionaryCrossedRandom2025}. It also follows, however, that dependence among effect sizes from the same species---crossed with, rather than nested within, study---is represented by neither the weighting nor the clustering. We therefore read the bias-robust mean as a point estimate that is robust to selective reporting but whose interval may be optimistic where species contribute effect sizes across several studies; our multilevel models, which do represent species and phylogeny explicitly, supply the complementary uncorrected and bias-corrected estimates. We overlay both corrected means on an orchard plot using \lstinline{orchaRd::pub_bias_plot()}.
```

### Kyle's concern is pre-empted by the method's own authors

Yang et al.'s tutorial carries a technical note that answers him almost verbatim:

> *"In terms of small sample size correction for CRVE, CR2 correction performs better than CR1. However, CR2 is not applicable to models with non-nested random effects, such as models with crossed random effects. **In our case, the model in the first step does not include random effects.**"*

So Kyle has correctly identified a real hazard of CR2 — the authors flag the same one — but it does not bite here, because the step-one model is fixed-effect by design. You can say this directly in the thread, citing the tutorial. ⚠️ Note this holds only once **A1** is fixed: the argument depends on step one being the intended FE + VCV model.

### Why this is the accurate answer to Kyle — and a correction to my earlier draft

I checked `fit_bias_robust` (`overall_effect.qmd:1274`) rather than assume. It does:

```r
fe <- metafor::rma(yi, vi, method = "FE", test = "t")
metafor::robust(fe, cluster = dat2$identifierStudyId, clubSandwich = TRUE)
```

So the Yang et al. estimator is a **univariate fixed-effect model with no random-effects structure at all**, given CR2 standard errors clustered on study. That matters two ways:

- **Kyle's stated concern doesn't apply as posed.** He worried that CR2 behaves badly when random effects are crossed. This model has no crossed random effects — it has no random effects. Using fixed-effect weights is the entire point of the Yang et al. approach, since FE weighting is less susceptible to selective reporting.
- **But there is a real limitation underneath it**, and it is arguably worse than the one he named: species-level dependence is handled by *nothing* in this model — not the weights, not the sandwich. That is what the replacement text above concedes.

⚠️ My earlier draft of this edit said among-species dependence "is accommodated by the random-effects structure rather than by the robust variance." That was wrong for this model, which has no random-effects structure. The text above replaces it.

⚠️ Still to resolve: `yangCautionaryCrossedRandom2025` is a placeholder for the paper Kyle linked (`10.1111/2041-210X.70156`) — look up its real authors and title before citing.

## E12 · `RUN` · line 191 — ρ sensitivity by AIC
**Addresses #24** (Kyle ×2)

Fit ρ ∈ {0.2, 0.5, 0.8}, compare AIC, then append to the leave-one-out paragraph:

```latex
We retained $\rho = 0.5$ in all main analyses for comparability with the original meta-analyses. As a sensitivity check we refitted the combined models across $\rho \in \{0.2, 0.5, 0.8\}$: pooled means shifted by at most ⟨⟨X⟩⟩ units and $\rho = 0.5$ was within ⟨⟨Y⟩⟩ AIC units of the best-supported value (\nameref{supplresults}).
```

Same reference as E11 (`10.1111/2041-210X.70156`).

## E13 · `PASTE` · line 193 — state the cross-dataset comparison explicitly
**Closes #25** (Cassidy, +1 Kyle)

**FIND:**
```
A cross-dataset validation of the two original source datasets (Hedges' \textit{g}, Davies et al.~\cite{daviesMetaanalysisFactorsInfluencing2020}; odds ratio, Jones and DuVal~\cite{jonesMechanismsSocialInfluence2019}) flagged original effect sizes from seven studies whose effect sizes disagreed by more than 0.5 Hedges' \textit{g} units.
```

**REPLACE:**
```latex
The two original meta-analyses overlap in the primary studies they included but report them on different metrics, which allows a cross-dataset validation. For every study represented in both source datasets, we compared the Hedges' \textit{g} reported by Davies et al.~\cite{daviesMetaanalysisFactorsInfluencing2020} with the \textit{g} implied by converting the odds ratio reported by Jones and DuVal~\cite{jonesMechanismsSocialInfluence2019} for the same experiment and outcome (\autoref{eq:or-to-g}). This flagged seven studies whose two values disagreed by more than 0.5 Hedges' \textit{g} units.
```

## E14 · `PASTE` · line 195 — reframe the website as a reproducibility archive
**Closes #26 #27** (Santiago ×2) and **#47** (your own note)

**FIND:**
```
All data processing, effect size calculations, model specifications, diagnostic checks, bias assessments, and full moderator outputs are provided in a fully reproducible online supplementary document available at: \url{https://esantos2ua.github.io/mate_choice_meta/}. The website includes annotated R code, complete model summaries, and figures.
```

**REPLACE:**
```latex
All data processing, effect size calculations, model specifications, diagnostic checks, bias assessments, and full moderator outputs are archived in a fully reproducible online supplement (\url{https://esantos2ua.github.io/mate_choice_meta/}; code repository \url{https://github.com/esantos2ua/mate_choice_meta}, archived at Zenodo, DOI: ⟨⟨Zenodo DOI⟩⟩). The archive includes annotated R code, the complete \lstinline{summary()} output and variance components ($\sigma^2$ for study, species, observation, and phylogeny) for every model reported here, and all figures. Every result and interpretation on which our conclusions rest is reported in the main text or in \nameref{suppinfo}; the online archive provides reproducibility, not additional inference.
```

Santiago's underlying worry (#26) is a journal-policy risk, so also do the paired audit: any sentence currently ending "reported in full in the online supplement" must have its substance in the paper. Two are in the Results subsection *Exploratory uni-moderator analyses* — handled at **E19**.

**Also add a supplementary variance-components table** (closes the rest of #27): one row per model × random effect, columns σ², partial *I*², with total *I*² and the 95% prediction interval as footer rows.

---

# PART 3 — Results

## E15 · `PASTE` · line 201 — clarify what the 13 overlapping studies mean
**Closes #28** (Christine, +1 Aleksandra ×2, +1 Anna)

**FIND:**
```
Our process yielded 13 studies ($45\%$ of the total) published up to and including 2019, overlapping with the literature search period of the original meta-analyses. Six studies ($20.7\%$ of the total) were theses.
```

**REPLACE:**
```latex
Thirteen of these 29 studies ($45\%$) were published in or before 2019 and therefore fell within the search window of the original meta-analyses, yet had not been included in them. That our multilingual, grey-literature-inclusive strategy recovered this much pre-2019 evidence---including six theses ($20.7\%$ of the total)---suggests the original searches were substantially less sensitive than their date ranges imply.
```

## E16 · `FILL` · insert after line 201 — dataset composition table
**Closes the "which are original vs. new?" half of #28** (Aleksandra: "maybe a diagram?")

Aleksandra asked for a diagram; a table is more compact and reusable. Insert a reference in the text and put the table in the Tables section.

```latex
\begin{table}[H]
\centering
\caption{\textbf{Composition of the combined datasets.} Effect-size counts after harmonisation onto both metrics; a study contributing continuous outcomes appears in both columns following conversion (\autoref{eq:or-to-g}, \autoref{eq:g-to-or}).}
\label{tab:composition}
\begin{tabular}{lrrrr}
\hline
Source & Studies & Species & Hedges' \textit{g} ES & $\ln(\mathit{OR})$ ES \\
\hline
Davies et al.~\cite{daviesMetaanalysisFactorsInfluencing2020} & 51 & 23 & 158 & --- \\
Jones and DuVal~\cite{jonesMechanismsSocialInfluence2019} & 40 & 17 & --- & 103 \\
This update (new) & 29 & 15 & 69 & 69 \\
\hline
\textbf{Combined} & \textbf{80} (\textit{g}) / \textbf{69} ($\ln \mathit{OR}$) & \textbf{33} & \textbf{227} & \textbf{172} \\
\hline
\end{tabular}
\end{table}
```

✔ Every cell is now verified against the frozen render (see **E1b**), except the per-source Species column, which is a raw string count — the 23 and 17 will not sum to 33 for the same reconciliation reason given in E1b, so either drop that column or footnote it. ⚠️ One discrepancy to resolve first: the retained extraction has **70** rows (29 studies, 15 species), but the manuscript reports **69** new effect sizes throughout and `new_extraction_species_counts.csv` also totals 69. One row is dropped downstream — the row with a blank `effectSizeHedgesDHowCalculated` is the likely candidate. Confirm which, so the number is defensible.

## E17 · `PASTE` · lines 206 & 208 — plain-English odds and benchmark caveat
**Closes #29 #30** (Erick ×2, Christine)

**FIND:**
```
Combining both datasets yielded an overall mean OR of 1.81 (95\% CI: 1.35 to 2.42; \hyperref[fig:ororchard]{Figure~\ref*{fig:ororchard}}).
```

**REPLACE:**
```latex
Combining both datasets yielded an overall mean OR of 1.81 (95\% CI: 1.34 to 2.45; \hyperref[fig:ororchard]{Figure~\ref*{fig:ororchard}}). All odds ratios are back-transformed from the log scale on which the models were fitted. Against a 50:50 chance expectation, a mean OR of 1.81 corresponds to an observer choosing the socially favoured male on 64\% of occasions; the original estimate of 2.71 corresponds to 73\%, and our new data alone (OR = 1.46) to 59\%.
```

Then, for #30 — keep the benchmarks (Christine's reason is sound) but caveat once, which answers Erick:

**FIND:**
```
which is considered a 'moderate' effect. Our new data had a mean overall Hedges' \textit{g} of 0.21 (95\% CI: -0.02 to 0.43), which is considered a 'small' effect.
```

**REPLACE:**
```latex
conventionally described as a `moderate' effect (\textit{sensu} Cohen), although such benchmarks are arbitrary and poorly calibrated to behavioural and evolutionary data~\cite{mollerHowMuchVariance2002}. Our new data had a mean overall Hedges' \textit{g} of 0.21 (95\% CI: $-0.02$ to 0.43), a `small' effect on the same scale.
```

⚠️ Add a bib entry for Møller & Jennions 2002 (*Ecology* / *Oecologia*, "How much variance can be explained by ecologists and evolutionary biologists?") or substitute Nakagawa & Cuthill 2007. Also note the LaTeX quote fix: `'moderate'` should be `` `moderate' `` to render correctly.

## E18 · `FILL` · line 210 — τ², prediction intervals, and the *I*² wording

### ✔ τ² — read off the 2026-08-05 render

In a multilevel model τ² is the **sum of the variance components**. From the combined intercept-only models:

| Component | Hedges' *g* (*k* = 227) | log OR (*k* = 172) |
|---|---|---|
| Study | 0.0374 | 0.0334 |
| Effect size (residual) | 0.3632 | 0.3543 |
| Species (non-phylogenetic) | 0.0158 | 0.1864 |
| Phylogeny | 0.0175 | 0.0083 |
| **Total τ²** | **0.4339** | **0.5824** |

### ⚠️ Prediction intervals — computed by hand, verify before use

The render does not print PIs anywhere (`orchaRd` computes them internally for the orchard plots but never exposes the numbers), so I calculated them from the published components as $b \pm t_{df}\sqrt{SE^2 + \tau^2}$:

| Scale | *b* | SE | df | 95% PI |
|---|---|---|---|---|
| Hedges' *g* | 0.4455 | 0.1035 | 29 | **−0.92 to 1.81** |
| log OR | 0.5939 | 0.1466 | 27 | **−1.00 to 2.19** (OR 0.37 to 8.92) |

Confirm with one line before these go in the manuscript — `predict()` handles the degrees of freedom itself and is authoritative:

```r
predict(res_hedges_comb$model)   # $pi.lb / $pi.ub
predict(res_or_comb$model)
```

**Both prediction intervals span zero**, which is the substantive point: the *average* effect is positive, but the expected effect in a new study ranges from clearly negative to strongly positive. That is a far cleaner statement of "conditional and context-dependent" than *I*² alone, and it is worth reusing in the Discussion (**E21**) and in the reply to Kyle.
**Closes #31** (Kyle ×2)

**FIND:**
```
Total heterogeneity across effect sizes was large in all models ($I^2 >$ 74\%; for details see \hyperref[tab:partial-i2]{Table~\ref*{tab:partial-i2}}).
```

**REPLACE:**
```latex
Heterogeneity was substantial in all models. $I^2$---the proportion of observed variance not attributable to sampling error---exceeded 74\%, and the total among-effect-size variance was $\tau^2$ = 0.43 for Hedges' \textit{g} and 0.58 for log odds ratios (for details see \hyperref[tab:partial-i2]{Table~\ref*{tab:partial-i2}}). The corresponding 95\% prediction intervals span $-0.92$ to 1.81 and $-1.00$ to 2.19 (odds ratio: 0.37 to 8.92), so although the \textit{average} effect is positive, the effect expected in a new study ranges from clearly negative to strongly positive. We report these alongside $I^2$ because $I^2$ is a proportion, and so depends on the precision of the contributing studies, whereas $\tau^2$ and the prediction interval express heterogeneity on the scale of the effect size itself.
```

In `metafor`, τ² is `sum(mod$sigma2)` and the prediction interval comes from `predict(mod)$pi.lb` / `$pi.ub`. A prediction interval spanning zero is a stronger, cleaner statement of the "conditional, context-dependent" argument than *I*² — reuse it in the Discussion (**E21**).

## E18b · `PASTE` ✔ · lines 215, 220 — "Wald $Q_M$" is actually an $F$-test
**Not raised in a comment, but surfaced while verifying E6 — and Kyle and Ayumi are exactly the readers who would catch it.**

Because every model is fitted with `test = "t"`, `metafor` reports the omnibus moderator test as an **$F$-statistic with containment degrees of freedom**, not a Wald $Q_M$ chi-square. The executed output reads `Test of Moderators (coefficients 2:3): F(df1 = 2, df2 = 28) = 3.0647, p-val = 0.0626`. The manuscript reports this as `Wald $Q_M$ = 3.06, \textit{p} = 0.06`.

This is a labelling error, not a numerical one — the values are right. It propagates because `moderator_analysis.qmd:457` extracts `res$model$QM`, which with `test = "t"` holds the $F$ value, and the prose calls it $Q_M$ throughout. Fix everywhere, with the df now available:

| Location | Current | Should be |
|---|---|---|
| Taxon, Hedges' *g* | `Wald $Q_M$ = 3.06, p = 0.06` | `$F_{2,27}$ = 3.06, \textit{p} = 0.063` |
| Taxon, log OR | `Wald $Q_M$ = 1.17, p = 0.33` | `$F_{2,25}$ = 1.17, \textit{p} = 0.327` |
| Exploratory moderators | `all Wald $Q_M$, p > 0.2` | `all omnibus $F$-tests, \textit{p} > 0.2` |
| Copying mechanism (combined *g*) | `Wald $Q_M$ = 0.003, p = 0.96` | `$F_{1,225}$ = 0.00, \textit{p} = 0.958` |
| Virginity (new extraction) | `Wald $Q_M$ = 1.61, p = 0.22` | `$F_{1,27}$ = 1.61, \textit{p} = 0.215` |
| Virginity (combined OR) | `OR = 1.75 \textit{vs.} 1.91; $p$ = 0.72` | `$F_{1,170}$ = 0.13, \textit{p} = 0.723` |

### ✔ Degrees of freedom — read off the 2026-08-05 re-render

`among_test()` had captured `QMdf` all along but nothing displayed it. After exposing it, the full set for all 10 uni-moderator fits:

| Analysis | *F* | df1 | df2 | *p* |
|---|---|---|---|---|
| Mechanism — Hedges' *g* (new) | 0.31 | 1 | 27 | 0.582 |
| Mechanism — log OR (new) | 0.30 | 1 | 27 | 0.587 |
| Modality — Hedges' *g* (new) | 0.18 | 2 | 12 | 0.839 |
| Modality — log OR (new) | 0.18 | 2 | 12 | 0.836 |
| Demonstration sub-type — Hedges' *g* (new) | 1.13 | 1 | 56 | 0.293 |
| Demonstration sub-type — log OR (new) | 1.13 | 1 | 56 | 0.293 |
| **Virginity — Hedges' *g* (new)** | **1.61** | **1** | **27** | **0.215** |
| Virginity — log OR (new) | 1.61 | 1 | 27 | 0.215 |
| **Mechanism — Hedges' *g* (new + Davies)** | **0.00** | **1** | **225** | **0.958** |
| **Virginity — log OR (new + Jones)** | **0.13** | **1** | **170** | **0.723** |

⚠️ **Note the df2 jump between new-extraction and combined models** — 27 against 225 and 170. Containment df track the level at which the moderator varies: in the new extraction these moderators vary between studies, whereas in the combined data they vary within them. Worth a glance to confirm the coding is what you intend, since a moderator varying *within* study is a materially different claim from one varying between studies.

⚠️ The manuscript's `$p$ = 0.96` for mechanism and `$p$ = 0.72` for combined virginity match at 2 s.f.; `Wald $Q_M$ = 0.003` does **not** — the *F* is 0.00 (0.0028 before rounding). Use `$F_{1,225}$ = 0.00`, or quote more decimals.

### `moderator_analysis.qmd` narrative — corrected

The $Q_M$ → $F$ relabelling has been applied throughout that file:

| Line | Change |
|---|---|
| 105 | "omnibus $Q_M$ test" → "omnibus $F$-test"; "the $Q_M$ / $I^2$ question" → "the $F$ / $I^2$ question" |
| 355 | Now states explicitly that `test = "t"` yields an $F$ with containment df, *not* a Wald chi-square |
| 455–462 | `among_test()` returns `F`, `Fp`, `df1`, `df2`; comment documents that metafor stores the $F$ in `$QM` for historical reasons |
| 527 | comment "means/Q_M" → "means/F-test" |
| 612–618 | `qm_line()` renders `$F_{df1,df2}$ = …` |
| 820–824 | helpers gain `qdf1()` / `qdf2()`; both inline sentences print the df |
| 830 | "A non-significant $Q_M$" → "A non-significant omnibus $F$" |
| 879 | table intro mentions the df |
| 892–918 | `summarise_fit()` emits `F`/`df1`/`df2`/`p`; caption explains the distinction |
| 935 | two further $Q_M$ mentions relabelled |

All 18 R chunks re-checked for balanced delimiters. The only remaining `Q_M` strings are in the explanatory comment and caption, where the contrast with the Wald statistic is the point.

## E19 · `PASTE` · lines 215 & 220 — split the taxon sentences; delete the relocated moderator text
**Closes #33** (Erick) and completes **#34** and **#32**

**FIND:**
```
to the other vertebrates---birds and mammals (\textit{g} = 0.71, 95\% CI: 0.36 to 1.07); total heterogeneity was high (94.3\%) and the among-group test approached statistical significance (Wald $Q_M$ = 3.06, \textit{p} = 0.06). On the log-odds-ratio scale the ranking significantly differed---fish were highest (log OR = 0.82, 95\% CI: 0.37 to 1.26), followed by the other vertebrates (log OR = 0.61, 95\% CI: $-0.04$ to 1.25) and arthropods (log OR = 0.33, 95\% CI: $-0.13$ to 0.80)---and total heterogeneity was high (89.5\%), with non-significant differences among groups (Wald $Q_M$ = 1.17, \textit{p} = 0.33).
```

**REPLACE:**
```latex
to the other vertebrates, \textit{i.e.} birds and mammals (\textit{g} = 0.71, 95\% CI: 0.36 to 1.07). Total heterogeneity was high (94.3\%) and the among-group test approached statistical significance ($F_{2,27}$ = 3.06, \textit{p} = 0.063). On the log-odds-ratio scale the ranking differed, with fish highest (log OR = 0.82, 95\% CI: 0.37 to 1.26), followed by the other vertebrates (log OR = 0.61, 95\% CI: $-0.04$ to 1.25) and arthropods (log OR = 0.33, 95\% CI: $-0.13$ to 0.80). Total heterogeneity was again high (89.5\%), and differences among groups were not significant ($F_{2,25}$ = 1.17, \textit{p} = 0.327). Residual variance was itself group-specific, and roughly four times larger in fish ($\tau^2$ = 0.54 for Hedges' \textit{g}, 1.04 for log odds ratios) than in arthropods (0.13 and 0.15). Because the two scales give different rankings and neither omnibus test is significant, we do not interpret the apparent gradient.
```

Note the replacement also drops "the ranking significantly differed" — as written it claims significance in the same clause that reports *p* = 0.33.

**Paired deletion for #34** — in the *Exploratory uni-moderator analyses* subsection, delete these two sentences, now in Methods via E6:
```
Beyond taxonomic group, we extracted four candidate moderators during data collection: the copying mechanism (generalized \textit{vs.} individual), the modality of the social cue (visual, chemical, or acoustic), the mating status of the observer, and the relative age of the demonstrator. These were not part of our pre-registered analyses and several of their levels are sparsely sampled, so we treat these meta-regression models as exploratory and report them in full in the online supplement. The relative age of the demonstrator showed no variation in our extraction (all ``same-age'') and could not be analyzed. The remaining three moderators were fitted as single-moderator multilevel models on the new extraction (both scales) and, where the coding could be harmonized with an original dataset, on the combined data.
```
Replace with: `No moderator explained a detectable share of the heterogeneity on either scale (all Wald $Q_M$, $p > 0.2$; total $I^2$ remained above 80\%).` and let the paragraph continue as written. Then change the closing sentence's "provided in the online supplement" to point at `\nameref{suppinfo}` (part of the E14 audit).

---

# PART 4 — Discussion

## E20 · `PASTE` · line 230 — Discussion opener: scope, then "real"
**Closes #35 #36** (Kyle, Christine)

**FIND:**
```
By updating the datasets from the two original meta-analyses and reanalysing them within a unified, phylogenetically-informed multilevel framework, we can now answer the two questions we set out with. First, the qualitative conclusion of both foundational syntheses persists:
```

**REPLACE:**
```latex
By updating the datasets from the two original meta-analyses and reanalysing them within a unified, phylogenetically-informed multilevel framework---227 Hedges' \textit{g} effect sizes from 80 studies and 172 log odds ratios from 69 studies, spanning 33 species---we can now answer the two questions we set out with. First, the qualitative conclusion of both foundational syntheses persists:
```

And for Christine's objection to "real" (#36):

**FIND:**
```
mate choice copying is therefore real, but more modest and more context-dependent than \textcite{jonesMechanismsSocialInfluence2019} and \textcite{daviesMetaanalysisFactorsInfluencing2020} implied
```

**REPLACE:**
```latex
Mate choice copying therefore occurs across a broad range of taxa, but is more modest and more context-dependent than \textcite{jonesMechanismsSocialInfluence2019} and \textcite{daviesMetaanalysisFactorsInfluencing2020} implied
```

Note the capital M — the sentence currently begins with a lowercase "mate". Same problem at the §4.1 heading and at the start of the Conclusion (**E25**).

## E21 · `PASTE` ✔ · insert after line 237 — species and methodological heterogeneity
**Closes #37** (Kyle, +Christine on the species half)

Covers all three of Kyle's asks — species-level variation, methodological heterogeneity, and the comparison with the re-extracted studies — in **three paragraphs, ~330 words**, down from ~600 in the first draft. Every figure verified against the 2026-08-05 render and `outputs/3_original_dataset_crosscheck/`. Insert in §4.1 after the paragraph ending `...an interpretation consistent with the negligible phylogenetic signal we recovered.`

**INSERT:**
```latex
Where that heterogeneity sits differs between the two scales. Species identity absorbed 23.9\% of it on the log odds ratio scale but only 3.1\% on the Hedges' \textit{g} scale, while phylogeny absorbed almost none on either ($\leq 3.5\%$; \hyperref[tab:partial-i2]{Table~\ref*{tab:partial-i2}}). That difference reflects dataset composition rather than biology: species accounted for 29\% of the heterogeneity in our new extraction and 45.6\% in the binary data of Jones and DuVal~\cite{jonesMechanismsSocialInfluence2019}, but for none at all in the continuous data of Davies et al.~\cite{daviesMetaanalysisFactorsInfluencing2020}. Two readings follow. Where species variance is detectable it is not organised by relatedness, which points to mating system, ecology, and assay tradition rather than to lineage-specific cognition. But because \textit{Drosophila} and \textit{Poecilia} supply two-thirds of all effect sizes, ``among-species'' variance is partly variance among the few laboratories that study them; with the taxonomic gradient reversing between scales and neither omnibus test significant, we do not treat it as established.

Much of the remaining variance lies in design features our coding could not capture: before-and-after \textit{versus} no-pretest designs, association time \textit{versus} copulation, live \textit{versus} video demonstrators, and---for 22 of the 38 binary effect sizes---whether a control group existed at all or a chance expectation stood in for one. These axes plausibly generate more variance than the biological moderators we tested, which would explain why none of the latter absorbed a detectable share.

Variation also enters through extraction itself. The two source syntheses report overlapping studies on different metrics, and for seven of them the values disagreed by more than 0.5 Hedges' \textit{g} units. Re-extraction from the primary sources resolved every one toward the odds ratios of Jones and DuVal: the continuous extraction had variously captured a different construct (association time, body size), doubled paired sample sizes, produced artifacts of degenerate $2\times2$ tables, and in one case reversed the sign, turning a reported absence of copying into apparent evidence for it. The binary extraction had its own faults, over-counting effect sizes in two studies. Our estimates are robust to how these values are handled (\nameref{supplresults}), but the episode matters: much of what reads as biological disagreement between the two syntheses was extraction disagreement---an argument for cross-validating source data whenever meta-analyses are combined.
```

### What was cut, and why it is safe to cut

| Dropped | Where it survives |
|---|---|
| Fourth paragraph ("We draw a broader lesson…") | Its one load-bearing clause is now the closing sentence of ¶3; the cross-validation argument also appears in **E23** |
| Per-study naming (Applebaum, Briggs, Howard, Gierszewski, Fowler-Finn) | `reextraction_flagged_studies.md`, already citable as supplementary material |
| $2+\sqrt{3} = 3.732$; the structural zero cell | ibid. — vivid, but detail a reader does not need to follow the argument |
| "$N = 40$ where 20 were tested" spelled out for both Dugatkin papers | compressed to "doubled paired sample sizes" |
| Fowler-Finn pool-vs-split as a separate sentence | dropped; it is the one disagreement that was *not* an error, so it weakens rather than strengthens the paragraph |
| Explicit 71.7% / 45.4% residual figures | now in the Results correction below, where they belong |

Naming colleagues' extraction errors in a Discussion reads as an attack, and the supplement carries the detail. If you would rather name them: construct errors = Applebaum & Cruz 2000, Briggs et al. 1996, Howard et al. 1998; artifacts = Dugatkin 1992, Gierszewski et al. 2018; sign error = Howard et al. 1998; over-counting = Dugatkin 1992, Gierszewski et al. 2018.

### Provenance

| Claim | Source |
|---|---|
| 23.9 / 3.1 / ≤3.5% partial *I*² | `tab:partial-i2`, reproduced exactly from post-render variance components ✔ |
| Species 29% (new), 45.6% (Jones), 0.0% (Davies) | same table, "New Only" / "Original Only" rows |
| 22 of 38 binary effect sizes | extraction spreadsheet ✔ (**E4**) |
| Seven studies, all resolving toward Jones & DuVal; the four error classes | `outputs/3_original_dataset_crosscheck/reextraction_flagged_studies.md` |

### 🔴 Related correction to the Results

Writing this exposed an inaccuracy in the heterogeneity paragraph, which currently reads:

> "study ID ... accounted for less than 8\% across models, whereas observation ID ... and species ID ... accounted for most of the heterogeneity."

True for log OR (45.4% + 23.9%), false for Hedges' *g*, where species is **3.1%** and the effect-size level alone is 71.7%.

**FIND:**
```
whereas observation ID (representing the within-study effect) and species ID (representing the non-phylogenetic effect) accounted for most of the heterogeneity.
```

**REPLACE:**
```latex
whereas observation ID (representing the within-study effect) accounted for most of the heterogeneity on both scales (71.7\% for Hedges' \textit{g}, 45.4\% for log odds ratios). Species ID (the non-phylogenetic species effect) contributed substantially on the log odds ratio scale (23.9\%) but little on the Hedges' \textit{g} scale (3.1\%).
```

## E22 · `WRITE` · line 239 — generalized vs. individual copying
**Closes #38** (Iwo — the most detailed comment in the set)

Iwo's diagnosis is precise: the paragraph slides between a *conceptual* distinction (a transmissible preference for a phenotype vs. a preference for one individual) and an *experimental-design* distinction (different targets sharing a trait vs. the same targets), and as written it reads as though individual-design studies are less rigorous. Rewrite the middle of the paragraph:

**FIND:**
```
individual copying, by contrast, ends with the demonstrated male. The evolutionary reading of mate choice copying therefore rests on the generalized, transmissible form being robustly expressed, and our data support that premise: generalized copying was statistically indistinguishable from individual copying, and if anything, marginally stronger in the new extraction.
```

**REPLACE:**
```latex
a preference attached to one individual, by contrast, ends with the demonstrated male. It is worth separating this evolutionary distinction from the experimental one it is inferred from. Our moderator codes the \textit{design} of a trial, not the psychology of the observer: generalized designs present observers with different target individuals sharing a trait, whereas individual designs re-present the same targets. The two are not equally informative about the evolutionary question---an individual design cannot distinguish a preference generalised to the trait from one attached to the specific individual, or from other latent cues correlated with it---but neither is the more rigorous test, and individual designs are often the only feasible option for a given system. Our data are therefore consistent with, rather than a direct test of, the generalized form being robustly expressed: copying strength was statistically indistinguishable between the two designs and, if anything, marginally stronger under generalized designs in the new extraction. A design that manipulates the target trait explicitly and pre-registers the generalisation test is what would settle the question, and we regard this as a high priority for future work.
```

The closing sentence of the paragraph (`This makes a mechanism-explicit, pre-registered test...`) is now redundant — delete it.

## E23 · `WRITE` · insert before line 244 — limitations
**Closes #39** (Kyle: "do you have anywhere the limitations of the study?")

Cheapest structural fix: rename the subsection and open it with a limitations paragraph.

**FIND:** `\subsection{Knowledge gaps and future opportunities}`
**REPLACE:** `\subsection{Limitations, knowledge gaps, and future opportunities}`

Then insert this paragraph immediately after the heading, before `Three features of the evidence base...`:

```latex
Several features of our approach constrain the strength of these inferences. Because the two source meta-analyses reported different metrics, placing all studies on a common scale required approximate conversions that assume an underlying logistic distribution: in our new extraction alone, 38 Hedges' \textit{g} values were converted from odds ratios and 31 log odds ratios from Hedges' \textit{g}. Twenty-two of 38 binary effect sizes had no separate control group and relied on an equal-allocation chance expectation, which likely understates their sampling variance. Much of our effect-size data was extracted from published figures; the agreement between our extraction routine and \lstinline{metaDigitise} on a validation subset was close (mean signed \textit{z}-score $= -0.10$), but figure extraction remains a source of error. Several moderator levels were sparsely sampled and none of the biological moderator analyses was pre-registered, so those results are exploratory. Our bias-robust estimate uses common-effect weights with cluster-robust standard errors on study, and so does not represent dependence among effect sizes from the same species; its interval is correspondingly likely to be narrow. Finally, although every species was placed directly by the Open Tree of Life, the phylogeny required randomly resolved polytomies and computed rather than estimated branch lengths, both of which reduce the resolution available to the phylogenetic random effect---though that effect explained little heterogeneity in any case.
```

✔ All counts here are verified: 38 / 31 conversions and 22-of-38 imputed controls against the extraction spreadsheet, zero grafted tips against the saved trees (**E5**).

## E24 · `RUN` · line 246 — tie taxonomic gaps to heterogeneity, add marginalised means
**Addresses #40** (Kyle)

**FIND:**
```
Reassuringly, the uni-moderator analyses returned positive means in all three taxonomic groups on both scales, with only weak support for among-group differences, so we treat the apparent gradient cautiously.
```

**REPLACE:**
```latex
That species identity accounted for a large share of the heterogeneity while phylogeny accounted for almost none indicates that biologically important variation lies among species but is not predicted by relatedness---precisely the situation in which a sample concentrated in two genera is least informative, and in which broader taxonomic coverage would be most valuable. Reassuringly, the uni-moderator analyses returned positive means in all three taxonomic groups on both scales, with only weak support for among-group differences, so we treat the apparent gradient cautiously. To gauge how far the pooled estimate reflects this uneven sampling, we also computed a mean marginalised over taxonomic groups, weighting groups rather than effect sizes equally: this gave ⟨⟨g_marg⟩⟩ on the Hedges' \textit{g} scale and ⟨⟨or_marg⟩⟩ on the odds ratio scale, compared with 0.45 and 1.81 in the observed sample~\cite{⟨⟨Kyle's two examples⟩⟩}.
```

`orchaRd::marginalised_means()` (⚠️ confirm the exact function name in v2.2.0). Expect the marginalised mean to sit somewhat *higher* than the raw mean given the arthropod-heavy sample — a useful, honest counterweight to the bias-corrected results. Kyle's two examples: `10.1016/j.anbehav.2026.123542` and `10.1111/ele.14083` (Pottier et al., *Ecology Letters*).

## E25 · `PASTE` · line 251 — Conclusion wording
**Closes #41** (Christine) and **#42** (Iwo)

**FIND:**
```
mate choice copying is a real and taxonomically widespread behaviour: after incorporating
```

**REPLACE:**
```latex
Mate choice copying is a quantifiable and taxonomically widespread behaviour: after incorporating
```

**FIND:**
```
At the same time, the updated picture is more sober than the original meta-analyses suggested.
```

**REPLACE:**
```latex
At the same time, the updated picture is more tempered than the original meta-analyses suggested.
```

---

# PART 5 — Back matter

## E26 · `WRITE` · line 332 — Acknowledgements
**Closes #45** (your own note)

**FIND:** `Shoutout to all my friends.`

**REPLACE:**
```latex
We thank ⟨⟨anyone who assisted with translation, screening, or data checking but is not an author⟩⟩. We are grateful to Davies et al. and to Jones and DuVal for making the data from their meta-analyses openly available, without which this update would not have been possible, and to the Open Tree of Life project and its contributors.
```

The thanks to the two source teams is worth doing explicitly — you rebuilt your synthesis on their data and, in places, correct it.

## E27 · `WRITE` · line 340 — Author contributions
**Closes #44** (your note + Anna on the initials clash)

Only three of 17 authors currently have statements. Combined with **E2**, use MeRIT initials in the Methods plus a CRediT list here. Template:

```latex
Author contributions follow CRediT and are reported alongside in-line MeRIT initials in the Methods. \textbf{Eduardo S.~A. Santos (ESAS)}: conceptualisation, data curation, formal analysis, investigation, methodology, project administration, software, visualisation, writing---original draft, and writing---review and editing. \textbf{Aleksandra Milenovic (AMilenovic)}: ⟨⟨⟩⟩. \textbf{Aneta ⟨⟨surname⟩⟩ (A⟨⟨⟩⟩)}: ⟨⟨⟩⟩. \textbf{Anna Lenz (AL)}: ⟨⟨⟩⟩. \textbf{Ayumi Mizuno (AMizuno)}: ⟨⟨⟩⟩. \textbf{Cassidy Schneider (CSchneider)}: ⟨⟨⟩⟩. \textbf{Christine Sosiak (CSosiak)}: ⟨⟨⟩⟩. \textbf{Erick ⟨⟨surname⟩⟩}: ⟨⟨⟩⟩. \textbf{Hao Qin (HQ)}: ⟨⟨⟩⟩. \textbf{Iwo Gross (IG)}: ⟨⟨⟩⟩. \textbf{Jimuel ⟨⟨surname⟩⟩}: ⟨⟨⟩⟩. \textbf{Kyle ⟨⟨surname⟩⟩}: ⟨⟨⟩⟩. \textbf{Mahi Zakir (MZ)}: ⟨⟨⟩⟩. \textbf{Marija ⟨⟨surname⟩⟩}: ⟨⟨⟩⟩. \textbf{Santiago Ortega (SO)}: ⟨⟨⟩⟩. \textbf{Sergio ⟨⟨surname⟩⟩}: ⟨⟨⟩⟩. \textbf{Malgorzata Lagisz (ML)}: conceptualisation, investigation, methodology, and writing---review and editing. \textbf{Shinichi Nakagawa (SN)}: conceptualisation, funding acquisition, investigation, methodology, and writing---review and editing.
```

Initial clashes to watch beyond Anna's point: **CS** (Cassidy Schneider / Christine Sosiak) and **SN**/**SO**/**S**ergio. Circulate the template and have people fill their own row.

## E28 · `PASTE` · lines 483 and 492 — trim the funnel captions
**Completes #46** (Christine)

Once **E7** puts the definition in the Methods, delete this sentence from *both* funnel-plot captions (Hedges' g and odds ratio — identical text in each):

**FIND (delete, in both captions):**
```
Asymmetry here, the shortage of small, imprecise studies on one side of the funnel, is the classic visual signature of small-study and publication bias.
```

**REPLACE:**
```latex
Asymmetry here (defined in Methods) is the classic visual signature of small-study and publication bias.
```

## E29 · no action — resolve the thread
**#43** — Kyle: *"I love the presentation of this with the different bias corrected estimates."* Close it.

---

# PART 6 — Housekeeping not raised in comments

Spotted while reading; all `PASTE`-grade.

| # | Location | Fix |
|---|---|---|
| H1 | `\author{}` block, lines 10, 15, 18, 19, 21, 23 | Six authors still have first-name-only entries and/or `\orcidlink{your-orcid-here}` (Aneta, Erick, Jimuel, Kyle, Marija, Sergio). |
| H2 | line 143 | `the two original meta-analysis did` → `meta-analyses did` (already folded into **E4**). |
| H3 | throughout | Davies et al. is cited as Hedges' *d* in some places and *g* in others. State once that their *d* is treated as *g*, then use one symbol. |
| H4 | line 225 | `$≤0.07$` uses a Unicode ≤ inside math mode → `$\leq 0.07$`. |
| H5 | line 89 | `mean signed \textit{z}-score $= −0.10$` uses a Unicode minus inside math → `$= -0.10$`. |
| H6 | lines 87, 208 | Curly quotes `‘mate choice.’` and `'moderate'` → LaTeX `` `mate choice.' `` / `` `moderate' ``. |
| H7 | §4.1 heading, line 233 | `\subsection{mate choice copying as social learning...}` → capital M. |
| H8 | Results, lines 215/220 | "Wald $Q_M$" is an $F$-test throughout — see **E18b**. |

---

# Tracking table

All 47 unresolved comment IDs → edit → status. IDs match `unresolved_comments_plan_2026-07-31.md`.

| ID | Commenter(s) | Edit | Status |
|---|---|---|---|
| 1 | Aleksandra, Anna | E1 + E1b | `PASTE` ✔ |
| 2 | Anna | E1 + E1b | `PASTE` ✔ |
| 3 | Kyle | E1 | `PASTE` |
| 4 | Erick | E1 | `PASTE` |
| 5 | Santiago, Christine | E1 | `PASTE` |
| 6 | Santiago | E1 | `PASTE` |
| 7 | Anna | E2 | `PASTE` |
| 8 | Santiago | E3 | `WRITE` |
| 9 | Ayumi | E3 | `WRITE` |
| 10 | Ayumi | E3 | `WRITE` |
| 11 | Erick | E4 + E4b | `RUN` |
| 12 | Ayumi | E4 | `FILL` |
| 13 | Iwo | E5 | `PASTE` ✔ |
| 14 | Ayumi | E6 | `WRITE` |
| 15 | Kyle ×3 | E6 | `WRITE` |
| 16 | Kyle | E6 + E18 | `WRITE` |
| 17 | Ayumi | E7 | `PASTE` |
| 18 | Erick | E10 | `PASTE` ✔ |
| 19 | Kyle | E8 | `PASTE` |
| 20 | Cassidy, Christine | E8 | `PASTE` |
| 21 | Erick, Kyle | E9 | `PASTE` |
| 22 | Cassidy | E8 | `PASTE` |
| 23 | Kyle | E11 | `PASTE` |
| 24 | Kyle ×2 | E12 | `RUN` |
| 25 | Cassidy, Kyle | E13 | `PASTE` |
| 26 | Santiago | E14 | `PASTE` |
| 27 | Santiago | E14 | `PASTE` |
| 28 | Christine, Aleksandra ×2, Anna | E15 + E16 | `FILL` |
| 29 | Erick | E17 | `PASTE` |
| 30 | Erick, Christine | E17 | `PASTE` |
| 31 | Kyle ×2 | E18 | `FILL` |
| 32 | Erick | E6 + E19 | `WRITE` |
| 33 | Erick | E19 | `PASTE` |
| 34 | Erick, Iwo | E6 + E19 | `WRITE` |
| 35 | Kyle | E20 | `PASTE` ✔ |
| 36 | Christine | E20 | `PASTE` |
| 37 | Kyle, Christine | E21 | `WRITE` |
| 38 | Iwo | E22 | `WRITE` |
| 39 | Kyle | E23 | `WRITE` |
| 40 | Kyle | E24 | `RUN` |
| 41 | Christine | E25 | `PASTE` |
| 42 | Iwo | E25 | `PASTE` |
| 43 | Kyle | E29 | none |
| 44 | Eduardo, Anna | E2 + E27 | `WRITE` |
| 45 | Eduardo | E26 | `WRITE` |
| 46 | Christine | E7 + E28 | `PASTE` |
| 47 | Eduardo | E14 | `FILL` |

## Suggested sequence

0. **Settle A1 first.** The Yang step-one fix is the only outstanding item that can move a headline number. Everything in Part 4 (Discussion) and the abstract's bias-correction sentence depends on it.

1. **One sitting, no lookups** — every `PASTE` edit plus Part 6: E1, E2, E5, E7, E8, E9, E10, E11, E13, E14, E15, E17, E18b, E19, E20, E25, E28, E29, H1–H8. That closes 26 comments, including the whole abstract.
2. **One R session** — E4, E12 (τ² and prediction intervals), E16 need numbers from the fitted objects. Closes another 4.
3. **Restructuring, no new analysis** — E3, E6, E27. E6 needs one decision from you: why the taxon models drop the phylogenetic term.
4. **New analyses** — E4b (refit without imputed controls), E12 (ρ sensitivity), E24 (marginalised means). Nothing here gates anything else, now that E10 is settled as SE-based and E11 is caveat-only.
5. **New Discussion prose last** — E21, E22, E23, E26.
