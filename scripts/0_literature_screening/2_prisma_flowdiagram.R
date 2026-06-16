# =============================================================================
# PRISMA 2020 flow diagram  —  reproducible build
# Mate-choice copying meta-analysis (update)
#
# Reproduces the flow diagram previously drawn in the PRISMA shiny app
# (https://estech.shinyapps.io/prisma_flowdiagram/) using the underlying
# {PRISMA2020} R package, so the figure is fully version-controlled and
# regenerated from a single CSV of numbers.
#
# Input : data/0_literature_screening/prisma_flowdiagram_data.csv
# Output: builds/0_literature_screening/prisma_flowdiagram.{pdf,png,svg}
#
# Run from the project root (the .Rproj directory), e.g.
#   Rscript scripts/0_literature_screening/2_prisma_flowdiagram.R
# =============================================================================

rm(list = ls())

# --- 0. Dependencies ---------------------------------------------------------
# {PRISMA2020} draws the diagram; {DiagrammeRsvg}/{rsvg}/{xml2}/{stringr}
# are used by the pandoc-free exporter below to turn the htmlwidget into
# vector (PDF/SVG) and raster (PNG) files.
pkgs <- c("PRISMA2020", "DiagrammeR", "DiagrammeRsvg", "rsvg",
          "htmlwidgets", "xml2", "stringr")
to_install <- pkgs[!vapply(pkgs, requireNamespace, logical(1), quietly = TRUE)]
if (length(to_install) > 0) {
  install.packages(to_install, repos = "https://cloud.r-project.org")
}

library(PRISMA2020)

# --- 1. Paths ----------------------------------------------------------------
data_csv <- "data/0_literature_screening/prisma_flowdiagram_data.csv"
out_dir  <- "builds/0_literature_screening"
if (!dir.exists(out_dir)) dir.create(out_dir, recursive = TRUE)

stopifnot(file.exists(data_csv))

# --- 2. Read the numbers -----------------------------------------------------
# The CSV follows the {PRISMA2020} template exactly. Every count lives in the
# `n` column; `NA` in that column suppresses a box/line (this is how the
# "Registers", "reports", and "other methods" lines are hidden here).
prisma_raw <- read.csv(data_csv, stringsAsFactors = FALSE)
prisma     <- PRISMA_data(prisma_raw)

# --- 3. Build the diagram ----------------------------------------------------
# Layout matches the reference figure:
#   previous = TRUE   -> left "Previous studies" column
#                        (Jones & DuVal 2019 = 40; Davies et al. 2020 = 58)
#   other    = FALSE  -> no "other methods" column (no websites/citations)
#   side_boxes = TRUE, Helvetica 12 (shiny defaults)
# NOTE: detail_databases / detail_registers / meta_analysis are only available
#       in the GitHub build of {PRISMA2020}; they are omitted here so the
#       script runs against the CRAN release (1.1.1).
plot <- PRISMA_flowdiagram(
  prisma,
  interactive = FALSE,
  previous    = TRUE,
  other       = FALSE,
  side_boxes  = TRUE,
  fontsize    = 12,
  font        = "Helvetica"
)

# --- 4. Save (pandoc-free) ---------------------------------------------------
# PRISMA_save() routes through htmlwidgets::saveWidget(selfcontained = TRUE),
# which requires a system pandoc install. To keep this script runnable from a
# bare `Rscript` call, we reproduce the package's SVG export (PRISMA_gen_tmp_svg_)
# but with selfcontained = FALSE, then rasterise/vectorise with {rsvg}.
# The extra work re-injects the rotated side-box labels (Identification /
# Screening / Included), exactly as the package does.
prisma_export_svg <- function(obj, drop_total_reports = TRUE) {
  tmp_html <- tempfile(fileext = ".html")
  # selfcontained = FALSE avoids the pandoc dependency
  htmlwidgets::saveWidget(obj, file = tmp_html, selfcontained = FALSE)
  htmldata <- xml2::read_html(tmp_html)
  js <- xml2::xml_text(
    xml2::xml_find_first(
      htmldata,
      '//div[contains(@class, "grViz")]//following-sibling::script'
    )
  )
  svg <- xml2::read_xml(DiagrammeRsvg::export_svg(obj))
  # re-inject the rotated side-box label text from the widget's JS nodeMap
  nodemap <- stringr::str_match(js, "const nodeMap = new Map\\(\\[(.*)\\]\\);")[1, 2]
  if (!is.na(nodemap)) {
    jsnode <- stringr::str_split(
      stringr::str_remove_all(nodemap, "\\[|\"|]"), ",\\s", simplify = TRUE
    )
    for (i in seq_len(length(jsnode))) {
      matsp <- stringr::str_split_fixed(jsnode[i], ",", 2)
      ns <- xml2::xml_ns(svg)
      node <- xml2::xml_find_first(
        svg, paste0('//d1:g[@id="', matsp[, 1], '"]//d1:text'), ns
      )
      ax <- xml2::xml_attr(node, "x")
      ay <- xml2::xml_attr(node, "y")
      xml2::xml_attr(node, "x") <- as.double(ay) * -1
      xml2::xml_attr(node, "y") <- as.double(ax) + 2
      xml2::xml_attr(node, "transform") <- "rotate(-90)"
      xml2::xml_text(node) <- matsp[, 2]
    }
  }
  # ---- drop the "Reports of total included studies (n = NA)" line ----------
  # The CRAN build always renders this second line in the final grey box and
  # offers no switch to disable it. We remove it from the SVG and re-centre the
  # remaining "Total studies included in review (n = ...)" text in the (unchanged)
  # box. Set drop_total_reports = FALSE to keep the package's default behaviour.
  if (isTRUE(drop_total_reports)) {
    ns <- xml2::xml_ns(svg)
    rep_node <- xml2::xml_find_first(
      svg,
      '//d1:text[normalize-space(.)="Reports of total included studies"]',
      ns
    )
    if (!is.na(rep_node)) {
      g     <- xml2::xml_parent(rep_node)
      texts <- xml2::xml_find_all(g, "./d1:text", ns)
      ys    <- as.numeric(xml2::xml_attr(texts, "y"))
      spacing <- if (length(ys) >= 2) min(diff(sort(ys))) else 0
      cutoff  <- as.numeric(xml2::xml_attr(rep_node, "y")) - 1e-6
      drop <- texts[ys >= cutoff]    # "Reports of..." line + its "(n = NA)" line
      keep <- texts[ys <  cutoff]    # the "Total studies ..." lines we retain
      for (k in keep) {              # shift kept lines down to re-centre
        xml2::xml_attr(k, "y") <-
          as.character(as.numeric(xml2::xml_attr(k, "y")) +
                         spacing * (length(drop) / 2))
      }
      for (d in drop) xml2::xml_remove(d)
    }
  }
  tmp_svg <- tempfile(fileext = ".svg")
  xml2::write_xml(svg, file = tmp_svg)
  tmp_svg
}

svg_file <- prisma_export_svg(plot)
file.copy(svg_file, file.path(out_dir, "prisma_flowdiagram.svg"), overwrite = TRUE)
rsvg::rsvg_pdf(svg_file, file.path(out_dir, "prisma_flowdiagram.pdf"))
rsvg::rsvg_png(svg_file, file.path(out_dir, "prisma_flowdiagram.png"))
invisible(file.remove(svg_file))

message("PRISMA flow diagram written to ", normalizePath(out_dir))
