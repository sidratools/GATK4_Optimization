#!/bin/bash
#########################################################################
# Optimization of HaplotypeCaller					#
#      version 3.0                                                      #
#      date: 7 Sep 2017 						#
#     Nagarajan Kathiresan, Ph.D., nkathiresan@sidra.org, www.sidra.org #
#########################################################################

## Software modules
module load java/1.8.121
module load SAMtools/1.3

## Programs settings
export BWA="time -p /gpfs/projects/NAGA/naga/NGS/pipeline/GATK_Best_Practices/apps/bwa" ;
export SAMTOOLS="time -p /gpfs/projects/NAGA/naga/NGS/pipeline/GATK_Best_Practices/apps/samtools" ;
export GATK="time -p /gpfs/software/genomics/GATK/4b.2/gatk/gatk-launch" ;

## Reference settings
export REF=/gpfs/data_jrnas1/ref_data/Hsapiens/hs37d5/hs37d5.fa ;
export VARDBDIR=/gpfs/data_jrnas1/ref_data/Hsapiens/GRCh37/variation;
export MILLS=${VARDBDIR}/Mills_and_1000G_gold_standard.indels.vcf.gz;
export DBSNP=${VARDBDIR}/dbsnp_138.vcf.gz;

## Project settings
export PRJNAME=gcat_set_042;
export PRJDIR=$PWD/${PRJNAME} ;
export BAMDIR=${PRJDIR}/bam
export VCFDIR=${PRJDIR}/vcf
export LOGDIR=${PRJDIR}/logs


export GLBASE=165;
export CORES=1;
export PREFIX=gcat_set_042 ;

#BSUB -L /bin/bash
#BSUB -J gcat_set_042.HC[1-84]
#BSUB -w gcat_set_042.PRM
#BSUB -e gcat_set_042/logs/HC.gcat_set_042.%I.err
#BSUB -o gcat_set_042/logs/HC.gcat_set_042.%I.out
#BSUB -n 1
#BSUB -P test


if [ ${LSB_JOBINDEX} -eq 23 ] ; then
  ${SAMTOOLS} view -@ ${CORES} -o ${BAMDIR}/${PREFIX}.recal-merged-bqsr-X.bam ${BAMDIR}/${PREFIX}.recal-merged-bqsr.bam X ;
  ${SAMTOOLS} index ${BAMDIR}/${PREFIX}.recal-merged-bqsr-X.bam ;
  $GATK HaplotypeCaller --reference $REF --intervals X --input ${BAMDIR}/${PREFIX}.recal-merged-bqsr-X.bam --dbsnp $DBSNP --emitRefConfidence GVCF --readValidationStringency LENIENT --nativePairHmmThreads ${CORES} --createOutputVariantIndex true --output ${VCFDIR}/${PREFIX}.raw.snps.indels-X.g.vcf

elif [ ${LSB_JOBINDEX} -eq 24 ]; then
  ${SAMTOOLS} view -@ ${CORES} -o ${BAMDIR}/${PREFIX}.recal-merged-bqsr-Y.bam ${BAMDIR}/${PREFIX}.recal-merged-bqsr.bam Y ;
  ${SAMTOOLS} index ${BAMDIR}/${PREFIX}.recal-merged-bqsr-Y.bam ;
  $GATK HaplotypeCaller --reference $REF --intervals Y --input ${BAMDIR}/${PREFIX}.recal-merged-bqsr-Y.bam --dbsnp $DBSNP --emitRefConfidence GVCF --readValidationStringency LENIENT --nativePairHmmThreads ${CORES} --createOutputVariantIndex true --output ${VCFDIR}/${PREFIX}.raw.snps.indels-Y.g.vcf

elif [ ${LSB_JOBINDEX} -eq 25 ]; then 
  ${SAMTOOLS} view -@ ${CORES} -o ${BAMDIR}/${PREFIX}.recal-merged-bqsr-MT.bam ${BAMDIR}/${PREFIX}.recal-merged-bqsr.bam MT ;
  ${SAMTOOLS} index ${BAMDIR}/${PREFIX}.recal-merged-bqsr-MT.bam ;
  $GATK HaplotypeCaller --reference $REF --intervals MT --input ${BAMDIR}/${PREFIX}.recal-merged-bqsr-MT.bam --dbsnp $DBSNP --emitRefConfidence GVCF --readValidationStringency LENIENT --nativePairHmmThreads ${CORES} --createOutputVariantIndex true --output ${VCFDIR}/${PREFIX}.raw.snps.indels-MT.g.vcf

elif [ ${LSB_JOBINDEX} -gt 25 ]; then
  export GLINDEX=$((${LSB_JOBINDEX}+${GLBASE}));
  export GLREF="GL000${GLINDEX}.1"
  ${SAMTOOLS} view -@ ${CORES} -o ${BAMDIR}/${PREFIX}.recal-merged-bqsr-${GLREF}.bam ${BAMDIR}/${PREFIX}.recal-merged-bqsr.bam ${GLREF} ;
  ${SAMTOOLS} index ${BAMDIR}/${PREFIX}.recal-merged-bqsr-${GLREF}.bam ;
  $GATK HaplotypeCaller --reference $REF --intervals ${GLREF} --input ${BAMDIR}/${PREFIX}.recal-merged-bqsr-${GLREF}.bam --dbsnp $DBSNP --emitRefConfidence GVCF --readValidationStringency LENIENT --nativePairHmmThreads ${CORES} --createOutputVariantIndex true --output ${VCFDIR}/${PREFIX}.raw.snps.indels-${GLREF}.g.vcf

else 
  ${SAMTOOLS} view -@ ${CORES} -o ${BAMDIR}/${PREFIX}.recal-merged-bqsr-${LSB_JOBINDEX}.bam ${BAMDIR}/${PREFIX}.recal-merged-bqsr.bam ${LSB_JOBINDEX} ;
  ${SAMTOOLS} index ${BAMDIR}/${PREFIX}.recal-merged-bqsr-${LSB_JOBINDEX}.bam ;
  $GATK HaplotypeCaller --reference $REF --intervals ${LSB_JOBINDEX} --input ${BAMDIR}/${PREFIX}.recal-merged-bqsr-${LSB_JOBINDEX}.bam --dbsnp $DBSNP --emitRefConfidence GVCF --readValidationStringency LENIENT --nativePairHmmThreads ${CORES} --createOutputVariantIndex true --output ${VCFDIR}/${PREFIX}.raw.snps.indels-${LSB_JOBINDEX}.g.vcf

fi
