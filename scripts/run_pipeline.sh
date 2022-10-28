echo "-------- Starting pipeline at $(date +'%d %h %y, %r')... --------"
wd=~/testsim

echo "Downloading genome..."
mkdir -p $wd/res/genome
wget -c -O $wd/res/genome/ecoli.fasta.gz ftp://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/000/005/845/GCF_000005845.2_ASM584v2/GCF_000005845.2_ASM584v2_genomic.fna.gz
if [ "$?" -ne 0 ] # Checks if previous exit code is not equal to 0
then
    echo "Error downloading file. Usage: bash scripts/$0"
    exit 1 # Error signal, forces the script to exit with an error when downloading was not succesfull
fi
echo 

echo "Uncompressing genome..."
gunzip -f $wd/res/genome/ecoli.fasta.gz #Force to overwrite existing file, it avoids having to answer "yes" when rerunning pipeline
echo 

echo "Running STAR index..."
mkdir -p $wd/res/genome/star_index
STAR \
    --runThreadN 4 \
    --runMode genomeGenerate \
    --genomeDir $wd/res/genome/star_index/ \
    --genomeFastaFiles $wd/res/genome/ecoli.fasta \
    --genomeSAindexNbases 9
echo

for sid in $(ls $wd/data/*.fastq.gz | xargs basename -a | cut -d_ -f1 | sort -u)
do
	bash $wd/scripts/analyse_sample.sh $sid 
	echo "Done"
	echo
done

echo "Running MultiQC..."
mkdir -p $wd/out/multiqc
multiqc -o $wd/out/multiqc $wd
echo

echo "-------- Pipeline finished at $(date +'%d %h %y, %r')... --------"
