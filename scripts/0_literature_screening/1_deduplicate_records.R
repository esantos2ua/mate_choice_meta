# February, 2026
#
#
#
#
#

rm(list = ls())

library("dplyr")
library("data.table")
library("crayon")
library("stringr")
library("readr")

#' [Rayyan estimated 17,812 records have duplicates]
articles <- fread("data/0_literature_screening/combined_records_final.csv")

articles


# 1. Convert title to lowercase -------------------------------------------

# Let's do this more carefully. Not going to use synthesisr
articles[, title_lwr := str_to_lower(title)]
head(unique(articles$title_lwr))
articles[, title_lwr := gsub("[[:punct:]]", " ", title_lwr)]

# remove double spaces:
articles[, title_lwr := gsub(" {2,}", " ", title_lwr)]
articles[, title_lwr := trimws(title_lwr)]
length(unique(articles$title_lwr))
articles[, n_title_matches := .N, by = title_lwr]
articles[n_title_matches > 1, ]

articles[duplicated(title_lwr)]

# Tag whether important fields are populated ------------------------
# And sort as a numeric column (so we can select the highest ranked of duplicate records)
articles[is.na(abstract)]
articles[is.na(authors)]
articles[is.na(doi)]
articles[doi == "", ]

articles[, has_abstract := ifelse(abstract == "" | is.na(abstract), 0, 1)]
articles[, has_authors := ifelse(authors == "" | is.na(authors), 0, 1)]
articles[, has_doi := ifelse(doi == "" | is.na(doi), 0, 1)]

articles[, quality := has_abstract + has_authors + has_doi]
articles
setorder(articles, title_lwr)
head(unique(articles$title_lwr))


# I wanted to do this in a more clever one-line way but I couldn't figure it ou...
# Concatenate source files by title_lwr
sources <- articles[, .(source_file = paste(sort(unique(source_file)), collapse = "; ")),
                    by = .(title_lwr)]
sources

# Select highest quality:
articles.title.dedupe <- articles[, .SD[which.max(quality), !c("source_file"), with = F], 
                                  by = .(title_lwr)]
nrow(articles.title.dedupe) < nrow(articles)
nrow(articles)

# Merge concatenated sources into de-duplicated dataset
articles.title.dedupe.mrg <- merge(articles.title.dedupe,
                                   sources,
                                   by = "title_lwr",
                                   all.x = T)
articles.title.dedupe.mrg[is.na(source_file), ]
nrow(articles.title.dedupe.mrg) == nrow(articles.title.dedupe)
# Must be TRUE

articles.title.dedupe.mrg[duplicated(title_lwr), ]

# >>> DOI duplicates ------------------------------------------------------------

articles.title.dedupe.mrg$doi
articles.title.dedupe.mrg[grepl("http", doi), ]
articles.title.dedupe.mrg[doi != "" & !is.na(doi), n_doi_matches := .N, by = .(doi)]
articles.title.dedupe.mrg

articles.title.dedupe.mrg[, has_abstract := ifelse(abstract == "" | is.na(abstract), 0, 1)]
articles.title.dedupe.mrg[, has_authors := ifelse(authors == "" | is.na(authors), 0, 1)]
articles.title.dedupe.mrg[, has_doi := ifelse(doi == "" | is.na(doi), 0, 1)]

articles.title.dedupe.mrg[, quality := has_abstract + has_authors + has_doi]
articles.title.dedupe.mrg


# Concatenate source files by doi
split_conc <- function(x){
  str_split(x, pattern = "; ") |>
    unlist() |>
    unique() |>
    sort() |>
    paste(collapse = "; ")
}
# Test:
split_conc(c("SCO_04_DaviesEtAlOriginalRayyanFormatted.csv; WoS_01_JonesDuvalOriginalRayyanFormatted.csv", 
             "TEST_SCO_04_DaviesEtAlOriginalRayyanFormatted.csv; WoS_01_JonesDuvalOriginalRayyanFormatted.csv"))

#
sources <- articles.title.dedupe.mrg[, .(source_file = split_conc(source_file)),
                    by = .(doi)]
sources

# Select highest quality:
articles.doi.dedupe <- articles.title.dedupe.mrg[, .SD[which.max(quality), !c("source_file"), with = F], 
                                            by = .(doi)]
nrow(articles.doi.dedupe) < nrow(articles)
nrow(articles)
nrow(articles.doi.dedupe)


# Merge concatenated sources into de-duplicated dataset
articles.final <- merge(articles.doi.dedupe,
                                   sources,
                                   by = "doi",
                                   all.x = T)
nrow(articles.final) == nrow(articles.doi.dedupe)
#' [Must be TRUE]

articles.final[is.na(source_file)]


# Clean -------------------------------------------------------------------
# Paste source file into abstract
articles.final[, abstract := paste0(abstract, " | ", source_file)]

articles.final <- articles.final[, !c("title_lwr", "n_title_matches", "has_abstract",
                                      "has_authors", "has_doi", "quality", "n_doi_matches",
                                      "source_file")]

articles.final

# Filtering only articles >= 2019, which is what we need to screen:
articles.final <- articles.final[year >= 2019, ]


# Split by screener ----------------------------------------------------------------
screeners <- c("Aleksandra", "Aneta", "Anna", "Ayumi", "Cassidy", "Christine",
                               "Erick", "Iwo", "Hao", "Jimuel", "Kyle", "Marija", "Santiago",
                               "Sergio", "Shinichi", "Losia", "Eduardo")
length(screeners)

# Separate primary team from checkers (Losia & Eduardo)
primary_list <- setdiff(screeners, c("Eduardo", "Losia"))
secondary_list <- c("Eduardo", "Losia")

# Shuffle dataset:
articles.final <- articles.final[sample(.N), ]
articles.final

# Dynamic assignment:
n_total <- nrow(articles.final)

# Function to create vector that fits the dataset
create_assignments <- function(names, total_rows) { 
  reps_needed <- ceiling(total_rows / length(names))
  
  full_vector <- rep(names, each = reps_needed)
  return(full_vector[1:total_rows])
  }

#assignments <- lapply(screeners, function(x) rep(x, 73)) |> unlist()
#length(assignments)
#nrow(articles.final)

#articles.final[, screener := assignments[1:nrow(articles.final)] ]
# Assign to primary team:
articles.final[, primary_screener := create_assignments(primary_list, n_total)]

# Assign to Eduardo and Losia:
articles.final[, secondary_screener := create_assignments(secondary_list, n_total)]

articles.final[is.na(primary_screener), ]
articles.final[, .(n = .N), by = .(primary_screener)]

articles.final[is.na(secondary_screener), ]
articles.final[, .(n = .N), by = .(secondary_screener)]

message("Earliest year in dataset: ", min(articles.final$year))

# Save person-specific file ----------------------------------------------------------------

invisible(lapply(articles.final$primary_screener,
              function(x) write_csv(articles.final[primary_screener == x, ], paste0("builds/0_literature_screening/deduplicated_and_randomly_split/", x, ".csv"))))


