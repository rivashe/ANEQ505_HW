

---

# Week 3 – Denoising and Taxonomy

## Microbiome data processing overview

- Typical workflow: study design → sample collection/storage → DNA extraction → library prep → sequencing → demultiplexing → quality processing → denoising/clustering → feature table + rep‑seqs → taxonomy → diversity and downstream stats.​
    
- Pre‑study questions: Is 16S right for my question, what sample size, what body site/environment, what metadata, what confounders (diet, age, sex, housing, facility)?Week5-Mon-high-quality-data.pdf+1
    

## Wet‑lab considerations

- Field handling: consistent collection method (swab, feces, biopsy, water filter), minimize time to preservation, consider biomass and contamination risk.Week3_Mon_denoising_02-02-26.pdf+1
    
- Lysis options:
    
    - Mechanical: bead beating, vortex with beads, homogenizer, improves recovery of Gram‑positive and tough cells​
        
    - Non‑mechanical: heat, freeze–thaw, sonication​
        
    - Chemical/enzymatic: detergents, alkali, lysozyme, proteinase K; often combined with mechanical lysis in commercial kits.
        

---

## Importing and demultiplexing

## FASTQ structure and quality

- FASTQ record: header line (sequencer ID, lane, etc.), sequence line, placeholder line, quality string with ASCII‑encoded Phred scores.week4_Mon_Alpha_lecture.pdf+1
    
- Phred Q score: Q10 (90% accuracy), Q20 (99%), Q30 (99.9%); in Illumina encoding, character = Q + 33 in ASCII.
    

## Import and demux in QIIME2

- Common QIIME2 semantic types: `SampleData[SequencesWithQuality]`, `SampleData[PairedEndSequencesWithQuality]`, `FeatureTable[Frequency]`, `FeatureData[Sequence]`, `FeatureData[Taxonomy]`, `Phylogeny[Rooted]`, etc.week4_Mon_Alpha_lecture.pdf+1
    
- Demultiplexing:
    
    - Demultiplexed data: one FASTQ (or pair) per sample; can import with CASAVA or manifest formats​
        
    - Multiplexed data with separate barcodes.fastq: import as EMP (single/paired) and use q2‑demux to split by barcodes.week4_Mon_Alpha_lecture.pdf+1
        
- If you do not demultiplex: reads from multiple samples are mixed, so sample‑level inference (diversity, differential abundance) is meaningless.

---

## Denoising vs clustering; ASVs vs OTUs

## Denoising

- Denoising algorithms (DADA2, Deblur, MED, UNOISE3) model sequencing errors and infer **exact** amplicon sequence variants (ASVs/ESVs).paste.txt+1
    
- Key features:
    
    - Use quality profiles, error models, and expected abundance patterns.
        
    - Remove low‑quality reads, truncate reads at chosen length (3′) and optionally trim from 5′.​
        
    - Identify and remove chimeras, PhiX, and other artifacts.
- DADA2 in QIIME2:
    
    - Example command:  
        `qiime dada2 denoise-single --i-demultiplexed-seqs demux.qza --p-trim-left 0 --p-trunc-len 120 --o-representative-sequences rep-seqs-dada2.qza --o-table table-dada2.qza --o-denoising-stats stats-dada2.qza`.​
        
    - `stats.qza` reports per‑sample reads: input → filtered → denoised → merged (for paired) → non‑chimeric.paste.txt+1
        

## OTU clustering

- OTU clustering (e.g., q2‑vsearch, usearch, mothur) groups reads by sequence similarity (often 97%).​
    
- Pros:
    
    - Historically standard, robust to some error.
        
- Cons:
    
    - Groups distinct but similar taxa, losing fine‑scale diversity.
        
    - OTUs depend on clustering threshold and algorithm.​
        

## ASVs vs OTUs – conceptual differences

- ASVs: unique sequences after error correction; consistent labels across studies using the same region and method.
- OTUs: operational bins defined per‑study; not directly comparable across independent pipelines.​
    
- Caveat: 16S rRNA copy number variation can produce multiple slightly different 16S copies within a single genome; over‑splitting with ultra‑fine thresholds could split one genome into multiple ASVs.​
    

---

## Choosing trim and truncation parameters

- Use demux quality plots (`demux.qzv`) to:
    
    - Identify where median quality drops sharply; truncate before the crash.week4_Mon_Alpha_lecture.pdf+1
        
    - Optionally trim low‑quality leading bases or primers (e.g., trim‑left 19 to remove 515f primer).​
        
- For paired‑end:
    
    - Ensure enough overlap after truncation; e.g., 2×150 bp on a 250 bp amplicon: 150 + 150 − 250 = 50 bp overlap.​
        
    - Too aggressive truncation → merge failures → apparent low diversity and many lost reads.paste.txt+1
        

---

## Outputs after denoising

- `table.qza`: feature table (samples × ASVs) with counts.week4_Mon_Alpha_lecture.pdf+1
    
- `rep-seqs.qza`: FASTA sequences of each feature.week4_Mon_Alpha_lecture.pdf+1
    
- `stats.qza`: denoising stats for troubleshooting.​
    
- After phylogeny: `rooted-tree.qza` for phylogenetic diversity and UniFrac.Week3_Wed_taxonomy_02-03-26.pdf+1
    

---

## Taxonomy – assignment and use

## Why taxonomy matters

- Scientific communication: interpretible names (e.g., “increase in Bacteroidetes” rather than “Feature 23”).​
    
- Quality control:
    
    - Detect host mitochondria and chloroplast (plant) reads.​
        
    - Identify obvious contaminants: unexpected taxa given sample type (e.g., soil taxa dominating air blanks).Week5-Mon-high-quality-data.pdf+1
        
- Biology and function:
    
    - Related taxa often share functional potentials and ecological roles.​
        

## How taxonomy is assigned

- Inputs: representative sequences (`FeatureData[Sequence]`) and a reference database (`FeatureData[Sequence]` + `FeatureData[Taxonomy]`)
- Common reference databases:
    
    - Greengenes2, SILVA, RDP, UNITE (fungal ITS), RefSeq, GenBank, GTDB, Web of Life.​
        
- Methods:
    
    - Alignment‑based: VSEARCH, BLAST; nearest‑neighbor or consensus taxonomy.​
        
    - Machine learning: Naive Bayes classifiers (e.g., q2‑feature‑classifier, RDP classifier) using k‑mer features
- k‑mer representation:
    
    - Decompose sequences into overlapping words of length k (e.g., 7‑mers); frequency of k‑mers used as features for ML classifier.​
        
- Training classifiers:
    
    - Use reference sequences trimmed to the same region (e.g., 16S V4) and reference taxonomies.​
        
    - Weighted classifiers incorporate environment‑specific taxon prevalence (e.g., human gut vs vaginal vs soil) and can improve precision​
        

## Database choice and ambiguity

- Different databases can yield different taxonomic labels at genus/species ranks for the same ASV.​
    
- Some sequences cannot be reliably classified to species (e.g., identical V4 segments for Lactobacillus helveticus vs L. hamsteri); context (host, habitat) matters for interpretation.
    

## Using taxonomy for QC and filtering

- Common filters:
    
    - Remove mitochondria and chloroplast sequences in animal/plant‑associated 16S datasets using `qiime taxa filter-table`.
    - Remove unassigned or very low‑confidence assignments at high ranks if appropriate for downstream analyses.​
        
- Taxonomic barplots:
    
    - Visualize relative abundance per sample; can reveal unexpected dominance of contaminants or host organelles.
        

---

# Week 4 – Alpha diversity and rarefaction

## Definitions and concepts

- **Alpha diversity**: diversity **within** a sample (e.g., richness, evenness, phylogenetic diversity).
    
- **Beta diversity**: differences **between** samples/communities (composition and structure).
    
- **Community richness**: number of distinct features (ASVs/OTUs) in a sample; often loosely used as “alpha diversity” in microbiome papers.
    

## Non‑phylogenetic alpha metrics

- Observed OTUs / Observed ASVs:
    
    - Simple richness: count of features with non‑zero abundance in a sample.
        
- Shannon diversity:
    
    - Combines richness and evenness.
        
    - H=−∑ipilog⁡piH = -\sum_i p_i \log p_iH=−∑ipilogpi, where pip_ipi is the relative abundance of feature i.
    - Two samples with identical richness but different dominance patterns can differ in Shannon.paste.txt+1
        

## Phylogenetic alpha metrics

- Faith’s Phylogenetic Diversity (PD):
    
    - Sum of branch lengths in the phylogenetic tree spanned by the ASVs present in a sample.
        
    - Captures phylogenetic breadth; communities with the same richness but spanning more distant clades have higher PD.
        

---

## Sequencing depth and rarefaction

## Why uneven depth is a problem

- Diversity metrics depend on sampling effort:
    
    - More reads → higher chance of detecting rare taxa → higher observed richness and sometimes higher Shannon.
        
- Example: a sample with 20,000 reads will almost always appear more diverse than one with 1,000 reads, even if underlying communities are identical.]​
    

## Rarefaction (subsampling without replacement)

- Concept:
    
    - Choose an even sampling depth (e.g., 5,000 reads).
        
    - For each sample with ≥ depth, randomly subsample that many reads **without replacement**; samples below that depth are dropped.paste.txt+1
        
- Purpose:
    
    - Remove confounding of diversity by sequencing depth, making alpha/beta comparisons more interpretable.​
        
- Limitations:
    
    - Discards data, especially from high‑depth samples.
        
    - Choice of depth is subjective and can bias which samples are retained.paste.txt+1
        
    - Controversial for differential abundance; some argue normalization + appropriate tests are preferable in that context.

## Rarefaction curves

- Plot: x‑axis = sequencing depth; y‑axis = richness (or other alpha metric); curve for each sample.
- Use:
    
    - Identify depth beyond which adding more reads yields diminishing returns (curve flattens); this is a reasonable rarefaction depth.paste.txt+1
        
    - Avoid depths where curves are still increasing steeply; new taxa are still being discovered.​
        
- Practical rules of thumb (for gut samples):
    
    - Many gut communities achieve most richness at ~5,000–10,000 reads; 20–30k is often more than sufficient.paste.txt+1
        
    - Modern datasets often provide 20–50k reads per sample, so alpha diversity is relatively robust to small depth differences in that range.paste.txt+1
        

## Alternatives to rarefaction

- Normalization approaches (e.g., scaling to library size, log‑ratio transforms, compositional methods) can be used for:
    
    - Differential abundance.
        
    - Some beta diversity metrics (with appropriate modeling).​
        
- However, for many standard QIIME2 workflows of alpha and beta diversity, rarefaction remains common, with awareness of its tradeoffs.paste.txt+1
    

---

## Comparing alpha diversity

- Visualization:
    
    - Boxplots/violin plots: alpha metrics by treatment, group, timepoint.
    - Scatterplots: alpha vs continuous variables (e.g., BMI, age, diet diversity)
        
- Statistical tests:
    
    - Kruskal–Wallis or Wilcoxon for group comparisons (non‑parametric​)
        
    - Spearman correlation for relationships with continuous variables​
        

---

## Biological patterns and dogma

## Which environments are most diverse?

- Soil and sediment typically show very high microbial diversity, often exceeding host‑associated sites.paste.txt+1
    
- Within host‑associated habitats, the gut (especially hindgut/rumen) tends to have higher alpha diversity than skin or urogenital systems​
    

## Diversity and health

- Dogma (with caveats):
    
    - Gut: higher alpha diversity often associated with health; low diversity sometimes linked to dysbiosis (e.g., antibiotics, inflammatory conditions).paste.txt+1
        
    - Oral and urogenital: higher diversity often linked to dysbiosis (e.g., bacterial vaginosis), where a canonical low‑diversity state (e.g., Lactobacillus‑dominated vagina) is considered healthy.​
        
- Across animals:
    
    - Herbivores and omnivores generally have higher gut diversity than strict carnivores.
        
    - Ruminants and hindgut fermenters have higher diversity than simple‑gut animals​
        
    - Bats and some birds show lower gut diversity, possibly due to weight constraints and rapid transit.
        

## Captivity and early‑life effects

- Captivity:
    
    - Meta‑analyses show that many captive animals have reduced gut diversity relative to wild conspecifics, likely due to constrained diets, reduced environmental microbial exposure, and management differences.paste.txt+1
        
- Early‑life:
    
    - Maternal source and early environment can “set” diversity trajectories; examples include zoo‑born vs wild‑born ungulates where differences persist despite later shared environments.​
        

---

## Lego rarefaction activity (conceptual)

- Legos of different colors = taxa; full bag = complete amplicon pool.paste.txt+1
    
- Pull 10, 25, 50, 100 blocks without replacement:
    
    - Shows that low “depth” (10) misses many colors and misestimates relative abundances; as depth increases, estimates stabilize.paste.txt+1
        

---

# Week 5 – High‑quality data: confounders, contamination, controls

## Experimental confounders and design

## Maternal effects

- Offspring share microbiota with the dam; litter is a strong random effect.Week5-Mon-high-quality-data.pdf+1
    
- Bad design: all pups from Dam 1 in treatment A, Dam 2 in treatment B; group separation could reflect dam rather than treatment.​
    
- Good design: pups from each dam split across treatments (e.g., each litter contributes individuals to both treatment and control).
    

## Co‑housing and cage effects

- Co‑housed animals (especially coprophagic rodents) converge in microbiota.
    
- Avoid designs where all treatment A animals are in one cage rack and treatment B in another; cage becomes confounded with treatment.
    
- Strategy:
    
    - Randomize animals from each cage into different treatments when possible, or treat cage as the experimental unit.
        

## Sampling effects

- Spatial heterogeneity:
    
    - Soil: depth and micro‑scale structure strongly affect communities; repeated sampling must control for depth and location.
        
    - Gut: fecal samples approximate large intestine but may not reflect small intestine or rumen content; match sample type to biological question.
        
- Biomass:
    
    - High‑biomass: feces, rumen content, soil; relatively robust to low‑level contaminants.
        
    - Low‑biomass: air, treated water, surfaces, tissues thought to be sterile, swabs from low‑biomass sites; highly vulnerable to contamination.
        

---

## Shipping, storage, and preservation

## Fecal preservation (Song et al.)

- Study: human and dog feces in multiple preservatives (none, 70% EtOH, 95% EtOH, RNAlater, OMNIgene, FTA cards) across temperatures (−20 °C, 4 °C, room temp, freeze–thaw) and timepoints (day 0, 1 week, 4 weeks, 8 weeks).​
    
- Key findings:
    
    - Some preservative + temperature combinations preserve community structure well; others (e.g., no preservative + prolonged room temp) cause large shifts​
        
    - In extremes, storage artifacts can make a sample as different from “fresh” as two different host species.
        
- Practical implications:
    
    - Choose preservation based on field constraints; OMNIgene or 95% EtOH often perform well for feces if freezing is delayed.​
        
    - Keep conditions consistent across groups to avoid differential preservation artifacts.​
        

## Microbiome Quality Control (MBQC) project

- Multi‑lab study showing:
    
    - Substantial variation introduced by differing extraction kits, PCR primers, sequencing platforms, read lengths, and bioinformatics pipelines.​
        
    - Despite variation, some core patterns are robust, but careful standardization and reporting are crucial.​
        
- Emphasis:
    
    - Report kit brands, lot numbers, homogenizer usage, primer sets, sequencing machine, read lengths, and software.​
        

---

## Contamination: sources and management

## Common contamination sources

- Reagents and plastics: DNA extraction kits (especially beads), PCR mastermixes, water, tubes.​
    
- Environmental: lab air, dust, skin, respiratory droplets, lab surfaces.​
    
- Cross‑contamination: well‑to‑well spillover on plates, mis‑indexing, sequencing run carryover.​
    

## Low‑biomass special issues

- Typical “contaminant genera” in negative controls include Actinomyces, Corynebacterium, Bacillus, Propionibacterium, Chryseobacterium, Flavobacterium, Sediminibacterium, various Proteobacteria.Week3_Wed_taxonomy_02-03-26.pdf+1
    
- RIDE checklist recommendations:
    
    - Report design and contamination‑reduction steps.
        
    - Include at least one of each negative control type per batch: sampling blanks, extraction blanks, no‑template PCR controls.​
        
    - Compare biological samples to controls and report the impact of contaminants on interpretation.​
        

## Practical lab practices

- Experimental design:
    
    - Randomize sample order across extraction and PCR batches; record reagent lot numbers.​
        
- Sampling:
    
    - Clean gloves, masks, potentially clean suits for sensitive work; sampling blanks (e.g., unused swab exposed during sampling)
- DNA extraction and PCR:
    
    - Pre‑PCR work in dedicated, decontaminated hoods physically separated from post‑PCR areas; extraction blanks; no‑template PCR controls.​
        
- Sequencing:
    
    - Use unique, redundant barcodes; watch for index hopping; avoid reusing index combinations across projects when possible.​
        
- Well‑to‑well contamination:
    
    - More common among neighboring wells; low‑biomass samples more impacted.​
        
    - Randomize sample positions; group similar biomass together; consider single‑tube extractions for precious low‑biomass samples.​
        

---

## Controls and computational handling

## Positive controls (mock communities)

- Defined mixtures of known taxa (e.g., 8 bacteria + 2 yeasts with known theoretical compositions by genome copies or 16S copies).​
    
- Uses:
    
    - Assess accuracy of taxonomic assignment and relative abundance estimation.
        
    - Diagnose pipeline biases (e.g., under‑representation of particular Gram‑positives).
        
- QIIME2 tools:
    
    - `q2-quality-control`:
        
        - `evaluate-composition`: compares observed taxonomic composition vs theoretical.
            
        - `evaluate-seqs`: compares observed sequences to expected references.​
            

## Negative controls

- Types:
    
    - Sampling blanks, extraction blanks, no‑template PCR controls.​
        
- How to use:
    
    - Always report taxa found in negatives.
        
    - Avoid naïvely removing all taxa that appear in negatives; many may be sample cross‑talk, not reagent contaminants.​
        
    - Use statistical tools (e.g., `decontam` in R) that model patterns such as higher frequency in low‑DNA samples and presence in controls.​
        

## After QC

- After using controls to assess contamination:
    
    - Remove control samples themselves from downstream ecological analyses (alpha/beta diversity, differential abundance).​
        
    - Work on a cleaned dataset with well‑documented QC decisions.​
        

---

## Big‑picture: interpreting controversial low‑biomass signals

- Examples:
    
    - Placenta microbiome claims vs later work showing profiles resembling contamination controls.​
        
    - Cancer microbiome signatures challenged due to likely contamination and batch effects; later methods (e.g., SCRuB) attempt explicit contamination modeling.​
        
- Take‑home:
    
    - Extraordinary low‑biomass claims require extraordinary QC: multiple negative controls, mock communities, independent pipelines, and careful statistics.​
        
    - Transparent reporting (MIMARKS/MIxS) is essential for evaluating these studies.​
        

