#!/bin/bash
    sh ${PWD}/Step1_BWA-MEM_Samtools_BaseRecalibrator_version-3.0.sh ;
bsub < ${PWD}/Step2_ApplyBQSR_PrintReads_part-of-BAM_version-3.0.sh ;
bsub < ${PWD}/Step3_PrintReads_merge_version-3.0.sh ;
bsub < ${PWD}/Step4_HaplotypeCaller_version-3.0.sh ;
bsub < ${PWD}/Step5_Merge_partial_gVCF_files_version-3.0.sh ;
