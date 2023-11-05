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
should_confirm_commands=${2:-"yes"}

# Check if CUDA is visible and if not, inform the user about CPU mode
cuda_visible=${CUDA_VISIBLE_DEVICES:-""}
if [ -z "${cuda_visible}" ]
then
    echo "❗ [full_experiment.sh] WARNING: CUDA_VISIBLE_DEVICES is not set. Running in CPU mode."
fi

yle_raw_data_folder=$(realpath ./data/fin-sme/yle/)

# Read in names of environment variables to check
mapfile -t check_these_vars < ./config/mandatory_environment_variables.txt

# if should_confirm_commands=no, add the should-variables to check_these_vars
if [ "${should_confirm_commands}" != "yes" ]
then
    check_these_vars+=("should_create_experiment")
    check_these_vars+=("should_preprocess")
    check_these_vars+=("should_train")
    check_these_vars+=("should_evaluate")
fi

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
    missing=no
    for var in "${check_these_vars[@]}"; do
        eval "test -z \$$var" &&
            echo "Missing variable: $var" &&
            missing="yes"
    done
    test "$missing" = "yes" && exit 1

    echo "✅  Environment seems OK"
}


construct_command () {
    local command_name=$1
    local flag=$2
    if [ "${should_confirm_commands}" = "yes" ]
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
    local should_confirm_commands=${2:-"yes"}

    activate_conda_env

    confirm_commands_flag=$(
        test "${should_confirm_commands}" = "no" &&
            echo "cat" ||
            echo "fzf --sync --multi"
    )

    if [ "${should_confirm_commands}" = "yes" ]
    then
        commands_to_run_file=$(mktemp)
        echo "create_experiment,preprocess_for_translation,train,evaluate,evaluate_yle" | tr "," "\n" | fzf --multi > ${commands_to_run_file}
        mapfile -t commands_to_run < ${commands_to_run_file}
    else
        commands_to_run=( "create_experiment" "preprocess" "train" "evaluate" "evaluate_yle" )
    fi

    # These should always happen
    check_deps
    check_env

    for command in "${commands_to_run[@]}"
    do
        if [ "$command" = "evaluate" ]; then
            evaluate "dev"
            evaluate "test"
        elif [ "$command" = "preprocess" ]; then
            preprocess_for_translation
        elif [ "$command" = "evaluate_yle" ]; then
            run_yle_eval
        else
            $command
        fi
    done
}

main "${config_file}" "${should_confirm_commands}"
