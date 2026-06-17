# =============================================================================
# build_phylogeny.R
# -----------------------------------------------------------------------------
# Build the species phylogenies for the Mate-Choice Copying (MCC) meta-analysis
# using prepR4pcm (Nakagawa et al. 2026) + the Open Tree of Life (rotl) backend.
#
# Produces TWO trees, each annotated with the number of effect sizes per tip:
#   (1) NEW EXTRACTION ONLY  — species in the Santos extraction that pass the
#                              same filters as overall_effect.qmd (15 species).
#   (2) COMBINED             — union of species across the three datasets used
#                              in the combined meta-analytic models:
#                              New extraction + Davies et al. 2020 (Hedges' g)
#                              + Jones & DuVal 2019 (log OR) (33 species).
#
# For each tree we also build the phylogenetic correlation matrix
# (pr_phylo_cor / ape::vcv(corr = TRUE)) so the tree can be dropped straight
# into metafor::rma.mv() as a phylogenetic random effect:
#       random = list(~1 | species_phylo, ...),
#       R      = list(species_phylo = phylo_cor)
#
# Recipe follows the prepR4pcm "Phylogenetic meta-analysis with rotl" vignette
# (Cinar et al. 2022, MEE 13:383): rotl topology -> resolve polytomies at random
# -> Grafen (1989) branch lengths -> correlation matrix.
#
# NOTE: rotl/taxadb need internet access. Run locally (R is not in the Cowork
# sandbox). Outputs are written to outputs/2_phylogeny/ and data/2_phylogeny/.
# =============================================================================

# ---- 0. Dependencies --------------------------------------------------------
if (is.null(getOption("repos")) || getOption("repos")["CRAN"] %in% c(NA, "@CRAN@")) {
  options(repos = c(CRAN = "https://cloud.r-project.org"))
}
if (!requireNamespace("pacman", quietly = TRUE)) install.packages("pacman")
# prepR4pcm is on CRAN; fall back to GitHub dev version if needed.
if (!requireNamespace("prepR4pcm", quietly = TRUE)) {
  tryCatch(install.packages("prepR4pcm"),
           error = function(e) pacman::p_load_gh("itchyshin/prepR4pcm"))
}
pacman::p_load(prepR4pcm, rotl, ape, metafor, readxl, readr, dplyr, stringr, here, rphylopic)

# Set add_silhouettes <- FALSE to skip PhyloPic icons (e.g. if offline).
add_silhouettes <- TRUE

dir_out  <- here::here("outputs", "2_phylogeny")
dir_data <- here::here("data", "2_phylogeny")
dir.create(dir_out,  recursive = TRUE, showWarnings = FALSE)
dir.create(dir_data, recursive = TRUE, showWarnings = FALSE)

# =============================================================================
# 1. LOAD DATA AND APPLY THE SAME FILTERS AS overall_effect.qmd
# =============================================================================
path_new    <- here::here("data", "1_effect_size_calculation_pipeline",
                          "Data Extraction Mate Choice Meta Analysis.xlsx")
path_davies <- here::here("data", "original_meta_analyses_datasets",
                          "Davies_et_al_2020_Final_data.xlsx")
path_jones  <- here::here("data", "original_meta_analyses_datasets",
                          "Jones_DuVal_2019_data.CSV")

# --- 1a. New extraction (Santos) --------------------------------------------
# Filter identical to overall_effect.qmd: drop RemoveFromDataset == "Yes",
# then require a non-missing Hedges' d (+ variance) and/or a non-missing
# log odds ratio (+ variance). log(OR) is only defined for OR > 0.
db_new <- readxl::read_excel(path_new, sheet = "EduardoExtraction") %>%
  filter(is.na(RemoveFromDataset) | RemoveFromDataset != "Yes") %>%
  mutate(
    effectSizeCalculatedHedgesD         = as.numeric(effectSizeCalculatedHedgesD),
    effectSizeCalculatedHedgesDVariance = as.numeric(effectSizeCalculatedHedgesDVariance),
    effectSizeCalculatedOddsRatio       = as.numeric(effectSizeCalculatedOddsRatio),
    effectSizeCalculatedOddsRatioVariance = as.numeric(effectSizeCalculatedOddsRatioVariance),
    has_hedges = !is.na(effectSizeCalculatedHedgesD) & !is.na(effectSizeCalculatedHedgesDVariance),
    has_or     = !is.na(effectSizeCalculatedOddsRatio) & effectSizeCalculatedOddsRatio > 0 &
                 !is.na(effectSizeCalculatedOddsRatioVariance),
    species    = str_squish(as.character(taxonomySpecies))
  ) %>%
  filter(has_hedges | has_or)

# --- 1b. Davies et al. 2020 (continuous / Hedges' g) ------------------------
db_davies <- readxl::read_excel(path_davies, sheet = "Data") %>%
  mutate(Hedges_d_directional = as.numeric(Hedges_d_directional),
         Variance             = as.numeric(Variance)) %>%
  filter(!is.na(Hedges_d_directional), !is.na(Variance), Variance > 0) %>%
  mutate(species = str_squish(as.character(Species_latin)))

# --- 1c. Jones & DuVal 2019 (binary / log OR) -------------------------------
# The source file stores only the species EPITHET. We rebuild full binomials
# from the Family + epithet (see mapping below).
db_jones <- readr::read_csv(path_jones, show_col_types = FALSE) %>%
  filter(!is.na(lnOR), !is.na(VlnOR), VlnOR > 0) %>%
  mutate(epithet = str_squish(as.character(Species)),
         family  = str_squish(as.character(Family)))

# =============================================================================
# 2. SPECIES-NAME RECONCILIATION TO FULL BINOMIALS
# =============================================================================
# (i) New extraction subspecies -> species for tree matching.
recode_new <- c("Taeniopygia guttata castanotis" = "Taeniopygia guttata")

# (ii) Davies genus-only entry. "Schizocosa" is recorded at genus level only;
#      the matching Jones record (Lycosidae, ocreata) is Schizocosa ocreata, so
#      we assume the same species. *** VERIFY against the Davies source. ***
recode_davies <- c("Schizocosa" = "Schizocosa ocreata")

# (iii) Jones epithet (+Family) -> full binomial. All cross-checked against the
#       full binomials present in the new extraction / Davies, except where noted.
jones_binomial <- tibble::tribble(
  ~family,            ~epithet,        ~species,
  "Adrianichthyidae", "latipes",       "Oryzias latipes",
  "Blenniidae",       "nitidus",       "Rhabdoblennius nitidus",
  "Gasterosteidae",   "aculeatus",     "Gasterosteus aculeatus",
  "Gobiidae",         "minutu",        "Pomatoschistus minutus",   # epithet truncated in source
  "Percidae",         "olmstedi",      "Etheostoma olmstedi",
  "Poeciliidae",      "latipinna",     "Poecilia latipinna",
  "Poeciliidae",      "nigrofasciata", "Limia nigrofasciata",
  "Poeciliidae",      "perugiae",      "Limia perugiae",
  "Poeciliidae",      "reticulata",    "Poecilia reticulata",
  "Pomacentridae",    "leucogaster",   "Amblyglyphidodon leucogaster", # *** VERIFY ***
  "Lycosidae",        "ocreata",       "Schizocosa ocreata",
  "Estrildidae",      "guttata",       "Taeniopygia guttata",
  "Icteridae",        "ater",          "Molothrus ater",
  "Muscicapidae",     "hypoleuca",     "Ficedula hypoleuca",
  "Drosophilidae",    "melanogaster",  "Drosophila melanogaster",
  "Drosophilidae",    "serrata",       "Drosophila serrata",
  "Ocypodidae",       "mjoebergi",     "Uca mjoebergi"
)

db_new    <- db_new    %>% mutate(species = recode(species, !!!recode_new))
db_davies <- db_davies %>% mutate(species = recode(species, !!!recode_davies))
db_jones  <- db_jones  %>% left_join(jones_binomial, by = c("family", "epithet"))
if (any(is.na(db_jones$species)))
  warning("Unmapped Jones epithets: ",
          paste(unique(db_jones$epithet[is.na(db_jones$species)]), collapse = ", "))

# =============================================================================
# 3. PER-SPECIES EFFECT-SIZE COUNTS
# =============================================================================
# New extraction: every retained row carries BOTH a Hedges' d and a log OR
# (two representations of the same comparison), so the number of distinct
# effect sizes per species == the number of retained rows.
counts_new <- db_new %>%
  group_by(species) %>%
  summarise(n_hedges_es   = sum(has_hedges),
            n_or_es        = sum(has_or),
            n_effect_sizes = n(),                              # distinct comparisons (rows)
            n_studies      = n_distinct(identifierStudyId),    # distinct studies
            .groups = "drop") %>%
  arrange(desc(n_effect_sizes))

# Combined: count Hedges' g effect sizes and log OR effect sizes separately
# (as in the qmd composition table) and sum them per species.
hedges_es <- bind_rows(
  db_new    %>% filter(has_hedges) %>% transmute(species),
  db_davies %>% transmute(species)
) %>% count(species, name = "n_hedges_es")

or_es <- bind_rows(
  db_new   %>% filter(has_or) %>% transmute(species),
  db_jones %>% transmute(species)
) %>% count(species, name = "n_or_es")

# Distinct studies per species, pooled across all three sources. Study ids are
# namespaced per source (Davies = Author, Jones = study) so identical ids in
# different datasets are not collapsed.
studies_combined <- bind_rows(
  db_new    %>% transmute(species, study = paste0("NEW:", identifierStudyId)),
  db_davies %>% transmute(species, study = paste0("DAV:", Author)),
  db_jones  %>% transmute(species, study = paste0("JON:", study))
) %>% distinct(species, study) %>% count(species, name = "n_studies")

counts_combined <- full_join(hedges_es, or_es, by = "species") %>%
  mutate(across(c(n_hedges_es, n_or_es), ~coalesce(., 0L)),
         n_total_es = n_hedges_es + n_or_es) %>%
  left_join(studies_combined, by = "species") %>%
  mutate(n_studies = coalesce(n_studies, 0L)) %>%
  arrange(desc(n_total_es))

readr::write_csv(counts_new,      file.path(dir_data, "new_extraction_species_counts.csv"))
readr::write_csv(counts_combined, file.path(dir_data, "combined_species_counts.csv"))

message(sprintf("New extraction: %d species, %d effect sizes",
                nrow(counts_new), sum(counts_new$n_effect_sizes)))
message(sprintf("Combined: %d species, %d Hedges ES + %d OR ES = %d total",
                nrow(counts_combined), sum(counts_combined$n_hedges_es),
                sum(counts_combined$n_or_es), sum(counts_combined$n_total_es)))

# =============================================================================
# 4. TREE BUILDER (rotl topology -> bifurcating -> Grafen branches)
# =============================================================================
# Open Tree of Life returns some species under their current accepted name,
# which differs from the name used in the datasets. Map the tree tip label back
# to the dataset name so tips, counts, and the model's species grouping all
# agree. (Uca mjoebergi -> Open Tree of Life "Austruca mjoebergi": genus Uca was
# split; the fiddler crab is now Austruca mjoebergi.)
otl_synonyms <- c("Austruca mjoebergi" = "Uca mjoebergi")

build_tree <- function(species_vec) {
  species_vec <- sort(unique(species_vec))
  res <- prepR4pcm::pr_get_tree(
    species_vec,
    source             = "rotl",
    resolve_polytomies = TRUE,      # ape::multi2di(random = TRUE)
    branch_lengths     = "grafen"   # ape::compute.brlen(method = "Grafen")
  )
  # Clean Open Tree of Life "_ottNNNN" id suffixes and underscores.
  res$tree$tip.label <- gsub("_ott\\d+", "", res$tree$tip.label)
  res$tree$tip.label <- gsub("_", " ", res$tree$tip.label)
  # Relabel any Open Tree of Life synonyms back to the dataset names.
  hit <- res$tree$tip.label %in% names(otl_synonyms)
  if (any(hit)) res$tree$tip.label[hit] <- otl_synonyms[res$tree$tip.label[hit]]
  res
}

# Reconcile a data frame of species against a retrieved tree, grafting any
# species Open Tree of Life could not place next to a congener (documented in
# $augmented). Returns the (possibly augmented) tree.
reconcile_and_augment <- function(res, species_vec) {
  df  <- data.frame(species = sort(unique(species_vec)), stringsAsFactors = FALSE)
  rec <- prepR4pcm::reconcile_tree(df, res$tree, x_species = "species", authority = NULL)
  print(prepR4pcm::reconcile_summary(rec))   # audit every name match
  aug <- prepR4pcm::reconcile_augment(rec, res$tree)
  aug$tree$tip.label <- gsub("_", " ", aug$tree$tip.label)
  if (!is.null(aug$augmented) && nrow(aug$augmented) > 0) {
    message("Grafted (no Open Tree of Life tip; placed near a congener):")
    print(aug$augmented[, c("species", "placed_near", "n_congeners")])
  }
  aug$tree
}

# --- PhyloPic silhouettes ----------------------------------------------------
# Many of our taxa are obscure genera with no species-level silhouette on
# PhyloPic. For each species we therefore try, in order: the species, its genus,
# then a hand-set list of higher taxa (so we still get a recognisable icon).
phylopic_fallback <- list(
  "Enchenopa binotata"           = c("Membracidae", "Hemiptera", "Insecta"),
  "Schizocosa ocreata"           = c("Lycosidae", "Araneae", "Arachnida"),
  "Uca mjoebergi"                = c("Ocypodidae", "Brachyura", "Decapoda"),
  "Amblyglyphidodon leucogaster" = c("Pomacentridae", "Actinopterygii"),
  "Porichthys notatus"           = c("Batrachoididae", "Actinopterygii"),
  "Rhabdoblennius nitidus"       = c("Blenniidae", "Actinopterygii"),
  "Pomatoschistus minutus"       = c("Gobiidae", "Actinopterygii"),
  "Brachyrhaphis rhabdophora"    = c("Poeciliidae", "Cyprinodontiformes", "Actinopterygii"),
  "Limia nigrofasciata"          = c("Poeciliidae", "Actinopterygii"),
  "Limia perugiae"               = c("Poeciliidae", "Actinopterygii"),
  "Gambusia holbrooki"           = c("Poeciliidae", "Actinopterygii"),
  "Poecilia formosa"             = c("Poeciliidae", "Actinopterygii"),
  "Poecilia mexicana"            = c("Poeciliidae", "Actinopterygii"),
  "Etheostoma flabellare"        = c("Percidae", "Actinopterygii"),
  "Etheostoma zonale"            = c("Percidae", "Actinopterygii"),
  "Etheostoma olmstedi"          = c("Percidae", "Actinopterygii"),
  "Syngnathus typhle"            = c("Syngnathidae", "Actinopterygii"),
  "Gasterosteus aculeatus"       = c("Gasterosteidae", "Actinopterygii"),
  "Oryzias latipes"              = c("Adrianichthyidae", "Actinopterygii"),
  "Coturnix japonica"            = c("Phasianidae", "Galliformes", "Aves"),
  "Molothrus ater"               = c("Icteridae", "Passeriformes", "Aves"),
  "Ficedula hypoleuca"           = c("Muscicapidae", "Passeriformes", "Aves"),
  "Taeniopygia guttata"          = c("Estrildidae", "Passeriformes", "Aves"),
  "Dama dama"                    = c("Cervidae", "Artiodactyla", "Mammalia"),
  "Drosophila subobscura"        = c("Drosophila", "Drosophilidae", "Insecta"),
  "Drosophila simulans"          = c("Drosophila", "Drosophilidae", "Insecta"),
  "Drosophila serrata"           = c("Drosophila", "Drosophilidae", "Insecta")
)

# Resolve one image (Picture/png) for a species, trying the cascade above.
# Returns NULL if nothing resolves. Memoised across both trees.
.sil_cache <- new.env(parent = emptyenv())
fetch_silhouette <- function(species) {
  if (exists(species, envir = .sil_cache)) return(get(species, envir = .sil_cache))
  genus  <- word(species, 1)
  tries  <- unique(c(species, genus, phylopic_fallback[[species]]))
  img    <- NULL
  for (nm in tries) {
    uid <- tryCatch(rphylopic::get_uuid(name = nm, n = 1), error = function(e) NA_character_)
    if (length(uid) == 1 && !is.na(uid)) {
      img <- tryCatch(rphylopic::get_phylopic(uuid = uid, format = "vector"),
                      error = function(e) tryCatch(rphylopic::get_phylopic(uuid = uid),
                                                   error = function(e2) NULL))
      if (!is.null(img)) { attr(img, "resolved_as") <- nm; attr(img, "uuid") <- uid; break }
    }
  }
  if (is.null(img)) message("  no PhyloPic silhouette for: ", species)
  assign(species, img, envir = .sil_cache)
  img
}

fetch_silhouettes <- function(species_vec) {
  if (!isTRUE(add_silhouettes)) return(NULL)
  message("Fetching PhyloPic silhouettes...")
  stats::setNames(lapply(species_vec, fetch_silhouette), species_vec)
}

# Aspect ratio (width / height) of a silhouette, for either a grImport2 Picture
# (vector) or a png array (raster). Used to standardise icon size by AREA.
sil_aspect <- function(img) {
  a <- tryCatch({
    if (methods::is(img, "Picture")) {
      abs(diff(img@summary@xscale)) / abs(diff(img@summary@yscale))
    } else if (is.array(img)) {
      d <- dim(img); d[2] / d[1]
    } else NA_real_
  }, error = function(e) NA_real_)
  if (!is.finite(a) || a <= 0) 1 else a
}

# Plot a tree with a PhyloPic silhouette at each tip, the italic species name,
# and TWO right-hand count columns (effect sizes `k` in red, studies in blue),
# mirroring the example figure. Saves both a PDF and a PNG (`file` is the .pdf).
plot_tree_with_counts <- function(tree, es_named, st_named, title, file, sil = NULL) {
  tree <- ladderize(tree)
  n    <- ape::Ntip(tree)
  es   <- es_named[tree$tip.label]; es[is.na(es)] <- 0
  st   <- st_named[tree$tip.label]; st[is.na(st)] <- 0

  render <- function() {
    # Names and counts are drawn inside the plot region (via x.lim) rather than
    # into the margin, so margins are small and symmetric to centre the figure.
    op <- par(mar = c(2, 2, 4, 2), xpd = NA)
    # Tree occupies the left third; the rest is silhouette + label + counts.
    plot.phylo(tree, show.tip.label = FALSE, no.margin = FALSE, x.lim = c(0, 3.0))
    pp   <- get("last_plot.phylo", envir = ape::.PlotPhyloEnv)
    span <- pp$x.lim[2]
    xmax <- max(pp$xx[seq_len(n)])           # x of the tips
    yy   <- pp$yy[seq_len(n)]
    x_icon <- xmax + 0.12 * span             # silhouette column (right edge)
    x_name <- xmax + 0.14 * span             # species name (left-aligned)
    x_es   <- 0.83 * span                     # effect-sizes column
    x_st   <- 0.99 * span                     # studies column

    # Silhouettes (one per tip; skipped silently where none resolved).
    # Standardise by AREA: scale height by 1/sqrt(aspect) so a long, thin
    # silhouette (e.g. Danio rerio) and a compact one (e.g. Mus musculus) take
    # up roughly the same visual area instead of the wide ones looking huge.
    # Right-justified (hjust = 1) so every icon ends at the same x, keeping a
    # constant gap to the species names regardless of silhouette width.
    sil_target_area <- 0.95                   # tune overall icon size here
    if (!is.null(sil)) {
      for (i in seq_len(n)) {
        img <- sil[[tree$tip.label[i]]]
        if (is.null(img)) next
        hh <- max(0.5, min(1.3, sil_target_area / sqrt(sil_aspect(img))))
        tryCatch(
          rphylopic::add_phylopic_base(img = img, x = x_icon, y = yy[i],
                                       height = hh, hjust = 1, fill = "black"),
          error = function(e) NULL)
      }
    }
    text(x = x_name, y = yy, labels = tree$tip.label, cex = 0.8,  font = 3, adj = 0)
    text(x = x_es,   y = yy, labels = es[tree$tip.label], cex = 0.85, font = 2, col = "#B22222", adj = 1)
    text(x = x_st,   y = yy, labels = st[tree$tip.label], cex = 0.85, font = 2, col = "#1F5C8B", adj = 1)
    text(x = x_es,   y = n + 1.2, labels = "k",       cex = 0.9, font = 4, col = "#B22222", adj = 1)
    text(x = x_st,   y = n + 1.2, labels = "studies", cex = 0.9, font = 4, col = "#1F5C8B", adj = 1)
    title(main = title, cex.main = 1.0)
    par(op)
  }

  ht <- max(4, 0.32 * n + 1.5)
  pdf(file, width = 9, height = ht);                 render(); dev.off()
  png_file <- sub("\\.pdf$", ".png", file)
  png(png_file, width = 9, height = ht, units = "in", res = 200); render(); dev.off()
  message("Saved plots: ", file, " and ", png_file)
}

# =============================================================================
# 5. BUILD, ANNOTATE, AND SAVE BOTH TREES
# =============================================================================

## ---- TREE 1: NEW EXTRACTION ONLY ------------------------------------------
res_new  <- build_tree(counts_new$species)
tree_new <- reconcile_and_augment(res_new, counts_new$species)

es_new  <- setNames(counts_new$n_effect_sizes, counts_new$species)
st_new  <- setNames(counts_new$n_studies,      counts_new$species)
sil_new <- fetch_silhouettes(tree_new$tip.label)
plot_tree_with_counts(tree_new, es_new, st_new,
                 title = "MCC phylogeny - New extraction (Santos)",
                 file  = file.path(dir_out, "phylogeny_new_extraction.pdf"),
                 sil   = sil_new)

ape::write.tree(tree_new, file.path(dir_out, "tree_new_extraction.tre"))
phylo_cor_new <- prepR4pcm::pr_phylo_cor(tree_new)
saveRDS(phylo_cor_new, file.path(dir_out, "phylo_cor_new_extraction.rds"))

## ---- TREE 2: COMBINED ------------------------------------------------------
res_comb  <- build_tree(counts_combined$species)
tree_comb <- reconcile_and_augment(res_comb, counts_combined$species)

es_comb  <- setNames(counts_combined$n_total_es, counts_combined$species)
st_comb  <- setNames(counts_combined$n_studies,  counts_combined$species)
sil_comb <- fetch_silhouettes(tree_comb$tip.label)
plot_tree_with_counts(tree_comb, es_comb, st_comb,
                 title = "MCC phylogeny - Combined (New + Davies 2020 + Jones & DuVal 2019)",
                 file  = file.path(dir_out, "phylogeny_combined.pdf"),
                 sil   = sil_comb)

# PhyloPic requires attribution. Record which silhouette was used per species
# (the resolved taxon + uuid) so the figure legend can credit the artists.
sil_credits <- dplyr::bind_rows(lapply(names(sil_comb), function(sp) {
  img <- sil_comb[[sp]]
  if (is.null(img)) return(NULL)
  data.frame(species = sp,
             resolved_as = attr(img, "resolved_as"),
             uuid = attr(img, "uuid"), stringsAsFactors = FALSE)
}))
if (nrow(sil_credits) > 0) {
  attr_tbl <- tryCatch(rphylopic::get_attribution(uuid = sil_credits$uuid),
                       error = function(e) NULL)
  readr::write_csv(sil_credits, file.path(dir_out, "silhouette_sources.csv"))
}

ape::write.tree(tree_comb, file.path(dir_out, "tree_combined.tre"))
phylo_cor_comb <- prepR4pcm::pr_phylo_cor(tree_comb)
saveRDS(phylo_cor_comb, file.path(dir_out, "phylo_cor_combined.rds"))

# Per-model correlation matrices (the combined Hedges' g and log OR models use
# different species subsets). Prune the combined tree to each model's species.
sp_hedges <- counts_combined$species[counts_combined$n_hedges_es > 0]
sp_or     <- counts_combined$species[counts_combined$n_or_es     > 0]
tree_hedges <- ape::keep.tip(tree_comb, intersect(tree_comb$tip.label, sp_hedges))
tree_or     <- ape::keep.tip(tree_comb, intersect(tree_comb$tip.label, sp_or))
saveRDS(prepR4pcm::pr_phylo_cor(tree_hedges), file.path(dir_out, "phylo_cor_hedges_model.rds"))
saveRDS(prepR4pcm::pr_phylo_cor(tree_or),     file.path(dir_out, "phylo_cor_or_model.rds"))

# Citations for the methods section (Open Tree of Life + ape, etc.).
cat(prepR4pcm::pr_cite_tree(res_comb, format = "markdown"),
    file = file.path(dir_out, "tree_citations.md"))

message("Done. Trees, plots, and phylogenetic correlation matrices written to ",
        dir_out)

# =============================================================================
# 6. HOW TO USE THE TREE AS A PHYLOGENETIC RANDOM EFFECT (template)
# =============================================================================
# The species grouping variable in your effect-size data MUST use the SAME full
# binomials as the tree tip labels (rownames of the correlation matrix). The
# current overall_effect.qmd collapses names to the epithet only; switch that
# grouping to the reconciled full binomial (the `species` column built above)
# before fitting, e.g.:
#
#   phylo_cor <- readRDS("outputs/2_phylogeny/phylo_cor_hedges_model.rds")
#   db_hedges$species_phylo <- db_hedges$species   # full binomial, matches tips
#   mod <- metafor::rma.mv(
#     yi, V = VCV,
#     random = list(~1 | identifierStudyId,
#                   ~1 | identifierEffectSizeID,
#                   ~1 | species_phylo),          # phylogenetic random effect
#     R = list(species_phylo = phylo_cor),
#     data = db_hedges, method = "REML", test = "t", sparse = TRUE)
#
# Run a sensitivity analysis with vs. without any grafted tips (see aug$augmented).
# =============================================================================
