
---
course: ANEQ505
topic: Command Log (by Week)
tooling: Alpine (OnDemand) + QIIME2 + Git/Obsidian
---

# ANEQ505 — Commands by Week (What they do + when we use them)

> Tip: Copy/paste commands into code blocks as you run them and add short notes under **Notes / Output**.

---

## Week 1 — Office Hours Poll + Intro to Fridays + Alpine Basics



## Week 1 (Friday) — Alpine + OnDemand + Directory Basics + Metadata Intro

### A) Logging in (OnDemand → Terminal)
- **Goal:** Open an Alpine shell via OnDemand website.

Notes / Output:
- Bookmark saved: yes/no  
- Duo working: yes/no  

---

### B) Where am I? (Working directory)
```bash
pwd
```

What it does: Prints your current directory (where you “are” on the system).

Notes / Output:

Returned path:

C) List files in a directory
ls
ls -a
ls -l
What it does:

ls lists visible files

ls -a includes hidden “dot files”

ls -l long format (permissions, size, date)

Notes / Output:

Any unexpected files:

D) Move to scratch (absolute path)
cd /scratch/alpine/USER@colostate.edu
What it does: Changes directory to scratch (where we compute).
Why: Scratch is fast + large quota; home is small + not for compute.

Notes / Output:

Confirmed scratch:

E) Make a folder and move into it
mkdir test
cd test
What it does:

mkdir makes a directory

cd moves into it

Notes / Output:

Folder created successfully: yes/no

F) Go up one directory level
cd ../
What it does: Moves “up” one level (relative path navigation).

Notes / Output:

Now in:

G) Copy + rename files (metadata workflow)
mkdir metadata
cd metadata
cp /pl/active/courses/2025_summer/CSU_2025/q2_workshop_final/QIIME2/metadata_q2_workshop.txt .
mv metadata_q2_workshop.txt metadata.txt
What it does:

cp SOURCE . copies a file into current folder

mv old new renames/moves a file

Notes / Output:

metadata.txt present (check with ls): yes/no

H) Load QIIME2 (modules)
module purge
module load qiime2/2024.10_amplicon
What it does:

module purge clears loaded modules (avoid conflicts)

module load ... activates QIIME2 environment

Notes / Output:

Any caching message:

I) Make a QIIME2 visualization of metadata
qiime metadata tabulate \
  --m-input-file metadata.txt \
  --o-visualization metadata.qzv
What it does: Converts metadata into a .qzv viewable in view.qiime2.org.

Notes / Output:

Transferred metadata.qzv to laptop: yes/no

Variables noticed (facility, day, sample type, etc.):

J) Optional: Redirect TMP to scratch (edit .bashrc)
Add to ~/.bashrc:

export TMPDIR=/scratch/alpine/$USER/tmp
What it does: Forces temp files into scratch (often faster + avoids home quota issues).

Notes / Output:

Added successfully: yes/no

Week 2 (Friday) — Interactive Node + Project Folder Setup + Import Demuxed Reads (Manifest)
A) Start reserved interactive session (class node)
sinteractive --reservation=aneq505 --time=01:00:00 --partition=amilan --nodes=1 --ntasks=6 --qos=normal
What it does: Requests an interactive compute node reserved for class (so commands run “on compute” interactively).

Notes / Output:

Node allocated: yes/no

B) Load QIIME2 (again)
module purge
module load qiime2/2024.10_amplicon
C) Go to your tutorial folder
cd /scratch/alpine/$USER/decomp_tutorial
pwd
What it does: Moves to your analysis folder; pwd confirms location.

Notes / Output:

Confirmed path:

D) Create analysis subfolders (organization)
mkdir slurm taxonomy tree taxaplots dada2 demux core_metrics manifest
What it does: Creates standard directories so outputs don’t get messy.

Notes / Output:

Created all folders: yes/no

E) Copy manifest files (provided)
cp /pl/active/courses/2025_summer/CSU_2025/q2_workshop_final/QIIME2/manifest_run2.txt manifest/
cp /pl/active/courses/2025_summer/CSU_2025/q2_workshop_final/QIIME2/manifest_run3.txt manifest/
What it does: Copies text files listing sample IDs + paths to FASTQs.

Notes / Output:

Manifests present:

F) Copy demultiplexed reads folders (provided)
cp -r /pl/active/courses/2025_summer/CSU_2025/q2_workshop_final/QIIME2/reads_run2 .
cp -r /pl/active/courses/2025_summer/CSU_2025/q2_workshop_final/QIIME2/reads_run3 .
What it does: Copies per-sample FASTQs into your workspace.

Notes / Output:

Spot-check reads_run2 has .fastq.gz files: yes/no

G) Import reads into QIIME2 (manifest-based import)
qiime tools import \
  --type "SampleData[PairedEndSequencesWithQuality]" \
  --input-format PairedEndFastqManifestPhred33V2 \
  --input-path manifest/manifest_run2.txt \
  --output-path demux/demux_run2.qza

qiime tools import \
  --type "SampleData[PairedEndSequencesWithQuality]" \
  --input-format PairedEndFastqManifestPhred33V2 \
  --input-path manifest/manifest_run3.txt \
  --output-path demux/demux_run3.qza
What it does: Converts raw FASTQs into QIIME2 artifacts (.qza) with correct semantic type.

Notes / Output:

.qza files created: yes/no

H) Summarize demux quality
qiime demux summarize \
  --i-data demux/demux_run2.qza \
  --o-visualization demux/demux_run2.qzv

qiime demux summarize \
  --i-data demux/demux_run3.qza \
  --o-visualization demux/demux_run3.qzv
What it does: Creates interactive plots (read counts + quality profiles).

Notes / Output:

Read length:

Where quality drops:

Trim/trunc plan:

Week 3 (Friday) — DADA2 Denoising + Merge Runs + Feature Table + Rep Seqs
A) Denoise paired-end reads (run separately per run)
cd dada2

qiime dada2 denoise-paired \
  --i-demultiplexed-seqs ../demux/demux_run2.qza \
  --p-trunc-len-f 150 \
  --p-trunc-len-r 150 \
  --p-n-threads 8 \
  --o-table table_run2.qza \
  --o-representative-sequences seqs_run2.qza \
  --o-denoising-stats dada2_stats_run2.qza

qiime dada2 denoise-paired \
  --i-demultiplexed-seqs ../demux/demux_run3.qza \
  --p-trunc-len-f 150 \
  --p-trunc-len-r 150 \
  --p-n-threads 8 \
  --o-table table_run3.qza \
  --o-representative-sequences seqs_run3.qza \
  --o-denoising-stats dada2_stats_run3.qza
What it does: Quality-filters, merges pairs, removes chimeras, outputs ASVs:

table_*.qza (feature table)

seqs_*.qza (rep sequences)

dada2_stats_*.qza (per-sample read retention)

Notes / Output:

Trunc params used:

Runtime:

Any sample with big read loss:

B) Visualize DADA2 stats
qiime metadata tabulate \
  --m-input-file dada2_stats_run2.qza \
  --o-visualization dada2_stats_run2.qzv

qiime metadata tabulate \
  --m-input-file dada2_stats_run3.qza \
  --o-visualization dada2_stats_run3.qzv
What it does: Makes the stats readable in QIIME2 View.

Notes / Output:

Lowest % non-chimeric sample:

Overall retention looks OK?:

C) Merge feature tables (multiple runs → one dataset)
qiime feature-table merge \
  --i-tables table_run2.qza \
  --i-tables table_run3.qza \
  --o-merged-table table.qza
What it does: Combines ASV counts across runs into one feature table.

Notes / Output:

table.qza created: yes/no

D) Summarize merged feature table
qiime feature-table summarize \
  --i-table table.qza \
  --o-visualization table.qzv \
  --m-sample-metadata-file ../metadata/metadata.txt
What it does: Gives per-sample and per-feature counts + links metadata.

Notes / Output:

samples:
Min reads:

Max reads:

E) Merge representative sequences
qiime feature-table merge-seqs \
  --i-data seqs_run2.qza \
  --i-data seqs_run3.qza \
  --o-merged-data seqs.qza
What it does: Combines ASV sequences into one artifact.

Notes / Output:

seqs.qza created:

F) Tabulate rep sequences (viewable)
qiime feature-table tabulate-seqs \
  --i-data seqs.qza \
  --o-visualization seqs.qzv
What it does: Lets you view ASV IDs and sequences.

Notes / Output:

Clicking sequence shows:

Any weird lengths:

Week 3 (Friday) — Running Jobs on Alpine (Slurm)
A) Submit a test batch job
Create slurm/test.sh:

#!/bin/bash
#SBATCH --job-name=test
#SBATCH --nodes=1
#SBATCH --ntasks=2
#SBATCH --partition=amilan
#SBATCH --time=01:00:00
#SBATCH --mail-type=ALL
#SBATCH --mail-user=YOUR_USERNAME@colostate.edu
#SBATCH --output=slurm-%j.out
#SBATCH --qos=normal

module purge
module load qiime2/2024.10_amplicon

OUTFILE="message_${SLURM_JOB_ID}.txt"
echo "status report" > $OUTFILE
echo "Job ID: $SLURM_JOB_ID" >> $OUTFILE
echo "Node: $(hostname)" >> $OUTFILE
echo "Timestamp: $(date)" >> $OUTFILE
echo "You ran your first job!" >> $OUTFILE
Submit:

sbatch slurm/test.sh
What it does: Runs commands on compute nodes without you babysitting it.

Notes / Output:

Job ID:

Output file created:

Week 4 (Friday) — Taxonomy + Taxa Barplots + Filtering + Rarefaction + Trees (SEPP)
A) Download a pretrained classifier (Greengenes 515–806)
wget -O "gg-13-8-99-515-806-nb-classifier.qza" \
  "https://data.qiime2.org/2023.5/common/gg-13-8-99-515-806-nb-classifier.qza"
What it does: Downloads a pretrained Naive Bayes classifier.

Notes / Output:

File size:

Download successful:

B) Classify taxonomy (sklearn)
qiime feature-classifier classify-sklearn \
  --i-reads seqs.qza \
  --i-classifier gg-13-8-99-515-806-nb-classifier.qza \
  --o-classification taxonomy.qza
What it does: Assigns taxonomy labels to ASVs.

Notes / Output:

Runtime:

Any “Unassigned” heavy patterns:

C) View taxonomy
qiime metadata tabulate \
  --m-input-file taxonomy.qza \
  --o-visualization taxonomy.qzv
D) Taxa barplot (composition)
qiime taxa barplot \
  --i-table table.qza \
  --i-taxonomy taxonomy.qza \
  --m-metadata-file metadata/metadata.txt \
  --o-visualization taxaplots/taxa_barplot.qzv
What it does: Stacked barplots by taxonomic level + metadata grouping.

Notes / Output:

Biggest phyla:

Clear grouping by facility/soil vs skin:

E) Filter common contaminants (mitochondria/chloroplast)
qiime taxa filter-table \
  --i-table table.qza \
  --i-taxonomy taxonomy.qza \
  --p-exclude mitochondria,chloroplast \
  --o-filtered-table table-no-mito-no-chloro.qza
What it does: Removes features annotated as mito/chloro.

Notes / Output:

Features removed?:

Why might none be present?:

F) Rarefaction curves (choose sampling depth)
qiime diversity alpha-rarefaction \
  --i-table table-no-mito-no-chloro.qza \
  --m-metadata-file metadata/metadata.txt \
  --o-visualization core_metrics/alpha_rarefaction.qzv \
  --p-min-depth 10 \
  --p-max-depth 4900
What it does: Shows richness/evenness vs depth; helps pick rarefaction depth.

Notes / Output:

Depth where curves level off:

Samples lost at higher depth?:

G) SEPP phylogenetic tree (reference insertion)
wget -O "sepp-refs-gg-13-8.qza" \
  "https://data.qiime2.org/2023.5/common/sepp-refs-gg-13-8.qza"
Create tree/sepp_script.sh and submit:

#!/bin/sh
#SBATCH --job-name=sepp
#SBATCH --nodes=1
#SBATCH --ntasks=24
#SBATCH --partition=amilan
#SBATCH --time=01:00:00
#SBATCH --mail-type=ALL
#SBATCH --mail-user=YOUR_EMAIL@colostate.edu

module purge
module load qiime2/2024.10_amplicon

qiime fragment-insertion sepp \
  --i-representative-sequences seqs.qza \
  --i-reference-database sepp-refs-gg-13-8.qza \
  --o-tree tree/tree.qza \
  --o-placements tree/tree_placements.qza
Submit:

sbatch tree/sepp_script.sh
What it does: Builds a phylogenetic tree needed for phylogenetic diversity metrics.

Notes / Output:

Job ID:

Completed successfully:

Quick Reference — Command “Dictionary”
Navigation / Files
pwd → print working directory

ls → list files

cd PATH → change directory

mkdir NAME → make directory

cp SRC DEST → copy

mv OLD NEW → move/rename

wget -O file URL → download from web

Alpine / Jobs
sinteractive ... → interactive compute session (class reservation)

module purge → clear modules

module load X → load environment

sbatch script.sh → submit batch job

QIIME2 Core
qiime tools import → import raw data into .qza

qiime demux summarize → visualize read counts + quality

qiime dada2 denoise-paired → ASVs + chimera removal + merging pairs

qiime feature-table merge → merge runs

qiime feature-table summarize → table stats

qiime feature-table tabulate-seqs → view sequences

qiime feature-classifier classify-sklearn → taxonomy assignment

qiime taxa barplot → composition barplots

qiime taxa filter-table → remove unwanted taxa

qiime diversity alpha-rarefaction → rarefaction curves

qiime fragment-insertion sepp → build phylogenetic tree

To-Do / Next Week
Add “core-metrics-phylogenetic” workflow once introduced

Add beta diversity + PERMANOVA commands when covered

Add longitudinal/time-series methods if used