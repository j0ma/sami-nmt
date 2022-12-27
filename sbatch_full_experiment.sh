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

./full_experiment.sh \
    "${randseg_cfg_file}" false false
