#!/usr/bin/env python3
"""
Cross-check the two source meta-analyses we are updating
========================================================

We are building an updated mate-choice-copying meta-analysis on top of two
existing datasets:

  * Davies et al. (2020)  -- effect size: Hedges' d  (with a directional version)
  * Jones & DuVal (2019)  -- effect size: log odds ratio (lnOR)

This script answers two questions:

  1. Which studies / effect sizes appear in BOTH datasets?
  2. For the shared effect sizes, do the reported effect sizes AGREE in
     magnitude once they are placed on a common scale?

Because the two papers report different effect-size metrics, we convert the
Jones & DuVal lnOR onto the Hedges' d scale before comparing.

--------------------------------------------------------------------------
METHODOLOGY (so the matching is reproducible)
--------------------------------------------------------------------------

STEP 1 - Load both datasets.
  * Davies: sheet "Data" of the .xlsx. Key columns: Study_no, Effect_size_no,
    Author, Year, Species_latin, Hedges_d (non-directional), Total_n_analysis.
  * Jones & DuVal: the .CSV. Key columns: study (a code like "APP2000THE"),
    Exp, year, Species (epithet only, e.g. "reticulata"), lnOR, VlnOR.

STEP 2 - Effect-size conversion (lnOR -> Hedges' d).
  We use the standard logistic-to-normal approximation (Cox/Haddock;
  Borenstein et al. 2009, "Introduction to Meta-Analysis", ch. 7):

        d = lnOR * sqrt(3) / pi          ( sqrt(3)/pi ~= 0.5513 )

  This is the same conversion used to pool OR- and d-based studies in a single
  meta-analysis, so it is the appropriate scale on which to ask "do these
  agree?". It is an APPROXIMATION (it assumes an underlying logistic latent
  trait), so small disagreements can be conversion artefacts rather than true
  discrepancies.

STEP 3 - Study-level matching.
  Neither dataset shares a common study ID, so we build a key from metadata:

        key = (first-3-letters of first-author surname (upper),
               publication year)

  Davies' first-author surname comes from the first token of `Author`.
  Jones' study code already begins with the first 3 letters of the first
  author's surname (e.g. "APP2000THE" -> "APP", 2000), so the key is directly
  comparable.

  A (prefix, year) collision is then disambiguated by SPECIES:
    - we compare the species epithet (Jones stores only the epithet; for Davies
      we take the last token of Species_latin),
    - allowing for truncation/genus-only records by matching on the first 5
      characters in either direction (this is what rescues, e.g.,
      Forsgren "minutu" vs "minutus", and Fowler-Finn, where Davies recorded
      only the genus "Schizocosa").
    - If (prefix, year) maps to exactly one Davies study, we accept it even
      when the species string differs (genus-only records).

STEP 4 - Effect-size-level matching WITHIN each shared study.
  The two teams frequently extracted DIFFERENT NUMBERS of effect sizes from the
  same paper (e.g. Danchin 2018: 17 in Jones vs 2 in Davies). There is no
  shared effect-size ID, so we cannot align them 1:1 by label. Instead, within
  each shared study we solve an optimal assignment: match every effect size in
  the SMALLER set to a distinct effect size in the larger set so as to minimise
  the total absolute difference in |d|. (Sets are tiny, so we brute-force the
  optimum over permutations.) Unpaired effect sizes in the larger set are
  reported but not scored.

  We compare ABSOLUTE magnitudes (|d|) because the two datasets use opposite/
  inconsistent sign conventions for "copying vs avoidance"; sign agreement is
  reported separately as a diagnostic but is not the basis of the match.

STEP 5 - "Match in magnitude" criterion.
  A pair is counted as agreeing if
        |d_Jones - d_Davies| <= 0.15            (absolute, Hedges' d units)
     OR  |d_Jones - d_Davies| / max(...)  <= 0.15   (15% relative)
  The relative arm prevents large-but-proportionally-close effects from being
  flagged; the absolute arm handles near-zero effects. Both thresholds are
  reported so they can be tightened/loosened.

--------------------------------------------------------------------------
OUTPUTS (written to outputs/3_original_dataset_crosscheck/)
--------------------------------------------------------------------------
  crosswalk_effect_sizes.csv   one row per matched effect-size pair
  shared_studies.csv           one row per shared study (counts + species)
  unmatched_jones_studies.csv  Jones studies with NO Davies counterpart
  (a summary is also printed to stdout)
--------------------------------------------------------------------------
Usage:  python3 scripts/3_original_dataset_crosscheck/crosscheck_davies_jones.py
"""

import csv
import math
import os
from collections import defaultdict
from itertools import permutations

import openpyxl

# ----------------------------------------------------------------------
# Paths
# ----------------------------------------------------------------------
HERE = os.path.dirname(os.path.abspath(__file__))
REPO = os.path.abspath(os.path.join(HERE, "..", ".."))
DATA = os.path.join(REPO, "data", "original_meta_analyses_datasets")
DAVIES_XLSX = os.path.join(DATA, "Davies_et_al_2020_Final_data.xlsx")
JONES_CSV = os.path.join(DATA, "Jones_DuVal_2019_data.CSV")
OUTDIR = os.path.join(REPO, "outputs", "3_original_dataset_crosscheck")
os.makedirs(OUTDIR, exist_ok=True)

# Matching / agreement parameters (edit here to tighten or loosen)
LNOR_TO_D = math.sqrt(3) / math.pi   # ~= 0.5513
TOL_ABS = 0.15                       # absolute tolerance in Hedges' d
TOL_REL = 0.15                       # relative tolerance (fraction)


# ----------------------------------------------------------------------
# STEP 1 - load
# ----------------------------------------------------------------------
def load_davies():
    wb = openpyxl.load_workbook(DAVIES_XLSX, data_only=True)
    ws = wb["Data"]
    rows = list(ws.iter_rows(values_only=True))
    hdr = rows[0]
    idx = {h: i for i, h in enumerate(hdr)}
    out = []
    for r in rows[1:]:
        if r[idx["Study_no"]] is None:
            continue
        d = r[idx["Hedges_d"]]
        if d is None:
            continue
        author = str(r[idx["Author"]]).strip()
        sp = str(r[idx["Species_latin"]]).strip()
        out.append(dict(
            study=r[idx["Study_no"]],
            es=str(r[idx["Effect_size_no"]]),
            author=author,
            year=r[idx["Year"]],
            species=sp,
            epithet=sp.split()[-1].lower(),
            n=r[idx["Total_n_analysis"]],
            behaviour=r[idx["Behaviour_type"]],
            d=float(d),
            absd=abs(float(d)),
        ))
    return out


def load_jones():
    out = []
    with open(JONES_CSV, newline="") as f:
        for row in csv.DictReader(f):
            if not row.get("study"):
                continue
            lnor = float(row["lnOR"])
            d = lnor * LNOR_TO_D                 # STEP 2 conversion
            out.append(dict(
                code=row["study"],
                exp=row["Exp"],
                year=int(row["year"]),
                species=row["Species"].strip(),
                epithet=row["Species"].strip().lower(),
                behaviour=row.get("Model_Choice", ""),
                lnor=lnor,
                d=d,
                absd=abs(d),
            ))
    return out


# ----------------------------------------------------------------------
# STEP 3 - study-level keys
# ----------------------------------------------------------------------
def davies_prefix(author):
    return author.split()[0][:3].upper()


def epithet_match(a, b):
    return a == b or a.startswith(b[:5]) or b.startswith(a[:5])


def match_studies(jones, davies):
    dby = defaultdict(list)
    for r in davies:
        dby[(davies_prefix(r["author"]), r["year"])].append(r)
    jby = defaultdict(list)
    for r in jones:
        jby[(r["code"][:3].upper(), r["year"])].append(r)

    shared, unmatched = [], []
    for jk, jr in jby.items():
        cand = dby.get(jk, [])
        if not cand:
            unmatched.append((jk, jr, "no Davies study with this author-prefix + year"))
            continue
        studies = defaultdict(list)
        for c in cand:
            studies[c["study"]].append(c)
        jep = jr[0]["epithet"]
        pick = None
        for recs in studies.values():
            if epithet_match(jep, recs[0]["epithet"]):
                pick = recs
                break
        if pick is None and len(studies) == 1:      # single study, accept despite species string
            pick = list(studies.values())[0]
        if pick:
            shared.append((jk, jr, pick))
        else:
            opts = "; ".join(f"study {s} ({r[0]['species']})" for s, r in studies.items())
            unmatched.append((jk, jr, f"author/year present but species mismatch: {opts}"))
    return shared, unmatched


# ----------------------------------------------------------------------
# STEP 4 - optimal effect-size assignment within a study
# ----------------------------------------------------------------------
def best_assignment(js, ds):
    """Return list of (jones_rec, davies_rec) pairs minimising total |Δ|d||."""
    small, large = (js, ds) if len(js) <= len(ds) else (ds, js)
    small_is_jones = len(js) <= len(ds)
    best = None
    for perm in permutations(range(len(large)), len(small)):
        cost = sum(abs(small[i]["absd"] - large[perm[i]]["absd"]) for i in range(len(small)))
        if best is None or cost < best[0]:
            best = (cost, perm)
    pairs = []
    for i, j in enumerate(best[1]):
        sm, lg = small[i], large[j]
        pairs.append((sm, lg) if small_is_jones else (lg, sm))
    return pairs


def is_match(a, b):
    if abs(a - b) <= TOL_ABS:
        return True
    m = max(a, b)
    return m > 0 and abs(a - b) / m <= TOL_REL


# ----------------------------------------------------------------------
# main
# ----------------------------------------------------------------------
def main():
    jones = load_jones()
    davies = load_davies()
    shared, unmatched = match_studies(jones, davies)

    pair_rows = []
    n_match = 0
    for jk, jr, dr in sorted(shared, key=lambda x: x[0]):
        n_j, n_d = len(jr), len(dr)
        for j, d in best_assignment(jr, dr):
            m = is_match(j["absd"], d["absd"])
            n_match += int(m)
            pair_rows.append(dict(
                author_prefix=jk[0], year=jk[1],
                jones_code=j["code"], jones_exp=j["exp"],
                jones_lnOR=round(j["lnor"], 4),
                jones_d_from_lnOR=round(j["d"], 4),
                jones_behaviour=j["behaviour"],
                davies_study=d["study"], davies_es=d["es"],
                davies_hedges_d=round(d["d"], 4),
                davies_behaviour=d["behaviour"],
                davies_n=d["n"],
                abs_jones_d=round(j["absd"], 4),
                abs_davies_d=round(d["absd"], 4),
                abs_diff=round(j["absd"] - d["absd"], 4),
                n_jones_es=n_j, n_davies_es=n_d,
                sign_agree=(j["d"] >= 0) == (d["d"] >= 0),
                magnitude_match=m,
            ))

    # ---- write crosswalk ----
    with open(os.path.join(OUTDIR, "crosswalk_effect_sizes.csv"), "w", newline="") as f:
        w = csv.DictWriter(f, fieldnames=list(pair_rows[0].keys()))
        w.writeheader()
        w.writerows(pair_rows)

    # ---- write shared-studies summary ----
    with open(os.path.join(OUTDIR, "shared_studies.csv"), "w", newline="") as f:
        w = csv.writer(f)
        w.writerow(["author_prefix", "year", "jones_species", "davies_species",
                    "davies_study", "n_jones_es", "n_davies_es", "n_compared"])
        for jk, jr, dr in sorted(shared, key=lambda x: x[0]):
            w.writerow([jk[0], jk[1], jr[0]["species"], dr[0]["species"],
                        dr[0]["study"], len(jr), len(dr), min(len(jr), len(dr))])

    # ---- write unmatched ----
    with open(os.path.join(OUTDIR, "unmatched_jones_studies.csv"), "w", newline="") as f:
        w = csv.writer(f)
        w.writerow(["author_prefix", "year", "species", "n_effect_sizes",
                    "jones_codes", "reason"])
        for jk, jr, reason in sorted(unmatched, key=lambda x: x[0]):
            w.writerow([jk[0], jk[1], jr[0]["species"], len(jr),
                        "|".join(sorted({r["code"] for r in jr})), reason])

    # ---- console summary ----
    n_pairs = len(pair_rows)
    print("=" * 70)
    print("SUMMARY")
    print("=" * 70)
    print(f"Jones & DuVal studies total : {len(set(r['code'][:3].upper()+str(r['year']) for r in jones))}")
    print(f"Shared studies (both)       : {len(shared)}")
    print(f"Jones studies NOT in Davies : {len(unmatched)} "
          f"({sum(len(j) for _, j, _ in unmatched)} effect sizes)")
    print(f"Comparable effect-size pairs: {n_pairs}")
    print(f"  match in magnitude        : {n_match} ({100*n_match/n_pairs:.0f}%)")
    print(f"  sign agreement            : {sum(r['sign_agree'] for r in pair_rows)} "
          f"({100*sum(r['sign_agree'] for r in pair_rows)/n_pairs:.0f}%)")
    print()
    print("UNMATCHED JONES STUDIES (verified against ALL of Davies):")
    for jk, jr, reason in sorted(unmatched, key=lambda x: x[0]):
        print(f"  {jk[0]} {jk[1]} {jr[0]['species']:<14} n={len(jr)}  -- {reason}")
    print()
    print(f"CSVs written to {os.path.relpath(OUTDIR, REPO)}/")


if __name__ == "__main__":
    main()
