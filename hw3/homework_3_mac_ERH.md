~={red}(1point)=~ for Alpha Rarefaction Plot
Run Core Metrics ~={red}(1 point; .25pts per line)=~
Make alpha diversity plots ~={red}(3points)=~
~={red}10 points=~ for the questions 

~={red}15 points total=~
------------------------------------------------------------------

Due: 

**For complete credit for this assignment, you must answer all questions and include all commands in your obsidian upload.**

------------------------------------------------------------------
**Learning Objectives**
1. Practice recording commands and editing code to match your analysis.
2. Perform alpha rarefaction and determine an appropriate sequencing depth.
3. Run core metrics, generate plots for alpha and beta diversity
--------------------------------------------------

**Cow Site Data Workflow**, part 3

Load qiime2 in a terminal session after you go into the **cow** folder

```
# Insert the two commands to activate qiime2

module purge
module load qiime2/2024.10_amplicon

```

### Alpha Rarefaction Plot ~={red}(1 point)=~
- Chose the input sequencings depths (min and max) for generating the alpha rarefaction plot: 

```
#go to the cow directory

qiime diversity alpha-rarefaction \
--i-table dada2/cow_table_dada2_filtered300.qza \
--m-metadata-file metadata/cow_metadata.txt \
--o-visualization alpha_rarefaction_curves_16S.qzv \
--p-min-depth ADD 500 \
--p-max-depth ADD 10000
```


### Run Core Metrics ~={red}(1 point)=~

```
qiime diversity core-metrics-phylogenetic \
    --i-table dada2/cow_table_dada2_filtered300.qza \
    --i-phylogeny tree/tree_gg2.qza \
    --m-metadata-file metadata/cow_metadata.txt \
    --p-sampling-depth 2000 \
    --output-dir core_metrics_results \
```


### Visualize alpha diversity plots
- generate a plot to visualize the observed features ~={red}(1 point)=~
```
qiime diversity alpha-group-significance \
    --i-alpha-diversity core_metrics_results/observed_features_vector.qza \
    --m-metadata-file metadata/cow_metadata.txt \
    --o-visualization core_metrics_results/observed_features_significance.qzv \
```

- generate a plot to visualize faith's PD ~={red}(2 points)=~
```
## insert the entire code chunk for generating this visualization 
qiime diversity alpha-group-significance \
    --i-alpha-diversity core_metrics_results/faith_pd_vector.qza \
    --m-metadata-file metadata/cow_metadata.txt \
    --o-visualization core_metrics_results/faith_pd_significance.qzv \

```



## Homework questions ~={red}(10 points)=~

1. what is the name of the file you needed to use to figure out what min and max depths to use to generate the alpha rarefaction plot? (Hint: which file contains the sequencing depths for each sample)   
The feature table summary visualization (cow_table_dada2_filtered300.qzv, generated via qiime feature-table summarize) is the key file. It provides a per-sample sequencing depth histogram and interactive table showing the minimum, median, and maximum read counts across all samples, which informs the rarefaction curve range and the sampling depth cutoff.    

2. what did you choose for the rarefaction depth (the input for core metrics -p-sampling-depth flag)? why?     
I chose a depth of 2,000 because Shannon diversity curves plateau for all biological groups before this threshold, indicating sufficient sequencing coverage. Depths beyond 2,000 result in substantial sample loss from udder, nasal, and oral groups without any gain in diversity estimate accuracy.     

3. Which cow body location had more observed features? Which has the lowest?    
- Highest observed features: Skin (n=20) — median of 350, with an IQR extending to ~370, comparable to fecal but with a higher upper range.    
- Lowest observed features: Control (n=5) — median of 10–15, dramatically lower than all other sites.   

4. What is the main difference between Faiths PD and Shannons alpha diversity metrics?      
-Faith's Phylogenetic Diversity (PD) is a phylogenetic alpha-diversity metric that measures the total sum of branch lengths in the phylogenetic tree represented by taxa in a sample, capturing evolutionary breadth.    
- Shannon's index is a non-phylogenetic metric that quantifies both species richness and evenness based purely on taxon counts/proportions.     

5. Which diversity metrics produced by the core-metrics pipeline require phylogenetic information?    
From the core-metrics-phylogenetic pipeline, the metrics that require a rooted phylogenetic tree are:   

- Alpha diversity: Faith's Phylogenetic Diversity (faith_pd)   
- Beta diversity: Weighted UniFrac and Unweighted UniFrac distance matrices    

Shannon, observed features, Bray-Curtis, and Jaccard are all non-phylogenetic.    

6. Which two body sites have the highest Faiths PD alpha diversity?  Are the groups significantly different?    

The two sites with the highest Faith's PD are skin (median of about 65) and fecal (median of about 55).     

From the pairwise Kruskal-Wallis results, the comparison between fecal and skin yields H = 12.565, p = 3.93 × 10⁻⁴, q = 8.78 × 10⁻⁴. Which means they are significantly different from one another after FDR correction.    

7. Does it seem like there are any groupings in the beta diversity? What are the groupings?     
Yes, there are clear, distinct groupings in the PCoA plot. Three main clusters emerge:    

- Skin + Udder form a tight, well-defined cluster in the upper left (emperor plot), notably overlapping, suggesting compositional similarity between these two surface-associated body sites.
- Fecal forms its own tight, well-separated cluster in the lower left.    
- Oral  + Nasal overlap considerably in the center-right, forming a broad shared cluster, suggesting more similar communities between these two mucosal sites.

8. Why do you think these samples are grouping together? The feature table summary visualization (table.qzv, generated via qiime feature-table summarize) is the key file. It provides a per-sample sequencing depth histogram and interactive table showing the minimum, median, and maximum read counts across all samples — which informs the rarefaction curve range and the sampling depth cutoff.    
The clustering pattern reflects shared ecological and physiological characteristics between body sites. The skin and udder are both external epithelial surfaces exposed to similar environmental microbes and physical conditions, which explains their overlap. Fecal samples reflect the highly specialized anaerobic gut environment, driving strong separation from all other sites. Nasal and oral samples share characteristics with upper respiratory and oral mucosal surfaces, both of which are exposed to airborne microbes and saliva/mucus, explaining their partial overlap.    

9. What test can you run to determine if the groups are significantly different?    
1. PERMANOVA (Permutational Multivariate Analysis of Variance) is a non-parametric test that evaluates whether differences in community composition between groups exceed what would be expected by random chance, using permutation-based inference on a distance matrix.    

10. What command would you use to run that test?    

```
#insert command for running the test you suggest from question 7

qiime diversity beta-group-significance \
    --i-distance-matrix core_metrics_results/unweighted_unifrac_distance_matrix.qza \
    --m-metadata-file metadata/cow_metadata.txt \
    --m-metadata-column body_site \
    --o-visualization core_metrics_results/unweighted_unifrac_permanova.qzv \
    --p-pairwise \

```