#!/usr/bin/env bash

export randseg_pick_randomly=no
export randseg_uniform=no
export randseg_root_folder=./experiments
export randseg_raw_data_folder=./data/fin-sme/bidirectional_baseline
export randseg_source_language=src
export randseg_target_language=tgt
export randseg_checkpoints_folder=./fin_sme_bin/bidirectional_baseline_${randseg_model_name}_${randseg_num_merges}merges_$(date +%s)
export randseg_binarized_data_folder=./fin_sme_bin/bidirectional_baseline_${randseg_model_name}_${randseg_num_merges}merges_$(date +%s)
export randseg_model_name=bidirectional_baseline_${randseg_num_merges}merges

mkdir -p $randseg_checkpoints_folder $randseg_binarized_data_folder

export randseg_max_tokens="17000" 
export randseg_max_update="15000"
