#!/bin/bash
set -e

# H. liu, April 30, 2020.
# Bias correct NLDAS-based GMET ensemble in comparison with NLDAS data.

#==========================input (need update)=========================== 
RootDir=ROOTDIR 
EnsDirBase=ENSDIRBASE
if [ ! -d $EnsDirBase ]; then mkdir -p $EnsDirBase; fi

startEns=STARTENS   # start number of ensembles to generate
stopEns=STOPENS  # stop number of ensembles to generate
numEns=$(($stopEns - $startEns +1))

NldasFile=NLDASFILE
CaseID=CASEID
Year=YEAR
SubstractPy=SUBSTRACTPy
AdditionPy=ADDITIONPy

#==========================bias correction (no need to update)===========================

echo $CaseID,$Year

# configure ensemble results folders
EnsDir=$EnsDirBase/$CaseID/gmet_ens
EnsBcDir=$EnsDirBase/$CaseID/gmet_ens_bc
TmpDir=$EnsDirBase/$CaseID/tmp
if [ ! -d $EnsBcDir ]; then mkdir $EnsBcDir; fi
if [ ! -d $TmpDir ]; then mkdir $TmpDir; fi
 
# calculate ensemble mean over members (time,y,x)
echo calculate ensmeble mean
startEns_NUM=$(echo $startEns | awk '{printf("%03d",$1)}')
EnsFile=$EnsDir/ens_forc.$Year.$startEns_NUM.nc

EnsMeanFile=$TmpDir/ens_forc.$Year.mean.nc
rm -f $EnsMeanFile

ncea -h -n $numEns,3,1 -v pcp,t_mean,t_range $EnsFile $EnsMeanFile # -n file_number,digit_number,numeric_increment

# calculate delta = NLDAS - ensemble mean
echo calculate delta
EnsBiasFile=$TmpDir/ens_forc.$Year.bias.nc
rm -f $EnsBiasFile
# ncflint -h -w -1,1 -v pcp,t_mean $EnsMeanFile $NldasFile $EnsBiasFile # output is in file1 format 
python $SubstractPy $EnsMeanFile $NldasFile $EnsBiasFile # output is in file1 format 

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
#     ncflint -h -w 1,1 -v pcp,t_mean $InFile $EnsBiasFile $TmpFile
    python $AdditionPy $InFile $EnsBiasFile $TmpFile
    
    # add corrected P and T to OutputFile
    cp $InFile $OutputFile
    ncks -h -A -v pcp,t_mean,t_range $TmpFile $OutputFile
    rm -f $TmpFile 
    
done

