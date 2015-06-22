#! /bin/bash
#$ -j y
#$ -cwd

# ensure that the script fails on error
set -e

# set -x to see on terminal what commands are executed
# only for debugging
set -x

#$1: study name – “testing”
#$2: number of chromosome – “22”

#check for hte number of arguments passed.
if [ $# -lt 2 ];then
    echo "run_preprocessing.sh requires at a minimum two arguments: studyname chromosomenumber "
    exit 1
fi 

study=$1
chromosome_num=$2
file=${study}


CDIR='pwd'

#file="BioMe-AA_ILLUMINA"
#num=22
#study="BioMe-AA_ILLUMINA"


echo "SNP names update"
## bash snp_names_update.sh input_prefix output
bash snp_names_update.sh $file ${study}-${chromosome_num}-result

echo "monomorphic SNPs"
Rscript --vanilla more-alleles-2015-05-25.R ALL.chr${chromosome_num}.phase3_shapeit2_mvncall_integrated_v5a.20130502.genotypes.vcf.gz ${study}-${chromosome_num}-result ${study}-${chromosome_num}-result2

echo "liftOver"
bash liftover_to_37.sh ${study}-${chromosome_num}-result2


echo "HRC process step"
perl HRC-check-bim.pl ${study}-${chromosome_num}-result2-final.bim

echo "HRC 2nd step"
bash Run-plink.sh
rm *-${study}-${chromosome_num}-result2-final.bim
## generate xxx-updated.bim

echo "convert into VCF"
mkdir $study-${chromosome_num}
mv ${study}-${chromosome_num}-result2-final-updated* $study-${chromosome_num}/
cd ${study}-${chromosome_num}
plink-1.9 --bfile ${study}-${chromosome_num}-result2-final-updated --recode vcf --out ${study}.${chromosome_num}
gzip ${study}.${chromosome_num}.vcf
cd ..
