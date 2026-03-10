**ANEQ Class Assignment #2: Practice Qiime2 Workflow**

Due: March 5th 2026 at midnight


**For complete credit for this assignment, you must answer all questions and include all commands in your obsidian upload.**

------------------------------------------------------------------
**Learning Objectives**
1. Practice independently running a partial Qiime2 workflow on new data using both the command line and slurm to submit jobs. 
2. Practice recording commands and editing code to match your analysis.
3. Perform taxonomic assignments using greengenes2, filtering out unwanted taxonomy and large amplicons, run another job script for generating a SEPP tree.
--------------------------------------------------

**Cow Site Data Workflow**, part 2

Load qiime2 in a terminal session after you go into the taxonomy folder

```
# Insert the two commands to activate qiime2

module purge
module load qiime2/2024.10_amplicon


```

### Remove long (300+ base pair) amplicons from the representative sequences file and the feature table

```
# filter out any large amplicons from the seqs and table (because they are contaminates)

cd /scratch/alpine/$USER/cow/dada2

qiime feature-table filter-seqs \
--i-data cow_seqs_dada2.qza \
--m-metadata-file cow_seqs_dada2.qza \
--p-where 'length(sequence) < 300' \
--o-filtered-data cow_seqs_dada2_filtered300.qza

qiime feature-table tabulate-seqs \
--i-data cow_seqs_dada2_filtered300.qza \
--o-visualization cow_seqs_dada2_filtered300.qzv

qiime feature-table filter-features \
--i-table cow_table_dada2.qza \
--m-metadata-file cow_seqs_dada2_filtered300.qza \
--o-filtered-table cow_table_dada2_filtered300.qza
  
qiime feature-table summarize \
--i-table cow_table_dada2_filtered300.qza \
--m-sample-metadata-file ../metadata/cow_metadata.txt \
--o-visualization cow_table_dada2_filtered300.qzv
    
```


### Classify taxonomy using GreenGenes2

First get the Greengenes2 database:

```
cd /scratch/alpine/$USER/cow/taxonomy
```

```
wget --no-check-certificate https://ftp.microbio.me/greengenes_release/2024.09/2024.09.backbone.v4.nb.qza
```

Classify taxonomy using GreenGenes2 classify the ASVs (takes about 5 mins). ~={red}(1point)=~
```
qiime feature-classifier classify-sklearn \
  --i-reads ../dada2/cow_seqs_dada2_filtered300.qza \
  --i-classifier 2024.09.backbone.v4.nb.qza \
  --o-classification taxonomy_gg2_filtered.qza
```

Visualize the taxonomy of your ASVs: ~={red}(1point)=~
```
qiime metadata tabulate \
  --m-input-file taxonomy_gg2_filtered.qza \
  --o-visualization taxonomy_gg2_filtered.qzv
```

- Filter mitochondria and chloroplast out to generate a filtered feature table, keep only ASVs with a class or lower taxonomy. fill in the blank (--p-exclude) to exclude these DNA. Fill in the blank to include only class level or below classifications. (~={red}1point)=~
```
qiime taxa filter-table \
  --i-table ../dada2/cow_table_dada2_filtered300.qza \
  --i-taxonomy taxonomy_gg2_filtered.qza \
  --p-exclude mitochondria,chloroplast,sp004296775 \
  --p-include c__ \
  --o-filtered-table ../dada2/table_nomitochloro_gg2_filtered300.qza
```

- Visualize the taxa bar plot
```
qiime taxa barplot \
  --i-table ../dada2/table_nomitochloro_gg2_filtered300.qza \
  --i-taxonomy ../taxonomy/taxonomy_gg2_filtered.qza \
  --m-metadata-file ../metadata/cow_metadata.txt \
  --o-visualization taxa_barplot_nomitochloro_gg2_filtered300.qzv
```

## Filtered Taxa Bar Plot Questions ~={red}(10 points)=~

**Question 1**: Attach a picture of your taxa bar plot, organized by cow sampling location (body_site) at the level 7 taxonomic level. What general trends do you notice? 
Overall, body site is a strong driver of microbiome composition. Fecal samples are dominated by Bacteroidia and Clostridia with a relatively consistent structure across individuals. Skin and udder samples show more variability. Nasal and oral samples are compositionally distinct from gut samples. Additionally, controls are nearly depleted of taxa, as expected.    


**_Question 2**: What are the top 2 most abundant bacterial **classes** in the fecal samples? 
The top 2 most abundant bacterial classes in fecal samples are *Bacteroidia* and *Clostridia*.   

**_Question 3**: What highly abundant ASV is shared between both the udder and skin samples?
The most highly abundant ASV shared between udder and skin is *Faecousia sp000434635*, which could be due to fecal surface contamination in a farm environment.   

**_Question 4**: Which samples (still sorted by body_site) have higher alpha diversity in terms of observed features?
The samples with more alpha diversity in terms of observed features is found in the skin samples.   

**Question 5**: do all samples contain archaea as well?
Not all individual samples contained archaea, but every body site category did; controls and negative extractions did not, which makes sense.    

**Question 6**: why do we filter out sp004296775?
*sp004296775* is filtered out because it is a misclassified chloroplast sequence. The classifier assigns it a bacterial label, but it is of the chloroplast endosymbiont.  


**Question 7**: what is the difference between these two flags? 
--p-exclude mitochondria,chloroplast,sp004296775 \
actively removes ASVs whose taxonomy contains mitochondria, chloroplast, or *sp004296775* (another chloroplast classification based on Greengenes).   
--p-include c__ \
keeps only ASVs classified at least to class level, dropping anything too poorly resolved.  

They can be used in conjunction to remove contaminants and low-confidence classifications.    

**Question 8**: do the positive controls look the same as each other? Yes or No?
Yes. Both PC1.3 and PC1.4 are dominated by the same taxon in the same order, consistent with mock communities.   


**Question 9**: Do the negative/extraction controls (Samples labeled as EC), look like the positive controls? Yes or no? 
No, they do not look like positive controls. However, EC1.4 and EC2.3 show a profile similar to the positive control, suggesting cross-contamination into those extraction batches.    


**Question 10**: do the negative/extraction controls (Samples labeled as EC), look like the real samples? Yes or no?
No. EC has far fewer reads (a mean of 655), and they also lack coherent community structures, as expected for such negative controls.    


## Phylogenetic tree ~={red}(1point)=~

Create a job script to run the phylogenetic tree building. Remember you must start a new terminal session, navigate to your slurm directory, and then submit the job. You do NOT need to start any other interactive sessions.This job will take about an hour. 

Go to OnDemand and create a new text file for your job script
```
nano <tree.sh>
```

```
#!/bin/bash
#SBATCH --job-name=tree
#SBATCH --nodes=1
#SBATCH --ntasks=8
#SBATCH --partition=amilan
#SBATCH --time=04:00:00
#SBATCH --mail-type=ALL
#SBATCH --mail-user=YOUR_EMAIL_HERE@colostate.edu
#SBATCH --output=slurm-%j.out
#SBATCH --qos=normal

#Activate qiime
#Insert the two commands you need to load qiime2
module purge
module qiime2/2024.10_amplicon

cd /scratch/alpine/$USER/aneq505/hw1/tree

#Get reference
wget --no-check-certificate -P ../tree https://ftp.microbio.me/greengenes_release/2022.10/2022.10.backbone.sepp-reference.qza


#Command
qiime fragment-insertion sepp \
  --i-representative-sequences ../dada2/cow_seqs_dada2_filtered300.qza \
  --i-reference-database 2022.10.backbone.sepp-reference.qza \
  --o-tree tree_gg2.qza \
  --o-placements tree_placements_gg2.qza \
  --p-threads 4
```

- submit the job from the terminal
```
#submit the job
sbatch YourJobName.sh
```
We will use this file in the next homework!

### Once this job finishes, copy and paste what the slurm email says here ~={red}(1 point)=~: 
Job ID: 24582867
Cluster: alpine
User/Group: c837169103@colostate.edu/c837169103pgrp@colostate.edu
State: COMPLETED (exit code 0)
Nodes: 1
Cores per node: 8

-------- CPU Metrics --------
CPU Utilized: 03:45:59
CPU Efficiency: 40.25% of 09:21:28 core-walltime
Job Wall-clock time: 01:10:11
Memory Utilized: 11.82 GiB
Memory Efficiency: 39.41% of 30.00 GiB (3.75 GiB/core)
