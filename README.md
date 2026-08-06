# Mate choice copying in non-human animals: an update of two meta-analyses

Reproducible workflow for an update and reconciliation of two published meta-analyses of
mate choice copying — Davies et al. (2020) and Jones & DuVal (2019). Every number, figure
and table in the manuscript is produced by the code in this repository.

**Reproducible supplement (rendered site):** <https://esantos2ua.github.io/mate_choice_meta/>
**Preregistration:** <https://osf.io/vfahk/overview>
**Archived release:** Zenodo DOI — *pending*

---

## Start here

If you have arrived from the paper and want to check a specific result, the rendered site
is the fastest route — every chapter shows the code, the model output and the figure
together. Otherwise:

| You want to… | Go to |
|---|---|
| See the headline estimates and how they were fitted | [`overall_effect.qmd`](scripts/1_effect_size_calculation_pipeline/overall_effect.qmd) |
| Check the publication-bias corrections | [`publication_bias.qmd`](scripts/1_effect_size_calculation_pipeline/publication_bias.qmd) |
| See why the two source datasets disagreed for seven studies | [`extraction_validation.qmd`](scripts/3_original_dataset_crosscheck/extraction_validation.qmd) |
| Check robustness (leave-one-out, contentious effect sizes) | [`sensitivity_analysis.qmd`](scripts/1_effect_size_calculation_pipeline/sensitivity_analysis.qmd) |
| See the exploratory moderator models | [`moderator_analysis.qmd`](scripts/1_effect_size_calculation_pipeline/moderator_analysis.qmd) |
| Read the screening/PRISMA process | [`literature_screening.qmd`](scripts/0_literature_screening/literature_screening.qmd) |
| Inspect the raw extraction | [`data/1_effect_size_calculation_pipeline/`](data/1_effect_size_calculation_pipeline/) |

## Where the manuscript's numbers come from

| Manuscript item | Produced by |
|---|---|
| Overall effects; orchard figures with bias corrections | `overall_effect.qmd` |
| Taxonomic moderator model and figure | `overall_effect.qmd` |
| Partial *I*² table | `overall_effect.qmd` (writes `outputs/1_effect_size_calculation_pipeline/partial_i2_table.tex`) |
| Egger's regression, time-lag models, funnel plots | `publication_bias.qmd` |
| Leave-one-out and contentious-effect-size analyses | `sensitivity_analysis.qmd` |
| Biological moderator models | `moderator_analysis.qmd` |
| Cross-check of the two source datasets | `scripts/3_original_dataset_crosscheck/` |
| Phylogeny and correlation matrices | `scripts/2_phylogeny/build_phylogeny.R` |
| PRISMA flow diagram | `scripts/0_literature_screening/2_prisma_flowdiagram.R` |

## Repository layout

The pipeline runs in numbered stages, and the numbering is consistent across `data/`,
`scripts/`, `builds/` and `outputs/`.

```
.
├── _quarto.yml             # Quarto book configuration
├── index.qmd               # Book landing page          ─┐
├── summary.qmd             # Plain-language summary      │ book scaffolding
├── references.qmd          # Bibliography page           │
├── references.bib          # All citations               │
├── styles.css              # Site styling               ─┘
│
├── data/                   # INPUTS (raw + a few derived counts)
│   ├── 0_literature_screening/              # combined records, PRISMA counts
│   ├── 1_effect_size_calculation_pipeline/  # extraction spreadsheet
│   ├── 2_phylogeny/                         # species counts (written by stage 2)
│   └── original_meta_analyses_datasets/     # Davies 2020 & Jones/DuVal 2019 (raw input)
│
├── scripts/                # ANALYSIS CODE (literate .qmd chapters + helper scripts)
│   ├── 0_literature_screening/              # dedup, PRISMA diagram, screening chapter
│   ├── 1_effect_size_calculation_pipeline/  # effect sizes (.py) + four analysis chapters
│   ├── 2_phylogeny/                         # phylogeny build (R) + its own README
│   └── 3_original_dataset_crosscheck/       # Davies vs Jones & DuVal validation
│
├── builds/                 # INTERMEDIATE artifacts (reviewer splits, PRISMA diagram)
├── outputs/                # FINAL artifacts (figures, LaTeX tables, trees, model objects)
├── docs/                   # Rendered site (GitHub Pages) — generated, do not edit
├── _freeze/                # Quarto freeze cache — generated
└── archive/                # Retired / superseded files (kept for provenance)
```

## Reproducing

Quarto project; paths resolve from the project root (`execute-dir: project`), and R code
additionally uses `here::here()`.

```bash
quarto render          # rebuilds docs/ (uses the _freeze cache where sources are unchanged)
```

R dependencies install at runtime via `pacman::p_load()` / `p_load_gh()`. Core analysis
uses **metafor** (`rma.mv`), **orchaRd**, **clubSandwich**, **ape** and **rotl**.

Two steps are run manually, outside the book render:

- `scripts/1_effect_size_calculation_pipeline/calculate_effect_sizes.py` — writes computed
  effect sizes back into the extraction spreadsheet.
- `scripts/2_phylogeny/build_phylogeny.R` — queries the Open Tree of Life, so it needs
  network access and is not re-run on every render. Its outputs are committed.

To force a chapter to re-execute, delete its folder under `_freeze/`. Quarto's freeze is
keyed on a content hash, so touching a file does not invalidate it.

## Data provenance

| Source | File | Note |
|---|---|---|
| This study | `data/1_effect_size_calculation_pipeline/Data Extraction Mate Choice Meta Analysis.xlsx` | new extraction, 29 studies |
| Davies et al. (2020) | `data/original_meta_analyses_datasets/Davies_et_al_2020_Final_data.xlsx` | reused with thanks; see note below |
| Jones & DuVal (2019) | `data/original_meta_analyses_datasets/Jones_DuVal_2019_data.CSV` | reused with thanks |

The two original datasets are redistributed here so the update is reproducible end to end.
Please cite the original papers when using them.

⚠️ **One coding note that matters if you reuse the Davies data.** Its `Author` column is not
a unique study identifier — five author strings each cover two or three separate
publications. We key on the `Study_no` column instead. Using `Author` merges twelve
publications into five and understates the study count by seven.

## Use of AI tools

Consistent with the disclosure in the manuscript: `Google Gemini 3.1 Pro` was used to
extract numerical values from published figures (all values checked against the source by
ESAS, with a 20-record validation subset re-extracted using `metaDigitise`);
`Claude Sonnet 5` was used to draft analytical code and structure this repository (all code
reviewed and tested by ESAS); and `Claude Opus 5` was used to review the manuscript text
(all final wording decisions verified by ESAS and SN). No AI tool searched the literature,
screened records, judged eligibility, or made a final analytical or interpretive decision.

## Citation

If you use this code or the harmonised dataset, please cite the paper and the archived
release:

> Santos, E. S. A., *et al.* Mate choice copying in non-human animals: an update of two
> meta-analyses. *Preprint*, EcoEvoRxiv. DOI *pending*.
>
> Archived code and data: Zenodo, DOI *pending*.

## Licence

Code is released under the MIT Licence; text, figures and the harmonised dataset under
[CC BY 4.0](https://creativecommons.org/licenses/by/4.0/). The two original datasets remain
subject to the terms of their source publications.
