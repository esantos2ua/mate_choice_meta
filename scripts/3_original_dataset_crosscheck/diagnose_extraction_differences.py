#!/usr/bin/env python3
"""
Diagnose extraction differences between Davies (2020) and Jones & DuVal (2019)
=============================================================================

Companion to crosscheck_davies_jones.py. For every SHARED study it prints, side
by side, the raw effect sizes each team extracted, so we can see *why* two
records that come from the same paper disagree in magnitude.

It surfaces the four recurring causes of disagreement:
  (1) different NUMBER of effect sizes (one team split / pooled treatments);
  (2) different SAMPLE SIZE (N) used for the same contrast;
  (3) different OUTCOME extracted (Jones' Model_Choice behaviour vs Davies'
      Behaviour_type -- e.g. one took an affiliation-time measure, the other a
      mate-choice-reversal frequency);
  (4) SIGN convention (Davies' non-directional Hedges' d carries the raw
      mean-difference sign; Jones' lnOR sign encodes copying direction) -- this
      is why we match on |d|, not signed d.

Jones lnOR is placed on the Hedges' d scale with d = lnOR * sqrt(3)/pi.

Output: outputs/3_original_dataset_crosscheck/extraction_diagnostics.txt
Usage:  python3 scripts/3_original_dataset_crosscheck/diagnose_extraction_differences.py
"""
import csv, math, os
from collections import defaultdict
import openpyxl

HERE = os.path.dirname(os.path.abspath(__file__))
REPO = os.path.abspath(os.path.join(HERE, "..", ".."))
DATA = os.path.join(REPO, "data", "original_meta_analyses_datasets")
OUT = os.path.join(REPO, "outputs", "3_original_dataset_crosscheck", "extraction_diagnostics.txt")
K = math.sqrt(3) / math.pi

wb = openpyxl.load_workbook(os.path.join(DATA, "Davies_et_al_2020_Final_data.xlsx"), data_only=True)
ws = wb["Data"]; rows = list(ws.iter_rows(values_only=True)); hdr = rows[0]
idx = {h: i for i, h in enumerate(hdr)}
davies = []
for r in rows[1:]:
    if r[idx["Study_no"]] is None or r[idx["Hedges_d"]] is None: continue
    davies.append(dict(study=r[idx["Study_no"]], es=str(r[idx["Effect_size_no"]]),
        author=str(r[idx["Author"]]).strip(), year=r[idx["Year"]],
        epithet=str(r[idx["Species_latin"]]).split()[-1].lower(),
        n=r[idx["Total_n_analysis"]], beh=r[idx["Behaviour_type"]], d=float(r[idx["Hedges_d"]])))
jones = []
with open(os.path.join(DATA, "Jones_DuVal_2019_data.CSV"), newline="") as f:
    for row in csv.DictReader(f):
        if not row.get("study"): continue
        lnor = float(row["lnOR"])
        jones.append(dict(code=row["study"], exp=row["Exp"], year=int(row["year"]),
            epithet=row["Species"].strip().lower(), beh=row["Model_Choice"],
            lnor=lnor, d=lnor * K))

dby, jby = defaultdict(list), defaultdict(list)
for r in davies: dby[(r["author"].split()[0][:3].upper(), r["year"])].append(r)
for r in jones:  jby[(r["code"][:3].upper(), r["year"])].append(r)
def emat(a, b): return a == b or a.startswith(b[:5]) or b.startswith(a[:5])

shared = []
for jk, jr in jby.items():
    cand = dby.get(jk, [])
    if not cand: continue
    st = defaultdict(list)
    for c in cand: st[c["study"]].append(c)
    pick = None
    for recs in st.values():
        if emat(jr[0]["epithet"], recs[0]["epithet"]): pick = recs; break
    if pick is None and len(st) == 1: pick = list(st.values())[0]
    if pick: shared.append((jk, jr, pick))

lines = []
for jk, jr, dr in sorted(shared, key=lambda x: x[0]):
    tag = f"{jk[0]}{jk[1]}"
    flags = []
    if len(jr) != len(dr): flags.append(f"ES count differs ({len(jr)} vs {len(dr)})")
    if len({d['beh'] for d in dr}) and {j['beh'] for j in jr}:  # behaviour note
        pass
    lines.append("=" * 72)
    lines.append(f"{tag}  ({dr[0]['author']} {jk[1]}, {dr[0]['epithet']})  "
                 f"Jones n={len(jr)}  Davies n={len(dr)}")
    if flags: lines.append("  FLAG: " + "; ".join(flags))
    lines.append(f"  {'JONES code/exp':18s} {'lnOR':>8} {'->d':>8}  {'Model_Choice':>16}")
    for j in sorted(jr, key=lambda r: abs(r['d'])):
        lines.append(f"  {j['code']+'/'+j['exp']:18s} {j['lnor']:8.3f} {j['d']:8.3f}  {j['beh']:>16}")
    lines.append(f"  {'DAVIES es':18s} {'Hedges_d':>8} {'|d|':>8}  {'N':>4} {'Behaviour_type':>16}")
    for d in sorted(dr, key=lambda r: abs(r['d'])):
        lines.append(f"  {d['es']:18s} {d['d']:8.3f} {abs(d['d']):8.3f}  {str(d['n']):>4} {str(d['beh']):>16}")

with open(OUT, "w") as f:
    f.write("\n".join(lines) + "\n")
print(f"Wrote {os.path.relpath(OUT, REPO)} ({len(shared)} shared studies)")
