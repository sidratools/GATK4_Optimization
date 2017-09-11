#!/bin/bash
module load java/1.8.121
module load GATK/4.beta1

export PRJNAME=gcat_set_042 ;
export VCFDIR=${PWD}/${PRJNAME}/vcf ;
export TMPDIR=${PWD}/${PRJNAME}/tmp ;
export CORES=32;
export PREFIX=gcat_set_042 ;

export GATK="time -p /gpfs/software/genomics/GATK/4b.2/gatk/gatk-launch MergeVcfs" ;


export INTER="raw.snps.indels";
export EXTN="g.vcf" ;
export VCF_LIST="";
rm -f $PWD/execute.merge

echo -ne "$GATK " > ${PWD}/execute.merge ;
for i in `seq 1 22`; 
do
 echo -ne "--input ${VCFDIR}/${PREFIX}.${INTER}-${i}.${EXTN} " >> ${PWD}/execute.merge ;
done

for i in X Y MT GL000191.1 GL000192.1 GL000193.1 GL000194.1 GL000195.1 GL000196.1 GL000197.1 GL000198.1 GL000199.1 GL000200.1 GL000201.1 GL000202.1 GL000203.1 GL000204.1 GL000205.1 GL000206.1 GL000207.1 GL000208.1 GL000209.1 GL000210.1 GL000211.1 GL000212.1 GL000213.1 GL000214.1 GL000215.1 GL000216.1 GL000217.1 GL000218.1 GL000219.1 GL000220.1 GL000221.1 GL000222.1 GL000223.1 GL000224.1 GL000225.1 GL000226.1 GL000227.1 GL000228.1 GL000229.1 GL000230.1 GL000231.1 GL000232.1 GL000233.1 GL000234.1 GL000235.1 GL000236.1 GL000237.1 GL000238.1 GL000239.1 GL000240.1 GL000241.1 GL000242.1 GL000243.1 GL000244.1 GL000245.1 GL000246.1 GL000247.1 GL000248.1 GL000249.1
do
 echo -ne " --input ${VCFDIR}/${PREFIX}.${INTER}-${i}.${EXTN} " >> ${PWD}/execute.merge ;
done
echo -ne " --output ${VCFDIR}/${PREFIX}.Merged.g.vcf  --TMP_DIR $TMPDIR --reference /gpfs/data_jrnas1/ref_data/Hsapiens/hs37d5/hs37d5.fa " >> ${PWD}/execute.merge ;

#BSUB -L /bin/bash
#BSUB -J gcat_set_042.MergeVCF
#BSUB -w gcat_set_042.HC[1-84]
#BSUB -e gcat_set_042/logs/gcat_set_042.MergeVCF.err
#BSUB -o gcat_set_042/logs/gcat_set_042.MergeVCF.out
#BSUB -n 32
#BSUB -R span[hosts=1]
#BSUB -P test

cat ${PWD}/execute.merge ;
chmod +x ${PWD}/execute.merge ;
sh ${PWD}/execute.merge ;
