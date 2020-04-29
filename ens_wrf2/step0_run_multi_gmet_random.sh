#!/bin/bash
set -e

# root_dir=/glade/u/home/hongli/work/russian/ens_forc
root_dir=/home/hongli/work/russian/ens_forc_wrf
source_dir=${root_dir}/scripts_uniform
tpl_dir=${root_dir}/GMET_tpl
work_base=${root_dir}/test_random
if [ ! -d ${work_base} ]; then mkdir -p ${work_base}; fi

stnlist_dir=${source_dir}/step4_sample_stnlist_random
stndata_dir=${source_dir}/step5_prepare_stndata_random

# get all the stnlist files
FILES=$stnlist_dir/stnlist_*.txt

command_folder=$source_dir/step0_run_multi_gmet_random_command
if [ -d $command_folder ]; then rm -r $command_folder; fi; mkdir -p $command_folder

# create work folder for each stnlist file (e.g. stnlist_slope.NCA125_012grids.txt)
for file in $FILES; do  
    
    file_name=${file##*/} # remove file path, keep only file name
    file_name_short="${file_name/.txt/}" # remove suffix ".txt"
    grid_num=$(echo $file_name_short| cut -d'_' -f 2) # extract substring "012grids"
    work_dir=${work_base}/${grid_num}
    echo ${grid_num}

    # create work folder
    src=${tpl_dir}
    dst=${work_dir}
    if [ -d ${dst} ]; then rm -r ${dst}; fi
    cp -r ${src} ${dst}
    
    # replace stnlist_slope.NCA125.txt
    src=${file}
    dst=${work_dir}/inputs/stnlist_slope.txt
    if [ -f ${dst} ]; then rm ${dst}; fi
    ln -s ${src} ${dst}
    
    # replace stndata
    src=${stndata_dir}/stndata_${grid_num}
    dst=${work_dir}/stndata
    if [ -d ${dst} ]; then rm -r ${dst}; fi
    ln -s ${src} ${dst}
    
#     # method 1: run GMET
#     cd ${work_dir}/run/
#     ./run_gmet.sh
#     cd $root_dir
    
    # method 2: submit job
    # create job submission file
    cd ${command_folder}
    command_file=sbatch_${grid_num}.sh
    if [ -e ${command_file} ]; then rm -rf ${command_file}; fi
    
    echo '#!/bin/bash' > ${command_file}
    echo "#SBATCH --job-name=${grid_num}" >> ${command_file}
    echo '#SBATCH --partition=main' >> ${command_file}
    echo '#SBATCH --ntasks=1' >> ${command_file}
    echo '#SBATCH --time=00:30:00' >> ${command_file}
    echo '#SBATCH --output=./out.%j' >> ${command_file}
    echo '#SBATCH --error=./err.%j' >> ${command_file} 

    echo "cd ${work_dir}/run/" >> ${command_file}
    echo "./run_gmet.sh" >> ${command_file}
    echo "cd $root_dir" >> ${command_file}
    chmod 740 ${command_file}	
    
    #submit job	
    sbatch ${command_file}
    cd ${root_dir}
done

