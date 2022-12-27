#!/usr/bin/env bash

export randseg_experiment_name=english2finnish
export randseg_random_seed=2022
export randseg_pick_randomly=yes
export randseg_num_merges=5000
export randseg_root_folder=./experiments
export randseg_raw_data_folder=./data/eng-fin
export randseg_model_name=transformer_randbpe_${randseg_num_merges}mops_${randseg_random_seed}
export randseg_checkpoints_folder=./bin/randseg_ckpt_eng_fin_randbpe_${randseg_random_seed}_$(date +%s)
export randseg_binarized_data_folder=./bin/randseg_bindata_eng_fin_randbpe_${randseg_random_seed}_$(date +%s)
export randseg_source_language=eng
export randseg_target_language=fin

mkdir -p $randseg_checkpoints_folder $randseg_binarized_data_folder
