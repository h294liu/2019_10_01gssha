#!/bin/bash
set -e

# H. liu, April 30, 2020.
# Calculate |x-q05| for MAD spread metric
# Part 2: correct bias

#==========================input (need update)=========================== 
# configure ensemble results folders
EnsDir=ENSDIR
EnsSumDir=ENSSUMDIR
 
startEns=STARTENS   # start number of ensembles to generate
stopEns=STOPENS  # stop number of ensembles to generate

Year=YEAR

#==========================calculate abs(x-median)===========================

echo $Year
EnsMedianFile=$EnsSumDir/ens_forc.$Year.enspctl.50.nc

# bias correct all ensmeble members
echo calculate abs x-median
for M in $(seq ${startEns} ${stopEns}); do
    
    NUM=$(echo $M | awk '{printf("%03d",$1)}')
    echo ens member $NUM
    
    # clear existing output file
    InFile=$EnsDir/ens_forc.$Year.$NUM.nc 
    OutputFile=$EnsSumDir/abs_x_median.$Year.$NUM.nc 
    rm -f $OutputFile
    
    # calculate x-median
    ncflint -h -O --fix_rec_crd -v pcp,t_mean,t_min,t_max,t_range -w 1,-1 $InFile $EnsMedianFile $OutputFile

    # calculate absolute x-median
    ncap2 -h -A -s 'pcp=abs(pcp);t_mean=abs(t_mean);t_min=abs(t_min);t_max=abs(t_max);t_range=abs(t_range);' $OutputFile
    
done

