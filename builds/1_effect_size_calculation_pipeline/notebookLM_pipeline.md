# 🔬 NotebookLM Meta-Analysis Extraction Pipeline

**Version:** 1.1
**Purpose:** To systematically extract, classify, and validate quantitative data, species information, and metadata from research PDFs for meta-analysis, while controlling for lab-level non-independence.

## ⚠️ Important Operating Rules for NotebookLM

1. **The "Cache-Bust" Rule:** Always start a **Completely New Chat** for each step in this pipeline. Do not run Step 3 in the same chat window as Step 2. This prevents the AI from recycling old tables and forces it to read the PDFs freshly.
2. **The Reference Sheet:** Before running any of these prompts, ensure you have uploaded the `MetaAnalysis_Reference_Sheet.pdf` to your NotebookLM sources. This document must contain your data dictionary and examples of perfect extractions (Few-Shot Prompting).

---

## Step 1: Species & Basic Metadata Extraction

**Goal:** Establish the foundational dataset by identifying the exact species studied in every paper to ensure taxonomic accuracy across your meta-analysis.

**Copy & Paste this prompt:**

```text
SYSTEM OVERRIDE & CACHE CLEAR: 
Ignore all previous tables, drafts, and conversational history. You must generate an entirely new table from scratch by freshly scanning the source documents.

MANDATORY GROUNDING:
You must strictly use the formatting, rules, and schemas provided in the document named `MetaAnalysis_Reference_Sheet.pdf`.

TASK: Species and Study Identification
Please analyze all uploaded PDF research reports. I need to extract the exact study organism used in each paper.

Instructions for the Table:
1. Study ID: Use the format `Author_Year_JournalName` (e.g., `Belkina_2021_AnimalBehaviour`). Use the first author's last name and full CamelCase journal name. Do not abbreviate the journal.
2. Species: Identify the study organism and provide the full biological binomial nomenclature (e.g., Drosophila melanogaster, Poecilia reticulata). Do not use common names alone.

Output Format:
Provide a single Markdown table containing only the requested columns. Ensure every single PDF in the source list is accounted for in this table.

```

---

## Step 2: Co-Authorship & Lab Identification

**Goal:** Extract data in a "Long Format" to build a bipartite network in R/Python to identify "Hub Labs" and test for non-independence.

**Copy & Paste this prompt:**

```text
SYSTEM OVERRIDE & CACHE CLEAR: 
Ignore all previous tables, drafts, and conversational history. You must generate an entirely new table from scratch by freshly scanning the source documents.

MANDATORY GROUNDING:
You must strictly use the formatting, rules, and schemas provided in the document named `MetaAnalysis_Reference_Sheet.pdf`.

TASK: Long-Format Data Extraction for Network Analysis
Please analyze all uploaded PDF research reports. I need to create a co-authorship network, which requires the data to be in a "Long Format." This means you must generate a table where EVERY author of every paper has their own row.

Instructions for the Table:
1. Study ID: Use the format `Author_Year_JournalName` (e.g., `Belkina_2021_AnimalBehaviour`). Use the first author's last name and full CamelCase journal name.
2. Author Name: The full name of the specific author for that row.
3. Author Position: State if they are "First", "Last", "Corresponding", or "Middle".
4. Institutional Affiliation: The specific University or Institute for that author.
5. Lab Identifier (CRITICAL): Create a standardized string in the format `PILastName_Institution_City` (e.g., `Dukas_UniversityOfToronto_Toronto`). Use the Last Author's name as the PI for this identifier, even for rows representing middle authors, so all authors on the same paper are linked to the same "Primary Lab".

Output Format:
Provide a single Markdown table. If a paper has 5 authors, that paper must have 5 distinct rows in your table.

```

---

## Step 3: Trial-Level Data Mapping

**Goal:** Map the internal structure of each paper to identify how many effect sizes can be extracted, flag repeated measures, and pinpoint exact page numbers for human extractors.

**Copy & Paste this prompt:**

```text
SYSTEM OVERRIDE & CACHE CLEAR: 
Ignore all previous tables, drafts, and conversational history. You must generate an entirely new table from scratch by freshly scanning the source documents.

MANDATORY GROUNDING:
You must strictly use the formatting, rules, and schemas provided in the document named `MetaAnalysis_Reference_Sheet.pdf`.

TASK: Trial-Level Data Extraction and Localization for Meta-Analysis
Please analyze all uploaded PDF research reports. My goal is to identify exactly how many distinct experimental trials or tests exist within each paper that provide data on mate-choice copying, and specifically WHERE that data is located.

Generate a comprehensive Markdown table with the following columns. Create a new row for EVERY distinct trial:
1. Study ID: Construct the identification key exactly as `Author_Year_JournalName`.
2. Trial ID: The name or number of the experiment (e.g., "Experiment 1", "Treatment A").
3. Trial Description: A brief (1-2 sentence) description of what was manipulated.
4. Sample Size (N): The total number of focal subjects tested in this specific trial.
5. Subject Independence: State either "Independent Cohort" (if a fresh batch of naive animals was used) OR "Repeated Measures" (if the same animals from a previous trial were re-tested).
6. Control Group Shared: Does this trial share a control group with another trial in the same paper? (Answer Yes or No, and specify which trial if Yes).
7. Data Location (CRITICAL): Specify exactly where the effect size data or summary statistics can be found. Include the Page Number and the Format Type (e.g., "Table 1, Page 5", "Figure 3A, Page 8").

Output Format:
Provide only the markdown table.

```

---

## Step 4: Quantitative Data Extraction (Multi-Agent Pipeline)

**Goal:** Extract the actual numbers (Means, SD/SE, Counts, or Test Statistics) using a simulated 3-agent architecture to cross-validate data and catch common statistical errors.

**Copy & Paste this prompt:**

```text
SYSTEM OVERRIDE & CACHE CLEAR: 
Ignore all previous tables, drafts, and conversational history. You must generate an entirely new table from scratch by freshly scanning the source documents.

MANDATORY GROUNDING:
You must strictly use the formatting, rules, and schemas provided in the document named `MetaAnalysis_Reference_Sheet.pdf`.

SYSTEM DIRECTIVE: EXHAUSTIVE MULTI-AGENT DATA EXTRACTION
You are an automated meta-analysis extraction pipeline powered by three simulated expert agents. Your task is to extract quantitative effect size data from EVERY SINGLE PDF provided in the source list. 

CRITICAL RULE: You are strictly forbidden from summarizing, grouping papers, or skipping any uploaded document. You must process the documents sequentially, one by one.

THE PIPELINE:
For *each* document in your sources, you must run the following sequence internally before adding the results to the final output:

1. Agent 1 (The Extractor): Scan the Methods and Results. Extract the continuous data (Means, SD/SE, N), binary data (Counts), or inferential statistics (F, t, chi-square, p) for Experimental and Control groups for every mate-choice copying trial. 
2. Agent 2 (The Verifier): Act as a skeptical methodologist. Review Agent 1's numbers against the original text/tables. You must specifically verify three things: 
    A) Did Agent 1 confuse Standard Error (SE) with Standard Deviation (SD)? 
    B) Is the sample size (N) independent or repeated measures? 
    C) MISSING TRIALS CHECK: Read the methods carefully. Did Agent 1 miss any subsequent trials, secondary experiments, or repeated measures for this study?
3. Agent 3 (The Arbiter): Resolve any errors found by Agent 2. Format the validated data into a standardized table row.

OUTPUT FORMAT:
Do not print the debate between the agents for every paper. Instead, print a single, continuous Markdown table containing the final, validated data from Agent 3 for all papers.

The final table MUST contain these exact columns:
1. Study ID (Format: Author_Year_JournalName)
2. Trial ID (Specific experiment or condition)
3. Response Metric (What was measured)
4. Validated Exp Group Data (Mean ± SD/SE, Counts, or Test Stat)
5. Validated Control Group Data (Mean ± SD/SE, Counts, or NA)
6. SD or SE? (Explicitly state which variance metric is reported, or NA)
7. Agent 1 Initial Pull (Brief summary of what Agent 1 originally extracted)
8. Agent 2 Verification Notes (State corrections made, confirm independence, and explicitly state "No missing trials found" or list the missed trials added)
9. Verification Location (Exact Page and Table/Figure number)

EXECUTION:
Begin processing Source 1. Continue through every source until all documents have been extracted and added to the table. Print the final table now.

```