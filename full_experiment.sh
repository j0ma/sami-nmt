#!/usr/bin/env bash

# Complete experiment sequence
set -xeo pipefail

echo "Execution environment:"
env

source scripts/subword_functions.sh
for experiment_function_file in scripts/experiment_functions/*.sh
do
    source "${experiment_function_file}"
done

# Constants
config_file=$1
should_confirm=${2:-"true"}

cuda_visible=${CUDA_VISIBLE_DEVICES:-""}

yle_raw_data_folder=$(realpath ./data/fin-sme/yle/)

# Read in names of environment variables to check
mapfile -t check_these_vars < ./config/mandatory_environment_variables.txt

activate_conda_env () {
    source /home/$(whoami)/miniconda3/etc/profile.d/conda.sh
    conda activate randseg
}

check_deps() {
    echo "❗  Checking dependencies..."
    while read -r dep; do
        test -z "$(which $dep)" &&
            echo "Missing dependency: ${dep}" &&
            exit 1 || echo "Found ${dep} ➡  $(which $dep)"
    done <requirements_external.txt
    echo "✅  Dependencies seem OK"
}

check_env() {
    echo "❗ Checking environment..."

    # First fill optionals with defaults
    source config/default_hparams.sh

    # Then source the config
    source "${config}"

    # Then check mandatory variables
    missing=false
    for var in "${check_these_vars[@]}"; do
        eval "test -z \$$var" &&
            echo "Missing variable: $var" &&
            missing="true"
    done
    test "$missing" = "true" && exit 1

    echo "✅  Environment seems OK"
}

create_experiment() {
    echo "❗ Creating experiment..."

    prepx create \
        --with-tensorboard --with-supplemental-data \
        --root-folder="${randseg_root_folder}" \
        --experiment-name="${randseg_experiment_name}" \
        --train-name="${randseg_model_name}" \
        --raw-data-folder="${randseg_raw_data_folder}" \
        --checkpoints-folder="${randseg_checkpoints_folder}" \
        --binarized-data-folder="${randseg_binarized_data_folder}" || echo "Error creating experiment folder! Maybe it exists already?"

    echo "✅  Done!"
}

create_yle_eval_folder() {
    echo "❗ Creating  eval folder"

    local new_eval_name="eval_yle_${randseg_model_name}"
    local raw_data_folder=${yle_raw_data_folder}
    local train_folder=./experiments/${randseg_experiment_name}/train/${randseg_model_name}
    local binarized_data_folder=/dev/null # yle will be evaluated using fairseq-interactive

    local experiments_folder=$(realpath ${train_folder}/../../../)
    local experiment_name=$(basename $(realpath ${train_folder}/../../))

    prepx create \
        --eval-only \
        --eval-name ${new_eval_name} \
        --raw-data-folder ${raw_data_folder} \
        --binarized-data-folder ${binarized_data_folder} \
        --eval-checkpoint ${train_folder}/checkpoints/checkpoint_best.pt \
        --root-folder ${experiments_folder} \
        --experiment-name ${experiment_name} || echo "Failed to create eval! Maybe it exists already?"
}

reverse_subword_segmentation () {
    local input_file=$1
    local output_file=$2

    if [ "${character_level_model}" = "yes" ]
    then
        reverse_character_segmentation \
            "${input_file}" \
            "${output_file}"
    elif [ "$randseg_use_sentencepiece" = "yes" ]
    then
        reverse_sentencepiece_segmentation \
            "${input_file}" \
            "${output_file}"
    else
        reverse_bpe_segmentation \
            "${input_file}" \
            "${output_file}"
    fi

}

construct_command () {
    local command_name=$1
    local flag=$2
    #test "${flag}" = "yes" && echo "${command_name}" || echo "skip"
    if [ "${should_confirm}" = "yes" ] 
    then
        echo "${command_name}"
    elif [ "${flag}" = "yes" ] 
    then
        echo "${command_name}"
    else
        echo "skip"
    fi
}

main() {
    local config=$1
    local should_confirm_commands=${2:-"true"}

    activate_conda_env

    confirm_commands_flag=$(
        test "${should_confirm_commands}" = "false" &&
            echo "cat" ||
            echo "fzf --sync --multi"
    )

    # These should always happen
    check_deps
    check_env

    create_experiment_flag=$(construct_command create_experiment $randseg_should_create_experiment)
    preprocess_flag=$(construct_command preprocess_for_translation $randseg_should_preprocess)
    train_flag=$(construct_command train $randseg_should_train)
    evaluate_flag=$(construct_command evaluate $randseg_should_evaluate)

    echo "$create_experiment_flag" "$preprocess_flag" "$train_flag" "$evaluate_flag" |
        tr " " "\n" |
        ${confirm_commands_flag} |
        while read command; do
            if [ "$command" = "skip" ]; then
                continue
            elif [ "$command" = "evaluate" ]; then
                for split in "dev" "test"; do evaluate $split; done
            elif [ "$command" = "create_experiment" ]; then
                create_experiment
                if [ "${randseg_eval_yle}" = "yes" ]
                then
                    create_yle_eval_folder
                fi
            else
                $command
            fi
        done
}

main "${config_file}" "${should_confirm}"
