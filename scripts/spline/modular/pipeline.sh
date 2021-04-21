#!/bin/bash

n="artificial"
reference="best"
group="all"

function usage()
{
	echo "Fit a smoothing spline on your data"
	echo ""
	echo "OPTIONS"
	echo -e "\t-h --help"
	echo ""
	echo -e "\t-n=$n"
	echo -e "\t\tBatch name"
	echo ""
	echo -e "\t-r --reference=$reference"
	echo -e "\t\tSet reference: either best or multi"
	echo ""
	echo -e "\t-g --group=$group"
	echo -e "\t\tSet group: neigh, all or dist"
	echo ""
}


while [ "$1" != "" ]; do
	PARAM=`echo $1 | awk -F= '{print $1}'`
	VALUE=`echo $1 | awk -F= '{print $2}'`
	case $PARAM in
		-h | --help)
			usage
			exit
			;;
		-n)
			n=$VALUE
			;;
		-r | --reference)
			reference=$VALUE
			;;
		-g | --group)
			group=$VALUE
			;;
		*)
			echo "ERROR: unknown parameter \"$PARAM\""
			usage
			exit 1
			;;
	esac
	shift
done

echo ""
echo -e "Starting analysis for:"
echo -e "\tbatch-$n"
echo -e "\t$reference"
echo -e "\t$group"
echo ""


# Standard variables
batchpath="/home/ginko/ens/data/analyses/spline/batch-$n"
clusterpath="/kingdoms/nbc/workspace14/CETO05/bettani/spline"
respath="$batchpath/$reference-$group"
pipeline="/home/ginko/ens/scripts/spline/modular"

server="bettani@jord.biologie.ens.fr"
bioclust="bettani@bioclusts01.bioclust.biologie.ens.fr"

# Make batch dir with toml if new batch
mkdir -p $batchpath
cp -n $pipeline/params/params.toml $batchpath/params.toml
cp -n $pipeline/params/indexes.toml $batchpath/indexes.toml

# Create input dirs and files
mkdir -p "$respath/in/csv"
mkdir -p "$respath/in/unif"
mkdir -p "$respath/in/conf"
mkdir -p "$respath/out/data"
mkdir -p "$respath/post-proc"
mkdir -p "$respath/results"
mkdir -p "$respath/plots"
cp $pipeline/analysis* $respath

# Tag params
echo "$reference-$group = '$(git rev-parse HEAD)'" >> $batchpath/params.toml
# Preprocessing
echo -e "\n[*] Preprocessing step 1 (Julia)"
julia  $pipeline/preprocess.jl $batchpath $reference $group
echo -e "\n[*] Preprocessing step 2 (R)"
Rscript $pipeline/preprocess.R $respath

# Clean dir
echo -e "\n[*] Cleaning remote dir"
ssh $server "rm -r $clusterpath/$reference-$group"

# Upload
echo -e "\n[*] Uploading preprocessed data on server"
scp -r $respath "bettani@jord.biologie.ens.fr:$clusterpath/$reference-$group"

# Give permissions
ssh $server "cd $clusterpath/$reference-$group
mv analysis.sh ~
chmod a+x ~/analysis.sh
mv ~/analysis.sh .
"

# Submit (need to cd otherwise initialDir doesn't work)
echo -e "\n[*] Submitting jobs"
ssh -J $server $bioclust  "cd $clusterpath/$reference-$group && condor_submit analysis.sub"

# Wait
echo -e "\n[*] Waiting for jobs to end"
ssh -J $server $bioclust "condor_wait $clusterpath/$reference-$group/out/analysis.log"

# Download                                                                        
echo -e "\n[*] Downloading results"
scp -r "$server:$clusterpath/$reference-$group/out/data/" "$respath/out"

# Post-processing
echo -e "\n[*] Post-processing step 1 (R)"
Rscript $pipeline/postprocess.R $respath
echo -e "\n[*] Post-processing step 2 (Julia)"
julia $pipeline/postprocess.jl $respath

# Simulate
echo -e "\n[*] Simulating step 1 (R)"
Rscript $pipeline/simulate.R $respath
echo -e "\n[*] Simulating step 2 (Julia)"
julia $pipeline/simulate.jl $respath

# Plot
echo -e "\n[*] Plotting results"
julia $pipeline/plot.jl $respath
