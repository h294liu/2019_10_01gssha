#!/bin/bash
set -e

# H. liu, April 30, 2020.
# Bias correct NLDAS-based GMET ensemble in comparison with NLDAS data.

#==========================input (need update)=========================== 
EnsSumDir=ENSSUMDIR
Year=YEAR
Metric=METRIC
Pth=PTH

#==========================bias correction (no need to update)===========================
module load cdo

echo $Metric.$Pth        

EnsFile=$EnsSumDir/abs_x_median.$Year.*.nc
OutputFile=$EnsSumDir/ens_forc.$Year.MAD.nc
rm -f $OutputFile
cdo $Metric,$Pth $EnsFile $OutputFile

ncatted -O -a history,global,d,, $OutputFile # remove history
ncatted -h -a _FillValue,,o,d,1e+20 $OutputFile # modify missing value to the same as gmet data

