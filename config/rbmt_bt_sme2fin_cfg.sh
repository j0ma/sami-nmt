#!/usr/bin/env bash

export randseg_pick_randomly=no
export randseg_uniform=no
export randseg_root_folder=./experiments
export randseg_raw_data_folder=./data/fin-sme/rbmt_bt
export randseg_source_language=sme
export randseg_target_language=fin
export randseg_checkpoints_folder=./sme_fin_bin/sweep_randseg_ckpt_sme_fin_vanillabpe_rbmt_bt_${randseg_num_merges}mops_${randseg_random_seed}_temperature${randseg_temperature}_$(date +%s)
export randseg_binarized_data_folder=./sme_fin_bin/sweep_randseg_bindata_sme_fin_vanillabpe_rbmt_bt_${randseg_num_merges}mops_${randseg_random_seed}_temperature${randseg_temperature}_$(date +%s)
export randseg_model_name=transformer_vanillabpe_rbmt_bt_${randseg_num_merges}mops_${randseg_random_seed}_temperature${randseg_temperature}

mkdir -p $randseg_checkpoints_folder $randseg_binarized_data_folder

export randseg_max_tokens="3600" #0"
export randseg_max_update="30000"
