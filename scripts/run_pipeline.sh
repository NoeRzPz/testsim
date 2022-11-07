echo "-------- Starting pipeline at $(date +'%d %h %y, %r')... --------"

#Variables definition
wd=~/testsim
genome_url=ftp://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/000/005/845/GCF_000005845.2_ASM584v2/GCF_000005845.2_ASM584v2_genomic.fna.gz
genome_fname=$wd/res/genome/ecoli.fasta.gz
md5_url=ftp://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/000/005/845/GCF_000005845.2_ASM584v2/md5checksums.txt

echo "Downloading genome..."
mkdir -p $wd/res/genome
wget -c -O $genome_fname $genome_url
if [ "$?" -ne 0 ] # Checks if previous exit code is not equal to 0
then
    echo "Error in downloading file. Usage: bash $0"
    exit 1 # Error signal, forces the script to exit with an error when downloading was not succesfull
fi

#Computing md5sum
md5sum -c <(echo $(curl $md5_url | grep v2.genomic.fna | cut -d" " -f1) $genome_fname)
if [ "$?" -ne 0 ]
then
	echo "md5sum checked for downloaded file failed. Aborting."
	exit 1
fi
echo 

echo "Uncompressing genome..."
if [[ -e $(echo $genome_fname | cut -d"." -f1-2) ]] #It avoids having to overwrite file when rerunning pipeline
then
	echo "You have already unziped your reference genome"
else
	gunzip $wd/res/genome/ecoli.fasta.gz
fi	
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

echo "Starting sample analysis..."
echo
for sid in $(ls $wd/data/*.fastq.gz | xargs basename -a | cut -d "_" -f1 | sort -u)
do
	echo "Analysing sample $sid..."
	bash $wd/scripts/analyse_sample.sh $sid 
	echo "Done"
	echo
done

echo "Running MultiQC..."
mkdir -p $wd/out/multiqc
multiqc -o $wd/out/multiqc $wd
echo

echo "-------- Pipeline finished at $(date +'%d %h %y, %r')... --------"
