# Comment mapping & revision guide — *Mate-choice copying: an update of two meta-analyses*

Generated 2026-07-08 from `main (6).tex` + the Overleaf comment export.

## Why the comments were hard to match

Two things in the export are broken, which is why the anchors don't line up:

1. **The `context`/`fragment` columns are corrupted.** Almost every row repeats the *same* opening Introduction paragraph ("The process of mate choice allows individuals…"), so they tell you nothing about where the comment actually is.
2. **The `position` (character-offset) column is only partly reliable.** Some offsets are accurate to the current file (e.g. char 11404 lands exactly on the empty `\cite{}` that a "reference needed" comment targets). But others have **drifted** because the manuscript was edited after the comment was written — most notably Losia's "needs justification" comments sit at an Introduction offset, yet their content clearly belongs to the Methods "Additions and deviations" section.

So below I mapped every **unresolved** comment by *content* against the current text, not by raw offset. Each entry gives the true location, the exact text it refers to, and a concrete suggestion.

**Confidence key:** 🟢 certain · 🟡 likely · 🟠 best guess (verify the anchor in Overleaf).

---

## The three big-picture comments to tackle first

Everything else is small. These three drive the revision:

1. **Streamline the Introduction to 3 moves** (Shinichi): (1) Topic 1–2 paragraphs, (2) Gaps/justification 1–2 paragraphs — the more important part, (3) what you did. All the content is already there; it just needs condensing and reordering.
2. **Turn "we updated and looked" into a prediction** (Shinichi): use the replication/publication-bias literature he flagged (see #7–#11 below) to *predict* that the effect will shrink on updating — this simultaneously answers Losia's repeated "needs justification" and gives the paper a hypothesis.
3. **Cut the Discussion** (Shinichi): merge §4.1 into §4.2, drop result-level detail, and combine the bias/decline/reporting paragraphs. Move the full sensitivity analyses to the Supplement.

---

## Introduction

### 1. Author names & ORCIDs 🟢
- **Where:** `\author{}` block, lines 9–23 (`\orcidlink{your-orcid-here}` placeholders on Aleksandra, Aneta, Anna, Ayumi, Cassidy, Christine, Erick, Hao, Iwo, Jimuel, Kyle, Mahi, Marija, Santiago, Sergio).
- **Comment (Eduardo, self-note):** "Guys, please add your correct full name and ORCID here."
- **Suggestion:** This is a coauthor action item, not a revision. Circulate a quick form / email to the 15 authors requesting full name + ORCID, then replace the placeholders. Cheap to close.

### 2. Condense the Introduction to three moves 🟢
- **Where:** whole Introduction, lines 49–59 (the three "topic" paragraphs are lines 49, 51, 53).
- **Comment (Shinichi):** "These 3 can be condensed — you only need 3 things in the intro: 1) Topic (1–2 paragraphs), 2) Gaps/justification (more important than topic, 1–2 paragraphs), 3) what you did. Restructure — all the content is here, you can streamline it."
- **Suggestion:** Merge the current paragraphs 1–3 (definition → why it evolves → taxonomic spread + evolutionary consequences) into **two** tight topic paragraphs. Keep para 4 (what the two meta-analyses found) as the bridge into the gap. Then make the "updating + declines" material (see #7) your explicit **gap/justification**. End with the research-question paragraph (#12). Target: from ~6 paragraphs down to ~4.

### 3. Justify why only the Q2 search strategy was run 🟡
- **Where:** Methods → "Additions and deviations", line 70: *"We conducted only the strategy described under Q2 in the preregistered protocol: 'More comprehensive search strategy…'"* (offset drifted; content match is unambiguous).
- **Comment (Losia):** "need justification why only this one was conducted."
- **Suggestion:** Add one clause explaining the choice, e.g. *"…because the more comprehensive, multilingual, grey-literature–inclusive strategy (Q2) fully subsumes the narrower Q1 search, making the additional strategy redundant while maximising recall."*

### 4. Justify the "included studies" deviation 🟡
- **Where:** line 71: *"We included the same studies as in the earlier meta-analyses, plus new studies from all periods retrieved in our searches."*
- **Comment (Losia):** "needs justification, e.g. because…"
- **Suggestion:** Add rationale: *"…because retaining the original studies is what makes this an update rather than a new synthesis, and allows direct reconciliation of old and new estimates on a common scale."*

### 5. Justify the "no de-novo extraction" deviation 🟡
- **Where:** line 72: *"We did not extract de novo effect sizes from original meta-analyses, but instead conducted cross-checking of effect sizes present in both original meta-analyses."*
- **Comment (Losia):** "needs justification."
- **Suggestion:** *"…because the original effect sizes were already published and quality-controlled; cross-checking (rather than re-extracting) lets us flag discrepancies between the two source datasets while avoiding the risk of introducing new extraction error."*

### 6. Clarify "random choice" 🟡
- **Where:** Methods → PECOS "Comparator", line 84 (char 11565): *"For instance, random choice: females or males tested under identical conditions, either without a model … or with the model … hidden by an opaque partition."*
- **Comment (Losia):** "unclear why random."
- **Suggestion:** Rename to avoid the word "random" (which reads as randomisation). Use *"For instance, a no-information control: individuals tested under identical conditions but with no model present, or the model hidden behind an opaque partition — so any preference reflects chance/baseline rather than social information."*

### 7–11. Expand the "Updating studies" paragraph into a prediction 🟢
- **Where:** line 57, *"Updating studies is a fundamental part of science… an update is necessary to incorporate new empirical evidence…"*
- **Comments (Shinichi, five threads):**
  - "This bit needs expanding — Alfredo's work — badge of status — they changed earlier results — this sets some expectations."
  - "Updating often results in declines — Yefeng's paper shows publication-bias corrections make the effect disappear — so you can form a hypothesis/prediction, which is better than 'just update and see'."
  - Links: `https://elifesciences.org/articles/37385`, `https://onlinelibrary.wiley.com/doi/full/10.1002/ece3.73578` (Sánchez-Tójar et al.); `https://link.springer.com/article/10.1186/s12915-022-01485-y` (Yang et al. — "2/3 become non-sig after publication-bias correction, which nobody does").
  - "These new studies justify our updating — above, Losia wanted justification and you now have one."
- **Suggestion:** Add ~3–4 sentences that convert this into a stated expectation. Draft:
  > *Updates and replications in ecology and evolution frequently revise — and often deflate — textbook effects: re-analyses have overturned canonical status-signalling results (Sánchez-Tójar et al.), and systematic publication-bias corrections eliminate a large fraction of published effects that are almost never applied in the primary literature (Yang et al.). We therefore expected, rather than merely explored, that an expanded and bias-corrected synthesis would recover a positive but attenuated effect of mate-choice copying relative to the original meta-analyses.*
  - **Action:** add these three references to `10_MainTextReferences.bib`. Verify the exact citations before inserting (the eLife 37385 = Sánchez-Tójar et al. 2018 badge-of-status meta-analysis; the Springer link = Yang et al. 2022/2023 *BMC Biology* on publication bias). This is *distinct* from `yangRobustPointVariance2024`, which you already cite.
  - **Bonus:** this single addition also closes comments #3–#5 (Losia's justification requests) and gives the Discussion (#25) its answer.

### 12. Make the research-question paragraph the paper's spine 🟢
- **Where:** line 59, *"In the present work, we employed updated methodological techniques… Thus, our specific research question is: Do the main findings of these two meta-analyses remain valid, and/or how much do they change…?"*
- **Comment (Shinichi):** "This is the most important paragraph of the whole MS — it needs to tell you what you did, and the paper should revolve around it. You put 2 questions — the paper needs to address these, and the first paragraph of the Discussion needs to give clear answers to them."
- **Suggestion:** State the two questions as an explicit numbered pair — (Q1) *Do the qualitative conclusions survive?* and (Q2) *By how much do the magnitudes change?* Then open the Discussion (line 278) by answering each in one sentence: Q1 → yes, effect stays positive/significant; Q2 → roughly halved, and near-zero under conservative bias correction.

---

## Materials and Methods

### 13. Too many bullet lists 🟢
- **Where:** Methods generally (outlines at lines 68–73, 87–91, 101–109, 219–222). Anchor at line 62.
- **Comment (Shinichi):** "Too many lists — academic papers have lists but much fewer. Turn them into a paragraph using '…, 1)…, 2)…, 3)…'. A clear list is easier to read, but AI over-uses them and heavy use should be avoided."
- **Suggestion:** Convert the "Additions and deviations", the PECOS outcome list, and the two-step Egger's list into running prose with inline enumeration. Keep at most the eligibility-criteria list (line 101) as a genuine enumerated list.

### 14–15. Add PRISMA-EcoEvo statement + checklist 🟢
- **Where:** start of Methods, line 63 (preregistration sentence).
- **Comments (Shinichi):** "Please say we will use PRISMA-EcoEvo reporting guidelines and fill in the checklist — we usually submit a checklist as a supplement." + link `https://www.prisma-statement.org/ecoevo`.
- **Suggestion:** Add: *"We report this update following the PRISMA-EcoEvo reporting guidelines (O'Dea et al. 2021); the completed checklist is provided as Supplementary Material."* Then generate the checklist and add it as a supplementary file. Add the `odeaPreferredReportingItems2021` reference to the bib.

### 16. "not converted to g?" 🟠
- **Where:** offset lands in PECOS (char 11404), but content is about effect-size conversion — most likely the Effect-size calculation section (lines 124–195) or a specific reported value. Verify anchor in Overleaf.
- **Comment (Losia):** "not converted to g?"
- **Suggestion:** Check whether a value that should be on the Hedges' *g* scale is still reported as OR/log-OR. Confirm the sentence at line 195 ("converted values were flagged…") covers it, and make explicit that every effect used in the *g* synthesis is on the *g* scale.

### 17–22. PECOS framework: definitions, missing citations, clarity 🟡
- **Where:** PECOS block, lines 82–93 (offsets 11404/11411 land here accurately).
- **Comments (Losia):** "define" ×2, "not clear", "reference needed" ×2, "where?".
- **Mapping & suggestions:**
  - **Empty `\cite{}` on line 84** (`\cite{}\textbf{Comparator}`) → this is the "reference needed". **Fill or delete the empty citation command** — right now it will render nothing / throw a warning.
  - **"define"** → define **"audience effect"** (line 83) and **"social cue"** on first use, with a citation.
  - **"not clear" / "where?"** → tighten the Comparator sentence (see #6) and make sure each PECOS element states its source; add a citation where the Exposure/Comparator definitions come from Jones & DuVal / Davies et al.
  - **Action:** these are terse inline flags whose exact word is lost in the export — open the PECOS paragraph in Overleaf and address each highlighted term. The empty `\cite{}` is the one unambiguous, must-fix item.

---

## Results

### 23. Shorten small-study/sensitivity results; move to Supplement 🟢
- **Where:** Results → "Small-study effects, time-lag patterns, and sensitivity analyses", lines 260–273 (anchor 42839).
- **Comment (Shinichi):** "Great, you can shorten them — even all the sensitivity analyses can go to the Supplement."
- **Suggested 2–3 sentence summary to keep in Results** (replaces lines 262–273):
  > *We found strong small-study effects on both the Hedges' g and odds-ratio scales, and mixed evidence of a time-lag decline (present only for the binary outcomes). Under the more conservative bias correction the adjusted mean approached, and for Hedges' g fell marginally below, zero, whereas the bias-robust estimator retained a positive but reduced effect (Figures~\ref{fig:ororchard},~\ref{fig:hedgesorchard}). The pooled estimates were nonetheless robust to leave-one-out, leave-one-species-out, and to how the contentious effect sizes were handled, with the largest shift in any pooled mean being ≤0.07 units (full diagnostics and numeric results in Supplementary §S-Sensitivity and the online supplement).*
- **Where the full content should go in the Supplement:** the funnel plots, leave-one-out, leave-one-species-out, and contentious-effect figures already live in **§Supplementary Figures** (line 508 → figures S2–S3 funnels, S4–S7 leave-one-out, S8–S9 sensitivity). The cleanest home for the *narrative + numbers* you're cutting is a new short text subsection **`\subsection*{Publication-bias and sensitivity analyses}` inserted right after §Search strings (line 417) and before §Supplementary Figures (line 508)** — so the prose sits immediately alongside the figures it references. Put the Egger-slope values, the two corrected means, the leave-one-out/species shifts, and the three-version contentious-effect *k* values there. Reserve full model summaries and annotated code for the **online reproducible supplement** (the GitHub Pages site already linked at line 232 / the Data Availability Statement).

### 24. Define term briefly in parentheses 🟡
- **Where:** line 269, *"The combined estimates showed little sensitivity to the contentious effect sizes…"*
- **Comment (Losia):** "define briefly in ()."
- **Suggestion:** On first use, gloss "contentious effect sizes" inline: *"…the contentious effect sizes (those from the seven studies whose values disagreed between the two source meta-analyses by more than 0.5 Hedges' g units)…"*

### 31. Figure — replace "k" with "effect sizes" label 🟢
- **Where:** phylogeny figure caption, line 328 (`the number of effect sizes (\textit{k})`); anchor 63655. Same "k" label appears in the orchard-plot figures.
- **Comment (Losia):** "in the figure, replace 'k' with 'effect sizes' label."
- **Suggestion:** In the figure artwork (not just the caption), change the axis/annotation label from `k` to "effect sizes". Regenerate the affected plots (`orchaRd`) so the panel labels read "effect sizes (studies)" instead of `k`.

### 32. "used" 🟠
- **Where:** phylogeny caption, line 328 (anchor 63782) — near "the actual number of studies included is 29" / "…in which they are reported".
- **Comment (Losia):** "used."
- **Suggestion:** Minor wording — likely wants "…the number of effect sizes **used**…" or "studies **used**". Confirm the exact word in Overleaf and insert "used".

### 33. Explain the bubbles in every orchard plot 🟢
- **Where:** figure captions for the orchard plots, esp. `fig:ororchard` (line 336) and `fig:hedgesorchard` (line 344); anchor 64796.
- **Comment (Losia):** "also explain bubbles for each orchard plot."
- **Suggestion:** Add one sentence to each orchard-plot caption: *"Each bubble is an individual effect size; bubble area is proportional to its precision (1/SE)."* (Currently only the leave-one-out/sensitivity captions explain the scaling.)

---

## Discussion

### 25–26. Discussion is too long — streamline 🟢
- **Where:** whole Discussion, lines 276–310 (anchor 47848).
- **Comments (Shinichi):** "Word limit — Discussion seems quite long, could be streamlined; I like the organisation." + "Ideas: 1) merge 4.1 and some of 4.2 — they make the same argument (copying positive but conditional); 2) cut result-level detail and discuss higher-level things; 3) combine the paragraphs on bias, decline and reporting standards."
- **Current size:** ~1,920 words across 12 paragraphs. **Target: ~1,150–1,250 words / 7 paragraphs (a ~35–40% cut).** Per-paragraph word counts today: opening 163; §4.1 = 108 (l.283) + 219 (l.285) + 139 (l.287–288) + 220 (l.290); §4.2 = 221 (l.295) + 201 (l.297) + 83 (l.299) + 68 (l.301) + 123 (l.303) + 183 (l.305); conclusion 194.

#### Concrete paragraph-by-paragraph plan

**P1 — Opening: answer the two questions (revise l.278; 163 → ~100 w).**
Rewrite so it explicitly answers Q1 (qualitative conclusion survives) and Q2 (magnitude ~halved, near zero under conservative correction). Drop one of the two anchor numbers — keep either `OR = 2.71` *or* `Hedges' d = 0.58`, not both, and refer to the attenuation qualitatively.
> *Example:* "Our update answers the two questions we set out with. First, the qualitative conclusion of both foundational meta-analyses survives: after an expanded, multilingual, grey-literature–inclusive search and a unified phylogenetic multilevel re-analysis, the average effect of social information on mate choice remains positive and statistically significant on both scales. Second, the magnitude is smaller than previously implied — roughly half when the new evidence is considered alone, with confidence intervals spanning zero, and, under the more conservative bias correction, an adjusted mean close to zero. Mate-choice copying is therefore real, but more modest and more context-dependent than the original syntheses implied."

**§4.1 — "Copying is positive but conditional" (this is Shinichi's move #1).**
- **P2 — merge l.283 + l.285 (327 → ~180 w).** Both make the identical "positive-but-modest = social information *supplements* rather than *overrides* personal assessment; theory predicts conditional, strategic copying" argument. State it once. Keep the punchline that recent weak/null studies are evidence of *selective* copying, not its absence. Delete the rhetorical opener "How should a positive but moderate average effect… be interpreted biologically?"
- **P3 — merge the heterogeneity material from l.285-tail + l.295 (into ~140 w).** This is the "some of 4.2" Shinichi means: l.295 repeats l.285's conditionality point. Combine into one paragraph: heterogeneity is large, accumulates within studies and among species (not between labs or across the phylogeny), the candidate moderators explored post-hoc explained none of it, and the virginity effect was not reproduced. Fold the phylogeny/*Drosophila*/domain-general point (l.287–288, 139 w) down to **two sentences** here (~50 w) — it supports the same "recurring, domain-general solution" theme.
- **P4 — keep generalized vs individual copying (l.290, 220 → ~120 w).** This is a genuinely distinct, higher-level point worth keeping — it's the hinge for the sexual-selection/cultural-evolution reading. **Cut the numbers** (`0.44 vs 0.44`, `0.26 vs 0.16`) → "the two were statistically indistinguishable, with the generalized form marginally larger in the new extraction."

**§4.2 — "Limitations and future directions."**
- **P5 — combine bias + decline + reporting: l.299 + l.301 + l.303 + l.305 (455 → ~180 w).** This is Shinichi's move #3. Strip all result-level detail (Egger β values, `k` counts, the `0.5 g` threshold, `0.04–0.07` shifts, the *Poecilia reticulata* removal — all already in Results). Keep three high-level claims and the prescription.
  > *Example:* "Three features of the evidence base temper these conclusions and set the agenda for future work. First, small-study effects were strong on both scales, and the more conservative correction drew the adjusted mean towards — and for Hedges' g marginally below — zero, so the true effect very likely lies below the naïve pooled estimate. Second, effect sizes for the binary outcomes declined with publication year, echoing the familiar pattern in which early, large effects are tempered by better-powered designs. Third, primary studies quantify copying in incompatible ways and the two source meta-analyses reported different metrics, forcing approximate conversions; although our estimates proved robust to how the resulting contentious values were handled, the broader lesson is methodological. The field would benefit from registered reports, routine publication of null and small-sample results, and minimum reporting standards — group means, SDs, sample sizes, and raw choice counts — so that future updates rest on less-censored, directly comparable data."
- **P6 — keep taxonomic breadth (l.297, 201 → ~110 w).** Distinct future-direction. **Cut the result-level scale-disagreement detail** (which group ranks where on each metric); keep the high-level message: evidence is concentrated in *Drosophila* and *Poecilia*, other clades are effectively absent, and broader sampling would test generality and give the phylogenetic tests something to work with.

**§4.3 — Conclusion (l.310, 194 → ~140 w).** Keep — Shinichi liked the finish. Trim by removing the numeric restatements; end on the existing "template for how meta-analyses can be revisited" sentence.

**Net effect:** 12 → 7 paragraphs, ~1,920 → ~1,150 words. The two example rewrites above are drop-in starting points; everything else is a keep-and-trim.

### 27. Uni-moderator / heterogeneity analyses were not preregistered 🟡
- **Where:** Discussion → "Knowledge gaps", line 295 (anchor 56437), which already says "post-hoc, non-pre-registered uni-moderator analyses."
- **Comment (Eduardo, self-note):** "I have some uni-moderator analyses and the heterogeneity assessment. They were not preregistered, though."
- **Suggestion:** Already handled — the text labels them exploratory/non-pre-registered (also in Results §3.4, line 257). Just make sure this framing is consistent everywhere they appear and flagged as exploratory in any figure/table titles. No further action beyond a consistency check.

### 28 & 30. "Strong finish" ×2 🟢
- **Where:** end of Conclusion, line 310, *"Finally, we offer this update as a template for how meta-analyses in ecology and evolution can be revisited…"* (anchors 62683, 62964).
- **Comments (Shinichi):** "strong finish" / "A strong finish."
- **Suggestion:** Positive feedback — keep this closing sentence as is.

### 29. "data" 🟠
- **Where:** end of Discussion / just before `\section{Figures}`, ~line 310–314 (anchor 62950).
- **Comment (Losia):** "data."
- **Suggestion:** Ambiguous single-word flag. Most likely a nudge that a **Data Availability Statement** belongs here / should be referenced — you do have one at line 394 (GitHub link). Confirm the highlighted word in Overleaf; possibly just a wording edit ("data").

---

## Supplementary material & figures

### 35. Add "(hierarchical non-independence of effect sizes)" 🟢
- **Where:** funnel-plot caption, line 522, *"…they still carry all of the random-effects heterogeneity (between-study, between-effect-size, and between-species)."* (anchor 75867).
- **Comment (Losia):** "(hierarchical non-independence of effect sizes)."
- **Suggestion:** She's supplying the phrase to insert — add it as a gloss: *"…heterogeneity (between-study, between-effect-size, and between-species — i.e. the hierarchical non-independence of effect sizes)."*

### 36. "multilevel structure" 🟢
- **Where:** same caption, line 522, *"…once the nesting is accounted for…"* (anchor 75946).
- **Comment (Losia):** "multilevel structure."
- **Suggestion:** Replace the informal "nesting" with her term: *"once the multilevel structure is accounted for."*

### 37. Rename exclusion reasons in Table S2 🟢
- **Where:** `tables/excluded_studies_table` (input at line 599); anchor 83146.
- **Comment (Losia):** "Table S2 exclusion reasons 'Not the type of study necessary' and 'Not the design of study necessary' sound odd — consider 'wrong study type' and 'wrong study design'."
- **Suggestion:** Edit the exclusion-reason labels in the source table/data to **"wrong study type"** and **"wrong study design"**, then regenerate the table.

### 38. Add GitHub repo / Zenodo 🟡
- **Where:** end of document, line 603 (anchor 83314). Note a Data Availability Statement already exists at line 395 with `https://github.com/esantos2ua/mate_choice_meta`.
- **Comment (Eduardo, self-note):** "Include github repo/zenodo later."
- **Suggestion:** The GitHub link is in; **mint a Zenodo DOI** for the repository (archive a release) and add it to the Data Availability Statement so the archive is citable and versioned.

---

## Already resolved (no action needed — for your reference)

The export lists ~30 resolved threads. The substantive ones already closed: search strings added, PRISMA flowchart added, full-text exclusion table added, project website added, all included studies cited in main text, "combined and optimised search terms" wording, "platform vs database" wording, and a batch of Losia's typo/wording fixes ("delete", "used", "genera", decimal consistency, "on average", "these meta-regression models", etc.). Shinichi's note on mixing "statistical significance" + effect-size language is marked resolved but only *partly* actioned — he wrote "I did a bit below but not all, please do." **Worth a final pass:** state which effects are statistically significant alongside their magnitudes throughout Results, since reviewers respond well to that pairing.

---

## Suggested priority order

1. **Introduction rewrite** (#2, #7–#11, #12) — biggest lift, unlocks the paper's framing and answers Losia's justification comments.
2. **Discussion trim** (#25–#26) — merge §4.1/§4.2, cut numbers, combine bias/decline/reporting.
3. **Methods fixes** (#3–#6, #13, #14–#15, #17–#22) — justifications, PRISMA-EcoEvo, de-list, fix the empty `\cite{}`.
4. **Figures/tables** (#31, #33, #35, #36, #37) — regenerate plots with "effect sizes" labels + bubble legend; rename exclusion reasons.
5. **Housekeeping** (#1 ORCIDs, #38 Zenodo DOI, significance-language pass).
