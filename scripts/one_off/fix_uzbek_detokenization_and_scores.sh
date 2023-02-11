#!/usr/bin/env bash

set -euo pipefail

source ~/randbpe/scripts/bpe_functions.sh

exp_folder=$1
eval_folder="${exp_folder}/eval"

pushd $eval_folder

for individual_eval_folder in ./*;
do
    echo $individual_eval_folder
    pushd $individual_eval_folder
    for split in "valid" "test"
    do
        reverse_bpe_segmentation ${split}.gold ${split}.gold.detok &
        reverse_bpe_segmentation ${split}.hyps ${split}.hyps.detok &
        reverse_bpe_segmentation ${split}.source ${split}.source.detok &
    done
    popd
    wait
done
