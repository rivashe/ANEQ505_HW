#!/bin/bash
#SBATCH --job-name=cow_hw1
#SBATCH --nodes=1
#SBATCH --ntasks=12
#SBATCH --partition=amilan
#SBATCH --time=04:00:00
#SBATCH --mail-type=ALL
#SBATCH --output=/scratch/alpine/%u/aneq505/hw1/slurm/slurm-%j.out
#SBATCH --qos=normal
#SBATCH --mail-user=c837169103@colostate.edu

# =============================================================================
# HW1: COW DATASET — Import, Demultiplex, Denoise
# Path: /scratch/alpine/$USER/aneq505/hw1
# =============================================================================

# Stop on first error so we don't silently skip steps
set -e

# Activate qiime2
module purge
module load qiime2/2024.10_amplicon

# --- IMPORT (ALREADY COMPLETED — skip to avoid overwrite error) ---
# cow_reads.qza already exists (4.38 GB). Uncomment below ONLY if you
# need to redo the import from scratch (delete cow_reads.qza first).
#
# cd /scratch/alpine/$USER/aneq505/hw1
# echo ">>> Importing raw reads..."
# qiime tools import \
#   --type EMPPairedEndSequences \
#   --input-path raw_reads \
#   --output-path cow_reads.qza

# --- DEMULTIPLEX ---
cd /scratch/alpine/$USER/aneq505/hw1/demux
echo ">>> Demultiplexing..."
qiime demux emp-paired \
  --m-barcodes-file ../metadata/cow_barcodes.txt \
  --m-barcodes-column barcode \
  --p-rev-comp-mapping-barcodes \
  --p-rev-comp-barcodes \
  --i-seqs ../cow_reads.qza \
  --o-per-sample-sequences demux_cow.qza \
  --o-error-correction-details cow_demux_error.qza

echo ">>> Generating demux summary..."
qiime demux summarize \
  --i-data demux_cow.qza \
  --o-visualization demux_cow.qzv

# --- DENOISE ---
# NOTE: Check demux_cow.qzv FIRST to pick trim/trunc values!
# The values below (trim 0/0, trunc 240/200) are starting estimates.
# Adjust based on YOUR quality plot, then re-run this section.
cd /scratch/alpine/$USER/aneq505/hw1/dada2
echo ">>> Denoising with DADA2..."
qiime dada2 denoise-paired \
  --i-demultiplexed-seqs ../demux/demux_cow.qza \
  --p-trim-left-f 0 \
  --p-trim-left-r 0 \
  --p-trunc-len-f 250 \
  --p-trunc-len-r 250 \
  --p-n-threads 6 \
  --o-representative-sequences cow_seqs_dada2.qza \
  --o-denoising-stats cow_dada2_stats.qza \
  --o-table cow_table_dada2.qza

# --- VISUALIZATIONS ---
echo ">>> Generating visualizations..."
qiime metadata tabulate \
  --m-input-file cow_dada2_stats.qza \
  --o-visualization cow_dada2_stats.qzv

qiime feature-table summarize \
  --i-table cow_table_dada2.qza \
  --m-sample-metadata-file ../metadata/cow_metadata.txt \
  --o-visualization cow_table_dada2.qzv

qiime feature-table tabulate-seqs \
  --i-data cow_seqs_dada2.qza \
  --o-visualization cow_seqs_dada2.qzv

echo ">>> All done!"

##### END OF SCRIPT ####