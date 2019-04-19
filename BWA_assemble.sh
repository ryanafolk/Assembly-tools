# Script to map reads with BWA and extract consensus sequence
# Make sure to change the looping glob pattern
# Dependencies: samtools, bammtools, bwa
# Do not run multiple loops concurrently in the same directory without changing the temporary file handling

mkdir tmp
mkdir consensus_sequences

for i in *_P1.fastq; 
do 
g=$(echo ${i} | sed 's/_P1\.fastq//g')
# Assemble
# Make sure to index reference first
bwa mem -t 16 REFERENCE.fasta ${g}_P1.fastq ${g}_P2.fastq > temp.sam

# Call consensus sequence
# Make sure to set haploid for chloroplast data
samtools sort -T ./tmp/aln.sorted -o temp.bam temp.sam
samtools mpileup -uf REFERENCE.fasta temp.bam > bcf.tmp
# In the next command bcftools should have this argument for chloroplast data: --ploidy 1; diploid for nucleus
bcftools call --ploidy 1 -c bcf.tmp | vcfutils.pl vcf2fq > ./consensus_sequences/${g}.consensus.fq
rm temp.sam temp.bam bcf.tmp ./tmp/aln.sorted*

done
