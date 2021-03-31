#!bin/bash

# TODO add options for only analyse some combinations of params eg. neigh multi
# TODO maybe next time just compute the significant indexes?

n=7
inpath="/home/ginko/ens/data/analyses/spline/cluster-inputs-$n/"
respath="/home/ginko/ens/data/analyses/spline/batch-$n/"
diffpath="/home/ginko/ens/data/analyses/spline/batch-$n-diff/"

# Create input dirs
mkdir -p "$inpath/csv"
mkdir -p "$inpath/in/uniformized"
mkdir -p "$inpath/in/r.config"
mkdir -p "$inpath/out/data"
mkdir -p "$inpath/results"

cp /home/ginko/ens/scripts/spline/common/analysis* $inpath
chmod a+x $inpath/analysis.sh


# Preprocessing
julia  "/home/ginko/ens/scripts/spline/common/preprocess.jl" $inpath
Rscript "/home/ginko/ens/scripts/spline/common/preprocess.R" $inpath

# Upload
rm -r "$inpath/csv"

ssh bettani@jord "cd /kingdoms/nbc/workspace14/CETO05/ && rm -r bettani"
scp -r $inpath bettani@jord:/kingdoms/nbc/workspace14/CETO05/bettani 

# Connect to the cluster
ssh -J bettani@jord.biologie.ens.fr bettani@bioclusts01.bioclust.biologie.ens.fr

# Download
scp -r bettani@jord:/kingdoms/nbc/workspace14/CETO05/bettani $respath

# Post-processing
Rscript /home/ginko/ens/scripts/spline/common/postprocess.R $respath
julia /home/ginko/ens/scripts/spline/common/postprocess.jl $respath

rm -r $inpath

# 2-step process
scp -r bettani@jord:/kingdoms/nbc/workspace14/CETO05/bettani $diffpath

rm $(diff -rs $diffpath/out/data $respath/out/data | egrep '^Files .+ and .+ are identical$' | awk -F '(Files | and | are identical)' '{print $2}') 


Rscript /home/ginko/ens/scripts/spline/common/postprocess.R $diffpath
julia /home/ginko/ens/scripts/spline/common/postprocess.jl $diffpath

julia /home/ginko/ens/scripts/spline/common/postprocess-diff.jl $respath $diffpath
rm -r $diffpath
