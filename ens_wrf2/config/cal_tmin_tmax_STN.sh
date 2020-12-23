#!/bin/bash
set -e

# H. liu, June 5, 2020.
# Calculate tmin and tmax for NLDAS-based GMET ensemble.

#==========================setup=========================== 
EnsDir=ENSDIR
OutputDir=OUTPUTDIR

Y=YEAR
startEns=STARTENS   # start number of ensembles to generate
stopEns=STOPENS  # stop number of ensembles to generate

#==========================end setup===========================
ens_namebase=conus_daily_eighth

for mmb in $(seq $startEns $stopEns); do
    
    printf -v mmb "%03d" $mmb
    inFile=$EnsDir/${ens_namebase}_${Y}0101_${Y}1231_${mmb}.nc4
    outFile=$OutputDir/${ens_namebase}_${Y}0101_${Y}1231_${mmb}.nc4
    echo ${ens_namebase}_${Y}0101_${Y}1231_${mmb}.nc4
    
    ncap2 -A -h -s 't_min=t_mean-0.5*t_range;t_max=t_mean+0.5*t_range' $inFile $outFile
    
    ncatted -h -a long_name,t_min,o,c,"estimated daily min temperature" $outFile
    ncatted -h -a long_name,t_max,o,c,"estimated daily max temperature" $outFile
    
done


