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

    if [ "${should_confirm_commands}" = "yes" ]
    then
        commands_to_run_file=$(mktemp)
        echo "create_experiment,preprocess_for_translation,train,evaluate,evaluate_yle" | tr "," "\t" | fzf --multi > ${commands_to_run_file}
        mapfile -t commands_to_run < ${commands_to_run_file}
    else
        commands_to_run=( "create_experiment" "preprocess_for_translation" "train" "evaluate" "evaluate_yle" )
    fi

    # These should always happen
    check_deps
    check_env

    for command in "${commands_to_run[@]}"
    do
        if [ "$command" = "evaluate" ]; then
            evaluate "dev"
            evaluate "test"
        elif [ "$command" = "evaluate_yle" ]; then
            run_yle_eval
        else
            $command
        fi
    done
}

main "${config_file}" "${should_confirm}"
