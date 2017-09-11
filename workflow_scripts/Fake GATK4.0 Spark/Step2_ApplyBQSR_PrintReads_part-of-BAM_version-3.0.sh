#!/bin/bash
#########################################################################
# ApplyBQSR + PrintReads Optimization					#
#      version 3.0                                                      #
#      date: 7 Sep 2017	                                                #
#     Nagarajan Kathiresan, Ph.D., nkathiresan@sidra.org, www.sidra.org #
#########################################################################

export GLBASE=165;
export CORES=1;
## Software modules
module load java/1.8.121
module load SAMtools/1.3

## Programs settings
export SAMTOOLS="time -p /gpfs/software/genomics/SAMtools/1.3/bin/samtools" ;
export GATK="time -p /gpfs/software/genomics/GATK/4b.2/gatk/gatk-launch" ;

## Reference settings
export REF=/gpfs/data_jrnas1/ref_data/Hsapiens/hs37d5/hs37d5.fa ;
export VARDBDIR=/gpfs/data_jrnas1/ref_data/Hsapiens/GRCh37/variation;
export MILLS=${VARDBDIR}/Mills_and_1000G_gold_standard.indels.vcf.gz;
export DBSNP=${VARDBDIR}/dbsnp_138.vcf.gz;

## Project settings


export PRJNAME=gcat_set_042;
export PRJDIR=$PWD/${PRJNAME} ;

export INDIR=${PRJDIR}/bam ;
export BAMDIR=${PRJDIR}/bam ;
export VCFDIR=${PRJDIR}/vcf ;
export LOGDIR=${PRJDIR}/logs ;

mkdir -p $BAMDIR;
mkdir -p $VCFDIR;
mkdir -p $LOGDIR;

export PREFIX=gcat_set_042 ;

#BSUB -L /bin/bash
#BSUB -J gcat_set_042.PR[1-84]
#BSUB -w BaseRecalibrator[1] 
#BSUB -e gcat_set_042/logs/PR.gcat_set_042.%I.err
#BSUB -o gcat_set_042/logs/PR.gcat_set_042.%I.out
#BSUB -n 1
#BSUB -R span[hosts=1]
#BSUB -P test

if [ ${LSB_JOBINDEX} -eq 23 ] ; then
   ${SAMTOOLS} view -@ ${CORES} -o ${BAMDIR}/${PREFIX}.AddOrReplaceReadGroups-X.bam ${BAMDIR}/${PREFIX}_AddOrReplaceReadGroups.bam X;
   ${SAMTOOLS} index ${BAMDIR}/${PREFIX}.AddOrReplaceReadGroups-X.bam;
   $GATK ApplyBQSR --intervals X --bqsr_recal_file ${BAMDIR}/${PREFIX}.recal.table --readValidationStringency LENIENT --input ${BAMDIR}/${PREFIX}.AddOrReplaceReadGroups-X.bam --output ${BAMDIR}/${PREFIX}.BQSR-X.bam;
   $GATK PrintReads --intervals X --input ${BAMDIR}/${PREFIX}.BQSR-X.bam --reference $REF --output ${BAMDIR}/${PREFIX}.recal-X.bam;

elif [ ${LSB_JOBINDEX} -eq 24 ]; then
  ${SAMTOOLS} view -@ ${CORES} -o ${BAMDIR}/${PREFIX}.AddOrReplaceReadGroups-Y.bam ${BAMDIR}/${PREFIX}_AddOrReplaceReadGroups.bam Y ;
  ${SAMTOOLS} index ${BAMDIR}/${PREFIX}.AddOrReplaceReadGroups-Y.bam ;
  $GATK ApplyBQSR --intervals Y --bqsr_recal_file ${BAMDIR}/${PREFIX}.recal.table --readValidationStringency LENIENT --input ${BAMDIR}/${PREFIX}.AddOrReplaceReadGroups-Y.bam --output ${BAMDIR}/${PREFIX}.BQSR-Y.bam
  $GATK PrintReads --intervals Y --input ${BAMDIR}/${PREFIX}.AddOrReplaceReadGroups-Y.bam --reference $REF --output ${BAMDIR}/${PREFIX}.recal-Y.bam ;

elif [ ${LSB_JOBINDEX} -eq 25 ]; then
 ${SAMTOOLS} view -@ ${CORES} -o ${BAMDIR}/${PREFIX}.AddOrReplaceReadGroups-MT.bam ${BAMDIR}/${PREFIX}_AddOrReplaceReadGroups.bam MT ;
 ${SAMTOOLS} index ${BAMDIR}/${PREFIX}.AddOrReplaceReadGroups-MT.bam ;
 $GATK ApplyBQSR --intervals MT --bqsr_recal_file ${BAMDIR}/${PREFIX}.recal.table --readValidationStringency LENIENT --input ${BAMDIR}/${PREFIX}.AddOrReplaceReadGroups-MT.bam --output ${BAMDIR}/${PREFIX}.BQSR-MT.bam
 $GATK PrintReads --intervals MT --input ${BAMDIR}/${PREFIX}.AddOrReplaceReadGroups-MT.bam --reference $REF --output ${BAMDIR}/${PREFIX}.recal-MT.bam ;

elif [ ${LSB_JOBINDEX} -gt 25 ]; then
  export GLINDEX=$((${LSB_JOBINDEX}+${GLBASE}));
  export GLREF="GL000${GLINDEX}.1"
  ${SAMTOOLS} view -@ ${CORES} -o ${BAMDIR}/${PREFIX}.AddOrReplaceReadGroups-${GLREF}.bam ${BAMDIR}/${PREFIX}_AddOrReplaceReadGroups.bam ${GLREF} ;
  ${SAMTOOLS} index ${BAMDIR}/${PREFIX}.AddOrReplaceReadGroups-${GLREF}.bam ;
  $GATK ApplyBQSR --intervals ${GLREF} --bqsr_recal_file ${BAMDIR}/${PREFIX}.recal.table --readValidationStringency LENIENT --input ${BAMDIR}/${PREFIX}.AddOrReplaceReadGroups-${GLREF}.bam --output ${BAMDIR}/${PREFIX}.BQSR-${GLREF}.bam ;
  $GATK PrintReads --intervals ${GLREF} --input ${BAMDIR}/${PREFIX}.AddOrReplaceReadGroups-${GLREF}.bam --output ${BAMDIR}/${PREFIX}.recal-${GLREF}.bam
else 
   ${SAMTOOLS} view -@ ${CORES} -o ${BAMDIR}/${PREFIX}.AddOrReplaceReadGroups-${LSB_JOBINDEX}.bam ${BAMDIR}/${PREFIX}_AddOrReplaceReadGroups.bam ${LSB_JOBINDEX} ;
   ${SAMTOOLS} index ${BAMDIR}/${PREFIX}.AddOrReplaceReadGroups-${LSB_JOBINDEX}.bam ;
   $GATK ApplyBQSR --intervals ${LSB_JOBINDEX} --bqsr_recal_file ${BAMDIR}/${PREFIX}.recal.table --readValidationStringency LENIENT --input ${BAMDIR}/${PREFIX}.AddOrReplaceReadGroups-${LSB_JOBINDEX}.bam --output ${BAMDIR}/${PREFIX}.BQSR-${LSB_JOBINDEX}.bam ;
   $GATK PrintReads --intervals ${LSB_JOBINDEX} --input ${BAMDIR}/${PREFIX}.AddOrReplaceReadGroups-${LSB_JOBINDEX}.bam --output ${BAMDIR}/${PREFIX}.recal-${LSB_JOBINDEX}.bam
fi
