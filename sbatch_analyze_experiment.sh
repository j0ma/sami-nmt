#!/usr/bin/env bash

#SBATCH --cpus-per-task=32
#SBATCH --mem=64G
#SBATCH --ntasks=1
#SBATCH --account=guest
#SBATCH --partition=guest-gpu
#SBATCH --qos=low-gpu
#SBATCH --export=ALL
#SBATCH --requeue
#SBATCH --gres=gpu:1
#SBATCH --mail-user=jonnesaleva@brandeis.edu
#SBATCH --mail-type=ALL
#SBATCH --output=analyze-experiment-%j.out

test -z "${randseg_exp_folder}" && exit 1
test -z "${randseg_cfg_folder}" && exit 1

echo "Analyzing experiment: ${randseg_exp_folder}"

activate_conda_env () {
    source /home/$(whoami)/miniconda3/etc/profile.d/conda.sh
    conda activate randseg
}

activate_conda_env

bash scripts/analyze_experiment.sh \
    "${randseg_exp_folder}" \
    "${randseg_cfg_folder}"
