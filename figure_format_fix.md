# Figure format fix — all 16 figures as vector PDF

Applied 2026-08-06. Biology Open accepts **only EPS, PDF or SVG** for graphs and line art, and warns that raster formats "may delay production". Every figure in this paper is line art (orchard plots, funnel plots, forest plots, a phylogeny, a flow diagram), so all of them should be PDF.

## The two problems

**1. The two orchard comparison figures were never saved as PDF.** They are knitr chunk output — hence the `-1.png` filenames — rather than `ggsave` deliverables like every other figure. The manuscript included the raster versions:

```
figures/correction_comparison_or-1.png
figures/correction_comparison_hedges-1.png
```

**2. Two PDFs were silently stale** while their PNG twins were current: `loo_study_or.pdf` (six weeks old) and `sensitivity_contentious_or.pdf`. All four save helpers wrapped `ggsave` in `tryCatch(..., error = function(e) warning(...))`, so a failed write produced a warning that scrolled past in a long render and left the old file in place.

## What changed in the code

**`overall_effect.qmd`** — new `save_deliverable_fig()` helper plus two calls:

```r
save_deliverable_fig(fig_hedges, "correction_comparison_hedges", width = 9, height = 12)
save_deliverable_fig(fig_or,     "correction_comparison_or",     width = 9, height = 12)
```

It writes PDF and PNG, then **verifies both files exist and were actually rewritten**, raising an error if not.

**All four existing helpers** — `save_sens_fig`, `save_loo_fig` (`sensitivity_analysis.qmd`), `save_taxon_fig` (`overall_effect.qmd`), `save_mod_fig` (`moderator_analysis.qmd`) — now `stop()` instead of `warning()` on a failed write, and each performs the same staleness check afterwards.

⚠️ **This changes render behaviour by design.** If a figure file is locked — most often because the PDF is open in a viewer — the render will now **fail loudly** instead of quietly leaving a stale file. That is the point: a six-week-old figure reaching a journal is a worse outcome than a failed render. Close any open PDF viewers before rendering.

## What to run

```bash
git add -A && git commit -m "Export orchard figures as PDF; make figure saves fail loudly"
quarto render 2>&1 | tee render.log
```

Then confirm all sixteen are current:

```bash
ls -l outputs/1_effect_size_calculation_pipeline/*.pdf outputs/2_phylogeny/*.pdf
grep -i "stale or missing figure\|could not save" render.log   # expect no matches
```

The two new files will be `correction_comparison_hedges.pdf` and `correction_comparison_or.pdf` — note **no `-1` suffix**, since they no longer come from knitr.

## Then edit `main.tex` — two lines

**Line 312**
```latex
\includegraphics[width=5in]{figures/correction_comparison_or-1.png}
```
→
```latex
\includegraphics[width=5in]{figures/correction_comparison_or.pdf}
```

**Line 320**
```latex
\includegraphics[width=5in]{figures/correction_comparison_hedges-1.png}
```
→
```latex
\includegraphics[width=5in]{figures/correction_comparison_hedges.pdf}
```

After this every `\includegraphics` in both `main.tex` and `supplementary_information.tex` points at a `.pdf`. Worth confirming:

```bash
grep -o "figures/[a-z_0-9-]*\.[a-z]*" main.tex supplementary_information.tex | sort -u
```

Nothing should end in `.png`.

## Files to re-upload to Overleaf `figures/`

All sixteen, since a full render regenerates them:

| | |
|---|---|
| **Main article (7)** | `prisma_flowdiagram.pdf`, `phylogeny_new_extraction.pdf`, `correction_comparison_or.pdf` ⟵ new, `correction_comparison_hedges.pdf` ⟵ new, `taxon_moderator_orchard.pdf`, `dashboard_eggers_timelag_or.pdf`, `dashboard_eggers_timelag_hedges.pdf` |
| **Supplement (9)** | `phylogeny_combined.pdf`, `funnel_hedges.pdf`, `funnel_or.pdf`, `loo_study_hedges.pdf`, `loo_study_or.pdf`, `loo_species_hedges.pdf`, `loo_species_or.pdf`, `sensitivity_contentious_hedges.pdf`, `sensitivity_contentious_or.pdf` |

⚠️ **Delete the two old `-1.png` files from Overleaf** once the PDFs are in, so a stale raster cannot be picked up by a typo.

## Two things to check in the new PDFs

- **File size.** The orchard comparison figures are three stacked panels with every raw effect size plotted; as vector PDFs they may be large. If either exceeds a few MB, the supplement's 50 MB cap is still safe but the main submission PDF will be heavy. `qpdf --linearize` or reducing point transparency would help if so.
- **Fonts.** BiO asks for Arial or Helvetica in figures and for text saved as text, not outlines. `ggsave` embeds whatever the ggplot theme uses — likely the R default sans, which maps to Helvetica in PDF. Worth a glance at one figure's properties, but this is a revision-stage concern, not a first-submission blocker.
