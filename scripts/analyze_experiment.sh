#!/usr/bin/env bash

set -euo pipefail

. scripts/seq_length_functions.sh

experiment_path=$1
sweep_cfg_folder=${2:-""}

tgt_lang=${target_language:-uzb}
should_analyze_further=${analyze_further:-""}
split=${split:-test}

# constants
train_folder="$experiment_path/train"
eval_folder="$experiment_path/eval"
supp_folder="$train_folder/supplemental_data"

# how many started/finished?
num_started=$(ls $train_folder | wc -l)
num_finished=$(find $eval_folder -name ${split}.eval.score | wc -l)

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

PS3="Should we get BLEU results and analyze the vocabulary? "

if [ -z "${should_analyze_further}" ]
then
    select should_analyze_further in "yes" "no"
    do
        export should_analyze_further=${should_analyze_further}
        break
    done
fi

if [ "${should_analyze_further}" = "yes" ]; then

    # Sweep results (BLEU)
    echo "Getting sweep results..."
    parallel --tag --bar --progress \
        "cat" ::: \
        $eval_folder/*/valid.eval.score_sacrebleu_bleu | \
        sort | tee $experiment_path/sweep_results_valid_bleu.tsv

    parallel --tag --bar --progress \
        "cat" ::: \
        $eval_folder/*/valid.eval.score_sacrebleu_chrf | \
        sort | tee $experiment_path/sweep_results_valid_chrf.tsv

    parallel --tag --bar --progress \
        "cat" ::: \
        $eval_folder/*/test.eval.score_sacrebleu_bleu | \
        sort | tee $experiment_path/sweep_results_test_bleu.tsv

    parallel --tag --bar --progress \
        "cat" ::: \
        $eval_folder/*/test.eval.score_sacrebleu_chrf | \
        sort | tee $experiment_path/sweep_results_test_chrf.tsv

    # Analyze the text data
    #echo "Analyzing BPE text data..."
    #parallel --jobs 1 --bar --progress \
        #"bash scripts/analyze_text_data.sh {1} eng ${tgt_lang}" ::: \
        #$(find $train_folder -type d -name supplemental_data)
fi
