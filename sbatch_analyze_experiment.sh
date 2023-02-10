#!/usr/bin/env bash

#SBATCH --cpus-per-task=4
#SBATCH --mem=8G
#SBATCH --ntasks=1
#SBATCH --account=guest
#SBATCH --partition=guest-compute
#SBATCH --qos=low
#SBATCH --export=ALL
#SBATCH --requeue
#SBATCH --mail-user=jonnesaleva@brandeis.edu
#SBATCH --mail-type=ALL
#SBATCH --output=scratch/slurmlog/analyze-experiment-%j.out

test -z "${randseg_exp_folder}" && exit 1
test -z "${randseg_cfg_folder}" && exit 1

echo "Analyzing experiment: ${randseg_exp_folder}"

activate_conda_env () {
    source /home/$(whoami)/miniconda3/etc/profile.d/conda.sh
    conda activate randseg
}

activate_conda_env

target_language=${target_language} analyze_further=yes \
bash scripts/analyze_experiment.sh \
    "${randseg_exp_folder}" \
    "${randseg_cfg_folder}"
