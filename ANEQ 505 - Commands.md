*Note:* when setting up you should look in your HOME directory "show dotfiles" and look for ".bashrc" and add into it "export TMPDIR=/scratch/alpine/$USER"

1. Going to scratch directory: 
	1. cd /scratch/alpine/$USER/aneq505
2. Starting a job:
	1. sinteractive --reservation=aneq505 --time=01:00:00 --partition=amilan --nodes=1 --ntasks=2 --qos=normal
3. make a directory using the mkdir command   
	1. mkdir decomp_tutorial`  
4. move into that directory using 
	1. cd   cd decomp_tutorial
5. # we first purge any loaded modules from the node we are on, this ensures no conflicting modules are "on" modules are preloaded packages of things people commonly use  
	1. module purge   
  6. we can turn "on" or "load" qiime2  
	  1. module load qiime2/2024.10_amplicon
7. Copy the data
	1. cp /pl/active/courses/2025_summer/CSU_2025/q2_workshop_final/QIIME2/metadata_q2_workshop.txt .
8. Metadata
	1. 
9. Decomp
	1. qiime metadata tabulate \ --m-input-file metadata.txt \ --o-visualization metadata.qzv
	

