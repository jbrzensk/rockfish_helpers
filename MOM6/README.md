# MOM6 Readme - Help

Included in this folder are some utilities to help with running MOM6-COBALT.

## decomposition_finder.sh

Finds decomposition and gives ratiosn of ahlo size as well as x/y ratio.
The best decomposition will have a the highest halo value, and the x/y ratio closest to 1.

These must all be run through using check_mask. Run from the `INPUT` directory.

Example to generate and see how many processors a 13x10 layout will use:

```bash
check_mask --grid_file ../ocean_mosaic.nc --ocean_topog ../topog.nc --layout 13,10
```

### decomp_finder.sh

Same as above, but only finds values that have the same size domain for all processors. IE: every core will have exaclty the same size domain, whereas the above code may have cores with one more or less cell in a direction (non-uniform).

## mpi_commands.txt

A series of MPI commands for multiple users running on one server, which does not have a batch scheduler (slurm, pbs).

There is a command to generate a generic rankfiles to split monkfish into two (list of processors).

```bash
for ((r=0; r<114; r++)); do     printf 'rank %d=%s slot=0:0-127\n' "$r" "$node"; done > socket0.rankfile

for ((r=0; r<114; r++)); do     printf 'rank %d=%s slot=1:0-127\n' "$r" "$node"; done > socket1.rankfile
```

The list can be viewed with cat:
```
...
rank 0=monkfish slot=1:0-127
rank 1=monkfish slot=1:0-127
rank 2=monkfish slot=1:0-127
rank 3=monkfish slot=1:0-127
rank 4=monkfish slot=1:0-127
rank 5=monkfish slot=1:0-127
rank 6=monkfish slot=1:0-127
rank 7=monkfish slot=1:0-127
rank 8=monkfish slot=1:0-127
rank 9=monkfish slot=1:0-127
...
```

and this can be used with the `mpiexec` command to prevent double occupancy.

```bash
mpiexec -np 114 --rankfile socket0.rankfile --report-bindings ./MOM6SIS2_FEISTY 
```

## core_viewer.sh

A bash script for viewing the core/processor occupancy, to see how jobs have been distributed.

## run_MOM6.sh

A bash script to send different values for `FMORT`, `Encounter`, `K`, and `K50` and run MOM6 in parallel.

This is meant for the **1D Column** model of MOM6. Mostly kept here for reference purposes. See The FEISTY or EXPERIMENTS repos for more detailed run instructions.

