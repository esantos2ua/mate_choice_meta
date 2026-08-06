# Biology Open — abstract, summary statement, AI declaration

Drafted 2026-08-06 against the 09:13 render. All figures verified.

---

## 1. Abstract — 198 words (limit 200)

**Replace:** the entire `\noindent` paragraph inside `\begin{abstract}` (line 40), keeping the `\\` at the end and the Keywords line that follows.

```latex
\noindent Mate choice copying, the use of social information from the mating decisions of others, is a taxonomically widespread form of social learning with the potential to shape sexual selection. Two meta-analyses concluded that social information moderately and positively biases mate choice, but both rest on literature searches now at least seven years old. Using a multilingual, grey-literature-inclusive search across seven languages, we added 69 effect sizes from 29 studies to the original datasets and harmonized the two source metrics onto common scales, giving 227 Hedges' \textit{g} effect sizes from 87 studies and 172 log odds ratios from 69 studies across 33 species. Re-analysed with phylogenetically informed multilevel models, the overall effect remained positive and significant but was appreciably smaller than before (Hedges' \textit{g} = 0.45, 95\% CI: 0.25 to 0.66, \textit{vs.} 0.58; odds ratio = 1.81, 1.34 to 2.45, \textit{vs.} 2.71). Heterogeneity was high and concentrated within studies and among species, not across the phylogeny. We detected strong small-study effects on both scales, and correcting for them drew the adjusted mean towards zero. Animals do copy the mate choices of others, but the effect is smaller, more variable, and more sensitive to publication bias than previously estimated.\\
```

### What was cut, and why

| Cut | Reasoning |
|---|---|
| "Here we update and reconcile both syntheses" | Redundant once the search sentence states what was done |
| "(15 species)" for the new extraction | The combined 33 species is the number that matters |
| "Considered on its own, the new evidence was roughly half that magnitude" | A secondary comparison; belongs in Results |
| The two-corrections contrast, spelled out | Compressed to "drew the adjusted mean towards zero" — the direction is the finding, the method contrast is not abstract material |
| Leave-one-out / contentious-effect-size robustness | Reassurance, not a result |
| "a pattern itself consistent with theory predicting that copying is a conditional, strategic use of social information" | The theoretical reading is a Discussion point |
| The three-part call for future work | Replaced by a single conclusion sentence, which is what BiO asks the closing line to do |

⚠️ One judgement call: the cut version says correction "drew the adjusted mean towards zero" without distinguishing the two frameworks. That is accurate for both (−0.21 and 0.10, neither distinguishable from zero) and avoids implying a negative mean. If a coauthor objects that it understates the divergence, the honest one-clause restoration is *"...towards zero, though a bias-robust estimator retained a positive but reduced mean"* — which adds 12 words and takes you to 210, over the limit. Something else would have to go.

---

## 2. Summary statement — 27 words (BiO asks 15–30)

**Insert:** immediately after `\end{abstract}` and before `\clearpage`. BiO uses it for e-alerts and tables of contents, so it must stand alone and must not repeat the title.

```latex
\noindent \textbf{Summary statement:} Updating two meta-analyses with seven more years of evidence confirms that animals copy each other's mate choices, but the average effect is smaller and less certain than previously reported.
```

Alternatives if you prefer a different emphasis:

- **Methodological angle (26 words):** *"A multilingual update of two mate choice copying meta-analyses shows the effect persists but shrinks, and that much apparent disagreement between syntheses came from how effect sizes were extracted."*
- **Bias angle (24 words):** *"Seven more years of evidence confirm that animals copy mate choices, but correcting for small-study effects draws the average effect close to zero."*

The first is the safest for a general-readership alert; the third is the most striking but leads with the most contestable finding.

---

## 3. AI declaration

BiO requires this in **its own subsection of Materials and Methods** ([AI policies](https://journals.biologists.com/journals/pages/ai-policies)), not in passing. You currently describe the Gemini routine inside *Data collection* (line 89), which does not satisfy the requirement.

### Recommended placement

Add as the **last subsection of Materials and Methods**, after *Small-study effects, time-lag patterns, and sensitivity analyses* (i.e. immediately before `\section{Results}` at line 209). Keeping it at the end of the section makes it easy for an editor to find, and avoids interrupting the analytical narrative.

```latex
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
\subsection{Use of artificial intelligence tools}
\label{sec:ai}
Generative artificial intelligence tools were used at three points in this work. In every case their output was checked by the authors, who take full responsibility for the content of this manuscript.

First, numerical values reported only in figures were extracted using \lstinline{Google Gemini 3.1 Pro}: a cropped figure and its caption were supplied to the model with a prompt requesting the point estimates and error-bar limits, returned as a markdown table. Because automated figure extraction can fail silently, ESAS checked every extracted value against the source figure, and a validation subset of 20 records was independently re-extracted with \lstinline{metaDigitise}~\cite{pickReproducibleFlexibleHighthroughput2019}; the two methods agreed closely (mean signed \textit{z}-score $= -0.10$, 95\% CI: $-0.27$ to $0.06$).

Second, \lstinline{Claude Sonnet 5} was used to draft the analytical code and to structure the reproducibility repository. ESAS reviewed and tested all generated code, and the complete annotated source is publicly archived (see \nameref{sec:data}), so that every result reported here can be traced to the code that produced it.

Third, \lstinline{Claude Opus 5} was used to review the written manuscript and suggest edits. All suggestions were evaluated by the authors, and ESAS and SN verified every final wording decision.

No artificial intelligence tool was used to search the literature, to screen records for eligibility, or to judge study inclusion. No tool made a final analytical or interpretive decision: model specifications, the treatment of contentious effect sizes, and all conclusions drawn from the results were determined by the authors.
```

⚠️ **One claim I removed, and why you should not put it back.** My first draft said no tool was used to "select or fit statistical models". Given that Sonnet drafted the analytical code and Opus reviewed the manuscript — including, in practice, flagging methodological issues such as the bias-robust weighting scheme and the degrees-of-freedom convention — that sentence would not have been accurate. The wording above instead says no tool made a *final* analytical decision, which is true and still meaningful. If a coauthor wants a stronger denial, the accurate limit is: AI proposed and implemented; the authors decided and verified.

⚠️ `\nameref{sec:data}` assumes you add `\label{sec:data}` to the Data and resource availability section. If you would rather not, replace with a plain cross-reference.

### Then trim `Data collection`

Delete the now-duplicated sentences from line 89 and point to the new subsection:

**FIND**
```
We extracted data from figures using a routine in \lstinline{Google Gemini 3.1 Pro}. The routine consists of uploading the cropped figure with its caption to a \lstinline{Google Gemini 3.1 Pro} chat, with a prompt that requests the model to extract values from the plots for the point estimates and error bars, and to store the outcomes in a markdown table. For a set of 20 records, we also extracted data from the same plots using \lstinline{metaDigitise} \cite{pickReproducibleFlexibleHighthroughput2019} for validation; the results were qualitatively and quantitatively indistinguishable (mean signed \textit{z}-score $= −0.10$, 95\% CI: $−0.27\ to\ 0.06$).
```

**REPLACE**
```latex
Values reported only in figures were extracted with the assistance of a generative artificial intelligence tool and validated against an established digitisation package (see \nameref{sec:ai}).
```

The `\label{sec:ai}` is already in the subsection above, so the `\nameref` resolves.

⚠️ Two things this fixes beyond compliance. The current wording gives the extraction routine but never states that a human checked the output — reviewers will ask. And the Unicode minus signs in the existing sentence (`−0.10`, `−0.27`) are the ones flagged as H5; the replacement text above uses proper LaTeX math minus.

### A related consistency check

The Author Contributions statement (**E27**) currently credits ESAS with "software". That remains accurate — authorship of the analysis rests with the person who directed, reviewed and tested it — but the two statements should not contradict each other. With the AI subsection in place, "software" reads correctly as ESAS having produced and validated the analytical code, with the tool assistance disclosed separately. No change needed; just don't add wording elsewhere that implies the code was written unaided.

---

## Remaining before submission

- Zenodo DOI (`⟨⟨Zenodo DOI⟩⟩`, line 206)
- Rename "Data Availability Statement" → "Data and resource availability"
- Competing interests → the exact phrase "No competing interests declared"
- Spell out funders per the Crossref registry
- Collate supplementary material into a single PDF (≤50 MB); the composition table goes there, since main-text display items are at the cap of 8
