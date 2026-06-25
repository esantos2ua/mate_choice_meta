# Manuscript review — inconsistencies + Discussion draft

_Mate-choice copying in non-human animals: an update of two meta-analyses_
Review of the compiled PDF, ordered front-to-back. Line numbers refer to the margin numbers in the compiled manuscript.

---

## Part 1 — Inconsistencies and things to fix (in order)

### A. Placeholder / template text still in the document (highest priority)

1. **Abstract (lines 8–15).** This is still the boilerplate from the `getwriting` LaTeX class ("This is an example of the document that can be generated with the getwriting class… I usually use this template…"). There is no real abstract. Replace with a structured abstract reporting the two questions, the updated effect sizes (OR and Hedges' *g*), heterogeneity, bias findings, and the take-home message.

2. **Acknowledgements (line 387).** "Shoutout to all my friends." — placeholder. Replace with real acknowledgements (data contributors, language reviewers AM/ML/ESAS/HQ/SO who are thanked in Methods but may not be co-authors, funding administrators, etc.).

3. **Discussion (lines 376–378).** Section 4 is empty — only the two sub-headings "4.1 Knowledge gaps and future opportunities" and "4.2 Conclusion" exist, with no opening paragraph for Section 4 and no body text. (Draft scaffolding provided in Part 2.)

### B. Authorship inconsistency

4. **Author list (lines 3–5) vs. Author Contributions (lines 392–396).** The title page lists ~19 authors (Santos, Aleksandra, Aneta, Anna, Ayumi, Cassidy, Christine, Erick, Hao, Iwo, Jimuel, Kyle, Mahi, Marija, Santiago Ortega, Sergio, Nakagawa, Lagisz), but the Contributions section names only **three** (Santos, Lagisz, Nakagawa). Also, most listed authors appear by **first name only** (no surnames). Reconcile the byline with the contributions list, add full names, and give every author a CRediT statement — or trim the byline.

### C. Research questions vs. what was actually done

5. **Q1 may no longer be answered (lines 65–67 vs. Results).** Q1 asks what happens "if we update the datasets **and use the same original analytic methods**." The Results (3.2) only present the updated multilevel/phylogenetic analyses, plus the original meta-analytic means as reported by the source papers. There is no analysis that re-runs the *original* analytic methods on the updated data. Either add that comparison or revise Q1 so the questions match the analyses presented.

6. **Deviations wording (lines 78–85).** Section 2.1 says only the Q2 search strategy was run, and that effect sizes from the originals were cross-checked rather than re-extracted. Make sure the framing of Q1/Q2 in the Introduction (lines 65–70) is consistent with these deviations — as written, the Introduction still promises a "same original methods" arm that the deviations effectively drop.

### D. Methods — equations and terminology

7. **"Hedges' *d*" is wrong (lines 168–169).** "Hedges' *g* (a bias-corrected version of Hedges' *d*)." Hedges' *g* is the bias-corrected version of **Cohen's *d*** (the standardized mean difference *d*), not "Hedges' *d*." Fix the terminology.

8. **Equation-range citation (line 175).** Text says conversions use "Equation 16–Equation 19," but the conversion block actually runs through **Equation 20** (Var(lnOR) = Var(g) × π²/3). Change to "Equation 16–Equation 20." Relatedly, Equation 2 (the *d* formula) is defined but never cited in the surrounding text (lines 177–180 jump from Eq 1 to Eq 3).

9. **"Hedges' *d*" vs "Hedges' *g*" for Davies (lines 250, 327).** Davies et al. is described as "Hedges' *d* data" (line 250) and "mean overall Hedges' *d* of 0.58" (line 327), while your synthesis uses Hedges' *g*. State explicitly that these are treated as comparable (g ≈ d at the sample sizes involved), or harmonize the label.

10. **"Alternative method to Egger's regression" (line 264).** You then describe *fitting the Egger regression model*. The phrasing is self-contradictory — reword to "a multilevel analogue of Egger's regression" or similar.

### E. Software / reproducibility details to verify

11. **Data extraction tool (line 159).** "a routine in Google Gemini 3.1 Pro" is vague and unusual for a methods section, and the validation set says "a set of 20 records." Specify exactly what the routine did, how accuracy was assessed against `metaDigitise`, and confirm the model name/version is correct.

12. **Package versions (line 240).** `metafor v.5.0-1` is a notably high version number — verify it's correct (and not a typo for a 4.x release). Also re-confirm `orchaRd v.2.2.0` and `R v.4.6.0`.

### F. Figure 1 (PRISMA) — numbers don't add up

13. **Exclusion reasons don't sum to the stated total.** The box states "Reports excluded… Studies excluded (n = 19)" but the itemized reasons — design (10) + humans (3) + no data (2) + no full text (1) + same data (1) — **sum to 17, not 19.** Two excluded reports are unaccounted for. (All other PRISMA arithmetic checks out: 2,855 − 901 − 898 = 1,056 screened; 1,056 − 1,008 = 48 sought; 48 − 19 = 29 included; 40 + 58 + 29 = 127 total.)

14. **Terminology: "PRISMA flowchart" vs "PRISMA-like flowchart."** Line 141 and the Figure 1 caption say "PRISMA flowchart," but line 315 says "PRISMA-**like** flowchart." Pick one.

### G. Results — numbers and internal consistency

15. **New-data odds ratio CI is inconsistent (lines 324–325).** "Our mean overall OR using the new data is **1.46 (95% CI: 1.29 to 3.49)**." On the log scale the point estimate (ln 1.46 = 0.378) is far from the geometric centre of the interval (≈ exp(0.75) = **2.12**) and sits almost on top of the lower bound. Either the point estimate or one CI bound is mistyped — cross-check against the model output / Figure 3b. (For comparison, the combined OR "1.81 (1.35–2.42)" is perfectly centred, so this one stands out.)

16. **Figure 6/7 cross-reference order (lines 349–350).** The sentence lists "Hedges' *g*… Odds ratio…" then cites "Figure 6a and Figure 7a," but **Figure 6 is the odds-ratio diagnostic and Figure 7 is the Hedges' *g* diagnostic.** The figure order is reversed relative to the text order — either reorder the citation to "(Figure 7a and Figure 6a)" or swap the clause order.

17. **Heterogeneity %: Section 3.3 vs Table 1.** Line 339 reports total heterogeneity of **94.3%** (Hedges' *g*) and **89.5%** (log OR) for the taxon uni-moderator models, whereas Table 1 reports combined totals of **85.7%** and **74.7%**. These are different models, but the gap is large — add a sentence clarifying why the moderator-model I² differs, or recheck the values.

18. **Redundant phrasing (lines 342–343).** "…with little evidence of among-group differences, with little evidence for among-taxonomic group differences in the mean effect sizes." The clause is duplicated — delete one.

19. **"Corrected" leave-out k drops slightly (lines 370–375).** Under the *Corrected* version, k is 225 (Hedges) and 169 (OR) vs. the full 227 and 172. If correction "retained those studies but replaced contentious values," k should be unchanged. Add a half-sentence explaining why a few effect sizes were nonetheless dropped (e.g., un-correctable), or recheck.

### H. Minor / style

20. **Figure 2 "studies" column sums to 30, not 29 (line 311 says 29 studies).** This is expected — Moran et al. (ref 52) covers two *Etheostoma* species and is counted once per species. Consider a caption note so a reader doesn't think it's an error. (The *k* column correctly sums to 69.)

21. **Hyphenation: "mate-choice copying" vs "mate choice copying."** Both appear (e.g., title/keywords line 17). Standardize.

22. **Acknowledgements/Funding ordering & Data Availability URL.** Confirm the GitHub URL (line 389) and the rendered supplementary site URL (line 307) both resolve, and that "Supplementary Table S1/S2" and "Supplementary Figure S1–S9" referenced in text all exist.

### Numbers that check out (no action needed)
- 69 effect sizes / 29 studies (refs 35–63); 13/29 ≈ 45%; 6/29 ≈ 20.7%.
- 15 species (Fig 2); combined 33 species; *k* column sums to 69.
- Drosophila + Poecilia: 46 effect sizes = 66.7%; 11 + 8 studies.
- OR k split 103 + 69 = 172; Hedges k split 158 + 69 = 227; taxon panels sum correctly.
- Table 1 partial I² rows each sum to their stated totals.

---

## Part 2 — Discussion draft: ideas and scaffolding

The headline tension to organize the Discussion around: **the effect is real and robust, but it is smaller than the original meta-analyses suggested, strongly heterogeneous, and contaminated by small-study/publication bias.** Below is a suggested structure with talking points grounded in your results.

### 4.0 Opening synthesis (add a short lead paragraph)
- One paragraph answering Q1/Q2 directly. Updating the datasets and applying contemporary multilevel-phylogenetic methods **confirms a positive, significant mate-choice copying effect** (combined OR 1.81 [1.35–2.42]; Hedges' *g* 0.445 [0.241–0.649]), but **attenuated** relative to the originals (OR 2.71 → 1.81; Davies' *d* 0.58 → combined *g* 0.445; new-data-only *g* just 0.21, CI touching zero).
- Frame this as the central "update" finding: the phenomenon survives replication and expansion, but its magnitude shrinks once newer, broader, grey-literature evidence and bias corrections are included.

### 4.1 Knowledge gaps and future opportunities
Candidate sub-themes (pick/merge):

- **Taxonomic and phylogenetic skew.** Drosophila + Poecilia = 66% of effect sizes; 15 species in your extraction, 33 combined. Despite this, the among-taxon test was weak (Q_M p = 0.06 for *g*; p = 0.32 for OR), and phylogeny explained little heterogeneity (I² < 7%). Gap: most "diversity" is two model genera. Future work should target under-sampled clades (amphibians, reptiles, non-poeciliid fish, more mammals/birds) to test generality.
- **Heterogeneity is the story.** Total I² > 74% in every model, dominated by within-study (observation-level) and non-phylogenetic species effects, not between-study or phylogenetic signal. Gap: we don't yet know *what* moderators drive this. Future work: pre-registered moderator tests (mechanism — generalized vs individual copying; cue modality — visual/chemical/acoustic; observer virginity; demonstrator age; lab vs wild). You collected several of these variables — flag whether they're analysed in the supplement or earmarked for a follow-up.
- **Strong small-study effects / publication bias.** Egger-type slopes were positive and significant on both scales (g: 4.36 [3.22–5.49]; OR: 2.11 [1.23–2.99]). Bias-corrected means shrink dramatically — toward or below zero under Nakagawa (e.g., combined *g* −0.21; new-extraction OR −0.02), while Yang's bias-robust means stay positive (g 0.34; OR 0.57). Gap/opportunity: the true effect likely lies below the naive estimate; the field needs registered reports and routine publication of null results.
- **Decline / time-lag effect.** A negative year trend for OR (β = −0.028 [−0.048, −0.007]) but not for *g* (β ≈ 0). Discuss the classic "decline effect" interpretation (early striking results regress as the literature matures; recent, more rigorous designs — e.g., Belkina 2021, Cirino 2023, Pusiak 2020, Nöbel 2023 — report weaker/null copying), and why it shows on one scale but not the other.
- **Methodological fragmentation.** Outcomes range from preference-zone time to social-learning indices to copulation choice, and original studies used incompatible effect-size metrics requiring logistic-normal conversion (Eqs 16–20, flagged as approximate). Gap: lack of standardized designs/reporting. Opportunity: propose minimum reporting standards (group means, SDs, ns, raw choice counts) to enable cleaner future syntheses.
- **The contentious effect sizes.** Seven studies disagreed with the original meta-analyses by > 0.5 *g* units. Results were robust to leave-out/correction, but this is worth a candid paragraph on extraction reliability and the value of cross-dataset validation as a routine update practice (tie to Pollo et al. 2025, ref 9).

### 4.2 Conclusion
- Mate-choice copying is a **real and taxonomically widespread** behaviour, but the updated, bias-aware estimate is **modest** and surrounded by substantial heterogeneity and evidence of selective reporting.
- The two original meta-analyses' qualitative conclusions hold; their **magnitudes were likely overestimates.**
- Forward-looking close: broader taxon sampling, mechanism-focused moderator tests, registered reports, and standardized reporting are the highest-value next steps. Position the paper as a model for *updating* ecology/evolution meta-analyses with contemporary methods.

### Optional subsection worth adding: **4.x Limitations**
- Effect-size conversions are approximate (logistic-normal assumption).
- Random polytomy resolution + Grafen branch lengths (no true branch lengths) in the phylogeny.
- Within-study correlation fixed at r = 0.5 (sensitivity?).
- Reliance on figure-digitized data for some studies.
