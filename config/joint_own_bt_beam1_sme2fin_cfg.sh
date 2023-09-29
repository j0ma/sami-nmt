#!/usr/bin/env bash

export randseg_pick_randomly=no
export randseg_uniform=no
export randseg_root_folder=./experiments
export randseg_raw_data_folder=./data/fin-sme/own_bt_beam1
export randseg_source_language=sme
export randseg_target_language=fin
export randseg_checkpoints_folder=./sme_fin_bin/own_bt_beam1_checkpoints_$(date +%s)
export randseg_binarized_data_folder=./sme_fin_bin/own_bt_beam1_bindata_$(date +%s)
export randseg_model_name=own_bt_beam1_${randseg_num_merges}merges

mkdir -p $randseg_checkpoints_folder $randseg_binarized_data_folder

export randseg_max_tokens="17000" 
export randseg_max_update="15000"
export randseg_joint_subwords=yes
export randseg_lr=0.001
