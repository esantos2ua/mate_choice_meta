# =============================================================================
# diagnose_taxon_model.R
# -----------------------------------------------------------------------------
# Inspect the taxonomic-moderator heteroscedastic model fits and their fallback
# cascade WITHOUT re-rendering the Quarto book.
#
# It loads the bundle that overall_effect.qmd writes on render
# (outputs/1_effect_size_calculation_pipeline/taxon_model_fits.rds) and prints,
# for each effect-size class (Hedges' g and log OR):
#   * which random-effects structure was ultimately used;
#   * the full cascade log (every candidate structure, attempted / OK /
#     OK-with-warnings / ERROR, runtime, warning count, captured message);
#   * the full metafor model summary();
#   * the variance components (flagging any at/near the zero boundary);
#   * per-group sample sizes; and the omnibus QM + total I^2.
#
# USAGE (from the repo root):
#   Rscript scripts/1_effect_size_calculation_pipeline/diagnose_taxon_model.R
# or interactively:
#   source("scripts/1_effect_size_calculation_pipeline/diagnose_taxon_model.R")
#
# If the .rds does not exist yet, render overall_effect.qmd once first (the
# `fit_taxon_hetero_models` chunk writes it).
# =============================================================================

if (is.null(getOption("repos")) || getOption("repos")["CRAN"] %in% c(NA, "@CRAN@")) {
  options(repos = c(CRAN = "https://cloud.r-project.org"))
}
if (!requireNamespace("pacman", quietly = TRUE)) install.packages("pacman")
pacman::p_load(metafor, dplyr, tibble, here)

rds <- here::here("outputs", "1_effect_size_calculation_pipeline", "taxon_model_fits.rds")
if (!file.exists(rds)) {
  stop("Bundle not found:\n  ", rds,
       "\nRender scripts/1_effect_size_calculation_pipeline/overall_effect.qmd once first ",
       "(the `fit_taxon_hetero_models` chunk writes this file).")
}

bundle <- readRDS(rds)
tax_levels <- c("Arthropods", "Fish", "Other Vertebrates")

group_counts <- function(res) {
  if (is.null(res) || is.null(res$data)) return(NULL)
  res$data %>%
    dplyr::group_by(tax_group) %>%
    dplyr::summarise(
      `k (effect sizes)` = dplyr::n(),
      studies = dplyr::n_distinct(identifierStudyId),
      species = dplyr::n_distinct(taxonomySpecies),
      .groups = "drop"
    ) %>%
    dplyr::rename(`Taxonomic group` = tax_group)
}

chosen_varcomp <- function(res) {
  if (is.null(res) || is.null(res$model)) return(NULL)
  m   <- res$model
  glv <- levels(droplevels(factor(res$data$tax_group, levels = tax_levels)))
  out <- tibble::tibble(Component = character(), Variance = numeric())
  addc <- function(out, labs, vals) {
    if (is.null(vals) || length(vals) == 0) return(out)
    dplyr::bind_rows(out, tibble::tibble(Component = labs, Variance = round(as.numeric(vals), 6)))
  }
  # Structure-aware labelling (see overall_effect.qmd): metafor stores variances
  # in sigma2 / tau2 / gamma2 depending on which cascade structure was used.
  spec <- if (is.null(res$spec)) "" else res$spec
  if (grepl("between-study \\+ residual", spec)) {
    out <- addc(out, paste0("Between-study tau^2 - ", glv[seq_along(m$tau2)]),  m$tau2)
    out <- addc(out, paste0("Residual sigma^2 - ",   glv[seq_along(m$gamma2)]), m$gamma2)
    out <- addc(out, "Species sigma^2", m$sigma2)
  } else if (grepl("residual only", spec)) {
    out <- addc(out, paste0("Residual sigma^2 - ", glv[seq_along(m$tau2)]), m$tau2)
    out <- addc(out, c("Between-study tau^2", "Species sigma^2")[seq_along(m$sigma2)], m$sigma2)
  } else {
    out <- addc(out, c("Between-study tau^2", "Residual sigma^2 (effect size)", "Species sigma^2")[seq_along(m$sigma2)], m$sigma2)
  }
  out
}

report <- function(res, label, qm = NULL, i2 = NULL) {
  cat("\n############################################################\n")
  cat("##  ", label, "\n")
  cat("############################################################\n")
  if (is.null(res)) { cat("  No result object (empty data?).\n"); return(invisible()) }
  cat("Chosen structure :", res$spec, "\n")
  cat("Model fitted     :", !is.null(res$model), "\n")

  cat("\n--- Cascade log ------------------------------------------\n")
  print(as.data.frame(res$diagnostics), row.names = FALSE, right = FALSE)

  gc <- group_counts(res)
  if (!is.null(gc)) {
    cat("\n--- Per-group sample sizes -------------------------------\n")
    print(as.data.frame(gc), row.names = FALSE, right = FALSE)
  }

  vc <- chosen_varcomp(res)
  if (!is.null(vc)) {
    cat("\n--- Variance components (chosen model) -------------------\n")
    print(as.data.frame(vc), row.names = FALSE, right = FALSE)
    n_zero <- sum(vc$Variance < 1e-6, na.rm = TRUE)
    if (n_zero > 0)
      cat("NOTE:", n_zero, "variance component(s) at/near zero (boundary estimate).\n")
  }

  if (!is.null(qm) && !is.null(qm$QM))
    cat(sprintf("\nOmnibus among-group test: QM = %.3f, df = %s, p = %.4g\n",
                qm$QM, paste(qm$QMdf, collapse = ","), qm$QMp))
  if (!is.null(i2) && is.finite(i2))
    cat(sprintf("Total I^2: %.1f%%\n", i2))

  if (!is.null(res$model)) {
    cat("\n--- metafor summary() ------------------------------------\n")
    print(summary(res$model))
  }
  cat("\n")
  invisible()
}

cat("Loaded:", rds, "\n")
if (!is.null(bundle$saved_at)) cat("Saved at:", format(bundle$saved_at), "\n")

report(bundle$hedges, "Hedges' g",      qm = bundle$qm$hedges, i2 = bundle$i2$hedges)
report(bundle$or,     "Log Odds Ratio", qm = bundle$qm$or,     i2 = bundle$i2$or)
