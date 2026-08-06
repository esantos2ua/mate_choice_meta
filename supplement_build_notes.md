# Supplementary PDF — build notes and citation audit

Created 2026-08-06 from `main (10).tex`.

---

## 1. The citation requirement is the opposite of what you asked for

You asked to make sure every supplement citation appears in the **main** reference list. Biology Open requires the reverse:

> "Each reference cited in the text must be listed in the Reference list and vice versa... **Where references are cited only in supplementary information, please provide a separate supplementary reference list and do not include these in the main reference list.**"

So supplement-only works must be *excluded* from the main list and given their own.

### Audit result: this does not affect you

| | Count |
|---|---|
| Citation keys in the main article | 81 |
| Citation keys in the supplement | 2 |
| Cited in both | 2 |
| **Cited only in the supplement** | **0** |

The two supplement citations are `nakagawaMethodsTestingPublication2022` and `yangRobustPointVariance2024`, both cited extensively in the main Methods. **Nothing needs to move, and no separate supplementary reference list is strictly required.**

### Why the 29 new studies are already handled

They are cited inline in the Results (`We obtained a total of 69 new effect sizes from 29 studies... \cite{29 keys}`), so all 29 are in the main reference list ✔.

### Why the excluded-studies table is not a problem

`included_studies_table.tex` and `excluded_studies_table.tex` present studies as **plain-text columns** (Author / Year / Title / Journal / DOI), not `\cite` commands. Zero `\cite` in either file. This is the cleanest possible arrangement under BiO's rule: excluded studies are documented for PRISMA without generating supplement-only reference-list entries. Leave them as they are.

---

## 2. The standalone supplement: `supplementary_information.tex`

Compiles independently to the single PDF BiO wants.

**What it contains** — everything from `\section*{Supplementary Information}` onward in `main (10).tex`:

| Section | Content |
|---|---|
| Search strings | all databases and languages |
| Supplementary Results | small-study effects, time-lag, sensitivity analyses |
| Supplementary Figures | 9 figures (Fig. S1–S9) |
| Supplementary Tables | PRISMA-EcoEvo checklist, included studies, excluded studies |

**What the wrapper adds**

- Its own title page, author line and affiliation, so the PDF stands alone
- `S`-prefixed page numbers and a running header
- `\thefigure`/`\thetable`/`\theequation` redefined to `S1, S2, …` (BiO's required scheme)
- A table of contents
- `\subsection*` promoted to `\section*` so the hierarchy makes sense without the main article above it
- An optional `Supplementary references` list at the end, purely so the PDF is readable alone. Given the audit above, you can delete that block with no compliance consequence.

**Compile**

```bash
pdflatex supplementary_information
biber    supplementary_information
pdflatex supplementary_information
pdflatex supplementary_information
```

Needs `getwriting.cls`, `figures/` and `tables/` alongside it — i.e. compile it inside the Overleaf project, as a second document.

**Verified:** braces balanced, 9 `figure` environments opened and closed, 3 `\input` tables resolve, 2 citation keys, one `\subsection*` correctly retained as a nested heading under Supplementary Results.

---

## 3. 🔴 Two supplementary figures are stale — PDF and PNG are out of sync

`save_loo_fig()` and `save_sens_fig()` write a PDF **and** a PNG of each figure. For two of them the PNG regenerated but the PDF did not:

| File | PNG | PDF | Status |
|---|---|---|---|
| `loo_study_or` | 08-06 09:18 | **06-24 16:19** | 🔴 PDF is six weeks old |
| `sensitivity_contentious_or` | 08-06 09:14 | **08-05 19:05** | 🔴 PDF predates the last render |
| `loo_study_hedges` | 09:18 | 09:18 | ✔ |
| `loo_species_hedges` / `_or` | 19:11 | 19:11 | ✔ |
| `sensitivity_contentious_hedges` | 09:14 | 09:14 | ✔ |
| `funnel_hedges` / `_or` | 19:05 | 19:05 | ✔ current — `publication_bias.qmd` unchanged since |
| `phylogeny_combined` | 06-18 | 06-18 | ✔ tree unchanged |

**The manuscript `\includegraphics` the PDFs**, so two supplementary figures would go to the journal showing pre-Davies-fix results.

I could not establish the cause. In both functions the PDF is written *before* the PNG inside a single `tryCatch`, so a failing PDF write should have prevented the PNG — yet the PNG is current and no "Could not save" warning appears in `render.log`. A file lock (the PDF open in a viewer during the render) is the most likely explanation.

**Check on your machine:**

```r
file.info(list.files("outputs/1_effect_size_calculation_pipeline",
                     pattern = "loo_study_or|sensitivity_contentious_or",
                     full.names = TRUE))["mtime"]
```

If the PDFs are genuinely old, close any open viewers and re-run those two chunks, or re-save directly:

```r
ggplot2::ggsave("outputs/1_effect_size_calculation_pipeline/loo_study_or.pdf",
                loo_plots$study_or, width = 9, height = 10)
ggplot2::ggsave("outputs/1_effect_size_calculation_pipeline/sensitivity_contentious_or.pdf",
                sens_plot_or, width = 10, height = 6)
```

⚠️ Worth adding `if (!file.exists(...) || file.mtime(...) < Sys.time() - 60)` style checking, or simply removing the `tryCatch` so a failed write becomes a visible error rather than a silent stale file.

---

## 4. Files to upload

| Destination | Files |
|---|---|
| Overleaf root | `supplementary_information.tex` (new second document) |
| `figures/` | the 7 main figures already staged, **plus** the 9 supplementary figures once `loo_study_or.pdf` and `sensitivity_contentious_or.pdf` are confirmed current |
| `tables/` | `partial_i2_table.tex`, `prisma_ecoevo_checklist.tex`, `included_studies_table.tex`, `excluded_studies_table.tex` |

Then compile `supplementary_information.tex` on its own and submit that PDF as the supplementary file. Confirm it lands under 50 MB — with 9 vector PDFs it will be comfortably below.

---

## 5. Will it compile as-is? Three bugs found and fixed

I checked rather than assumed, and the first version had three faults. All are now corrected in the file.

| Bug | Effect | Fix applied |
|---|---|---|
| `\fancyhead[R]{S\thepage}` on top of `\renewcommand{\thepage}{S\arabic{page}}` | Pages numbered **SS1, SS2** | Header now just `\thepage` |
| `\tableofcontents` with starred `\section*` headings | ToC would print **empty** — starred sections are never added | `\addcontentsline{toc}{section}{...}` after each of the four headings |
| Four `\hyperref` to **main-article** figure labels | `??` in the standalone PDF | Replaced with plain text: "Fig. 3 / 4 / 6 / 7 of the main article" |

That last one is worth understanding: the Supplementary Results paragraph pointed at the two orchard figures and the two Egger/time-lag dashboards, which live in the main article. Inside a standalone document those labels do not exist. Plain-text references are the correct fix and are what BiO expects anyway.

**Everything else resolves.** `getwriting.cls`, `authblk`, the `outline` environment, `fancyhdr` and the bibliography are all already in the project because `main.tex` uses them. So yes — upload it alongside `main.tex` and it compiles.

---

## 6. Replacing the stale PDFs with PNGs — works, but don't

Technically fine: `pdflatex` accepts PNG and the two files are 300 dpi.

But BiO is explicit for graphs and line art:

> "We accept the following file formats for graphs/line art: **EPS, PDF and SVG**... *Note that submission of JPEG or TIFF format for graphs/line art may delay production of your article.*"

Orchard and forest plots are line art. PNG is raster, is not on the accepted list, and would likely be queried at production even if it passes first-stage review. Since re-saving is one line per figure, take the two-minute route:

```r
ggplot2::ggsave("outputs/1_effect_size_calculation_pipeline/loo_study_or.pdf",
                loo_plots$study_or, width = 9, height = 10)
ggplot2::ggsave("outputs/1_effect_size_calculation_pipeline/sensitivity_contentious_or.pdf",
                sens_plot_or, width = 10, height = 6)
```

Close any PDF viewer that might be holding those files open first — that is the most likely reason they did not rewrite during the render.

---

## 7. What to delete from `main.tex` — and the eight references that break

### Delete

Everything from `\section*{Supplementary Information}` (line 391) up to but **not including** `\end{document}` — the whole block: Search strings, Supplementary Results, the nine supplementary figures, and the three `\input` table lines.

**Keep** `\input{tables/partial_i2_table}` at line 353. That is Table 1 of the main article and stays.

### Then repair eight cross-references

Deleting the supplement removes the labels these point at. Each becomes `??` unless converted to plain text.

| Current in `main.tex` | Replace with | Times |
|---|---|---|
| `\hyperref[tab:prisma-ecoevo]{Supplementary Table~\ref*{tab:prisma-ecoevo}}` | `Supplementary Table~S1` | 2 |
| `\hyperref[tab:included]{Supplementary Table~\ref*{tab:included}}` | `Supplementary Table~S2` | 2 |
| `\hyperref[tab:excluded]{Supplementary Table~\ref*{tab:excluded}}` | `Supplementary Table~S3` | 6 |
| `\hyperref[fig:supplementaryfigurephylogenycombined]{Supplementary Figure~\ref*{fig:...}}` | `Supplementary Fig.~S1` | 1 |
| `\nameref{supplresults}` | `Supplementary Information` | several |
| `\nameref{suppinfo}` | `Supplementary Information` | several |
| `\nameref{searchstrings}` | `Supplementary Information` | 1 |

⚠️ **Confirm the supplementary table order** before committing to S1/S2/S3. In `supplementary_information.tex` they appear as PRISMA-EcoEvo checklist → included studies → excluded studies, which gives the numbering above. If you reorder them, renumber these references to match.

The nine supplementary figures are already numbered S1–S9 in the order they appear, and `phylogeny_combined` is first, so `Supplementary Fig.~S1` is correct.

### Sanity check afterwards

Compile `main.tex` and search the log for `LaTeX Warning: Reference ... undefined`. There should be none. Any that appear are cross-references I have not listed.

---

## 8. Last remaining items

- `⟨⟨Zenodo DOI⟩⟩` still in the Data and resource availability section
- Every supplementary item must be cited at least once in the main text — Figs S1–S9 and the three tables all are ✔
