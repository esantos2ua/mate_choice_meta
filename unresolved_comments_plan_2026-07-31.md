# How to address the 47 unresolved Overleaf comments

Source: `main (7).tex` + `overleaf_comments_..._2026-07-31.json` (174 threads total, 127 resolved, **47 unresolved**).
Anchors in this export are reliable — `fragment` and `context` line up with the current file, so every comment below is located by exact text.

**Marker key** (note: this is *priority/effort*, and differs from the anchor-confidence key used in `comment_revision_guide.md`):
🟢 valid comment, uncontroversial fix, draft text supplied · 🟢🟢 valid but substantive — needs new analysis, new writing, or a structural change · 🟡 arguable — a judgement call rather than a fix.

For a copy-paste edit sheet ordered by line number, see `unresolved_comments_EDITS_2026-07-31.md`.

Numbers marked ✔ were verified against the repo (`data/`, `data/2_phylogeny/*_species_counts.csv`, extraction spreadsheet) while writing this. Numbers marked ⚠️ need you to pull them from the model objects.

---

## The five substantive asks (everything else is local wording)

1. **Make the old-vs-new accounting explicit and numeric**, in the abstract, in Results, and ideally as a table or a PRISMA-for-updates diagram. Five people independently asked for this (#1, #2, #28, #35). It is the single highest-value edit.
2. **Resolve the tension between "the conclusion survives" and "the bias-corrected mean is ≤ 0"** — currently the abstract, Results and Conclusion each strike a slightly different balance (#4, #6, #41).
3. **Complete the Methods**: the moderator models, the heteroscedastic model, REML/test statistic, τ², and the equal-allocation assumption are all used in Results but never specified (#8, #11, #12, #14, #15, #16, #32, #34).
4. **Fix one real internal inconsistency**: eligibility criterion 6 says "individual, discrete choices" but PECOS and the data include continuous association-time outcomes (#8, #10).
5. **Add a limitations paragraph and a species-level/methodological heterogeneity discussion** (#39, #37, #40).

---

## Abstract

### #1 · How many studies/effects originally, how many now? 🟢
*Aleksandra + Anna, on "we added 69 new effect sizes from 29 studies"*

### #2 · Add the total effect sizes 🟢
*Anna, on "combined evidence" — she even drafted the sentence*

### #3 · Briefly define "small-study effects" 🟢 *(Kyle)*

### #4 · Explain the conservative bias correction more thoroughly 🟢 *(Erick)*

### #5 · "Leave-one-out"/"leave-one-species-out" unclear to non-meta-analysts 🟢 *(Santiago + Christine)*

### #6 · Tension between "conclusion survives" and "adjusted mean ≤ 0" 🟢 *(Santiago)*

**All six are one rewrite.** Replace the second half of the abstract with something like:

> Using a comprehensive, multilingual, and grey-literature-inclusive search across seven languages, we added 69 new effect sizes from 29 studies (15 species) to the original datasets, harmonizing the two source metrics (odds ratio and Hedges' standardized mean difference) onto common scales. The combined evidence comprises **227 Hedges' *g* effect sizes from 80 studies and 172 log odds ratio effect sizes from 69 studies, across 33 species** ⚠️(study counts to confirm; ✔ effect-size counts and species count confirmed). We re-analyzed it with phylogenetically-informed multilevel meta-analytic models and a battery of publication bias assessments and sensitivity analyses. The overall effect of social information remained positive and statistically significant on both scales but was appreciably smaller than the original estimates (Hedges' *g* = 0.44, 95% CI 0.24 to 0.65, *vs.* 0.58 originally; OR = 1.81, 1.35 to 2.42, *vs.* 2.71). Considered on its own, the new evidence was roughly half that magnitude. Heterogeneity was high and accumulated mainly within studies and among species rather than between studies or across the phylogeny, which showed little signal. We detected strong small-study effects on both scales — **smaller, less precise studies reported systematically larger effects, the expected signature of selective reporting** — and a partial decline in effect size over time for the binary outcomes. **How much this matters depends on the correction applied: a bias-robust estimator retained a positive but reduced mean, whereas a more conservative regression-based correction drew the adjusted mean to approximately zero, and below zero for Hedges' *g*.** The unadjusted pooled estimates were nonetheless **insensitive to the removal of any single study or species, and to alternative treatment of the effect sizes that disagreed between the two source datasets.** **The qualitative conclusion that animals copy the mate choices of others therefore remains supported by the unadjusted evidence, but the magnitude — and, under conservative bias correction, even the presence — of a positive average effect is less certain than the original syntheses implied.** The effect is also highly heterogeneous, a pattern itself consistent with theory predicting that copying is a conditional, strategic use of social information.

That single paragraph closes #1–#6. Note it deliberately drops "survives" (#6) and spells out the two corrections (#4) rather than burying them in one clause.

---

## Methods — reporting and framing

### #7 · "We are using MeRIT" 🟢 *(Anna, on "We preregistered")*

MeRIT (Method Reporting with Initials for Transparency; Nakagawa et al. 2023, *Nat Commun*) is a contributorship convention, not a reporting checklist, so it complements rather than replaces PRISMA-EcoEvo. Two actions:

- Add to the opening Methods paragraph: *"We report author contributions to each methodological step using MeRIT (Method Reporting with Initials for Transparency;~\cite{...}), giving author initials in-line throughout the Methods."*
- Then actually carry initials through every step. You already do this in three places (language screening, `AMizuno for Japanese, ML for Polish…`; `Data were primarily extracted by ESAS, with 10\% checked by ML`); the gaps are screening, effect-size calculation, phylogeny assembly, model fitting, and figure production. **This also resolves #44.**

### #8 · Merge PECOS and Eligibility criteria; fix the discrete-vs-continuous contradiction 🟢🟢 *(Santiago)*
### #9 · PECOS says "sexually mature" but eligibility criteria don't 🟢 *(Ayumi)*
### #10 · Criterion contradicts inclusion of association/preference-zone time 🟢 *(Ayumi)*

Three comments, one fix. Delete `\subsection{Eligibility criteria}` as a separate section and fold its content into the PECOS block, so each criterion appears exactly once:

- **Population** — keep "sexually mature", which then covers #9. Add "except where the study explicitly manipulated sexual maturity/experience".
- **Outcome** — this is where #10 lives. The current criterion *"studies had to report individual, discrete choices"* is simply wrong given the dataset (✔ 22 of the 70 extracted rows are mean-difference data on continuous outcomes). Replace with: *"studies had to report, for each focal individual, either a discrete mate choice or a continuous measure of mate preference (e.g., association or preference-zone time)."*
- After the five PECOS headings, add a short paragraph headed *"Additional restrictions"* holding only what PECOS does not cover: eligible languages (the seven), and the minimum statistical information required for effect-size calculation (means + SD/SE + *n*, count data, or a convertible test statistic — noting that *F*, χ² and GLMM outputs were not convertible and were excluded).

This removes the "which list is definitive?" problem Santiago raised and shortens the Methods.

---

## Methods — effect sizes

### #11 · Was the no-control-group assumption flagged / excluded? 🟢🟢 *(Erick)*
### #12 · How many effect sizes needed it? Odd totals? Zero cells? 🟢🟢 *(Ayumi)*

The strongest response is numbers plus a sensitivity analysis, and the numbers are already in the extraction sheet:

- ✔ **22 of the 38 count-data effect sizes (11 of 17 binary-outcome studies)** had no separate control group and used *C* = *D* = *n*/2.
- ✔ **9 of those had odd totals**, giving half-integer cell counts (e.g. *C* = *D* = 7.5 for *n* = 15) — the log-odds and its delta-method variance are both well defined for non-integer cells, so no rounding was applied.
- ✔ **No cell was zero** in any 2×2 table, so no continuity correction was needed.

Suggested replacement for the last sentence of the odds-ratio subsection:

> When no separate control group existed, we used the null expectation that individuals chose each option with equal probability, setting $C = D = n/2$, as both original meta-analyses did. This applied to 22 of the 38 binary effect sizes (11 of 17 studies). Where $n$ was odd, the resulting half-integer cell counts were retained rather than rounded, as $\ln(OR)$ and its delta-method variance are defined for non-integer counts. No 2×2 table contained a zero cell, so no continuity correction was required. Because the equal-allocation assumption treats a within-subject or chance-expectation comparison as if it were an independent control group — and therefore likely understates sampling variance — we flagged these effect sizes and refitted the binary model with them excluded (see \nameref{supplresults}).

That sensitivity refit is a small addition to the pipeline and directly answers Erick's "exclusion?".

### Also worth checking while you are here
✔ The retained extraction has **70** rows (29 studies, 15 species) but the manuscript reports **69** new effect sizes throughout, and `new_extraction_species_counts.csv` also totals 69. One row is being dropped downstream (the row with a blank `effectSizeHedgesDHowCalculated` is the likely candidate). Reconcile so the number is defensible.

---

## Methods — phylogeny

### #13 · `(n=X species?)` TODO 🟢 *(Iwo — flagged to make it visible)*

`scripts/2_phylogeny/build_phylogeny.R` already messages "Grafted (no Open Tree of Life tip; placed near a congener)" and `reconcile_augment()` returns `$augmented`, so re-run it and read the count off. The README also notes a with/without-graft sensitivity check is available — report that too: *"Any species that the Open Tree could not place was grafted next to a congener (n = N species); pooled estimates were unchanged when grafted tips were excluded (\nameref{supplresults})."*

---

## Methods — models

### #14 · Moderator and heteroscedastic model specifications are missing 🟢🟢 *(Ayumi)*
### #15 · Provide stats notation; was REML used? was a *t*-distribution assumed? 🟢 *(Kyle, 3 comments)*
### #16 · Did you also report τ²? 🟢 *(Kyle)*
### #32 · Uni-moderator analyses never appear in the Methods 🟢 *(Erick)*
### #34 · Move the moderator descriptions from Results to Methods 🟢 *(Erick + Iwo)*

These five collapse into **one new Methods subsection**, which also lets you delete the first two sentences of the "Exploratory uni-moderator analyses" Results subsection (#34). Draft:

> **Model specification.** All models were fitted by restricted maximum likelihood (REML), and inference on fixed effects used *t*-distributed test statistics with the Knapp–Hartung adjustment (`test = "t"` in `rma.mv`), which is preferable to *z*-based inference at the moderate number of clusters available here. For each model we report the variance component of every random effect (σ²) alongside total and partial *I*², and 95% prediction intervals for the overall mean, since *I*² alone describes the *proportion* of observed variance not attributable to sampling error rather than its absolute magnitude \[cite Borenstein et al. 2017, *Res Synth Methods*; IntHout et al. 2016, *BMJ Open*].
>
> **Moderator models.** We fitted taxonomic group (arthropods, fish, other vertebrates) as a single moderator on each combined dataset, retaining the full random-effects and phylogenetic structure of the intercept-only models. Because effect-size variance differed among taxonomic groups, the taxon models were fitted with group-specific variance components (a heteroscedastic structure, `struct = "DIAG"` ⚠️confirm against script). We report the omnibus Wald *Q*_M test for among-group differences, together with group-specific marginalized means and all pairwise contrasts obtained with `orchaRd::mod_results()`. Four further moderators extracted during data collection — copying mechanism (generalized *vs.* individual), social-cue modality (visual, chemical, acoustic), observer mating status, and relative demonstrator age — were not pre-registered and several of their levels are sparsely sampled; we therefore fitted them as single-moderator models and treat them as exploratory throughout.

On Erick's second point in #32 (Wald *Q* *vs.* contrasts relative to the intercept): report both. The omnibus *Q*_M answers "do groups differ at all", the marginalized means and pairwise contrasts answer "which differ" without the arbitrary reference level. `orchaRd` gives you both cheaply.

---

## Methods — publication bias

### #17 · Figures show SE, methods say inverse of sampling variance 🟢 *(Ayumi)*

Real inconsistency: the funnel-plot captions say precision = 1/SE, the methods say "the inverse of sampling variance". Change the methods to *"plotted against precision, defined as the inverse of the standard error (1/SE)"* to match the figures.

### #18 · Nakagawa recommends effective *N*, not variance or SE 🟢🟢 *(Erick)*

Erick is right, and this is the most technically consequential comment in the section. Because the sampling variance of Hedges' *g* and of ln(OR) is itself a function of the effect-size estimate, using √*v*ᵢ as the Egger's moderator induces an artefactual slope; Nakagawa et al. (2022) recommend the effective sample size instead. Note that your own text already says this two paragraphs later ("Uni-moderator models were run for each of the inverses of the effective sample size…"), so the Methods currently describe two different analyses.

Recommendation: standardise on the effective-sample-size formulation throughout — √(1/*ñ*) as the moderator for the Egger's-analogue test and 1/*ñ* for the bias-corrected intercept, with *ñ* defined explicitly for two-group designs ⚠️(check the exact definition and exponent against Table 2 of Nakagawa et al. 2022 before writing it in) — then re-run and update Figures, captions, and the Results sentence. If the SE-based version is kept for continuity with the original meta-analyses, present the effective-*N* version as the primary analysis and the SE version in the supplement.

### #19 · SD/√n *vs.* √v 🟡 *(Kyle)*

Kyle appears to be reading $SE=\sqrt{v_i}$ as the SE of a mean rather than of an effect size, where it is correct. Cheap defusal: define the symbol on first use — *"where $v_i$ is the sampling variance of the *i*th effect size, so that $SE_i=\sqrt{v_i}$"* — and reply in the thread. Becomes moot if you adopt #18.

### #20 · Rephrase step 2 so it reads as a step 🟢 *(Cassidy + Christine)*

> …we implemented a two-step approach: (1) fit a multilevel analogue of Egger's regression using [precision proxy] as the moderator; and (2) if the slope was statistically significant — indicating a biased estimate — re-fit the model using [the variance-scale moderator] to obtain a bias-adjusted overall mean.

Christine's addition (fold the second sentence into the first) is what the em-dash does here.

### #21 · This is small-study bias, not time-lag bias 🟢 *(Erick, confirmed by Kyle)*

The "Third, we examined… time-lag bias" paragraph ends by describing uni-moderator models on *effective sample size* — a small-study analysis sitting in the time-lag paragraph. Move that clause up into the Egger's paragraph and leave the time-lag paragraph with publication year plus the two-moderator model:

> Third, we examined time-lag bias by fitting publication year as a moderator. We also fitted a multi-moderator model containing both the precision moderator and publication year, to test whether either pattern persisted after conditioning on the other.

### #22 · Capitalise after a colon when a full sentence follows 🟢 *(Cassidy)*

Style-guide dependent; a two-minute pass over the three colons in this section, and check the target journal.

### #23 · CR2 assumes nested, not crossed, random effects 🟢🟢 *(Kyle)*

Kyle's concern is legitimate: cluster-robust variance estimation clusters on one grouping factor, and your structure crosses species/phylogeny with study. Options, in order of effort:

1. Cheapest — state the clustering explicitly and flag the limitation: *"CR2 variance estimation clusters effect sizes by study; because species and phylogeny are crossed with, rather than nested within, study, the robust variance addresses within-study dependence only, and residual among-species dependence is handled by the random-effects structure rather than by the sandwich estimator \[cite the MEE paper Kyle links]."*
2. Better — report the Yang et al. estimator with clustering by study *and* by species, and note whether the adjusted mean is sensitive to the choice.
3. Also worth doing regardless — check `clubSandwich`'s effective degrees of freedom; if they are small, say so, since that is where crossed structures bite.

The reference Kyle cites (10.1111/2041-210X.70156) should be added either way.

### #24 · You could select ρ by AIC rather than fixing ρ = 0.5 🟢 *(Kyle, 2 comments)*

Fitting ρ ∈ {0.2, 0.5, 0.8} and comparing AIC is a modest addition and pre-empts the "why 0.5?" question. Suggested framing: keep ρ = 0.5 in the main analysis for comparability with the original meta-analyses, add a supplementary table of AIC and pooled means across ρ values, and add one sentence: *"pooled means shifted by ≤ ⚠️X units across ρ ∈ {0.2, 0.5, 0.8}, and ρ = 0.5 was within ⚠️Y AIC units of the best-supported value."*

### #25 · State the comparison explicitly 🟢 *(Cassidy + Kyle)*

In the cross-dataset validation paragraph, name what was compared against what:

> For every study represented in both source datasets, we compared the Hedges' *g* reported by Davies et al. with the *g* implied by converting Jones and DuVal's odds ratio for the same experiment and outcome (\autoref{eq:or-to-g}), and flagged studies where the two disagreed by more than 0.5 *g* units (seven studies).

---

## Methods — supplement and reproducibility

### #26 · Is the website supplementary material? Journals may not allow interpretation there 🟢🟢 *(Santiago)*

A fair and easily-fixed risk. Recommended split:

- The **website is a reproducibility archive** — code, model output, diagnostics. No interpretive claims live only there.
- Every numeric result and every interpretive statement the paper relies on appears in the **main text or a versioned supplementary PDF** submitted with the manuscript.
- Reword the pointer accordingly: *"…are provided in a fully reproducible online supplement (\url{...}), archived at Zenodo (DOI: ⚠️pending). All results on which our conclusions rest are reported in the main text or in \nameref{suppinfo}; the website provides the annotated code and complete model output."*

Then audit the two places that currently defer interpretation to the website — the "Exploratory uni-moderator analyses" subsection ends "provided in the online supplement" twice, and the sensitivity results point to `\nameref{supplresults}`.

### #27 · Show full `summary()` output and all variance components 🟢 *(Santiago)*

Straightforward and worth doing: add a supplementary table of variance components (σ² for study, species, observation, phylogeny, with total and partial *I*²) for every primary model, and print `summary()` verbatim per model on the website. This also satisfies #16.

### #47 · "Include github repo/zenodo later" 🟢 *(your own note, at the Data Availability Statement)*

Mint a Zenodo DOI from the GitHub release and cite it in the Data Availability Statement, the reproducibility sentence, and the OSF record.

---

## Results

### #28 · Are the 13 studies overlapping, or missed by the originals? 🟢🟢 *(Christine, +1 Aleksandra, +1 Anna)*
### also #28b · Establish clearly which studies/effects are original *vs.* added — maybe a diagram *(Aleksandra)*

The sentence is genuinely ambiguous. It means "published within the originals' search window but not captured by them" — which is a *finding* about search quality, so make it one:

> Thirteen of these 29 studies (45%) were published in or before 2019 and therefore fell within the search window of the original meta-analyses, yet had not been included in them. That our multilingual, grey-literature-inclusive strategy recovered this much pre-2019 evidence — including six theses (20.7%) — suggests the original searches were substantially less sensitive than their date ranges imply.

For the diagram request, two options: extend the existing PRISMA flowchart to the **PRISMA 2020 "previous studies" variant** (it has a dedicated column for records from the earlier reviews), or add a compact dataset-composition table:

| | Studies | Species | Hedges' *g* ES | ln(OR) ES |
|---|---|---|---|---|
| Davies et al. 2020 (original) | ⚠️ | ⚠️ | ⚠️ | — |
| Jones & DuVal 2019 (original) | ⚠️ | ⚠️ | — | ⚠️ |
| This update (new) | 29 ✔ | 15 ✔ | 69 ✔ | 69 ✔ |
| **Combined** | ⚠️80 / ⚠️69 | **33** ✔ | **227** ✔ | **172** ✔ |

The table is probably the better use of space, and it feeds straight into the abstract rewrite (#1, #2) and the Discussion opener (#35).

### #29 · Convert the OR to plainer English 🟢 *(Erick)*

Yes — an odds ratio against a 50:50 chance expectation maps cleanly onto a probability, *p* = OR/(1+OR):

> …an overall mean OR of 1.81 (95% CI: 1.35 to 2.42), equivalent to an observer choosing the socially favoured male on **64%** of occasions where chance alone predicts 50% (the originals' OR of 2.71 corresponds to 73%; our new data alone, OR = 1.46, to 59%).

Also confirm in the text that ORs are back-transformed from the log scale on which models were fitted, since Erick had to ask.

### #30 · The 'moderate'/'small' benchmarks 🟡 *(Erick dislikes them; Christine finds them useful)*

Keep them — Christine's reason (orientation for non-meta-analytic readers) is sound — but caveat once, which satisfies Erick:

> …which by convention is described as a 'moderate' effect (*sensu* Cohen 1988), although such benchmarks are arbitrary and poorly calibrated to behavioural and evolutionary data \[cite Møller & Jennions 2002 / Nakagawa & Cuthill 2007].

### #31 · Report τ² and prediction intervals; *I*² wording is technically wrong 🟢🟢 *(Kyle, 2 comments)*

Kyle is right on both counts. Reword the opening of the heterogeneity paragraph and add the numbers:

> Heterogeneity was substantial in all models: *I*², the proportion of observed variance not attributable to sampling error, exceeded 74%, and the total among-effect-size variance was ⚠️τ² = X (95% prediction interval for a new effect size: ⚠️L to U). Because *I*² depends on the precision of the contributing studies, we report both. More specifically, study ID… \[unchanged]

Prediction intervals also strengthen the Discussion — a PI that spans zero is a cleaner way to make the "conditional, context-dependent" argument than *I*² alone.

### #33 · Em dash plus semicolon in one sentence 🟢 *(Erick)*

Split the taxon sentence:

> On the Hedges' *g* scale, point estimates increased from arthropods (*g* = 0.24, 95% CI: 0.01 to 0.46) through fish (*g* = 0.49, 0.28 to 0.69) to other vertebrates, *i.e.* birds and mammals (*g* = 0.71, 0.36 to 1.07). Total heterogeneity was high (94.3%) and the among-group test approached significance (Wald *Q*_M = 3.06, *p* = 0.06).

Apply the same treatment to the log-odds sentence that follows, which has the same problem.

---

## Discussion

### #35 · Describe the evidence base with numbers at the top of the Discussion 🟢 *(Kyle)*

Open with the scope before the claim: *"Across 80 studies, 227 Hedges' *g* effect sizes and 172 log odds ratios spanning 33 species ⚠️(confirm), the qualitative conclusion of both foundational syntheses persists: …"*

### #36 · "real" is awkward 🟢 *(Christine)* · and #41 · same word in the Conclusion 🟢 *(Christine)*

Christine's point is that any single positive result makes copying "real"; the interesting claim is about prevalence and magnitude. Two replacements:

- Discussion: *"Mate choice copying therefore occurs across a broad range of taxa, but is more modest and more context-dependent than \textcite{jones...} and \textcite{davies...} implied…"*
- Conclusion: *"Mate choice copying is a quantifiable and taxonomically widespread behaviour: …"*

While there, fix the sentence-initial lowercase "mate choice copying" at the start of the Discussion paragraph, the §4.1 heading, and the Conclusion.

### #37 · Species differences, methodological heterogeneity, and comparison with the updated studies are missing 🟢🟢 *(Kyle, with Christine agreeing on the species part)*

The heaviest writing ask, and the most defensible. Kyle wants three things; the third is the one reviewers will also ask for. Suggested new paragraph in §4.1, after the conditional-view paragraph:

- **Species-level variation.** You have the material: species ID carries a large share of *I*² while phylogeny carries almost none, which is a substantive result — variation among species is not organised by relatedness, so it likely reflects ecology, mating system, and assay tradition rather than shared ancestry. Name the clade-level patterns even if tentatively (fish > other vertebrates > arthropods on the *g* scale, reversed and non-significant on the log-odds scale, so treat the gradient as unresolved), and note that *Drosophila* and *Poecilia* dominance means "among-species" variance is partly "among-labs-studying-two-genera" variance.
- **Methodological heterogeneity.** Discuss what the coding could not capture: before-and-after *vs.* no-pretest designs, association time *vs.* copulation outcomes, real *vs.* video/image demonstrators, and the equal-allocation control substitution (#11–#12). These plausibly generate more variance than the biological moderators you tested, which is consistent with the null moderator results.
- **Comparison with the studies you updated.** For the handful of studies whose effect sizes you re-extracted or corrected (the seven flagged studies, and the ones where conversion was needed), say explicitly how your values differ from the originals' and why — extraction from figures, pooling decisions, over-counted binary rows. `outputs/3_original_dataset_crosscheck/` should give you the per-study comparison directly.

### #38 · The generalized *vs.* individual distinction is confusing 🟢🟢 *(Iwo — the most detailed comment in the set)*

Iwo's diagnosis is precise: the paragraph slides between a *conceptual* distinction (a transmissible preference for a phenotype *vs.* a preference for one individual) and an *experimental-design* distinction (different targets sharing a trait *vs.* the same targets), and as written it reads as though individual-design studies are less rigorous. Restructure in three moves:

1. Define the two levels separately and label them differently in the text — e.g. *generalized preference* (the evolutionarily consequential outcome) *vs.* *generalized-design trial* (the assay that can detect it). Your Methods definition is already design-based ("trials presented observers with different target individuals that maintained a certain trait"), so make explicit that the moderator codes **design**, not inferred psychology.
2. State the inferential asymmetry rather than a quality judgement: individual-design trials cannot distinguish a preference generalised to the trait from a preference attached to the specific individual, or from other latent cues; generalized designs can. Neither is better science — they answer different questions, and individual designs are often the only feasible option.
3. Then the "our data support that premise" sentence needs weakening accordingly: finding that copying strength does not differ between designs is consistent with generalisation, but it is not a direct test of it — which is exactly why you call for a mechanism-explicit pre-registered test. Say that.

### #39 · Where are the limitations? 🟢🟢 *(Kyle)*

There is no limitations section, and the material is scattered through §4.2. Either rename §4.2 to "Limitations, knowledge gaps and future opportunities" and add the missing items, or add a short dedicated paragraph. The candidates, largely already established above: approximate metric conversion under a logistic assumption (✔ 38 *g* values converted from ORs and 31 lnORs converted from *g* in the new extraction alone — worth stating), the equal-allocation control substitution, figure-based data extraction (including the Gemini routine — the metaDigitise validation is a strength, say so here), sparse moderator levels and non-pre-registered moderator analyses, the crossed-random-effects caveat on CR2 (#23), grafted phylogeny tips and randomly resolved polytomies with Grafen branch lengths, and taxonomic concentration in two genera.

### #40 · Tie the taxonomic gap back to heterogeneity; consider marginalized means 🟢 *(Kyle)*

Two edits to the taxonomic-breadth paragraph:

- Make the argument from your own variance decomposition: *"That species ID accounted for a large share of heterogeneity while phylogeny accounted for almost none indicates that biologically important variation lies among species but is not predicted by relatedness — precisely the situation in which a sample concentrated in two genera is least informative, and in which broader taxonomic coverage would be most valuable."*
- Kyle's marginalized-means suggestion is a genuinely nice addition: report the overall mean marginalized over taxonomic groups (equal weighting per group, or per species) alongside the observed-sample mean, to show what the pooled estimate would look like under balanced coverage. `orchaRd::marginal_means()` handles this; cite the two examples he gives (10.1016/j.anbehav.2026.123542; Anim. Behav. and 10.1111/ele.14083). Expect the marginalized mean to sit somewhat higher than the raw mean given the arthropod-heavy sample — which is a useful, honest counterweight to the bias-corrected results.

### #42 · "sober" → "tempered" 🟢 *(Iwo)*

Take it. *"…the updated picture is more tempered than the original meta-analyses suggested."*

### #43 · "I love the presentation of this" 🟢 *(Kyle, on the Hedges' figure caption)*

No action — resolve the thread.

---

## Figures

### #46 · Funnel-plot asymmetry is defined only in the caption 🟢 *(Christine)*

Move the definition into the Methods where funnel plots are first mentioned, and leave the caption pointing to it:

> First, we visually assessed funnel-plot asymmetry — a systematic association between effect-size magnitude and precision, such that the scatter of low-precision studies is offset relative to high-precision ones rather than symmetric about the mean, which is the expected footprint of selective reporting — by examining residuals from a model containing all random factors, plotted against precision (1/SE).

---

## Housekeeping

### #44 · Add author contributions; disambiguate Ayumi's and Aleksandra's initials 🟢 *(you + Anna)*

Currently only three authors have contribution statements. Combined with #7, the clean solution is MeRIT: initials in-line in the Methods, plus a full CRediT-style list for all 17 authors. For the initials clash, extend the convention you already use for the language searches — **AMizuno** and **AMilenović** — and define both in a footnote or at the head of the contributions section. Check for other clashes too: **CS** is ambiguous between Cassidy Schneider and Christine Sosiak, and **SN**/**SO** are fine but **S**ergio may collide.

### #45 · "Shoutout to all my friends." → real acknowledgements 🟢 *(your own note)*

Placeholder still in the manuscript. Include: the coauthors' institutions if relevant, anyone who assisted with translation or screening but is not an author, Davies et al. and Jones & DuVal for making their data available (worth doing explicitly — you rebuilt your synthesis on it), and the Open Tree of Life.

### Not commented on, but visible while reading
- Five authors still have `\orcidlink{your-orcid-here}` or first-name-only entries (Aneta, Erick, Jimuel, Kyle, Marija, Sergio).
- "as the two original meta-analysis did" → "meta-analyses did".
- Davies et al. is cited as Hedges' *d* in some places and *g* in others; state once that their *d* is treated as *g* (or converted) and use one symbol thereafter.
- `$≤0.07$` in the sensitivity Results sentence uses a Unicode ≤ inside math mode; use `\leq`.

---

## Suggested order of work

1. **Zero-cost text edits** (#3, #19, #20, #22, #33, #36, #41, #42, #43, #46, plus housekeeping) — one pass, an hour.
2. **Methods restructuring** (#7, #8, #9, #10, #14, #15, #16, #17, #21, #25, #26, #27, #32, #34) — no new analysis, mostly consolidation and specification.
3. **New numbers from existing objects** (#12, #13, #29, #31, #35, and the dataset-composition table for #1, #2, #28) — extraction, not re-analysis.
4. **New analyses** (#11 sensitivity refit without imputed controls; #18 effective-*N* Egger's; #23 clustering check; #24 ρ sensitivity; #40 marginalized means) — the decision point, since #18 could shift the headline bias results.
5. **New Discussion writing** (#37, #38, #39, #40) and then the abstract rewrite (#1–#6) last, once the numbers are settled.
