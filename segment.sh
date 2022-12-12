#!/usr/bin/env bash

text_file=$1
out_file=$2
vocab_file=$3
codes_file=$4
num_operations=$5
pick_randomly=${6:-yes}
random_bpe_seed=${7:-1917}

order=3 # unused?
size=3  # unused?

check_these_vars=(
    "text_file"
    "out_file"
    "vocab_file"
    "codes_file"
    "num_operations"
    "pick_randomly"
    "random_bpe_seed"
)

check_args() {
    echo "❗ Checking environment..."

    # First check mandatory variables
    for var in "${check_these_vars[@]}"; do
        eval "test -z \$$var" &&
            echo "Missing variable: $var" &&
            missing="true" || missing="false"
    done
    test "$missing" = "true" && exit 1

    echo "✅  Environment seems OK"
}

learn_bpe() {
    local text_file=$1
    local num_operations=$2
    local codes_file=$3
    local pick_randomly=$4
    local random_bpe_seed=$5

    pick_randomly_flag=$(
        test "${pick_randomly}" = "yes" &&
            echo "--pick-randomly --random-seed-for-merges ${random_bpe_seed}" ||
            echo ""
    )

    subword-nmt learn-bpe \
        $pick_randomly_flag \
        -s "${num_operations}" \
        <"${text_file}" \
        >"${codes_file}"
}

learn_bpe() {
    local text_file=$1
    local codes_file=$2
    local out_file=$3

    subword-nmt apply-bpe \
        -c "${codes_file}" \
        <"${text_file}" \
        >"${out_file}"
}

get_vocab() {
    # To segment rare words into character n-grams, do the following:
    local text_file=$1
    local vocab_file=$2
    local order=$3
    local size=$4
    subword-nmt get-vocab \
        --text_file "${text_file}" \
        --vocab_file "${vocab_file}"

    subword-nmt segment-char-ngrams \
        --vocab "${vocab_file}" \
        -n "${order}" \
        --shortlist "${ize}" \
        <"${text_file}" \
        >"${out_file}"
}

reverse_bpe_segmentation() {
    local text_file=$1
    local out_file=$1
    sed -r 's/(@@ )|(@@ ?$)//g' \
        <"${text_file}" \
        >"${out_file}"
}

check_args
