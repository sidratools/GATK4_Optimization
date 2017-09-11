#########################################################################
# Fake Spark GATK 4.0 workflow						#
#									#
#   Step 1:								#
#      BWA + Samtools + Basecalibrator steps				#
#      version 3.0							#
#      date: 7 Sep  2017						#
#     Nagarajan Kathiresan, Ph.D., nkathiresan@sidra.org, www.sidra.org #
#########################################################################


## Software modules 
module load java/1.8.121
module load SAMtools/1.3
rm -Rf first.sh
export CORES=32;

## Programs settings
export BWA=/gpfs/projects/NAGA/naga/NGS/pipeline/GATK_Best_Practices/apps/bwa ;
export SAMTOOLS=/gpfs/projects/NAGA/naga/NGS/pipeline/GATK_Best_Practices/apps/samtools ;
export GATK="/gpfs/software/genomics/GATK/4b.2/gatk/gatk-launch"

## Reference settings
export REF=/gpfs/data_jrnas1/ref_data/Hsapiens/hs37d5/hs37d5.fa ;
export VARDBDIR=/gpfs/data_jrnas1/ref_data/Hsapiens/GRCh37/variation;
export MILLS=${VARDBDIR}/Mills_and_1000G_gold_standard.indels.vcf.gz;
export DBSNP=${VARDBDIR}/dbsnp_138.vcf.gz;

## Project settings

export PRJNAME=gcat_set_042
export PRJDIR=$PWD/${PRJNAME} ;
export INDIR=/gpfs/data_jrnas1/naga/PlatinumGenomes/Compressed_Fastq
export BAMDIR=${PRJDIR}/bam
export VCFDIR=${PRJDIR}/vcf
export LOGDIR=${PRJDIR}/logs


export STEPNAME=(BWAMEM SortSam MarkDuplicate AddOrReplaceReadGroups SamTools BaseRecalibrator)

export BAMLIST=${PWD}/list ;
export NBBAM=$(cat $BAMLIST | wc -l)
export ALLSMPL=""
mkdir -p $BAMDIR
mkdir -p $VCFDIR
mkdir -p $LOGDIR

export var=0;

for sample in `cat $BAMLIST`; 
do
    let "var+=1";
    export prefix=${sample};
    export JNAME=${prefix}_${STEPNAME};
    echo $JNAME ;

   ### BWA - Map to Reference 
    export BSUB="bsub -P test -m nsnodes -n ${CORES} -R \"span[hosts=1]\" -J ${STEPNAME[0]}[$var] -o ${LOGDIR}/${prefix}.${STEPNAME[0]}.out -e ${LOGDIR}/${prefix}.${STEPNAME[0]}.err ";
    echo $BSUB;
    echo  ${STEPNAME[0]} : $prefix
    echo "time -p $BWA mem -t ${CORES} -M -R \"@RG\tID:${prefix}\tLB:${prefix}\tSM:${prefix}\tPL:ILLUMINA\" $REF ${INDIR}/${prefix}_1.fastq.gz ${INDIR}/${prefix}_2.fastq.gz > ${BAMDIR}/${prefix}.sam " > ./first.sh
    cat first.sh
    cat first.sh | $BSUB ;
  
   ### GATK4 beta1 - Sort SAM into BAM
    CMD[1]="time -p $GATK SortSam --input ${BAMDIR}/${prefix}.sam --output ${BAMDIR}/${prefix}.bam --SORT_ORDER coordinate"
   ### GATK4 beta1 - Mark duplicate reads
    CMD[2]="time -p $GATK MarkDuplicates --input ${BAMDIR}/${prefix}.bam --output ${BAMDIR}/${prefix}_dedup.bam --METRICS_FILE ${BAMDIR}/${prefix}_dedup.metrics.txt"
   ### GATK4 beta1 - Add read group information (this is important for downstream GATK functionalities) 
    CMD[3]="time -p $GATK AddOrReplaceReadGroups --input ${BAMDIR}/${prefix}_dedup.bam --output ${BAMDIR}/${prefix}_AddOrReplaceReadGroups.bam --RGLB ${prefix} --RGPL illumina --RGPU ${prefix} --RGSM ${prefix}"
   ### SAMTools - Index BAM file
    CMD[4]="time -p $SAMTOOLS index ${BAMDIR}/${prefix}_AddOrReplaceReadGroups.bam" ;

   ### Recalibrate base quality scores 
    #GATK BaseRecalibrator
    CMD[5]="time -p $GATK BaseRecalibrator --input ${BAMDIR}/${prefix}_AddOrReplaceReadGroups.bam --reference $REF --knownSites $DBSNP --output ${BAMDIR}/${prefix}.recal.table"

      for stepid in `seq 1 $((${#STEPNAME[@]}-1))`;
        do
            echo  ${STEPNAME[$stepid]} :  $prefix  
            export BSUB="bsub -P test -m nsnodes -n ${CORES} -R \"span[hosts=1]\" -w ${STEPNAME[${stepid}-1]}[$var] -J ${STEPNAME[$stepid]}[$var] -o ${LOGDIR}/${prefix}.${STEPNAME[$stepid]}.out -e ${LOGDIR}/${prefix}.${STEPNAME[$stepid]}.err ";
     #       echo $BSUB;    
     #       echo ${CMD[${stepid}]};
            echo ${CMD[${stepid}]} | $BSUB;    
       done
done
echo " $var samples submitted in ${#STEPNAME[@]} stages";
