#!/usr/bin/env bash

set -euo pipefail

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

apply_bpe() {
    local text_file=$1
    local codes_file=$2
    local out_file=$3

    subword-nmt apply-bpe \
        -c "${codes_file}" \
        <"${text_file}" \
        >"${out_file}"
}

get_vocab() {
    local text_file=$1
    local vocab_file=$2
    subword-nmt get-vocab \
        -i "${text_file}" \
        -o "${vocab_file}"
}

reverse_bpe_segmentation() {
    local text_file=$1
    local out_file=$2
    sed -r 's/(@@ )|(@@ ?$)//g' \
        <"${text_file}" \
        >"${out_file}"
}

main() {
    local text_file=$1
    local out_file=$2
    local vocab_file=$3
    local codes_file=$4
    local num_operations=$5
    local pick_randomly=$6
    local random_bpe_seed=$7

    check_args
    learn_bpe \
        "${text_file}" \
        "${num_operations}" \
        "${codes_file}" \
        "${pick_randomly}" \
        "${random_bpe_seed}"
    apply_bpe \
        "${text_file}" \
        "${codes_file}" \
        "${out_file}"

    get_vocab "${out_file}" "${vocab_file}"
}

