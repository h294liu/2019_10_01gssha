#!/bin/bash

WorkDir=WORKDIR
Y=YR
gridFile=GRIDFILE

echo $Y        
OutputFile=${WorkDir}/gmet_regr/regress_ts.$Y.nc
tmpFile=${OutputFile}_bk
if [ -e ${tmpFile} ]; then rm -rf ${tmpFile}; fi

# pre-process regression output 
ncatted -O -h -a history_of_appended_files,global,d,, $OutputFile # remove history_of_appended_files
ncatted -O -h -a history,global,d,, $OutputFile # remove history
ncks -h -x -v mask,pcp_new,pcp_update,pcp_error_update $OutputFile $tmpFile # copy netcdf except the mask variable if exists
        
# add de-standardized y and y_error from pcp and pcp_error
echo update pcp and pcp_error
ncap2 -A -h -s 'pcp_update=pcp*ystd+ymean' $tmpFile
ncap2 -A -h -s 'pcp_2_update=pcp_2*ystd+ymean' $tmpFile
ncap2 -A -h -s 'pcp_error_update=pcp_error*ystd' $tmpFile
ncap2 -A -h -s 'pcp_error_2_update=pcp_error_2*ystd' $tmpFile

# replace fillValue zero with -999
# reference: http://dvalts.io/2018/06/22/Masking-netcdf-variable.html
echo update fillValue
ncks -A -h -v data_mask $gridFile $tmpFile
for var in pcp pop pcp_error tmean tmean_error trange trange_error \
pcp_2 pop_2 pcp_error_2 tmean_2 tmean_error_2 trange_2 trange_error_2 \
ymean ystd ymin ymax ystd_all pcp_update pcp_error_update pcp_2_update pcp_error_2_update; do
    echo $var
    ncatted -h -a _FillValue,$var,o,d,1e+20 $tmpFile
    ncap2 -A -h -s "where(data_mask == 0) ${var}=${var}@_FillValue" $tmpFile $tmpFile
done

mv $tmpFile $OutputFile