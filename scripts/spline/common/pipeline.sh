#!bin/bash

# TODO add options for only analyse some combinations of params eg. neigh multi
# TODO maybe next time just compute the significant indexes?

n=6
inpath="/home/ginko/ens/data/analyses/spline/cluster-inputs-$n/"
respath="/home/ginko/ens/data/analyses/spline/batch-$n/"

mkdir "$inpath"
mkdir "$inpath/r.config"
mkdir "$inpath/csv"
mkdir "$inpath/uniformized"
mkdir "$inpath/in"
mkdir "$inpath/out"

chmod a+x $inpath/analysis.sh
cp "/home/ginko/ens/scripts/spline/common/analysis*" $inpath

julia  "/home/ginko/ens/scripts/spline/common/preprocess.jl" $inpath
Rscript "/home/ginko/ens/scripts/spline/common/preprocess.R" $inpath



# ssh bettani@jord "cd /kingdoms/nbc/workspace14/CETO05/ && rm -r bettani"
scp -r $inpath bettani@jord:/kingdoms/nbc/workspace14/CETO05/bettani 

ssh -J bettani@jord.biologie.ens.fr bettani@bioclusts01.bioclust.biologie.ens.fr


scp -r bettani@jord:/kingdoms/nbc/workspace14/CETO05/bettani $respath

mkdir $respath/results

julia /home/ginko/ens/scripts/spline/common/postprocess.jl $respath
Rscript /home/ginko/ens/scripts/spline/common/postprocess.R $respath

rm -r $inpath
