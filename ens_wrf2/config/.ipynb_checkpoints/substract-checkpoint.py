#!/usr/bin/env python
# coding: utf-8

import xarray as xr
import netCDF4 as nc
import numpy as np
import sys,os

# --- check args
if len(sys.argv) != 4:
    print("Usage: %s <inFile1> <inFile2> <outFile>" % sys.argv[0])
    sys.exit(0)
# otherwise continue
inFile1 = sys.argv[1] 
inFile2 = sys.argv[2] 
outFile = sys.argv[3] 

# delta = inFile1 - inFile2. Format is the same as inFile1.

# inFile1='/glade/u/home/hongli/scratch/2020_04_21nldas_gmet/test_uniform_perturb/00810grids/tmp/ens_forc.2015.mean.nc'
# inFile2='../../../data/nldas_daily_utc_convert/NLDAS_2015.nc'
# outFile = '/glade/u/home/hongli/scratch/2020_04_21nldas_gmet/test_uniform_perturb/00810grids/tmp/test.nc'

if os.path.exists(outFile):
    os.remove(outFile)

f1 = xr.open_dataset(inFile1)
f1_pcp = f1['pcp'].values[:] # (time, y, x). unit: mm/day
f1_tmean = f1['t_mean'].values[:]
f1_trange = f1['t_range'].values[:]

f2 = xr.open_dataset(inFile2)
f2_pcp = f2['pcp'].values[:] 
f2_tmean = f2['t_mean'].values[:]
f2_trange = f2['t_range'].values[:]

pcp_delta = f2_pcp-f1_pcp
tmean_delta = f2_tmean-f1_tmean
trange_delta = f2_trange-f1_trange

# save
with nc.Dataset(inFile1) as src:
    with nc.Dataset(outFile, "w") as dst:
        
        # copy dimensions
        for name, dimension in src.dimensions.items():
             dst.createDimension(name, (len(dimension) if not dimension.isunlimited() else None))

        # copy variable attributes all at once via dictionary (for the included variables)
        includes = ['time', 'pcp', 't_mean', 't_range']
        for name, variable in src.variables.items():
            if name in includes:
                x = dst.createVariable(name, variable.datatype, variable.dimensions)   
                dst[name].setncatts(src[name].__dict__)
            if name == 'time':                
                dst[name][:]=src[name][:] 

        # assign values for variables ([:] is necessary)
        dst.variables['pcp'][:] = pcp_delta
        dst.variables['t_mean'][:] = tmean_delta  
        dst.variables['t_range'][:] = trange_delta 
