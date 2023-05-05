# Useful code
This is a collection of useful pieces of code I am generating during my PhD at BSC

## 1. SLURM wrapper

`scripts/slurm-wrapper-BSC.sh`

This is a wrapper for job submissin in the SLURM job scheduling system for HPC which considers 3 types of jobs: `standard`, `array` and `greasy` (BSC internal schedueling tool); and 3 memory constraints: `none`, `medmem`, `highmem`. 

Usage options are displayed with `./slurm-wrapper-BSC.sh -h ` : 

```
Usage: Slurm-wrapper-Ruben-unstable {-j|--job}
                                    {-o|--output_dir}
                                    {-r|--ref_dir}
                                    {-N|--nodes}
                                    {-n|--ntasks}
                                    {-u|--cpus-per-task}
                                    {-tn|--tasks-per-node}
                                    {-q|--qos}
                                    {-t|--time}
                                    {-mem|--mem_constraint}
                                    {-a|--array}
                                    {-af|--array_file}
                                    {-g|--greasy}
                                    {-gf|--greasy_file}
                                    {-c|--command}
                                    {-arg1|--argument_1}
                                    {-arg2|--argument_2}
                                    {-arg3|--argument_3}
                                    {-arg4|--argument_4}
                                    {-arg5|--argument_5}
```
