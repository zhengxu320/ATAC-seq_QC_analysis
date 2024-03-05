#!/bin/bash 
# This is for Docker pipe, default root dir is /atac-seq
# This is for Docker!!!


species=$1

# get pipe path, though readlink/realpath can do it, some version doesn't have that
pipe_path="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )" 
 

# common tools:
adapter_1="CTGTCTCTTATACACATCT"
adapter_2="CTGTCTCTTATACACATCT"
fastq_dump_tool='fastq-dump.2.10.0' #Command not found, but not important cause our test file format is not sra, so it will not be used
preseq="/opt/preseq_v2.0/preseq" #Changed the path from only name to full path, to make it work,(at least it will give some output when input 'preseq')
cutadapt="/usr/local/bin/cutadapt" #Exsiting
fastqc="/opt/miniconda/bin/fastqc" #Exsiting, but need to actiave conda first: source /opt/miniconda/bin/activate
samtools="/usr/local/bin/samtools" #Exsiting
bwa="/opt/bwa-0.7.16a//bwa" #Exsiting
methylQA="/opt/methylQA//methylQA" #Command not found,but if input the full path, it will give some output
macs2="/usr/local/bin/macs2" #Exsiting

# genome specific resources:
# I added the full path for each file, to make it work
if [[ $species == mm10 ]]; 
	then
	bwa_ref="/storage1/fs1/hprc/Active/xu.z1/AIAP_test_source/atac_seq/Resource/Genome/mm10/bwa_index_mm10/mm10.fa"
	chrom_size="/storage1/fs1/hprc/Active/xu.z1/AIAP_test_source/atac_seq/Resource/Genome/mm10/mm10.chrom.sizes"
	black_list="/storage1/fs1/hprc/Active/xu.z1/AIAP_test_source/atac_seq/Resource/Genome/mm10/mm10_black_list.bed"
	genome_size=2730871774
	promoter_file="/storage1/fs1/hprc/Active/xu.z1/AIAP_test_source/atac_seq/Resource/Genome/mm10/mm10_promoter_bistream_1kb.bed"
	coding_promoter="/storage1/fs1/hprc/Active/xu.z1/AIAP_test_source/atac_seq/Resource/Genome/mm10/mm10_promoter_coding_bistream_1kb.bed"
	macs2_genome='mm'
elif [[ $species == mm9 ]];
	then
	bwa_ref="/atac_seq/Resource/Genome/mm9/bwa_index_mm9/mm9.fa"
	chrom_size="/atac_seq/Resource/Genome/mm9/mm9_chrom_sizes"
	black_list="/atac_seq/Resource/Genome/mm9/mm9-blacklist.bed"
	genome_size=2725765481
	promoter_file="/atac_seq/Resource/Genome/mm9/mm9_promoter_bistream_1kb.bed"
	coding_promoter="/atac_seq/Resource/Genome/mm9/mm9_coding_promoter_bistream_1kb.bed"
	macs2_genome='mm'
elif [[ $species == hg38 ]]; #Edited the path to full path of AIAP_test_real to run the pipeline for hprc data
	then
	bwa_ref="/storage1/fs1/hprc/Active/xu.z1/AIAP_test_real/atac_seq/Resource/Genome/hg38/bwa_index_hg38.25/hg38.25_chromsome.fa"
	chrom_size="/storage1/fs1/hprc/Active/xu.z1/AIAP_test_real/atac_seq/Resource/Genome/hg38/hg38.25_chromsome.sizes"
	black_list="/storage1/fs1/hprc/Active/xu.z1/AIAP_test_real/atac_seq/Resource/Genome/hg38/hg38_black_list.bed"
	genome_size=3209286105
	promoter_file="/storage1/fs1/hprc/Active/xu.z1/AIAP_test_real/atac_seq/Resource/Genome/hg38/hg38_promoter_bistream_1kb.bed"
	coding_promoter="/storage1/fs1/hprc/Active/xu.z1/AIAP_test_real/atac_seq/Resource/Genome/hg38/hg38_coding_promoter_bistream_1kb.bed"
	macs2_genome='hs'
elif [[ $species == hg19 ]];
	then
	bwa_ref="/atac_seq/Resource/Genome/hg19/bwa_index_0.7.5/hg19.fa"
	chrom_size="/atac_seq/Resource/Genome/hg19/hg19_chromosome.size"
	black_list="/atac_seq/Resource/Genome/hg19/hg19_blacklist.bed"
	genome_size=3137161264
	promoter_file="/atac_seq/Resource/Genome/hg19/hg19_promoter_bistream_1kb.bed"
	coding_promoter="/atac_seq/Resource/Genome/hg19/hg19_promoter_coding_bistream_1kb.bed"
	macs2_genome='hs'
elif [[ $species == danRer10 ]];
	then
	bwa_ref="/atac_seq/Resource/Genome/danRer10/bwa_index_denRer10/danRer10.fa"
	chrom_size="/atac_seq/Resource/Genome/danRer10/danRer10.chrom.sizes"
	touch pesudo_bl.txt
	black_list="pesudo_bl.txt"
	genome_size=1340447187
	promoter_file="/atac_seq/Resource/Genome/danRer10/promoter_region_danRer10_bistream_1k.bed"
	coding_promoter="/atac_seq/Resource/Genome/danRer10/danRer10_coding_promoter_bistream_1k.bed"
	macs2_genome='mm'
elif [[ $species == danRer11 ]];
	then
	bwa_ref="/atac_seq/Resource/Genome/danRer11/bwa_index_GTCz11/GRCz11.fa"
	chrom_size="/atac_seq/Resource/Genome/danRer11/GRCz11_chrom.size"
	touch pesudo_bl.txt
        black_list="pesudo_bl.txt"
        genome_size=1345118429
	promoter_file="/atac_seq/Resource/Genome/danRer11/GRCz11_promoter_region.bed"
	coding_promoter="/atac_seq/Resource/Genome/danRer11/pseudo_GRCz11_coding_promoter_region.bed"
	macs2_genome='mm'
elif [[ $species == dm6 ]];
	then
	bwa_ref="/atac_seq/Resource/Genome/dm6/bwa_index_dm6/dm6.fa"
	chrom_size="/atac_seq/Resource/Genome/dm6/d.mel.chrom.sizes"
	touch pesudo_bl.txt
        black_list="pesudo_bl.txt"
        genome_size=143726002
	promoter_file="/atac_seq/Resource/Genome/dm6/promoter_region_from_Dmel.bed"
	coding_promoter="/atac_seq/Resource/Genome/dm6/pseudo_coding_promoter_region.bed"
	macs2_genome="dm"
elif [[ $species == rn6 ]];
	then
	bwa_ref="/atac_seq/Resource/Genome/rn6/bwa_index_rn6/rn6.fa"
	chrom_size="/atac_seq/Resource/Genome/rn6/rn6.chrom.sizes"
	touch pesudo_bl.txt
        black_list="pesudo_bl.txt"
        genome_size=2870182909
	promoter_file="/atac_seq/Resource/Genome/rn6/promoter_region.bed"
	coding_promoter="/atac_seq/Resource/Genome/rn6/coding_promoter_region.bed"
	macs2_genome="mm"
elif [[ $species == personalize ]];
	then
	echo "please add all your preferred file as reference, please make sure that you are very clear of which file is for which"
	echo "remove exit 1 after adding your file"
	exit 1
	baw_ref=" "
	chrom_size=" "
	black_list=" "
	genome_size=
	promoter_file=" "
	macs2_genome=" "
	coding_promoter=" "
fi

