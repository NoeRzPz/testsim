WD=~/testsim

mkdir -p $WD/res/genome

# Download the E.coli genome
wget -O $WD/res/genome/ecoli.fasta.gz ftp://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/000/005/845/GCF_000005845.2_ASM584v2/GCF_000005845.2_ASM584v2_genomic.fna.gz

#Unzip E.coli genome 
gunzip $WD/res/genome/ecoli.fasta.gz

for sid in $(ls $WD/data/*.fastq.gz | xargs basename -a | cut -d_ -f1 | sort -u)
do
	bash $WD/scripts/analyse_sample.sh $sid 
done

mkdir -p $WD/out/multiqc

multiqc -o $WD/out/multiqc $WD
