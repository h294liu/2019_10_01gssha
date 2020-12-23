#!/bin/bash
set -e

root_dir=/glade/u/home/hongli/scratch/2019_10_01gssha/ens_forc_wrf2
source_dir=${root_dir}/scripts
tpl_dir=${root_dir}/GMET_tpl
# Program1=/glade/u/home/hongli/tools/GMET-1/downscale/downscale_bc.exe
Program1=/glade/u/home/hongli/tools/GMET-1/downscale/downscale_cv.exe
Program2=/glade/u/home/hongli/tools/GMET-1/scrf/generate_ensemble_cv.exe

work_base=${root_dir}/test_uniform_cv
if [ ! -d ${work_base} ]; then mkdir -p ${work_base}; fi

command_folder=$source_dir/step6_run_multi_gmet_cv
if [ -d $command_folder ]; then rm -r $command_folder; fi; mkdir -p $command_folder

stnlist_dir=${source_dir}/step4_sample_stnlist
stndata_dir=${source_dir}/step5_prepare_stndata

# get all the stnlist files
# FILES=(011grids 017grids 026grids 046grids 099grids 393grids)
FILES=(046grids 099grids 393grids)
FILE_NUM=${#FILES[@]}

for i in $(seq 1 $(($FILE_NUM -1))); do
# for i in $(seq 0 0); do

    grid_num=${FILES[${i}]}
    work_dir=${work_base}/${grid_num}
    echo ${grid_num}

    # create work folder
    src=${tpl_dir}
    dst=${work_dir}
    if [ -d ${dst} ]; then rm -r ${dst}; fi
    cp -r ${src} ${dst}
    
    # replace stnlist_slope.NCA125.txt
    src=$stnlist_dir/stnlist_${grid_num}.txt
    dst=$work_dir/inputs/stnlist_slope.txt
    if [ -f ${dst} ]; then rm ${dst}; fi
    ln -s ${src} ${dst}
    
    # replace stndata
    src=$stndata_dir/stndata_${grid_num}
    dst=$work_dir/stndata
    if [ -d ${dst} ]; then rm -r ${dst}; fi
    ln -s ${src} ${dst}
    
#     # method 1: run GMET
#     cd ${work_dir}/run/
#     ./run_gmet.sh
#     cd $root_dir
    
    # method 2: submit job
    # create job submission file
    cd ${command_folder}
    LogFile=log_${grid_num}
    CommandFile=qsub_${grid_num}.sh
    if [ -e ${CommandFile} ]; then rm -rf ${CommandFile}; fi   
    
    echo '#!/bin/bash' > ${CommandFile}
    echo "#PBS -N ${grid_num}" >> ${CommandFile}
    echo '#PBS -A P48500028' >> ${CommandFile}
    echo '#PBS -q regular' >> ${CommandFile}
    echo '#PBS -l select=1:ncpus=1:mpiprocs=1' >> ${CommandFile}
    echo '#PBS -l walltime=00:15:00' >> ${CommandFile}
    echo "#PBS -o ${LogFile}.o" >> ${CommandFile}
    echo "#PBS -e ${LogFile}.e" >> ${CommandFile}
    
    echo "mkdir -p /glade/scratch/hongli/temp" >> ${CommandFile}
    echo "export TMPDIR=/glade/scratch/hongli/temp" >> ${CommandFile}

    echo "module load gnu" >> ${CommandFile}
    echo "module load netcdf" >> ${CommandFile}
    echo "cd ${work_dir}/run/" >> ${CommandFile}
    echo "${Program1} config.ens_regr.txt" >> ${CommandFile}
    echo "${Program2} namelist.ens_forc.txt" >> ${CommandFile}
    echo "cd $root_dir" >> ${CommandFile}
    chmod 740 ${CommandFile}
    
#     qsub ${CommandFile}
    ./${CommandFile}
    cd ${root_dir}
done

