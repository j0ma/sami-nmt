#!/usr/bin/env bash

# Rescores all experiments in an eval

score_individual_experiment () {
    local exp_folder=$1
    eval_folder="${exp_folder}/eval/"
    local exp_name=$2
    local split=$3
    local metric=$4
    local use_detok=${5:-yes}

    if [ "${use_detok}" = "yes" ]
    then
        export detok_suffix=".detok"
    else
        export detok_suffix=""
    fi

    score_this_folder="${eval_folder}/${exp_name}"

    pushd $score_this_folder
    
    # get sacrebleu scores
    sacrebleu ${split}.gold${detok_suffix} -i ${split}.hyps${detok_suffix} -b -m ${metric} -w 4 > ${split}.eval.score_sacrebleu_${metric}

}

export -f score_individual_experiment

experiment_folder=$(realpath $1)

export use_detok=${use_detok:-yes}

parallel --bar --progress "score_individual_experiment ${experiment_folder} {1} {2} {3} ${use_detok}" ::: $(ls $experiment_folder/eval) ::: "test" "valid" ::: bleu chrf
