####################################################################################
# BWA + Picard + Samtools + GATK 3.7 Pipeline 					   #
#      version 2.0 (fixed /tmp issue in picardi)			           #
#      version 3.0 (fixed HC -nct 8 issue and $PWD used for list of input files)   #
#		   (included -m for nsnodes )					   #
#      date: 7 Sep 2017								   #
#      Pre-request:								   #
#        1. Modify PRJNAME							   #
#	 2. Update INDIR  according to your input data location			   #
#        3. Update BAMLIST accoring to your input file name(s) in the file list    #
#     Nagarajan Kathiresan, Ph.D., nkathiresan@sidra.org, www.sidra.org 	   #
####################################################################################

## Software modules 
module load Picard/2.6.0 
rm -Rf first.sh ;
export CORES=32;

## Project settings
export PRJNAME=gcat42 ;
export PRJDIR=$PWD/$PRJNAME ;
mkdir -p $PRJDIR ;
export INDIR=/gpfs/data_jrnas1/naga/PlatinumGenomes/Compressed_Fastq ;
export BAMDIR=${PRJDIR}/bam ;
export VCFDIR=${PRJDIR}/vcf ;
export LOGDIR=${PRJDIR}/logs ;
export TMP=${PRJDIR}/tmp ;

## Create the required directories 
export BAMLIST=${PWD}/list ;
export NBBAM=$(cat $BAMLIST | wc -l) ;
export ALLSMPL="" ;
mkdir -p $BAMDIR ;
mkdir -p $VCFDIR ;
mkdir -p $LOGDIR ;
mkdir -p $TMP ;


## Programs settings
export BWA=/gpfs/projects/NAGA/naga/NGS/pipeline/GATK_Best_Practices/apps/bwa ;
export SAMTOOLS=/gpfs/projects/NAGA/naga/NGS/pipeline/GATK_Best_Practices/apps/samtools ;
export GATK="java -XX:+UseParallelGC -XX:ParallelGCThreads=32 -Xmx128g -jar /gpfs/software/genomics/GATK/3.7/base/GenomeAnalysisTK.jar" ;
export PICARD="java -XX:+UseParallelGC -XX:ParallelGCThreads=32 -Xmx128g -Djava.io.tmpdir=${TMP} -jar /gpfs/software/genomics/Picard/2.6.0/build/libs/picard.jar " ;

## Reference settings
export REF=/gpfs/data_jrnas1/ref_data/Hsapiens/hs37d5/hs37d5.fa ;
export VARDBDIR=/gpfs/data_jrnas1/ref_data/Hsapiens/GRCh37/variation;
export MILLS=${VARDBDIR}/Mills_and_1000G_gold_standard.indels.vcf.gz;
export DBSNP=${VARDBDIR}/dbsnp_138.vcf.gz;
export STEPNAME=(BWAMEM SortSam MarkDuplicate AddOrReplaceReadGroups SamTools RealignerTargetCreator IndelRealigner BaseRecalibrator PrintReads HaplotypeCaller) ;

## NGS pipeline 
export var=0
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
  
   ### Picard - Sort SAM into BAM
    CMD[1]="time -p $PICARD SortSam I=${BAMDIR}/${prefix}.sam O=${BAMDIR}/${prefix}.bam SORT_ORDER=coordinate TMP_DIR=$TMP"
   ### Picard - Mark duplicate reads
    CMD[2]="time -p $PICARD MarkDuplicates I=${BAMDIR}/${prefix}.bam O=${BAMDIR}/${prefix}_dedup.bam METRICS_FILE=${BAMDIR}/${prefix}_dedup.metrics.txt"
   ### Picard - Add read group information (this is important for downstream GATK functionalities) 
    CMD[3]="time -p $PICARD AddOrReplaceReadGroups I=${BAMDIR}/${prefix}_dedup.bam O=${BAMDIR}/${prefix}_AddOrReplaceReadGroups.bam RGLB=${prefix} RGPL=illumina RGPU=${prefix} RGSM=${prefix}"
   ### SAMTools - Index BAM file
    CMD[4]="time -p $SAMTOOLS index ${BAMDIR}/${prefix}_AddOrReplaceReadGroups.bam" ;

   ### Realign locally around Indels
    #GATK RealignerTargetCreator
    CMD[5]="time -p $GATK -T RealignerTargetCreator -nt ${CORES} -R ${REF} -known ${MILLS} -I ${BAMDIR}/${prefix}_AddOrReplaceReadGroups.bam -o ${BAMDIR}/${prefix}.realigner.intervals"
    #GATK IndelRealigner
    CMD[6]="time -p $GATK -T IndelRealigner -R $REF -known ${MILLS} -I ${BAMDIR}/${prefix}_AddOrReplaceReadGroups.bam -targetIntervals ${BAMDIR}/${prefix}.realigner.intervals -o ${BAMDIR}/${prefix}.realigned.bam"

   ### Recalibrate base quality scores 
    #GATK BaseRecalibrator
    CMD[7]="time -p $GATK -T BaseRecalibrator -nct ${CORES} -I ${BAMDIR}/${prefix}.realigned.bam -R $REF -knownSites $DBSNP -o ${BAMDIR}/${prefix}.recal.table"
    #GATK PrintReads
    CMD[8]="time -p $GATK -T PrintReads -nct ${CORES} -I ${BAMDIR}/${prefix}.realigned.bam -R $REF -BQSR ${BAMDIR}/${prefix}.recal.table -o ${BAMDIR}/${prefix}.realigned.recal.bam"
   
   ### Call variant 
    #GATK HaplotypeCaller
    CMD[9]="time -p $GATK -T HaplotypeCaller -nct ${CORES} -pairHMM VECTOR_LOGLESS_CACHING -R $REF -I ${BAMDIR}/${prefix}.realigned.recal.bam --emitRefConfidence GVCF --variant_index_type LINEAR --variant_index_parameter 128000 --dbsnp $DBSNP -o ${VCFDIR}/${prefix}.raw.snps.indels.g.vcf"

      for stepid in `seq 1 $((${#STEPNAME[@]}-1))`;
        do
            echo  ${STEPNAME[$stepid]} :  $prefix  
            export BSUB="bsub -P test -m nsnodes -n ${CORES} -R \"span[hosts=1]\" -w ${STEPNAME[${stepid}-1]}[$var] -J ${STEPNAME[$stepid]}[$var] -o ${LOGDIR}/${prefix}.${STEPNAME[$stepid]}.out -e ${LOGDIR}/${prefix}.${STEPNAME[$stepid]}.err ";
     #       echo $BSUB;    
            #echo ${CMD[${stepid}]};
            echo ${CMD[${stepid}]} | $BSUB;    
       done

done

echo " $var samples submitted in ${#STEPNAME[@]} stages";
