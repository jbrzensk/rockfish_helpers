# rockfish_helpers

Scripts and environments for the rockfish server at SIO

This is separated into multiple folders:

## [MOM6](/MOM6): MOM6 Interactive runtime environment

## [R](/R) : R and R studio specific helpers
- [R_server.sh](/R/R_server.sh): Launches a containerized R which contains most of ESMF scripts and is parallelized.

## [bash](/bash): bash scripts for commonly repeated tasks. 

## [fortran](/fortran): Fortran sample code

- [hello_world](/fortran/examples/hello_world.f90): A hello world example written in Fortran.

- [hello_world_mpi](/fortran/examples/hello_world_mpi.f90): A hello world example written in MPI and Fortran.

## [modules](/modules/rockfish_modules.md): Module usage explanation
- An explanation of the module system. Mostly pertains to monkfish, but rockfish uses the same system.
  
## [netcdf](/netcdf): netCDF Helper Scripts

- [netcdf_splitter](/netcdf/netcdf_splitter): Splits netCDF files into slices, with a common name stem. Computations are generally faster on smaller netCDF files. Files cna be combined at the end with [net_cdf_combiner](/netcdf/netcdf_combiner).

- [netcdf_combiner](/netcdf/netcdf_combiner): Combines what splitter takes apart.

- [VolMP](/netcdf/VolMP): Scripts for integrating and averaging some specific plankton and fish values from VolMP data sets. See here for how to do weighted averaging and integrating.

## [python](/python): Python helpers for rockfish    

- [environment_builder](/python/environment_builder.sh): This function builds an environment for MOM analysis. The code can be reused to build other environments for other projects. It also included a *[mom_requirements.txt](/python/mom_requirements.txt)* file, which has everything pip needs to create an environment for running the diagnostics in the MOM6 diagnostics folder.
  
- [jupyter_notebook_helper](/python/jupyter_notebook_helper.sh): This is a script for starting a Jupyter notebook instance. It also gives the command to SSH tunnel into Rockfish to your Jupyter instance.

## [ssh](/ssh): How to setup SSH keys for password-less login
