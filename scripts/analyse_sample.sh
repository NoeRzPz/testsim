wd=~/testsim #Define working directory

if [ "$#" -ne 1 ]
then
    echo "Usage: $0 <sampleid>"
    exit 1
fi

sampleid=$1

echo "Analysing sample ${sampleid}..."
echo "Running FastQC..."
mkdir -p $wd/out/fastqc
fastqc -o $wd/out/fastqc $wd/data/${sampleid}_?.fastq.gz
echo

echo "Running cutadapt..."
mkdir -p $wd/log/cutadapt
mkdir -p $wd/out/cutadapt
cutadapt \
    -m 20 \
    -a AGATCGGAAGAGCACACGTCTGAACTCCAGTCA \
    -A AGATCGGAAGAGCGTCGTGTAGGGAAAGAGTGT \
    -o $wd/out/cutadapt/${sampleid}_1.trimmed.fastq.gz \
    -p $wd/out/cutadapt/${sampleid}_2.trimmed.fastq.gz $wd/data/${sampleid}_1.fastq.gz $wd/data/${sampleid}_2.fastq.gz \
    > $wd/log/cutadapt/${sampleid}.log
echo

echo "Running STAR alignment..."
mkdir -p $wd/out/star/${sampleid}
STAR \
    --runThreadN 4 \
    --genomeDir $wd/res/genome/star_index/ \
    --readFilesIn $wd/out/cutadapt/${sampleid}_1.trimmed.fastq.gz $wd/out/cutadapt/${sampleid}_2.trimmed.fastq.gz \
    --readFilesCommand zcat \
    --outFileNamePrefix $wd/out/star/${sampleid}/
echo
