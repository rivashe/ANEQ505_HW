# HW4 - Directory Guide

---

## Project Structure Overview

```
hw4/
├── 01_notes/               # Project notes and documentation
│   ├── homework4_mac.md
├── 02_data/                # Raw data files
├── 03_metadata/            # Sample metadata files
├── 04_code/                # R code and analysis scripts
│   ├── alpha_div/          # Alpha diversity analysis data
│   │  ├── shannon.tsv 
│   ├── beta_div/           # Beta diversity analysis data
│   │  ├── unweighted_unifrac.txt
│   ├── cow_HW4_r.Rmd       # Main R Markdown analysis file(code)
│   └── taxonomy/           # Taxonomy and composition analysis data
│   │  ├── rel_abundance_taxa_family.RDS
│   │  ├── rel_abundance_taxa_lowest.RDS
└── 05_figures/             # Publication-ready figures
│   ├── shannon_bodisite.jpeg
│   ├── taxa_family_bodisite.jpeg
│   ├── taxa_family_fecal.jpeg
│   ├── unweighted_unifrac_pcoa.jpeg
```

---

## Detailed Directory Contents

### **01_notes/** - Project Notes & Documentation - HW4
**Purpose:** Complete HW4 notes and answers  
**Contents:**
- HW4 complete answers

---

### **02_data/** - Raw Data Files
**Purpose:** Store all raw data input files needed for analysis  
**Contents:**
- `tabulated_results.tsv` — QIIME2 tabulated taxonomic results (genus level)

**Note:** These files are imported into R Markdown for analysis

---

### **03_metadata/** - Sample Metadata
**Purpose:** Store all sample metadata information  
**Contents:**
- `cow_metadata.txt` — Full metadata file with all samples and body sites
  - Columns: sample_name, body_site, cow_id, other variables

**How to use:** These files are loaded into R with:
```r
metadata <- read_tsv("../03_metadata/cow_metadata.txt")
```

---

### **04_code/** - Analysis Code
**Purpose:** Store all R scripts and analysis code  

#### **04_code/cow_HW4_r.Rmd** (Main Analysis File)
**Purpose:** Primary R Markdown file for complete microbiome analysis  
**Contains:**
- Library loading
- Metadata import
- Alpha diversity analysis (Shannon entropy with LME models)
- Beta diversity analysis (UniFrac PCoA)
- Taxonomic composition plots (family level)
- Statistical comparisons with p-values
- Publication-ready figure generation

**Run this file to:**
- Load all data
- Run all statistical analyses
- Generate all figures
- Export results to `../05_figures/`

**File paths in R Markdown:**
```r
# Metadata
metadata <- read_tsv("../03_metadata/cow_metadata.txt")

# Alpha diversity
shannon <- read_tsv("../02_data/shannon.tsv")

# Beta diversity
uw_unifrac <- read_tsv("../02_data/unweighted_unifrac.txt")

# Taxonomy
tabulated_results <- read_tsv("../02_data/tabulated_results.tsv")

# Output figures to:
ggsave(..., filename = "../05_figures/figure_name.jpeg")
```



#### **04_code/taxonomy/** - Taxonomy Subfolder
**Purpose:** Store taxonomy processing and composition analysis code  
**Contains:**
- `rel_abundance_taxa_lowest.RDS` — Relative abundance by lowest identified taxonomic level
- `rel_abundance_taxa_family.RDS` — Relative abundance grouped at family level
- Optional scripts for taxonomic processing

---

### **05_figures/** - Publication-Ready Figures
**Purpose:** Store all final figures generated from analysis  
**Contains:**

| Figure | File Name | Analysis Type |
|--------|-----------|---------------|
| **Shannon Entropy** | `shannon_bodysite.jpeg` | Alpha diversity with statistical comparisons |
| **Taxa by Body Site** | `taxa_family_bodysite.jpeg` | Stacked bar plot (family level) across all body sites |
| **Taxa - Fecal Only** | `taxa_family_fecal.jpeg` | Stacked bar plot (family level) for fecal samples only |
| **PCoA Plot** | `unweighted_unifrac_pcoa.jpeg` | Beta diversity ordination with ellipses & p-values |

**All figures:** 300 dpi JPEG format, publication-ready dimensions (8x6 or 12x8 inches)

---

## Workflow & File Dependencies

### Analysis Flow:
```
Raw QIIME2 outputs (.qza, .qzv)
        ↓
Export to TSV (02_data/)
        ↓
Load into R Markdown (04_code/cow_HW4_r.Rmd)
        ↓
Combine with metadata (03_metadata/)
        ↓
Run analyses & generate figures
        ↓
Save to 05_figures/
```


**Last Updated:** April 9, 2026  
**Created for:** Easy navigation and reproducibility for HW4 guide 
