#!/usr/bin/env bash

parse_json_hparams() {
    local hparams=$1
    for key in $(echo $hparams | jq -r 'keys[]'); do
        export $key=$(echo $hparams | jq -r --arg k "$key" '.[$k]')
    done
}

sort_out_hyperparams() {
    local hparams_line=$1
    parse_json_hparams "${hparams_line}"
    data_and_cfg_json=$(
        python scripts/resolve_data_folder_and_cfg_file.py \
            --direction "${randseg_direction}" \
            --train-data-type "${randseg_train_data_type}"
    )

    export randseg_raw_data_folder=$(echo ${data_and_cfg_json} | jq -r '.data_folder')
    export randseg_cfg_file=$(echo ${data_and_cfg_json} | jq -r '.cfg_file')
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
