# Faking the Spark Behavior for the Next Generation Variant Discovery Workflow using GATK4 with workload schedulers


## Objectives

* Develop the automated Broad institute best practices workflow for next generation variant discovery using GATK 3.7, GATK 4.0 and GATK 4.0 Spark version with workload scheduler. 
* Compare the execution time between GATK 3.7, GATK 4.0 and GATK 4.0 Spark versions.
* Compare the output results (gVCF/VCF generated files) across GATK 3.7, GATK 4.0 and GATK 4.0 Spark versions.
* Faking the Spark behavior for the next generation variant discovery using GATK 4.0 with workload scheduler. 
* Compare the execution time and the output results (gVCF/VCF generated files) across GATK 4.0, GATK 4.0 Spark and Fake GATK 4.0 Spark. 


## Background

The next generation variant discovery workflow using GATK 4.0 is completely different from GATK 3.x due to the following reasons: 
* The Picard tools is used for some of the workflow steps (a) Sort SAM into BAM (b) Mark duplicate reads and (c) Add read group information in GATK 3.x. Whereas, the Picard tools are embedded into GATK 4.0. 
* The local realignment (i.e., realign locally around INDELs) is not part of GATK 4.0, whereas (a) RealignerTargetCreator and (b) IndelRealigner are some of the workflow steps in GATK 3.x. 
* The Spark tools are included in GATK 4.0 version. 

## Broad institute best practices workflow for next generation variant discovery
 
The next generation variant discovery workflow is developed based on Broad institute recommendations. We used GATK 3.7, GATK 4.0 beta2, GATK 4.0 Spark and Fake GATK 4.0 Spark versions. The workflow steps are summarized in the following Figure. 

![](https://github.com/sidratools/GATK4_Optimization/blob/master/Graphs/Next%20generation%20variant%20discovery%20workflow.png)
 

## Data set used for benchmarking 

We used Platinum Genomes project data (NA12878, NA12891 and NA12892) for benchmarking. 

## Comparison across 3 different pipelines

### Comparison of Execution time 

This following summary provides the execution time of various steps across 3 different pipelines.
 
![](https://github.com/sidratools/GATK4_Optimization/blob/master/Graphs/NGS%20workflow%20-%20Execution%20time%20for%20NA12892.png)

### Comparison of concordance/discordance across 3 pipelines^
^ Thanks to Najeeb 

![](https://github.com/sidratools/GATK4_Optimization/blob/master/Graphs/NGS%20pipeline%20-%20comparision.png)

### Reference 

1. Platinum Genomes project data: https://www.illumina.com/platinumgenomes.html 
2. 

## Contact details 

Nagarajan Kathiresan, Ph.D.,
Biomedical Informatics Division,
Sidra Medical and Research Center,
P.O. Box 26999, Doha, Qatar 

nkathiresan@sidra.org| www.sidra.org
