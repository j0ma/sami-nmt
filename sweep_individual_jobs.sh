#!/usr/bin/env bash

test -z "${randseg_cfg_file}" && exit 1
test -z "${randseg_hparams_folder}" && exit 1

get_nth_row () {
    local nth=$1
    head -n $nth | tail -n 1
}

srun_cmd="""srun \
	--partition guest-gpu \
	--account guest \
	--qos low-gpu \
	--gres gpu:V100:1 \
	--ntasks 1 \
	--cpus-per-task 4 \
	--mem-per-cpu 2G
    --mail-user=jonnesaleva@brandeis.edu \
    --mail-type=END \
    --export=ALL
"""

# Get it all back on one line
srun_cmd=$(echo $srun_cmd)

# Set env var `randseg_hparams_folder` to a folder
# where each SLURM worker can pick tasks from TSV
hparams_file=${randseg_hparams_folder}/hparams.tsv
n_hparams=$(wc -l $hparams_file | cut -f1 -d' ')

parallel --jobs $n_hparams "${srun_cmd} ./singlegpu_sweep.sh {1}" :::: ${hparams_file}
