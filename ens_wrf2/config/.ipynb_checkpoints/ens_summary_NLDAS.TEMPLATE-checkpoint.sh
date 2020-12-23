#!/bin/bash
set -e

# H. liu, April 30, 2020.
# Bias correct NLDAS-based GMET ensemble in comparison with NLDAS data.

#==========================input (need update)=========================== 
EnsDirBase=ENSDIRBASE # ens results' parent directory
EnsFolder=ENSFOLDER
Year=YEAR
Metric=METRIC
Pth=PTH

#==========================bias correction (no need to update)===========================
module load cdo

echo $Year
EnsDir=$EnsDirBase/$EnsFolder
EnsFile=$EnsDir/conus_daily_eighth_${Year}0101_${Year}1231_*.nc4

EnsSumDir=$EnsDirBase/${EnsFolder}_summary
if [ ! -d $EnsSumDir ]; then mkdir $EnsSumDir; fi

if [ $Metric = ensmean ] || [ $Metric = ensstd ]; then
    echo $Metric   
    OutputFile=$EnsSumDir/ens_forc.$Year.$Metric.nc
    rm -f $OutputFile
    cdo $Metric $EnsFile $OutputFile
    ncatted -h -O -a history,global,d,, $OutputFile # remove history to save nc length

elif [ $Metric = enspctl ]; then
    echo $Metric.$Pth        
    OutputFile=$EnsSumDir/ens_forc.$Year.$Metric.$Pth.nc
    rm -f $OutputFile
    cdo $Metric,$Pth $EnsFile $OutputFile
    ncatted -O -a history,global,d,, $OutputFile
fi
