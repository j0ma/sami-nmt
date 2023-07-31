#!/usr/bin/env bash

export randseg_pick_randomly=no
export randseg_uniform=no
export randseg_root_folder=./experiments
export randseg_raw_data_folder=./data/fin-sme
export randseg_source_language=sme
export randseg_target_language=fin
export randseg_model_name=baseline
export randseg_checkpoints_folder=./sme_fin_bin/fin2sme_${randseg_model_name}_$(date +%s)
export randseg_binarized_data_folder=./sme_fin_bin/fin2sme_${randseg_model_name}_$(date +%s)

mkdir -p $randseg_checkpoints_folder $randseg_binarized_data_folder

export randseg_max_tokens="60000" 
export randseg_max_update="15000"
