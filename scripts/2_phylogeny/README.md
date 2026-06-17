# Phylogeny construction for the MCC meta-analysis

Builds two species phylogenies with [`prepR4pcm`](https://itchyshin.github.io/prepR4pcm/)
+ the Open Tree of Life (`rotl`) backend, each annotated with the number of
effect sizes per tip, plus the phylogenetic correlation matrices used as a
**phylogenetic random effect** in the `metafor::rma.mv()` models.

## Files

- `build_phylogeny.R` — the full pipeline (run locally; needs internet for `rotl`/`taxadb`).
- `../../data/2_phylogeny/new_extraction_species_counts.csv` — verified counts, new extraction.
- `../../data/2_phylogeny/combined_species_counts.csv` — verified counts, combined.
- `../../outputs/2_phylogeny/` — trees (`.tre`), tip-annotated plots (**both `.pdf` and `.png`**), and `phylo_cor_*.rds` matrices (written when the R script runs).
- `../../outputs/2_phylogeny/preview_*.png` — schematic previews (see caveat below).

## The two trees

1. **New extraction only** — 15 species, 69 effect sizes. Species from the
   Santos extraction that pass the `overall_effect.qmd` filters.
2. **Combined** — 33 species, 399 effect sizes (227 Hedges' *g* + 172 log OR).
   Union of species across the three datasets feeding the combined models:
   new extraction + Davies et al. 2020 (Hedges) + Jones & DuVal 2019 (log OR).

## Filters (identical to `overall_effect.qmd`)

- **New extraction:** drop `RemoveFromDataset == "Yes"`; keep rows with a
  non-missing Hedges' *d* (+ variance) and/or a non-missing odds ratio
  (+ variance). `log(OR)` requires `OR > 0`. Every retained row carries both a
  Hedges' *d* and a log OR (two representations of the same comparison), so per
  species the number of effect sizes equals the number of retained rows.
- **Davies 2020 (Hedges):** non-missing `Hedges_d_directional`, `Variance > 0`.
- **Jones & DuVal 2019 (log OR):** non-missing `lnOR`, `VlnOR > 0`.

## Silhouettes (PhyloPic)

Each tip carries a species silhouette fetched from [PhyloPic](https://www.phylopic.org/)
via [`rphylopic`](https://rphylopic.palaeoverse.org/). Because several taxa are
obscure genera, `fetch_silhouette()` tries a cascade — **species → genus →
higher taxon** (the `phylopic_fallback` list) — so every tip gets a recognisable
icon even when no species-level silhouette exists. The taxon actually used (and
its uuid) is written to `outputs/2_phylogeny/silhouette_sources.csv` for the
figure credit line (PhyloPic silhouettes require attribution).

- Set `add_silhouettes <- FALSE` near the top of the script to skip icons (e.g. offline).
- Icon/label spacing is controlled by `x_icon`, `x_name`, `height` in
  `plot_tree_with_counts()` — nudge these if a wide silhouette crowds a name.

## Tip counts

Each tip shows two numbers: **effect sizes (`k`, red)** and **studies (blue)**.

- New-extraction tree: `n_effect_sizes` (distinct comparisons / rows per species)
  and `n_studies` (distinct `identifierStudyId`).
- Combined tree: `n_total_es = n_hedges_es + n_or_es`, matching the qmd
  composition table (the new extraction contributes to both the Hedges and OR
  datasets and is therefore counted in each, exactly as in the qmd); `n_studies`
  is the distinct studies pooled across all three sources (study ids namespaced
  per source so identical ids in different datasets aren't collapsed).

## Species-name reconciliation to full binomials

A phylogeny needs full binomials, but the source files are inconsistent:

- New extraction stores full binomials; the subspecies
  *Taeniopygia guttata castanotis* is collapsed to **Taeniopygia guttata**.
- Davies stores full binomials, except **Schizocosa** (genus only) — assumed
  **Schizocosa ocreata** (matches the Jones *Lycosidae / ocreata* record).
  ⚠️ *Verify against the Davies source.*
- Jones & DuVal stores **only the epithet**; full binomials are rebuilt from
  `Family + epithet` (mapping table in the script). One needs checking:
  **Pomacentridae / leucogaster → *Amblyglyphidodon leucogaster*** ⚠️ *verify*.
  (`minutu` is a truncated `minutus` → *Pomatoschistus minutus*.)

Open Tree of Life also returns some species under their current accepted name.
**Uca mjoebergi** comes back as **Austruca mjoebergi** (the genus *Uca* was
split); the script relabels that tip back to *Uca mjoebergi* (the `otl_synonyms`
vector) so the tip, its counts, and the model grouping all agree. Add to that
vector if a future Open Tree of Life query renames another species.

> Note: `overall_effect.qmd` currently groups the species random effect by the
> **epithet only** (and for Jones, the bare epithet). To use the tree as a
> phylogenetic random effect, the model's grouping variable must instead use the
> **full binomial** that matches the tree tip labels. The bottom of
> `build_phylogeny.R` shows the `R = list(species_phylo = phylo_cor)` template.

## Pipeline (Cinar et al. 2022 recipe, via prepR4pcm)

`pr_get_tree(source = "rotl", resolve_polytomies = TRUE, branch_lengths = "grafen")`
→ strip `_ottNNNN` suffixes → `reconcile_tree()` / `reconcile_augment()` (grafts
any species Open Tree of Life can't place next to a congener, recorded in
`$augmented` — run a with/without-graft sensitivity check) → `pr_phylo_cor()`.

## ⚠️ Preview caveat

`preview_*.png` were drawn from established higher-level relationships for an
immediate look. **The definitive, citable topology is the one produced by
`build_phylogeny.R` from the Open Tree of Life** — use that for the manuscript
and for the correlation matrices.
