# Licence

This repository is dual-licensed, because it contains both software and scholarly content.

| Material | Licence |
|---|---|
| **Code** — `.R`, `.py`, `.qmd` code chunks, `.cls`, `.css`, build configuration | MIT Licence (below) |
| **Content** — text, figures, tables, and the harmonised effect-size dataset produced by this study | [Creative Commons Attribution 4.0 International (CC BY 4.0)](https://creativecommons.org/licenses/by/4.0/) |
| **Third-party data** — see note below | Terms of the original publications |

## Third-party data

`data/original_meta_analyses_datasets/` contains data redistributed from two previously
published meta-analyses so that this update is reproducible end to end:

- `Davies_et_al_2020_Final_data.xlsx` — Davies, A. D., Lewis, Z. and Dougherty, L. R. (2020)
- `Jones_DuVal_2019_data.CSV` — Jones, B. C. and DuVal, E. H. (2019)

These files remain subject to the licensing terms of their source publications and are
**not** covered by the CC BY 4.0 grant above. If you reuse them, cite the original papers.

⚠️ A coding note if you reuse the Davies data: its `Author` column is not a unique study
identifier — five author strings each span two or three separate publications. Key on
`Study_no` instead. See the README for details.

---

## MIT Licence (code)

Copyright (c) 2026 Eduardo S. A. Santos and co-authors

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.

---

## CC BY 4.0 (content)

You are free to share and adapt the content, for any purpose including
commercially, provided you give appropriate credit, link to the licence, and
indicate if changes were made.

Full text: <https://creativecommons.org/licenses/by/4.0/legalcode>

Suggested attribution:

> Santos, E. S. A. *et al.* (2026) *Mate choice copying in non-human animals: an update of
> two meta-analyses.* <https://github.com/esantos2ua/mate_choice_meta> — CC BY 4.0.
