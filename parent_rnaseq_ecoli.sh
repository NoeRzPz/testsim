WD=~/testsim
for sid in $(ls $WD/data/*.fastq.gz | xargs basename -a | cut -d_ -f1 | sort -u)
do
	 echo bash $WD/scripts/rna_pipeline.sh $sid 
done

