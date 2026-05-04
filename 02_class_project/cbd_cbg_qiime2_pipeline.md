# CBD/CBG Gnotobiotic Microbiome — QIIME2 Processing Pipeline

**Author:** Eliud R. Rivas Hernandez  
**HPC:** Alpine (RMACC), partition `amilan`  
**QIIME2 version:** 2024.10 amplicon  
**Experiment:** Longitudinal 16S rRNA microbiome profiling of germ-free C57BL/6J mice  
dosed with Placebo, CBD, or CBG across three timepoints (Bl, W2, W4). s

This pipeline was run in **two parallel tracks**:

| Track | Read mode | DADA2 command | Notes |
|:------|:----------|:--------------|:------|
| Paired-end | Both F + R reads | `denoise-paired` | Longer ASVs, higher quality |
| Forward-only (single-end) | Forward reads only | `denoise-single` | Used when reverse reads were low quality |

Both tracks share the same taxonomy classifiers, SEPP tree backbone, and metadata file.    

---

## Step 1 — Demultiplexing

Demultiplexing assigns raw sequencing reads to individual samples based on their
unique barcode sequences. The EMP (Earth Microbiome Project) paired-end protocol
was used, where barcodes are embedded in the reverse read. This step produces a
per-sample FASTQ artifact that DADA2 can process.   

> **Note:** Demultiplexing was performed in a separate upstream script using
> `qiime demux emp-paired` (paired-end) and `qiime demux emp-single`
> additionally, `--p-rev-comp-mapping-barcodes` was changed to `--p-no-golay-error-correction` due to primers used for this experiment, which was confirmed due to low reads when using the `--p-rev-comp-mapping-barcodes`.
> (forward-only). The outputs `p_demux/p_demux.qza` and `f_demux/f_demux.qza`
> are the starting inputs for the steps below.

To inspect read quality and determine truncation lengths before denoising:

```bash

# Paired-end quality summary
qiime demux summarize \
  --i-data p_demux/p_demux.qza \
  --o-visualization p_demux/p_demux.qzv

# Forward-only quality summary
qiime demux summarize \
  --i-data f_demux/f_demux.qza \
  --o-visualization f_demux/f_demux.qzv
```

---

## Step 2 — Denoising with DADA2

DADA2 models the error profile of the sequencing run to distinguish true
biological sequence variants (ASVs) from sequencing errors. It performs
quality filtering, chimera removal, and merging of paired reads (in the
paired-end track), producing a feature table of ASV counts per sample and
a set of representative sequences. ASVs are preferable to OTUs because they
provide single-nucleotide resolution without clustering-induced information loss.    

Truncation lengths were chosen based on the demux quality summary: reads were
truncated at 250 bp (forward) and 225 bp (reverse) where median quality scores
dropped below Q25.    

### Paired-end track

```bash
qiime dada2 denoise-paired \
  --i-demultiplexed-seqs p_demux/p_demux.qza \
  --p-trunc-len-f 250 \
  --p-trunc-len-r 225 \
  --p-n-threads 4 \
  --o-table p_dada2/table.qza \
  --o-representative-sequences p_dada2/seqs.qza \
  --o-denoising-stats p_dada2/dada2_stats.qza

# Visualize denoising stats
qiime metadata tabulate \
  --m-input-file p_dada2/dada2_stats.qza \
  --o-visualization p_dada2/dada2_stats.qzv

# Summarize feature table with metadata
qiime feature-table summarize \
  --i-table p_dada2/table.qza \
  --o-visualization p_dada2/table.qzv \
  --m-sample-metadata-file metadata/merged_q2_metadata.txt

qiime feature-table tabulate-seqs \
  --i-data p_dada2/seqs.qza \
  --o-visualization p_dada2/seqs.qzv
```

### Forward-only (single-end) track

```bash
qiime dada2 denoise-single \
  --i-demultiplexed-seqs f_demux/f_demux.qza \
  --p-trunc-len 250 \
  --p-n-threads 4 \
  --o-table f_dada2/f_table.qza \
  --o-representative-sequences f_dada2/f_seqs.qza \
  --o-denoising-stats f_dada2/f_dada2_stats.qza

qiime metadata tabulate \
  --m-input-file f_dada2/f_dada2_stats.qza \
  --o-visualization f_dada2/f_dada2_stats.qzv

qiime feature-table summarize \
  --i-table f_dada2/f_table.qza \
  --o-visualization f_dada2/f_table.qzv \
  --m-sample-metadata-file metadata/merged_q2_metadata.txt

qiime feature-table tabulate-seqs \
  --i-data f_dada2/f_seqs.qza \
  --o-visualization f_dada2/f_seqs.qzv
```

---

## Step 3a — Taxonomic Classification with Greengenes2 (2024.09)

Taxonomic classification assigns each ASV a taxonomic label by comparing it
against a reference database using a naive Bayes classifier pre-trained on the
V4 hypervariable region (515F–806R). Greengenes2 (2024.09) provides a
comprehensive, curated reference phylogeny with updated taxonomy. The
pre-trained V4 classifier is downloaded directly from the Greengenes2 FTP
server, avoiding the need to train from scratch.    

After classification, the feature table is filtered to remove non-target
sequences: mitochondria, chloroplasts, and the unclassified placeholder
`sp004296775`. Only features with a class-level assignment (`c__`) are retained,
ensuring downstream analyses reflect true bacterial diversity.    

### Paired-end track

```bash
# Download pre-trained GG2 V4 NB classifier (once)
wget --no-check-certificate \
  -O taxonomy/gg2/2024.09.backbone.v4.nb.qza \
  https://ftp.microbio.me/greengenes_release/2024.09/2024.09.backbone.v4.nb.qza

# Classify ASVs
qiime feature-classifier classify-sklearn \
  --i-reads p_dada2/seqs.qza \
  --i-classifier taxonomy/gg2/2024.09.backbone.v4.nb.qza \
  --p-n-jobs 4 \
  --o-classification taxonomy/gg2/taxonomy_gg2.qza

qiime metadata tabulate \
  --m-input-file taxonomy/gg2/taxonomy_gg2.qza \
  --o-visualization taxonomy/gg2/taxonomy_gg2.qzv

# Filter: remove mito, chloroplast, unclassified
qiime taxa filter-table \
  --i-table p_dada2/table.qza \
  --i-taxonomy taxonomy/gg2/taxonomy_gg2.qza \
  --p-exclude mitochondria,chloroplast,sp004296775 \
  --p-include c__ \
  --o-filtered-table p_dada2/table_nmnc_gg2.qza

qiime feature-table summarize \
  --i-table p_dada2/table_nmnc_gg2.qza \
  --o-visualization p_dada2/table_nmnc_gg2.qzv \
  --m-sample-metadata-file metadata/merged_q2_metadata.txt

qiime taxa barplot \
  --i-table p_dada2/table_nmnc_gg2.qza \
  --i-taxonomy taxonomy/gg2/taxonomy_gg2.qza \
  --m-metadata-file metadata/merged_q2_metadata.txt \
  --o-visualization p_taxaplots/taxa_barplot_gg2.qzv
```

### Forward-only (single-end) track

```bash
# Classifier is shared — reused from paired-end track

qiime feature-classifier classify-sklearn \
  --i-reads f_dada2/f_seqs.qza \
  --i-classifier taxonomy/gg2/2024.09.backbone.v4.nb.qza \
  --p-n-jobs 4 \
  --o-classification taxonomy/gg2/f_taxonomy_gg2.qza

qiime metadata tabulate \
  --m-input-file taxonomy/gg2/f_taxonomy_gg2.qza \
  --o-visualization taxonomy/gg2/f_taxonomy_gg2.qzv

qiime taxa filter-table \
  --i-table f_dada2/f_table.qza \
  --i-taxonomy taxonomy/gg2/f_taxonomy_gg2.qza \
  --p-exclude mitochondria,chloroplast,sp004296775 \
  --p-include c__ \
  --o-filtered-table f_dada2/f_table_nmnc_gg2.qza

qiime feature-table summarize \
  --i-table f_dada2/f_table_nmnc_gg2.qza \
  --o-visualization f_dada2/f_table_nmnc_gg2.qzv \
  --m-sample-metadata-file metadata/merged_q2_metadata.txt

qiime taxa barplot \
  --i-table f_dada2/f_table_nmnc_gg2.qza \
  --i-taxonomy taxonomy/gg2/f_taxonomy_gg2.qza \
  --m-metadata-file metadata/merged_q2_metadata.txt \
  --o-visualization f_taxaplots/f_taxa_barplot_gg2.qzv
```

---

## Step 3b — Taxonomic Classification with SILVA 138

SILVA 138 NR99 is a widely used ribosomal RNA database with curated,
non-redundant sequences clustered at 99% identity. Because no pre-trained
SILVA V4 classifier was available for QIIME2 2024.10, the naive Bayes
classifier was trained from scratch using the region-specific reference
sequences (515F–806R). Training is computationally intensive (>1 hr, >32 GB
RAM) but only needs to be done once; the resulting classifier is reused for
both pipeline tracks.    

Filtering retains only features assigned at phylum level or below (`p__`),
removing mitochondria and chloroplasts.   

### Paired-end track

```bash
# Download SILVA 138 NR99 V4 reference files (once)
wget --no-check-certificate \
  -O taxonomy/silva/silva-138-99-seqs-515-806.qza \
  https://data.qiime2.org/2024.2/common/silva-138-99-seqs-515-806.qza

wget --no-check-certificate \
  -O taxonomy/silva/silva-138-99-tax-515-806.qza \
  https://data.qiime2.org/2024.2/common/silva-138-99-tax-515-806.qza

# Train classifier (once — shared across both tracks)
qiime feature-classifier fit-classifier-naive-bayes \
  --i-reference-reads taxonomy/silva/silva-138-99-seqs-515-806.qza \
  --i-reference-taxonomy taxonomy/silva/silva-138-99-tax-515-806.qza \
  --o-classifier taxonomy/silva/silva-138-99-515-806-nb-classifier.qza

# Classify ASVs
qiime feature-classifier classify-sklearn \
  --i-reads p_dada2/seqs.qza \
  --i-classifier taxonomy/silva/silva-138-99-515-806-nb-classifier.qza \
  --p-n-jobs 4 \
  --o-classification taxonomy/silva/taxonomy_silva.qza

qiime metadata tabulate \
  --m-input-file taxonomy/silva/taxonomy_silva.qza \
  --o-visualization taxonomy/silva/taxonomy_silva.qzv

# Filter: remove mito, chloroplast; retain phylum-assigned features
qiime taxa filter-table \
  --i-table p_dada2/table.qza \
  --i-taxonomy taxonomy/silva/taxonomy_silva.qza \
  --p-exclude mitochondria,chloroplast \
  --p-include p__ \
  --o-filtered-table p_dada2/table_nmnc_silva.qza

qiime feature-table summarize \
  --i-table p_dada2/table_nmnc_silva.qza \
  --o-visualization p_dada2/table_nmnc_silva.qzv \
  --m-sample-metadata-file metadata/merged_q2_metadata.txt

qiime taxa barplot \
  --i-table p_dada2/table_nmnc_silva.qza \
  --i-taxonomy taxonomy/silva/taxonomy_silva.qza \
  --m-metadata-file metadata/merged_q2_metadata.txt \
  --o-visualization p_taxaplots/taxa_barplot_silva.qzv
```

### Forward-only (single-end) track

```bash
# Classifier is shared — reused from paired-end track

qiime feature-classifier classify-sklearn \
  --i-reads f_dada2/f_seqs.qza \
  --i-classifier taxonomy/silva/silva-138-99-515-806-nb-classifier.qza \
  --p-n-jobs 4 \
  --o-classification taxonomy/silva/f_taxonomy_silva.qza

qiime metadata tabulate \
  --m-input-file taxonomy/silva/f_taxonomy_silva.qza \
  --o-visualization taxonomy/silva/f_taxonomy_silva.qzv

qiime taxa filter-table \
  --i-table f_dada2/f_table.qza \
  --i-taxonomy taxonomy/silva/f_taxonomy_silva.qza \
  --p-exclude mitochondria,chloroplast \
  --p-include p__ \
  --o-filtered-table f_dada2/f_table_nmnc_silva.qza

qiime feature-table summarize \
  --i-table f_dada2/f_table_nmnc_silva.qza \
  --o-visualization f_dada2/f_table_nmnc_silva.qzv \
  --m-sample-metadata-file metadata/merged_q2_metadata.txt

qiime taxa barplot \
  --i-table f_dada2/f_table_nmnc_silva.qza \
  --i-taxonomy taxonomy/silva/f_taxonomy_silva.qza \
  --m-metadata-file metadata/merged_q2_metadata.txt \
  --o-visualization f_taxaplots/f_taxa_barplot_silva.qzv
```

---

## Step 4 — Phylogenetic Placement (SEPP, Greengenes2 backbone)

A phylogenetic tree is required for phylogeny-aware diversity metrics such as
Faith's Phylogenetic Diversity and weighted/unweighted UniFrac. Rather than
building a de novo tree (which can be unstable with short amplicon reads),
SEPP (SATé-Enabled Phylogenetic Placement) inserts each ASV into a
high-quality reference phylogeny by finding its most likely placement. The
Greengenes2 2022.10 backbone is used as the reference, as it is the most
comprehensive curated reference available for QIIME2 fragment insertion.    

The resulting rooted insertion tree is shared across both the GG2 and SILVA
taxonomy branches within each read-mode track, since the tree is built from
ASV sequences directly and is independent of which database classified them.    

### Paired-end track

```bash
# Download GG2 2022.10 SEPP backbone (once — shared across both tracks)
wget --no-check-certificate \
  -O taxonomy/gg2/2022.10.backbone.sepp-reference.qza \
  https://ftp.microbio.me/greengenes_release/2022.10/2022.10.backbone.sepp-reference.qza

qiime fragment-insertion sepp \
  --i-representative-sequences p_dada2/seqs.qza \
  --i-reference-database taxonomy/gg2/2022.10.backbone.sepp-reference.qza \
  --p-threads 4 \
  --o-tree p_tree/tree_gg2.qza \
  --o-placements p_tree/tree_gg2_placements.qza
```

### Forward-only (single-end) track

```bash
# SEPP backbone is shared — reused from paired-end track

qiime fragment-insertion sepp \
  --i-representative-sequences f_dada2/f_seqs.qza \
  --i-reference-database taxonomy/gg2/2022.10.backbone.sepp-reference.qza \
  --p-threads 4 \
  --o-tree f_tree/f_tree_gg2.qza \
  --o-placements f_tree/f_tree_gg2_placements.qza
```

> **Note on tree reuse:** The insertion tree (`*_tree_gg2.qza`) is used for
> Faith's PD and UniFrac calculations in **both** the GG2 and SILVA taxonomy
> branches within each track. This is valid because SEPP operates on the raw
> ASV nucleotide sequences, not on taxonomic labels — the same sequences are
> used regardless of which database classified them.

---

## Output file summary

| File | Description |
|:-----|:------------|
| `p_dada2/table_nmnc_gg2.qza` | Paired-end filtered feature table (GG2) |
| `p_dada2/table_nmnc_silva.qza` | Paired-end filtered feature table (SILVA) |
| `f_dada2/f_table_nmnc_gg2.qza` | Forward-only filtered feature table (GG2) |
| `f_dada2/f_table_nmnc_silva.qza` | Forward-only filtered feature table (SILVA) |
| `taxonomy/gg2/taxonomy_gg2.qza` | GG2 taxonomy (paired-end ASVs) |
| `taxonomy/gg2/f_taxonomy_gg2.qza` | GG2 taxonomy (forward-only ASVs) |
| `taxonomy/silva/taxonomy_silva.qza` | SILVA taxonomy (paired-end ASVs) |
| `taxonomy/silva/f_taxonomy_silva.qza` | SILVA taxonomy (forward-only ASVs) |
| `p_tree/tree_gg2.qza` | Insertion tree (paired-end, GG2 backbone) |
| `f_tree/f_tree_gg2.qza` | Insertion tree (forward-only, GG2 backbone) |

These outputs are copied to `data/qiime_exports/` in the R project and
imported into `microeco` via `file2meco::qiime2meco()` for downstream
diversity analyses.
