#!/usr/bin/env bash

#SBATCH --cpus-per-task=16
#SBATCH --mem=16G
#SBATCH --ntasks=1
#SBATCH --account=guest
#SBATCH --partition=guest-gpu
#SBATCH --qos=low-gpu
#SBATCH --export=ALL
#SBATCH --requeue
#SBATCH --gres=gpu:V100:1
#SBATCH --mail-user=jonnesaleva@brandeis.edu
#SBATCH --mail-type=FAIL,CANCEL
#SBATCH --output=%x-%j.out

env

test -z "${randseg_cfg_file}" && exit 1
test -z "${randseg_existing_train_folder}" && exit 1

run_single_exp () {
    local gpu_idx=$1
    shift

    CUDA_VISIBLE_DEVICES=${gpu_idx} \
        ./run_new_eval_existing_model.sh \
        "${randseg_cfg_file}" false false

}

export -f run_single_exp

gpus=$(echo $CUDA_VISIBLE_DEVICES | tr "," " ")
num_gpus=$(echo $CUDA_VISIBLE_DEVICES | tr "," "\n" | wc -l)
taskid=${SLURM_ARRAY_TASK_ID}

echo "Number of GPUs: $num_gpus"
parallel --jobs $num_gpus --link "run_single_exp {1} {2}" ::: ${gpus} :::: $hparams_file
