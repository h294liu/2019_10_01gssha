#!/bin/bash
set -e

# H. liu, April 30, 2020.
# Bias correct NLDAS-based GMET ensemble in comparison with NLDAS data.
# Part 1: calculate ensemble mean and bias

#==========================input (need update)=========================== 
# configure ensemble results folders
EnsDir=ENSDIR
EnsBcDir=ENSBCDIR
TmpDir=TMPDIR
 
startEns=STARTENS   # start number of ensembles to generate
numEns=100

NldasFile=NLDASFILE
Year=YEAR

#==========================bias correction (no need to update)===========================

echo $Year

EnsMeanFile=$TmpDir/ens_forc.$Year.mean.nc
EnsBiasFile=$TmpDir/ens_forc.$Year.bias.nc
# rm -f $EnsBiasFile
rm -f $EnsMeanFile $EnsBiasFile

# calculate ensemble mean over members (time,y,x)
echo calculate ensmeble mean
startEns_NUM=$(echo $startEns | awk '{printf("%03d",$1)}')
EnsFile=$EnsDir/ens_forc.$Year.$startEns_NUM.nc
ncea -h -n $numEns,3,1 -v pcp,t_mean,t_min,t_max $EnsFile $EnsMeanFile # -n file_number,digit_number,numeric_increment

# calculate delta = NLDAS - ensemble mean
echo calculate delta
ncflint -h --fix_rec_crd -v pcp,t_mean,t_min,t_max -w -1,1 $EnsMeanFile $NldasFile $EnsBiasFile # output is in file1 format 
