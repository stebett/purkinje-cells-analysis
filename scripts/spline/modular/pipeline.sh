#!bin/bash

# Parameters
n="artificial"
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
julia  $pipeline/preprocess.jl $batchpath $reference $group
Rscript $pipeline/preprocess.R $respath

# Clean dir
ssh $server "rm -r $clusterpath/$reference-$group"

# Upload
scp -r $respath "bettani@jord.biologie.ens.fr:$clusterpath/$reference-$group"

# Give permissions
ssh $server "cd $clusterpath/$reference-$group
mv analysis.sh ~
chmod a+x ~/analysis.sh
mv ~/analysis.sh .
"

# Submit (need to cd otherwise initialDir doesn't work)
ssh -J $server $bioclust  "cd $clusterpath/$reference-$group && condor_submit analysis.sub"

# Wait
ssh -J $server $bioclust "condor_wait $clusterpath/$reference-$group/out/analysis.log"

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
