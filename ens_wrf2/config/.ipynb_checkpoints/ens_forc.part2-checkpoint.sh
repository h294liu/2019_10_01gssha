#!/bin/bash

WorkDir=WORKDIR
Y=YR
startEns=STARTENS
stopEns=STOPENS
gridFile=GRIDFILE

echo $Y        
for M in $(seq ${startEns} ${stopEns}); do
    
    NUM=$(echo $M | awk '{printf("%03d",$1)}')
    echo ens member $NUM

    OutputFile=${WorkDir}/gmet_ens/ens_forc.$Y.$NUM.nc
    tmpFile=${OutputFile}_bk
    if [ -e ${tmpFile} ]; then rm -rf ${tmpFile}; fi

    # pre-process regression output 
    cp $OutputFile $tmpFile

    # replace fillValue zero with 1e+20
    # reference: http://dvalts.io/2018/06/22/Masking-netcdf-variable.html
    echo update fillValue
    ncks -A -h -v data_mask $gridFile $tmpFile
    for var in pcp t_mean t_range; do
        echo $var
        ncatted -h -a _FillValue,$var,o,d,1e+20 $tmpFile
        ncap2 -A -h -s "where(data_mask == 0) ${var}=${var}@_FillValue" $tmpFile $tmpFile
    done

    mv $tmpFile $OutputFile
done