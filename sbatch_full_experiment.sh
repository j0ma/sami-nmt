#!/usr/bin/env bash

#SBATCH --cpus-per-task=32
#SBATCH --mem=64G
#SBATCH --ntasks=1
#SBATCH --account=guest
#SBATCH --partition=guest-gpu
#SBATCH --qos=low-gpu
#SBATCH --export=ALL
#SBATCH --requeue
#SBATCH --gres=gpu:V100:1
#SBATCH --mail-user=jonnesaleva@brandeis.edu
#SBATCH --mail-type=ALL

test -z "${randseg_cfg_file}" && exit 1

get_nth_row () {
    local nth=$1
    head -n $nth | tail -n 1
}

hparams=$(tail -n +2 config/sweep_conditions.tsv | get_nth_row ${SLURM_ARRAY_TASK_ID})
rand_seed=$(echo $hparams | cut -f1 -d' ')
num_merges=$(echo $hparams | cut -f2 -d' ')
temperature=$(echo $hparams | cut -f3 -d' ')

echo "seed: ${rand_seed}"
echo "num_merges: ${num_merges}"
echo "temperature: ${temperature}"

#./full_experiment.sh \
    #"${randseg_cfg_file}" false false
