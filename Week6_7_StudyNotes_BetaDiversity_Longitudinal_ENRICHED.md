# Weeks 6 & 7 Study Notes — Beta Diversity, Compositionality, Differential Abundance & Study Design

---

## Part 1: Key Definitions & Metrics

### Alpha Diversity Metrics

**Observed Features** — An alpha diversity metric that counts the number of unique features (ASVs/OTUs) present in a community. It captures *richness* only, without considering abundance.
`core-metrics-results/observed_features_vector.qza`

**Pielou's Evenness** — Measures relative evenness of species abundances within a sample. Ranges from 0 (dominated by one taxon) to 1 (all taxa equally abundant). Does not consider richness or phylogeny.
`core-metrics-results/evenness_vector.qza`

**Faith's Phylogenetic Diversity (PD)** — Uses phylogenetic branch lengths plus richness (presence/absence) to determine alpha diversity. A sample with many distantly related organisms has higher Faith's PD than one with many closely related organisms.
`core-metrics-results/faith_pd_vector.qza`

**Shannon's Diversity Index** — Combines richness and evenness but does *not* incorporate phylogenetic information. A community with many evenly distributed species has higher Shannon entropy than one dominated by a few taxa.
`core-metrics-results/shannon_vector.qza`

### Statistical Terms

**Alpha Group Significance** — Tests whether alpha diversity differs significantly between metadata categories (e.g., treatment groups, body sites). In QIIME 2: `qiime diversity alpha-group-significance`.

**Kruskal–Wallis Test** — A nonparametric test used to determine if differences exist between two or more independent groups. It does not assume normality in the data, making it appropriate for diversity metrics that are often non-normally distributed. **Important:** While valid for alpha diversity metrics, Kruskal-Wallis is *not* appropriate for identifying differentially abundant taxa in amplicon data because it does not account for compositionality (see Part 6).

**Alpha Correlation** — Tests relationships between alpha diversity and continuous metadata variables (e.g., age, BMI, time). Uses Spearman or Pearson correlation.

**Continuous Variable** — A numeric metadata variable with a range of values (e.g., time, temperature, age, estradiol concentration).

**Categorical Variable** — A metadata variable consisting of discrete groups (e.g., treatment, body site, housing type).

---

## Part 2: Beta Diversity Trends (Week 6, Monday)

### What Is Beta Diversity?

Beta diversity measures the *differences in community composition between samples*. While alpha diversity describes what's happening within a single sample, beta diversity asks: how similar or different are two communities?

Common beta diversity metrics include:

- **Bray-Curtis Dissimilarity** — Quantitative metric based on shared species abundances. Ranges from 0 (identical) to 1 (completely different). Does not use phylogeny.
- **Unweighted UniFrac** — Qualitative phylogenetic metric. Measures the fraction of branch length in a phylogenetic tree that is unique to either sample (presence/absence only).
- **Weighted UniFrac** — Quantitative phylogenetic metric. Incorporates both phylogeny and abundance information, weighting branches by the difference in taxon abundances.
- **Jaccard Distance** — Binary (presence/absence) metric without phylogenetic information.

Beta diversity is typically visualized using ordination methods such as **Principal Coordinates Analysis (PCoA)**, where each point represents a sample and the distance between points reflects community dissimilarity. Statistical significance of group separation is tested with **PERMANOVA** (Permutational Multivariate Analysis of Variance), and homogeneity of group dispersion is evaluated using **PERMDISP** (betadisper).

### Major Beta Diversity Patterns in Microbiome Research

#### Global Patterns: Free-Living vs. Host-Associated

**Ley et al., 2008, Nature Reviews Microbiology**
One of the earliest large-scale PCoA analyses using 16S rRNA data showed that microbial communities separate primarily by habitat type. Free-living communities (soil, water) cluster distinctly from host-associated communities (vertebrate gut, human body sites). Within host-associated communities, further separation occurs by host diet and body site. Examining individual phyla (Bacteroidetes, Firmicutes) reveals that these broad patterns are consistent across major bacterial lineages.

#### The Earth Microbiome Project (EMP)

**Thompson et al., 2017, Nature**
The EMP analyzed 27,751 samples from 97 independent studies using 16S rRNA sequencing. At the broadest level (EMPO level 2), samples cluster by whether they are animal-associated, plant-associated, saline, or non-saline. At finer resolution (EMPO level 3), environment-specific subclusters emerge (e.g., animal distal gut vs. proximal gut, soil vs. sediment). The first two PCoA axes explain ~15% of variation, reflecting the immense diversity across Earth's microbial habitats.

#### EMP500

**Shaffer et al., 2022, Nature Microbiology**
The EMP500 expanded on the original EMP by incorporating multiple data types for 880 samples: 16S rRNA, 18S rRNA, ITS, metagenomics, and metabolomics. Key findings include a positive correlation between shotgun metagenomic taxonomic richness and microbially-related metabolite richness. PERMANOVA pseudo-F statistics indicated that environment type (EMPO classification) significantly structures both metabolite and microbial composition, with metabolite ordinations (robust Aitchison PCA) showing even stronger environmental separation than microbial ordinations (weighted UniFrac PCoA).

### Human Gut Microbiome Patterns

#### Development and Age

**Yatsunenko et al., 2012**
Cross-cultural comparison of gut microbiomes from individuals in Malawi, Venezuela (Amerindians), and the United States showed that UniFrac distance between children and adults decreases sharply during the first ~3 years of life, then stabilizes. By age 3, children's microbiomes begin to resemble adult composition, though the trajectory and final composition vary by cultural/geographic context. US individuals showed lower child-adult distances at earlier ages compared to Malawian and Amerindian populations.

**Olm et al., 2022**
Using 1,900 fecal samples from infants (<3 years) across 18 populations, this study showed that both age and lifestyle (industrialized, transitional, nonindustrialized) are associated with infant microbiome composition. On a PCoA of unweighted UniFrac distances, point size scaled to age and color coded by lifestyle revealed that microbiome development follows different trajectories depending on industrialization level. Industrialized infants clustered separately from nonindustrialized infants, with transitional populations falling in between.

#### Diet and Plant Diversity

**American Gut Project (McDonald et al., 2018)**
The largest citizen-science microbiome study showed that individuals consuming more than 30 different plant types per week had significantly higher levels of conjugated linoleic acid and distinct microbial profiles enriched in fiber-fermenting taxa like Lachnospiraceae, Ruminococcaceae, Blautia, Oscillospira, and *Faecalibacterium prausnitzii*. These high-plant-diversity individuals also showed higher observed molecular features and lower Bray-Curtis dissimilarity (i.e., more stable communities). When placed in the context of EMP data, AGP human gut samples overlapped substantially with the EMP gut samples but occupied a distinct subspace.

### Why Does Microbial Diversity Matter?

Diversity of microbes is often related to diversity of function. A more diverse community may harbor a broader range of metabolic capabilities, potentially enhancing resilience to perturbation. However, the relationship between taxonomic and functional diversity is complicated by **functional redundancy**.

#### Functional Redundancy

**Louca et al., 2018, Nature Ecology & Evolution**
Functional redundancy occurs when different taxa contribute to the ecosystem in similar ways — for example, multiple unrelated species may all perform fermentation or carbon fixation. Studying bromeliads, Louca et al. showed that while taxonomic composition (family-level) varied enormously across individual bromeliads, the metabolic gene group composition was far more conserved. Core functions like fermentation, oxygen respiration, and carbon fixation were maintained even as the taxa performing them changed.

**Li et al., 2023, Nature Communications**
The human gut microbiome exhibits high functional redundancy. Using proteomic content networks (PCNs), Li et al. showed that different taxa contribute overlapping functional profiles. This redundancy may underlie the stability and resilience of the gut ecosystem — if one taxon is lost, others can fill its functional niche.

> **Connection to your research:** Your flaxseed study found that the FLAX group maintained more stable beta diversity (lower Bray-Curtis distances from baseline) during estrogen suppression, without significant changes in alpha diversity. This is consistent with functional redundancy: compositional shifts may occur (detectable via beta diversity) while overall diversity and potentially function remain buffered.

### What Does a Lack of Beta Diversity Pattern Mean?

When beta diversity analysis reveals no clear separation between groups, this can indicate:

- The factor being tested has minimal influence on community composition
- High within-group variability is masking between-group differences
- The communities may be functionally similar despite being taxonomically variable (functional redundancy)
- The distance metric chosen may not capture the relevant biological signal (e.g., unweighted vs. weighted UniFrac)

#### Convergence Between Distantly Related Hosts

**Song et al., 2020**
Comparative analyses of vertebrate gut microbiomes across mammals, birds, reptiles, amphibians, and fish revealed that birds and bats show remarkable convergence in gut microbiome composition despite their distant evolutionary relationship. This demonstrates that ecological factors (e.g., flight, high metabolic rates) can override phylogenetic signals. The concept of **phylosymbiosis** — more closely related host species tend to have more similar microbiomes — holds broadly but has exceptions driven by convergent ecological pressures.

#### Host Physiology vs. Diet

**Amato et al., 2018**
In non-human primates, PCoA of unweighted and weighted UniFrac distances showed stronger clustering by host phylogenetic clade (Old World, Apes, New World, Lemurs) than by dietary niche (folivore vs. non-folivore). PERMANOVA confirmed that evolutionary history (R² = 0.27–0.29) explained more variation than diet (R² = 0.04–0.05), though both were significant.

#### Some Animals Lack Resident Microbiomes

**Hammer et al., 2017**
Caterpillars were shown to lack a resident gut microbiome entirely — their gut microbial communities are transient, derived from ingested plant material, and do not establish stable host-associated communities. This challenges the assumption that all animals have functionally important gut microbiomes.

---

## Part 3: 16S rRNA Copy Number Variation

### Background: What Is the 16S rRNA Gene?

The ribosome is the molecular machine responsible for translating mRNA into protein. Because translation is essential for all life, ribosomal RNA genes are highly conserved across bacteria and archaea. The 16S rRNA gene (~1,500 bp in bacteria) encodes the RNA component of the small ribosomal subunit.

The 16S gene contains nine hypervariable regions (V1–V9) interspersed with conserved regions. Conserved regions serve as universal primer binding sites, while variable regions (particularly V4, used by the Earth Microbiome Project) provide taxonomic resolution for identification at genus or species level.

### Why Do Some Organisms Have Multiple 16S Copies?

**Klappenbach, Dunbar & Schmidt, 2000, Applied & Environmental Microbiology**
Bacteria can carry anywhere from 1 to 15+ copies of the rRNA operon in their genomes. Early-colonizing, fast-growing bacteria (copiotrophs) tend to have more rRNA operon copies (mean ~5–6), while slow-growing, resource-efficient bacteria (oligotrophs) tend to have fewer copies (mean ~1–2). Multiple rRNA operons allow faster ribosome production, enabling rapid growth when nutrients become available.

**Roller, Stoddard & Schmidt, 2016, Nature Microbiology**
Confirmed that rRNA operon copy number correlates with bacterial reproductive strategy. High-copy organisms are associated with copiotrophic lifestyles (fast growth, high resource environments), while low-copy organisms are associated with oligotrophic lifestyles (slow growth, nutrient-poor environments).

### Ecological Strategy: Oligotroph vs. Copiotroph

| Feature | Oligotroph | Copiotroph |
|---------|-----------|------------|
| Growth rate | Slow | Fast |
| rRNA operon copies | Low (1–2) | High (5–15+) |
| Resource use | Efficient, specialised | Opportunistic, generalist |
| Typical habitat | Nutrient-poor (deep ocean, subsoil) | Nutrient-rich (rhizosphere, gut after meal) |
| Response to nutrients | Minimal change | Rapid bloom |

### How Does Copy Number Variation Affect Microbiome Studies?

**Abundance bias:** Taxa with more 16S copies produce more amplicons during PCR, inflating their apparent relative abundance. Conversely, taxa with fewer copies are underrepresented. For example, archaea often have few rRNA copies and are systematically underrepresented in 16S surveys relative to bacteria.

**Diversity overestimation:** If the multiple copies within a single genome are not identical (which occurs — Acinas et al., 2004 showed that intragenomic 16S divergence can reach up to 6.4% in some species), different copies from the same organism may be classified as separate ASVs/OTUs, artificially inflating richness estimates.

### Can We Correct for Copy Number Variation?

Several tools have been developed to address this:

- **CopyRighter** (Angly et al., 2014, Microbiome) — Corrects microbial community profiles through lineage-specific gene copy number correction
- **PAPRICA** — Predicts metabolic potential and corrects for copy number using phylogenetic placement
- **PICRUSt/PICRUSt2** — Phylogenetic Investigation of Communities by Reconstruction of Unobserved States; also includes copy number normalization
- **q2-gcn-norm** — A QIIME 2 plugin for gene copy number normalization

**However, correction remains problematic:**

**Louca, Doebeli & Parfrey, 2018** — "Correcting for 16S rRNA gene copy numbers in microbiome surveys remains an unsolved problem." Incorrect predictions can introduce more noise than the original bias. Databases of known copy numbers are incomplete, and many environmental taxa have unknown copy numbers that must be predicted (often incorrectly).

### Current Recommendations

The field currently recommends **against** routinely correcting for 16S copy number variation because:
1. Incorrect predictions introduce noise that can be worse than the original bias
2. Results become harder to compare across studies using different correction models
3. Most microbiome studies interpret relative abundance *relative to other samples within the same study*, not as absolute numbers — the bias is consistent and affects all samples equally

The key takeaway: **Be aware of this bias when interpreting and discussing results**, especially when comparing bacteria to archaea or when discussing absolute abundances. But within a given study, relative comparisons remain valid.

### What About 18S Copy Number Variation?

**Herrera et al., 2009**
The 18S rRNA gene in eukaryotes (including fungi targeted by ITS sequencing) also shows copy number variation. In *Aspergillus fumigatus*, strain-dependent variation in 18S rDNA copy numbers was documented, meaning the same problem applies to fungal/eukaryotic microbiome surveys.

### Discussion Prompt

*Would the environment you study primarily have oligotrophic (slow) or copiotrophic (fast) bacteria? Why?*

> **Thinking about your flaxseed study:** The human gut is a relatively nutrient-rich environment, so we'd expect a mix but with many copiotrophs. However, during estrogen suppression, if the gut environment becomes less hospitable, you might see shifts toward taxa with different ecological strategies. The stability you observed in the FLAX group could reflect maintenance of the copiotrophic taxa that thrive in a well-nourished gut environment.

---

## Part 4: Longitudinal Studies and Analyses (Week 7)

### What Are Longitudinal Studies?

Longitudinal studies employ continuous or repeated measures from the same subjects over time. They differ from cross-sectional studies, which sample many different individuals at a single time point.

Key characteristics:
- Same individual sampled at multiple time points for the same metrics
- Generally observational, collecting quantitative and/or qualitative data on exposures and outcomes
- Reveal complex temporal patterns of change that single-timepoint studies miss

### Advantages of Longitudinal Design

1. **Relate events to exposures/treatments** — What are the effects of a medication, diet, or lifestyle change on the gut microbiome over time?
2. **Define exposures with respect to time** — How long do effects last? When do they begin?
3. **Establish sequence of events and patterns** — How does a perturbation ripple through the community?
4. **Measure individual variability against the cohort** — Do all patients respond the same way, or are there responders and non-responders?
5. **Capture stability, response, and recovery** — Single-timepoint studies may miss slow responders or recovery dynamics.

*(Caruana et al., 2015, J Thorac Dis)*

### Disadvantages of Longitudinal Design

1. **Participant loss (attrition)** — Dropouts reduce representativeness and statistical power
2. **Difficulty isolating exposure effects** — External factors accumulate over time
3. **Statistical complexity** — Repeated measures require appropriate methods (not just t-tests or ANOVA)
4. **Time and cost** — More expensive and logistically demanding
5. **External bias** — Uncontrolled environmental changes can confound results

### Why Not Just a Pre-Post Design?

A pre-post study (baseline → treatment → single follow-up) is the simplest form of longitudinal design. But it misses critical dynamics:

- Does the pathogen return?
- Is the effect permanent?
- Do new pathogens emerge?
- What happens to commensal bacteria?
- Are there slow responders who look unchanged at 24 hours but shift by day 7?

> **Connection to your research:** Your flaxseed study sampled at weeks 0, 2, 4, 6, 8, and 12 — capturing both the suppression phase and partial recovery. This revealed that the Control group diverged most from baseline at week 6 (p=0.025 for Bray-Curtis distances) but reconverged by week 8, a pattern invisible in a pre-post design.

### Case Study: Calf Pair Housing and Microbiome Development

A study on dairy calves compared individually housed (n=10) vs. pair-housed (n=20) calves, sampling fecal microbiomes at days 1, 5, 35, and 63. Key findings:

- **Age was the dominant driver** of microbiome development, with Shannon entropy increasing significantly from day 1 through day 63
- **Treatment (pair vs. individual housing)** significantly affected alpha diversity trajectories (p = 0.0072 by LME model)
- **Sex** also showed significant effects (p = 0.016)
- **Beta diversity (first distances from baseline)** showed both groups diverged from day 1 similarly — no significant treatment effect on rate of compositional change
- **Fecal health** was associated with microbiome divergence — calves with fewer abnormal fecal episodes had microbiomes that remained closer to their day 1 baseline

### Linear Mixed Effects (LME) Models

LME models are the appropriate statistical framework for longitudinal microbiome data because repeated observations on the same subject are **correlated, not independent**.

**Fixed effects** — Address research questions directly. Examples: treatment group, time, treatment × time interaction.

**Random effects** — Account for study design structure but don't address research questions. Examples: subject ID (each individual has their own baseline and trajectory), pen/cage (for animal studies).

The model structure:
```
Response ~ Fixed Effects + (Random Effects)
Example: Shannon ~ Treatment * Time + (1 | Subject_ID)
```

This model estimates:
- Whether treatment groups differ overall (treatment main effect)
- Whether diversity changes over time (time main effect)
- Whether the rate of change differs between groups (treatment × time interaction)
- While accounting for individual variation (random intercept per subject)

> **From your flaxseed analysis:** You used LME models in Prism and R (lme4/lmerTest) to test treatment, time, and their interaction on Shannon diversity, observed features, and evenness. The treatment × time interaction for Shannon was p=0.0715 — approaching significance, suggesting the groups may be diverging over time despite the main effects being non-significant individually.

### The q2-longitudinal Plugin

**Bokulich et al., 2018, mSystems**

A QIIME 2 plugin designed specifically for longitudinal microbiome analysis. Key methods:

#### Volatility Plots

Volatility is an indication of the temporal stability of a metric over time and between subjects. Volatility charts combine control charts and spaghetti plots:

- Each thin line = one individual over time
- Thick line = group mean
- **Control limits** = ±3 standard deviations from the mean (dotted lines)
- **Warning limits** = ±2 standard deviations from the mean (dashed lines)
- Points outside control limits represent observations substantially deviating from expected behavior

```bash
qiime longitudinal volatility \
  --m-metadata-file metadata.tsv \
  --m-metadata-file shannon_vector.qza \
  --p-default-metric shannon_entropy \
  --p-default-group-column treatment \
  --p-state-column timepoint \
  --p-individual-id-column subject_id \
  --o-visualization volatility-plot.qzv
```

#### Feature Volatility

An **exploratory method** that identifies features (taxa) predictive of a given state or time point using supervised regression. Unlike differential abundance methods, feature volatility can identify important low-abundance taxa that shift predictably with time or condition.

#### First Differences (Alpha Diversity)

Tracks the **rate of change** in a metadata value (e.g., Shannon diversity) between successive time points for each individual:

```
Sample 1 → Sample 2 → Sample 3 → Sample 4 → Sample 5
ASV1:  2       4        8        14       22
First diff:  2       4        6         8
```

Can also calculate differences from a **baseline** state rather than sequential comparisons — useful for asking "how far has this individual's microbiome shifted from its starting point?"

```bash
qiime longitudinal first-differences \
  --m-metadata-file metadata.tsv \
  --m-metadata-file shannon_vector.qza \
  --p-metric shannon_entropy \
  --p-state-column timepoint \
  --p-individual-id-column subject_id \
  --p-baseline 0 \
  --o-first-differences first-diff-shannon.qza
```

#### First Distances (Beta Diversity)

The beta diversity analog of first differences. Identifies the **beta diversity distance between successive samples from the same subject** over time, tracking how rapidly community composition is changing.

With a baseline parameter, it tracks how far each individual has moved from their starting community — essentially what you've been computing with Bray-Curtis distances from baseline in your flaxseed study.

```bash
qiime longitudinal first-distances \
  --i-distance-matrix bray_curtis_distance_matrix.qza \
  --m-metadata-file metadata.tsv \
  --p-state-column timepoint \
  --p-individual-id-column subject_id \
  --p-baseline 0 \
  --o-first-distances first-dist-bc.qza
```

#### Linear Mixed Effects in QIIME 2

```bash
qiime longitudinal linear-mixed-effects \
  --m-metadata-file metadata.tsv \
  --m-metadata-file shannon_vector.qza \
  --p-metric shannon_entropy \
  --p-group-columns treatment \
  --p-state-column timepoint \
  --p-individual-id-column subject_id \
  --o-visualization lme-shannon.qzv
```

#### Other Methods

**Maturity Index Prediction** — Uses supervised regression to quantify the relative rate of microbiome development over time. Requires large sample sizes and evenly sampled groups. Originally developed to study gut microbiome immaturity in malnourished Bangladeshi children (Subramanian et al., 2014, Nature).

**Non-parametric Microbial Interdependence Test (NMIT)** — Evaluates how interdependencies between features within a community differ over time or between groups. Requires at least 5–6 time points per subject. Robust to missing samples but computationally intensive (Zhang et al., 2017, Genetic Epidemiology).

### Case Study: Decomposition Soil Volatility

Phylogenetic volatility plots comparing decomposition soil vs. control soil across accumulated degree days (ADD) showed that decomposition soils diverged increasingly from controls over time at two of three field sites (ARF and STAFS, both p < 0.001). The third site (FIRS) showed no significant divergence — a site-specific response that would be missed without longitudinal sampling. This demonstrates how volatility analysis captures both the magnitude and consistency of temporal shifts.

---

## Part 5: Compositionality and Differential Abundance Testing (Week 7, Monday)

### What Is Compositional Data?

**Compositional data** are data naturally described as proportions or probabilities, or data with a constant or irrelevant sum. 16S rRNA amplicon sequencing data are inherently compositional: each sample has a fixed sequencing depth (library size), and what you observe is a *proportion* of reads assigned to each taxon, not an absolute count of cells.

This creates a fundamental interpretive challenge: **changes in the relative abundance of one taxon are forced to affect the apparent relative abundance of all others**, even if the absolute counts of those others haven't changed at all.

### The Compositionality Problem: An Intuitive Example

Imagine sampling bacteria from an ocean before and after an oil spill. Before the spill, you observe 12 orange-colored (oil-degrading) bacteria and 12 blue-colored bacteria. After the spill, the total microbial load decreases. When you take a new sample of the same sequencing depth, you might observe 12 orange and only 6 blue — suggesting the orange taxa *increased*. But in reality, their absolute numbers may be unchanged while the blue taxa decreased. The compositional constraint forces a false-positive signal.

The same problem runs in the other direction: if total microbial load increases (e.g., a bloom), both taxa might increase in absolute terms, yet their *relative* proportions remain unchanged — giving you a false-negative result.

**The key point: you cannot determine which taxon is actually changing from relative abundance alone.**

*(Lin & Peddada, 2020, Nature Communications)*

### Why Non-Parametric Tests Are Problematic for Differential Abundance

Tests like the Mann-Whitney/Wilcoxon rank-sum test and Kruskal-Wallis test operate directly on proportional abundances (or rank-transformed versions of them). These approaches:

- Do not account for the compositional constraint of amplicon sequencing data
- Treat each taxon as if it were measured independently, when in reality all taxa share the same read pool
- Are prone to spurious associations driven by changes in other taxa rather than the taxon being tested

> **Note:** Kruskal-Wallis *is* appropriate for alpha diversity metrics (Shannon, Faith's PD, etc.) because those metrics are summary statistics of the whole community, not individual taxon abundances. The problem is specifically with using it to identify which *individual taxa* differ between groups.

### Appropriate Approaches for Differential Abundance

#### ANCOM — Analysis of Composition of Microbiomes

**Mandal et al., 2015, Frontiers in Microbiology (PMC4450248)**

ANCOM addresses compositionality by testing *log-ratios* between every pair of features rather than raw abundances. The null hypothesis for each pair (i, j) is:

```
H₀(ij): mean(log(xᵢ/xⱼ)) = mean(log(yᵢ/yⱼ))
```

**Key properties:**
- Makes no assumption about independence between features
- Log-ratio normalization makes few assumptions about feature distributions; any statistical test (including nonparametric ones) can be applied to log ratios
- More resilient to differences in sequencing depth
- Requires pseudocounts to handle zeros (zeros cannot be log-transformed)
- Assumes that the majority of taxa are *not* changing between conditions (the "sparse changes" assumption)

**Interpreting ANCOM output — the W statistic:**
For each feature, ANCOM calculates a **W score** = the number of pairwise log-ratio hypotheses rejected in which that feature appears. The higher W, the more likely the feature represents a true biological difference.

- **clr mean difference (F-statistic)** = magnitude of the difference in centered log-ratio values. Values near zero are not biologically impressive even if W is high.
- A volcano plot of W vs. clr mean difference is the canonical ANCOM visualization.

#### ANCOM-BC — ANCOM with Bias Correction

**Lin & Peddada, 2020, Nature Communications**

ANCOM-BC improves on ANCOM by addressing an additional source of bias: **cross-sample variation in sampling fractions** (i.e., differences in the ratio of sequenced reads to true microbial load across samples). This variation introduces false positives and false negatives that ANCOM does not correct for.

ANCOM-BC introduces a **sample-specific offset term** in a linear regression framework estimated from the observed data. This offset functions as the bias correction. Working in log scale is analogous to log-ratio transformation for compositionality. With ANCOM-BC, one can perform standard statistical tests and construct confidence intervals for differential abundance.

#### ANCOM-BC2 — Multigroup with Covariate Adjustment and Repeated Measures

**Lin & Peddada, 2023, Nature Methods**

The most recent iteration, ANCOM-BC2, extends ANCOM-BC to support:
- **Multigroup analysis** with pairwise comparisons
- **Covariate adjustment** (e.g., controlling for BMI, age, batch)
- **Repeated measures** / longitudinal designs

Output is a heatmap of log-fold-changes across pairwise group comparisons (e.g., ileocolonic resection vs. none; colectomy vs. none), with starred cells indicating significant differences after multiple testing correction.

> **Connection to your research:** You used MaAsLin2 rather than ANCOM for your flaxseed analysis — both are compositionally-aware approaches. Understanding the W statistic logic helps you explain why simply comparing means with a t-test or Kruskal-Wallis on relative abundances would not have been appropriate.

#### MaAsLin2 — Multivariable Association Discovery in Population-Scale Meta-omics Studies

**Mallick et al., 2021, PLOS Computational Biology**

MaAsLin2 is an R package (not a QIIME 2 plug-in) designed for multivariable association discovery across meta-omics datasets. It was developed by the Huttenhower lab at Harvard.

**Key capabilities:**
- Handles metagenomics, metatranscriptomics, metaproteomics, and metabolomics data
- Accounts for compositionality, sparsity, non-normality, and high dimensionality
- Supports multivariate metadata (multiple covariates and confounders simultaneously)
- Includes zero-adjusted regression for sparse data
- Supports **random effects for longitudinal sampling and batch effects** — making it ideal for repeated-measures designs like your flaxseed study
- Validates against benchmarked synthetic abundances (SparseDOSSA)

**Why MaAsLin2 is appropriate for your study:** It can simultaneously model treatment, time, and their interaction while accounting for subject-level random effects and blocking variables (e.g., estrogen suppression phase), and it handles the compositional nature of the data internally.

### Choosing a Method: Sensitivity vs. FDR Trade-offs

Different methods show very different behavior on the sensitivity vs. false discovery rate (FDR) spectrum:

| Method | Sensitivity | FDR Control | Notes |
|--------|------------|-------------|-------|
| edgeR | Low | Good (balanced) | RNA-seq tool adapted for microbiome |
| limma VOOM | Low | Good (balanced) | RNA-seq tool adapted for microbiome |
| DESeq2 | Low (low power) → High (well-powered) | Good (balanced) → Inflated FDR with large/uneven library sizes | Best for small datasets (<20 per group) |
| MaAsLin2 | Moderate | Good | Balanced; handles covariates and random effects |
| ANCOM | Low-moderate | Very good (low FDR) | Conservative; good specificity, lower sensitivity |
| Wilcoxon.TSS | Moderate | Good | Simple; does not correct for compositionality |
| metagenomeSeq2 | High | Inflated | High power but many false positives |
| Negative Binomial | High | Very high inflation | Not recommended |

**Key takeaway:** Methods with the highest sensitivity tend to have inflated FDR. ANCOM-BC2 (not included in the benchmark above) generally outperforms both ANCOM and many other methods. The "right" choice depends on study size, expected effect size, and tolerance for false discoveries.

*(Benchmarking from Mallick et al., 2021)*

---

## Part 6: Known Differential Abundance Patterns (Week 7, Monday)

The following represent well-established (though sometimes debated) examples of differential abundance in the microbiome literature. These are important both as scientific context and as benchmarks for evaluating methods.

### Obesity: Firmicutes/Bacteroidetes Ratio

**Ley et al., 2005, PNAS**
One of the first large-scale demonstrations that obesity alters gut microbial ecology. In genetically obese (*ob/ob*) mice compared to lean controls, obese individuals showed significantly higher Firmicutes and lower Bacteroidetes (p < 0.003 for Bacteroidetes). This was extended to humans, though the signal is not as consistent.

**Turnbaugh et al., 2009, Nature**
In a large human twin cohort, lean individuals showed enrichment of Bacteroidetes (p < 0.003), and obese individuals showed enrichment of Actinobacteria (p < 0.002). Firmicutes differences between lean and obese were not statistically significant (p < 0.09).

**At the species level:**
- Obesity-associated microbiota tend to be enriched in *Lactobacillus reuteri*
- Obesity-associated microbiota tend to be depleted in *Bifidobacterium animalis* and *Methanobrevibacter smithii*

*(Schwiertz et al.; Million et al.)*

**However, this literature is contested:** Sze & Schloss, 2016 (*mBio*) re-analyzed publicly available obesity microbiome data and found substantial inconsistency across studies — the signal may be weaker and more population-specific than originally reported.

### Diet: Plant Diversity

**McDonald et al., 2018, mSystems (American Gut Project)**
Individuals eating >30 plant types/week are enriched in Lachnospiraceae, Ruminococcaceae, *Blautia*, *Oscillospira*, *Clostridiales*, and *F. prausnitzii* compared to individuals eating <10 plant types/week. These taxa are predominantly fiber fermenters and are associated with short-chain fatty acid production.

### Lifestyle: Industrialized vs. Non-Industrialized

**McDonald et al., 2018, mSystems**
Comparing industrialized populations to hunter-gatherers and remote farmers reveals that non-industrialized gut microbiomes are enriched in: Mollicutes, Prevotella, Ruminobacter, Sarcina, Succinivibrio, Treponema, *P. stercorea*. These taxa are largely associated with plant polysaccharide fermentation. Industrialized gut microbiomes tend to be enriched in Lachnospiraceae, Rikenellaceae, Bacteroides, *Blautia*, Parabacteroides, and *B. ovatus*.

### Colorectal Cancer: Fusobacterium nucleatum

Two landmark 2012 papers independently identified an association between *Fusobacterium nucleatum* and colorectal carcinoma:

- **Castellarin et al., 2012, Genome Research** — *Fusobacterium nucleatum* infection is prevalent in human colorectal carcinoma
- **Kostic et al., 2012, Genome Research** — Genomic analysis identifies association of *Fusobacterium* with colorectal carcinoma

*F. nucleatum* is an oral bacterium normally associated with periodontal disease. Its enrichment in colorectal tumors suggests potential roles in tumor promotion, though causality is still being investigated.

### Beyond Differential Abundance: Machine Learning Approaches

An alternative to hypothesis-driven differential abundance testing is asking: **Are particular features predictive of an outcome or phenotype?** Machine learning approaches that include feature importance analysis (e.g., random forests, gradient boosting) provide a complementary angle for identifying microbial taxa associated with outcomes — particularly when there are many weakly predictive features rather than a few strongly differentially abundant ones. These approaches will be covered in the following week.

---

## Part 7: Designing a Microbiome Study and Data Management (Week 7, Wednesday)

### Pre-Research Considerations

Before collecting a single sample, good study design requires addressing:

- **Resources** — What funding, personnel, time, equipment, and computational infrastructure are available?
- **Method documentation** — How will methods be recorded? Electronic Lab Notebooks (ELNs) such as LabArchives provide version-controlled, searchable records of SOPs, plate maps, PCR logs, and reagent information.
- **Standard Operating Procedures (SOPs)** — Does the lab have established protocols? Consistent SOPs reduce technical variability that could introduce batch effects. Key SOPs include: sample naming conventions, reagent usage rules, DNA extraction protocols, library preparation workflows.
- **Regulatory approvals** — IRB approval (human subjects) or IACUC approval (animal studies) must be in place before sampling begins.
- **Lab management** — Who manages consumables, freezer inventories, and equipment maintenance? Is there a lab manager? Knowing who is responsible for -80°C alarm systems, filter maintenance, and sample check-in procedures prevents costly sample loss.

### Formulating Your Hypothesis

A strong microbiome hypothesis is **specific and testable**. Compare:

> *"Fecal communities from at-risk individuals can predict IBD diagnosis"*

vs.

> *"Fecal communities from children ages 8–18 in the US with a susceptible NOD2 variant can predict IBD diagnosis"*

The second is better because it specifies the population (age range, geography, genetic background), making the study design, required sample size, and analysis approach clearer and reproducible.

**What do you want to learn?** This shapes the entire study:
- Identify a microbe or metabolite *associated with* an outcome → differential abundance, correlation
- Correlate features with community structure → ordination, PERMANOVA
- Predict a response based on the microbiome → supervised machine learning

*(QIITA workshop, J. Debelius)*

### Choosing a Study Design

| Study Type | Description | Microbiome Use Case |
|-----------|-------------|---------------------|
| Cross-sectional | Single time point, entire population | Broad surveys (EMP, AGP); prevalence of taxa in a population |
| Intervention | One group changed, other kept constant | Treatment effects on microbiome (e.g., dietary intervention) |
| Longitudinal | Repeated sampling over time | Stability, resilience, temporal dynamics |
| Case-control | Matched individuals, enriched for two outcomes | Disease association studies |
| Crossover | Subjects serve as their own controls | Reduces inter-individual variability; ideal for dietary studies |
| Survival | What predicts a terminal event? | Microbiome predictors of disease onset |

### What Data Type(s) to Collect?

Microbiome studies can address different questions depending on the data layer collected:

- **Community Structure** — Who is present and in what abundance? Do communities from different locations share composition? → 16S rRNA amplicon, ITS
- **Diversity and Dynamics** — How many types of organisms? How do they change over time? → Any amplicon-based approach with longitudinal sampling
- **Ecosystem Function** — What functional genes are present? Which are expressed? → Metagenomics, metatranscriptomics
- **Interaction and Communication** — Which metabolites are produced? What proteins are signaling? → Metabolomics, metaproteomics

The EMP500 and studies like it demonstrate the value of multi-omics approaches for capturing these different dimensions simultaneously.

**Are you only considering bacteria?** Many microbiome studies focus exclusively on bacteria, but the gut also harbors fungi (targeted by ITS sequencing), archaea, protozoa (e.g., *Entamoeba coli*, *Blastocystis*), and viruses (virome). Depending on your question, restricting to bacteria may miss important biology — e.g., the rumen microbiome involves protozoa and fungi as major contributors to fiber digestion.

### Considering Confounders

Confounders are factors that co-vary with your exposure of interest and independently affect the microbiome. They must be either controlled (by study design) or measured (so they can be statistically adjusted for).

**Biological confounders:**
- Maternal effects (in early-life studies)
- Co-housing effects (shared microbial environments)
- Host age, sex, diet, medications, prior antibiotics use

**Technical confounders:**
- Sampling method (swab vs. biopsy vs. stool)
- Storage conditions and freeze-thaw cycles
- Shipping effects
- DNA extraction kit and operator
- Library preparation batch
- Sequencing platform and run
- Primer choice and PCR conditions
- Computational pipeline and reference database

Samples from different time points or treatment groups should be **randomized across plates and sequencing runs** to avoid confounding batch effects with biological variation. Barcoding systems that scan sample tubes upon receipt and generate plate maps help enforce this randomization.

### Empowering Your Study: Statistical Power

**Power** (in statistics) = the probability of detecting a true difference as a function of sample size.

Microbiome effect sizes vary enormously depending on what is being compared:

**Large effect sizes** (easier to detect, need fewer samples):
- Different host species
- Different body sites
- Different geographic regions

**Moderate effect sizes**:
- Host age, long-term diet

**Small effect sizes** (harder to detect, need more samples):
- Short-term dietary interventions
- Specific drugs or treatments
- Subtle lifestyle differences

**Technical considerations** also affect apparent effect size: different sequencing protocols, primer sets, processing pipelines, storage conditions, and reagent lots all introduce variation that can swamp biological signal.

Tools for microbiome-specific power calculations:
- **micropower** (`https://github.com/brendankelly/micropower`)
- **Evident** (`https://github.com/biocore/Evident`)

### Metadata: The Foundation of Interpretation

**Metadata** = information about your samples beyond the primary omics data. It is data in itself.

Examples of metadata:
- Date and location of sample collection
- Storage location of raw sample
- Experimental metadata: controls, replicates, blanks, extraction kit lot numbers
- Physical and chemical properties of the environment (pH, temperature, moisture)
- Ontology designations (ENVO for environment, EMPO for microbiome context)
- Host taxonomy, age, sex, health status, medication use, dietary information

**Why metadata is non-negotiable:**
- Data are meaningless if you don't know where they came from
- Microbial communities are tightly adapted to their environments — metadata is required to interpret patterns
- Sequencing data can often be re-analyzed as methods improve, but **metadata cannot be retroactively collected**. Missing metadata permanently limits what questions can be asked of a dataset.

**Metadata standards:**
- **MIxS (Minimum Information about Any (x) Sequence)** — Defined by the Genomic Standards Consortium. Specifies required fields for genomes (MIGS), metagenomes (MIMS), and marker gene surveys (MIMARKS). Available at `gensc.org/mixs`
- **QIITA** (`qiita.ucsd.edu`) — Database of sequences, observation tables, and metadata with analysis tools (QIIME integration)
- **EBI/ENA** (`www.ebi.ac.uk/ena`) — European Nucleotide Archive; central sequence and metadata repository

### Data and Project Management Best Practices

**Goal: After publishing, another researcher can reproduce your results without contacting you.**

#### During the Study

- **ELN (Electronic Lab Notebook)** — Use platforms like LabArchives to maintain version-controlled records of PCR results, plate maps, extraction logs, reagent lots, and sequencing run summaries. Organize by project and date.
- **Sample barcoding** — Scan barcodes upon receipt, cross-reference with metadata sheets. Store duplicate samples at -80°C for re-extraction if needed. Randomize samples across plates to avoid batch effects.
- **SOP adherence** — Follow established protocols; document any deviations.

#### Computational Resources

Before starting analysis, establish:
- What computational resource will you use? (Local HPC, cloud, personal laptop)
- Are required software pipelines (QIIME 2, R packages, Python environments) already installed? Do you need to set them up?
- What training is needed? (Workshops, documentation, tutorials)
- How will provenance/analysis history be tracked? (QIIME 2 provenance tracking, Snakemake/Nextflow workflows, Jupyter notebooks, RMarkdown)

#### Data Storage

- Short-term: Active project storage on lab servers, Dropbox, Google Drive, OneDrive, Microsoft Teams, or institutional systems (e.g., CSU's RSTOR)
- Long-term / archival: Raw sequencing data deposited in public repositories upon publication
  - **NCBI SRA / BioProject** — Standard US repository for sequencing data
  - **EBI/ENA** — European equivalent, also widely used
  - **Qiita** — Microbiome-specific; stores sequences, feature tables, and metadata together
  - **Zenodo / Figshare / Dryad** — General-purpose repositories for processed data, code, and supplementary files
  - **MassIVE** — Mass spectrometry data (metabolomics)

#### Code and Analysis Sharing

- Record all commands (bash scripts, R scripts, Python notebooks)
- Share code publicly on **GitHub** after publication (or link to it in the manuscript)
- Use **Jupyter notebooks** or **RMarkdown** for reproducible, narrative-style analysis documentation
- **Data availability sections** in publications should include all accession numbers, repository links, and DOIs needed to reproduce the analysis

A complete data availability section cites: raw sequence accessions, metadata files, processed feature tables, analysis code repositories, and any external databases used (GreenGenes2, SILVA, GTDB, etc.).

---

## Part 8: Integration and Key Takeaways

### How These Topics Connect

1. **Beta diversity patterns** show that environment type and host biology are the primary drivers of microbiome composition globally, while within hosts, factors like age, diet, and geography shape community structure.

2. **16S rRNA copy number variation** reminds us that our measurements are imperfect — relative abundance estimates are biased toward high-copy organisms, and diversity may be overestimated. But for within-study comparisons, this bias is consistent.

3. **Compositionality** is a fundamental property of amplicon data that invalidates simple statistical tests (Kruskal-Wallis, t-test) for identifying differentially abundant taxa. Log-ratio-based approaches (ANCOM, ANCOM-BC2) and multivariable regression frameworks (MaAsLin2) are the appropriate alternatives.

4. **Longitudinal studies** are essential for understanding microbiome dynamics — stability, resilience, response to perturbation, and recovery — that are invisible in cross-sectional snapshots.

5. **Appropriate statistical methods** (LME models, first differences/distances, volatility analysis) are necessary to properly analyze repeated measures data without violating assumptions of independence.

6. **Good study design** and **rigorous data management** are prerequisites for interpretable, reproducible, and publishable microbiome research — and cannot be remedied retroactively.

### Conceptual Framework: Stability and Resilience

- **Stability** = longitudinal beta diversity consistency (low variance in Bray-Curtis distances over time)
- **Resilience** = capacity to return to baseline state after perturbation (recovery rate and completeness)
- **Functional redundancy** = different taxa performing similar functions, buffering ecosystem function against taxonomic shifts

When alpha diversity is stable but beta diversity changes, it suggests compositional reorganization without loss of overall richness — consistent with functional redundancy maintaining ecosystem function even as the players change.

### Key References

| Reference | Topic |
|-----------|-------|
| Ley et al., 2008, Nat Rev Micro | Global beta diversity patterns |
| Thompson et al., 2017, Nature | Earth Microbiome Project |
| Shaffer et al., 2022, Nat Micro | EMP500 multi-omics |
| Yatsunenko et al., 2012 | Human gut development |
| Olm et al., 2022 | Infant microbiome and lifestyle |
| McDonald et al., 2018, mSystems | American Gut Project; diet and lifestyle DA taxa |
| Song et al., 2020 | Vertebrate gut convergence |
| Amato et al., 2018 | Primate phylogeny vs. diet |
| Hammer et al., 2017 | Caterpillars lack gut microbiome |
| Louca et al., 2018, Nat Eco Evo | Functional redundancy |
| Li et al., 2023, Nat Comm | Gut functional redundancy |
| Klappenbach et al., 2000, AEM | rRNA copy number and ecology |
| Roller et al., 2016, Nat Micro | rRNA copy number and reproduction |
| Louca et al., 2018, Microbiome | 16S CNV correction unsolved |
| Acinas et al., 2004 | Intragenomic 16S divergence |
| Angly et al., 2014, Microbiome | CopyRighter tool |
| Bokulich et al., 2018, mSystems | q2-longitudinal plugin |
| Caruana et al., 2015, J Thorac Dis | Longitudinal study design |
| Subramanian et al., 2014, Nature | Microbiota maturity index |
| Zhang et al., 2017, Genet Epidemiol | NMIT framework |
| Lin & Peddada, 2020, Nat Comm | ANCOM-BC; compositionality bias correction |
| Lin & Peddada, 2023, Nat Methods | ANCOM-BC2; multigroup + repeated measures |
| Mandal et al., 2015, Front Micro | ANCOM original; log-ratio testing |
| Mallick et al., 2021, PLOS Comp Bio | MaAsLin2; multivariable DA |
| Ley et al., 2005, PNAS | Obesity and gut microbial ecology (mice) |
| Turnbaugh et al., 2009, Nature | Firmicutes/Bacteroidetes in lean vs. obese |
| Sze & Schloss, 2016, mBio | Revisiting obesity-microbiome signal |
| Castellarin et al., 2012, Genome Res | *Fusobacterium* in colorectal carcinoma |
| Kostic et al., 2012, Genome Res | *Fusobacterium* genomics in colorectal cancer |

---

*CSU qCMB — Microbiome Course Notes — Weeks 6 & 7 (updated with Week 7 Mon & Wed lectures)*
