#!bin/bash

n=8
reference="best"
group="all"

clusterpath="/kingdoms/nbc/workspace14/CETO05/bettani/spline"
respath="/home/ginko/ens/data/analyses/spline/batch-$n/$reference-$group"

# Create input dirs and files
mkdir -p "$respath/in/csv"
mkdir -p "$respath/in/unif"
mkdir -p "$respath/in/conf"
mkdir -p "$respath/out/data"
mkdir -p "$respath/post-proc"
mkdir -p "$respath/results"
cp /home/ginko/ens/scripts/spline/modular/analysis* $respath
chmod a+x $respath/analysis.sh


# Preprocessing
julia  "/home/ginko/ens/scripts/spline/modular/preprocess.jl" $respath $reference $group
Rscript "/home/ginko/ens/scripts/spline/modular/preprocess.R" $respath

# Upload
ssh bettani@jord "cd $clusterpath && rm -r $reference-$group"
scp -r $respath "bettani@jord:$clusterpath/$reference-$group"

# Connect to the cluster
ssh -J bettani@jord.biologie.ens.fr bettani@bioclusts01.bioclust.biologie.ens.fr

# Download
scp -r bettani@jord:"$clusterpath/$reference-$group/out/" "$respath/out"

# Post-processing
Rscript /home/ginko/ens/scripts/spline/modular/postprocess.R $respath
julia /home/ginko/ens/scripts/spline/modular/postprocess.jl $respath

