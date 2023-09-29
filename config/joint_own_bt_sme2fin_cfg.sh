#!/usr/bin/env bash

export randseg_pick_randomly=no
export randseg_uniform=no
export randseg_root_folder=./experiments
export randseg_raw_data_folder=./data/fin-sme/own_bt_onceonly
export randseg_source_language=sme
export randseg_target_language=fin
export randseg_checkpoints_folder=./sme_fin_bin/own_bt_checkpoints_$(date +%s)
export randseg_binarized_data_folder=./sme_fin_bin/own_bt_bindata_$(date +%s)
export randseg_model_name=own_bt_${randseg_num_merges}merges

mkdir -p $randseg_checkpoints_folder $randseg_binarized_data_folder

export randseg_max_tokens="20000" 
export randseg_max_update="15000"
export randseg_joint_subwords=yes
export randseg_lr=0.001
