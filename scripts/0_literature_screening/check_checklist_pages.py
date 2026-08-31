#!/usr/bin/env python3
"""
Audit (and help update) the page references in prisma_ecoevo_checklist.tex.

The checklist's "Location / notes" column cites manuscript pages as `p.~N`.
Those numbers are only valid for one particular compiled PDF, so they go stale
whenever the manuscript is re-paginated -- which the Biology Open reformat did
wholesale, since the section order changed from Intro/Methods/Results/Discussion
to Intro/Results/Discussion/Methods.

This script does two things against a given compiled PDF:

  1. Prints a section -> page map, so each checklist row can be re-pointed by
     hand quickly and verifiably.
  2. For every `p.~N` in the checklist, reports the section that page currently
     holds, so an obviously-wrong reference (a Methods item pointing at the
     reference list, say) is easy to spot.

Usage:
    python3 scripts/0_literature_screening/check_checklist_pages.py \
        "bio_revision/OverLeafCompiled/Mate Choice Copying Meta-Analysis Revision_clean.pdf"

Run it again on the FINAL compiled PDF immediately before submission, then fix
the checklist by hand from the map it prints. Deliberately does not rewrite the
.tex: each row's page depends on what that row is claiming, which is a judgement
the script cannot make.
"""
import re, subprocess, sys, os

HEADINGS = ["ABSTRACT", "INTRODUCTION", "RESULTS", "DISCUSSION",
            "MATERIALS AND METHODS", "Acknowledgements", "Competing interests",
            "Contribution", "Funding", "Data availability", "Supplementary",
            "REFERENCES", "Figure legends", "Tables"]

def pages(pdf):
    txt = subprocess.run(["pdftotext", "-layout", pdf, "-"],
                         capture_output=True, text=True).stdout
    return txt.split("\f")

def section_map(pgs):
    """page -> list of headings starting on it, and heading -> first page."""
    per_page, first = {}, {}
    for i, page in enumerate(pgs, 1):
        for raw in page.split("\n"):
            line = re.sub(r"\s{2,}\d{1,4}\s*$", "", raw).strip()
            line = re.sub(r"^\s*\d{1,4}\s{2,}", "", line).strip()
            for h in HEADINGS:
                if line.upper() == h.upper():
                    per_page.setdefault(i, []).append(h)
                    first.setdefault(h, i)
    return per_page, first

def section_of(page, first, npages):
    """which section a page falls inside, from the heading start pages"""
    best, bestpage = "(front matter)", 0
    for h, p in first.items():
        if p <= page and p >= bestpage:
            best, bestpage = h, p
    return best

def main():
    if len(sys.argv) < 2:
        sys.exit(__doc__)
    pdf = sys.argv[1]
    if not os.path.exists(pdf):
        sys.exit("no such PDF: %s" % pdf)
    chk = os.path.join(os.path.dirname(os.path.abspath(__file__)),
                       "..", "..", "prisma_ecoevo_checklist.tex")
    chk = os.path.normpath(chk)

    pgs = pages(pdf)
    per_page, first = section_map(pgs)
    n = len(pgs)

    print("=== %s: %d pages ===\n" % (os.path.basename(pdf), n))
    print("SECTION -> FIRST PAGE")
    for h in HEADINGS:
        if h in first:
            print("   %-26s p%d" % (h, first[h]))

    text = open(chk, encoding="utf-8").read()
    refs = sorted({int(m) for m in re.findall(r"p\.~(\d+)", text)})
    print("\nCHECKLIST PAGE REFERENCES -> WHAT IS ON THAT PAGE NOW")
    print("   %-8s %-30s %s" % ("cited", "section on that page now", "count in checklist"))
    for r in refs:
        cnt = len(re.findall(r"p\.~%d\b" % r, text))
        where = section_of(r, first, n) if r <= n else "*** BEYOND END OF PDF ***"
        print("   p.%-6d %-30s %d" % (r, where, cnt))
    print("\n%d distinct pages cited, %d references total"
          % (len(refs), len(re.findall(r"p\.~\d+", text))))

if __name__ == "__main__":
    main()
