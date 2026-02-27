

---

# Week 3 – Denoising and Taxonomy

## Microbiome data processing overview

- Typical workflow: study design → sample collection/storage → DNA extraction → library prep → sequencing → demultiplexing → quality processing → denoising/clustering → feature table + rep‑seqs → taxonomy → diversity and downstream stats.​
    
- Pre‑study questions: Is 16S right for my question, what sample size, what body site/environment, what metadata, what confounders (diet, age, sex, housing, facility)?Week5-Mon-high-quality-data.pdf+1
    

## Wet‑lab considerations

- Field handling: consistent collection method (swab, feces, biopsy, water filter), minimize time to preservation, consider biomass and contamination risk.
    
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

- Denoising algorithms (DADA2, Deblur, MED, UNOISE3) model sequencing errors and infer **exact** amplicon sequence variants (ASVs/ESVs).
    
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
    
    - Identify where median quality drops sharply; truncate before the crash.
        
    - Optionally trim low‑quality leading bases or primers (e.g., trim‑left 19 to remove 515f primer).​
        
- For paired‑end:
    
    - Ensure enough overlap after truncation; e.g., 2×150 bp on a 250 bp amplicon: 150 + 150 − 250 = 50 bp overlap.​
        
    - Too aggressive truncation → merge failures → apparent low diversity and many lost reads.
        

---

## Outputs after denoising

- `table.qza`: feature table (samples × ASVs) with counts.week4_Mon_Alpha_lecture.pdf+1
    
- `rep-seqs.qza`: FASTA sequences of each feature.week4_Mon_Alpha_lecture.pdf+1
    
- `stats.qza`: denoising stats for troubleshooting.​
    
- After phylogeny: `rooted-tree.qza` for phylogenetic diversity and UniFrac
    

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
        

Here’s a markdown-ready set of class notes that integrates and expands on all four lectures with primary literature sprinkled throughout.

---

# Week 5–7 Microbiome Methods Notes

## 1. High‑quality microbiome data

## 1.1 Common confounders and technical artifacts

Microbiome data quality is shaped by both biology and workflow choices. Key artifact categories:​

- Maternal effects: vertical transmission of microbes and shared environment can drive strong similarity within litters or families, often larger than experimental effects (e.g., Goodrich et al. 2014 on heritable taxa in the human gut)​
    
- Co‑housing effects: cage/pen mates rapidly converge in community composition; housing can be a stronger driver than treatment if not controlled.​
    
- Sampling effects:
    
    - Collection method: swab vs. filter vs. biopsy vs. fecal can yield different communities because of spatial structuring and biomass differences.​
        
    - Spatial sampling: depth in soil/water, gut site (lumen vs. mucosa, rumen vs. feces) strongly affects composition.​
        
    - Biomass: low vs. high biomass samples differ in susceptibility to contamination and stochasticity.​
        
- Shipping/storage effects: temperature, time to freezing, use of preservatives (e.g., RNAlater, OMNIgene) can shift communities; consistent protocols are critical.​
    
- Molecular workflow effects: extraction kit, bead‑beating intensity, primer set, PCR cycles, and library prep chemistry all change observed taxa and diversity.Week6_Mon_BetaTrends_copy.pdf+1
    
- Computational effects: choice of denoising (DADA2, Deblur), OTU vs. ASV, reference database, and normalization/rarefaction affect downstream metrics, especially beta diversity.week5_Wed_betadiv.pdf+1
    

Design implication: randomize samples across batches/plates, document every step (reagent lot numbers, extraction dates), and whenever possible block on known sources of variation (e.g., process all low‑biomass samples together).​

## 1.2 Contamination types and sources

Contaminants are a major threat, especially for low‑biomass work. Common sources:​

- Reagents and plastics: extraction kits, magnetic beads, water, PCR mastermix, and plasticware often carry characteristic contaminant taxa.​
    
- Environmental contamination: skin, oral, lab air/dust, surfaces, and equipment can introduce DNA.​
    
- Cross‑contamination (“well‑to‑well” and “run‑to‑run”):
    
    - Splashing, aerosols, pipetting errors, and index hopping introduce cross‑talk.
        
    - Contamination tends to be strongest in neighboring wells but can extend several wells away.​
        

A high‑profile example is the re‑analysis of a cancer microbiome study where a nearly perfect tumor–microbe signature was largely explained by contaminants and batch structure rather than biology.​

## 1.3 Controls and best practices

## Negative controls

Include at least one per batch of each type:​

- Sampling blank (swab/field blank).
    
- Extraction blank.
    
- No‑template PCR control.
    

These are used to:

- Characterize the background community carried by reagents and environment.
    
- Identify taxa whose abundance scales with low DNA concentration (strong contaminant signature).
    

Crucially, do not simply remove all taxa seen in negatives, because many of those taxa may also be true constituents of biological samples that have bled into controls.​

## Positive controls (mock communities)

Mock communities (known composition and abundance) are essential for benchmarking:

- Evaluate taxonomic accuracy and sensitivity.
    
- Detect amplification bias, chimera rates, and misclassifications.​
    

In QIIME 2, q2‑quality‑control provides:​

- `evaluate_composition`: compare expected vs. observed taxonomic compositions for mock samples.
    
- `evaluate_seqs`: compare expected vs. observed sequences to assess denoising/OTU picking.
    

## Dedicated guidance for low‑biomass samples

Eisenhofer et al. 2019 proposed the RIDE checklist for low‑biomass work:​

- Explicitly report design and contamination‑reduction steps.
    
- Include all negative control types per sampling/extraction/amplification batch.
    
- Quantify contamination by comparing negatives to biological samples.
    
- Explore contaminant taxa and report their impact on interpretation, ideally using statistical contaminant identification models.
    

In practice, tools like decontam implement models based on two reproducible patterns: contaminant features increase in relative abundance in low‑DNA samples and they are enriched in negatives.​

After quality control, negative and positive control samples themselves should be removed from downstream biological analyses, but the information they provided should already have been used to filter or annotate taxa.​

---

## 2. Beta diversity and distance metrics

## 2.1 Alpha vs. beta diversity and rarefaction

- Alpha diversity: within‑sample richness/evenness (e.g., observed ASVs, Shannon, Faith’s PD).​
    
- Beta diversity: between‑sample differences in community composition, expressed as a distance or dissimilarity matrix.​
    

Because diversity is strongly affected by sequencing depth, rarefaction or other normalization is needed before comparing samples:

- Two samples with similar read depth can appear artificially similar, even if biologically distinct.​
    
- Normalizing reads (e.g., rarefaction, compositional approaches) reduces depth‑driven artifacts but introduces its own trade‑offs.​
    

## 2.2 Common beta diversity metrics

All metrics operate on a feature table (samples × taxa/features), sometimes with a phylogenetic tree.​

Non‑phylogenetic metrics:

- Bray–Curtis distance:
    
    - Abundance‑weighted, non‑phylogenetic.
        
    - Captures differences in relative abundances; sensitive to dominant taxa.​
        
- Jaccard distance:
    
    - Presence–absence only.
        
    - Reflects whether taxa are shared, ignoring abundance.​
        

Phylogenetic metrics (require a rooted tree):

- Unweighted UniFrac: fraction of branch length unique to each community, presence–absence only.​
    
- Weighted UniFrac: similar but incorporates relative abundance along branches, emphasizing abundant taxa.​
    

High‑level comparison:

|Metric|Phylogenetic?|Uses abundance?|Emphasis|
|---|---|---|---|
|Bray–Curtis|No|Yes|Differences in relative abundances|
|Jaccard|No|No|Shared vs. unique taxa presence|
|Unweighted UniFrac|Yes|No|Deep evolutionary gains/losses|
|Weighted UniFrac|Yes|Yes|Abundant, phylogenetically structured taxa|

Examples in the lecture slides explicitly show how Bray–Curtis, Jaccard, and UniFrac distance matrices differ for the same toy feature table.​

## 2.3 Beta diversity visualization: ordination and PCoA

A distance matrix is usually interpreted via ordination.

- Principal Coordinates Analysis (PCoA) embeds samples in a low‑dimensional space that preserves pairwise distances as much as possible.​
    
- Axes (PCo1, PCo2, …) have associated % variance explained, indicating how much of the between‑sample variation is represented.​
    

Examples:

- Costello et al. 2009 (Science) showed that different human body sites cluster separately based on unweighted UniFrac PCoA, illustrating strong habitat‑specific microbiomes.​
    
- The Earth Microbiome Project meta‑analysis (Thompson et al. 2017 Nature) showed that environment type and host association are major drivers of global beta diversity across >27,000 samples.

PCoA plots can be colored by metadata (body site, age, treatment, host species) and grouped using ellipses or hulls to visually inspect clustering patterns.

## 2.4 Statistical testing on beta diversity

Once you have a distance matrix, you can test for group differences:

- PERMANOVA (e.g., `beta-group-significance` in QIIME 2):
    
    - Multivariate ANOVA on distances; null = group centroids are equivalent in multivariate space.​
        
    - Sensitive to both centroid differences and differences in dispersion.
        
- PERMDISP:
    
    - Tests whether dispersion (within‑group variance) differs between groups; used to interpret PERMANOVA results.​
        
- ANOSIM:
    
    - Tests whether between‑group ranks of distances are greater than or equal to within‑group ranks; often used with ranked dissimilarities.​
        

In QIIME 2, the `beta-group-significance` visualizer can run PERMANOVA, PERMDISP, and ANOSIM on the same distance matrix.​

---

## 3. Beta diversity trends and functional redundancy

## 3.1 Broad beta‑diversity patterns in microbiome research

## Host vs. environment gradients

Ley et al. (2008, Nat Rev Microbiol) and follow‑up work highlighted that host diet, physiology, and obesity status are associated with clear shifts in gut community structure, often reflected in beta diversity patterns.​

The Earth Microbiome Project (Thompson et al. 2017, Nature) showed:

- Strong clustering by environment type (soil vs. marine vs. host‑associated) using UniFrac and Bray–Curtis distances.
- Host‑associated microbiomes occupy distinct regions of ordination space relative to free‑living communities.

More recent EMP500 work added standardized multi‑omics (16S, 18S, ITS, metagenomics, metabolomics) and confirmed that beta diversity patterns reflect not just taxonomic composition but also functional potential and metabolite profiles across ecosystems.​

## Human gut across age and lifestyle

- Yatsunenko et al. 2012 demonstrated that gut microbiomes of children and adults differ strongly in UniFrac space, with age and geography being major axes of variation.​
    
- Olm et al. 2022 extended this to a large infant cohort, showing that lifestyle (industrialized vs. transitional vs. traditional) and age jointly structure infant gut beta diversity.1​
    

The American Gut Project further showed that lifestyle factors such as diet (e.g., number of plant types consumed per week) correlate with both alpha diversity and Bray–Curtis distances between individuals, with higher plant diversity associated with more diverse and distinct communities.​

## 3.2 Host phylogeny, diet, and phylosymbiosis

Comparative primate and vertebrate gut microbiome studies reveal:

- Amato et al. 2018 found that host phylogenetic clade explains more beta diversity (unweighted and weighted UniFrac) than dietary niche among primates, indicating that host physiology and evolutionary history outweigh diet alone.​
    
- Song et al. 2020 reported convergence between birds and bats: despite different phylogenetic positions, flight‑adapted vertebrates show convergent gut community structures in UniFrac PCoA space, highlighting ecological convergence.]​
    

Phylosymbiosis: the tendency for more closely related host species to have more similar microbiomes than expected by chance; observed in multiple host clades and quantified using distance‑based methods such as Mantel tests between host phylogenetic distances and microbiome distances​

## 3.3 Diversity and function: functional redundancy

Leff et al. 2015 showed that nutrient additions (N, P) across global grasslands shift microbial beta diversity in a way that correlates with plant community changes.​

- Constrained ordinations (e.g., distance‑based RDA) indicated that N and P treatments significantly explain Bray–Curtis differences in fungal, archaeal, and bacterial communities.​
    
- Pearson correlations between mean Bray–Curtis dissimilarity (control vs. fertilized plots) and plant community shifts show coordinated plant–microbe responses.​
    

Louca et al. 2018 (Nature Ecology & Evolution) examined bromeliad tank communities and found:

- High taxonomic turnover (beta diversity) across samples.
    
- Much lower variation in functional gene categories (fermentation, respiration, carbon fixation), implying strong functional redundancy.​
    

Functional redundancy:

- Different taxa contribute similar functional capabilities, leading to relatively stable functional profiles despite large beta diversity at the taxon level.​
    
- In the human gut, metagenomic data likewise show a relatively stable “core” at the gene/pathway level despite person‑to‑person taxonomic variation, consistent with functional redundancy and resilience.​
    

Recent work (e.g., Li et al. 2023, Nat Commun) reinforced that gut microbial communities often exhibit high redundancy in key metabolic pathways (e.g., SCFA production), which can buffer host function against moderate taxonomic shifts.​

## 3.4 When beta diversity lacks clear patterns

A lack of strong clustering or clear group separation in beta diversity can mean several things:​

- The factor of interest truly has small or context‑dependent effects.
    
- Other unmeasured variables (e.g., age, geography, host genetics) dominate variation.
    
- The metric chosen is not aligned with the biology (e.g., using presence–absence when abundance changes are key).
    

Comparative vertebrate studies show cases where host class or habitat does _not_ separate cleanly in ordination space, suggesting convergence or strong functional constraints across distant hosts.​

This reinforces the need to:

- Test multiple distance metrics.
    
- Partition variance among covariates (e.g., PERMANOVA with multivariable models).
    
- Link beta diversity patterns to functional and ecological hypotheses, not just visual clustering.
    

---

## 4. 16S rRNA copy number variation (CNV)

## 4.1 Biological background

The ribosome is essential for translation, and 16S rRNA genes are part of highly conserved rRNA operons.​

Microbes differ widely in the number of rRNA operons they carry:

- Oligotrophs (slow‑growing, resource‑limited environments) tend to have few rRNA operons.
    
- Copiotrophs (fast‑growing, nutrient‑rich environments) often have many copies, enabling rapid ribosome synthesis and fast growth when resources spike.​
    

Klappenbach et al. 2000 (Appl Environ Microbiol) showed that higher rRNA operon copy number correlates with higher maximum growth rate and prevalence in nutrient‑rich settings.​

## 4.2 Consequences for 16S‑based microbiome surveys

Because standard amplicon workflows treat each 16S gene equally, taxa with more copies of the 16S rRNA gene generate more reads per cell:

- Relative abundances can be biased toward high‑copy taxa, underestimating low‑copy taxa, including many archaea.]​
    
- Diversity may be overestimated if divergent copies within a genome are treated as separate ASVs/OTUs.​
    

Acinas et al. 2004 documented divergence and redundancy of 16S copies within genomes, showing that multiple operons can differ enough to appear as distinct OTUs, inflating richness estimates.​

These issues extend to 18S rRNA gene CNV for eukaryotes, as shown by strain‑dependent variation in _Aspergillus fumigatus_ 18S copy number (Herrera et al. 2009).​

## 4.3 Approaches to correct or account for CNV

Several methods attempt to adjust for copy number:

- PAPRICA and CopyRighter use lineage‑specific copy number predictions to correct feature tables before diversity estimation.​
    
- PICRUSt and related tools use ancestral state reconstruction of gene content, including rRNA copy number, to predict metagenomes from 16S data.]​
    
- QIIME 2 plugins such as `q2-gcn-norm` implement gene copy number normalization for amplicon tables.​
    

However, Louca et al. 2018 (“Correcting for 16S rRNA gene copy numbers in microbiome surveys remains an unsolved problem”) argued that:​

- Copy number databases are incomplete and biased toward cultured taxa.
    
- Mis‑estimated copy numbers can introduce more noise than the original bias.
    
- Corrected data sets become hard to compare across studies that used different prediction models or none at all.
    

The lecture recommendation is to avoid routine copy‑number correction for now and instead:

- Interpret relative abundances and diversity _comparatively_ across treatments/groups within the same study.
    
- Be explicit about CNV‑related biases in discussion and when comparing across taxa or domains (e.g., bacteria vs. archaea).​
    

For truly quantitative microbiomics, Wang et al. (“absolute quantitative microbiome using cellular internal standards”) proposed adding defined cellular internal standards to estimate absolute abundances, which can circumvent some CNV issues but adds complexity.​

---

## 5. Longitudinal microbiome studies

## 5.1 What is a longitudinal study?

Longitudinal designs:

- Repeatedly sample the same individuals over time for the same metrics (e.g., 16S, metagenomics, metabolomics, clinical metadata).
    
- Are generally observational, with rich quantitative and qualitative data on exposures and outcomes.

- Reveal temporal dynamics, transitions, stability, and recovery patterns that single time points cannot capture.​
    

A pre–post study (baseline + one follow‑up) is the simplest form but misses nuanced trajectories such as transient responses, delayed effects, or relapses.​

## 5.2 Advantages and disadvantages

Advantages:​

1. Relate events to exposures/treatments over time (e.g., medication, diet, housing).
    
2. Define duration and timing of effects (onset, peak, persistence, recovery).
    
3. Establish temporal sequence and patterns (e.g., disease flare followed by microbiome shift, or vice versa).
    
4. Quantify within‑subject variability vs. between‑subject heterogeneity.
    
5. Characterize development and maturation trajectories (e.g., infant gut, calf gut), including slow vs. fast responders.
    

Disadvantages:​

1. Loss to follow‑up can bias the cohort.
    
2. Complex exposure histories complicate causal inference.
    
3. Requires more sophisticated statistical methods (repeated measures, mixed models).
    
4. Greater time and financial burden.
    
5. Susceptible to time‑varying confounders and external events (dietary shifts, infections, antibiotics).
    

## 5.3 Example: calf housing and early‑life microbiome

A longitudinal study on calves examined the effects of individual vs. pair housing:​

- Design: n=10 individual, n=20 pair; fecal sampling at days 1, 5, 35, and 63; daily fecal scoring for 56 days.​
    
- Findings:
    
    - Age was a dominant driver of gut microbiome development, with Shannon diversity increasing significantly between each time point (p < 10⁻³–10⁻¹⁵).​
        
    - Housing influenced community composition and health trajectories, but effects had to be interpreted after adjusting for age.
        

This illustrates a general principle: in early‑life or developmental studies, age is usually the primary structuring variable and must be included in models to isolate treatment effects.​

## 5.4 Statistical approaches: linear mixed effects and q2‑longitudinal

Repeated measures on the same subject violate independence assumptions; mixed models account for this:

- Fixed effects: variables answering the research question (e.g., time, treatment, age, sex, housing).​
    
- Random effects: account for study design (subject ID, cage, batch) and repeated measures correlation.​
    

The QIIME 2 `q2-longitudinal` plugin (Bokulich et al. 2018, _mSystems_) provides tools for longitudinal microbiome analysis:journals.asm+1[​

- Interactive volatility plots.
    
- Linear mixed‑effects models for alpha diversity and metadata.
    
- Paired differences/distances for before–after comparisons.
    
- First differences and first distances for rates of change.
    
- NMIT (non‑metric microbial interdependence test) for temporal co‑variation among features.
    
- Supervised regression for longitudinal feature identification (e.g., “maturity index” models).
    

Bokulich et al. showed how these methods can capture subject‑specific trajectories and group‑level effects that would be missed by cross‑sectional analyses.journals.asm+1

## 5.5 Volatility plots, first differences, and first distances

## Volatility plots

- Combine features of control charts and spaghetti plots to visualize change in a variable over time across subjects.​
    
- Include warning and control limits (±2 and ±3 SD from the mean) to highlight outlying observations.​
    
- Useful to visualize alpha diversity, specific taxa, or metadata trends and examine group differences with mixed‑effects models.​
    

The calf example showed volatility in Shannon diversity over time, with treatment and sex effects quantified via linear mixed models (p ≈ 0.01 for each factor).​

## First differences and first distances

These quantify _rate_ and _direction_ of change:​

- First differences (alpha/metadata):
    
    - Change in a metric between successive time points, or relative to a baseline (e.g., Day 1).
        
    - Helps identify periods of rapid change vs. stability.
        
- First distances (beta diversity):
    
    - Distance between successive samples from the same subject (or between a subject and a baseline reference such as a mother).
        
    - Trends in first distances over time reveal how far a community drifts from its initial state.
        

In the calf data:

- First distances (UniFrac) relative to Day 1 quantified how each calf’s microbiome diverged from baseline.​
    
- Housing treatment did not significantly affect these distances, but fecal health did: calves with fewer abnormal fecal events had smaller final distances from baseline.​
    

## 5.6 Additional q2‑longitudinal methods

- Maturity index prediction:
    
    - Supervised regression to predict “microbiome age” from community composition; requires large, evenly sampled cohorts.​
        
    - Useful to compare developmental trajectories between groups (e.g., preterm vs. term infants).
        
- NMIT (Non‑parametric Microbial Interdependence Test):
    
    - Evaluates whether networks of co‑varying features differ between groups over time.​
        
    - Requires ≥5–6 time points per subject; robust to some missing data but computationally intensive.
        

These methods help move beyond static comparisons to understand temporal organization, resilience, and interdependencies in microbial communities.​

---

## 6. Practical takeaways

- Design: anticipate maternal, co‑housing, age, and batch effects; integrate them into design and models rather than treating them as afterthoughts.
    
- Controls: always include and analyze negative and positive controls; adopt elements of the RIDE checklist for low‑biomass projects​
    
- Distances: choose beta diversity metrics aligned with your question (phylogenetic vs. non‑phylogenetic, abundance vs. presence–absence) and report the rationale.​
    
- Interpretation: interpret taxonomic beta diversity jointly with functional data (metagenomes/metabolomes) to assess redundancy vs. specialization.​
    
- Longitudinal analysis: use mixed‑effects models and q2‑longitudinal tools (volatility, first distances, NMIT) to capture real temporal patterns rather than relying on repeated cross‑sectional snapshots.
    

These principles generalize across microbiome systems (human, animal, environmental) and will strengthen the validity and interpretability of your datasets.