#!/usr/bin/env bash

set -euo pipefail

. scripts/seq_length_functions.sh

experiment_path=$1
sweep_cfg_folder=${2:-""}

# constants
train_folder="$experiment_path/train"
eval_folder="$experiment_path/eval"
supp_folder="$train_folder/supplemental_data"

# how many started/finished?
num_started=$(ls $train_folder | wc -l)
num_finished=$(ls $eval_folder/*/valid.eval.score | wc -l)

if [ -z "${sweep_cfg_folder}" ]; then
    echo "Experiment: ${experiment_path}"
    echo "Num started: ${num_started}"
    echo "Num finished: ${num_finished}"
else
    n_total_configs=$(cat ${sweep_cfg_folder}/*.tsv | wc -l)
    echo "Experiment: ${experiment_path}"
    echo "Num started: ${num_started} / ${n_total_configs}"
    echo "Num finished: ${num_finished} / ${n_total_configs}"
fi

# Sweep results (BLEU)
echo "Getting sweep results..."
parallel --tag --bar --progress \
    "tail -n 1 {1} | cut -f2" ::: \
    $eval_folder/*/valid.eval.score | \
    sort | tee $experiment_path/sweep_results.tsv

# Analyze the text data
echo "Analyzing BPE text data..."
parallel --jobs 1 --bar --progress \
    "bash scripts/analyze_text_data.sh {1} eng uzb" ::: \
    $(find $train_folder -type d -name supplemental_data)

