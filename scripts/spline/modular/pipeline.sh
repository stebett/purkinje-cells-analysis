#!bin/bash

# Parameters
n="test"
reference="best"
group="neigh"

# Standard variables
batchpath="/home/ginko/ens/data/analyses/spline/batch-$n"
clusterpath="/kingdoms/nbc/workspace14/CETO05/bettani/spline"
respath="$batchpath/$reference-$group"
pipeline="/home/ginko/ens/scripts/spline/modular"

server="bettani@jord.biologie.ens.fr"
bioclust="bettani@bioclusts01.bioclust.biologie.ens.fr"

# Make batch dir with toml if new batch
mkdir -p $newbatch
cp $pipeline/params/params.toml $newbatch/params.toml
cp $pipeline/params/indexes.toml $newbatch/indexes.toml


# Create input dirs and files
mkdir -p "$respath/in/csv"
mkdir -p "$respath/in/unif"
mkdir -p "$respath/in/conf"
mkdir -p "$respath/out/data"
mkdir -p "$respath/post-proc"
mkdir -p "$respath/results"
mkdir -p "$respath/plots"
cp $pipeline/analysis* $respath
chmod a+x $respath/analysis.sh


# Preprocessing
julia  $pipeline/preprocess.jl $batchpath $reference $group
Rscript $pipeline/preprocess.R $respath

# Upload
ssh $server "rm -rI $clusterpath/$reference-$group"
scp -r $respath "bettani@jord.biologie.ens.fr:$clusterpath/$reference-$group"

# Give permissions
ssh $server "cd $clusterpath/$reference-$group
			 mv analysis.sh ~
			 chmod a+x ~/analysis.sh
			 mv ~/analysis.sh .
			 "

# Submit
ssh -J $server $bioclust  "cd $clusterpath/$reference-$group
						   condor_submit analysis.sub
						   "

# Check
ssh -J $server $bioclust "condor_q"


# Download                                                                        
scp -r "$server:$clusterpath/$reference-$group/out/data/" "$respath/out"

# Post-processing
Rscript $pipeline/postprocess.R $respath
julia $pipeline/postprocess.jl $respath

# Simulate
Rscript $pipeline/simulate.R $respath
julia $pipeline/simulate.jl $respath

# Plot
julia $pipeline/plot.jl $respath
