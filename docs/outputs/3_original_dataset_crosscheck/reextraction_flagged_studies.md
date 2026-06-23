# Re-extraction of effect sizes with |Δd| > 0.5

Primary-PDF re-extraction of the 7 studies whose Davies-vs-Jones effect-size
pairs disagreed by more than 0.5 Hedges-d units in
`crosswalk_effect_sizes.csv`. For each study we located the raw data in the
source paper, recomputed the mate-choice-copying effect size as a log odds
ratio (lnOR) and as Hedges' d (d ≈ lnOR × √3/π = lnOR × 0.5513), and judged
which of the two prior meta-analyses extracted correctly.

**Confidence key:** ★★★ raw counts quoted verbatim, arithmetic reproduces
exactly; ★★ key counts read from a figure or partly inferred; ★ requires a
modelling/coding decision.

---

## Headline finding

In **all 7 flagged studies the Jones & DuVal (lnOR) value is the more faithful
extraction of the mate-choice-copying outcome.** The Davies et al. (Hedges-d)
values are the source of the disagreement, via four recurring problems:

1. **Wrong outcome construct** — Davies extracted a secondary *association/
   affiliation time* (Applebaum, Briggs) or a *size-preference* (Howard)
   measure instead of the copying/reversal frequency the studies actually test.
2. **Computational artifacts** — implausibly large d values that reproduce only
   from a degenerate `escalc` 2×2 (Dugatkin 1992 d = 3.732 = 2 + √3; Gierszewski
   d = 2.43 from the structural M1 zero-cell).
3. **Wrong sample size** — N = 40 recorded where the study used N = 20
   (both Dugatkin studies).
4. **Sign error** — Howard: Davies +1.14 vs the correct −0.61 (the study found
   *no* copying).

Two caveats cut the other way: **Jones over-counts effect sizes** in Dugatkin
(1992) (3 vs the 2 the paper supports) and Gierszewski (4 vs 2, duplicated
under "MAT"/"USI" codes), and the **Fowler-Finn** gap is *not* an error — it is
Davies pooling what Jones split.

---

## Per-study results

### 1. Applebaum & Cruz (2000) — *Limia perugiae*  ★★
- **Outcome:** preference-**reversal frequency** (binary; authors' G-tests). N = 24.
- **Raw (Fig. 2):** Exp1 ≈5/24 reversals, Exp2 ≈13/24, Exp3 ≈12/24.
- **Copying contrast (Exp2 vs Exp1):** OR = (13·19)/(11·5) = 4.49 → **lnOR = 1.502, d = 0.83** — reproduces Jones exactly.
- **Davies (d from affiliation time):** −0.247 and −0.243 are correct (paired t = −1.21, −1.19, /√24); **+2.813 and −2.024 are not reproducible** from any statistic in the paper — apparent errors.
- **Verdict:** Use Jones. lnOR 1.502 (d 0.83) for the copying contrast; the lnOR −1.335 baseline (Exp1 vs random) is a defensible second ES. Davies values mix in a secondary measure and two erroneous numbers.

### 2. Briggs, Godin & Dugatkin (1996) — *Poecilia reticulata*  ★★★
- **Outcome:** reversal frequency (binary). N = 20 each. Counts from Table 1.
- **Exp2 vs Exp1:** 12/8 vs 5/15 → OR 4.50 → **lnOR 1.504, d 0.83.** Exp3 vs Exp1 identical → **lnOR 1.504, d 0.83.** Reproduces Jones exactly (both ES).
- **Davies d = 1.376 (affiliation time, N = 40):** not derivable — the time comparisons are all non-significant (t = 0.65, 0.35) and the preferred-male times are graphed, not tabulated; N = 40 mis-treats 20 paired females as two groups.
- **Verdict:** Use Jones. Two ES, each lnOR 1.504 (d 0.83).

### 3. Dugatkin (1992) — *Poecilia reticulata*  ★★★
- *(single-authored; "Dugatkin & Godin 1992" is a mis-citation)*
- **Outcome:** choice frequency vs 50% null (G-tests). N = **20** per experiment.
- **Genuine copying contrasts (2):** Exp1 17/20 → **lnOR 1.735, d 0.96**; Exp5 (reversal) 16/20 → **lnOR 1.386, d 0.76.** Exps 2,3,4,6 are null controls (≈10–11/20).
- **Davies d = 3.732 = 2 + √3** — the classic degenerate-2×2 `escalc` artifact; **N = 40 is wrong** (should be 20). d = 0.558 is plausible but the pair misrepresents the paper.
- **Jones:** right direction but **3 values, somewhat inflated** (2.234/1.186/1.534) vs the 2 the paper supports.
- **Verdict:** Re-extract as **2 ES**: 17/20 (lnOR 1.735, d 0.96) and 16/20 (lnOR 1.386, d 0.76). Discard Davies.

### 4. Dugatkin & Godin (1993) — *Poecilia reticulata*  ★★★
- **Outcome:** choice frequency vs 50% null (G-tests). N = **20** per experiment.
- **Exp1** (young focal, older model): 17/20 → **lnOR 1.735, d 0.96** (paired-t time route: d 0.66). **Exp2** (old focal): 12/20 → **lnOR 0.405, d 0.22** (t route d 0.24). Reproduces Jones exactly.
- **Davies d = 2.377 and 1.000 (N = 40):** not reproducible (2.377 needs odds ≈74:1); N wrong. Likely `escalc`/zero-cell artifact.
- **Verdict:** Use Jones. Two ES: lnOR 1.735 (d 0.96) and 0.405 (d 0.22).

### 5. Fowler-Finn et al. (2015) — *Schizocosa*  ★★
- **Outcome:** mating phenotype matches observed phenotype (binary). Pooled: 15/21 = 71% vs 50%, χ² = 3.98, P = 0.046.
- **This is a pool-vs-split difference, NOT an error:**
  - **Davies (pooled, 1 ES):** d = 0.628 ≈ the 71%-vs-50% result. Defensible.
  - **Jones (split, 2 ES):** observed-ornamented arm lnOR ≈ 2.20 (d ≈ 1.21, copying present) and observed-non-ornamented arm lnOR ≈ 0.18 (d ≈ 0.10, no copying). Matches the significant phenotype×age interaction (P = 0.0097) and the authors' statement that copying occurs only for observed-ornamented males.
- **Verdict:** Decision needed. Jones' split is more faithful to the data structure; Davies' pooled value is a valid summary. Per-arm counts read from Fig. 5 (approximate).

### 6. Gierszewski et al. (2018) — *Poecilia latipinna* (FishSim)  ★★
- **Outcome:** mate-choice **reversal** frequency (binary). N = 15 per group.
- **Raw (p.13/Fig.7C):** Spot 11/15 reversals, No-spot 10/15, Control "two" (text) / ≈1 (figure).
- **Genuine ES (2), reversal-vs-control:** Spot **lnOR ≈ 3.2, d ≈ 1.77**; No-spot **lnOR ≈ 2.9, d ≈ 1.61** (with +0.5 correction).
- **Jones (4 ES):** double-counts the 2 contrasts under "MAT"/"USI"; magnitudes (d ≈ 1.4–1.7) are the right *class* (reversal-vs-control).
- **Davies (2 ES, d = 1.981 & 2.429):** right *count* but magnitudes inflated by the **M1 structural zero cell** (M1 = 0/15 prefer the target male by design) → `escalc` artifact.
- **Verdict:** Re-extract as **2 ES**, reversal-vs-control odds ratios, **d ≈ 1.6–2.0.** Neither prior extraction is fully right (Jones count wrong; Davies magnitude artifactual). Note text/figure discrepancy in the control count.

### 7. Howard et al. (1998) — *Oryzias latipes* (medaka)  ★★★
- **Outcome:** copying = reversal toward the model-associated (initially non-preferred) male. N (post-model) = 20.
- **Raw (p.1157):** 15 retained their original preference, 5 reversed. Copying odds (reversed:retained) = 5/15 = 1/3 → **lnOR = ln(1/3) = −1.099, d = −0.61.** Reproduces Jones exactly, **including the negative sign** — the study found *no copying* ("no indication that females copied", Abstract).
- **Davies d = +1.14 (N = 40):** conflates the strong *large-male association/size preference* (a different construct) with copying; wrong sign for copying and ~2× the magnitude.
- **Verdict:** Use Jones. lnOR −1.099 (d −0.61). This is a genuine **sign + construct error** in Davies.

---

## Recommended corrected effect sizes (copying outcome)

| Study | N | ES (copying contrast) | lnOR | Hedges d | conf. |
|---|---|---|---|---|---|
| Applebaum & Cruz 2000 | 24 | Exp2 vs Exp1 (13 vs 5 / 24) | 1.502 | 0.83 | ★★ |
| Briggs et al. 1996 | 20 | Exp2 vs Exp1 (12 vs 5 / 20) | 1.504 | 0.83 | ★★★ |
| Briggs et al. 1996 | 20 | Exp3 vs Exp1 (12 vs 5 / 20) | 1.504 | 0.83 | ★★★ |
| Dugatkin 1992 | 20 | Exp1 main (17/20) | 1.735 | 0.96 | ★★★ |
| Dugatkin 1992 | 20 | Exp5 reversal (16/20) | 1.386 | 0.76 | ★★★ |
| Dugatkin & Godin 1993 | 20 | Exp1 (17/20) | 1.735 | 0.96 | ★★★ |
| Dugatkin & Godin 1993 | 20 | Exp2 (12/20) | 0.405 | 0.22 | ★★★ |
| Fowler-Finn et al. 2015 | 21 | pooled (15/21 vs 50%) | ~0.92 | ~0.51 | ★★ |
| Fowler-Finn et al. 2015 | — | OR split: obs-ornamented / obs-non-orn. | 2.20 / 0.18 | 1.21 / 0.10 | ★★ |
| Gierszewski et al. 2018 | 15 | Spot vs control (11/15) | ~3.2 | ~1.77 | ★★ |
| Gierszewski et al. 2018 | 15 | No-spot vs control (10/15) | ~2.9 | ~1.61 | ★★ |
| Howard et al. 1998 | 20 | reversal (5 rev : 15 retained) | −1.099 | −0.61 | ★★★ |

Decisions for the team: (a) whether to pool or split Fowler-Finn; (b) how many
ES to keep for Dugatkin 1992 and Gierszewski; (c) confirm the Gierszewski
control reversal count (text "2" vs figure "≈1"); (d) whether any "different
outcome construct" Davies values (affiliation time, size preference) should be
retained as separate effect sizes rather than discarded.
