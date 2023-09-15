#!/usr/bin/env bash

export randseg_pick_randomly=no
export randseg_uniform=no
export randseg_root_folder=./experiments
export randseg_raw_data_folder=./data/fin-sme/own_bt_huge2_fin2sme
export randseg_source_language=fin
export randseg_target_language=sme
export randseg_checkpoints_folder=./fin_sme_bin/own_bt_huge2_checkpoints_$(date +%s)
export randseg_binarized_data_folder=./fin_sme_bin/own_bt_huge2_bindata_$(date +%s)
export randseg_model_name=own_bt_huge2

mkdir -p $randseg_checkpoints_folder $randseg_binarized_data_folder

export randseg_max_tokens="17000" 
export randseg_max_update="15000"
