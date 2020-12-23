#!/bin/bash
set -e

# H. liu, June 5, 2020.
# Calculate tmin and tmax for NLDAS-based GMET ensemble.

#==========================setup=========================== 
EnsDir=ENSDIR

Y=YEAR
startEns=STARTENS   # start number of ensembles to generate
stopEns=STOPENS  # stop number of ensembles to generate

#==========================end setup===========================
ens_namebase=ens_forc

for mmb in $(seq $startEns $stopEns); do
    
    printf -v mmb "%03d" $mmb
    inFile=$EnsDir/$ens_namebase.$Y.$mmb.nc
    echo $ens_namebase.$Y.$mmb.nc
        
    ncap2 -A -h -s 't_min=t_mean-0.5*t_range;t_max=t_mean+0.5*t_range;' $inFile
    
    ncatted -h -a long_name,t_min,o,c,"estimated daily min temperature" $inFile
    ncatted -h -a long_name,t_max,o,c,"estimated daily max temperature" $inFile
    
    ncatted -h -a _FillValue,t_min,o,d,1e+20 $inFile
    ncatted -h -a _FillValue,t_max,o,d,1e+20 $inFile

done


