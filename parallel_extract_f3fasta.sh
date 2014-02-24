#!/bin/bash
#PBS -l nodes=1:ppn=1man 
#PBS -l walltime=72:00:00
#PBS -l mem=10gb
#PBS -q bigmem
#PBS -m ae
cd $PBS_O_WORKDIR
#The following command will copy fasta file in memory. The grep should be faster
if [ ! -f /dev/shm/Step2.F5.nodots.trimmedto25.csfasta ]; then
cp /gpfs/home/cdesai/Testing/Run3_BC43_Bowtie_Runs/Fresh_Run/Step2.F5.nodots.trimmedto25.csfasta /dev/shm/
fi

cat /gpfs/home/cdesai/Testing/Run3_BC43_Bowtie_Runs/Fresh_Run/Step3.commonheaders.txt.1 | xargs -I{} grep -m 1 -A 1 {} \
 /dev/shm/Step2.F5.nodots.trimmedto25.csfasta \
 > /gpfs/home/cdesai/Testing/Run3_BC43_Bowtie_Runs/Fresh_Run/Step3.F5.nodots.trimmedto25.common.csfasta.1
