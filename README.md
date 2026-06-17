# Mate-choice copying in non-human animals — meta-analysis

An update of two meta-analyses (Davies et al. 2020; Jones & DuVal 2019) on mate-choice
copying. This repository holds the reproducible workflow: data, analysis code, derived
artifacts, and a Quarto book published to GitHub Pages.

**Rendered site:** https://ejlundgren.github.io/mate_choice_meta/ (built from `docs/`)

## Repository layout

The pipeline runs in numbered stages (`0` → `1` → `2`), and that numbering is consistent
across `data/`, `scripts/`, `builds/`, and `outputs/`.

```
.
├── _quarto.yml             # Quarto book configuration
├── index.qmd               # Book landing page          ─┐
├── references.qmd          # Bibliography page           │ book scaffolding
├── references.bib          # All citations               │ (rendered chapters)
├── styles.css              # Site styling               ─┘
│
├── data/                   # INPUTS (raw + a few derived counts)
│   ├── 0_literature_screening/          # combined records, PRISMA counts
│   ├── 1_effect_size_calculation_pipeline/  # extraction spreadsheet
│   ├── 2_phylogeny/                     # species counts (written by stage-2 script)
│   └── original_meta_analyses_datasets/ # Davies 2020 & Jones/DuVal 2019 (shared raw input)
│
├── scripts/                # ANALYSIS CODE (incl. literate .qmd chapters)
│   ├── 0_literature_screening/          # dedup, PRISMA diagram, screening chapter
│   ├── 1_effect_size_calculation_pipeline/  # effect sizes (.py) + analysis chapters (.qmd)
│   └── 2_phylogeny/                     # phylogeny build (R) + README
│
├── builds/                 # INTERMEDIATE artifacts
│   └── 0_literature_screening/          # reviewer split CSVs, PRISMA flow diagram
│
├── outputs/                # FINAL artifacts
│   ├── 1_effect_size_calculation_pipeline/  # included/excluded study LaTeX tables
│   └── 2_phylogeny/                     # trees, phylo correlation matrices, figures
│
├── docs/                   # Rendered Quarto site (GitHub Pages) — generated, do not edit
├── _freeze/                # Quarto freeze cache — generated
└── archive/                # Retired / superseded files (kept for provenance)
```

## Pipeline stages

| Stage | Code | Inputs | Outputs |
|-------|------|--------|---------|
| **0 — Literature screening** | `scripts/0_literature_screening/` (`1_deduplicate_records.R`, `2_prisma_flowdiagram.R`, `literature_screening.qmd`) | `data/0_literature_screening/` | reviewer splits + PRISMA diagram in `builds/0_literature_screening/` |
| **1 — Effect size calculation** | `scripts/1_effect_size_calculation_pipeline/` (`calculate_effect_sizes.py`, `overall_effect.qmd`, `publication_bias.qmd`) | `data/1_effect_size_calculation_pipeline/`, `data/original_meta_analyses_datasets/` | study tables in `outputs/1_effect_size_calculation_pipeline/` |
| **2 — Phylogeny** | `scripts/2_phylogeny/build_phylogeny.R` | `data/original_meta_analyses_datasets/`, `data/1_...` | trees + correlation matrices in `outputs/2_phylogeny/`, counts in `data/2_phylogeny/` |

## Reproducing

The book is a Quarto project. Paths in scripts resolve from the project root
(`execute-dir: project`); R scripts also use `here::here()`. To rebuild the site:

```bash
quarto render          # rebuilds docs/ (uses _freeze cache where unchanged)
```

R dependencies are managed at runtime via `pacman::p_load()` / `p_load_gh()`.
The Python effect-size pipeline (`calculate_effect_sizes.py`) writes back into the
extraction spreadsheet and is run manually, separate from the book render.
