#!/usr/bin/env bash

env

test -z "${randseg_cfg_file}" && exit 1

run_single_exp () {
    local gpu_idx=$1
    shift
    local hparams=$@
    shift

    export randseg_random_seed=$(echo $hparams | cut -f1 -d' ')
    export randseg_num_merges=$(echo $hparams | cut -f2 -d' ')
    export randseg_temperature=$(echo $hparams | cut -f3 -d' ')

    echo "gpu: ${gpu_idx}"
    echo "seed: ${randseg_random_seed}"
    echo "mops: ${randseg_num_merges}"
    echo "temp: ${randseg_temperature}"

    CUDA_VISIBLE_DEVICES=${gpu_idx} ./full_experiment.sh "${randseg_cfg_file}" false false

}

export -f run_single_exp

gpus=$(echo $CUDA_VISIBLE_DEVICES | tr "," " ")
num_gpus=$(echo $CUDA_VISIBLE_DEVICES | tr "," "\n" | wc -l)
echo "Number of GPUs: $num_gpus"

run_single_exp "${gpus}" $@
