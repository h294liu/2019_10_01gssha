#!/bin/bash
set -e

# H. liu, April 30, 2020.
# Bias correct NLDAS-based GMET ensemble in comparison with NLDAS data.
# Part 2: correct bias

#==========================input (need update)=========================== 
# configure ensemble results folders
EnsDir=ENSDIR
EnsBcDir=ENSBCDIR
TmpDir=TMPDIR
 
startEns=STARTENS   # start number of ensembles to generate
stopEns=STOPENS  # stop number of ensembles to generate
numEns=100

Year=YEAR

#==========================bias correction (no need to update)===========================

echo $Year
EnsBiasFile=$TmpDir/ens_forc.$Year.bias.nc

# bias correct all ensmeble members
echo bias correct
for M in $(seq ${startEns} ${stopEns}); do
    
    NUM=$(echo $M | awk '{printf("%03d",$1)}')
    echo ens member $NUM
    
    # clear existing output file
    InFile=$EnsDir/ens_forc.$Year.$NUM.nc 
    TmpFile=$EnsBcDir/bias_corr.$Year.$NUM.nc
    OutputFile=$EnsBcDir/ens_forc.$Year.$NUM.nc 
    rm -f $OutputFile
    
    # bias correct
    ncflint -h -O --fix_rec_crd -v pcp,t_mean,t_min,t_max -w 1,1 $InFile $EnsBiasFile $TmpFile

    # force negative pcp to be zero (after bias correction)
    ncap2 -h -O -s 'where(pcp < 0) pcp=0;' $TmpFile $TmpFile
    
    # add corrected P and T to OutputFile
    cp $InFile $OutputFile
    ncks -h -A -v pcp,t_mean,t_min,t_max $TmpFile $OutputFile
    rm -f $TmpFile 
    
    # calculate t_range based on bias-correct t_min and t_max
    ncap2 -h -O -s 't_range=t_max-t_min;' $OutputFile $OutputFile
        
done

