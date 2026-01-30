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
	

