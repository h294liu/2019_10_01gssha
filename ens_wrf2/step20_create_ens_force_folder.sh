#!/bin/bash
set -e

model_tpl_dir=/glade/u/home/hongli/scratch/2019_10_01gssha/model/270m_Forward_Jan01_2018-Apr15_2018_WestWRF_tpl
temp_dir=/glade/u/home/hongli/scratch/2019_10_01gssha/ens_forc_wrf2/scripts/step13_format_ens_to_ascii
CaseID=046grids

root_dir=/glade/u/home/hongli/scratch/2019_10_01gssha/ens_forc_wrf2/scripts
outdir=${root_dir}/step20_create_ens_force_folder
if [ ! -d ${outdir} ]; then mkdir -p ${outdir}; fi

mb=001
startEns=3
stopEns=100
#---------------------------------------------------
for M in $(seq ${startEns} ${stopEns}); do
    
    NUM=$(echo $M | awk '{printf("%03d",$1)}')
    echo mb$NUM

    mbdir=${outdir}/mb$NUM
    if [ ! -d ${mbdir} ]; then mkdir -p ${mbdir}; fi
    
    cd $mbdir

    ln -s $model_tpl_dir/input/hmet_ascii_data_1day_lead/*_Clod.asc .
    ln -s $model_tpl_dir/input/hmet_ascii_data_1day_lead/*_Drad.asc .
    ln -s $model_tpl_dir/input/hmet_ascii_data_1day_lead/*_Grad.asc .
    ln -s $model_tpl_dir/input/hmet_ascii_data_1day_lead/*_Pres.asc .
    ln -s $model_tpl_dir/input/hmet_ascii_data_1day_lead/*_RlHm.asc .
    ln -s $model_tpl_dir/input/hmet_ascii_data_1day_lead/*_WndS.asc .
    ln -s $model_tpl_dir/input/hmet_ascii_data_1day_lead/20180408*_Temp.asc .
    ln -s $model_tpl_dir/input/hmet_ascii_data_1day_lead/20180408*_Prcp.asc .

    ln -s $temp_dir/$CaseID/mb$mb/* . # ensemble precip and temperature

done
