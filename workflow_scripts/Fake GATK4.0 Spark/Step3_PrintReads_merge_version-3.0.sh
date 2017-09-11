#!/bin/bash
module load SAMtools/1.3

export PRJNAME=gcat_set_042;
export BAMDIR=${PWD}/${PRJNAME}/bam ;
export TMPDIR=${PWD}/${PRJNAME}/tmp ;
mkdir -f $TMPDIR;
export CORES=32 ;
export PREFIX=gcat_set_042 ;

## Software
export SAMTOOLS="time -p /gpfs/software/genomics/SAMtools/1.3/bin/samtools" ;
export GATK="time -p /gpfs/software/genomics/GATK/4b.2/gatk/gatk-launch" ;

## Reference 
export REF=/gpfs/data_jrnas1/ref_data/Hsapiens/hs37d5/hs37d5.fa
export VARDBDIR=/gpfs/data_jrnas1/ref_data/Hsapiens/GRCh37/variation
export MILLS=${VARDBDIR}/Mills_and_1000G_gold_standard.indels.vcf.gz
export DBSNP=${VARDBDIR}/dbsnp_138.vcf.gz

## File manupulation 

export INTER="recal"
export EXTN="bam" ;

## Get the list of all recalibrated BAM files
for i in `seq 1 22`; 
do
  PR_LIST+="${BAMDIR}/${PREFIX}.${INTER}-${i}.${EXTN} "
done
for i in X Y MT GL000191.1 GL000192.1 GL000193.1 GL000194.1 GL000195.1 GL000196.1 GL000197.1 GL000198.1 GL000199.1 GL000200.1 GL000201.1 GL000202.1 GL000203.1 GL000204.1 GL000205.1 GL000206.1 GL000207.1 GL000208.1 GL000209.1 GL000210.1 GL000211.1 GL000212.1 GL000213.1 GL000214.1 GL000215.1 GL000216.1 GL000217.1 GL000218.1 GL000219.1 GL000220.1 GL000221.1 GL000222.1 GL000223.1 GL000224.1 GL000225.1 GL000226.1 GL000227.1 GL000228.1 GL000229.1 GL000230.1 GL000231.1 GL000232.1 GL000233.1 GL000234.1 GL000235.1 GL000236.1 GL000237.1 GL000238.1 GL000239.1 GL000240.1 GL000241.1 GL000242.1 GL000243.1 GL000244.1 GL000245.1 GL000246.1 GL000247.1 GL000248.1 GL000249.1 
do
 PR_LIST+="${BAMDIR}/${PREFIX}.${INTER}-${i}.${EXTN} "
done
echo ${PR_LIST}


#BSUB -L /bin/bash
#BSUB -J gcat_set_042.PRM
#BSUB -w gcat_set_042.PR[1-84]
#BSUB -e gcat_set_042/logs/PRM.gcat_set_042.err
#BSUB -o gcat_set_042/logs/PRM.gcat_set_042.out
#BSUB -n 32
#BSUB -R span[hosts=1]
#BSUB -P test


  ${SAMTOOLS} merge -@ ${CORES} ${BAMDIR}/${PREFIX}.recal-merged-bqsr.bam ${PR_LIST}  
  ${SAMTOOLS} index ${BAMDIR}/${PREFIX}.recal-merged-bqsr.bam
