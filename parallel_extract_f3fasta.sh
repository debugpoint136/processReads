#!/bin/bash
#PBS -l nodes=1:ppn=1man 
#PBS -l walltime=72:00:00
#PBS -l mem=20gb
#PBS -q bigmem
#PBS -m ae
cd $PBS_O_WORKDIR
#The following command will copy fasta file in memory. The grep should be faster
if [ ! -f /dev/shm/Step2.F5.nodots.trimmedto25.csfasta ]; then
cp /gpfs/home/cdesai/Testing/Run3_BC43_Bowtie_Runs/Fresh_Run/Step2.F5.nodots.trimmedto25.csfasta /dev/shm/
fi

jobs_running_on_node = 0

for hdr in `ls -1 Step3.a*`;
do
cat /gpfs/home/cdesai/Testing/Run3_BC43_Bowtie_Runs/Fresh_Run/$hdr | xargs -I{} grep -m 1 -A 1 {} \
 /dev/shm/f3.csfasta \
 > /gpfs/home/cdesai/Testing/Run3_BC43_Bowtie_Runs/Fresh_Run/$hdr.nodots.trimmedto25.common.csfasta.1 &

$jobs_running_on_node = $jobs_running_on_node + 1 # keep track of how many jobs are running parallelly

 #note : & in the previous line puts the job in background.. so it will continue to run and fire the next command in script
 # That means that 50 jobs will start running at once on a single node!
 # Coz the main file is sitting on the mem of this machine.. so cant farm out the processes to other nodes for real parallelization
 # Else the file will have to re-read on all those nodes.. and there is no mechanism to relay the file from memory to memory between the nodes
 # So the workaround is.. we will give 10min breather after 5 jobs like below, trying not to overwhelm the system

 	n=$(($jobs_running_on_node%5))

 	if [ $n == 0 ];then
 	sleep 10m
  	fi 
 
done
