#!/usr/bin/env bash

export randseg_pick_randomly=no
export randseg_uniform=no
export randseg_root_folder=./experiments
export randseg_raw_data_folder=./data/fin-sme/clean_rbmt_nmt_bt
export randseg_source_language=fin
export randseg_target_language=sme
export randseg_checkpoints_folder=./fin_sme_bin/sweep_randseg_ckpt_fin_sme_vanillabpe_clean_rbmt_nmt_bt_${randseg_num_merges}mops_${randseg_random_seed}_temperature${randseg_temperature}_$(date +%s)
export randseg_binarized_data_folder=./fin_sme_bin/sweep_randseg_bindata_fin_sme_vanillabpe_clean_rbmt_nmt_bt_${randseg_num_merges}mops_${randseg_random_seed}_temperature${randseg_temperature}_$(date +%s)
export randseg_model_name=clean_rbmt_nmt

mkdir -p $randseg_checkpoints_folder $randseg_binarized_data_folder

export randseg_max_tokens="16000" 
export randseg_max_update="15000"
