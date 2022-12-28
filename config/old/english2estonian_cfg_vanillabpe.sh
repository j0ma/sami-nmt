#!/usr/bin/env bash

export randseg_experiment_name=english2estonian
export randseg_random_seed=2022
export randseg_pick_randomly=no
export randseg_num_merges=5000
export randseg_root_folder=./experiments
export randseg_raw_data_folder=./data/est-eng
export randseg_model_name=transformer_vanillabpe_${randseg_num_merges}mops_${randseg_random_seed}
export randseg_checkpoints_folder=./bin/randseg_ckpt_eng_est_vanillabpe_${randseg_random_seed}_$(date +%s)
export randseg_binarized_data_folder=./bin/randseg_bindata_eng_est_vanillabpe_${randseg_random_seed}_$(date +%s)
export randseg_source_language=eng
export randseg_target_language=est

mkdir -p $randseg_checkpoints_folder $randseg_binarized_data_folder
