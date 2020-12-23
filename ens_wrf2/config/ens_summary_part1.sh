#!/bin/bash
set -e

# H. liu, April 30, 2020.
# ensemble summary statistics, such as mean, std, median, and percentiles.

#==========================input (need update)=========================== 
EnsDirBase=ENSDIRBASE # ens results' parent directory
CaseID=CASEID
EnsFolder=ENSFOLDER
Year=YEAR
Metric=METRIC
Pth=PTH

#==========================bias correction (no need to update)===========================
module load cdo

echo $CaseID,$Year
EnsDir=$EnsDirBase/$CaseID/$EnsFolder
EnsFile=$EnsDir/ens_forc.$Year.*.nc
EnsSumDir=$EnsDirBase/$CaseID/${EnsFolder}_summary

if [ $Metric = ensmean ] || [ $Metric = ensstd ]; then
    echo $Metric   
    OutputFile=$EnsSumDir/ens_forc.$Year.$Metric.nc
    rm -f $OutputFile
    cdo $Metric $EnsFile $OutputFile

    ncatted -h -O -a history,global,d,, $OutputFile # remove history
#     ncatted -h -a _FillValue,,o,d,1e+20 $OutputFile # modify missing value to the same as gmet data

elif [ $Metric = enspctl ]; then
    echo $Metric.$Pth        
    OutputFile=$EnsSumDir/ens_forc.$Year.$Metric.$Pth.nc
    rm -f $OutputFile
    cdo $Metric,$Pth $EnsFile $OutputFile

    ncatted -h -O -a history,global,d,, $OutputFile # remove history
#     ncatted -h -a _FillValue,,o,d,1e+20 $OutputFile # modify missing value to the same as gmet data
fi
