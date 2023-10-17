#!/usr/bin/env bash

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
